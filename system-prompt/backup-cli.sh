#!/bin/bash
# Backup script for Claude Code CLI bundle
# Only backs up if the file matches the known original hash

set -e

# Known original - update these when Claude Code updates
EXPECTED_VERSION="2.0.55"
EXPECTED_HASH="97641f09bea7d318ce5172d536581bb1da49c99b132d90f71007a3bb0b942f57"

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

# Check if backup already exists
if [ -f "$BACKUP_PATH" ]; then
    echo "Error: Backup already exists at $BACKUP_PATH"
    echo "Delete it manually if you want to create a new backup."
    exit 1
fi

# Check if cli.js exists
if [ ! -f "$CLI_PATH" ]; then
    echo "Error: CLI not found at $CLI_PATH"
    exit 1
fi

# Compute current hash
CURRENT_HASH=$(shasum -a 256 "$CLI_PATH" | cut -d' ' -f1)

# Compare hashes
if [ "$CURRENT_HASH" != "$EXPECTED_HASH" ]; then
    echo "Error: Hash mismatch - file may be modified or different version"
    echo ""
    echo "Expected (v$EXPECTED_VERSION): $EXPECTED_HASH"
    echo "Current:                       $CURRENT_HASH"
    echo ""
    echo "If Claude Code was updated, update EXPECTED_VERSION and EXPECTED_HASH in this script."
    exit 1
fi

# Create backup
cp "$CLI_PATH" "$BACKUP_PATH"
echo "Backup created: $BACKUP_PATH"
echo "Version: $EXPECTED_VERSION"
echo "Hash: $EXPECTED_HASH"
