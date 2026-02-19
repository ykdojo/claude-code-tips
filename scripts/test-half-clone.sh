#!/usr/bin/env bash
#
# test-half-clone.sh - Test suite for half-clone-conversation.sh
#
# Creates mock conversations and verifies the half-clone behavior.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HALF_CLONE_SCRIPT="${SCRIPT_DIR}/half-clone-conversation.sh"

# Test directory (isolated from real Claude data)
TEST_DIR=$(mktemp -d)
TEST_CLAUDE_DIR="${TEST_DIR}/.claude"
TEST_PROJECTS_DIR="${TEST_CLAUDE_DIR}/projects"
TEST_PROJECT_PATH="/test/project"
TEST_PROJECT_DIRNAME="-test-project"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

log_test() { echo -e "${YELLOW}[TEST]${NC} $1"; ((++TESTS_RUN)) || true; }
log_pass() { echo -e "${GREEN}[PASS]${NC} $1"; ((++TESTS_PASSED)) || true; }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; ((++TESTS_FAILED)) || true; }

setup_test_env() {
    mkdir -p "${TEST_PROJECTS_DIR}/${TEST_PROJECT_DIRNAME}"
    mkdir -p "${TEST_CLAUDE_DIR}/todos"
    touch "${TEST_CLAUDE_DIR}/history.jsonl"
}

cleanup_test_env() {
    rm -rf "$TEST_DIR"
}

# Generate a mock message line
# Args: uuid, parent_uuid (or "null"), session_id, type (user/assistant), content
generate_message() {
    local uuid="$1"
    local parent_uuid="$2"
    local session_id="$3"
    local msg_type="$4"
    local content="$5"

    local parent_field
    if [ "$parent_uuid" = "null" ]; then
        parent_field='"parentUuid":null'
    else
        parent_field="\"parentUuid\":\"${parent_uuid}\""
    fi

    if [ "$msg_type" = "user" ]; then
        echo "{${parent_field},\"sessionId\":\"${session_id}\",\"type\":\"user\",\"message\":{\"role\":\"user\",\"content\":\"${content}\"},\"uuid\":\"${uuid}\",\"timestamp\":\"2025-01-01T00:00:00.000Z\"}"
    else
        echo "{${parent_field},\"sessionId\":\"${session_id}\",\"type\":\"assistant\",\"message\":{\"role\":\"assistant\",\"content\":[{\"type\":\"text\",\"text\":\"${content}\"}]},\"uuid\":\"${uuid}\",\"timestamp\":\"2025-01-01T00:00:00.000Z\"}"
    fi
}

# Create a test conversation with N messages
# Returns the session ID
create_test_conversation() {
    local num_messages="$1"
    local session_id
    session_id=$(uuidgen | tr '[:upper:]' '[:lower:]')
    local conv_file="${TEST_PROJECTS_DIR}/${TEST_PROJECT_DIRNAME}/${session_id}.jsonl"

    local prev_uuid="null"
    for i in $(seq 1 "$num_messages"); do
        local uuid
        uuid=$(uuidgen | tr '[:upper:]' '[:lower:]')
        local msg_type
        if [ $((i % 2)) -eq 1 ]; then
            msg_type="user"
            generate_message "$uuid" "$prev_uuid" "$session_id" "user" "User message $i"
        else
            msg_type="assistant"
            generate_message "$uuid" "$prev_uuid" "$session_id" "assistant" "Assistant response $i"
        fi
        prev_uuid="$uuid"
    done > "$conv_file"

    echo "$session_id"
}

run_half_clone() {
    local session_id="$1"
    # Override HOME to use test directory
    HOME="$TEST_DIR" "$HALF_CLONE_SCRIPT" "$session_id" "$TEST_PROJECT_PATH" 2>&1
}

count_messages() {
    local file="$1"
    wc -l < "$file" | tr -d ' '
}

get_new_session_from_output() {
    local output="$1"
    echo "$output" | grep "New session:" | awk '{print $3}'
}

