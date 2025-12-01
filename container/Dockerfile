# Claude Code Container with Gemini CLI fallback
# For running risky long-running agentic tasks in isolation
#
# Build (from repo root):
#   docker build -t claude-code-container -f container/Dockerfile .
#
# Run (mount this repo for symlinks to work):
#   docker run -it -v $(pwd):/home/claude/claude-code-tips claude-code-container
#
# After starting, you need to manually authenticate:
#   1. Run `claude` and complete Anthropic login
#   2. Run `gemini` and complete Google login

FROM node:20-bookworm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    tmux \
    jq \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code 2.0.55 (specific version for patching) and Gemini CLI
# Must be done as root for global npm install
RUN npm install -g @anthropic-ai/claude-code@2.0.55 @google/gemini-cli

# Copy patching files and apply patches (must be done as root before user switch)
COPY system-prompt/2.0.55/ /tmp/patches/
RUN CLI_PATH=/usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js && \
    cp "$CLI_PATH" "$CLI_PATH.backup" && \
    node /tmp/patches/patch-cli.js "$CLI_PATH" && \
    rm -rf /tmp/patches

# Create claude user (don't run as root)
RUN useradd -m -s /bin/bash claude
USER claude
WORKDIR /home/claude

# Create necessary directories
RUN mkdir -p ~/.claude/scripts ~/.claude/skills/reddit-fetch

# Set up aliases for convenience
RUN echo "alias c='claude'" >> ~/.bashrc && \
    echo "alias g='gemini'" >> ~/.bashrc

# Set up status line in settings.json
RUN echo '{"statusLine":{"type":"command","command":"~/.claude/scripts/context-bar.sh"}}' > ~/.claude/settings.json

# Copy setup script that creates symlinks and applies patches
COPY --chown=claude:claude container/setup.sh /home/claude/setup.sh
RUN chmod +x /home/claude/setup.sh

# Working directory for projects
WORKDIR /home/claude/workspace

# Run setup on container start (creates symlinks to mounted volume)
CMD ["/home/claude/setup.sh"]
