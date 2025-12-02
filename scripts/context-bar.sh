#!/bin/bash

# Claude Code status line script
# Shows: Opus 4.5 | 📁 Daft | 🔀 main (2 files uncommitted) | ████▄░░░░░ 45% of 200k tokens used (/context)
#
# Context calculation:
# - 200k total context window
# - 45k reserved for autocompact buffer (disable via /config if needed)
# - 20k baseline for system prompt, tools, memory, and dynamic context
# - 155k effectively available (after autocompact buffer), 135k free at conversation start

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

    # 200k total context window
    max_context=200000
    # 20k baseline: includes system prompt (~3k), tools (~15k), memory (~300),
    # plus ~2k for git status, env block, XML framing, and other dynamic context
    # not shown in /context breakdown but sent to the API
    baseline=20000
    bar_width=10

    if [[ "$context_length" -gt 0 ]]; then
        pct=$((context_length * 100 / max_context))
    else
        # At conversation start, ~18k baseline is already loaded
        pct=$((baseline * 100 / max_context))
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

    ctx="${bar} ${pct}% of 200k tokens used (/context)"
else
    ctx="█░░░░░░░░░ 10% of 200k tokens used (/context)"
fi

# Build output: Model | Dir | Branch (uncommitted) | Context
output="${model} | 📁${dir}"
[[ -n "$branch" ]] && output+=" | 🔀${branch} ${git_status}"
output+=" | ${ctx}"

echo "$output"

# Get conversation title (from summary entry) and user's last message
# Format: 📌 {title} | 💬 {last_message}
if [[ -n "$transcript_path" && -f "$transcript_path" ]]; then
    max_len=${#output}

    # Extract title from summary entry (if exists)
    title=$(jq -rs '[.[] | select(.type == "summary")] | last | .summary // empty' < "$transcript_path" 2>/dev/null)

    # Extract last user message (text only, not tool results)
    last_user_msg=$(jq -rs '
        [.[] | select(.type == "user") |
         select(.message.content | type == "string" or
                (type == "array" and any(.[]; .type == "text")))] |
        last | .message.content |
        if type == "string" then .
        else [.[] | select(.type == "text") | .text] | join(" ") end |
        gsub("\n"; " ") | gsub("  +"; " ")
    ' < "$transcript_path" 2>/dev/null)

    # Build second line: title first, then last message if room
    if [[ -n "$title" && -n "$last_user_msg" ]]; then
        # Format: 📌 title | 💬 message
        prefix="📌 "
        separator=" | 💬 "
        title_len=$((max_len - ${#prefix} - ${#separator} - 3))  # reserve 3 for "..."

        if [[ ${#title} -le $title_len ]]; then
            # Title fits, add message with remaining space
            remaining=$((max_len - ${#prefix} - ${#title} - ${#separator}))
            if [[ $remaining -gt 10 ]]; then
                if [[ ${#last_user_msg} -gt $remaining ]]; then
                    last_user_msg="${last_user_msg:0:$((remaining - 3))}..."
                fi
                echo "${prefix}${title}${separator}${last_user_msg}"
            else
                echo "${prefix}${title}"
            fi
        else
            # Title too long, truncate it
            echo "${prefix}${title:0:$title_len}..."
        fi
    elif [[ -n "$title" ]]; then
        # Only title available
        title_max=$((max_len - 4))
        if [[ ${#title} -gt $title_max ]]; then
            echo "📌 ${title:0:$title_max}..."
        else
            echo "📌 ${title}"
        fi
    elif [[ -n "$last_user_msg" ]]; then
        # Only message available
        msg_max=$((max_len - 4))
        if [[ ${#last_user_msg} -gt $msg_max ]]; then
            echo "💬 ${last_user_msg:0:$msg_max}..."
        else
            echo "💬 ${last_user_msg}"
        fi
    fi
fi
