#!/bin/bash

# Container setup - non-interactive, simplified for safe-assistant

set +e

REPO_URL="https://raw.githubusercontent.com/ykdojo/claude-code-tips/main"
CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
SHELL_RC="$HOME/.bashrc"

if ! command -v jq &> /dev/null; then
    echo "Error: jq required"
    exit 1
fi

echo "Container setup..."

# Ensure ~/.claude directory exists
mkdir -p "$CLAUDE_DIR"
mkdir -p "$CLAUDE_DIR/scripts"

# Initialize settings.json if it doesn't exist
if [[ ! -f "$SETTINGS_FILE" ]]; then
    echo '{}' > "$SETTINGS_FILE"
fi

# Helper to check if a JSON key exists
json_has_key() {
    local key="$1"
    jq -e "$key" "$SETTINGS_FILE" > /dev/null 2>&1
}

# DX Plugin
if claude plugin list 2>/dev/null | grep -q "dx@ykdojo"; then
    echo "[OK] DX plugin"
else
    echo "[Installing] DX plugin..."
    claude plugin marketplace add ykdojo/claude-code-tips 2>/dev/null || true
    claude plugin install dx@ykdojo
    echo "[Done] DX plugin"
fi

# Status line
if ! json_has_key '.statusLine'; then
    curl -sL "$REPO_URL/scripts/context-bar.sh" -o "$CLAUDE_DIR/scripts/context-bar.sh"
    chmod +x "$CLAUDE_DIR/scripts/context-bar.sh"
    tmp=$(mktemp)
    jq '.statusLine = {"type": "command", "command": "~/.claude/scripts/context-bar.sh"}' "$SETTINGS_FILE" > "$tmp"
    mv "$tmp" "$SETTINGS_FILE"
    echo "[Done] Status line"
fi

# Disable auto-updates
if ! json_has_key '.env.DISABLE_AUTOUPDATER'; then
    tmp=$(mktemp)
    jq '.env.DISABLE_AUTOUPDATER = "1"' "$SETTINGS_FILE" > "$tmp"
    mv "$tmp" "$SETTINGS_FILE"
    echo "[Done] Disable auto-updates"
fi

# Lazy-load MCP tools
if ! json_has_key '.env.ENABLE_TOOL_SEARCH'; then
    tmp=$(mktemp)
    jq '.env.ENABLE_TOOL_SEARCH = "true"' "$SETTINGS_FILE" > "$tmp"
    mv "$tmp" "$SETTINGS_FILE"
    echo "[Done] Lazy-load MCP tools"
fi

# Aliases (c and cs only - no ch since no Chrome in container)
if ! grep -q "# Claude Code aliases" "$SHELL_RC" 2>/dev/null; then
    cat >> "$SHELL_RC" << 'EOF'

# Claude Code aliases
alias c='claude'
alias cs='claude --dangerously-skip-permissions'
EOF
    echo "[Done] Aliases"
fi

# Fork shortcut
if ! grep -q "# Claude --fs shortcut" "$SHELL_RC" 2>/dev/null; then
    cat >> "$SHELL_RC" << 'EOF'

# Claude --fs shortcut
claude() {
  local args=()
  for arg in "$@"; do
    if [[ "$arg" == "--fs" ]]; then
      args+=("--fork-session")
    else
      args+=("$arg")
    fi
  done
  command claude "${args[@]}"
}
EOF
    echo "[Done] Fork shortcut"
fi

echo "Setup complete!"
