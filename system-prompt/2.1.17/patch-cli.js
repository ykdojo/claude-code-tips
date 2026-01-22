#!/usr/bin/env node
/**
 * Patch script for Claude Code CLI system prompt
 * Always restores from backup first, then applies patches
 */

const fs = require('fs');
const crypto = require('crypto');
const path = require('path');

// Configuration
const EXPECTED_VERSION = '2.1.17';
const EXPECTED_HASH = 'f98412938f6ce048b6cbeed73859ba3e420408a82f8966c04a6406319302e6e5';

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

// Convert find/replace patterns to regex-based matching for variable references
// This allows patches to work across versions where variable names change
function createRegexPatch(find, replace) {
  // Two types of placeholders:
  // 1. ${varName} - matches template literal vars like ${n3}, ${T3}
  // 2. __NAME__ - matches plain identifiers like kY7, aDA (for function names)
  const varRegex = /\$\{[a-zA-Z0-9_.]+(?:\(\))?\}/g;
  const identRegex = /__[A-Z0-9_]+__/g;

  // Extract unique placeholders from find pattern (in order)
  const placeholders = [];
  const seenPlaceholders = new Set();

  // Find all ${...} patterns
  let match;
  while ((match = varRegex.exec(find)) !== null) {
    if (!seenPlaceholders.has(match[0])) {
      seenPlaceholders.add(match[0]);
      placeholders.push({ text: match[0], type: 'var' });
    }
  }

  // Find all __NAME__ patterns
  while ((match = identRegex.exec(find)) !== null) {
    if (!seenPlaceholders.has(match[0])) {
      seenPlaceholders.add(match[0]);
      placeholders.push({ text: match[0], type: 'ident' });
    }
  }

  // If no placeholders, return null (use simple string match)
  if (placeholders.length === 0) {
    return null;
  }

  // Build regex pattern: escape everything except placeholders, which become capture groups
  let regexStr = find;
  // First escape all regex special chars
  regexStr = regexStr.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

  // Then replace each unique placeholder with appropriate capture group
  for (const p of placeholders) {
    const escaped = p.text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    // ${...} matches template literals, __NAME__ matches identifiers
    const capture = p.type === 'var'
      ? '(\\$\\{[a-zA-Z0-9_.]+(?:\\(\\))?\\})'
      : '([a-zA-Z0-9_$]+)';
    regexStr = regexStr.split(escaped).join(capture);
  }

  // Build replacement string with backreferences
  let replaceStr = replace;
  for (let i = 0; i < placeholders.length; i++) {
    replaceStr = replaceStr.split(placeholders[i].text).join(`$${i + 1}`);
  }

  return {
    regex: new RegExp(regexStr),
    replace: replaceStr,
    varCount: placeholders.length
  };
}

