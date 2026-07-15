# The missing private GitHub search

If you try to search your own private repos from the command line:

```bash
gh search code 'todo' --owner your-username
```

You'll likely get nothing back, even when you know it's there.

GitHub has two search engines. The good one - the code search that powers github.com/search and does index your private repos - is web-only. The REST API, and therefore the `gh` CLI, still runs on the legacy engine: default branch only, files under 384 KB, only repos with activity in the last year, and in practice it can return nothing at all for private repos. The new engine has no API.

Even the web one has a catch: a private repo you've never searched may not be in the index at all. When I searched one for the first time, GitHub said it was still indexing the repo and told me to try again in a few minutes.

I ran into this trying to find a note I'd saved in one of my repos, without remembering which one. Across my two accounts I have 228 non-fork repos, 161 of them private, so clicking around wasn't an option. The alternative that works: mirror everything locally and search with ripgrep.

- Shallow clones (`--depth 1`, default branch, forks excluded) of all 228 repos come to 2.8 GB
- A full-text search over all of it takes about 1 second cold, 11 ms warm
- Checking all repos to see if there's anything to update takes about 15 seconds with 16 parallel fetches, and if the mirror already synced within the past hour, the script skips syncing altogether

The coverage is the same as GitHub's own search index (default branch tip, no forks), except it actually includes all your private repos, archived ones too - and there's no indexing lag, so a fresh push is searchable seconds later.

I turned this into a Claude Code skill, so I can just ask "which repo has X" and it refreshes the mirror and greps. The whole thing is a [~60 line bash script](https://github.com/ykdojo/claude-code-tips/blob/main/skills/private-github-search/private-github-search-sync.sh) plus a [skill file](https://github.com/ykdojo/claude-code-tips/tree/main/skills/private-github-search).
