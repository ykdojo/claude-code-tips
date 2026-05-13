#!/usr/bin/env node
/**
 * Repack patched cli.js into Claude Code native binary
 * Uses in-place replacement to avoid issues with overlapping Bun string pointers
 * Supports ELF (Linux) and Mach-O (macOS) formats
 */

const LIEF = require("node-lief");
const fs = require("fs");
const { execSync } = require("child_process");

const BUN_TRAILER = Buffer.from("\n---- Bun! ----\n");
const SIZEOF_OFFSETS = 32;
const SIZEOF_STRING_POINTER = 8;
const SIZEOF_MODULE_V1 = 4 * SIZEOF_STRING_POINTER + 4; // 36 bytes (Bun < 1.3.9)
const SIZEOF_MODULE_V2 = 4 * SIZEOF_STRING_POINTER + 4 + 16; // 52 bytes (Bun >= 1.3.9, added extra field)

function detectModuleSize(modulesListLength) {
  if (modulesListLength % SIZEOF_MODULE_V2 === 0) return SIZEOF_MODULE_V2;
  if (modulesListLength % SIZEOF_MODULE_V1 === 0) return SIZEOF_MODULE_V1;
  return SIZEOF_MODULE_V1; // fallback
}

function parseStringPointer(buffer, offset) {
  return { offset: buffer.readUInt32LE(offset), length: buffer.readUInt32LE(offset + 4) };
}

function writeStringPointer(buffer, offset, sp) {
  buffer.writeUInt32LE(sp.offset, offset);
  buffer.writeUInt32LE(sp.length, offset + 4);
}

function parseOffsets(buffer) {
  let pos = 0;
  const byteCount = buffer.readBigUInt64LE(pos); pos += 8;
  const modulesPtr = parseStringPointer(buffer, pos); pos += 8;
  const entryPointId = buffer.readUInt32LE(pos); pos += 4;
  const compileExecArgvPtr = parseStringPointer(buffer, pos);
  return { byteCount, modulesPtr, entryPointId, compileExecArgvPtr };
}

function getStringPointerContent(buffer, sp) {
  return buffer.subarray(sp.offset, sp.offset + sp.length);
}

function parseModule(buffer, offset) {
  let pos = offset;
  return {
    name: parseStringPointer(buffer, pos), contents: parseStringPointer(buffer, pos + 8),
    sourcemap: parseStringPointer(buffer, pos + 16), bytecode: parseStringPointer(buffer, pos + 24),
    encoding: buffer.readUInt8(pos + 32), loader: buffer.readUInt8(pos + 33),
    moduleFormat: buffer.readUInt8(pos + 34), side: buffer.readUInt8(pos + 35)
  };
}

function isClaudeModule(name) {
  return name.endsWith("/claude") || name === "claude" ||
         name.endsWith("/claude.exe") || name === "claude.exe" ||
         name.endsWith("/cli.js");
}

function extractBunDataFromSection(sectionData) {
  const bunDataSizeU64 = sectionData.length >= 8 ? Number(sectionData.readBigUInt64LE(0)) : 0;
  const bunDataSizeU32 = sectionData.readUInt32LE(0);
  let headerSize, bunDataSize;
  if (sectionData.length >= 8 && 8 + bunDataSizeU64 <= sectionData.length && 8 + bunDataSizeU64 >= sectionData.length - 4096) {
    headerSize = 8; bunDataSize = bunDataSizeU64;
  } else if (4 + bunDataSizeU32 <= sectionData.length && 4 + bunDataSizeU32 >= sectionData.length - 4096) {
    headerSize = 4; bunDataSize = bunDataSizeU32;
  } else {
    throw new Error("Cannot determine section header format");
  }
  const bunDataContent = sectionData.subarray(headerSize, headerSize + bunDataSize);
  const offsetsStart = bunDataContent.length - SIZEOF_OFFSETS - BUN_TRAILER.length;
  const offsetsBytes = bunDataContent.subarray(offsetsStart, offsetsStart + SIZEOF_OFFSETS);
  return { bunOffsets: parseOffsets(offsetsBytes), bunData: bunDataContent, sectionHeaderSize: headerSize };
}

