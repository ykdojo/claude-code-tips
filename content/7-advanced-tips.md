# 7 advanced Claude Code tips from 17 months of intense use

I've been using Claude Code intensely for 17 months now - pretty much since it launched - and I've ramped it up significantly over the past few months. So I wanted to share some of the more advanced things I've learned.

## 1. Use auto mode

Auto mode lets Claude decide whether a command is safe to run in context, instead of asking you to approve every single one. (You can cycle to it with shift+tab.) I've been using it for a while and it's been working well enough so far.

The main thing it fixes is mindless approving. When a command is too long to read carefully, or you're getting tired, you end up approving things without really thinking about them. Auto mode takes that pressure off, so I think it's a good default.

If you still want to be careful, you can always approve things manually without auto mode. And if you want to give it complete independence, you can [run Claude Code in a container with `--dangerously-skip-permissions`](https://github.com/ykdojo/claude-code-tips?tab=readme-ov-file#tip-19-isolated-environments-for-long-running-risky-tasks).

## 2. Use Claude Code from your phone

Remote Control lets you drive Claude Code from your phone, which pairs really well with auto mode - you can kick something off, walk away, and check on it from anywhere.

The way I personally like to use it: whenever I need to do something, I start up a thread and run `/remote-control` (or `/rc` for short), follow the instructions, and drive that same session from my phone. Because it's the same session, you can go back and forth between your phone and your computer.

There's also a server mode (`claude remote-control --spawn=worktree --capacity=N`) that lets you start brand new sessions from your phone, but I prefer the `/rc` method, and I turn it off when I'm not using it. A potential attacker who gets access to your Claude Code session essentially has access to everything on your computer, so I'd rather be careful. The exception is when I have a totally [isolated environment](https://github.com/ykdojo/claude-code-tips?tab=readme-ov-file#tip-19-isolated-environments-for-long-running-risky-tasks) - then it's super convenient to be able to start a Claude Code session from anywhere from your phone.

Docs: [Remote Control](https://code.claude.com/docs/en/remote-control).

## 3. Use Fable 5 as much as you can

I've found that it's just generally a more capable model than Opus 4.6 or 4.8, and it's more friendly and easier to deal with than Opus 4.8. It feels like the best of both worlds: the ease of working with Opus 4.6, but also the intelligence of Opus 4.8.

By no means is it a perfect model, but it is the best model we've seen. So I think it's an advantage to use it as much as possible.

## 4. Use Claude in Chrome, if you haven't yet

I [touched on this in my earlier tips](https://github.com/ykdojo/claude-code-tips?tab=readme-ov-file#tip-9-complete-the-write-test-cycle-for-autonomous-tasks): for most browser tasks, you could use Playwright and other tools. But what makes Claude in Chrome really convenient is that it runs in your own browser profile, so you can give it access to logged-in state without having to provide credentials - and you can use different accounts.

It still makes mistakes, though. So you want to either be super careful about it and watch it closely, or give it separate accounts.
