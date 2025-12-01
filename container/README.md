# Claude Code Container

A Docker container for running risky, long-running agentic tasks in isolation. Includes Claude Code, Gemini CLI (as a fallback for blocked sites), and all the customizations from this repo.

## Why Use This

- **Isolation**: If something goes wrong, it's contained
- **Long-running tasks**: Leave it running without tying up your terminal
- **YOLO mode**: Auto-approve everything in a sandboxed environment
- **Reproducible setup**: Same config every time

## Quick Start

```bash
# Build the image (from repo root)
docker build -t claude-code-container -f container/Dockerfile .

# Run with the repo mounted (so symlinks work)
docker run -it -v $(pwd):/home/claude/claude-code-tips claude-code-container
```

## First-Time Authentication

After starting the container, you need to authenticate both CLIs manually:

### 1. Claude Code

```bash
claude
```

Follow the prompts to log in with your Anthropic account. This opens a browser URL - copy it to your host browser if needed.

### 2. Gemini CLI

```bash
gemini
```

Follow the prompts to log in with your Google account.

## What's Included

- **Claude Code 2.0.55** with system prompt patches applied (~39% token savings)
- **Gemini CLI** for fetching Reddit and other blocked sites
- **tmux** for the reddit-fetch skill
- **Status bar** showing model, git status, and token usage
- **Skills** symlinked from the mounted repo

## Persisting Auth

To avoid re-authenticating every time, you can mount the credential directories:

```bash
docker run -it \
  -v $(pwd):/home/claude/claude-code-tips \
  -v ~/.gemini:/home/claude/.gemini \
  claude-code-container
```

Note: Claude Code credentials are stored in macOS Keychain, so you'll need to re-auth Claude each time (or use `ANTHROPIC_API_KEY` env var if you have one).

## Working with Projects

Mount your project directory:

```bash
docker run -it \
  -v $(pwd):/home/claude/claude-code-tips \
  -v /path/to/your/project:/home/claude/workspace \
  claude-code-container
```

Then `cd /home/claude/workspace` and start Claude Code there.

## Updating

If Claude Code or this repo updates:

1. Rebuild the image: `docker build -t claude-code-container -f container/Dockerfile .`
2. Run a new container (the setup script will re-apply patches)
