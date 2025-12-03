# System Prompt Patching for v2.0.57

Patches to slim Claude Code's system prompt. See [2.0.55](../2.0.55/) for measured token savings and screenshots.

## System Prompt Extractions

This directory contains two different extractions of the Claude Code system prompt:

| File | Lines | Method | Description |
|------|-------|--------|-------------|
| `system-prompt-original-unpatched.md` | 833 | Programmatic | Extracted from CLI source code using `extract-system-prompt.js` |
| `system-prompt-iterative-extraction.md` | 1309 | Model self-report | Iteratively extracted by asking Claude to document its own instructions |

### Differences

**Programmatic extraction** parses the minified CLI bundle to reconstruct the system prompt. It captures the exact text injected at runtime but may miss some dynamic content.

**Iterative extraction** asks Claude instances to describe and document their instructions, then refine the document through multiple passes until verified complete. This method:
- Includes full JSON schemas for all 18 tools
- Contains more verbose examples (especially for TodoWrite)
- Documents the AskUserQuestion tool in detail
- Adds a summary of critical "NEVER" and "ALWAYS" rules
- May include model interpretation/organization not in the original

Both are useful references - the programmatic extraction shows the raw prompt, while the iterative extraction shows how the model understands and interprets its instructions.

## Quick Start

```bash
# Backup original (run once, requires write permission to npm global)
./backup-cli.sh

# Apply all patches (restores from backup first, so idempotent)
node patch-cli.js

# Verify with extraction
node extract-system-prompt.js /tmp/patched.md

# Restore original
./restore-cli.sh
```

## File Structure

```
2.0.57/
├── backup-cli.sh                          # Creates verified backup
├── restore-cli.sh                         # Restores from backup
├── patch-cli.js                           # Applies all patches (idempotent)
├── extract-system-prompt.js               # Extracts prompt for verification
├── patches/                               # Patch files (find/replace pairs)
├── system-prompt-original-unpatched.md    # Programmatic extraction from CLI source
└── system-prompt-iterative-extraction.md  # Model self-report extraction
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

## Variable Mappings (v2.0.57)

These change with each minified build. When updating, search the CLI bundle for readable strings (e.g., `"Bash"`) to find new variable names.

| Minified | Actual |
|----------|--------|
| D9 | Bash |
| s8 | Task |
| gGB | TodoWrite |
| g5 | Read |
| R5 | Edit |
| bX | Write |
| vX | WebFetch |
| CD | Glob |
| uY | Grep |
| dJ | AskUserQuestion |
| O_ | WebSearch |
| yP | SlashCommand |
| Uf1 | claude-code-guide (agent type) |

### Object.name Patterns

| Minified | Meaning |
|----------|---------|
| FO.name | Glob |
| d8.name | Read |
| oX.name | Write |
| In.name | Task |
| Sq.agentType | Explore (agent type) |

### Function/Helper Variables

| Minified | Meaning | Found In |
|----------|---------|----------|
| vk3 | Allowed tools function | allowed-tools |
| QFA | Allowed tools parser | allowed-tools |
| RJ | Get tool context | allowed-tools |
| r5 | Get rule value | allowed-tools |
| ld1 | Get tool display name | allowed-tools |
| KoA() | Max timeout | bash-tool |
| LGA() | Default timeout | bash-tool |
| Ke() | Char limit | bash-tool |
| BH9 | Security content | duplicate-security-warning |

### Zod Library Changes

| v2.0.56 | v2.0.57 |
|---------|---------|
| `:k.` | `:_.` |

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

## Upgrading to New Versions

See [UPGRADING.md](../UPGRADING.md) for detailed migration steps.
