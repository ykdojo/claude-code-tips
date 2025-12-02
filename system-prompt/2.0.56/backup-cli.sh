#!/bin/bash
# Backup script for Claude Code CLI bundle
# Only backs up if the file matches the known original hash

set -e

# Known original - update these when Claude Code updates
EXPECTED_VERSION="2.0.56"
EXPECTED_HASH="ab7dc714eae784d2478f7831d43cabd14df5687d503d69381d08a0704e50386d"

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
