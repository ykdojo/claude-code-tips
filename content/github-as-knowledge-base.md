# Use GitHub as your knowledge base

Here's something I've been doing for some time now: whenever I need a place for something, I just create a new private GitHub repository for it and ask Claude Code to put stuff in it - take notes, do research there, whatever I need.

I also have repositories for skills. If I have to repeat the same type of work over and over again, it's nice to be able to have that in a skill format so I can reuse those workflows.

The one missing piece is search: GitHub's own search doesn't work well for private repos. I wrote about that problem and how I solved it in [The missing private GitHub search](https://github.com/ykdojo/claude-code-tips/blob/main/content/the-missing-private-github-search.md) - it's a [skill](https://github.com/ykdojo/claude-code-tips/tree/main/skills/private-github-search) that mirrors all your repos locally and searches them with ripgrep, so I can just ask Claude Code "which repo has X" and it finds it.

This article is part of [40+ Claude Code Tips: From Basics to Advanced](https://github.com/ykdojo/claude-code-tips).
