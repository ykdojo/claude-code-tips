# Safety

**NEVER use `--dangerously-skip-permissions` on the host machine.**

For risky operations, use a Docker container. Inside containers, YOLO mode and `--dangerously-skip-permissions` are fine.

## Containers

| Container | Purpose |
|-----------|---------|
| `peaceful_lovelace` | Main container for risky operations |
| `eager_moser` | Secondary/backup |
| `daphne` | Daft-related operations |
| `claude-history` | Reserved - don't use for general tasks |

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
