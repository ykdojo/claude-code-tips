Clone the current conversation so the user can branch off and try a different approach.

Steps:
1. Get the current session ID by reading the most recent entry in `~/.claude/history.jsonl`
2. Run: `~/.claude/scripts/clone-conversation.sh <session-id>`
3. Tell the user they can access the cloned conversation with `claude -r` and look for the one marked `[CLONED]`
