#!/bin/bash

# Claude Code Tips - Setup Script
# Automates setup of recommended configurations from the tips repo

# Continue on errors (we handle them individually)
set +e

REPO_URL="https://raw.githubusercontent.com/ykdojo/claude-code-tips/main"
SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

# Check if running from local repo or via curl
if [[ -f "$SCRIPT_DIR/context-bar.sh" ]]; then
    RUN_MODE="local"
else
    RUN_MODE="remote"
fi

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GRAY='\033[0;90m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check for required dependencies
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is required but not installed.${NC}"
    echo "Install it with:"
    echo "  macOS:  brew install jq"
    echo "  Ubuntu: sudo apt install jq"
    echo "  Fedora: sudo dnf install jq"
    exit 1
fi

echo -e "${BLUE}Claude Code Tips - Setup Script${NC}"
echo "================================"
echo ""
echo "The following will be configured:"
echo ""

echo -e "${YELLOW}INSTALLS:${NC}"
echo "  1. DX plugin - slash commands (/dx:gha, /dx:clone, /dx:handoff) and skills (reddit-fetch)"
echo "  2. cc-safe - scans your settings for risky approved commands like 'rm -rf' or 'sudo'"
echo ""

echo -e "${YELLOW}SETTINGS (~/.claude/settings.json):${NC}"
echo "  3. Status line - shows model, git branch, uncommitted files, token usage at bottom of screen"
echo "  4. Disable auto-updates - prevents Claude Code from auto-updating (useful for system prompt patches)"
echo "  5. Lazy-load MCP tools - only loads MCP tool definitions when needed, saves context"
echo "  6. Read(~/.claude) permission - allows clone/half-clone commands to read conversation history"
echo "  7. Read(//tmp/**) permission - allows reading temporary files without prompts"
echo ""

echo -e "${YELLOW}SHELL CONFIG (~/.zshrc or ~/.bashrc):${NC}"
echo "  8. Aliases: c=claude, ch=claude --chrome, cs=claude --dangerously-skip-permissions"
echo "  9. Fork shortcut: --fs expands to --fork-session (e.g., claude -c --fs)"
echo ""

# Get items to skip
read -p "Skip any? [e.g., 1 4 7 or Enter for all]: " skip_input

# Convert to array
skip_items=()
if [[ -n "$skip_input" ]]; then
    read -ra skip_items <<< "$skip_input"
fi

should_skip() {
    local item="$1"
    for skip in "${skip_items[@]}"; do
        if [[ "$skip" == "$item" ]]; then
            return 0
        fi
    done
    return 1
}

echo ""
echo "Running setup..."
echo ""

# Ensure ~/.claude directory exists
mkdir -p "$CLAUDE_DIR"
mkdir -p "$CLAUDE_DIR/scripts"

# Initialize settings.json if it doesn't exist
if [[ ! -f "$SETTINGS_FILE" ]]; then
    echo '{}' > "$SETTINGS_FILE"
fi

# Helper to check if a JSON key/value exists
json_has_key() {
    local key="$1"
    jq -e "$key" "$SETTINGS_FILE" > /dev/null 2>&1
}

json_has_permission() {
    local perm="$1"
    jq -e ".permissions.allow | index(\"$perm\")" "$SETTINGS_FILE" > /dev/null 2>&1
}

# Detect shell config file
if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_RC="$HOME/.zshrc"
else
    SHELL_RC="$HOME/.bashrc"
fi

# ============================================
# 1. DX Plugin
# ============================================
if should_skip "1"; then
    echo -e "${GRAY}[Skipped]${NC} DX plugin"
elif claude plugin list 2>/dev/null | grep -q "dx@ykdojo"; then
    echo -e "${GREEN}[Already installed]${NC} DX plugin"
else
    echo "[Installing] DX plugin..."
    claude plugin marketplace add ykdojo/claude-code-tips 2>/dev/null || true
    claude plugin install dx@ykdojo
    echo -e "${GREEN}[Installed]${NC} DX plugin"
fi

# ============================================
# 2. cc-safe
# ============================================
if should_skip "2"; then
    echo -e "${GRAY}[Skipped]${NC} cc-safe"
elif command -v cc-safe &> /dev/null; then
    echo -e "${GREEN}[Already installed]${NC} cc-safe"
else
    echo "[Installing] cc-safe..."
    if npm install -g cc-safe 2>/dev/null; then
        echo -e "${GREEN}[Installed]${NC} cc-safe"
    elif sudo npm install -g cc-safe 2>/dev/null; then
        echo -e "${GREEN}[Installed]${NC} cc-safe (with sudo)"
    else
        echo -e "${YELLOW}[Manual install needed]${NC} cc-safe - run: sudo npm install -g cc-safe"
    fi
fi

# ============================================
# 3. Status line
# ============================================
if should_skip "3"; then
    echo -e "${GRAY}[Skipped]${NC} Status line"
elif json_has_key '.statusLine'; then
    echo -e "${GREEN}[Already configured]${NC} Status line"
else
    # Download or copy context-bar.sh
    if [[ "$RUN_MODE" == "local" ]]; then
        cp "$SCRIPT_DIR/context-bar.sh" "$CLAUDE_DIR/scripts/context-bar.sh"
    else
        curl -sL "$REPO_URL/scripts/context-bar.sh" -o "$CLAUDE_DIR/scripts/context-bar.sh"
    fi
    chmod +x "$CLAUDE_DIR/scripts/context-bar.sh"
    tmp=$(mktemp)
    jq '.statusLine = {"type": "command", "command": "~/.claude/scripts/context-bar.sh"}' "$SETTINGS_FILE" > "$tmp"
    mv "$tmp" "$SETTINGS_FILE"
    echo -e "${GREEN}[Configured]${NC} Status line"
