# Claude Code Scripts

## context-bar.sh

A complete status line script for Claude Code that shows model, directory, git branch, uncommitted file count, sync status with origin, and context usage.

**Example output:** `Opus 4.5 | 📁myproject | 🔀main (2 files uncommitted, synced) | ████▄░░░░░ 45% of 200k tokens used`

### Installation

1. Copy the script to your Claude scripts directory:
   ```bash
   mkdir -p ~/.claude/scripts
   cp context-bar.sh ~/.claude/scripts/
   chmod +x ~/.claude/scripts/context-bar.sh
   ```

2. Update your `~/.claude/settings.json`:
   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "~/.claude/scripts/context-bar.sh"
     }
   }
   ```

That's it!

### Requirements

- `jq` (for JSON parsing)
- `bash`
- `git` (optional, for branch display)

### How it works

Claude Code passes session metadata to status line commands via stdin as JSON, including:
- `model.display_name` - The model name
- `cwd` - Current working directory
- `transcript_path` - Path to the session transcript JSONL file

The script parses the transcript to calculate context usage from the most recent API response's token counts (input + cache tokens).
