# System Prompt Extraction & Slimming

Extract and slim Claude Code's system prompt from the CLI bundle.

## Results

### Extracted Prompt Size

From comparing `extract-system-prompt.js` output before and after patching:

- **Original**: 830 lines, 52,590 chars
- **After 33 patches**: ~23,200 chars (static template)
- **Savings**: ~29KB (~56% reduction in static content)

### Measured Token Savings

From `/context` command in Claude Code (shows actual runtime token counts):

| Component | Unpatched | Patched | Savings |
|-----------|-----------|---------|---------|
| System prompt | 3.0k | 2.4k | 600 tokens |
| System tools | 14.6k | 8.1k | 6,500 tokens |
| **Static total** | **~18k** | **~10.5k** | **~7,100 tokens (39%)** |
| Allowed tools list | ~2.5-3.5k | 0 | ~3,000 tokens |
| **Total (with allowed tools)** | **~21k** | **~10.5k** | **~10,100 tokens (48%)** |

The allowed tools row is estimated from Claude's self-reported token count when asked to analyze the list. This varies by project - with 70+ approved commands, the list was ~8,000-10,000 characters (~2,500-3,500 tokens).

## File Structure

```
system-prompt/
├── backup-cli.sh              # Creates verified backup
├── restore-cli.sh             # Restores from backup
├── patch-cli.js               # Applies all patches (idempotent)
├── extract-system-prompt.js   # Extracts prompt for verification
├── patches/                   # Patch files (find/replace pairs)
├── system-prompt.md           # Original extracted prompt (reference)
└── README.md
```

## Quick Start

```bash
# Apply all patches (restores from backup first, so idempotent)
# Auto-detects CLI path from shell rc files or uses default location
node patch-cli.js

# Verify with extraction (also auto-detects, or use CLI_PATH env var)
node extract-system-prompt.js /tmp/patched.md

# Restore original
./restore-cli.sh
```

## Patches Applied (33 total)

1. Removed duplicate emoji instruction from Edit tool
2. Removed duplicate emoji instruction from Write tool
3. Slimmed TodoWrite examples (6KB to 0.4KB)
4. Slimmed TodoWrite states section (1.8KB to 0.4KB)
5. Slimmed EnterPlanMode examples (670 to 150 chars)
6. Slimmed Bash tool description (3.7KB to 0.6KB)
7. Slimmed Task tool description (4.1KB to 0.6KB)
8. Simplified git commit section (3.8KB to 0.6KB)
9. Simplified PR creation section (2.2KB to 0.4KB)
10. Removed Code References section (363 bytes)
11. Slimmed TodoWrite "When to Use" (1.2KB to 200 chars)
12. Slimmed Professional objectivity (762 to 120 chars)
13. Slimmed WebFetch usage notes (808 to 120 chars)
14. Slimmed WebSearch CRITICAL section (485 to 100 chars)
15. Slimmed Skill tool instructions (887 to 80 chars)
16. Slimmed SlashCommand description (695 to 110 chars)
17. Slimmed EnterPlanMode "When to Use" (1.2KB to 200 chars)
18. Slimmed Read tool intro (292 to 110 chars)
19. Removed allowed tools list function (runtime-generated content)
20. Slimmed over-engineering bullets (~900 to 200 chars)
21. Slimmed documentation lookup section (~600 to 150 chars)
22. Removed tool usage policy examples (~400 chars)
23. Slimmed Grep tool description (~715 to 350 chars)
24. Slimmed Grep head_limit param (232 to 30 chars)
25. Slimmed Grep output_mode param (227 to 70 chars)
26. Slimmed Grep offset param (135 to 35 chars)
27. Slimmed Grep multiline param (112 to 40 chars)
28. Slimmed Grep type param (114 to 30 chars)
29. Slimmed Grep -A/-B/-C params (~300 to 90 chars)
30. Removed redundant parallel calls from Glob (~50 tokens)
31. Removed redundant parallel calls from Read (~50 tokens)
32. Removed duplicate security warning (~200 tokens)
33. Slimmed parallel calls guidance (~100 tokens)

## Adding New Patches

### Small patches (inline in patch-cli.js):
```javascript
{
  name: 'Description of patch',
  find: `exact string to find`,
  replace: `replacement string`
}
```

### Large patches (file-based):
1. Create `patches/patch-name.find.txt` with exact text to find
2. Create `patches/patch-name.replace.txt` with replacement
3. Add to patches array: `{ name: 'Description', file: 'patch-name' }`

