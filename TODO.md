# TODO

## Tip: Running Long-Running Risky Tasks Through a Container

I want to write a tip about isolating risky agentic workflows in a container.

### The Example

The task: "I want to make a simple post on the r/ClaudeAI subreddit. Can you help me come up with a good title based on the popular posts there?"

The post:

> Just found a funny but useful workaround for Claude Code's restrictions around accessing sites like Reddit:
>
> Create a SKILLS .md file that tells Claude to use Gemini CLI as a fallback (through tmux) when WebFetch fails.
>
> Then you can just ask stuff like "Check how X is regarded on Reddit" and it actually works. It goes back and forth with Gemini for a while - not the fastest process - but the results it reported back in my experiments have been pretty good so far.

This uses the reddit-fetch skill which delegates to Gemini CLI through tmux when WebFetch gets blocked. Gemini runs in YOLO mode, auto-approving all actions. It goes back and forth for a while - not the fastest process. Running this unsupervised is risky.

### Why a Container

The container provides isolation so if something goes wrong, it's contained. Good for:
- Long-running tasks you want to leave running
- YOLO mode workflows that auto-approve everything
- Experimental setups you don't want touching your main system

### Setup Involved

This tip will take time to prepare because we need to:
- Set up a Docker container with the right environment
- Install Claude Code, Gemini CLI, and tmux
- Manually log into both Claude Code and Gemini CLI (can't be automated, requires interactive auth)
