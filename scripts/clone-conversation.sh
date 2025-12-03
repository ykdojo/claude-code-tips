#!/usr/bin/env bash
#
# clone-conversation.sh - Clone a Claude Code conversation
#
# Usage:
#   clone-conversation.sh <session-id> [project-path]
#
# Arguments:
#   session-id    The UUID of the conversation to clone (required)
#   project-path  The project path (default: current directory)
#
# Example:
#   clone-conversation.sh d96c899d-7501-4e81-a31b-e0095bb3b501
#   clone-conversation.sh d96c899d-7501-4e81-a31b-e0095bb3b501 /home/user/myproject
#
# After cloning, use 'claude -r' to see both the original and cloned conversation.

set -euo pipefail

CLAUDE_DIR="${HOME}/.claude"
PROJECTS_DIR="${CLAUDE_DIR}/projects"
HISTORY_FILE="${CLAUDE_DIR}/history.jsonl"
TODOS_DIR="${CLAUDE_DIR}/todos"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

usage() {
    echo "Usage: $0 <session-id> [project-path]"
    echo ""
    echo "Arguments:"
    echo "  session-id    The UUID of the conversation to clone (required)"
    echo "  project-path  The project path (default: current directory)"
    echo ""
    echo "Example:"
    echo "  $0 d96c899d-7501-4e81-a31b-e0095bb3b501"
    echo "  $0 d96c899d-7501-4e81-a31b-e0095bb3b501 /home/user/myproject"
    echo ""
    echo "To find your current session ID, look in ~/.claude/history.jsonl"
    echo "or check the conversation file names in ~/.claude/projects/<project>/"
    exit 1
}

generate_uuid() {
    # Generate a new UUID v4
    if command -v uuidgen &> /dev/null; then
        uuidgen | tr '[:upper:]' '[:lower:]'
    elif [ -f /proc/sys/kernel/random/uuid ]; then
        cat /proc/sys/kernel/random/uuid
    else
        # Fallback: generate pseudo-UUID using bash
        printf '%04x%04x-%04x-%04x-%04x-%04x%04x%04x\n' \
            $((RANDOM)) $((RANDOM)) $((RANDOM)) \
            $((RANDOM & 0x0fff | 0x4000)) \
            $((RANDOM & 0x3fff | 0x8000)) \
            $((RANDOM)) $((RANDOM)) $((RANDOM))
    fi
}

convert_path_to_dirname() {
    # Convert a path like /home/claude/workspace to -home-claude-workspace
    echo "$1" | sed 's|^/||' | sed 's|/|-|g' | sed 's|^|-|'
}

find_conversation_file() {
    local session_id="$1"
    local project_path="$2"

    # Convert project path to the directory name format Claude uses
    local project_dirname
    project_dirname=$(convert_path_to_dirname "$project_path")

    local project_dir="${PROJECTS_DIR}/${project_dirname}"
    local conv_file="${project_dir}/${session_id}.jsonl"

    if [ -f "$conv_file" ]; then
        echo "$conv_file"
        return 0
    fi

    # Try to find the conversation in any project directory
    local found_file
    found_file=$(find "$PROJECTS_DIR" -name "${session_id}.jsonl" 2>/dev/null | head -1)

    if [ -n "$found_file" ]; then
        echo "$found_file"
        return 0
    fi

    return 1
}

get_project_from_conv_file() {
    local conv_file="$1"
    # Extract project directory name from the path
    local project_dirname
    project_dirname=$(dirname "$conv_file" | xargs basename)
    # Convert back to path format
    echo "$project_dirname" | sed 's|^-|/|' | sed 's|-|/|g'
}

