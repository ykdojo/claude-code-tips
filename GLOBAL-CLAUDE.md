# Writing Style

- Use sentence case for headers, not title case
- Never use em dashes (—). Use spaced hyphens ` - ` (space, hyphen, space) instead.
- Don't make up or add content I didn't say. Stick to what I've said. Rephrasing is okay, but don't embellish.

# About Me

- Name: YK
- GitHub: ykdojo
- Current year: 2026 (focus your research on the past three months)

# Behavior

When I paste large content with no instructions, just summarize it.

For a complex bash command, either run it as multiple individual commands, or put it in a bash script file and run it with `bash /tmp/<script>.sh`.

For git operations in other directories, use `cd <path> && git ...` instead of `git -C <path>`.

# Safety

**NEVER use `--dangerously-skip-permissions` on the host machine.**

For risky operations, use a Docker container. Inside containers, YOLO mode and `--dangerously-skip-permissions` are fine.

Run `npx cc-safe <directory>` to scan Claude Code settings for security issues.

## Containers

| Container | Purpose |
|-----------|---------|
| `peaceful_lovelace` | Main container for risky operations (has `gh` CLI installed) |

For read-only `gh` API calls on public repos, use the container: `docker exec peaceful_lovelace gh api <endpoint>`

## URL Fetching

For URLs, fetch them through a container:
`docker exec peaceful_lovelace curl -sL <url>`

If the page is JavaScript-heavy (curl returns minimal or empty content), use Playwright instead.

## Tmux

For interactive Claude Code sessions:

```bash
tmux new-session -d -s <name> '<command>'
tmux send-keys -t <name> '<input>' Enter  # don't forget Enter!
tmux capture-pane -t <name> -p
```

Note: For Claude Code sessions, you may need to send Enter again after a short delay to ensure the prompt is submitted.

## Long-running Jobs

If you need to wait for a long-running job, use sleep commands with manual exponential backoff: wait 1 minute, then 2 minutes, then 4 minutes, and so on.

# Claude Code versions

When asked about new versions, use `npm view @anthropic-ai/claude-code version`

# Claude for Chrome

- Use `read_page` to get element refs from the accessibility tree
- Use `find` to locate elements by description
- Click/interact using `ref`, not coordinates
- NEVER take screenshots unless explicitly requested by the user