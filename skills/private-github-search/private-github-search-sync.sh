#!/bin/bash
# Shallow-mirror all repos (excluding forks) of the GitHub accounts listed in
# owners.txt, for fast local full-text search with ripgrep.
#
# Layout (everything lives next to this script):
#   owners.txt        - one GitHub username per line (comments with # allowed)
#   repos/<owner>/<repo> - shallow clones, default branch only
#
# Runs in place from the installed plugin - the mirror lives at ~/repo-mirror
# (override with REPO_MIRROR_DIR).
#
# Usage:  private-github-search-sync.sh           - sync if the last sync was over an hour ago
#         private-github-search-sync.sh --force   - sync regardless of age
# Search: rg 'pattern' <mirror-dir>/repos
set -u

MIRROR_DIR="${REPO_MIRROR_DIR:-$HOME/repo-mirror}"
mkdir -p "$MIRROR_DIR"
OWNERS_FILE="$MIRROR_DIR/owners.txt"
STAMP="$MIRROR_DIR/.last-sync"
mkdir -p "$MIRROR_DIR/repos"

if [ "${1:-}" != "--force" ] && [ -e "$STAMP" ] && [ -n "$(find "$STAMP" -mmin -60 2>/dev/null)" ]; then
  echo "Fresh: last synced $(date -r "$STAMP" '+%H:%M') (under an hour ago), skipping. Use --force to sync anyway."
  exit 0
fi

if [ ! -s "$OWNERS_FILE" ]; then
  echo "No owners configured. Add one GitHub username per line to $OWNERS_FILE" >&2
  exit 1
fi

list_repos() {
  grep -v -e '^#' -e '^[[:space:]]*$' "$OWNERS_FILE" | while read -r owner; do
    gh repo list "$owner" --limit 500 --json nameWithOwner,isFork \
      -q '.[] | select(.isFork | not) | .nameWithOwner'
  done
}

sync_one() {
  repo="$1"
  dir="$2/repos/$repo"
  if [ -d "$dir/.git" ]; then
    out=$(git -C "$dir" fetch --depth 1 origin HEAD 2>&1 \
      && git -C "$dir" reset --hard FETCH_HEAD -q 2>&1) \
      || echo "FAIL update $repo: $out"
  else
    out=$(gh repo clone "$repo" "$dir" -- --depth 1 --single-branch -q 2>&1) \
      || echo "FAIL clone $repo: $out"
  fi
}
export -f sync_one

list_repos | xargs -P 16 -I{} bash -c 'sync_one "$1" "$2"' _ {} "$MIRROR_DIR"
touch "$STAMP"
echo "Done: $(find "$MIRROR_DIR/repos" -maxdepth 3 -name .git | wc -l | tr -d ' ') repos in $MIRROR_DIR/repos"
