#!/bin/bash
# Hook: SessionStart — Restores persistent memory at session start
# This hook is triggered when a new Claude Code session begins

set -e

MEMORY_DIR=".claude/memory"
MEMORY_FILE="$MEMORY_DIR/MEMORY.md"
SESSION_HISTORY="$MEMORY_DIR/session-history.md"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
DATE_TODAY=$(date +"%Y-%m-%d")

# Get git branch if available
BRANCH="unknown"
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
fi

# Check if memory exists
if [ ! -f "$MEMORY_FILE" ]; then
    echo "[Forge] No previous memory found. Starting fresh session."
    exit 0
fi

# Read current session number and increment
CURRENT_SESSION=$(grep -oP '(?<=\*\*Session\*\*: #)\d+' "$MEMORY_FILE" 2>/dev/null || echo "0")
NEW_SESSION=$((CURRENT_SESSION + 1))

# Extract key info from MEMORY.md
LAST_CONTEXT=$(grep -oP '(?<=\*\*Context\*\*: ).*' "$MEMORY_FILE" 2>/dev/null | head -1 || echo "unknown")
LAST_ACTION=$(grep -oP '(?<=\*\*Last Action\*\*: ).*' "$MEMORY_FILE" 2>/dev/null | head -1 || echo "unknown")

# Count active decisions (lines starting with numbers in Decisions section)
ACTIVE_DECISIONS=$(sed -n '/## Active Decisions/,/## /p' "$MEMORY_FILE" 2>/dev/null | grep -c '^\s*[0-9]' 2>/dev/null) || ACTIVE_DECISIONS=0

# Count pending tasks
PENDING_TASKS=$(grep -c '\- \[ \]' "$MEMORY_FILE" 2>/dev/null) || PENDING_TASKS=0
COMPLETED_TASKS=$(grep -c '\- \[x\]' "$MEMORY_FILE" 2>/dev/null) || COMPLETED_TASKS=0

# Update session number in MEMORY.md
sed -i "s/\*\*Session\*\*: #[0-9]*/\*\*Session\*\*: #$NEW_SESSION/" "$MEMORY_FILE"
sed -i "s/([0-9-]*)/($DATE_TODAY)/" "$MEMORY_FILE"

# Update branch in MEMORY.md
sed -i "s/\*\*Branch\*\*: .*/\*\*Branch\*\*: $BRANCH/" "$MEMORY_FILE"

# Log session start
if [ -f "$SESSION_HISTORY" ]; then
    echo "| $TIMESTAMP | #$NEW_SESSION | SessionStart | Restored from session #$CURRENT_SESSION |" >> "$SESSION_HISTORY"
fi

# Output context for Claude to see
cat << EOF
[Forge Memory Restored]
Session #$NEW_SESSION starting on $BRANCH

Previous context: $LAST_CONTEXT
Last action: $LAST_ACTION
Active decisions: $ACTIVE_DECISIONS
Tasks: $PENDING_TASKS pending, $COMPLETED_TASKS completed

Use /forge:status for full memory details or /forge:memory to edit.
EOF