clone_conversation() {
    local source_session="$1"
    local project_path="$2"

    # Find the source conversation file
    local source_file
    if ! source_file=$(find_conversation_file "$source_session" "$project_path"); then
        log_error "Could not find conversation file for session: $source_session"
        log_info "Looking in: ${PROJECTS_DIR}"
        log_info "Available conversations:"
        find "$PROJECTS_DIR" -name "*.jsonl" -type f 2>/dev/null | while read -r f; do
            local fname
            fname=$(basename "$f")
            # Only show UUID-named files (36 chars + .jsonl)
            if [[ ${#fname} -eq 42 && "$fname" =~ ^[a-f0-9-]+\.jsonl$ ]]; then
                echo "  - ${fname%.jsonl}"
            fi
        done
        exit 1
    fi

    log_info "Found source conversation: $source_file"

    # Get the project path from the file location if not specified
    if [ -z "$project_path" ]; then
        project_path=$(get_project_from_conv_file "$source_file")
    fi

    # Generate new session ID
    local new_session
    new_session=$(generate_uuid)
    log_info "Generated new session ID: $new_session"

    # Determine target file path
    local project_dirname
    project_dirname=$(convert_path_to_dirname "$project_path")
    local project_dir="${PROJECTS_DIR}/${project_dirname}"
    local target_file="${project_dir}/${new_session}.jsonl"

    # Create project directory if it doesn't exist
    mkdir -p "$project_dir"

    # Copy and transform the conversation file
    log_info "Cloning conversation to: $target_file"

    # Replace all occurrences of the old session ID with the new one
    # Also generate new UUIDs for each message to ensure uniqueness
    python3 << EOF
import json
import uuid
import sys

source_file = "$source_file"
target_file = "$target_file"
old_session = "$source_session"
new_session = "$new_session"

# Mapping of old UUIDs to new UUIDs
uuid_map = {}
first_user_message_tagged = False

def get_new_uuid(old_uuid):
    if old_uuid is None:
        return None
    if old_uuid not in uuid_map:
        uuid_map[old_uuid] = str(uuid.uuid4())
    return uuid_map[old_uuid]

def tag_first_user_message(obj):
    """Add [CLONED] tag to the first user message content"""
    global first_user_message_tagged
    if first_user_message_tagged:
        return obj
    if obj.get('type') != 'user' or 'message' not in obj:
        return obj

    msg = obj['message']
    if isinstance(msg, dict) and 'content' in msg:
        content = msg['content']
        if isinstance(content, str):
            obj['message']['content'] = '[CLONED] ' + content
            first_user_message_tagged = True
        elif isinstance(content, list):
            for item in content:
                if isinstance(item, dict) and item.get('type') == 'text':
                    item['text'] = '[CLONED] ' + item.get('text', '')
                    first_user_message_tagged = True
                    break
    return obj

try:
    with open(source_file, 'r') as f:
        lines = f.readlines()

    new_lines = []
    for line in lines:
        line = line.strip()
        if not line:
            continue

        try:
            obj = json.loads(line)
        except json.JSONDecodeError:
            # Keep non-JSON lines as-is
            new_lines.append(line)
            continue

        # Update session ID
        if 'sessionId' in obj:
            obj['sessionId'] = new_session

        # Tag the first user message with [CLONED]
        obj = tag_first_user_message(obj)

        # Update UUIDs
        if 'uuid' in obj:
            obj['uuid'] = get_new_uuid(obj['uuid'])

        if 'parentUuid' in obj:
            obj['parentUuid'] = get_new_uuid(obj['parentUuid'])

        if 'messageId' in obj:
            obj['messageId'] = get_new_uuid(obj['messageId'])

        # Update snapshot messageId if present
        if 'snapshot' in obj and isinstance(obj['snapshot'], dict):
            if 'messageId' in obj['snapshot']:
                obj['snapshot']['messageId'] = get_new_uuid(obj['snapshot']['messageId'])

        new_lines.append(json.dumps(obj, separators=(',', ':')))

    with open(target_file, 'w') as f:
        for line in new_lines:
            f.write(line + '\n')

    print(f"SUCCESS: Wrote {len(new_lines)} lines to {target_file}")

except Exception as e:
    print(f"ERROR: {e}", file=sys.stderr)
    sys.exit(1)
EOF

    if [ $? -ne 0 ]; then
        log_error "Failed to clone conversation file"
        exit 1
    fi

    # Update history.jsonl to include the new conversation
    log_info "Updating history file..."

    # Get the first user message for the display text
    local display_text
    display_text=$(python3 << EOF
import json

source_file = "$source_file"

try:
    with open(source_file, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
                if obj.get('type') == 'user' and 'message' in obj:
                    msg = obj['message']
                    if isinstance(msg, dict) and 'content' in msg:
                        content = msg['content']
                        if isinstance(content, str):
                            # Truncate and escape for shell
                            text = content[:200].replace('"', '\\"').replace('\n', ' ')
                            print(text)
                            break
                        elif isinstance(content, list):
                            for item in content:
                                if isinstance(item, dict) and item.get('type') == 'text':
                                    text = item.get('text', '')[:200].replace('"', '\\"').replace('\n', ' ')
                                    print(text)
                                    break
                            break
            except json.JSONDecodeError:
                continue
except Exception as e:
    print(f"[Cloned conversation]", end='')
EOF
)

    # Add entry to history.jsonl
    # Use platform-specific timestamp (milliseconds) + buffer to ensure it's the latest
    local timestamp
    if [[ "$OSTYPE" == "darwin"* ]]; then
        timestamp=$(( $(date +%s) * 1000 + 1000 ))
    else
        timestamp=$(( $(date +%s%3N) + 1000 ))
    fi

    # Create history entry
    python3 << EOF
import json
import os

history_file = "$HISTORY_FILE"
new_session = "$new_session"
project = "$project_path"
timestamp = $timestamp
display = """$display_text"""

# Truncate display text if needed
if len(display) > 200:
    display = display[:200] + "..."

# Prepend [CLONED] to indicate this is a clone
display = "[CLONED] " + display

entry = {
    "display": display,
    "pastedContents": {},
    "timestamp": timestamp,
    "project": project,
    "sessionId": new_session
}

# Append to history file
with open(history_file, 'a') as f:
    f.write(json.dumps(entry, separators=(',', ':')) + '\n')

print("History entry added successfully")
EOF

    # Copy todos if they exist
    local old_todo_file="${TODOS_DIR}/${source_session}-agent-${source_session}.json"
    local new_todo_file="${TODOS_DIR}/${new_session}-agent-${new_session}.json"

    if [ -f "$old_todo_file" ]; then
        log_info "Copying todo file..."
        cp "$old_todo_file" "$new_todo_file"
    fi

    log_success "Conversation cloned successfully!"
    echo ""
    echo "Original session: $source_session"
    echo "New session:      $new_session"
    echo "Project:          $project_path"
    echo ""
    echo "To resume the cloned conversation, use:"
    echo "  claude -r"
    echo ""
    echo "Then select the conversation marked with [CLONED]"
}

# Main
if [ $# -lt 1 ]; then
    usage
fi

SESSION_ID="$1"
PROJECT_PATH="${2:-$(pwd)}"

# Validate session ID format (UUID)
if ! [[ "$SESSION_ID" =~ ^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$ ]]; then
    log_error "Invalid session ID format. Expected UUID like: d96c899d-7501-4e81-a31b-e0095bb3b501"
    exit 1
fi

# Check if Claude directory exists
if [ ! -d "$CLAUDE_DIR" ]; then
    log_error "Claude directory not found at $CLAUDE_DIR"
    exit 1
fi

clone_conversation "$SESSION_ID" "$PROJECT_PATH"