# Test 1: 6 messages (3 user, 3 assistant) -> 3 clean user msgs, skip 1, keep 2
# Starts at user message 2 (line 3), keeps lines 3-6 = 4 messages + 1 reference = 5
test_even_messages() {
    log_test "6 messages (3 clean user): should keep 4 lines + 1 reference = 5"

    local session_id
    session_id=$(create_test_conversation 6)
    local output
    output=$(run_half_clone "$session_id")

    local new_session
    new_session=$(get_new_session_from_output "$output")
    local new_file="${TEST_PROJECTS_DIR}/${TEST_PROJECT_DIRNAME}/${new_session}.jsonl"

    if [ ! -f "$new_file" ]; then
        log_fail "Output file not created"
        return
    fi

    local count
    count=$(count_messages "$new_file")
    if [ "$count" -eq 5 ]; then
        log_pass "Kept 5 messages (4 + reference)"
    else
        log_fail "Expected 5 messages, got $count"
    fi
}

# Test 2: 7 messages (4 user, 3 assistant) -> 4 clean user msgs, skip 2, keep 2
# Starts at user message 3 (line 5), keeps lines 5-7 = 3 messages + 1 reference = 4
test_odd_messages() {
    log_test "7 messages (4 clean user): should keep 3 lines + 1 reference = 4"

    local session_id
    session_id=$(create_test_conversation 7)
    local output
    output=$(run_half_clone "$session_id")

    local new_session
    new_session=$(get_new_session_from_output "$output")
    local new_file="${TEST_PROJECTS_DIR}/${TEST_PROJECT_DIRNAME}/${new_session}.jsonl"

    local count
    count=$(count_messages "$new_file")
    if [ "$count" -eq 4 ]; then
        log_pass "Kept 4 messages (3 + reference)"
    else
        log_fail "Expected 4 messages, got $count"
    fi
}

# Test 3: 4 messages (2 user, 2 assistant) -> 2 clean user msgs, skip 1, keep 1
# Starts at user message 2 (line 3), keeps lines 3-4 = 2 messages + 1 reference = 3
test_minimum_messages() {
    log_test "4 messages (2 clean user): should keep 2 lines + 1 reference = 3"

    local session_id
    session_id=$(create_test_conversation 4)
    local output
    output=$(run_half_clone "$session_id")

    local new_session
    new_session=$(get_new_session_from_output "$output")
    local new_file="${TEST_PROJECTS_DIR}/${TEST_PROJECT_DIRNAME}/${new_session}.jsonl"

    local count
    count=$(count_messages "$new_file")
    if [ "$count" -eq 3 ]; then
        log_pass "Kept 3 messages (2 + reference)"
    else
        log_fail "Expected 3 messages, got $count"
    fi
}

# Test 4: 2 messages (1 user, 1 assistant) -> only 1 clean user msg, should error
test_single_message_error() {
    log_test "2 messages (1 clean user): should error"

    local session_id
    session_id=$(create_test_conversation 2)
    local output
    if output=$(run_half_clone "$session_id" 2>&1); then
        log_fail "Should have failed but succeeded"
    else
        if echo "$output" | grep -q "fewer than 2 clean user messages"; then
            log_pass "Correctly errored for single clean user message"
        else
            log_fail "Wrong error message: $output"
        fi
    fi
}

# Test 5: First kept message has null parentUuid
test_parent_uuid_nullified() {
    log_test "First kept message should have null parentUuid"

    local session_id
    session_id=$(create_test_conversation 6)
    local output
    output=$(run_half_clone "$session_id")

    local new_session
    new_session=$(get_new_session_from_output "$output")
    local new_file="${TEST_PROJECTS_DIR}/${TEST_PROJECT_DIRNAME}/${new_session}.jsonl"

    local first_line
    first_line=$(head -1 "$new_file")

    if echo "$first_line" | grep -q '"parentUuid":null'; then
        log_pass "First message has null parentUuid"
    else
        log_fail "First message does not have null parentUuid"
        echo "First line: $first_line"
    fi
}

# Test 6: [HALF-CLONE <timestamp>] tag is present
test_half_clone_tag() {
    log_test "[HALF-CLONE <timestamp>] tag should be in first user message"

    local session_id
    session_id=$(create_test_conversation 6)
    local output
    output=$(run_half_clone "$session_id")

    local new_session
    new_session=$(get_new_session_from_output "$output")
    local new_file="${TEST_PROJECTS_DIR}/${TEST_PROJECT_DIRNAME}/${new_session}.jsonl"

    # Match pattern like [HALF-CLONE Jan 7 14:30]
    if grep -qE '\[HALF-CLONE [A-Z][a-z]+ [0-9]+ [0-9]+:[0-9]+\]' "$new_file"; then
        log_pass "[HALF-CLONE <timestamp>] tag found"
    else
        log_fail "[HALF-CLONE <timestamp>] tag not found"
        cat "$new_file"
    fi
}

