#!/bin/bash
# Restore Claude Code CLI from backup

set -e

# Allow custom path for testing
if [ -n "$1" ]; then
    CLI_PATH="$1"
    BACKUP_PATH="$1.backup"
else
    CLI_PATH="$HOME/.claude/local/node_modules/@anthropic-ai/claude-code/cli.js"
    BACKUP_PATH="$HOME/.claude/local/node_modules/@anthropic-ai/claude-code/cli.js.backup"
fi

if [ ! -f "$BACKUP_PATH" ]; then
    echo "Error: No backup found at $BACKUP_PATH"
    exit 1
fi

cp "$BACKUP_PATH" "$CLI_PATH"
echo "Restored from backup."