fi

# ============================================
# 4. DISABLE_AUTOUPDATER
# ============================================
if should_skip "4"; then
    echo -e "${GRAY}[Skipped]${NC} Disable auto-updates"
elif json_has_key '.env.DISABLE_AUTOUPDATER'; then
    echo -e "${GREEN}[Already set]${NC} Disable auto-updates"
else
    tmp=$(mktemp)
    jq '.env.DISABLE_AUTOUPDATER = "1"' "$SETTINGS_FILE" > "$tmp"
    mv "$tmp" "$SETTINGS_FILE"
    echo -e "${GREEN}[Set]${NC} Disable auto-updates"
fi

# ============================================
# 5. ENABLE_TOOL_SEARCH
# ============================================
if should_skip "5"; then
    echo -e "${GRAY}[Skipped]${NC} Lazy-load MCP tools"
elif json_has_key '.env.ENABLE_TOOL_SEARCH'; then
    echo -e "${GREEN}[Already set]${NC} Lazy-load MCP tools"
else
    tmp=$(mktemp)
    jq '.env.ENABLE_TOOL_SEARCH = "true"' "$SETTINGS_FILE" > "$tmp"
    mv "$tmp" "$SETTINGS_FILE"
    echo -e "${GREEN}[Set]${NC} Lazy-load MCP tools"
fi

# ============================================
# 6. Read(~/.claude) permission
# ============================================
if should_skip "6"; then
    echo -e "${GRAY}[Skipped]${NC} Read(~/.claude) permission"
elif json_has_permission 'Read(~/.claude)'; then
    echo -e "${GREEN}[Already set]${NC} Read(~/.claude) permission"
else
    tmp=$(mktemp)
    jq '.permissions.allow = (.permissions.allow // []) + ["Read(~/.claude)"]' "$SETTINGS_FILE" > "$tmp"
    mv "$tmp" "$SETTINGS_FILE"
    echo -e "${GREEN}[Added]${NC} Read(~/.claude) permission"
fi

# ============================================
# 7. Read(//tmp/**) permission
# ============================================
if should_skip "7"; then
    echo -e "${GRAY}[Skipped]${NC} Read(//tmp/**) permission"
elif json_has_permission 'Read(//tmp/**)'; then
    echo -e "${GREEN}[Already set]${NC} Read(//tmp/**) permission"
else
    tmp=$(mktemp)
    jq '.permissions.allow = (.permissions.allow // []) + ["Read(//tmp/**)"]' "$SETTINGS_FILE" > "$tmp"
    mv "$tmp" "$SETTINGS_FILE"
    echo -e "${GREEN}[Added]${NC} Read(//tmp/**) permission"
fi

# ============================================
# 8. Terminal aliases
# ============================================
ALIASES_MARKER="# Claude Code aliases"

if should_skip "8"; then
    echo -e "${GRAY}[Skipped]${NC} Terminal aliases"
elif grep -q "$ALIASES_MARKER" "$SHELL_RC" 2>/dev/null; then
    echo -e "${GREEN}[Already configured]${NC} Terminal aliases"
else
    cat >> "$SHELL_RC" << 'EOF'

# Claude Code aliases
alias c='claude'
alias ch='claude --chrome'
alias cs='claude --dangerously-skip-permissions'
EOF
    echo -e "${GREEN}[Added]${NC} Terminal aliases to $SHELL_RC"
fi

# ============================================
# 9. Fork session shortcut
# ============================================
FS_MARKER="# Claude --fs shortcut"

if should_skip "9"; then
    echo -e "${GRAY}[Skipped]${NC} Fork shortcut"
elif grep -q "$FS_MARKER" "$SHELL_RC" 2>/dev/null; then
    echo -e "${GREEN}[Already configured]${NC} Fork shortcut"
else
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
    echo -e "${GREEN}[Added]${NC} Fork shortcut to $SHELL_RC"
fi

# ============================================
# SUGGESTIONS
# ============================================

echo ""
echo -e "${YELLOW}=== Suggestions ===${NC}"
echo ""

# Gemini CLI
if command -v gemini &> /dev/null; then
    echo -e "${GREEN}[Already installed]${NC} Gemini CLI"
else
    echo -e "${BLUE}[Optional]${NC} Gemini CLI - needed for reddit-fetch skill to work"
    echo "           Install: https://github.com/google-gemini/gemini-cli"
fi

# Playwright MCP
if claude mcp list 2>/dev/null | grep -q "playwright"; then
    echo -e "${GREEN}[Already installed]${NC} Playwright MCP"
else
    echo -e "${BLUE}[Optional]${NC} Playwright MCP - browser automation for testing web apps"
    echo "           Install: claude mcp add -s user playwright npx @playwright/mcp@latest"
fi

# ============================================
# DONE
# ============================================

echo ""
echo "================================"
echo -e "${GREEN}Setup complete!${NC}"
echo ""

# Check if shell config was modified
if ! should_skip "8" || ! should_skip "9"; then
    if ! grep -q "$ALIASES_MARKER" "$SHELL_RC" 2>/dev/null || ! grep -q "$FS_MARKER" "$SHELL_RC" 2>/dev/null; then
        : # nothing was added
    else
        echo "Run this to apply shell changes: source $SHELL_RC"
        echo ""
    fi
fi
