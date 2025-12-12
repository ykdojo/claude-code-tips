# About Me

- Name: YK
- GitHub: ykdojo

# Safety

**NEVER use `--dangerously-skip-permissions` on the host machine.**

For risky operations, use a Docker container. Inside containers, YOLO mode and `--dangerously-skip-permissions` are fine.

Run `npx cc-safe <directory>` to scan Claude Code settings for security issues.

## Containers

| Container | Purpose |
|-----------|---------|
| `peaceful_lovelace` | Main container for risky operations |
| `eager_moser` | Secondary/backup |
| `daphne` | Daft-related operations |
| `delfina` | Daft CI/GitHub Actions flaky test debugging |

```bash
docker exec peaceful_lovelace <command>
docker exec -it peaceful_lovelace bash  # interactive
```

## Tmux

For interactive Gemini or Claude Code sessions:

```bash
tmux new-session -d -s <name> '<command>'
tmux send-keys -t <name> '<input>' Enter  # don't forget Enter!
tmux capture-pane -t <name> -p
```

Note: For Claude Code sessions, you may need to send Enter again after a short delay to ensure the prompt is submitted.

## Long-running Jobs

If you need to wait for a long-running job, use sleep commands with manual exponential backoff: wait 1 minute, then 2 minutes, then 4 minutes, and so on.

# GitHub

Use `gh` CLI for GitHub URLs (PRs, issues, etc.) since WebFetch often fails with 404/auth errors.

# Python

Use Python 3.12 whenever Python 3 or Python is needed.
