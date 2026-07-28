#!/bin/bash

# Stop hook: suggests /half-clone when context usage exceeds 85%.
# When triggered, it blocks Claude from stopping and tells it to run /half-clone,
# which creates a new conversation with only the later half to continue in.
# Install by adding to ~/.claude/settings.json:
# {
#   "hooks": {
#     "Stop": [{
#       "hooks": [{
#         "type": "command",
#         "command": "~/.claude/scripts/check-context.sh"
#       }]
#     }]
#   }
# }

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# Read input from stdin
input=$(cat)

# Prevent infinite loops - exit if already triggered by a stop hook
stop_hook_active=$(echo "$input" | jq -r '.stop_hook_active // false' 2>/dev/null)
if [[ "$stop_hook_active" == "true" ]]; then
    log_info "Stop hook already active, skipping."
    exit 0
fi

transcript_path=$(echo "$input" | jq -r '.transcript_path // empty' 2>/dev/null)
if [[ -z "$transcript_path" || ! -f "$transcript_path" ]]; then
    log_warning "No transcript path found or transcript file doesn't exist."
    exit 0
fi

max_context=200000

# Calculate context usage from transcript (same method as context-bar.sh)
context_length=$(jq -s '
    map(select(.message.usage and .isSidechain != true and .isApiErrorMessage != true)) |
    last |
    if . then
        (.message.usage.input_tokens // 0) +
        (.message.usage.cache_read_input_tokens // 0) +
        (.message.usage.cache_creation_input_tokens // 0)
    else 0 end
' < "$transcript_path" 2>/dev/null)

if [[ -z "$context_length" || "$context_length" -eq 0 ]]; then
    log_warning "Unable to calculate context usage from transcript."
    exit 0
fi

pct=$((context_length * 100 / max_context))

if [[ $pct -ge 85 ]]; then
    log_info "Context usage is at ${pct}% (${context_length}/${max_context} tokens)."
    echo "{\"decision\": \"block\", \"reason\": \"Context usage is at ${pct}%. Please run /half-clone to create a new conversation with only the later half so a new agent can continue there.\"}"
else
    log_info "Context usage is at ${pct}% (${context_length}/${max_context} tokens). No action needed."
fi
