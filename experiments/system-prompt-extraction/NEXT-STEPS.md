# System Prompt Slimming - Handoff Document

## Goal
Reduce Claude Code's system prompt by ~50%. **Currently at ~50% reduction (26.3KB saved).**

## Current Progress

### What's Been Done
- **Backup/restore system**: `backup-cli.sh` and `restore-cli.sh` with SHA256 verification
- **Patch system**: `patch-cli.js` that restores from backup then applies patches (idempotent)
- **18 patches applied**, saving ~50% (~26.3KB):
  1. Removed duplicate emoji instruction from Edit tool
  2. Removed duplicate emoji instruction from Write tool
  3. Slimmed TodoWrite examples from 8 verbose to 2 concise
  4. Slimmed TodoWrite states section (1.8KB to 0.4KB)
  5. Slimmed EnterPlanMode examples from 6 to 2
  6. Slimmed Bash tool description (3.7KB to 0.6KB)
  7. Slimmed Task tool description (4.1KB to 0.6KB)
  8. Simplified git commit section (3.8KB to 0.6KB)
  9. Simplified PR creation section (2.2KB to 0.4KB)
  10. Removed Code References section (363 bytes)
  11. Slimmed TodoWrite "When to Use" sections (1.2KB to 200 chars)
  12. Slimmed Professional objectivity (762 to 120 chars)
  13. Slimmed WebFetch usage notes (808 to 120 chars)
  14. Slimmed WebSearch CRITICAL section (485 to 100 chars)
  15. Slimmed Skill tool instructions (887 to 80 chars)
  16. Slimmed SlashCommand description (695 to 110 chars)
  17. Slimmed EnterPlanMode "When to Use" section (1.2KB to 200 chars)
  18. Slimmed Read tool intro (292 to 110 chars)

### What Worked
- **File-based patches**: Large find/replace strings stored in `patches/*.find.txt` and `patches/*.replace.txt`
- **Inline patches**: Small patches can be defined directly in `patch-cli.js`
- **Extraction verification**: Use `CLI_PATH=/path/to/cli.js node extract-system-prompt.js output.md` to verify changes

### What Didn't Work
- **Template literals for large strings**: Embedding 6KB strings in JS template literals caused matching issues (whitespace/encoding differences)
- **Solution**: Load large patches from external `.txt` files instead

### Important: Escaped Backticks
In the CLI bundle, backticks are escaped as `\``. When creating patch files, use `\`` instead of plain backticks for strings like `\`command\`` or `\`skill: "pdf"\``.

## Remaining Tasks (Optional further optimization)

All major targets achieved (50% reduction). Diminishing returns from here.

Potential micro-optimizations (not recommended):
- Further trim individual tool descriptions
- Remove more examples from various sections
- These would save <1KB each with higher risk of behavior changes

## How to Add a New Patch

### For small patches (inline):
```javascript
// In patch-cli.js, add to patches array:
{
  name: 'Description of patch',
  find: `exact string to find`,
  replace: `replacement string`
}
```

### For large patches (file-based):
1. Create `patches/patch-name.find.txt` with exact text to find
2. Create `patches/patch-name.replace.txt` with replacement
3. Add to patches array: `{ name: 'Description', file: 'patch-name' }`

**Important**: The find text must match EXACTLY, including whitespace and newlines.

## Important: Iterate and Test

**Do NOT try to add all patches at once.** Work iteratively:

1. Add ONE patch
2. Run the patch script
3. Verify it applied (check "Patches applied: X/Y" output)
4. Run extraction to confirm the change looks correct
5. Commit
6. Move to next patch

If a patch shows `[SKIP]`, the find string doesn't match exactly. Debug by:
- Checking for whitespace differences
- Using `JSON.stringify()` to compare strings byte-by-byte
- For large patches, use file-based approach instead of inline

## Testing Workflow

```bash
# 1. Setup test environment
mkdir -p /tmp/cli-test
cp ~/.claude/local/node_modules/@anthropic-ai/claude-code/cli.js /tmp/cli-test/cli.js
./backup-cli.sh /tmp/cli-test/cli.js

# 2. Run patches
node patch-cli.js /tmp/cli-test/cli.js

# 3. Verify with extraction
CLI_PATH=/tmp/cli-test/cli.js node extract-system-prompt.js /tmp/cli-test/patched.md

# 4. Compare
wc -l /tmp/cli-test/patched.md  # Should show fewer lines
grep -c "pattern" /tmp/cli-test/patched.md  # Verify specific changes

# 5. Cleanup
rm -rf /tmp/cli-test
```

## File Structure
```
experiments/system-prompt-extraction/
├── backup-cli.sh              # Creates verified backup
├── restore-cli.sh             # Restores from backup
├── patch-cli.js               # Applies all patches (idempotent)
├── extract-system-prompt.js   # Extracts prompt for verification
├── patches/
│   ├── todowrite-examples.find.txt
│   └── todowrite-examples.replace.txt
├── system-prompt.md           # Reference extracted prompt (original)
└── README.md                  # Overview
```

## Key Numbers
- Original prompt: 830 lines, 52,590 chars
- Current (after 18 patches): 465 lines, 26,272 chars
- Savings: ~26.3KB (~50% of system prompt)
- Target exceeded!
