#!/usr/bin/env node
/**
 * Patch script for Claude Code CLI system prompt
 * Always restores from backup first, then applies patches
 */

const fs = require('fs');
const crypto = require('crypto');
const path = require('path');

// Configuration
const EXPECTED_VERSION = '2.0.55';
const EXPECTED_HASH = '97641f09bea7d318ce5172d536581bb1da49c99b132d90f71007a3bb0b942f57';

// Allow custom path for testing
const basePath = process.argv[2] ||
  path.join(process.env.HOME, '.claude/local/node_modules/@anthropic-ai/claude-code/cli.js');
const backupPath = basePath + '.backup';
const patchDir = __dirname;

// Helper to load patch strings from files (avoids template literal issues)
function loadPatch(name) {
  const findPath = path.join(patchDir, 'patches', `${name}.find.txt`);
  const replacePath = path.join(patchDir, 'patches', `${name}.replace.txt`);
  if (fs.existsSync(findPath) && fs.existsSync(replacePath)) {
    return {
      find: fs.readFileSync(findPath, 'utf8'),
      replace: fs.readFileSync(replacePath, 'utf8')
    };
  }
  return null;
}

// Patches to apply (find → replace)
// Inline patches for small changes, file-based for large ones
const patches = [
  {
    name: 'Remove duplicate emoji instruction in Edit tool',
    find: `- Only use emojis if the user explicitly requests it. Avoid adding emojis to files unless asked.
- The edit will FAIL`,
    replace: `- The edit will FAIL`
  },
  {
    name: 'Remove duplicate emoji instruction in Write tool',
    find: `- NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.
- Only use emojis if the user explicitly requests it. Avoid writing emojis to files unless asked.`,
    replace: `- NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.`
  },
  // File-based patches (loaded at runtime)
  { name: 'Slim TodoWrite examples (6KB → 0.4KB)', file: 'todowrite-examples' },
  { name: 'Slim TodoWrite states section (1.8KB → 0.4KB)', file: 'todowrite-states' },
  { name: 'Slim EnterPlanMode examples (670 → 150 chars)', file: 'enterplanmode-examples' },
  // Tool description slimming
  { name: 'Slim Bash tool description (3.7KB → 0.6KB)', file: 'bash-tool' },
  { name: 'Slim Task tool description (4.1KB → 0.6KB)', file: 'task-tool' },
  // Git/PR simplification
  { name: 'Simplify git commit section', file: 'git-commit' },
  { name: 'Simplify PR creation section', file: 'pr-creation' },
  {
    name: 'Remove Code References section (363 chars)',
    find: `# Code References

When referencing specific functions or pieces of code include the pattern \\\`file_path:line_number\\\` to allow the user to easily navigate to the source code location.

<example>
user: Where are errors from the client handled?
assistant: Clients are marked as failed in the \\\`connectToServer\\\` function in src/services/process.ts:712.
</example>
`,
    replace: '# .\n'  // Must be non-whitespace to avoid API error
  },
  // New patches - Round 2
  { name: 'Slim TodoWrite When to Use (1.2KB → 200 chars)', file: 'todowrite-when-to-use' },
  { name: 'Slim Professional objectivity (762 → 120 chars)', file: 'professional-objectivity' },
  { name: 'Slim WebFetch usage notes (808 → 120 chars)', file: 'webfetch-usage' },
  { name: 'Slim WebSearch CRITICAL section (485 → 100 chars)', file: 'websearch-critical' },
  { name: 'Slim Skill tool instructions (887 → 80 chars)', file: 'skill-tool' },
  { name: 'Slim SlashCommand description (695 → 110 chars)', file: 'slashcommand' },
  // Round 3 - Final optimizations
  { name: 'Slim EnterPlanMode When to Use (1.2KB → 200 chars)', file: 'enterplanmode-when-to-use' },
  { name: 'Slim Read tool intro (292 → 110 chars)', file: 'read-tool' },
];

// Helper: compute SHA256 hash
function sha256(filepath) {
  const content = fs.readFileSync(filepath);
  return crypto.createHash('sha256').update(content).digest('hex');
}

// Main
function main() {
  console.log('Claude Code CLI Patcher');
  console.log('=======================\n');

  // 1. Check backup exists
  if (!fs.existsSync(backupPath)) {
    console.error(`Error: No backup found at ${backupPath}`);
    console.error('Run backup-cli.sh first.');
    process.exit(1);
  }

  // 2. Verify backup hash
  const backupHash = sha256(backupPath);
  if (backupHash !== EXPECTED_HASH) {
    console.error('Error: Backup hash mismatch');
    console.error(`Expected: ${EXPECTED_HASH}`);
    console.error(`Got:      ${backupHash}`);
    process.exit(1);
  }
  console.log(`Backup verified (v${EXPECTED_VERSION})`);

  // 3. Restore from backup
  fs.copyFileSync(backupPath, basePath);
  console.log('Restored from backup\n');

  // 4. Apply patches
  let content = fs.readFileSync(basePath, 'utf8');
  let appliedCount = 0;

  for (const patch of patches) {
    let find, replace;

    // Load from file if specified, otherwise use inline
    if (patch.file) {
      const loaded = loadPatch(patch.file);
      if (!loaded) {
        console.log(`[SKIP] ${patch.name} (patch files not found)`);
        continue;
      }
      find = loaded.find;
      replace = loaded.replace;
    } else {
      find = patch.find;
      replace = patch.replace;
    }

    if (content.includes(find)) {
      if (patch.replaceAll) {
        content = content.split(find).join(replace);
      } else {
        content = content.replace(find, replace);
      }
      console.log(`[OK] ${patch.name}`);
      appliedCount++;
    } else {
      console.log(`[SKIP] ${patch.name} (not found in bundle)`);
    }
  }

  // 5. Write patched file
  fs.writeFileSync(basePath, content);

  // 6. Summary
  const newHash = sha256(basePath);
  const sizeDiff = fs.statSync(backupPath).size - fs.statSync(basePath).size;

  console.log('\n-----------------------');
  console.log(`Patches applied: ${appliedCount}/${patches.length}`);
  console.log(`Size reduction: ${sizeDiff} bytes`);
  console.log(`New hash: ${newHash}`);
}

main();
