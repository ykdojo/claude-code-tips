# Upgrading to a New Claude Code Version

## 1. Update Claude Code

```bash
npm update -g @anthropic-ai/claude-code
claude --version  # verify new version
```

## 2. Create new version folder

```bash
mkdir 2.0.XX  # replace with actual version
cd 2.0.XX
mkdir patches
```

## 3. Copy and update extraction script

Copy `extract-system-prompt.js` from previous version:

```bash
cp ../2.0.55/extract-system-prompt.js .
```

**Important:** The minified variable names change between versions. You'll need to update the mappings.

### Finding new variable mappings

Search for tool name assignments in the CLI bundle:

```bash
# Find all tool variable assignments
grep -oE '[A-Za-z0-9_]{2,4}="(Task|Bash|Read|Edit|Write|Glob|Grep|TodoWrite|WebFetch|WebSearch|AskUserQuestion|SlashCommand)"' \
  /opt/homebrew/lib/node_modules/@anthropic-ai/claude-code/cli.js | sort -u

# Find object.name patterns (tools referenced as SomeVar.name)
grep -oE '[a-zA-Z0-9_]+={name:[A-Za-z0-9_]+' \
  /opt/homebrew/lib/node_modules/@anthropic-ai/claude-code/cli.js | head -20

# Find agentType patterns
grep -oE '[A-Za-z0-9_]+={agentType:"[^"]*"' \
  /opt/homebrew/lib/node_modules/@anthropic-ai/claude-code/cli.js
```

Update the `VAR_MAP` and `replaceVariables()` function with new mappings.

### Update tool description search strings

Tool descriptions may change slightly. If a tool isn't extracted, find its new description:

```bash
grep -oE 'Launch.{0,60}agent' /opt/homebrew/lib/node_modules/@anthropic-ai/claude-code/cli.js
```

## 4. Extract and diff

Run extraction:

```bash
node extract-system-prompt.js system-prompt-original-unpatched.md
```

Diff against previous version to identify:
- Actual prompt changes (new instructions, modified wording)
- Extraction bugs (`[DYNAMIC]` placeholders indicate unmapped variables)

```bash
diff ../2.0.55/system-prompt-original-unpatched.md system-prompt-original-unpatched.md
```

If you see wrong tool names or `[DYNAMIC]` in unexpected places, you likely have unmapped variables. Iterate on the mappings until the diff shows only real changes.

## 5. Copy and update patch-cli.js

```bash
cp ../2.0.55/patch-cli.js .
```

Update:
- `EXPECTED_VERSION` to new version
- `EXPECTED_HASH` (run `shasum -a 256` on the CLI)
- `findClaudeCli()` if installation path changed

## 6. Update existing patches

**Critical:** Update variable names in BOTH `*.find.txt` AND `*.replace.txt` files!

The replace files contain variable references that must match the new version. Old variable names will cause runtime crashes (TypeError: Cannot read properties of undefined).

```bash
# Find patches with old variable names
grep -l '\${OLD_VAR}' patches/*.txt

# Bulk update (example for E9 -> C9)
sed -i '' 's/\${E9}/\${C9}/g' patches/*.txt
```

### Finding where patch text diverges

When a patch shows "not found in bundle", find the exact mismatch point:

```javascript
// Run: node -e '<paste this>' (from the version folder)
const fs = require('fs');
const bundle = fs.readFileSync('/opt/homebrew/lib/node_modules/@anthropic-ai/claude-code/cli.js', 'utf8');
const patch = fs.readFileSync('patches/PATCHNAME.find.txt', 'utf8');

let lo = 10, hi = patch.length;
while (lo < hi) {
  const mid = Math.floor((lo + hi + 1) / 2);
  if (bundle.indexOf(patch.slice(0, mid)) !== -1) lo = mid;
  else hi = mid - 1;
}
console.log('Match up to char:', lo, 'of', patch.length);
console.log('Patch:', JSON.stringify(patch.slice(lo-20, lo+30)));
const idx = bundle.indexOf(patch.slice(0, lo));
console.log('Bundle:', JSON.stringify(bundle.slice(idx + lo - 20, idx + lo + 30)));
```

This shows exactly where the text differs - usually a changed variable name.

### Debugging runtime crashes

Use bisect mode to find which patch breaks the CLI:

```bash
# Apply only first N patches
node patch-cli.js --max=10

# Test with tmux (claude -p can hang when run directly)
tmux new-session -d -s test 'claude -p "Say hello" 2>&1 > /tmp/claude-test.txt'
sleep 12
cat /tmp/claude-test.txt

# Binary search: if works, try more; if crashes, try fewer
```

**Symptoms of broken patches:**
- "Execution error" with no other output = variable reference in replace.txt points to non-existent function
- `TypeError: Cannot read properties of undefined` = same cause
- Claude hangs/interrupts immediately = similar issue

**Root cause is almost always:** A `*.replace.txt` file contains old variable names like `${i8.name}` that need to be updated to match the new version (e.g., `${m8.name}`).

### Function-based patches

Some patches replace entire functions (like `allowed-tools`). These need the full function signature updated:

```bash
# Find the new function pattern
grep -oE 'function [a-zA-Z0-9_]+\(A\)\{if\(!A\)return"";let Q=[a-zA-Z0-9_]+\(A\);if\(Q\.length===0\)return"";' \
  /opt/homebrew/lib/node_modules/@anthropic-ai/claude-code/cli.js

# Then get the full function with node
node -e '
const fs = require("fs");
const bundle = fs.readFileSync("/opt/homebrew/lib/node_modules/@anthropic-ai/claude-code/cli.js", "utf8");
const start = bundle.indexOf("function FUNCNAME(A){if(!A)");
if (start !== -1) console.log(bundle.slice(start, start + 300));
'
```

## 7. Build new patches

For each section to slim:

1. Find the exact text in the bundle
2. Create `patches/name.find.txt` with that text
3. Create `patches/name.replace.txt` with slimmed version
4. Test the patch: `node patch-cli.js`
5. Re-run extraction to verify
6. Start Claude Code and run `/context` to make sure it still works

## 8. Update README

Document which patches were created and token savings.
