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
        file_count=$(git -C "$cwd" --no-optional-locks status --porcelain -uall 2>/dev/null | wc -l | tr -d ' ')

        # Check sync status with upstream
        sync_status=""
        upstream=$(git -C "$cwd" rev-parse --abbrev-ref @{upstream} 2>/dev/null)
        if [[ -n "$upstream" ]]; then
            # Get last fetch time
            fetch_head="$cwd/.git/FETCH_HEAD"
            fetch_ago=""
            if [[ -f "$fetch_head" ]]; then
                fetch_time=$(stat -f %m "$fetch_head" 2>/dev/null || stat -c %Y "$fetch_head" 2>/dev/null)
                if [[ -n "$fetch_time" ]]; then
                    now=$(date +%s)
                    diff=$((now - fetch_time))
                    if [[ $diff -lt 60 ]]; then
                        fetch_ago="<1m ago"
                    elif [[ $diff -lt 3600 ]]; then
                        fetch_ago="$((diff / 60))m ago"
                    elif [[ $diff -lt 86400 ]]; then
                        fetch_ago="$((diff / 3600))h ago"
                    else
                        fetch_ago="$((diff / 86400))d ago"
                    fi
                fi
            fi

            counts=$(git -C "$cwd" rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
            ahead=$(echo "$counts" | cut -f1)
            behind=$(echo "$counts" | cut -f2)
            if [[ "$ahead" -eq 0 && "$behind" -eq 0 ]]; then
                if [[ -n "$fetch_ago" ]]; then
                    sync_status="synced ${fetch_ago}"
                else
                    sync_status="synced"
                fi
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

# Get user's last message (text only, not tool results, skip unhelpful messages)
if [[ -n "$transcript_path" && -f "$transcript_path" ]]; then
    max_len=$((${#output} - 4))  # subtract for "💬 " prefix
    last_user_msg=$(jq -rs '
        # Messages to skip (not useful as context)
        def is_unhelpful:
            startswith("[Request interrupted") or
            startswith("[Request cancelled") or
            . == "";

        [.[] | select(.type == "user") |
         select(.message.content | type == "string" or
                (type == "array" and any(.[]; .type == "text")))] |
        reverse |
        map(.message.content |
            if type == "string" then .
            else [.[] | select(.type == "text") | .text] | join(" ") end |
            gsub("\n"; " ") | gsub("  +"; " ")) |
        map(select(is_unhelpful | not)) |
        first // ""
    ' < "$transcript_path" 2>/dev/null)

    if [[ -n "$last_user_msg" ]]; then
        if [[ ${#last_user_msg} -gt $max_len ]]; then
            echo "💬 ${last_user_msg:0:$((max_len - 3))}..."
        else
            echo "💬 ${last_user_msg}"
        fi
    fi
fi