# Test 7: Session IDs are remapped
test_session_id_remapped() {
    log_test "Session IDs should be remapped to new ID"

    local session_id
    session_id=$(create_test_conversation 4)
    local output
    output=$(run_half_clone "$session_id")

    local new_session
    new_session=$(get_new_session_from_output "$output")
    local new_file="${TEST_PROJECTS_DIR}/${TEST_PROJECT_DIRNAME}/${new_session}.jsonl"

    # Check that old session ID is not in the new file
    if grep -q "\"sessionId\":\"${session_id}\"" "$new_file"; then
        log_fail "Old session ID still present"
    elif grep -q "\"sessionId\":\"${new_session}\"" "$new_file"; then
        log_pass "Session ID correctly remapped"
    else
        log_fail "New session ID not found"
    fi
}

# Test 8: History entry is added
test_history_entry() {
    log_test "History entry should be added"

    local session_id
    session_id=$(create_test_conversation 4)

    local history_before
    history_before=$(wc -l < "${TEST_CLAUDE_DIR}/history.jsonl" | tr -d ' ')

    run_half_clone "$session_id" > /dev/null

    local history_after
    history_after=$(wc -l < "${TEST_CLAUDE_DIR}/history.jsonl" | tr -d ' ')

    if [ "$history_after" -gt "$history_before" ]; then
        # Match pattern like [HALF-CLONE Jan 7 14:30]
        if grep -qE '\[HALF-CLONE [A-Z][a-z]+ [0-9]+ [0-9]+:[0-9]+\]' "${TEST_CLAUDE_DIR}/history.jsonl"; then
            log_pass "History entry added with [HALF-CLONE <timestamp>] tag"
        else
            log_fail "History entry added but missing [HALF-CLONE <timestamp>] tag"
        fi
    else
        log_fail "No history entry added"
    fi
}

