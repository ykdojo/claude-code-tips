# Project Instructions
- Writing: keep user's voice, conversational, stick closely to what user said without making things up, but fix small grammar mistakes
- After adding or renaming tips, run `node scripts/generate-toc.js` to update the table of contents
- `~/.claude/CLAUDE.md` is symlinked to `GLOBAL-CLAUDE.md` in this repo
- When committing changes to the plugin (skills, plugin.json, etc.), bump the patch version in both `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`. Don't bump for non-plugin changes.
- Git tags/releases (e.g. `v0.25.1`) and plugin versions (e.g. `0.14.9`) are separate. The git tag follows the repo release progression and is bumped for any change. The plugin version is only in `plugin.json` and `marketplace.json`.
- Before any AWS deploy (e.g. demo stacks for tips), follow the "AWS deployment security" checklist in `GLOBAL-CLAUDE.md`: no Swagger UI / OpenAPI docs / admin UI reachable directly on a public ALB/ELB, CloudFront-only access, verify by curling the ALB afterwards.
- After pushing a plugin change, update the local install non-interactively (no `/plugin` menu needed): `claude plugin marketplace update ykdojo` then `claude plugin update dx@ykdojo`. The CLI repopulates the versioned cache; a session restart is required to apply.

# Filing Claude Code GitHub issues

For issues against `anthropics/claude-code`. When I ask you to file one:
- Draft it to a temp file and open it in VS Code (`code <file>`) for me to review before filing - never file without showing me first.
- File from host `gh` (`gh issue create`), not a container.

Style (based on my past issues):
- Title: specific, states the symptom; flag regressions. No `[BUG]`/`[FEATURE]` prefix needed.
- Lead with a one-sentence problem statement (no "Description" header). Keep it short and factual, no fluff.
- Note the version where it broke / regression info when relevant.
- Bug sections: `## Steps to reproduce`, `## Expected behavior` (+ `## Actual behavior` if useful), `## Environment` (OS, Claude Code version, terminal).
- Feature requests: `## Problem`, then `## Suggestion` / `## Demonstration`.
- Show concrete fenced code blocks for actual vs expected. Link relevant scripts/files inline rather than pasting them.
