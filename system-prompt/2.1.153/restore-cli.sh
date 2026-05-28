#!/bin/bash
# Restore Claude Code CLI from backup

set -e

# Find claude CLI using which and common locations
get_claude_cli() {
    # Method 1: Use 'which claude' and follow symlinks
    local claude_bin=$(which claude 2>/dev/null)
    if [ -n "$claude_bin" ]; then
        local real_path=$(realpath "$claude_bin")
        local cli_path=$(dirname "$real_path")/cli.js
        if [ -f "$cli_path" ]; then
            echo "$cli_path"
            return 0
        fi
    fi

    # Method 2: Check common npm global locations
    for loc in "/opt/homebrew/lib/node_modules/@anthropic-ai/claude-code/cli.js" \
               "/usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js"; do
        if [ -f "$loc" ]; then
            echo "$loc"
            return 0
        fi
    done

    # Method 3: Check local install location
    local claude_launcher="$HOME/.claude/local/claude"
    if [ -f "$claude_launcher" ]; then
        local bin_path=$(grep 'exec' "$claude_launcher" | head -1 | sed 's/.*exec "\([^"]*\)".*/\1/')
        [ -n "$bin_path" ] && realpath "$bin_path"
        return 0
    fi

    return 1
}

# Allow custom path for testing, otherwise find it dynamically
if [ -n "$1" ]; then
    CLI_PATH="$1"
else
    CLI_PATH=$(get_claude_cli)
    if [ -z "$CLI_PATH" ]; then
        echo "Error: Could not find claude CLI. Is claude installed?"
        exit 1
    fi
fi
BACKUP_PATH="$CLI_PATH.backup"

if [ ! -f "$BACKUP_PATH" ]; then
    echo "Error: No backup found at $BACKUP_PATH"
    exit 1
fi

cp "$BACKUP_PATH" "$CLI_PATH"
echo "Restored from backup."