# Test 9: Double tagging - half-clone a conversation that already has a tag
test_double_tagging() {
    log_test "Double tagging: half-cloning already-tagged conversation should have both tags"

    # Create a 6-message conversation where the THIRD user message (which will be
    # the first kept after half-clone) already has a tag. This simulates:
    # 1. A conversation that was previously half-cloned
    # 2. Then continued with more messages
    # 3. Now being half-cloned again
    local session_id
    session_id=$(uuidgen | tr '[:upper:]' '[:lower:]')
    local conv_file="${TEST_PROJECTS_DIR}/${TEST_PROJECT_DIRNAME}/${session_id}.jsonl"

    local uuid1 uuid2 uuid3 uuid4 uuid5 uuid6
    uuid1=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid2=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid3=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid4=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid5=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid6=$(uuidgen | tr '[:upper:]' '[:lower:]')

    # 6 messages = 3 user messages. Half-clone skips 1, keeps 2.
    # So messages 3-6 are kept, and message 3 (2nd user msg) becomes first.
    # Put the existing tag on message 3 (the 2nd user message).
    {
        echo "{\"parentUuid\":null,\"sessionId\":\"${session_id}\",\"type\":\"user\",\"message\":{\"role\":\"user\",\"content\":\"User message 1\"},\"uuid\":\"${uuid1}\",\"timestamp\":\"2025-01-01T00:00:00.000Z\"}"
        echo "{\"parentUuid\":\"${uuid1}\",\"sessionId\":\"${session_id}\",\"type\":\"assistant\",\"message\":{\"role\":\"assistant\",\"content\":[{\"type\":\"text\",\"text\":\"Response 1\"}]},\"uuid\":\"${uuid2}\",\"timestamp\":\"2025-01-01T00:00:00.000Z\"}"
        echo "{\"parentUuid\":\"${uuid2}\",\"sessionId\":\"${session_id}\",\"type\":\"user\",\"message\":{\"role\":\"user\",\"content\":\"[HALF-CLONE Jan 1 12:00] User message 2\"},\"uuid\":\"${uuid3}\",\"timestamp\":\"2025-01-01T00:00:00.000Z\"}"
        echo "{\"parentUuid\":\"${uuid3}\",\"sessionId\":\"${session_id}\",\"type\":\"assistant\",\"message\":{\"role\":\"assistant\",\"content\":[{\"type\":\"text\",\"text\":\"Response 2\"}]},\"uuid\":\"${uuid4}\",\"timestamp\":\"2025-01-01T00:00:00.000Z\"}"
        echo "{\"parentUuid\":\"${uuid4}\",\"sessionId\":\"${session_id}\",\"type\":\"user\",\"message\":{\"role\":\"user\",\"content\":\"User message 3\"},\"uuid\":\"${uuid5}\",\"timestamp\":\"2025-01-01T00:00:00.000Z\"}"
        echo "{\"parentUuid\":\"${uuid5}\",\"sessionId\":\"${session_id}\",\"type\":\"assistant\",\"message\":{\"role\":\"assistant\",\"content\":[{\"type\":\"text\",\"text\":\"Response 3\"}]},\"uuid\":\"${uuid6}\",\"timestamp\":\"2025-01-01T00:00:00.000Z\"}"
    } > "$conv_file"

    local output
    output=$(run_half_clone "$session_id")

    local new_session
    new_session=$(get_new_session_from_output "$output")
    local new_file="${TEST_PROJECTS_DIR}/${TEST_PROJECT_DIRNAME}/${new_session}.jsonl"

    # Should have two [HALF-CLONE ...] tags - the new one prepended to the existing one
    local first_user_line
    first_user_line=$(grep '"type":"user"' "$new_file" | head -1)

    # Count occurrences of [HALF-CLONE pattern
    local tag_count
    tag_count=$(echo "$first_user_line" | grep -oE '\[HALF-CLONE [A-Z][a-z]+ [0-9]+ [0-9]+:[0-9]+\]' | wc -l | tr -d ' ')

    if [ "$tag_count" -eq 2 ]; then
        log_pass "Double tagging works - found 2 [HALF-CLONE] tags"
    else
        log_fail "Expected 2 [HALF-CLONE] tags, found $tag_count"
        echo "First user line: $first_user_line"
    fi
}

# Test 10: Thinking blocks should be stripped from assistant messages
test_thinking_blocks_stripped() {
    log_test "Thinking blocks should be stripped from cloned conversation"

    # Create a conversation with thinking blocks in assistant messages
    local session_id
    session_id=$(uuidgen | tr '[:upper:]' '[:lower:]')
    local conv_file="${TEST_PROJECTS_DIR}/${TEST_PROJECT_DIRNAME}/${session_id}.jsonl"

    local uuid1 uuid2 uuid3 uuid4
    uuid1=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid2=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid3=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid4=$(uuidgen | tr '[:upper:]' '[:lower:]')

    {
        echo "{\"parentUuid\":null,\"sessionId\":\"${session_id}\",\"type\":\"user\",\"message\":{\"role\":\"user\",\"content\":\"First question\"},\"uuid\":\"${uuid1}\",\"timestamp\":\"2025-01-01T00:00:00.000Z\"}"
        echo "{\"parentUuid\":\"${uuid1}\",\"sessionId\":\"${session_id}\",\"type\":\"assistant\",\"message\":{\"role\":\"assistant\",\"content\":[{\"type\":\"thinking\",\"thinking\":\"Let me think about this...\"},{\"type\":\"text\",\"text\":\"Response 1\"}]},\"uuid\":\"${uuid2}\",\"timestamp\":\"2025-01-01T00:00:00.000Z\"}"
        echo "{\"parentUuid\":\"${uuid2}\",\"sessionId\":\"${session_id}\",\"type\":\"user\",\"message\":{\"role\":\"user\",\"content\":\"Second question\"},\"uuid\":\"${uuid3}\",\"timestamp\":\"2025-01-01T00:00:00.000Z\"}"
        echo "{\"parentUuid\":\"${uuid3}\",\"sessionId\":\"${session_id}\",\"type\":\"assistant\",\"message\":{\"role\":\"assistant\",\"content\":[{\"type\":\"thinking\",\"thinking\":\"Thinking again...\"},{\"type\":\"text\",\"text\":\"Response 2\"}]},\"uuid\":\"${uuid4}\",\"timestamp\":\"2025-01-01T00:00:00.000Z\"}"
    } > "$conv_file"

    local output
    output=$(run_half_clone "$session_id")

    local new_session
    new_session=$(get_new_session_from_output "$output")
    local new_file="${TEST_PROJECTS_DIR}/${TEST_PROJECT_DIRNAME}/${new_session}.jsonl"

    # Check that no thinking blocks remain
    local thinking_count
    thinking_count=$(grep -c '"type":"thinking"' "$new_file" 2>/dev/null || true)
    thinking_count=${thinking_count:-0}

    if [ "$thinking_count" -eq 0 ]; then
        # Also verify text blocks are preserved
        if grep -q '"type":"text"' "$new_file"; then
            log_pass "Thinking blocks stripped, text blocks preserved"
        else
            log_fail "Thinking blocks stripped but text blocks also missing"
        fi
    else
        log_fail "Found $thinking_count thinking blocks (expected 0)"
    fi
}

