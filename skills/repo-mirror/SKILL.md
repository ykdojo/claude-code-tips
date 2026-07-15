---
name: repo-mirror
description: Full-text search across all of the user's GitHub repos (including private) via a local shallow mirror and ripgrep. Use for "where did I put X", "which repo has X", or any search across the user's repos - GitHub's good code search is web-only and the gh CLI / REST API cannot reliably search private repos.
---

# Repo mirror

GitHub's modern code search (the one that indexes private repos) is only available in the web UI - the REST API and `gh search code` still use the legacy engine, which often returns nothing for private repos. The reliable alternative: keep shallow local mirrors of all the user's repos and search them with ripgrep. A full search across hundreds of repos takes milliseconds.

## Layout

The mirror lives at `~/repo-mirror`:

- `~/repo-mirror/owners.txt` - one GitHub username per line (`#` comments allowed)
- `~/repo-mirror/sync.sh` - clones missing repos, updates existing ones
- `~/repo-mirror/repos/<owner>/<repo>` - shallow clones (default branch only, forks excluded - the same coverage as GitHub's own search index)

## Searching

```bash
rg -il 'pattern' ~/repo-mirror/repos          # which files, case-insensitive
rg -in 'pattern' ~/repo-mirror/repos | head   # matching lines
```

If freshness matters (recently pushed content), refresh first:

```bash
~/repo-mirror/sync.sh
```

Updates are fast (parallel no-op fetches); only the first-ever sync takes minutes.

## First-time setup

If `~/repo-mirror` doesn't exist yet:

1. Copy the bundled script: `mkdir -p ~/repo-mirror && cp <this skill's directory>/sync.sh ~/repo-mirror/sync.sh && chmod +x ~/repo-mirror/sync.sh`
2. Ask the user which GitHub accounts to mirror, then write them (one per line) to `~/repo-mirror/owners.txt`. Don't guess - they may manage more than one account.
3. Run `~/repo-mirror/sync.sh` (in the background; the initial clone of a few hundred repos takes a few minutes). Requires `gh` authenticated with access to those accounts' private repos.

## Notes

- Shallow default-branch mirrors: history, other branches, and files over what's on the default branch tip won't be found. For those, fall back to `git log -S` in a full clone or GitHub web search.
- The mirror can contain private data. Keep it out of synced/shared folders and never commit its contents anywhere.
