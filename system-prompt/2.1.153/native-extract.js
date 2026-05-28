#!/usr/bin/env node
/**
 * Extract cli.js from Claude Code native binary
 * Supports ELF (Linux) and Mach-O (macOS) formats
 */

const LIEF = require("node-lief");
const fs = require("fs");

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
  // Try u64 header first (Bun >= 1.3.4), then u32
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
  const trailerStart = bunDataContent.length - BUN_TRAILER.length;
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
  return { bunOffsets, bunData: Buffer.concat([dataRegion, offsetsBytes, trailerBytes]) };
}

function extractFromELFRaw(binaryPath) {
  const buf = fs.readFileSync(binaryPath);
  const trailerIdx = buf.lastIndexOf(BUN_TRAILER);
  if (trailerIdx === -1) throw new Error("Bun trailer not found in binary");
  const offsetsStart = trailerIdx - SIZEOF_OFFSETS;
  const offsetsBytes = buf.subarray(offsetsStart, trailerIdx);
  const bunOffsets = parseOffsets(offsetsBytes);
  const dataStart = offsetsStart - Number(bunOffsets.byteCount);
  const bunData = buf.subarray(dataStart, trailerIdx + BUN_TRAILER.length);
  return { bunOffsets, bunData, dataStartInFile: dataStart };
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

function extract(binaryPath) {
  LIEF.logging.disable();
  const binary = LIEF.parse(binaryPath);

  let bunData, bunOffsets;
  if (binary.format === "ELF") {
    ({ bunData, bunOffsets } = extractFromELF(binary, binaryPath));
  } else if (binary.format === "MachO") {
    ({ bunData, bunOffsets } = extractFromMachO(binary));
  } else {
    throw new Error(`Unsupported format: ${binary.format}`);
  }

  const modulesListBytes = getStringPointerContent(bunData, bunOffsets.modulesPtr);
  const moduleSize = detectModuleSize(modulesListBytes.length);
  const modulesCount = Math.floor(modulesListBytes.length / moduleSize);

  for (let i = 0; i < modulesCount; i++) {
    const module = parseModule(modulesListBytes, i * moduleSize);
    const moduleName = getStringPointerContent(bunData, module.name).toString("utf-8");
    if (isClaudeModule(moduleName)) {
      return getStringPointerContent(bunData, module.contents);
    }
  }
  throw new Error("Claude module not found");
}

// Main
const binaryPath = process.argv[2] || `${process.env.HOME}/.local/share/claude/versions/2.1.17`;
const outputPath = process.argv[3] || "/tmp/native-cli.js";

try {
  console.log(`Extracting from: ${binaryPath}`);
  const cliJs = extract(binaryPath);
  fs.writeFileSync(outputPath, cliJs);
  console.log(`Extracted to: ${outputPath} (${cliJs.length} bytes)`);
} catch (err) {
  console.error("Error:", err.message);
  process.exit(1);
}