# Helper: generate an isMeta user message (skill expansion)
generate_meta_message() {
    local uuid="$1"
    local parent_uuid="$2"
    local session_id="$3"
    local content="$4"

    local parent_field
    if [ "$parent_uuid" = "null" ]; then
        parent_field='"parentUuid":null'
    else
        parent_field="\"parentUuid\":\"${parent_uuid}\""
    fi

    echo "{${parent_field},\"sessionId\":\"${session_id}\",\"type\":\"user\",\"isMeta\":true,\"message\":{\"role\":\"user\",\"content\":[{\"type\":\"text\",\"text\":\"${content}\"}]},\"uuid\":\"${uuid}\",\"timestamp\":\"2025-01-01T00:00:00.000Z\"}"
}

# Helper: generate a tool_result user message
generate_tool_result_message() {
    local uuid="$1"
    local parent_uuid="$2"
    local session_id="$3"
    local tool_use_id="$4"

    echo "{\"parentUuid\":\"${parent_uuid}\",\"sessionId\":\"${session_id}\",\"type\":\"user\",\"message\":{\"role\":\"user\",\"content\":[{\"type\":\"tool_result\",\"tool_use_id\":\"${tool_use_id}\",\"content\":\"result data\"}]},\"uuid\":\"${uuid}\",\"timestamp\":\"2025-01-01T00:00:00.000Z\"}"
}

# Test 11: isMeta messages should NOT count as clean user messages
# if isMeta messages count toward total, the halfway point lands on the wrong message
test_ismeta_not_counted() {
    log_test "isMeta:true skill expansions should NOT count as clean user messages"

    local session_id
    session_id=$(uuidgen | tr '[:upper:]' '[:lower:]')
    local conv_file="${TEST_PROJECTS_DIR}/${TEST_PROJECT_DIRNAME}/${session_id}.jsonl"

    local uuid1 uuid2 uuid3 uuid4 uuid5 uuid6 uuid7 uuid8
    uuid1=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid2=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid3=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid4=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid5=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid6=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid7=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid8=$(uuidgen | tr '[:upper:]' '[:lower:]')

    # Conversation: user, isMeta-skill, assistant, user, assistant, user, assistant, user
    # Real user messages: uuid1 (Q1), uuid4 (Q2), uuid6 (Q3), uuid8 (Q4) = 4 genuine
    # isMeta: uuid2 (skill expansion) = phantom, should NOT count
    # If isMeta counted: 5 "clean" msgs, skip 2, start at msg 3 (uuid4)
    # If isMeta filtered: 4 clean msgs, skip 2, start at msg 3 (uuid6)
    {
        generate_message "$uuid1" "null" "$session_id" "user" "Question 1"
        generate_meta_message "$uuid2" "$uuid1" "$session_id" "Skill expansion text injected by CC"
        generate_message "$uuid3" "$uuid2" "$session_id" "assistant" "Answer to question 1"
        generate_message "$uuid4" "$uuid3" "$session_id" "user" "Question 2"
        generate_message "$uuid5" "$uuid4" "$session_id" "assistant" "Answer to question 2"
        generate_message "$uuid6" "$uuid5" "$session_id" "user" "Question 3 THE CORRECT START"
        generate_message "$uuid7" "$uuid6" "$session_id" "assistant" "Answer to question 3"
        generate_message "$uuid8" "$uuid7" "$session_id" "user" "Question 4"
    } > "$conv_file"

    local output
    output=$(run_half_clone "$session_id")

    local new_session
    new_session=$(get_new_session_from_output "$output")
    local new_file="${TEST_PROJECTS_DIR}/${TEST_PROJECT_DIRNAME}/${new_session}.jsonl"

    # Skip the synthetic "Continued from session" marker - check the SECOND user message
    local first_real_user
    first_real_user=$(grep '"type":"user"' "$new_file" | grep -v "Continued from session" | head -1)

    if echo "$first_real_user" | grep -q "THE CORRECT START"; then
        log_pass "Clone starts at correct genuine user message (Q3), isMeta filtered"
    elif echo "$first_real_user" | grep -q "Question 2"; then
        log_fail "Clone starts at Q2 - isMeta message was counted as clean (bug)"
    else
        log_fail "Unexpected first user message: $(echo "$first_real_user" | head -c 150)"
    fi
}

