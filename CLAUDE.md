# Project Instructions
- Writing: keep user's voice, conversational, stick closely to what user said without making things up, but fix small grammar mistakes
- After adding or renaming tips, run `node scripts/generate-toc.js` to update the table of contents
- `~/.claude/CLAUDE.md` is symlinked to `GLOBAL-CLAUDE.md` in this repo
- When committing changes to the plugin (skills, plugin.json, etc.), bump the patch version in both `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`. Don't bump for non-plugin changes.
- Git tags/releases (e.g. `v0.25.1`) and plugin versions (e.g. `0.14.9`) are separate. The git tag follows the repo release progression and is bumped for any change. The plugin version is only in `plugin.json` and `marketplace.json`.
