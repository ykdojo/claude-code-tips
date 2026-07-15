---
name: github-search
description: Full-text search across all of the user's GitHub repos (including private ones) using a local mirror and ripgrep. Use for "where did I put X", "which repo has X", or any search spanning the user's repos - gh search code / the REST API cannot reliably search private repos.
---

# GitHub search

GitHub's modern code search (the one that indexes private repos) is web-only; `gh search code` uses the legacy engine and often returns nothing for private repos. Instead, search a local mirror of all the user's repos - it covers the same content as GitHub's index (default branch, non-fork) and a full search takes milliseconds.

## Searching

Always refresh first - it exits instantly if the mirror was synced within the last hour, and takes ~15s otherwise (`--force` syncs regardless of age):

```bash
~/repo-mirror/sync.sh
rg -il 'pattern' ~/repo-mirror/repos          # which files
rg -in 'pattern' ~/repo-mirror/repos | head   # matching lines
```

## First-time setup

If `~/repo-mirror` doesn't exist: copy this skill's `sync.sh` to `~/repo-mirror/sync.sh` (executable), ask the user which GitHub accounts to mirror (don't guess - they may manage several), write them one per line to `~/repo-mirror/owners.txt`, then run `sync.sh` in the background (initial clone takes a few minutes; needs `gh` auth with access to those accounts).

## Caveats

- Only the default-branch tip is mirrored - for history or other branches, use `git log -S` in a full clone or GitHub web search.
- The mirror may contain private data: keep it out of synced folders and never commit or publish its contents.
