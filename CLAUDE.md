# Project Instructions

## Git Commit Guidelines
- Never add "Generated with Claude Code" or similar AI attribution in commit messages

## Writing Style for Tips
- Stay close to the user's original voice when they dictate content
- Don't paraphrase too much or add information they didn't mention
- Keep a conversational, personal tone - not too dry
- Use first person ("I found that...") to maintain authenticity
- Never use em dashes

## Testing with tmux

Use tmux to control another Claude Code instance for testing:

```bash
tmux kill-session -t test-session 2>/dev/null
tmux new-session -d -s test-session
tmux send-keys -t test-session 'claude' Enter
sleep 2
tmux send-keys -t test-session '/context' Enter
sleep 0.5
tmux send-keys -t test-session Enter
sleep 1
tmux capture-pane -t test-session -p
```