# Test 12: [Request interrupted by user] at the halfway point shifts the start
# Unpatched: 5 clean (Q1, Q2, interrupted, Q3, Q4), skip 2 -> 3rd = interrupted msg
# Patched:   4 clean (Q1, Q2, Q3, Q4), skip 2 -> 3rd = Q3
test_interrupted_not_counted() {
    log_test "[Request interrupted by user] should NOT count - clone must start at Q3 not interrupted"

    local session_id
    session_id=$(uuidgen | tr '[:upper:]' '[:lower:]')
    local conv_file="${TEST_PROJECTS_DIR}/${TEST_PROJECT_DIRNAME}/${session_id}.jsonl"

    local uuid1 uuid2 uuid3 uuid4 uuid5 uuid6 uuid7 uuid8 uuid9
    uuid1=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid2=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid3=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid4=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid5=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid6=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid7=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid8=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid9=$(uuidgen | tr '[:upper:]' '[:lower:]')

    # Q1, A1, Q2, A2, [interrupted], Q3 CORRECT, A3, Q4, A4
    # Unpatched: Q1(1), Q2(2), interrupted(3=start!), Q3, Q4 = 5 clean, skip 2
    # Patched:   Q1(1), Q2(2), Q3(3=start!), Q4 = 4 clean, skip 2
    {
        generate_message "$uuid1" "null" "$session_id" "user" "Question 1"
        generate_message "$uuid2" "$uuid1" "$session_id" "assistant" "Answer 1"
        generate_message "$uuid3" "$uuid2" "$session_id" "user" "Question 2"
        generate_message "$uuid4" "$uuid3" "$session_id" "assistant" "Partial answer 2"
        echo "{\"parentUuid\":\"${uuid4}\",\"sessionId\":\"${session_id}\",\"type\":\"user\",\"message\":{\"role\":\"user\",\"content\":[{\"type\":\"text\",\"text\":\"[Request interrupted by user]\"}]},\"uuid\":\"${uuid5}\",\"timestamp\":\"2025-01-01T00:00:00.000Z\"}"
        generate_message "$uuid6" "$uuid5" "$session_id" "user" "Question 3 CORRECT START"
        generate_message "$uuid7" "$uuid6" "$session_id" "assistant" "Answer 3"
        generate_message "$uuid8" "$uuid7" "$session_id" "user" "Question 4"
        generate_message "$uuid9" "$uuid8" "$session_id" "assistant" "Answer 4"
    } > "$conv_file"

    local output
    output=$(run_half_clone "$session_id")

    local new_session
    new_session=$(get_new_session_from_output "$output")
    local new_file="${TEST_PROJECTS_DIR}/${TEST_PROJECT_DIRNAME}/${new_session}.jsonl"

    # Skip synthetic marker, check first real user message
    local first_real_user
    first_real_user=$(grep '"type":"user"' "$new_file" | grep -v "Continued from session" | head -1)

    if echo "$first_real_user" | grep -q "CORRECT START"; then
        log_pass "Clone starts at Q3 (correct), interrupted not counted"
    elif echo "$first_real_user" | grep -q "Request interrupted by user"; then
        log_fail "Clone starts at [Request interrupted] - it was counted as clean (bug)"
    else
        log_fail "Unexpected first user: $(echo "$first_real_user" | head -c 150)"
    fi
}

