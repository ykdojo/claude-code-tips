#!/usr/bin/env node
/**
 * Patch script for Claude Code CLI system prompt
 * Always restores from backup first, then applies patches
 */

const fs = require('fs');
const crypto = require('crypto');
const path = require('path');

// Configuration
const EXPECTED_VERSION = '2.0.57';
const EXPECTED_HASH = '895f335ee2703e1da848413ac6074dfb283666755170e13574ba4d8034b1cd83';

// Auto-detect CLI path by following the claude binary
const { execSync } = require('child_process');

function findClaudeCli() {
  const home = process.env.HOME;

  // Method 1: Use 'which claude' and follow symlinks
  try {
    const claudePath = execSync('which claude', { encoding: 'utf8' }).trim();
    const realPath = fs.realpathSync(claudePath);

    // cli.js is in the same directory as the symlink target
    const cliPath = path.join(path.dirname(realPath), 'cli.js');
    if (fs.existsSync(cliPath)) return cliPath;

    // Fallback: check if realPath itself is cli.js
    if (realPath.endsWith('cli.js')) return realPath;
  } catch (e) {
    // which failed, try other methods
  }

  // Method 2: Check common npm global locations
  const globalLocations = [
    '/opt/homebrew/lib/node_modules/@anthropic-ai/claude-code/cli.js',
    '/usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js',
  ];

  for (const loc of globalLocations) {
    if (fs.existsSync(loc)) return loc;
  }

  // Method 3: Check local install location
  const localLauncher = path.join(home, '.claude/local/claude');
  if (fs.existsSync(localLauncher)) {
    const content = fs.readFileSync(localLauncher, 'utf8');
    const execMatch = content.match(/exec\s+"([^"]+)"/);
    if (execMatch) {
      return fs.realpathSync(execMatch[1]);
    }
  }

  return null;
}

// Allow custom path for testing, otherwise find it dynamically
const customPath = process.argv.find(a => !a.startsWith('--') && !a.includes('node') && !a.includes('patch-cli'));
const basePath = customPath || findClaudeCli();

if (!basePath) {
  console.error('Error: Could not find Claude Code CLI. Tried:');
  console.error('  - which claude');
  console.error('  - /opt/homebrew/lib/node_modules/@anthropic-ai/claude-code/cli.js');
  console.error('  - /usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js');
  console.error('  - ~/.claude/local/claude');
  console.error('');
  console.error('Pass the path as an argument: node patch-cli.js /path/to/cli.js');
  process.exit(1);
}

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
// All patches are file-based (loaded at runtime from patches/ folder)
const patches = [
  { name: 'Remove duplicate emoji instruction in Edit tool', file: 'edit-emoji' },
  { name: 'Remove duplicate emoji instruction in Write tool', file: 'write-emoji' },
  { name: 'Slim TodoWrite examples (6KB → 0.4KB)', file: 'todowrite-examples' },
  { name: 'Slim TodoWrite states section (1.8KB → 0.4KB)', file: 'todowrite-states' },
  { name: 'Slim EnterPlanMode examples (670 → 150 chars)', file: 'enterplanmode-examples' },
  // Tool description slimming
  { name: 'Slim Bash tool description (3.7KB → 0.6KB)', file: 'bash-tool' },
  { name: 'Slim Task tool description (4.1KB → 0.6KB)', file: 'task-tool' },
  // Git/PR simplification
  { name: 'Simplify git commit section', file: 'git-commit' },
  { name: 'Simplify PR creation section', file: 'pr-creation' },
  { name: 'Remove Code References section (363 chars)', file: 'code-references' },
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
  // Round 4 - Dynamic content optimization
  { name: 'Remove allowed tools list from prompt (saves 5-10KB+)', file: 'allowed-tools' },
  // Round 5 - Final cleanup
  { name: 'Slim over-engineering bullets (~900 chars → 200)', file: 'over-engineering' },
  { name: 'Slim documentation lookup section (~600 chars → 150)', file: 'documentation-lookup' },
  { name: 'Remove tool usage policy examples (~400 chars)', file: 'tool-usage-examples' },
  // Round 6 - Grep tool optimization
  { name: 'Slim Grep tool description (~715 → 350 chars)', file: 'grep-tool' },
  { name: 'Slim Grep head_limit param (232 → 30 chars)', file: 'grep-params-head_limit' },
  { name: 'Slim Grep output_mode param (227 → 70 chars)', file: 'grep-params-output_mode' },
  { name: 'Slim Grep offset param (135 → 35 chars)', file: 'grep-params-offset' },
  { name: 'Slim Grep multiline param (112 → 40 chars)', file: 'grep-params-multiline' },
  { name: 'Slim Grep type param (114 → 30 chars)', file: 'grep-params-type' },
  { name: 'Slim Grep -A/-B/-C params (~300 → 90 chars)', file: 'grep-params-context' },
  // Round 7 - Remove redundant parallel calls guidance
  { name: 'Remove parallel calls from Glob (~50 tokens)', file: 'glob-parallel-calls' },
  { name: 'Remove parallel calls from Read (~50 tokens)', file: 'read-parallel-calls' },
  // Round 8 - Remove duplicate content
  { name: 'Remove duplicate security warning (~200 tokens)', file: 'duplicate-security-warning' },
  { name: 'Slim parallel calls guidance (~100 tokens)', file: 'parallel-calls' },
  // Round 9 - Additional slimming
  { name: 'Slim Task Management examples (~1.5KB → 300 chars)', file: 'task-management-examples' },
  { name: 'Slim Read tool images line (~170 → 70 chars)', file: 'read-images' },
  { name: 'Slim NotebookEdit description (~400 → 120 chars)', file: 'notebookedit' },
  { name: 'Slim BashOutput description (~400 → 100 chars)', file: 'bashoutput' },
  { name: 'Slim KillShell description (~250 → 70 chars)', file: 'killshell' },
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

  // Support --max=N for bisecting
  const maxArg = process.argv.find(a => a.startsWith('--max='));
  const maxPatches = maxArg ? parseInt(maxArg.split('=')[1]) : Infinity;
  if (maxPatches !== Infinity) {
    console.log(`Limiting to first ${maxPatches} patches (bisect mode)\n`);
  }

  let patchIndex = 0;
  for (const patch of patches) {
    if (patchIndex >= maxPatches) {
      console.log(`[STOP] Reached max patches limit (${maxPatches})`);
      break;
    }
    patchIndex++;
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
