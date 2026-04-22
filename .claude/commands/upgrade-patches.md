---
description: Upgrade system prompt patches to the latest Claude Code version
allowed-tools: [Bash]
---

Upgrade system prompt patches to the latest Claude Code version.

1. Run `npm view @anthropic-ai/claude-code version` to get the latest version
2. List version directories under `system-prompt/` to find the most recent patched version
3. If patches already exist for the latest version, report that and stop
4. If not, follow `system-prompt/UPGRADING.md` to upgrade
5. Always go through the **full** Final Verification Checklist at the bottom of UPGRADING.md - all three build types (npm, native-linux, native-macos) and all tests in the matrix, not just one. Use tmux for interactive tests like `/context`.

**Container:** Use a dedicated `safeclaw-upgrade` container for all upgrade work. Create it with `cd /Users/yk/Desktop/projects/safeclaw && ./scripts/run.sh -s upgrade -n` if it doesn't exist. Do NOT use other safeclaw containers (e.g. community, work) - they may have specific Claude versions pinned for other purposes.