# Test 13: isMeta inflation causes halfway to land on a half-clone command
# Unpatched: Q1, isMeta1, Q2, /half-clone, isMeta2, Q3 = 6 clean, skip 3 -> 4th = /half-clone
# Patched:   Q1, Q2, /half-clone, Q3 = 4 clean, skip 2 -> 3rd = /half-clone (but stop_at_line catches last)
# Actually need the clone cmd in the MIDDLE not at end. Let's add Q4 after.
test_clone_cmd_not_starting_point() {
    log_test "isMeta inflation should NOT cause clone to start at /half-clone command"

    local session_id
    session_id=$(uuidgen | tr '[:upper:]' '[:lower:]')
    local conv_file="${TEST_PROJECTS_DIR}/${TEST_PROJECT_DIRNAME}/${session_id}.jsonl"

    local uuid1 uuid2 uuid3 uuid4 uuid5 uuid6 uuid7 uuid8 uuid9 uuid10 uuid11 uuid12
    uuid1=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid2=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid3=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid4=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid5=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid6=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid7=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid8=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid9=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid10=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid11=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid12=$(uuidgen | tr '[:upper:]' '[:lower:]')

    # Q1, A1, isMeta1, Q2, A2, /half-clone(mid), isMeta2, A3, Q3 CORRECT, A3, Q4, A4
    # Unpatched: 6 clean (Q1, isMeta1, Q2, /half-clone, isMeta2, Q3, Q4... wait)
    # Let me be precise. Unpatched counts: Q1, isMeta1, Q2, /half-clone, isMeta2, Q3, Q4 = 7
    # skip 3, start at 4th = /half-clone command!
    # Patched: Q1, Q2, /half-clone, Q3, Q4 = 5 genuine, skip 2, start at 3rd = /half-clone
    # Hmm, still lands on /half-clone. I need the structure so patched skips past it.
    # Better: just test that the tag goes on a genuine message, not a phantom.
    # Or: make the isMeta messages shift past the clone command.
    #
    # Simplest: Q1, A1, isMeta1, isMeta2, Q2, A2, Q3 CORRECT, A3, Q4, A4
    # Unpatched: 6 clean (Q1, isMeta1, isMeta2, Q2, Q3, Q4), skip 3, 4th = Q2
    # Patched:   4 clean (Q1, Q2, Q3, Q4), skip 2, 3rd = Q3
    # Q2 vs Q3 - that's a testable difference!
    {
        generate_message "$uuid1" "null" "$session_id" "user" "Question 1"
        generate_message "$uuid2" "$uuid1" "$session_id" "assistant" "Answer 1"
        generate_meta_message "$uuid3" "$uuid2" "$session_id" "Skill expansion one"
        generate_meta_message "$uuid4" "$uuid3" "$session_id" "Skill expansion two"
        generate_message "$uuid5" "$uuid4" "$session_id" "user" "Question 2 WRONG if isMeta counted"
        generate_message "$uuid6" "$uuid5" "$session_id" "assistant" "Answer 2"
        generate_message "$uuid7" "$uuid6" "$session_id" "user" "Question 3 CORRECT START"
        generate_message "$uuid8" "$uuid7" "$session_id" "assistant" "Answer 3"
        generate_message "$uuid9" "$uuid8" "$session_id" "user" "Question 4"
        generate_message "$uuid10" "$uuid9" "$session_id" "assistant" "Answer 4"
    } > "$conv_file"

    local output
    output=$(run_half_clone "$session_id")

    local new_session
    new_session=$(get_new_session_from_output "$output")
    local new_file="${TEST_PROJECTS_DIR}/${TEST_PROJECT_DIRNAME}/${new_session}.jsonl"

    local first_user_content
    first_user_content=$(grep '"type":"user"' "$new_file" | grep -v '"isMeta"' | grep -v "Continued from session" | head -1)

    if echo "$first_user_content" | grep -q "CORRECT START"; then
        log_pass "Clone starts at Q3 (correct), isMeta not counted"
    elif echo "$first_user_content" | grep -q "WRONG if isMeta counted"; then
        log_fail "Clone starts at Q2 - isMeta inflated the count (bug)"
    else
        log_fail "Unexpected first user: $(echo "$first_user_content" | head -c 150)"
    fi
}

