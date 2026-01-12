# Automatically patching Claude Code to maximize token efficiency - a lesson in automation

### Motivation

I've been obsessively using Claude Code ever since it launched about 11 months ago, and I've gotten pretty good at using it effectively over that time. One principle I always stick to: minimize the context. This helps you not only save costs, but also maximize performance.

However, when you run `/context` in Claude Code, you will typically see about 10% of your token budget already consumed before you even send a single prompt. That's a lot. I wanted to cut this in half, down to around 5%.

### Why npm over native binary

Claude Code offers two installation methods: a native binary (built with Bun) or npm. The native binary is Anthropic's recommended approach—it doesn't require Node.js and tends to be more stable.

But here's the thing: the native binary isn't easy to edit. It's a bundled executable. With the npm installation, you get access to the actual JavaScript files, which means you can patch them directly.

That's why I went with npm—so I could modify the `cli.js` file and trim down the system prompt.

### The 4-step process

**1. Self-report**

I asked Claude Code itself: "What do you see in your system prompt and tool descriptions?" It can introspect and tell you exactly what's being sent to the API.

**2. Identify the biggest savings**

I had Claude Code analyze the prompt and give me a table of potential savings—character counts, token estimates, and which sections could be trimmed or removed entirely. One big win was the "approved commands list," which was eventually removed by Anthropic in a later version, but before that, it was a significant chunk of tokens.

**3. Write the code and apply the patches**

I created a `patch-cli.js` script that reads patch files (find/replace pairs) and applies them to the CLI bundle. There's also a checker that validates the patches applied correctly.

**4. Test to make sure it works**

Run `/context` to verify the token reduction. Test basic functionality. Make sure nothing broke.

### The evolution: from manual to automated

At first, I was patching manually for each new version. That got repetitive fast. Claude Code was releasing updates almost daily, and every version brought changes:

- Variable names would change (minified code)
- Specific prompts would get reworded
- Entire features would appear or disappear (like the approved commands list)

I tried having Claude Code update the patches for me, but the first attempts were painful. It would hit the same errors repeatedly, go in circles, and produce inconsistent results.

So I documented the entire process in `UPGRADING.md`. This file contains:

- Step-by-step instructions for upgrading patches to a new version
- How to run Claude Code in a container for safe experimentation
- Debugging techniques for finding where patches break
- A verification checklist

The key insight: the document even has a self-improvement clause. As Claude Code works through upgrades, it can update UPGRADING.md itself with new learnings.

### The pattern

What I realized is that this is a powerful pattern: combining deterministic automation with non-deterministic automation (like Claude Code or Codex). Use them in different situations, but in combination.

- **CLAUDE.md / AGENTS.md** - Instructions for the AI (non-deterministic)
- **UPGRADING.md / PROCESS.md** - Documented procedures
- **Scripts** - Deterministic automation

The AI handles the parts that require judgment (finding where text diverged, deciding how to update patches). The scripts handle the deterministic parts (applying patches, validating hashes, running tests).

### Example: CI job analysis

I have a `/gha` command that analyzes GitHub Actions failures. When a CI job fails, I give it the URL and it:

1. Fetches the logs using `gh` CLI
2. Identifies what specifically caused the failure
3. Checks flakiness by looking at the past 10-20 runs
4. Finds the breaking commit if there's a pattern
5. Searches for existing fix PRs

The command is just instructions in a markdown file. Claude Code does the actual investigation. But having the structured process means it doesn't miss steps or go off on tangents.

### Example: local Kubernetes development

I had a similar journey with local Kubernetes development using Tilt. It started as a mess of confusing setup steps in the README.

The progression:
1. Started with README improvements - removed confusing parts
2. Simplified commands ("tilt up" became just "tilt")
3. Moved the details to CLAUDE.md so the AI could handle setup
4. Then moved more into scripts
5. Added a custom health check script

Each iteration reduced the friction and the places where things could go wrong.

### The automation meta-lesson

Ask yourself:

1. **What do you find yourself doing over and over again?**
2. **Which parts can be solved deterministically?** (Scripts, simple commands)
3. **Which parts need AI?** (Judgment calls, debugging, adapting to changes)

Go through the process repeatedly and identify the most painful parts. Those are your automation targets.

But here's the key: **don't over-automate**. Simplify, simplify, simplify. Too many skills, CLAUDE.md files that are too long, overly complex scripts - these create their own maintenance burden. Sometimes the best automation is just removing the confusing parts.
