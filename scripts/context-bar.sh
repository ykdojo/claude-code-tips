#!/bin/bash

# Claude Code status line script
# Shows: Opus 4.5 | 📁 Daft | 🔀 main (2 files uncommitted) | ████▄░░░░░ 45% of 155k (/context)
#
# Context calculation:
# - 200k total context window
# - 45k reserved for autocompact buffer (disable via /config if needed)
# - 18k baseline for system prompt, tools, and memory
# - 155k effectively available, 137k free at conversation start

input=$(cat)

# Extract model, directory, and cwd
model=$(echo "$input" | jq -r '.model.display_name // .model.id // "?"')
cwd=$(echo "$input" | jq -r '.cwd // empty')
dir=$(basename "$cwd" 2>/dev/null || echo "?")

# Get git branch, uncommitted file count, and sync status
branch=""
git_status=""
if [[ -n "$cwd" && -d "$cwd" ]]; then
    branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
    if [[ -n "$branch" ]]; then
        # Count uncommitted files
        file_count=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null | wc -l | tr -d ' ')

        # Check sync status with upstream
        sync_status=""
        upstream=$(git -C "$cwd" rev-parse --abbrev-ref @{upstream} 2>/dev/null)
        if [[ -n "$upstream" ]]; then
            counts=$(git -C "$cwd" rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
            ahead=$(echo "$counts" | cut -f1)
            behind=$(echo "$counts" | cut -f2)
            if [[ "$ahead" -eq 0 && "$behind" -eq 0 ]]; then
                sync_status="synced"
            elif [[ "$ahead" -gt 0 && "$behind" -eq 0 ]]; then
                sync_status="${ahead} ahead"
            elif [[ "$ahead" -eq 0 && "$behind" -gt 0 ]]; then
                sync_status="${behind} behind"
            else
                sync_status="${ahead} ahead, ${behind} behind"
            fi
        else
            sync_status="no upstream"
        fi

        # Build git status string
        if [[ "$file_count" -eq 0 ]]; then
            git_status="(0 files uncommitted, ${sync_status})"
        elif [[ "$file_count" -eq 1 ]]; then
            git_status="(1 file uncommitted, ${sync_status})"
        else
            git_status="(${file_count} files uncommitted, ${sync_status})"
        fi
    fi
fi

# Get transcript path for context calculation
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')

# Calculate context bar
if [[ -n "$transcript_path" && -f "$transcript_path" ]]; then
    context_length=$(jq -s '
        map(select(.message.usage and .isSidechain != true and .isApiErrorMessage != true)) |
        last |
        if . then
            (.message.usage.input_tokens // 0) +
            (.message.usage.cache_read_input_tokens // 0) +
            (.message.usage.cache_creation_input_tokens // 0)
        else 0 end
    ' < "$transcript_path")

    # 155k available (200k minus 45k autocompact buffer)
    max_context=155000
    # 18k baseline for system prompt, tools, memory
    baseline=18000
    bar_width=10

    # Subtract baseline to get conversation-only tokens
    conversation_tokens=$((context_length - baseline))
    [[ $conversation_tokens -lt 0 ]] && conversation_tokens=0

    if [[ "$conversation_tokens" -gt 0 ]]; then
        pct=$((conversation_tokens * 100 / max_context))
    else
        pct=0
    fi

    [[ $pct -gt 100 ]] && pct=100

    bar=""
    for ((i=0; i<bar_width; i++)); do
        bar_start=$((i * 10))
        progress=$((pct - bar_start))
        if [[ $progress -ge 8 ]]; then
            bar+="█"
        elif [[ $progress -ge 3 ]]; then
            bar+="▄"
        else
            bar+="░"
        fi
    done

    ctx="${bar} ${pct}% of 155k (/context)"
else
    ctx="░░░░░░░░░░ 0% of 155k (/context)"
fi

# Build output: Model | Dir | Branch (uncommitted) | Context
output="${model} | 📁${dir}"
[[ -n "$branch" ]] && output+=" | 🔀${branch} ${git_status}"
output+=" | ${ctx}"

echo "$output"
