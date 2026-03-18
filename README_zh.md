**🌐 Language / 语言: [English](README.md) | 中文**

# 45 个 Claude Code 使用技巧：从入门到进阶

这些是我总结的关于如何最大限度利用 Claude Code 的技巧，包括自定义状态栏脚本、将系统提示缩减一半、使用 Gemini CLI 作为 Claude Code 的"小弟"，以及让 Claude Code 在容器中运行自身。此外还包含 [dx 插件](#tip-44-安装-dx-插件)。

📺 [快速演示](https://www.youtube.com/watch?v=hiISl558JGE) - 看看这些技巧的实际效果，包括多 Claude 工作流和语音输入：

[![演示视频缩略图](assets/demo-thumbnail.png)](https://www.youtube.com/watch?v=hiISl558JGE)

<!-- TOC -->
## 目录

- [Tip 0: 自定义你的状态栏](#tip-0-自定义你的状态栏)
- [Tip 1: 学会几个必备的斜杠命令](#tip-1-学会几个必备的斜杠命令)
- [Tip 2: 用语音与 Claude Code 对话](#tip-2-用语音与-claude-code-对话)
- [Tip 3: 把大问题拆成小问题](#tip-3-把大问题拆成小问题)
- [Tip 4: 像高手一样使用 Git 和 GitHub CLI](#tip-4-像高手一样使用-git-和-github-cli)
- [Tip 5: AI 上下文就像牛奶——越新鲜越浓缩越好！](#tip-5-ai-上下文就像牛奶越新鲜越浓缩越好)
- [Tip 6: 把内容从终端里取出来](#tip-6-把内容从终端里取出来)
- [Tip 7: 设置终端别名以快速启动](#tip-7-设置终端别名以快速启动)
- [Tip 8: 主动压缩你的上下文](#tip-8-主动压缩你的上下文)
- [Tip 9: 为自主任务完成"写-测"循环](#tip-9-为自主任务完成写-测循环)
- [Tip 10: Cmd+A 和 Ctrl+A 是你的好朋友](#tip-10-cmda-和-ctrla-是你的好朋友)
- [Tip 11: 用 Gemini CLI 作为被屏蔽网站的备用方案](#tip-11-用-gemini-cli-作为被屏蔽网站的备用方案)
- [Tip 12: 投资你自己的工作流](#tip-12-投资你自己的工作流)
- [Tip 13: 搜索你的对话历史](#tip-13-搜索你的对话历史)
- [Tip 14: 用终端标签页实现多任务](#tip-14-用终端标签页实现多任务)
- [Tip 15: 精简系统提示](#tip-15-精简系统提示)
- [Tip 16: 用 Git worktree 并行处理多个分支](#tip-16-用-git-worktree-并行处理多个分支)
- [Tip 17: 为长时间运行的任务手动做指数退避](#tip-17-为长时间运行的任务手动做指数退避)
- [Tip 18: 把 Claude Code 当写作助手](#tip-18-把-claude-code-当写作助手)
- [Tip 19: Markdown 真的很好用](#tip-19-markdown-真的很好用)
- [Tip 20: 用 Notion 在粘贴时保留链接](#tip-20-用-notion-在粘贴时保留链接)
- [Tip 21: 用容器处理长时间运行的高风险任务](#tip-21-用容器处理长时间运行的高风险任务)
- [Tip 22: 提升 Claude Code 使用水平的最好方式就是用它](#tip-22-提升-claude-code-使用水平的最好方式就是用它)
- [Tip 23: 克隆/分叉对话，以及半克隆对话](#tip-23-克隆分叉对话以及半克隆对话)
- [Tip 24: 用 realpath 获取绝对路径](#tip-24-用-realpath-获取绝对路径)
- [Tip 25: 理解 CLAUDE.md、Skills、Slash Commands 和 Plugins 的区别](#tip-25-理解-claudemdskillsslash-commands-和-plugins-的区别)
- [Tip 26: 交互式 PR 审查](#tip-26-交互式-pr-审查)
- [Tip 27: 把 Claude Code 当研究工具](#tip-27-把-claude-code-当研究工具)
- [Tip 28: 掌握多种验证输出结果的方式](#tip-28-掌握多种验证输出结果的方式)
- [Tip 29: 把 Claude Code 当 DevOps 工程师](#tip-29-把-claude-code-当-devops-工程师)
- [Tip 30: 保持 CLAUDE.md 简洁，并定期回顾](#tip-30-保持-claudemd-简洁并定期回顾)
- [Tip 31: Claude Code 作为通用界面](#tip-31-claude-code-作为通用界面)
- [Tip 32: 关键在于选择正确的抽象层级](#tip-32-关键在于选择正确的抽象层级)
- [Tip 33: 审查你已批准的命令](#tip-33-审查你已批准的命令)
- [Tip 34: 多写测试（并使用 TDD）](#tip-34-多写测试并使用-tdd)
- [Tip 35: 在未知领域更勇敢一些；迭代式问题解决](#tip-35-在未知领域更勇敢一些迭代式问题解决)
- [Tip 36: 在后台运行 bash 命令和子 agent](#tip-36-在后台运行-bash-命令和子-agent)
- [Tip 37: 个性化软件的时代已经到来](#tip-37-个性化软件的时代已经到来)
- [Tip 38: 在输入框中导航和编辑](#tip-38-在输入框中导航和编辑)
- [Tip 39: 花时间规划，同时也要快速原型](#tip-39-花时间规划同时也要快速原型)
- [Tip 40: 简化过于复杂的代码](#tip-40-简化过于复杂的代码)
- [Tip 41: 自动化的自动化](#tip-41-自动化的自动化)
- [Tip 42: 分享你的知识，力所能及地贡献](#tip-42-分享你的知识力所能及地贡献)
- [Tip 43: 保持学习！](#tip-43-保持学习)
- [Tip 44: 安装 dx 插件](#tip-44-安装-dx-插件)
- [Tip 45: 快速安装脚本](#tip-45-快速安装脚本)

<!-- /TOC -->

## Tip 0: 自定义你的状态栏

你可以自定义 Claude Code 底部的状态栏，让它显示有用的信息。我的状态栏设置为显示：当前模型、当前目录、Git 分支（如果有的话）、未提交文件数量、与远程的同步状态，以及一个可视化的 token 使用进度条。同时还会显示第二行，内容是我的最后一条消息，这样我就能知道这个对话在聊什么：

```
Opus 4.5 | 📁claude-code-tips | 🔀main (scripts/context-bar.sh uncommitted, synced 12m ago) | ██░░░░░░░░ 18% of 200k tokens
💬 This is good. I don't think we need to change the documentation as long as we don't say that the default color is orange el...
```

这对于关注上下文用量、以及回忆自己在做什么非常有帮助。这个脚本还支持 10 种颜色主题（橙色、蓝色、青色、绿色、薰衣草、玫瑰、金色、石板、青绿、灰色）。

![颜色预览选项](scripts/color-preview.png)

要完成这个设置，可以使用[这个示例脚本](scripts/context-bar.sh)，并参考[设置说明](scripts/README.md)。

## Tip 1: 学会几个必备的斜杠命令

Claude Code 内置了很多斜杠命令（输入 `/` 即可查看所有命令）。以下几个值得特别了解：

### /usage

查看你的速率限制：

```
 Current session
 █████████▌                                         19% used
 Resets 12:59am (America/Vancouver)

 Current week (all models)
 █████████████████████▌                             43% used
 Resets Feb 3 at 1:59pm (America/Vancouver)

 Current week (Sonnet only)
 ███████████████████▌                               39% used
 Resets 8:59am (America/Vancouver)
```

如果你想密切关注用量，可以在标签页中保持打开，并通过 Tab 再按 Shift+Tab，或者 ← 再按 → 来刷新。

### /chrome

切换 Claude 的原生浏览器集成：

```
> /chrome
Chrome integration enabled
```

### /mcp

管理 MCP（模型上下文协议）服务器：

```
 Manage MCP servers
 1 server

 ❯ 1. playwright  ✔ connected · Enter to view details

 MCP Config locations (by scope):
  • User config (available in all your projects):
    • /Users/yk/.claude.json
```

### /stats

以 GitHub 风格的活动图查看你的使用统计：

```
      Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec Jan
      ··········································▒█░▓░█░▓▒▒
  Mon ·········································▒▒██▓░█▓█░█
      ·········································░▒█▒▓░█▒█▒█
  Wed ········································░▓▒█▓▓░▒▓▒██
      ········································░▓░█▓▓▓▓█░▒█
  Fri ········································▒░░▓▒▒█▓▓▓█
      ········································▒▒░▓░░▓▒▒░░

      Less ░ ▒ ▓ █ More

  Favorite model: Opus 4.5        Total tokens: 17.6m

  Sessions: 4.1k                  Longest session: 20h 40m 45s
  Active days: 79/80              Longest streak: 75 days
  Most active day: Jan 26         Current streak: 74 days

  You've used ~24x more tokens than War and Peace
```

### /clear

清除对话，重新开始。

## Tip 2: 用语音与 Claude Code 对话

我发现用语音交流比手动打字要快得多。在本地机器上安装一个语音转文字系统对此很有帮助。

在我的 Mac 上，我试过几种不同的方案：
- [superwhisper](https://superwhisper.com/)
- [MacWhisper](https://goodsnooze.gumroad.com/l/macwhisper)
- [Super Voice Assistant](https://github.com/ykdojo/super-voice-assistant)（开源，支持 Parakeet v2/v3）

使用托管服务可以获得更高的准确率，但我发现本地模型对于这个用途来说已经足够好了。即使转写中出现错误或错别字，Claude 也足够聪明，能够理解你想表达的意思。有时你需要把某些词说得格外清晰，但总体而言，本地模型的效果完全够用。

比如在这张截图中，你可以看到 Claude 能够正确解读转写出错的词，比如把 "ExcelElanishMark" 和 "advast" 正确理解为 "exclamation mark" 和 "Advanced"：

![语音转写错误被正确解读](assets/voice-transcription-mistakes.png)

我觉得最好的理解方式是：这就像和朋友交流一样。当然，你可以通过发短信来沟通，对某些人来说那样可能更方便，或者用邮件，都完全没问题，大多数人用 Claude Code 也是这样做的。但如果你想沟通更快，为什么不打个快速电话呢？你可以发语音消息，不需要真的和 Claude Code "打电话"。就是发一堆语音消息，至少对我来说更快——因为我这些年练出了一定的口语表达能力。但我认为对大多数人来说也会更快。

一个常见的反对意见是"如果你在一个有其他人的房间怎么办？"我只是戴着耳机低声说话——我个人喜欢用 Apple EarPods（不是 AirPods）。它们价格实惠，音质够好，你只需要对着麦克风轻声说话就行。我在别人面前这样做过，效果很好。在办公室里，人们本来就会说话——与其和同事说话，不如你悄悄地跟你的语音转文字系统说话。我觉得这完全没有问题。这个方法甚至在飞机上也能用。飞机上够吵，其他人听不到你说话，但只要你说话时靠近麦克风，本地模型还是能听清楚你在说什么。（事实上，我就是在飞行途中用这个方法写下了这段文字。）

**更新：** Claude Code 现在有了[内置语音模式](https://x.com/bcherny/status/2032238378389840018)。我测试过，效果不错，但我个人仍在使用本地模型，因为我觉得更快。

## Tip 3: 把大问题拆成小问题

这是最重要的概念之一。它和传统软件工程完全一样——最优秀的软件工程师早就知道怎么做了，这同样适用于 Claude Code。

如果你发现 Claude Code 无法一次性解决一个复杂的问题或编程任务，就让它把问题拆解成多个更小的子问题。看看它能不能解决其中一个独立的部分。如果还是太难，看看它能不能解决一个更小的子问题。继续细化，直到每个部分都能解决。

本质上，与其从 A 直接到 B：

![直接方式](assets/breakdown-direct.png)

不如从 A 到 A1，再到 A2，再到 A3，最后到 B：

![逐步方式](assets/breakdown-steps.png)

一个很好的例子是我在构建自己的语音转文字系统时的经历。我需要构建一个系统，让用户能够选择并下载模型、响应键盘快捷键、开始转写、将转写的文字放到用户光标位置，并用一个漂亮的 UI 包装这一切。内容太多了。所以我把它拆成了更小的任务：首先，我创建了一个只下载模型、什么都不做的可执行文件；然后创建了一个只录制声音的；再创建一个只转写预录音频的。我就这样逐一完成，最后再把它们合并。

这和另一点高度相关：在 AI 代理编程和 Claude Code 的世界里，你的问题解决能力和软件工程技能依然非常重要。Claude Code 能独立解决很多问题，但当你把自己的通用问题解决技能和软件工程技能结合进来时，它会变得强大得多。

## Tip 4: 像高手一样使用 Git 和 GitHub CLI

直接让 Claude 处理你的 Git 和 GitHub CLI 任务就行。这包括提交（这样你就不用手动写提交信息了）、创建分支、拉取和推送。

我个人允许自动拉取，但不允许自动推送，因为推送风险更高——如果出了什么问题，拉取不会污染远程仓库。

对于 GitHub CLI（`gh`），能做的事情很多。我在使用 Claude Code 之后开始更多地创建草稿 PR。这让 Claude Code 可以低风险地处理 PR 的创建流程——你可以在把它标记为准备好评审之前先自己审查一下。

事实证明，`gh` 相当强大。你甚至可以通过它发送任意 GraphQL 查询。比如，你甚至可以找出 GitHub PR 描述的精确编辑时间：

```
⏺ Bash(gh api graphql -f query='
      query {
        repository(owner: "...", name: "...") {
          pullRequest(number: ...) {
            userContentEdits(first: 100) {
              nodes { editedAt editor { login } }
            }
          }
        }
      }')

⏺ Here's the full edit history for your PR description:

  | #  | Edited At (UTC)     | Editor |
  |----|---------------------|--------|
  | 1  | 2025-12-01 00:08:34 | ykdojo |
  | 2  | 2025-12-01 15:57:21 | ykdojo |
  | 3  | 2025-12-01 16:24:33 | ykdojo |
  | 4  | 2025-12-01 16:27:00 | ykdojo |
  | 5  | 2025-12-04 00:40:02 | ykdojo |
  ...
```

### 关闭提交/PR 署名

默认情况下，Claude Code 会在提交中添加 `Co-Authored-By` 尾注，并在 PR 中添加署名页脚。你可以在 `~/.claude/settings.json` 中添加以下内容来禁用两者：

```json
{
  "attribution": {
    "commit": "",
    "pr": ""
  }
}
```

将两者都设置为空字符串即可完全移除署名。这取代了旧版的 `includeCoAuthoredBy` 设置，该设置现已废弃。

## Tip 5: AI 上下文就像牛奶——越新鲜越浓缩越好！

当你开始一个新的 Claude Code 对话时，它的表现最好，因为不需要处理之前对话遗留的大量上下文。但随着对话越来越长，上下文也会越来越长，性能往往会下降。

所以最好对每个新话题都开启一个新对话，或者在性能开始下降时也这样做。

## Tip 6: 把内容从终端里取出来

有时候你想复制 Claude Code 的输出，但直接从终端复制并不总是干净整洁的。以下几种方式可以更轻松地提取内容：

- **`/copy` 命令**：最简单的选项——只需输入 `/copy`，即可将 Claude 的最后一条回复以 markdown 格式复制到剪贴板
- **直接复制到剪贴板**：在 Mac 或 Linux 上，可以让 Claude 使用 `pbcopy` 将输出直接发送到剪贴板
- **写入文件**：让 Claude 把内容放入一个文件，然后让它在 VS Code（或你喜欢的编辑器）中打开，这样你就可以从那里复制。你也可以指定行号，让 Claude 打开到它刚编辑的具体那行。对于 markdown 文件，在 VS Code 中打开后，可以用 Cmd+Shift+P（Linux/Windows 上是 Ctrl+Shift+P）并选择"Markdown: Open Preview"来查看渲染效果
- **打开 URL**：如果有个 URL 你想自己查看，让 Claude 在浏览器中打开它。在 Mac 上，可以让它使用 `open` 命令，但通常让它在你喜欢的浏览器中打开在任何平台上都应该有效
- **GitHub Desktop**：你可以让 Claude 在 GitHub Desktop 中打开当前仓库。这在它处于非根目录时特别有用——例如，如果你让它在不同目录中创建了一个 git worktree，但你还没有从那里打开 Claude Code

你也可以把这些方法组合使用。比如，如果你想编辑 GitHub PR 描述，与其让 Claude 直接编辑（可能会弄乱），不如先让它把内容复制到本地文件，让它在那里编辑，你自己检查结果，确认没问题后，再让它复制粘贴回 GitHub PR。这种方式效果非常好。或者如果你想自己手动操作，可以让它在 VS Code 中打开，或者通过 pbcopy 给你，然后手动粘贴。

当然，你可以自己运行这些命令，但如果你发现自己反复在做同样的事，让 Claude 帮你运行会更方便。

## Tip 7: 设置终端别名以快速启动

因为用了 Claude Code，我更频繁地使用终端了，所以我发现设置短别名来快速启动各种工具很有帮助。以下是我使用的别名：

- `c` 对应 Claude Code（这是我用得最多的）
- `ch` 对应带 Chrome 集成的 Claude Code
- `gb` 对应 GitHub Desktop
- `co` 对应 VS Code
- `q` 对应跳转到我存放大多数项目的项目目录。从那里我可以手动 cd 进入某个文件夹来处理那个项目，或者直接用 `c` 启动 Claude Code，让它基本上能访问任何需要访问的项目

要设置这些别名，在你的 shell 配置文件（`~/.zshrc` 或 `~/.bashrc`）中添加如下内容：

```bash
alias c='claude'
alias ch='claude --chrome'
alias gb='github'
alias co='code'
alias q='cd ~/Desktop/projects'
```

有了这些别名之后，你可以把它们和参数组合使用：`c -c` 继续上一次对话，`c -r` 显示最近对话列表以便恢复。这些也适用于 `ch`（`ch -c`、`ch -r`）用于 Chrome 会话。

## Tip 8: 主动压缩你的上下文

Claude Code 有一个 `/compact` 命令，可以对你的对话进行总结以释放上下文空间。当可用上下文全部填满时，也会自动发生压缩。Opus 4.5 的总可用上下文窗口目前是 200k，其中 45k 留给自动压缩使用。大约 10% 的总 200k 会被系统提示、工具、记忆和动态上下文自动占用。但我发现主动手动调整效果更好。我通过 `/config` 关闭了自动压缩，这样主对话可以有更多上下文空间，也能更好地控制何时以及如何进行压缩。

我的做法是在开始新对话之前，先让 Claude 写一份交接文档。类似这样：

> Put the rest of the plan in the system-prompt-extraction folder as HANDOFF.md. Explain what you have tried, what worked, what didn't work, so that the next agent with fresh context is able to just load that file and nothing else to get started on this task and finish it up.

Claude 会创建一个总结当前工作状态的文件：

```
⏺ Write(experiments/system-prompt-extraction/HANDOFF.md)
  ⎿  Wrote 129 lines to experiments/system-prompt-extraction/HANDOFF.md
     # System Prompt Slimming - Handoff Document
     ## Goal
     Reduce Claude Code's system prompt by ~45% (currently at 11%, need ~34% more).
     ## Current Progress
     ### What's Been Done
     - **Backup/restore system**: `backup-cli.sh` and `restore-cli.sh` with SHA256 verification
     - **Patch system**: `patch-cli.js` that restores from backup then applies patches
     ...
```

Claude 写好之后，快速检查一下。如果有什么遗漏，可以要求修改：

> Did you add a note about iteratively testing instead of trying to do everything all at once?

然后开启一个新对话。对于新的 agent，你只需要给它文件路径就行，什么都不用多说，它应该能顺利接手：

```
> experiments/system-prompt-extraction/HANDOFF.md
```

在后续对话中，你可以让 agent 为下一个 agent 更新这份文档。

我还创建了一个 `/handoff` 斜杠命令来自动化这个过程——它会检查是否存在 HANDOFF.md，如果有就读取，然后创建或更新，内容包括目标、进度、哪些有效、哪些无效，以及下一步。你可以在 [skills 文件夹](skills/handoff/SKILL.md)中找到它，或者通过 [dx 插件](#tip-44-安装-dx-插件)安装。

**替代方案：使用计划模式**

另一种选择是使用计划模式。通过 `/plan` 或 Shift+Tab 进入。让 Claude 收集所有相关上下文，并为下一个 agent 制定一个全面的计划：

> I just enabled plan mode. Bring over all of the context that you need for the next agent. The next agent will not have any other context, so you'll need to be pretty comprehensive.

Claude 会探索代码库、收集上下文并编写详细计划。完成后，你会看到如下选项：

```
Would you like to proceed?

❯ 1. Yes, clear context and auto-accept edits (shift+tab)
  2. Yes, auto-accept edits
  3. Yes, manually approve edits
  4. Type here to tell Claude what to change
```

选项 1 会清除之前的上下文，并以这份计划重新开始。新的 Claude 实例只看到这份计划，可以专注工作而不受旧对话的干扰。同时它也会获得旧对话记录文件的链接，以备需要查找具体细节时使用。

## Tip 9: 为自主任务完成"写-测"循环

如果你想让 Claude Code 自主运行某些任务，比如 `git bisect`，你需要给它一种验证结果的方式。关键在于完成写-测循环：写代码、运行它、检查输出、再重复。

举个例子，假设你正在处理 Claude Code 本身，发现 `/compact` 停止工作并开始抛出 400 错误。找出是哪个提交导致这个问题的经典工具是 `git bisect`。好消息是你可以让 Claude Code 对自身运行 bisect，但它需要一种方式来测试每个提交。

对于涉及交互式终端（如 Claude Code）的任务，你可以使用 tmux。模式是：

1. 启动一个 tmux 会话
2. 向它发送命令
3. 捕获输出
4. 验证是否符合预期

这是一个测试 `/context` 是否正常工作的简单示例：

```bash
tmux kill-session -t test-session 2>/dev/null
tmux new-session -d -s test-session
tmux send-keys -t test-session 'claude' Enter
sleep 2
tmux send-keys -t test-session '/context' Enter
sleep 1
tmux capture-pane -t test-session -p
```

有了这样的测试，Claude Code 就可以运行 `git bisect` 并自动测试每个提交，直到找到出问题的那个。

这也说明了为什么你的软件工程技能仍然重要。如果你是软件工程师，你可能知道 `git bisect` 这样的工具。这些知识在 AI 时代依然非常有价值——只是以新的方式运用。

另一个例子就是单纯地写测试。在让 Claude Code 写完一些代码后，如果你想测试它，也可以让它为自己写测试，然后让它自行运行并修复问题。当然，它并不总是走在正确方向上，有时你需要监督，但它确实能自主完成相当数量的编程任务。

### 创意测试策略

有时你需要在完成写-测循环时发挥创意。比如，如果你在构建一个 web 应用，你可以使用 Playwright MCP、Chrome DevTools MCP，或者 Claude 的原生浏览器集成（通过 `/chrome`）。我还没试过 Chrome DevTools，但 Playwright 和 Claude 的原生集成我都试过了。总体来说，Playwright 通常效果更好。它确实消耗大量上下文，但 200k 的上下文窗口对于单个任务或几个小任务来说通常够用。

这两者的主要区别似乎在于：Playwright 专注于可访问性树（关于页面元素的结构化数据），而不是截图。虽然它有截图能力，但通常不用截图来执行操作。而 Claude 的原生浏览器集成更侧重于截图，并通过特定坐标来点击元素。它有时会随机点击，整个过程也可能很慢。

这可能会随时间改善，但默认情况下我会对大多数非视觉密集型任务使用 Playwright。只有当我需要使用登录状态而不提供凭据时（因为它在你自己的浏览器配置文件中运行），或者当它特别需要通过视觉坐标点击某些元素时，我才会使用 Claude 的原生浏览器集成。

这就是为什么我默认禁用 Claude 的原生浏览器集成，只通过之前定义的 `ch` 快捷方式使用它。这样 Playwright 处理大多数浏览器任务，只有在我特别需要时才启用 Claude 的原生集成。

另外，你可以让它使用可访问性树引用而不是坐标。这是我在 CLAUDE.md 中为此添加的内容：

```markdown
# Claude for Chrome

- Use `read_page` to get element refs from the accessibility tree
- Use `find` to locate elements by description
- Click/interact using `ref`, not coordinates
- NEVER take screenshots unless explicitly requested by the user
```

根据我的亲身经历，我曾有一次在处理一个 Python 库（[Daft](https://github.com/Eventual-Inc/Daft)）时，需要在 Google Colab 上测试我本地构建的版本。问题是在 Google Colab 上构建带有 Rust 后端的 Python 库很困难——似乎效果不太好。所以我需要在本地实际构建一个 wheel，然后手动上传，这样才能在 Google Colab 上运行。我也尝试过猴子补丁（monkey patching），在短期内有效，直到我必须等待整个 wheel 在本地构建完成。我就是这样与 Claude Code 来回协作，想出并执行这些测试策略的。

还有一个情况是我需要在 Windows 上测试，但我用的不是 Windows 机器。同一个仓库的 CI 测试失败了，因为我们在 Windows 上的 Rust 存在一些问题，而我没有办法在本地测试。所以我需要创建一个包含所有更改的草稿 PR，以及另一个包含相同更改、同时在非 main 分支上启用 Windows CI 运行的草稿 PR。我让 Claude Code 完成了所有这些工作，然后我直接在那个新分支中测试 CI。

## Tip 10: Cmd+A 和 Ctrl+A 是你的好朋友

这个观点我已经说了好几年了：在 AI 的世界里，Cmd+A 和 Ctrl+A 是你的好朋友。这同样适用于 Claude Code。

有时候你想给 Claude Code 提供一个 URL，但它无法直接访问。可能是一个私有页面（不是敏感数据，只是不公开），或者像 Reddit 帖子这样 Claude Code 难以抓取的内容。在这些情况下，你可以直接全选你看到的所有内容（Mac 上是 Cmd+A，其他平台是 Ctrl+A），复制，然后直接粘贴到 Claude Code 中。这是个相当强大的方法。

对于终端输出也非常有效。当我有来自 Claude Code 本身或任何其他 CLI 应用的输出时，我可以用同样的技巧：全选、复制、粘贴回 CC。很好用。

有些页面默认情况下不适合全选——但有一些技巧可以先让它们进入更好的状态。比如对于 Gmail 线程，点击"打印全部"进入打印预览（但取消实际打印）。那个页面会展开显示线程中的所有邮件，这样你就可以用 Cmd+A 干净地选择整个对话。

这适用于任何 AI，不仅仅是 Claude Code。

## Tip 11: 用 Gemini CLI 作为被屏蔽网站的备用方案

Claude Code 的 WebFetch 工具无法访问某些网站，比如 Reddit。但你可以通过创建一个 skill 来绕过这个问题——告诉 Claude 使用 Gemini CLI 作为备用方案。Gemini 有网络访问权限，可以获取 Claude 无法直接访问的网站内容。

这使用了 Tip 9 中的同一个 tmux 模式——启动一个会话，发送命令，捕获输出。skill 文件放在 `~/.claude/skills/reddit-fetch/SKILL.md`。完整内容见 [skills/reddit-fetch/SKILL.md](skills/reddit-fetch/SKILL.md)。

Skills 更节省 token，因为 Claude Code 只在需要时才加载它们。如果你想要更简单的方案，可以把精简版本放进 `~/.claude/CLAUDE.md`，但那样每次对话都会加载，不管你用不用得到。

我测试了这个功能，让 Claude Code 去查一下 Reddit 上对 Claude Code skills 的看法——有点元。它和 Gemini 来回交互了好一会儿，所以速度不快，但报告质量出乎意料地好。当然，要用这个功能，你需要先安装 Gemini CLI。你也可以通过 [dx 插件](#tip-44-安装-dx-插件)来安装这个 skill。

## Tip 12: 投资你自己的工作流

就我个人而言，我用 Swift 从头开始创建了自己的语音转文字应用；用 Claude Code 从头开始创建了自定义状态栏，这个用的是 bash；还创建了自己的系统，用于简化 Claude Code 压缩后的 JavaScript 文件中的系统提示。

但你不必像我这样搞那么复杂。只需要维护好你自己的 CLAUDE.md，确保它尽可能简洁，同时又能帮你实现目标——这类事情就很有用了。当然，学习这些技巧、学习这些工具和一些最重要的功能也是一样重要的。

所有这些都是对你用来构建任何你想构建的东西的工具的投资。我认为花一点时间在这上面是很重要的。

## Tip 13: 搜索你的对话历史

你可以让 Claude Code 查找你的历史对话，它会帮你找到并搜索。你的对话历史本地存储在 `~/.claude/projects/`，文件夹名基于项目路径（斜杠变成破折号）。

例如，位于 `/Users/yk/Desktop/projects/claude-code-tips` 的项目的对话会存储在：

```
~/.claude/projects/-Users-yk-Desktop-projects-claude-code-tips/
```

每个对话是一个 `.jsonl` 文件。你可以用基本的 bash 命令搜索：

```bash
# Find all conversations mentioning "Reddit"
grep -l -i "reddit" ~/.claude/projects/-Users-yk-Desktop-projects-*/*.jsonl

# Find today's conversations about a topic
find ~/.claude/projects/-Users-yk-Desktop-projects-*/*.jsonl -mtime 0 -exec grep -l -i "keyword" {} \;

# Extract just the user messages from a conversation (requires jq)
cat ~/.claude/projects/.../conversation-id.jsonl | jq -r 'select(.type=="user") | .message.content'
```

或者直接问 Claude Code："我们今天谈过关于 X 的什么？"它会帮你搜索历史记录。

## Tip 14: 用终端标签页实现多任务

同时运行多个 Claude Code 实例时，保持有序比任何具体的技术设置（比如 Git worktree）都更重要。我建议最多同时专注于三到四个任务。

我个人的方法是我称之为"瀑布"的模式——每次开始一个新任务，就在右边打开一个新标签页。然后从左到右、从左到右地扫描，从最老的任务到最新的。总体方向保持一致，除非需要检查某些任务、收到通知等。

以下是我的设置通常的样子：

![显示多任务工作流的终端标签页](assets/multitasking-terminal-tabs.png)

在这个例子中：
1. **最左边的标签** - 运行我语音转文字系统的持久标签（一直在这里）
2. **第二个标签** - 设置 Docker 容器
3. **第三个标签** - 检查本地机器的磁盘使用情况
4. **第四个标签** - 处理一个工程项目
5. **第五个标签（当前）** - 正在写这条技巧

## Tip 15: 精简系统提示

Claude Code 的系统提示和工具定义在你开始工作之前就已经占用了大约 19k token（约占 200k 上下文的 10%）。我创建了一个补丁系统，可以将其减少到约 9k token——节省了大约 10,000 token（约 50% 的开销）。

| 组件 | 之前 | 之后 | 节省 |
|------|------|------|------|
| 系统提示 | 3.0k | 1.8k | 1,200 tokens |
| 系统工具 | 15.6k | 7.4k | 8,200 tokens |
| **总计** | **~19k** | **~9k** | **~10k tokens (~50%)** |

以下是打补丁前后 `/context` 的对比：

**未打补丁（~20k，10%）**

![未打补丁的上下文](assets/context-unpatched.png)

**已打补丁（~10k，5%）**

![已打补丁的上下文](assets/context-patched.png)

这些补丁通过裁剪压缩后的 CLI 包中冗长的示例和重复文本来实现，同时保留所有必要的指令。

我对此进行了大量测试，效果很好。感觉更原始——更强大，但可能少了一些"管制感"，这也说得通，因为系统指令更短了。用这种方式感觉更像是一个专业工具。我真的很享受从更低的上下文开始工作，因为你有更多空间，可以把对话继续得更久一些。这绝对是这个策略最好的一点。

查看 [system-prompt 文件夹](system-prompt/)了解补丁脚本以及被裁剪内容的完整详情。

**为什么是打补丁？** Claude Code 有参数可以让你从文件提供简化的系统提示（`--system-prompt` 或 `--system-prompt-file`），所以那也是一种方法。但对于工具描述，没有官方选项可以自定义。打补丁修改 CLI 包是唯一的方式。由于我的补丁系统以统一的方式处理所有内容，我目前维持这种方式。将来我可能会用参数重新实现系统提示部分。

**支持的安装方式：** npm 和原生二进制文件（macOS 和 Linux）。

**重要提示**：如果你想保留你的补丁系统提示，请通过在 `~/.claude/settings.json` 中添加以下内容来禁用自动更新：

```json
{
  "env": {
    "DISABLE_AUTOUPDATER": "1"
  }
}
```

这适用于所有 Claude Code 会话，无论 shell 类型如何（交互式、非交互式、tmux）。当你准备好之后，可以手动更新并对新版本重新应用补丁。

### 懒加载 MCP 工具

如果你使用 MCP 服务器，默认情况下它们的工具定义会在每次对话中加载——即使你不用它们。这可能会带来相当大的开销，尤其是配置了多个服务器时。

启用懒加载，让 MCP 工具只在需要时才加载：

```json
{
  "env": {
    "ENABLE_TOOL_SEARCH": "true"
  }
}
```

将此添加到 `~/.claude/settings.json`。Claude 会按需搜索并加载 MCP 工具，而不是从一开始就全部加载。从 2.1.7 版本开始，当 MCP 工具描述超过上下文窗口的 10% 时，这会自动发生。

## Tip 16: 用 Git worktree 并行处理多个分支

如果你同时在同一个项目里处理多件事，又不想让它们互相干扰，Git worktree 是个很好的办法。你直接让 Claude Code 创建一个 git worktree 然后在里面开始工作就好了——不需要记住具体的语法。

基本思路是：你可以在不同的目录里处理不同的分支。本质上就是一个分支配一个目录。

你可以把 Git worktree 叠加在我在多任务技巧里介绍过的级联方法上一起用。

### Git worktree 是什么？

Git worktree 和普通的 git 分支一样，只是专门给它分配了一个新目录。

比如说，你同时在 main 分支和 feature-branch-1 上工作。没有 git worktree 的话，你一次只能处理其中一个，因为你的项目文件夹一次只能对应一个分支。

但有了 git worktree，你可以继续在原来的项目文件夹里处理 main 分支（或者其他任意分支），同时在一个新文件夹里处理 feature-branch-1。

![Git worktrees diagram showing parallel branch work in separate directories](assets/git-worktrees.png)

## Tip 17: 为长时间运行的任务手动做指数退避

等待 Docker 构建或 GitHub CI 这类耗时任务时，你可以让 Claude Code 手动做指数退避。指数退避在软件工程里是个常见技术，在这里同样适用。让 Claude Code 以递增的时间间隔检查状态——先等一分钟，再等两分钟，然后四分钟，依此类推。这不是传统意义上的程序化实现，而是由 AI 手动操作——但效果相当不错。

这样一来，Agent 就能持续检查状态，完成后及时通知你。

（对于 GitHub CI，虽然有 `gh run watch` 命令，但它会持续输出大量内容，白白浪费 token。用 `gh run view <run-id> | grep <job-name>` 配合手动指数退避实际上更节省 token。这也是一个通用技巧，即使没有专门的等待命令，它也能很好地派上用场。）

比如，如果你有一个 Docker 构建在后台运行：

![Manual exponential backoff checking Docker build progress](assets/manual-exponential-backoff.png)

它会一直持续检查，直到任务完成。

## Tip 18: 把 Claude Code 当写作助手

Claude Code 是一个出色的写作助手和搭档。我用它写作的方式是：先给它所有需要的背景信息，然后用语音给它详细的指示。这样我就能得到第一稿。如果不够好，我会再试几次。

然后我基本上逐行过一遍。我会说，好，我们一起来看看。这句话我喜欢，原因是这样。我觉得这句话需要挪到那里。这句话需要以某种方式改一改。我也可能会问到一些参考资料。

就是这样一种来回打磨的过程，可能是终端在左边，代码编辑器在右边：

![Side-by-side writing workflow with Claude Code](assets/writing-assistant-side-by-side.png)

这种方式效果非常好。

## Tip 19: Markdown 真的很好用

通常人们写新文档时，可能会用 Google Docs 或者 Notion 之类的工具。但现在我真心觉得最高效的方式是 markdown。

Markdown 在 AI 出现之前就已经挺好用的了，但配合 Claude Code，因为它在写作上的高效性（就像我之前提到的），让 markdown 的价值在我看来更上一层楼。无论你想写博客文章还是 LinkedIn 帖子，你都可以直接跟 Claude Code 说，让它保存成 markdown，然后从那里继续。

一个小技巧：如果你想把 markdown 内容粘贴到一个不能直接接受它的平台，可以先粘贴到一个空白的 Notion 文件里，再从 Notion 复制到目标平台。Notion 会把它转换成其他平台能接受的格式。如果普通粘贴不行，可以试试 Command + Shift + V 来无格式粘贴。

## Tip 20: 用 Notion 在粘贴时保留链接

反过来也一样有用。如果你有带链接的文字，比如从 Slack 复制的内容，直接粘贴到 Claude Code 里是看不到链接的。但如果先放进一个 Notion 文档，再从 Notion 复制，就能得到 markdown 格式——而 Claude Code 当然能读懂 markdown。

## Tip 21: 用容器处理长时间运行的高风险任务

普通会话更适合有条不紊的工作，你控制权限、仔细审查每一步输出。容器化环境则非常适合开启 `--dangerously-skip-permissions` 的会话，不需要对每个小操作逐一授权，可以让它自己跑一段时间。

这对于研究或实验类任务很有用——那些耗时很长、可能有一定风险的事情。一个典型例子是 Tip 11 里的 Reddit 研究工作流，其中 reddit-fetch skill 通过 tmux 与 Gemini CLI 来回交互。在你的主系统上无监督地运行这个流程是有风险的，但在容器里，就算出了什么问题也是隔离的。

另一个例子是我在这个仓库里创建[系统提示词补丁脚本](system-prompt/)的过程。每当 Claude Code 有新版本发布，我就需要更新针对压缩后的 CLI 包的补丁。与其在宿主机上用 `--dangerously-skip-permissions` 运行 Claude Code（那样它能访问所有东西），我选择在容器里运行它。Claude Code 可以探索压缩后的 JavaScript，找到变量映射，并创建新的补丁文件，这样我就不需要对每一个小操作都点击批准了。

事实上，它几乎能独立完成整个迁移。它尝试应用补丁，发现有些补丁在新版本上不起作用，然后迭代修复，甚至根据自己学到的东西改进了[升级说明文档](system-prompt/UPGRADING.md)，方便未来的实例参考。

我甚至创建了 [SafeClaw](https://github.com/ykdojo/safeclaw)，让运行容器化的 Claude Code 会话变得更简单。它让你能启动多个隔离的会话，每个都有一个 Web 终端，还能通过一个仪表盘统一管理。它用到了这个仓库里的几项定制内容，包括优化过的系统提示词、[DX 插件](#tip-44-install-the-dx-plugin)，以及[状态栏](#tip-0-customize-your-status-line)。

### 进阶：在容器里编排一个"工作 Claude Code"

你还可以更进一步：让本地的 Claude Code 控制另一个运行在容器里的 Claude Code 实例。关键是用 tmux 作为控制层：

1. 本地 Claude Code 启动一个 tmux 会话
2. 在这个 tmux 会话里，它运行或连接到容器
3. 容器内部，Claude Code 以 `--dangerously-skip-permissions` 模式运行
4. 外层 Claude Code 用 `tmux send-keys` 发送指令，用 `capture-pane` 读取输出

这样你就有了一个完全自主的"工作" Claude Code，可以运行实验性或长时间运行的任务，无需你批准每一个操作。完成后，本地 Claude Code 可以把结果拉回来。如果出了什么问题，一切都沙箱在容器里。

### 进阶：多模型编排

除了 Claude Code，你还可以在容器里运行不同的 AI CLI——Codex、Gemini CLI 或其他工具。我试过用 OpenAI Codex 做代码审查，效果不错。重点不在于你不能直接在宿主机上运行这些 CLI——当然可以。价值在于 Claude Code 的使用体验足够流畅，你只需跟它说话，让它来负责编排：启动不同的模型，在容器和宿主机之间传输数据。不用再手动切换终端和复制粘贴，Claude Code 成了协调一切的中央接口。

## Tip 22: 提升 Claude Code 使用水平的最好方式就是用它

最近我看到一位世界级攀岩运动员接受另一位攀岩运动员的采访。被问到"怎么提高攀岩水平？"她的回答很简单："靠攀岩。"

我对这个问题的感受也一样。当然，你可以做一些辅助性的事情，比如看视频、读书、了解各种技巧。但使用 Claude Code 是学习如何用好它的最佳方式。广泛地使用 AI，是学习如何使用 AI 的最佳方式。

我喜欢把它想成"十亿 token 法则"，而不是"一万小时法则"。如果你想用好 AI，真正对它的运作方式建立起直觉，最好的办法是消耗大量的 token。如今这完全可以做到。我发现，尤其是 Opus 4.5，它足够强大，价格也足够合理，你可以同时运行多个会话，不需要太担心 token 用量，这让你的发挥空间大了很多。

## Tip 23: 克隆/分叉对话，以及半克隆对话

有时候你想从某个节点尝试不同的思路，又不想失去原来的对话线索。[clone-conversation 脚本](scripts/clone-conversation.sh)可以用新的 UUID 复制一个对话，让你从那里分叉出去。

**内置替代方案（近期版本）：** Claude Code 现在已有原生分叉功能：
- `/fork` — 在对话中直接分叉当前会话
- `--fork-session` — 与 `--resume` 或 `--continue` 搭配使用（例如 `claude -c --fork-session`）

由于 `--fork-session` 没有简写形式，你可以把下面这个函数加到 `~/.zshrc` 或 `~/.bashrc`，用 `--fs` 作为快捷方式：

```bash
claude() {
  local args=()
  for arg in "$@"; do
    if [[ "$arg" == "--fs" ]]; then
      args+=("--fork-session")
    else
      args+=("$arg")
    fi
  done
  command claude "${args[@]}"
}
```

这个函数会拦截所有 `claude` 命令，把 `--fs` 展开为 `--fork-session`，其他参数原样传递。也适用于别名（参见 [Tip 7](#tip-7-set-up-terminal-aliases-for-quick-access)）：`c -c --fs`、`ch -c --fs` 等。

下面的克隆脚本早于这些内置选项，但再下面的半克隆脚本在压缩上下文方面仍然独具一格。

第一条消息会被标记为 `[CLONED <时间戳>]`（例如 `[CLONED Jan 7 14:30]`），在 `claude -r` 列表和对话内部都能看到。

手动设置方法，创建两个符号链接：
```bash
ln -s /path/to/this/repo/scripts/clone-conversation.sh ~/.claude/scripts/clone-conversation.sh
ln -s /path/to/this/repo/skills/clone ~/.claude/skills/clone
```

或者通过 [dx 插件](#tip-44-install-the-dx-plugin)安装——无需手动创建符号链接。

然后在任意对话中输入 `/clone`（使用插件则输入 `/dx:clone`），Claude 会自动找到会话 ID 并运行脚本。

我经过大量测试，克隆效果非常好。

### 半克隆以减少上下文

当对话变得太长时，[half-clone-conversation 脚本](scripts/half-clone-conversation.sh)只保留后半部分。这样可以减少 token 用量，同时保留你最近的工作内容。第一条消息会被标记为 `[HALF-CLONE <时间戳>]`（例如 `[HALF-CLONE Jan 7 14:30]`）。

手动设置方法，创建两个符号链接：
```bash
ln -s /path/to/this/repo/scripts/half-clone-conversation.sh ~/.claude/scripts/half-clone-conversation.sh
ln -s /path/to/this/repo/skills/half-clone ~/.claude/skills/half-clone
```

或者通过 [dx 插件](#tip-44-install-the-dx-plugin)安装——无需手动创建符号链接。

### 用 hook 自动触发半克隆

你还可以用一个 [hook](https://docs.anthropic.com/en/docs/claude-code/hooks) 在上下文过长时自动触发 `/half-clone`。[check-context 脚本](scripts/check-context.sh)在每次 Claude 响应后运行，检查上下文用量。如果超过 85%，它会告诉 Claude 运行 `/half-clone`，从而创建一个只保留后半部分的新对话，让新的 Agent 从那里继续。

设置方法，先复制脚本：
```bash
cp /path/to/this/repo/scripts/check-context.sh ~/.claude/scripts/check-context.sh
chmod +x ~/.claude/scripts/check-context.sh
```

然后把 hook 添加到 `~/.claude/settings.json`：
```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/scripts/check-context.sh"
          }
        ]
      }
    ]
  }
}
```

这需要禁用自动压缩功能（`/config` > Auto-compact > false），否则 Claude Code 可能在 hook 触发之前就已经压缩了上下文。触发时，hook 会阻止 Claude 停止并让它运行 `/half-clone`。与自动压缩相比，半克隆的优势在于它是确定性的、速度快——它保留你的原始消息，而不是对其进行摘要。

### 克隆脚本的推荐权限配置

两个克隆脚本都需要读取 `~/.claude`（对话文件和历史记录）。为了避免在任何项目中都弹出权限提示，可以将以下内容添加到全局设置（`~/.claude/settings.json`）：
```json
{
  "permissions": {
    "allow": ["Read(~/.claude)"]
  }
}
```

## Tip 24: 用 realpath 获取绝对路径

当你需要告诉 Claude Code 另一个文件夹里的文件时，用 `realpath` 来获取完整的绝对路径：

```bash
realpath some/relative/path
```

## Tip 25: 理解 CLAUDE.md、Skills、Slash Commands 和 Plugins 的区别

这几个功能有些相似，我最开始也觉得挺迷惑的。我一直在研究它们，尽力把它们梳理清楚，想把我学到的分享给大家。

**CLAUDE.md** 是最简单的一个。它是一批文件，会被当作默认提示词，在每次对话开始时自动加载进来。它的优点就是简单。你可以在特定项目里（`./CLAUDE.md`）或全局（`~/.claude/CLAUDE.md`）解释这个项目是干什么的。

**Skills** 就像是结构更好的 CLAUDE.md 文件。它们可以在相关时由 Claude 自动调用，也可以由用户用斜杠手动触发（例如 `/my-skill`）。比如，你可以有一个 skill，当你问某种语言的发音时，它会打开一个格式正确的 Google Translate 链接。如果这些指令在一个 skill 里，只有需要时才会加载。如果放在 CLAUDE.md 里，它们会一直占据空间。所以 skill 理论上更节省 token。

**Slash Commands** 与 skill 类似，也是一种单独打包指令的方式。它们可以由用户手动触发，也可以由 Claude 自己调用。如果你需要更精确地控制触发时机，按自己的节奏操作，slash command 就是合适的工具。

Skill 和 slash command 的功能非常相近。区别在于设计意图——skill 主要是为 Claude 设计的，slash command 主要是为用户设计的。不过它们最终已经[合并在一起](https://www.reddit.com/r/ClaudeAI/comments/1q92wwv/merged_commands_and_skills_in_213_update/)了，这也是我[曾经建议过的改动](https://github.com/anthropics/claude-code/issues/13115)。

**Plugins** 是将 skill、slash command、Agent、hook 和 MCP server 打包在一起的方式。但一个插件不必用上所有这些。Anthropic 官方的 `frontend-design` 插件本质上只是一个 skill，别的什么都没有。它本可以作为独立的 skill 发布，但插件格式让安装更方便。

比如，我构建了一个叫 `dx` 的插件，把这个仓库里的 slash command 和 skill 打包在一起。你可以在[安装 dx 插件](#tip-44-install-the-dx-plugin)部分看到它的工作方式。

## Tip 26: 交互式 PR 审查

Claude Code 非常适合做 PR 审查。流程很简单：让它用 `gh` 命令获取 PR 信息，然后你想怎么审查就怎么审查。

你可以做整体审查，或者逐文件、逐步骤地来。节奏由你控制，关注的细节程度由你决定，想处理的复杂度层级也由你说了算。也许你只是想了解整体结构，也许你还想让它跑一跑测试。

关键的区别在于：Claude Code 是一个交互式 PR 审查员，而不只是一次性输出结果的机器。有些 AI 工具擅长一次性审查（包括最新的 GPT 模型），但 Claude Code 让你能够进行真正的对话。

## Tip 27: 把 Claude Code 当研究工具

Claude Code 在各种研究任务上都表现出色。它本质上是 Google 或深度研究工具的替代品，但在某些方面更进一步。无论是研究某个 GitHub Actions 失败的原因（这是我最近经常做的事），还是对 Reddit 做情感分析或市场分析，或者探索你的代码库，又或者从公开信息里找到某样东西——它都能做到。

关键是给它正确的信息来源，以及告诉它如何获取这些信息。可能是 `gh` 终端命令，或者容器方案（Tip 21），或者通过 Gemini CLI 访问 Reddit（Tip 11），或者通过 Slack MCP 访问私人信息，或者用 Cmd+A / Ctrl+A 方法（Tip 10）——不管是什么。另外，如果 Claude Code 加载某些 URL 有困难，你可以试试 Playwright MCP 或 Claude 原生的浏览器集成（参见 Tip 9）。针对学术研究，我创建了一个 [paper-search](https://github.com/ykdojo/paper-search) 插件，用于搜索学术论文。

事实上，我甚至[靠 Claude Code 做研究省了 10,000 美元](content/how-i-saved-10k-with-claude-code.md)。

## Tip 28: 掌握多种验证输出结果的方式

如果输出的是代码，一种验证方式是让它写测试，确保测试整体上看起来没问题。这是一种方法，当然你也可以在 Claude Code 界面上随时查看它生成的代码。另外，你也可以用可视化 Git 客户端，比如 GitHub Desktop。我个人就在用。它不是完美的产品，但用来快速查看变更已经足够好了。还有一种方式就是我之前可能提到过的：让它生成一个 PR。让它创建一个草稿 PR，在变成正式 PR 之前检查内容。

另一个方法是让它自查，检查自己的输出。如果它给了你某种输出，比如某项研究的结果，你可以问它"你确定吗？能再检查一遍吗？"我最喜欢的一个提示词是："仔细检查你输出内容里的每一个说法，每一条，最后做一个表格，列出哪些是你能够验证的"——这个方法效果真的很好。

## Tip 29: 把 Claude Code 当 DevOps 工程师

我特意为这个单独写一个技巧，因为它对我来说真的很有用。每当 GitHub Actions CI 失败，我就把它交给 Claude Code，说"挖一下这个问题，找出根本原因。"有时它给的是表面层面的答案，但你只要持续追问——是特定的某次提交导致的吗，还是某个 PR，还是一个不稳定的问题？——它真的能帮你深挖这些手动很难查清楚的棘手问题。你得手动翻查一大堆日志，那样做非常痛苦，而 Claude Code 能处理其中的大量工作。

我把这个工作流打包成了一个 `/gha` slash command——只需运行 `/gha <url>`，传入任意 GitHub Actions URL，它就会自动调查失败原因，检查是否是不稳定问题，找出导致问题的提交，并提出修复建议。你可以在 [skills 文件夹](skills/gha/SKILL.md)里找到它，或者通过 [dx 插件](#tip-44-install-the-dx-plugin)安装。

一旦定位到具体问题，你就可以创建一个草稿 PR，按照我之前提到的那些技巧走一遍——检查输出，确保看起来没问题，让它验证自己的输出，然后把它变成正式 PR，真正修复这个问题。对我个人来说，这套流程效果非常好。

## Tip 30: 保持 CLAUDE.md 简洁，并定期回顾

保持 CLAUDE.md 简洁、尽量精炼，这一点很重要。你完全可以从没有 CLAUDE.md 开始。如果你发现自己反复告诉 Claude Code 同样的事情，那就把它加进 CLAUDE.md。我知道可以通过 `#` 符号来完成这个操作，但我更倾向于直接让 Claude Code 把它加到项目级或全局 CLAUDE.md 里，它会知道该编辑哪个文件。

![Keep it simple meme](assets/keep-it-simple-meme.jpg)

定期回顾你的 CLAUDE.md 文件也很重要，因为它们会随着时间推移变得过时。曾经合理的指令可能已经不再适用，或者你可能有了新的模式需要记录下来。我为此创建了一个 skill，叫做 [`review-claudemd`](skills/review-claudemd/SKILL.md)，它会分析你最近的对话，并为你的 CLAUDE.md 文件提出改进建议。

## Tip 31: Claude Code 作为通用界面

我以前觉得用 Claude Code 的话，CLI 就像新时代的 IDE——这个说法某种程度上还是成立的。我认为每次想快速修改代码之类的，它都是打开项目的绝佳入口。但具体取决于你项目的复杂程度，你可能需要比单纯"氛围编码"更仔细地审查输出结果。

但更普遍、更宏观地来看：Claude Code 其实是你与计算机、数字世界以及任何数字问题打交道的通用界面。很多时候，你完全可以让它自己想办法解决。比如，你要快速剪辑一段视频，直接让它去做——它大概会用 ffmpeg 或类似工具搞定。你想把一堆本地音频或视频文件转成文字，直接问它——它可能会建议用 Python 调用 Whisper。你想分析 CSV 文件里的数据，它可能会建议用 Python 或 JavaScript 做可视化。当然，再加上网络访问——Reddit、GitHub、MCP——可能性真的是无穷无尽的。

它在本地计算机操作方面也特别好用。比如存储空间快满了，你直接让它给你出主意怎么清理。它会翻看你的本地文件夹，找出哪些东西占了大量空间，然后给出建议——比如删掉特别大的文件。我自己就有一些 Final Cut Pro 文件早该清理了，是 Claude Code 提醒我的。它可能还会让你用 `docker system prune` 清理没用的 Docker 镜像和容器，或者告诉你某个你从没意识到还存在的缓存该清了。不管你想对电脑做什么，现在 Claude Code 都是我第一个打开的地方。

我觉得这挺有意思的——计算机最初就是文本界面，而我们现在某种程度上又回到了这个文本界面，还能像我前面说的那样同时开三四个标签页。对我来说，这真的很令人兴奋。感觉就像拥有了第二个大脑。但因为它的结构方式就是一个终端标签页，你还可以再开第三个脑、第四个脑、第五个脑、第六个脑。随着模型越来越强大，你能委托给这些东西去思考的比例——不是重要的事情，而是那些你不想做、觉得无聊或太繁琐的事情——都可以交给它们处理。就像我之前说的，研究 GitHub Actions 就是个很好的例子。谁愿意干这个？但事实证明，这些 agent 特别擅长处理这类无聊的任务。

## Tip 32: 关键在于选择正确的抽象层级

正如我前面提到的，有时候停留在氛围编码层面是完全可以的。如果你在做一次性项目或者代码库中不那么关键的部分，不一定非要关注每一行代码。但有时候，你需要深入一点——看看文件结构和函数、具体的代码行，甚至检查依赖项。

![Vibe coding spectrum](assets/vibe-coding-spectrum.png)

关键是这不是非此即彼的事。有人说氛围编码不好，因为你根本不知道自己在做什么，但有时候这完全没问题。而另一些时候，确实值得深入进去，用上你的软件工程技能，在细粒度层面理解代码，或者把代码库的某些部分或具体的报错日志复制粘贴出来，向 Claude Code 提出针对性的问题。

这有点像在探索一座巨大的冰山。如果你想停在氛围编码层面，就可以从远处飞过顶端俯瞰。然后你可以靠近一点，进入潜水模式，越潜越深——Claude Code 就是你的向导。

## Tip 33: 审查你已批准的命令

我最近看到[这个帖子](https://www.reddit.com/r/ClaudeAI/comments/1pgxckk/claude_cli_deleted_my_entire_home_directory_wiped/)，有人的 Claude Code 执行了 `rm -rf tests/ patches/ plan/ ~/`，把他们的主目录整个清空了。这种事很容易被当成氛围编码者的失误一笑而过，但其实任何人都可能犯这种错。所以定期审查你已批准的命令是很重要的。为了方便大家，我做了一个工具叫 **cc-safe**——一个 CLI，可以扫描你的 `.claude/settings.json` 文件，找出其中有风险的已批准命令。

它能检测以下模式：
- `sudo`、`rm -rf`、`Bash`、`chmod 777`、`curl | sh`
- `git reset --hard`、`npm publish`、`docker run --privileged`
- 以及更多——它具备容器感知能力，所以 `docker exec` 命令会被跳过

它会递归扫描所有子目录，所以你可以把它指向你的项目文件夹，一次性检查所有内容。你可以手动运行，或者让 Claude Code 帮你运行：

```bash
npm install -g cc-safe
cc-safe ~/projects
```

或者直接用 npx 运行：

```bash
npx cc-safe .
```

GitHub: [cc-safe](https://github.com/ykdojo/cc-safe)

## Tip 34: 多写测试（并使用 TDD）

随着你用 Claude Code 写的代码越来越多，犯错的机会也越来越大。PR 审查和可视化 Git 客户端有助于发现问题（正如我前面提到的），但随着代码库规模扩大，写测试变得至关重要。

你可以让 Claude Code 为它自己写的代码编写测试。有人说 AI 无法测试自己的工作，但事实证明它可以——这和人类大脑的工作方式类似。当你写测试时，你是在用不同的方式思考同一个问题，AI 也是如此。

我发现 TDD（测试驱动开发）配合 Claude Code 效果非常好：

1. 先写测试
2. 确保测试失败
3. 提交测试
4. 再写代码让测试通过

这实际上就是我构建 [cc-safe](https://github.com/ykdojo/cc-safe) 的方式。先写出会失败的测试并在实现之前提交，这就为代码应该做什么创建了一个清晰的契约。Claude Code 随后就有了一个具体的目标，而你也可以通过运行测试来验证实现是否正确。

如果你想更加保险，可以自己审查一下测试，确保它们不会做什么蠢事，比如直接返回 true。

## Tip 35: 在未知领域更勇敢一些；迭代式问题解决

自从我开始更密集地使用 Claude Code，我发现自己在面对未知时越来越勇敢了。

比如，当我开始在 [Daft](https://github.com/Eventual-Inc/Daft) 工作时，我发现前端代码有个问题。我不是 React 专家，但我还是决定深入研究。我开始提问，问代码库的结构，问这个问题本身。最终我能够解决它，因为我知道怎么用 Claude Code 迭代地解决问题。

最近也发生了类似的事。我在为 Daft 的用户构建一份指南，遇到了一些非常具体的问题：cloudpickle 在 Google Colab 中与 Pydantic 不兼容，以及 Python 和少量 Rust 代码的另一个问题——在 JupyterLab 中打印结果不正确，但在终端里运行完全正常。我以前从未接触过 Rust。

我本可以直接创建一个 issue 让其他工程师来处理。但我想，让我自己深入代码库看看。Claude Code 给出了一个初步解决方案，但不够好。于是我放慢了节奏。一位同事建议我们直接禁用那部分功能，但我不想引入任何回归。我们能找到更好的解决方案吗？

接下来是一个协作性的迭代过程。Claude Code 提出了可能的根本原因和解决方案，我对这些方案进行实验。有些是死胡同，我们就换个方向。整个过程中，我控制着自己的节奏——有时候快一点，比如让它探索不同的解决方案空间或代码库的不同部分；有时候慢一点，问"这行代码到底是什么意思？"。控制抽象层级，控制速度。

最终我找到了一个相当优雅的解决方案。这件事的启示是：即使在未知领域，你用 Claude Code 能做到的事情，往往比你想象的要多得多。

## Tip 36: 在后台运行 bash 命令和子 agent

当 Claude Code 里有一个耗时较长的 bash 命令在跑时，你可以按 Ctrl+B 把它移到后台运行。Claude Code 知道如何管理后台进程——它之后可以用 BashOutput 工具来检查进度。

当你意识到某个命令比预期耗时更长，而你又想让 Claude 同时做其他事情时，这个功能就很有用了。你可以让它用我在 Tip 17 中提到的指数退避方法来检查进度，或者干脆让它在进程运行期间去做完全不同的事情。

Claude Code 也有在后台运行子 agent 的能力。如果你需要进行长时间的调研，或者让某个 agent 定期检查某件事，不必一直让它在前台运行。只需让 Claude Code 在后台运行一个 agent 或任务，它会在你继续其他工作的同时处理好那件事。

### 战略性地使用子 agent

除了在后台运行任务之外，当你有一个大型任务需要拆解时，子 agent 也非常有用。比如，你有一个巨大的代码库需要分析，可以让子 agent 从不同角度或并行分析代码库的不同部分。只需让 Claude 派生多个子 agent 来处理不同的部分即可。

你可以通过直接提问来自定义子 agent：
- **数量** - 告诉 Claude 你想派生几个
- **后台还是前台** - 要求在后台运行，或者按 Ctrl+B
- **使用哪个模型** - 根据每个任务的复杂程度选择 Opus、Sonnet 或 Haiku（子 agent 默认使用 Sonnet）

## Tip 37: 个性化软件的时代已经到来

我们正在进入一个个性化、定制化软件的时代。自从 AI 出现以来——ChatGPT 也算，但尤其是 Claude Code——我发现自己能够创建更多软件，有时只为自己用，有时是小型项目。

正如我在本文前面提到的，我创建了一个自定义转录工具，每天都用它来和 Claude Code 说话。我也创造了定制 Claude Code 本身的方式，还用 Python 以比以前快得多的速度完成了大量数据可视化和数据分析任务。

再举个例子：[korotovsky/slack-mcp-server](https://github.com/korotovsky/slack-mcp-server)，一个拥有近 1000 颗星的热门 Slack MCP，设计为 Docker 容器运行。我在自己的 Docker 容器内顺畅使用它时遇到了麻烦（Docker-in-Docker 的复杂性）。与其跟那套配置死磕，我直接让 Claude Code 用 Slack 的 Node SDK 写了一个 CLI，效果非常好。

现在是令人兴奋的时代。不管你想做什么，都可以让 Claude Code 来做。如果规模足够小，你可能一两个小时就能做出来。我甚至创建了一个[幻灯片模板](https://ykdojo.github.io/claude-code-tips/content/spectrum-slides.html)——一个包含 CSS 和 JavaScript 的单一 HTML 文件，可以在里面嵌入一个交互式的、持久化的终端进程。

## Tip 38: 在输入框中导航和编辑

Claude Code 的输入框设计模拟了常见的终端/readline 快捷键，如果你习惯在终端工作，会觉得非常顺手。以下是一些实用的快捷键：

**导航：**
- `Ctrl+A` - 跳到行首
- `Ctrl+E` - 跳到行尾
- `Option+Left/Right`（Mac）或 `Alt+Left/Right` - 按词向后/向前跳

**编辑：**
- `Ctrl+W` - 删除前一个词
- `Ctrl+U` - 从光标位置删除到行首
- `Ctrl+K` - 从光标位置删除到行尾
- `Ctrl+C` / `Ctrl+L` - 清除当前输入
- `Ctrl+G` - 在外部编辑器中打开你的提示词（在需要粘贴大量文本时很有用，因为直接粘贴到终端可能会很慢）

如果你熟悉 bash、zsh 或其他 shell，你会感觉非常自然。

对于 `Ctrl+G`，使用哪个编辑器取决于你的 `EDITOR` 环境变量。你可以在 shell 配置文件（`~/.zshrc` 或 `~/.bashrc`）中设置：

```bash
export EDITOR=vim      # or nano, code, nvim, etc.
```

或者在 `~/.claude/settings.json` 中设置（需要重启）：

```json
{
  "env": {
    "EDITOR": "vim"
  }
}
```

**输入换行（多行输入）：**

最快的方法无需任何配置、在任何地方都适用：输入 `\` 后按 Enter 即可创建换行。要使用键盘快捷键，可以在 Claude Code 中运行 `/terminal-setup`。在 Mac Terminal.app 上，我用的是 Option+Enter。

**粘贴图片：**
- `Ctrl+V`（Mac/Linux）或 `Alt+V`（Windows）- 从剪贴板粘贴图片

注意：在 Mac 上是 `Ctrl+V`，不是 `Cmd+V`。

## Tip 39: 花时间规划，同时也要快速原型

你需要花足够的时间来规划，让 Claude Code 知道要构建什么以及如何构建。这意味着要尽早做出高层决策：用什么技术、项目的结构如何、每个功能应该放在哪里、代码应该放在哪些文件里。尽早做出正确决策非常重要。

有时候，先做原型会有帮助。仅仅快速做一个简单的原型，你就能说"好，这个技术适合这个用途"或者"这个技术效果更好"。

比如，我最近在实验做一个 diff 查看器。我先试了用 tmux 和 lazygit 的简单 bash 原型，然后又试着用 Ink 和 Node 做自己的 git 查看器。各种问题层出不穷，最终没有发布任何成果。但这个项目让我重新认识到规划和原型的重要性。我发现，只要在开始写代码之前稍微规划得好一点，就能更好地引导它。在整个编码过程中你仍然需要引导它，但先让它规划一下确实很有帮助。

你可以按 Shift+Tab 切换到计划模式来实现这一点，或者直接告诉 Claude Code 在写任何代码之前先制定一个计划。

## Tip 40: 简化过于复杂的代码

我发现 Claude Code 有时候会把事情搞得过于复杂，写太多代码。它会做出你没有要求的修改，似乎天生就有一种写更多代码的偏好。如果你遵循了本指南中的其他技巧，代码可能是正确的，但会很难维护、很难审查。如果不充分审查，可能会是一场噩梦。

所以有时候你需要检查代码，让它来简化。你可以自己修改，但也可以直接让它来简化。你可以问它"为什么你要做这个特定的修改？"或者"为什么你要加这一行？"

有人说如果你只通过 AI 来写代码，你就永远不会真正理解它。但这只有在你问得不够多的情况下才成立。如果你确保自己理解每一件事，其实你能比以往更快地理解代码，因为你可以随时问 AI。尤其是当你在一个大型项目上工作的时候。

值得注意的是，这一点对于文字内容同样适用。Claude Code 经常会试图在最后一段总结前面的段落，或者在最后一句话里总结前面的句子，会变得相当啰嗦。有时候这种总结是有帮助的，但大多数时候你需要让它删除或精简。

## Tip 41: 自动化的自动化

说到底，一切都是关于自动化的自动化。我的意思是，我发现这不仅仅是提高生产力的最佳方式，也让整个过程变得更有趣。至少对我来说，这种"自动化的自动化"的过程真的很好玩。

我个人是从 ChatGPT 开始的，当时想自动化那个把 ChatGPT 给出的命令复制粘贴到终端里运行的过程。我通过构建一个叫 [Kaguya](https://github.com/ykdojo/kaguya) 的 ChatGPT 插件，把这整个过程自动化了。从那以后，我一直朝着越来越多的自动化方向努力。

现在，我们甚至不需要构建这样的工具了，因为 Claude Code 这样的工具已经存在，而且运行得非常好。随着我越来越多地使用它，我开始想——如果能自动化打字的过程呢？于是我用 Claude Code 本身构建了我的语音转录应用，就像我之前提到的那样。

然后我开始思考，我发现自己有时候会重复说同样的话，于是我把那些内容放进了 CLAUDE.md。接着我又想，好，有时候我会反复运行同样的命令，怎么能自动化这个过程？也许可以让 Claude Code 来做，或者把它们放进 skills，或者甚至让它创建一个脚本，这样我就不需要一遍遍重复同样的过程了。

我认为，这就是我们最终的方向。每当你发现自己在重复同样的任务或同样的命令——偶尔几次还好，但如果你反反复复地重复，就该想想怎么把这整个过程自动化了。

## Tip 42: 分享你的知识，力所能及地贡献

这个技巧和其他的有些不同。我发现，通过尽可能多地学习，你就能把知识分享给身边的人。也许通过像这样的文章，也许通过书、课程、视频。我最近还为 [Daft 的同事们做了一次内部分享](https://www.daft.ai/blog/how-we-use-ai-coding-agents)，收获感非常好。

而且每当我分享技巧时，我也经常能得到反馈。比如，当我分享我缩短系统提示词和工具描述的技巧（Tip 15）时，有人告诉我还有 `--system-prompt` 这个标志可以作为替代方案。还有一次，我分享了斜杠命令和 skills 的区别（Tip 25），我从那个 Reddit 帖子的评论里学到了新东西。

所以分享知识不仅仅是为了建立个人品牌或巩固你的学习成果，它也是一种通过这个过程学到新东西的方式。这不总是单向的。

说到贡献，我一直在向 Claude Code 的代码仓库提交 issue。我想，好，如果他们听，很好；如果他们不听，也完全没关系，我没有任何期望。但在 2.0.67 版本中，我注意到他们采纳了我提出的多条建议：

- 修复了在 `/permissions` 中删除权限规则后滚动位置重置的问题
- 为 `/permissions` 命令添加了搜索功能

这个团队对功能请求和 bug 报告的反应速度真的令人惊叹。但这也说得通，因为他们就是在用 Claude Code 来构建 Claude Code 本身。

## Tip 43: 保持学习！

以下是几种持续了解 Claude Code 的有效方式：

**直接问 Claude Code 本身** - 如果你对 Claude Code 有任何问题，直接问它就好。Claude Code 有一个专门回答关于自身功能、斜杠命令、设置、hooks、MCP 服务器等问题的专属子 agent。

**查看更新日志** - 输入 `/release-notes` 可以查看当前版本的新功能。这是了解最新功能的最佳方式。

**向社区学习** - [r/ClaudeAI](https://www.reddit.com/r/ClaudeAI/) 是向其他用户学习、了解大家工作流程的好地方。

**关注 Ado 的技巧分享** - Ado（[@adocomplete](https://x.com/adocomplete)）是 Anthropic 的 DevRel，在 2025 年 12 月期间每天在他的"Advent of Claude"系列中分享 Claude Code 技巧。虽然这个特别系列已经结束，但他在 X 上持续分享有用的技巧。

- [Twitter/X: Advent of Claude 帖子](https://x.com/search?q=from%3Aadocomplete%20advent%20of%20claude&src=typed_query&f=live)
- [LinkedIn: Advent of Claude 帖子](https://www.linkedin.com/search/results/content/?fromMember=%5B%22ACoAAAFdD3IBYHwKSh6FsyGqOh1SpbrZ9ZHTjnI%22%5D&keywords=advent%20of%20claude&origin=FACETED_SEARCH&sid=zDV&sortBy=%22date_posted%22)

## Tip 44: 安装 dx 插件

这个仓库同时也是一个名为 `dx`（开发者体验）的 Claude Code 插件。它将上面多个技巧中的工具打包成一个安装包：

| Skill | 描述 |
|-------|------|
| `/dx:gha <url>` | 分析 GitHub Actions 失败情况（Tip 29） |
| `/dx:handoff` | 创建上下文延续的交接文档（Tip 8） |
| `/dx:clone` | 克隆会话以便分支（Tip 23） |
| `/dx:half-clone` | 半克隆以减少上下文（Tip 23） |
| `/dx:reddit-fetch` | 通过 Gemini CLI 获取 Reddit 内容（Tip 11） |
| `/dx:review-claudemd` | 审查会话以改进 CLAUDE.md 文件（Tip 30） |

**两条命令即可安装：**

```bash
claude plugin marketplace add ykdojo/claude-code-tips
claude plugin install dx@ykdojo
```

安装后，命令可以通过 `/dx:clone`、`/dx:half-clone`、`/dx:handoff` 和 `/dx:gha` 使用。`reddit-fetch` skill 会在你询问 Reddit URL 时自动触发。`review-claudemd` skill 会分析你最近的会话，并为你的 CLAUDE.md 文件提出改进建议。关于克隆命令，请参阅[推荐权限设置](#recommended-permission-for-clone-scripts)。

**推荐搭配：** [Playwright MCP](https://github.com/microsoft/playwright-mcp) 用于浏览器自动化——通过 `claude mcp add -s user playwright npx @playwright/mcp@latest` 添加

## Tip 45: 快速安装脚本

如果你想一次性设置本仓库中的多项推荐配置，有一个安装脚本可以处理大部分内容：

```bash
bash <(curl -s https://raw.githubusercontent.com/ykdojo/claude-code-tips/main/scripts/setup.sh)
```

脚本会展示所有将要配置的内容，并允许你跳过任何不需要的项目：

```
INSTALLS:
  1. DX plugin - slash commands (/dx:gha, /dx:clone, /dx:handoff) and skills (reddit-fetch)
  2. cc-safe - scans your settings for risky approved commands like 'rm -rf' or 'sudo'

SETTINGS (~/.claude/settings.json):
  3. Status line - shows model, git branch, uncommitted files, token usage at bottom of screen
  4. Disable auto-updates - prevents Claude Code from auto-updating (useful for system prompt patches)
  5. Lazy-load MCP tools - only loads MCP tool definitions when needed, saves context
  6. Read(~/.claude) permission - allows clone/half-clone commands to read conversation history
  7. Read(//tmp/**) permission - allows reading temporary files without prompts
  8. Disable attribution - removes Co-Authored-By from commits and attribution from PRs

SHELL CONFIG (~/.zshrc or ~/.bashrc):
  9. Aliases: c=claude, ch=claude --chrome, cs=claude --dangerously-skip-permissions
 10. Fork shortcut: --fs expands to --fork-session (e.g., claude -c --fs)

Skip any? [e.g., 1 4 7 or Enter for all]:
```

---

📺 **相关演讲**: [Claude Code Masterclass](https://youtu.be/9UdZhTnMrTA) - 31 个月 agentic 编码的经验与项目案例

📝 **故事**: [How I got a full-time job with Claude Code](content/how-i-got-a-job-with-claude-code.md)

📰 **Newsletter**: [Agentic Coding with Discipline and Skill](https://agenticcoding.substack.com/) - 将 agentic 编码实践提升到新的高度