# 10 Claude Code tips from Boris, the creator of Claude Code, summarized

Boris Cherny, the creator of Claude Code, recently shared [10 tips on X](https://x.com/bcherny/status/2017742741636321619) sourced from the Claude Code team. Here's a quick summary I created with the help of Claude Code and Opus 4.5.

## 1. Do more in parallel

Spin up 3-5 git worktrees, each running its own Claude session. This is the single biggest productivity unlock from the team. Some people set up shell aliases (za, zb, zc) to hop between worktrees in one keystroke.

## 2. Start every complex task in plan mode

Pour your energy into the plan so Claude can one-shot the implementation. If something goes sideways, switch back to plan mode and re-plan instead of pushing through. One person even spins up a second Claude to review the plan as a staff engineer.

## 3. Invest in your CLAUDE.md

After every correction, tell Claude: "Update your CLAUDE.md so you don't make that mistake again." Claude is eerily good at writing rules for itself. Keep iterating until Claude's mistake rate measurably drops.

## 4. Create your own skills and commit them to git

If you do something more than once a day, turn it into a skill or slash command. Examples from the team: a `/techdebt` command to find duplicated code, a command that syncs Slack/GDrive/Asana/GitHub into one context dump, and analytics agents that write dbt models.

## 5. Claude fixes most bugs by itself

Paste a Slack bug thread into Claude and just say "fix." Or say "Go fix the failing CI tests." Don't micromanage how. You can also point Claude at docker logs to troubleshoot distributed systems.

## 6. Level up your prompting

Challenge Claude - say "Grill me on these changes and don't make a PR until I pass your test." After a mediocre fix, say "Knowing everything you know now, scrap this and implement the elegant solution." Write detailed specs and reduce ambiguity - the more specific, the better the output.

## 7. Terminal and environment setup

The team loves Ghostty. Use `/statusline` to show context usage and git branch. Color-code your terminal tabs. Use voice dictation - you speak 3x faster than you type (hit fn twice on macOS).

## 8. Use subagents

Say "use subagents" when you want Claude to throw more compute at a problem. Offload tasks to subagents to keep your main context window clean. You can also route permission requests to Opus 4.5 via a hook to auto-approve safe ones.

## 9. Use Claude for data and analytics

Use Claude with the `bq` CLI (or any database CLI/MCP/API) to pull and analyze metrics. Boris says he hasn't written a line of SQL in 6+ months.

## 10. Learning with Claude

Enable the "Explanatory" or "Learning" output style in `/config` to have Claude explain the why behind its changes. You can also have Claude generate visual HTML presentations, draw ASCII diagrams of codebases, or build a spaced-repetition learning skill.

---

I resonate with a lot of these tips, so I recommend trying out at least a few of them. If you're looking for more Claude Code tips, I have a repo with 43 tips of my own here: [claude-code-tips](https://github.com/ykdojo/claude-code-tips)
