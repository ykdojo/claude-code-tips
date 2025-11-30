# System Prompt Extraction & Slimming

Extract and slim Claude Code's system prompt from the CLI bundle.

## Results

### Extracted Prompt Size

From comparing `extract-system-prompt.js` output before and after patching:

- **Original**: 830 lines, 52,590 chars
- **After 29 patches**: 446 lines, 24,090 chars (static template)
- **Savings**: ~28KB (~54% reduction in static content)

### Measured Token Savings

From `/context` command in Claude Code (shows actual runtime token counts):

| Component | Unpatched | Patched | Savings |
|-----------|-----------|---------|---------|
| System prompt | 3.0k | 2.6k | 400 tokens |
| System tools | 14.6k | 8.5k | 6,100 tokens |
| **Static total** | **~18k** | **~11k** | **~6,500 tokens (37%)** |
| Allowed tools list | ~2.5-3.5k | 0 | ~3,000 tokens |
| **Total (with allowed tools)** | **~21k** | **~11k** | **~9,500 tokens (46%)** |

The allowed tools row is estimated from Claude's self-reported token count when asked to analyze the list. This varies by project - with 70+ approved commands, the list was ~8,000-10,000 characters (~2,500-3,500 tokens).

## File Structure

```
system-prompt/
├── backup-cli.sh              # Creates verified backup
├── restore-cli.sh             # Restores from backup
├── patch-cli.js               # Applies all patches (idempotent)
├── extract-system-prompt.js   # Extracts prompt for verification
├── patches/                   # 52 patch files (26 find/replace pairs)
├── system-prompt.md           # Original extracted prompt (reference)
└── README.md
```

## Quick Start

```bash
# Apply all patches (restores from backup first, so idempotent)
node patch-cli.js

# Verify with extraction
CLI_PATH=~/.claude/local/node_modules/@anthropic-ai/claude-code/cli.js \
  node extract-system-prompt.js /tmp/patched.md

# Restore original
./restore-cli.sh
```

## Patches Applied (29 total)

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
In the CLI bundle, backticks are escaped as `\``. Use `\`` in patch files for strings like `\`command\``.

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

These change with each minified build:

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
| uzA | 2000 (line limit) |
| kj9 | 600000 (10 min timeout) |

## Remaining Slimming Opportunities (~300 chars)

Low-priority sections that could still be trimmed:

### 1. Hooks paragraph (~300 chars)
Already concise - minimal gain.

The system prompt is now essentially as slim as practical without risking behavior changes.

## What's NOT Captured

Dynamic content injected at runtime:
- Environment info (working directory, platform, date)
- Git status snapshot
- Model info ("You are powered by...")
- CLAUDE.md file contents
- MCP server instructions
