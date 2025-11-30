#!/bin/bash
# Backup script for Claude Code CLI bundle
# Only backs up if the file matches the known original hash

set -e

# Known original - update these when Claude Code updates
EXPECTED_VERSION="2.0.55"
EXPECTED_HASH="97641f09bea7d318ce5172d536581bb1da49c99b132d90f71007a3bb0b942f57"

# Allow custom path for testing
if [ -n "$1" ]; then
    CLI_PATH="$1"
    BACKUP_PATH="$1.backup"
else
    CLI_PATH="$HOME/.claude/local/node_modules/@anthropic-ai/claude-code/cli.js"
    BACKUP_PATH="$HOME/.claude/local/node_modules/@anthropic-ai/claude-code/cli.js.backup"
fi

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