# Test 14: HALF-CLONE tag should go on genuine user message, not isMeta
test_tag_on_genuine_not_meta() {
    log_test "[HALF-CLONE] tag should be on genuine user message, not isMeta"

    local session_id
    session_id=$(uuidgen | tr '[:upper:]' '[:lower:]')
    local conv_file="${TEST_PROJECTS_DIR}/${TEST_PROJECT_DIRNAME}/${session_id}.jsonl"

    local uuid1 uuid2 uuid3 uuid4 uuid5 uuid6 uuid7 uuid8
    uuid1=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid2=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid3=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid4=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid5=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid6=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid7=$(uuidgen | tr '[:upper:]' '[:lower:]')
    uuid8=$(uuidgen | tr '[:upper:]' '[:lower:]')

    # Q1, A1, Q2, A2, isMeta (skill), Q3 CORRECT TAG, A3, Q4
    # Unpatched: 4 clean (Q1, Q2, isMeta, Q3, Q4=5... no)
    # Unpatched counts: Q1, Q2, isMeta, Q3, Q4 = 5, skip 2, 3rd = isMeta
    # -> clone starts at isMeta line, tag goes on isMeta (BUG)
    # Patched: Q1, Q2, Q3, Q4 = 4, skip 2, 3rd = Q3
    # -> clone starts at Q3, tag goes on Q3 (CORRECT)
    {
        generate_message "$uuid1" "null" "$session_id" "user" "Question 1"
        generate_message "$uuid2" "$uuid1" "$session_id" "assistant" "Answer 1"
        generate_message "$uuid3" "$uuid2" "$session_id" "user" "Question 2"
        generate_message "$uuid4" "$uuid3" "$session_id" "assistant" "Answer 2"
        generate_meta_message "$uuid5" "$uuid4" "$session_id" "Skill expansion SHOULD NOT HAVE TAG"
        generate_message "$uuid6" "$uuid5" "$session_id" "user" "Question 3 CORRECT TAG"
        generate_message "$uuid7" "$uuid6" "$session_id" "assistant" "Answer 3"
        generate_message "$uuid8" "$uuid7" "$session_id" "user" "Question 4"
    } > "$conv_file"

    local output
    output=$(run_half_clone "$session_id")

    local new_session
    new_session=$(get_new_session_from_output "$output")
    local new_file="${TEST_PROJECTS_DIR}/${TEST_PROJECT_DIRNAME}/${new_session}.jsonl"

    # Check the first genuine user content (skip synthetic marker)
    local first_user_content
    first_user_content=$(grep '"type":"user"' "$new_file" | grep -v "Continued from session" | head -1)

    if echo "$first_user_content" | grep -q "CORRECT TAG"; then
        log_pass "[HALF-CLONE] tag correctly placed on genuine Q3"
    elif echo "$first_user_content" | grep -q "SHOULD NOT HAVE TAG"; then
        log_fail "Clone starts at isMeta - tag on phantom message (bug)"
    elif echo "$first_user_content" | grep -q "Question 2"; then
        log_fail "Clone starts at Q2 - wrong split point"
    else
        log_fail "Unexpected first user: $(echo "$first_user_content" | head -c 200)"
    fi
}

# Main
main() {
    echo "================================"
    echo "Half-Clone Conversation Tests"
    echo "================================"
    echo ""

    if [ ! -f "$HALF_CLONE_SCRIPT" ]; then
        echo "Error: half-clone-conversation.sh not found at $HALF_CLONE_SCRIPT"
        exit 1
    fi

    setup_test_env
    trap cleanup_test_env EXIT

    test_even_messages
    test_odd_messages
    test_minimum_messages
    test_single_message_error
    test_parent_uuid_nullified
    test_half_clone_tag
    test_session_id_remapped
    test_history_entry
    test_double_tagging
    test_thinking_blocks_stripped
    test_ismeta_not_counted
    test_interrupted_not_counted
    test_clone_cmd_not_starting_point
    test_tag_on_genuine_not_meta

    echo ""
    echo "================================"
    echo "Results: $TESTS_PASSED/$TESTS_RUN passed"
    if [ "$TESTS_FAILED" -gt 0 ]; then
        echo -e "${RED}$TESTS_FAILED tests failed${NC}"
        exit 1
    else
        echo -e "${GREEN}All tests passed!${NC}"
    fi
}

main "$@"