// Patches to apply (find → replace)
// Only patches saving 100+ chars are included
const patches = [
  // Big wins (1KB+)
  { name: 'Slim TodoWrite examples (6KB → 0.4KB)', file: 'todowrite-examples' },
  { name: 'Remove Task tool Usage notes + examples (~2KB)', file: 'task-usage-notes' },
  { name: 'Simplify git commit section (~3.4KB)', file: 'git-commit' },
  { name: 'Slim Bash tool description (3.7KB → 0.6KB)', file: 'bash-tool' },
  { name: 'Simplify PR creation section (~1.7KB)', file: 'pr-creation' },
  { name: 'Slim EnterPlanMode When to Use (1.2KB → 200 chars)', file: 'enterplanmode-when-to-use' },
  { name: 'Slim TodoWrite states section (1.8KB → 0.4KB)', file: 'todowrite-states' },
  { name: 'Slim Skill tool instructions (887 → 80 chars)', file: 'skill-tool' },
  { name: 'Slim TodoWrite When to Use (1.2KB → 200 chars)', file: 'todowrite-when-to-use' },

  // Medium wins (200-1000 chars)
  { name: 'Slim over-engineering bullets (~900 → 200 chars)', file: 'over-engineering' },
  { name: 'Slim LSP tool description (~750 → 150 chars)', file: 'lsp-tool' },
  { name: 'Slim Edit tool description (~900 → 200 chars)', file: 'edit-tool' },
  { name: 'Slim EnterPlanMode examples (670 → 150 chars)', file: 'enterplanmode-examples' },
  { name: 'Slim Professional objectivity (762 → 120 chars)', file: 'professional-objectivity' },
  { name: 'Slim WebFetch usage notes (808 → 120 chars)', file: 'webfetch-usage' },
  { name: 'Slim specialized tools instruction (~500 → 130 chars)', file: 'specialized-tools' },
  { name: 'Slim Grep tool description (~715 → 350 chars)', file: 'grep-tool' },
  { name: 'Slim TodoWrite examples v2 (~400 chars)', file: 'todowrite-examples-v2' },
  { name: 'Slim claude-code-guide agent (~500 → 115 chars)', file: 'agent-claude-code-guide' },
  { name: 'Slim NotebookEdit (~510 → 100 chars)', file: 'notebookedit' },
  { name: 'Slim Task Management examples (~1.2KB → 130 chars)', file: 'task-management-examples' },
  { name: 'Slim Write tool description (~550 → 100 chars)', file: 'write-tool' },
  { name: 'Slim WebSearch CRITICAL section (485 → 100 chars)', file: 'websearch-critical' },
  { name: 'Slim BashOutput (~440 → 95 chars)', file: 'bashoutput' },
  { name: 'Remove Code References section (363 chars)', file: 'code-references' },
  { name: 'Further slim git commit (~400 → 200 chars)', file: 'git-commit-v2' },
  { name: 'Slim Explore agent (~350 → 120 chars)', file: 'agent-explore' },
  { name: 'Slim security warning (~430 → 120 chars)', file: 'security-warning' },
  { name: 'Further slim PR creation (~400 → 150 chars)', file: 'pr-creation-v2' },
  { name: 'Slim Glob tool description (~400 → 100 chars)', file: 'glob-tool' },
  { name: 'Remove duplicate parallel calls instruction (~270 chars)', file: 'parallel-calls-duplicate' },
  { name: 'Slim AskUserQuestion (~450 → 190 chars)', file: 'askuserquestion' },
  { name: 'Slim Bash.description param (~300 → 40 chars)', file: 'bash-description-param' },
  { name: 'Slim hooks instruction (~380 → 110 chars)', file: 'hooks-instruction' },
  { name: 'Slim Grep -A/-B/-C context params (~300 → 100 chars)', file: 'grep-params-context' },
  { name: 'Slim KillShell (~260 → 35 chars)', file: 'killshell' },
  { name: 'Remove tool usage policy examples (~400 chars)', file: 'tool-usage-examples' },
  { name: 'Slim planning timelines (~290 → 50 chars)', file: 'planning-timelines' },
  { name: 'Slim Glob.path param (~255 → 65 chars)', file: 'glob-path-param' },
  { name: 'Slim Task tool description (4.1KB → 0.6KB)', file: 'task-tool' },
  { name: 'Slim Grep output_mode param (227 → 70 chars)', file: 'grep-params-output_mode' },
  { name: 'Slim Grep head_limit param (232 → 30 chars)', file: 'grep-params-head_limit' },
  { name: 'Slim doing tasks intro (~230 → 30 chars)', file: 'doing-tasks-intro' },
  { name: 'Slim CLI format instruction (~230 → 35 chars)', file: 'cli-format-instruction' },
  { name: 'Slim Read tool intro (292 → 110 chars)', file: 'read-tool' },
  { name: 'Slim Read capabilities (400 → 80 chars)', file: 'read-capabilities' },
  { name: 'Slim system-reminder instruction (~280 → 90 chars)', file: 'system-reminder-instruction' },
  { name: 'Slim output text instruction (~230 → 60 chars)', file: 'output-text-instruction' },
  { name: 'Slim general-purpose agent (~280 → 100 chars)', file: 'agent-general-purpose' },
  { name: 'Slim explore instruction (~275 → 105 chars)', file: 'explore-instruction' },
  // glob-parallel-calls and read-parallel-calls removed - their text is already removed by glob-tool and read-tool patches
  { name: 'Slim propose changes (~175 → 30 chars)', file: 'propose-changes' },
  { name: 'Slim URL warning (~220 → 70 chars)', file: 'url-warning' },
  { name: 'Slim security vulnerabilities (~200 → 60 chars)', file: 'security-vulnerabilities' },
  { name: 'Slim Plan agent (~210 → 85 chars)', file: 'agent-plan' },
  { name: 'Slim Read offset/limit line (~165 → 50 chars)', file: 'read-tool-offset' },
  { name: 'Slim Grep offset param (135 → 35 chars)', file: 'grep-params-offset' },
  { name: 'Slim Grep type param (114 → 30 chars)', file: 'grep-params-type' },
  { name: 'Slim todos mark complete (~150 → 45 chars)', file: 'todos-mark-complete' },

  // New patches
  { name: 'Slim ToolSearch description (~1.5KB → 400 chars)', file: 'toolsearch-description' },
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

    // Try regex-based matching for patterns with variable references
    const regexPatch = createRegexPatch(find, replace);

    if (regexPatch) {
      // Use regex matching
      if (regexPatch.regex.test(content)) {
        content = content.replace(regexPatch.regex, regexPatch.replace);
        console.log(`[OK] ${patch.name} (regex, ${regexPatch.varCount} vars)`);
        appliedCount++;
      } else {
        console.log(`[SKIP] ${patch.name} (regex not found)`);
      }
    } else if (content.includes(find)) {
      // Simple string match (no variables)
      if (patch.replaceAll) {
        content = content.split(find).join(replace);
      } else {
        content = content.replace(find, replace);
      }
      console.log(`[OK] ${patch.name}`);
      appliedCount++;
    } else {
      console.log(`[SKIP] ${patch.name} (not found)`);
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
