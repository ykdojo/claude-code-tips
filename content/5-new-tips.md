# 5 New Claude Code Tips

A while ago, I posted [32 Claude Code Tips: From Basics to Advanced](https://agenticcoding.substack.com/p/32-claude-code-tips-from-basics-to). Here's a quick update with 5 more tips.

## 1. `/copy` command

The simplest way to get Claude's output out of the terminal. Just type `/copy` and it copies Claude's last response to your clipboard as markdown.

## 2. `/fork` and `--fork-session`

Claude Code now has built-in conversation forking:

- `/fork` - fork from within a conversation
- `--fork-session` - use with `--resume` or `--continue` (e.g., `claude -c --fork-session`)

Since `--fork-session` has no short form, I created a shell function to use `--fs` as a shortcut. [You can see it here](https://github.com/ykdojo/claude-code-tips?tab=readme-ov-file#tip-21-clonefork-and-half-clone-conversations).

## 3. Plan mode for context handoff

Enter plan mode with `/plan` or Shift+Tab. Ask Claude to gather all the context the next agent needs:

> I just enabled plan mode. Bring over all of the context that you need for the next agent. The next agent will not have any other context, so you'll need to be pretty comprehensive.

When it's done, select Option 1 ("Yes, clear context and auto-accept edits") to start fresh with only the plan. The new Claude instance sees just the plan, no baggage from the old conversation.

## 4. Periodic CLAUDE\.md review

Your CLAUDE.md files get outdated over time. Instructions that made sense a few weeks ago might no longer be relevant. I created a `review-claudemd` skill that analyzes your recent conversations and suggests improvements. [You can check it here](https://github.com/ykdojo/claude-code-tips/tree/main/skills/review-claudemd).

## 5. Parakeet for voice transcription

I've been using voice transcription to talk to Claude Code instead of typing. I just added Parakeet support to [Super Voice Assistant](https://github.com/ykdojo/super-voice-assistant) (open source) and it's really fast - Parakeet v2 runs at ~110x realtime with 1.69% word error rate. Accurate enough for Claude Code.