**Important**: Find text must match EXACTLY, including whitespace and newlines.

### Escaped Backticks
The CLI bundle escapes backticks as `\`` (backslash + backtick). Copy strings exactly as they appear in the bundle, including escapes like `\`command\``.

### Iterate and Test
1. Add ONE patch
2. Run `node patch-cli.js`
3. Check "Patches applied: X/Y" output
4. Run extraction to verify
5. Commit

If patch shows `[SKIP]`, the find string doesn't match. Debug with `JSON.stringify()` to compare byte-by-byte.

## How Extraction Works

Claude Code is installed at `~/.claude/local/node_modules/@anthropic-ai/claude-code/cli.js` as a ~10MB minified JavaScript bundle.

The system prompt is:
- Built dynamically from template literals
- Split across multiple sections with JavaScript conditionals
- Uses minified variable names (e.g., `E9` for "Bash", `R8` for "Task")

The extraction script:
1. Finds each major section by its header (e.g., "# Tone and style")
2. Handles conditional template patterns like `${W.has(X)?`...`:""}`
3. Replaces minified variable names with readable ones

## Variable Mappings (v2.0.55)

These change with each minified build. When updating, search the CLI bundle for readable strings (e.g., `"Bash"`) to find new variable names.

| Minified | Actual |
|----------|--------|
| E9 | Bash |
| R8 | Task |
| eI.name | TodoWrite |
| h5 | Read |
| R5 | Edit |
| vX | Write |
| xX | WebFetch |
| DD | Glob |
| uY | Grep |
| uJ | AskUserQuestion |
| ZC | Explore (agent type) |
| yb1 | claude-code-guide (agent type) |
| F, Oq | SlashCommand |
| Lk | WebSearch |
| Nk | NotebookEdit |
| uzA, EA6 | 2000 (line limit) |
| kj9 | 600000 (10 min timeout) |

### Additional Variables Found in Patches

These variables appear in patch files but aren't in the extraction script (they become `[DYNAMIC]` in output). Useful reference when updating for new versions:

| Minified | Likely Meaning | Found In |
|----------|----------------|----------|
| J | Security instructions | duplicate-security-warning |
| eV9 | Security content (duplicate) | duplicate-security-warning |
| i8.name | Read tool | task-tool |
| JO.name | Glob tool | task-tool |
| B | PR template content | pr-creation |
| Q | Agent types list | task-tool, git-commit, pr-creation |

Note: `Q` (agent types) is handled specially by `extractAgentTypes()` in the extraction script.

## Remaining Slimming Opportunities

The system prompt is now essentially as slim as practical. The hooks paragraph (~300 chars) could be trimmed but gains are minimal.

## Updating for New CLI Versions

When Claude Code updates, patches may break due to changed minified variable names or modified content.

### Steps to Update

1. **Backup the new version**:
   ```bash
   ./backup-cli.sh
   ```

2. **If hash mismatch**, compute the new hash:
   ```bash
   shasum -a 256 ~/.claude/local/node_modules/@anthropic-ai/claude-code/cli.js
   ```

3. **Update `patch-cli.js`**:
   - Set `EXPECTED_VERSION` to new version (find with `grep "Version:" cli.js`)
   - Set `EXPECTED_HASH` to the SHA256 from step 2

4. **Run patches and check for failures**:
   ```bash
   node patch-cli.js
   ```
   Patches showing `[SKIP]` need their find strings updated.

5. **Fix skipped patches**: The minified bundle changes each build, so:
   - Search the CLI bundle for the readable text (e.g., "# Tone and style")
   - Copy the surrounding context into the patch `.find.txt` file
   - The replacement `.replace.txt` usually stays the same

6. **Verify with extraction**:
   ```bash
   node extract-system-prompt.js /tmp/patched.md
   ```

### Updating Variable Mappings

If `extract-system-prompt.js` outputs `[DYNAMIC]` markers, the variable names changed:
1. Search the bundle for readable strings like `="Bash"` or `="Read"`
2. Update the `VAR_MAP` object and `replaceVariables()` function

## What's NOT Captured

Dynamic content injected at runtime (not in static template):
- Environment info (working directory, platform, date)
- Git status snapshot
- Model info ("You are powered by...")
- CLAUDE.md file contents
- MCP server instructions
- Allowed tools list (note: patch #19 removes this from the prompt entirely)