function extractFromELFOverlay(binary) {
  const overlay = binary.overlay;
  const offsetsStart = overlay.length - 8 - BUN_TRAILER.length - SIZEOF_OFFSETS;
  const offsetsBytes = overlay.subarray(offsetsStart, overlay.length - 8 - BUN_TRAILER.length);
  const bunOffsets = parseOffsets(offsetsBytes);
  const tailDataLen = 8 + BUN_TRAILER.length + SIZEOF_OFFSETS;
  const dataStart = overlay.length - tailDataLen - Number(bunOffsets.byteCount);
  const dataRegion = overlay.subarray(dataStart, overlay.length - tailDataLen);
  const trailerBytes = overlay.subarray(overlay.length - 8 - BUN_TRAILER.length, overlay.length - 8);
  return { bunOffsets, bunData: Buffer.concat([dataRegion, offsetsBytes, trailerBytes]), dataStart, useRaw: false };
}

function extractFromELFRaw(binaryPath) {
  const buf = fs.readFileSync(binaryPath);
  const trailerIdx = buf.lastIndexOf(BUN_TRAILER);
  if (trailerIdx === -1) throw new Error("Bun trailer not found in binary");
  const offsetsStart = trailerIdx - SIZEOF_OFFSETS;
  const offsetsBytes = buf.subarray(offsetsStart, trailerIdx);
  const bunOffsets = parseOffsets(offsetsBytes);
  const dataStartInFile = offsetsStart - Number(bunOffsets.byteCount);
  const bunData = buf.subarray(dataStartInFile, trailerIdx + BUN_TRAILER.length);
  return { bunOffsets, bunData, dataStartInFile, useRaw: true };
}

function extractFromELF(binary, binaryPath) {
  if (binary.hasOverlay && binary.overlay.length > 0) {
    return extractFromELFOverlay(binary);
  }
  return extractFromELFRaw(binaryPath);
}

function extractFromMachO(binary) {
  const bunSegment = binary.getSegment("__BUN");
  if (!bunSegment) throw new Error("__BUN segment not found");
  const bunSection = bunSegment.getSection("__bun");
  if (!bunSection) throw new Error("__bun section not found");
  return extractBunDataFromSection(bunSection.content);
}

/**
 * In-place replacement of cli.js contents within the bun data buffer.
 * The old rebuildBunData approach copied each module's strings separately,
 * but Bun uses overlapping string pointers (shared memory regions), causing
 * the rebuilt buffer to be ~13x larger than the original (1.5GB vs 118MB).
 *
 * This approach writes the patched content directly over the original location,
 * padding with semicolons if the patched content is smaller. The module's
 * contents length pointer is updated to reflect the new size (without padding).
 */
function patchBunDataInPlace(bunData, bunOffsets, modifiedClaudeJs) {
  const modulesListBytes = getStringPointerContent(bunData, bunOffsets.modulesPtr);
  const moduleSize = detectModuleSize(modulesListBytes.length);
  const modulesCount = Math.floor(modulesListBytes.length / moduleSize);

  for (let i = 0; i < modulesCount; i++) {
    const module = parseModule(modulesListBytes, i * moduleSize);
    const moduleName = getStringPointerContent(bunData, module.name).toString("utf-8");

    if (isClaudeModule(moduleName)) {
      const origSize = module.contents.length;
      const newSize = modifiedClaudeJs.length;

      if (newSize > origSize) {
        throw new Error(`Patched cli.js (${newSize} bytes) is larger than original (${origSize} bytes). In-place replacement requires patched content to be <= original size.`);
      }

      // Write patched content at the original location
      modifiedClaudeJs.copy(bunData, module.contents.offset);

      // Pad remaining space with semicolons (valid JS no-ops)
      if (newSize < origSize) {
        bunData.fill(0x3B, module.contents.offset + newSize, module.contents.offset + origSize); // 0x3B = ';'
      }

      // Update the contents length in the module list to reflect actual content size.
      // The bytecode pointer may overlap with or follow the contents region, so we
      // keep the original length to avoid shifting any data. The semicolons are
      // harmless JS that won't affect execution.

      console.log(`  Replaced cli.js: ${origSize} -> ${newSize} bytes (${origSize - newSize} bytes padded)`);
      return bunData;
    }
  }

  throw new Error("Claude module not found in bun data");
}

