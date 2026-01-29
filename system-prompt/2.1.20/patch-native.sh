#!/bin/bash
# Patch Claude Code native binary
# Usage: ./patch-native.sh [binary-path]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BINARY_PATH="${1:-$HOME/.local/share/claude/versions/2.1.20}"
BACKUP_PATH="${BINARY_PATH}.backup"
TMP_CLI="/tmp/native-cli-$$.js"

echo "Claude Code Native Binary Patcher"
echo "=================================="
echo ""

# Check binary exists
if [ ! -f "$BINARY_PATH" ]; then
  echo "Error: Binary not found at $BINARY_PATH"
  exit 1
fi

# Get expected hashes from patch-cli.js
EXPECTED_HASHES=$(grep -E "^\s+'native-|^\s+npm:" "$SCRIPT_DIR/patch-cli.js" | sed "s/.*'\([a-f0-9]\{64\}\)'.*/\1/" | tr '\n' ' ')

# Create backup if needed
if [ ! -f "$BACKUP_PATH" ]; then
  echo "Validating binary before creating backup..."

  # Extract cli.js to check hash
  TMP_CHECK="/tmp/native-cli-check-$$.js"
  node "$SCRIPT_DIR/native-extract.js" "$BINARY_PATH" "$TMP_CHECK" 2>/dev/null
  ACTUAL_HASH=$(shasum -a 256 "$TMP_CHECK" | cut -d' ' -f1)
  rm -f "$TMP_CHECK"

  # Validate hash
  if ! echo "$EXPECTED_HASHES" | grep -q "$ACTUAL_HASH"; then
    echo "Error: Binary hash doesn't match any expected hash"
    echo "Got:      $ACTUAL_HASH"
    echo "Expected: $EXPECTED_HASHES"
    echo ""
    echo "The binary may already be patched or is an unknown version."
    echo "To force, manually create the backup: cp \"$BINARY_PATH\" \"$BACKUP_PATH\""
    exit 1
  fi

  echo "Hash validated: $ACTUAL_HASH"
  echo "Creating backup: $BACKUP_PATH"
  cp "$BINARY_PATH" "$BACKUP_PATH"
else
  echo "Backup exists: $BACKUP_PATH"
  echo "Restoring from backup..."
  cp "$BACKUP_PATH" "$BINARY_PATH"
fi

# Extract cli.js
echo ""
echo "Step 1: Extracting cli.js..."
node "$SCRIPT_DIR/native-extract.js" "$BACKUP_PATH" "$TMP_CLI"

# Create cli.js backup for patcher
TMP_CLI_BACKUP="${TMP_CLI}.backup"
cp "$TMP_CLI" "$TMP_CLI_BACKUP"

# Patch cli.js
echo ""
echo "Step 2: Applying patches..."
node "$SCRIPT_DIR/patch-cli.js" "$TMP_CLI"

# Repack binary
echo ""
echo "Step 3: Repacking binary..."
node "$SCRIPT_DIR/native-repack.js" "$BACKUP_PATH" "$TMP_CLI" "$BINARY_PATH"

# Cleanup
rm -f "$TMP_CLI" "$TMP_CLI_BACKUP"

echo ""
echo "Done! Testing..."
"$BINARY_PATH" --version

echo ""
echo "Patched binary: $BINARY_PATH"
echo "Backup: $BACKUP_PATH"
