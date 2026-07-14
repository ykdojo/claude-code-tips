# 7 advanced Claude Code tips from 17 months of intense use

I've been using Claude Code intensely for about 17 months now, and I've ramped it up significantly over the past few months. So I wanted to share some of the more advanced tips I've learned.

## 1. Use auto mode

Auto mode lets Claude decide whether a command is safe to run in context, instead of asking you to approve every single one. (You can cycle to it with shift+tab.) I've been using it for a while and it's been working really well so far.

The main thing it fixes is mindless approving. When a command is too long to read carefully, or you're getting tired, you end up approving things without really thinking about them. Auto mode takes that pressure off, so I think it's a good default.

Over the past few months, using auto mode has allowed me to be a lot more productive while still feeling safe.

## 2. Use Claude Code from your phone

Remote Control lets you drive Claude Code from your phone, which pairs really well with auto mode - you can kick something off, walk away, and check on it from anywhere.

The way I personally like to use it: whenever I need to do something, I start up a thread and run `/remote-control` (or `/rc` for short), and drive that same session from my phone. Because it's the same session, you can go back and forth between your phone and your computer.

On your phone, you can use the transcription feature to talk to it quickly. Even if there are transcription mistakes, Claude is pretty much always able to figure them out.

There's also a server mode (`claude remote-control --spawn=worktree --capacity=N`) that lets you start brand new sessions from your phone, but I prefer the `/rc` method, and I turn it off when I'm not using it. A potential attacker who gets access to your Claude Code session essentially has access to everything on your computer, so I'd rather be careful. The exception is when I have a completely isolated environment - then it's super convenient to be able to start a Claude Code session from anywhere from your phone.

## 3. Use Fable 5 as much as you can

I've found that it's just generally a more capable model than Opus 4.6 or 4.8, and it's more friendly and easier to deal with than Opus 4.8. It feels like the best of both worlds: the ease of working with Opus 4.6, but also the intelligence of Opus 4.8.

By no means is it a perfect model, but it is the best model we've seen. So I think it's an advantage to use it as much as possible.

## 4. Give it a separate machine to control

As an experiment, I decided to [give Claude Code full access to one of my spare machines](https://github.com/ykdojo/claude-controls-mac) so that it could control it, and I could start new sessions from my phone without worrying about leaked data.

So far, it's been working well. It's able to do anything on my spare laptop through computer use: it can click and drag things, and it can use the browser through Playwright and Claude in Chrome. I give it separate accounts so it doesn't mess things up. And the freedom of just letting it do everything it needs to do with `--dangerously-skip-permissions` - I've found that to be great.

## 5. Master the loop: investigate, design, implement, verify

After implementing many features and fixing many bugs with Claude Code, I found a simple loop like this to be pretty effective.

**Investigate**: ask it questions about the problem and try to understand it as much as you can. Pull related issues, Slack threads, and all the relevant context so you can get the full context of the problem. If it's a bug, create reproducible steps so you can verify your solution later.

**Design**: discuss potential solutions, trade-offs, and what might be the best way forward.

**Implement**: this is kind of a straightforward path once you've done solid investigation and design. But try to keep the code simple - it might create overly complex code, or touch other parts of the codebase or things you haven't asked for. So ask it to keep it concise.

**Verify**: review the changes by asking it about specific parts of what it's made. You can have it create a draft PR and make sure it looks good. Go back and forth.

This is a good way to ensure you move quickly, but with quality.

## 6. Use Claude in Chrome, if you haven't yet

I [touched on this in my earlier tips](https://github.com/ykdojo/claude-code-tips?tab=readme-ov-file#tip-9-complete-the-write-test-cycle-for-autonomous-tasks): for most browser tasks, you could use Playwright and other tools. But what makes Claude in Chrome really convenient is that it runs in your own browser profile, so you can give it access to logged-in state without having to provide credentials - and you can use different accounts.

It still makes mistakes, though. So you want to either be super careful about it and watch it closely, or give it separate accounts.

## 7. Use it to learn faster, not to replace understanding

If it produces complex code that you don't understand, sometimes that's fine for a casual project. But if it's a more serious project and you want to understand what's going on, ask questions about it.

If there's a draft PR you want to review, or maybe someone else's PR, ask it to walk you through the changes so you can understand them well. If you don't understand specific parts, don't be afraid to ask basic questions - you can ask deeper and deeper questions until you understand it fully. You can ask it to simplify things, or to summarize its responses.

Really, work with it as a learning partner.