// Main
const binaryPath = process.argv[2];
const patchedCliPath = process.argv[3];
const outputPath = process.argv[4];

if (!binaryPath || !patchedCliPath || !outputPath) {
  console.log("Usage: node native-repack.js <binary> <patched-cli.js> <output>");
  process.exit(1);
}

LIEF.logging.disable();
const binary = LIEF.parse(binaryPath);
const patchedCli = fs.readFileSync(patchedCliPath);

console.log(`Binary format: ${binary.format}`);
console.log(`Patched cli.js: ${patchedCli.length} bytes`);

if (binary.format === "ELF") {
  // For ELF, read the entire binary and do byte-level replacement
  const binaryBuf = fs.readFileSync(binaryPath);
  const result = extractFromELF(binary, binaryPath);
  const { bunData, bunOffsets, useRaw } = result;

  patchBunDataInPlace(bunData, bunOffsets, patchedCli);

  const dataRegionSize = Number(bunOffsets.byteCount);
  if (useRaw) {
    // New format: bunData is a subarray of the file buffer from extractFromELFRaw
    // The data was patched in-place via the subarray, so the file buffer is already updated.
    // But bunData from extractFromELFRaw is a subarray of a separate readFileSync buffer,
    // so we need to write it back to the main buffer.
    bunData.copy(binaryBuf, result.dataStartInFile, 0, dataRegionSize);
  } else {
    // Old format: overlay-based extraction
    const elfSize = binaryBuf.length - binary.overlay.length;
    const overlayOffset = elfSize + result.dataStart;
    bunData.copy(binaryBuf, overlayOffset, 0, dataRegionSize);
  }

  const origStat = fs.statSync(binaryPath);
  fs.writeFileSync(outputPath, binaryBuf);
  fs.chmodSync(outputPath, origStat.mode);

} else if (binary.format === "MachO") {
  // For Mach-O, patch the section data in place via LIEF
  const bunSegment = binary.getSegment("__BUN");
  const bunSection = bunSegment.getSection("__bun");
  const sectionData = Buffer.from(bunSection.content);

  // Determine header size
  const bunDataSizeU64 = sectionData.length >= 8 ? Number(sectionData.readBigUInt64LE(0)) : 0;
  const bunDataSizeU32 = sectionData.readUInt32LE(0);
  let headerSize;
  if (sectionData.length >= 8 && 8 + bunDataSizeU64 <= sectionData.length && 8 + bunDataSizeU64 >= sectionData.length - 4096) {
    headerSize = 8;
  } else if (4 + bunDataSizeU32 <= sectionData.length && 4 + bunDataSizeU32 >= sectionData.length - 4096) {
    headerSize = 4;
  } else {
    throw new Error("Cannot determine section header format");
  }

  const result = extractBunDataFromSection(sectionData);
  patchBunDataInPlace(result.bunData, result.bunOffsets, patchedCli);

  // Write patched bun data back into section data
  result.bunData.copy(sectionData, headerSize);

  if (binary.hasCodeSignature) binary.removeSignature();
  bunSection.content = sectionData;

  const tempPath = outputPath + ".tmp";
  binary.write(tempPath);
  const origStat = fs.statSync(binaryPath);
  fs.chmodSync(tempPath, origStat.mode);
  fs.renameSync(tempPath, outputPath);

  // Re-sign on macOS
  try {
    execSync(`codesign -s - -f "${outputPath}"`, { stdio: "ignore" });
    console.log("Code signed successfully");
  } catch (e) {
    console.warn("Warning: codesign failed, binary may not run");
  }

} else {
  console.error(`Unsupported format: ${binary.format}`);
  process.exit(1);
}

console.log(`Written to: ${outputPath}`);
