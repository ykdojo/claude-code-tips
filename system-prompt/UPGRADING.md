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

### Debugging broken patches

Use bisect mode to find which patch breaks the CLI:

```bash
# Apply only first N patches
node patch-cli.js --max=10

# Test if claude works
claude -p "test"

# Binary search: if works, try more; if crashes, try fewer
```

Common crash: `TypeError: Cannot read properties of undefined (reading 'body')` usually means a variable reference in a replace file points to a non-existent function.

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
