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

For a complex bash command, break it down into multiple simple commands so the user doesn't have to approve each one individually. Alternatively, put it in a bash script file and run it with `bash /tmp/<script>.sh`.

Example - instead of:
```bash
sleep 60 && ps aux | grep foo | wc -l && echo "---" && ls -la /some/path
```

Do this:
```bash
sleep 60
```
```bash
ps aux | grep foo | wc -l
```
```bash
ls -la /some/path
```

Also avoid complex pipes. Instead of:
```bash
grep "file: '" patch-cli.js | sed "s/.*file: '\([^']*\)'.*/\1/" | sort > /tmp/used.txt
```

Either run each step individually or put it in a script file and run with `bash /tmp/script.sh`.

For git operations in other directories, use `cd <path> && git ...` instead of `git -C <path>`.

Never use `2>&1` in bash commands. Keep stderr and stdout separate.

# Safety

**NEVER use `--dangerously-skip-permissions` on the host machine.**

For risky operations, use a Docker container. Inside containers, YOLO mode and `--dangerously-skip-permissions` are fine.

Run `npx cc-safe <directory>` to scan Claude Code settings for security issues.

## Containers

Use [safeclaw](https://github.com/ykdojo/safeclaw) containers (local: `/Users/yk/Desktop/projects/safeclaw`). Containers are named `safeclaw-<session-name>` (e.g., `safeclaw-work`, `safeclaw-research`).

To list running safeclaw containers: `docker ps --filter "name=safeclaw-"`

To create a new container: `cd /Users/yk/Desktop/projects/safeclaw && ./scripts/run.sh -s <name> -n`

For read-only `gh` API calls on public repos, use a running safeclaw container: `docker exec safeclaw-<name> bash -c 'gh api <endpoint>'`. If container `gh` lacks permissions, fall back to host `gh`.

## URL Fetching

Always fetch individual URLs through a safeclaw container:
`docker exec safeclaw-<name> curl -sL <url>`

If the page is JavaScript-heavy (curl returns minimal or empty content), use Playwright instead (safeclaw containers have Playwright installed).

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

# Claude for Chrome

- Use `read_page` to get element refs from the accessibility tree
- Use `find` to locate elements by description
- Click/interact using `ref`, not coordinates
- NEVER take screenshots unless explicitly requested by the user