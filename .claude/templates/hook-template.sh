#!/bin/bash
# Hook: {HookType}({Matcher}) — {Brief description}
# Trigger: {When this hook runs}
# Purpose: {What this hook accomplishes}

# Read the hook input from stdin (JSON format)
INPUT=$(cat)

# Extract relevant fields from JSON
# Works with or without jq installed
if command -v jq &> /dev/null; then
    # Using jq (preferred)
    FIELD=$(echo "$INPUT" | jq -r '.tool_input.field_name // empty' 2>/dev/null)
else
    # Fallback: using grep/sed
    FIELD=$(echo "$INPUT" | grep -oP '"field_name"\s*:\s*"\K[^"]+' 2>/dev/null || echo "")
fi

# Exit early if required field is missing
if [ -z "$FIELD" ] || [ "$FIELD" = "null" ]; then
    exit 0
fi

# ============================================
# HOOK LOGIC GOES HERE
# ============================================

# Example: Check a condition
if [ "$SOME_CONDITION" = "true" ]; then
    # Output to block (for PreToolUse hooks)
    # echo '{"decision": "block", "reason": "Reason for blocking"}'

    # Or output informational message
    echo "[Forge] Hook message here"
fi

# ============================================
# OUTPUT OPTIONS
# ============================================

# For PreToolUse hooks - to BLOCK:
# echo '{"decision": "block", "reason": "Why it was blocked"}'
# exit 0

# For PreToolUse hooks - to ALLOW (default):
# exit 0

# For PostToolUse hooks - informational output:
# echo "[Forge] Information for the user"
# exit 0

# For error conditions:
# echo "[Forge Error] Description of error" >&2
# exit 1
