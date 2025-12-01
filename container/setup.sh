#!/bin/bash
# Setup script for Claude Code container
# Creates symlinks to mounted volume (patches are applied at build time)

set -e

REPO_PATH="/home/claude/claude-code-tips"
CLAUDE_DIR="$HOME/.claude"

echo "Claude Code Container Setup"
echo "==========================="

# Check if repo is mounted
if [ ! -d "$REPO_PATH" ]; then
    echo "Error: Repository not mounted at $REPO_PATH"
    echo "Run with: docker run -it -v \$(pwd):/home/claude/claude-code-tips claude-code-container"
    exit 1
fi

# Create symlinks for skills
echo "Creating symlinks..."
ln -sf "$REPO_PATH/skills/reddit-fetch/SKILL.md" "$CLAUDE_DIR/skills/reddit-fetch/SKILL.md"
echo "  ✓ Skills linked"

# Create symlink for status bar script
ln -sf "$REPO_PATH/scripts/context-bar.sh" "$CLAUDE_DIR/scripts/context-bar.sh"
echo "  ✓ Status bar script linked"

echo "  ✓ Patches applied at build time"

echo ""
echo "Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Run 'claude' and authenticate with Anthropic"
echo "  2. Run 'gemini' and authenticate with Google"
echo ""

# Start interactive shell
exec /bin/bash
