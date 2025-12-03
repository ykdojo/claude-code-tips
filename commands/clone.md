Clone the current conversation so the user can branch off and try a different approach.

Steps:
1. Get the current session ID and project path by reading the most recent entry in `~/.claude/history.jsonl` (both `sessionId` and `project` fields)
2. Run: `~/.claude/scripts/clone-conversation.sh <session-id> <project-path>`
   - Always pass the project path from the history entry, not the current working directory
3. Tell the user they can access the cloned conversation with `claude -r` and look for the one marked `[CLONED]`
