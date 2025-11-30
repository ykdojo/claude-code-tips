#!/bin/bash
# Restore Claude Code CLI from backup

set -e

# Find claude CLI by checking shell rc files for alias, then following the launcher
get_claude_cli() {
    local claude_launcher=""

    # Check shell rc files for alias definition
    for rc in ~/.zshrc ~/.bashrc ~/.bash_profile; do
        if [ -f "$rc" ]; then
            local alias_line=$(grep "alias claude=" "$rc" 2>/dev/null | head -1)
            if [ -n "$alias_line" ]; then
                claude_launcher=$(echo "$alias_line" | sed "s/.*claude=['\"]\\([^'\"]*\\).*/\\1/")
                claude_launcher="${claude_launcher/#\~/$HOME}"
                [ -f "$claude_launcher" ] && break
                claude_launcher=""
            fi
        fi
    done

    # Fallback to default location
    if [ -z "$claude_launcher" ]; then
        claude_launcher="$HOME/.claude/local/claude"
    fi

    if [ ! -f "$claude_launcher" ]; then
        return 1
    fi

    # Extract the bin path from launcher and resolve to cli.js
    local bin_path=$(grep 'exec' "$claude_launcher" | head -1 | sed 's/.*exec "\([^"]*\)".*/\1/')
    [ -n "$bin_path" ] && realpath "$bin_path"
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
