---
name: reddit-fetch
description: Fetch content from Reddit using Gemini CLI when WebFetch is blocked. Use when accessing Reddit URLs, researching topics on Reddit, or when Reddit returns 403/blocked errors. (user)
---

# Reddit Fetch via Gemini CLI

When WebFetch fails to access Reddit (blocked, 403, etc.), use Gemini CLI via tmux.

Pick a unique session name (e.g., `gemini_abc123`) and use it consistently throughout.

## Setup

```bash
tmux new-session -d -s <session_name> -x 200 -y 50
tmux send-keys -t <session_name> 'gemini' Enter
sleep 3  # wait for Gemini CLI to load
```

## Send query and capture output

```bash
tmux send-keys -t <session_name> 'Your Reddit query here' Enter
sleep 30  # wait for response (adjust as needed, up to 90s for complex searches)
tmux capture-pane -t <session_name> -p -S -500  # capture output
```

## How to tell if Enter was sent

Look for YOUR QUERY TEXT specifically. Is it inside or outside the bordered box?

**Enter NOT sent** - your query is INSIDE the box:
```
╭─────────────────────────────────────╮
│ > Your actual query text here       │
╰─────────────────────────────────────╯
```

**Enter WAS sent** - your query is OUTSIDE the box, followed by activity:
```
> Your actual query text here

⠋ Our hamsters are working... (processing)

╭────────────────────────────────────────────╮
│ >   Type your message or @path/to/file     │
╰────────────────────────────────────────────╯
```

Note: The empty prompt `Type your message or @path/to/file` always appears in the box - that's normal. What matters is whether YOUR query text is inside or outside the box.

If your query is inside the box, run `tmux send-keys -t <session_name> Enter` to submit.

## Cleanup when done

```bash
tmux kill-session -t <session_name>
```
