# Use GitHub as your knowledge base

I've been using GitHub as my knowledge base - kind of a Notion replacement. Instead of opening up a Notion document, I just create a new repo or find an existing private repo where I can put my notes. I dictate my thoughts and develop my notes there, and if I have some research to do, I let Claude Code do the research and update those repos.

I also have repos for skills. If I have to repeat the same type of work over and over again, it's nice to be able to have that in a skill format so I can reuse those workflows.

The one missing piece is search: GitHub's own search doesn't work well for private repos. I wrote about that problem and how I solved it in [The missing private GitHub search](https://github.com/ykdojo/claude-code-tips/blob/main/content/the-missing-private-github-search.md) - it's a [skill](https://github.com/ykdojo/claude-code-tips/tree/main/skills/private-github-search) that mirrors all your repos locally and searches them with ripgrep, so I can just ask Claude Code "which repo has X" and it finds it.
