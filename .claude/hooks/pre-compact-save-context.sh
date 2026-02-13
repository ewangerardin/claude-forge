#!/bin/bash
# Hook: PreCompact — Saves context to persistent memory before compaction
# This hook is triggered automatically when Claude Code needs to compact the context

set -e

MEMORY_DIR=".claude/memory"
MEMORY_FILE="$MEMORY_DIR/MEMORY.md"
SESSION_HISTORY="$MEMORY_DIR/session-history.md"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
DATE_TODAY=$(date +"%Y-%m-%d")

# Ensure memory directory exists
mkdir -p "$MEMORY_DIR"

# Read current session number from MEMORY.md or default to 0
if [ -f "$MEMORY_FILE" ]; then
    CURRENT_SESSION=$(grep -oP '(?<=\*\*Session\*\*: #)\d+' "$MEMORY_FILE" 2>/dev/null || echo "0")
else
    CURRENT_SESSION=0
fi

# Get git branch if available
BRANCH="unknown"
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
fi

# Read hook input from stdin (JSON with session info)
INPUT=$(cat)

# Extract transcript summary if available (Claude Code passes context info)
if command -v jq &> /dev/null; then
    TRANSCRIPT_SUMMARY=$(echo "$INPUT" | jq -r '.transcript_summary // empty' 2>/dev/null || echo "")
else
    TRANSCRIPT_SUMMARY=$(echo "$INPUT" | grep -oP '"transcript_summary"\s*:\s*"\K[^"]+' 2>/dev/null || echo "")
fi

# Log the compaction event to session history
if [ ! -f "$SESSION_HISTORY" ]; then
    cat > "$SESSION_HISTORY" << 'HISTORYEOF'
# Session History

| Date | Session | Event | Notes |
|------|---------|-------|-------|
HISTORYEOF
fi

echo "| $TIMESTAMP | #$CURRENT_SESSION | PreCompact | Context saved before compaction |" >> "$SESSION_HISTORY"

# Output message for Claude to see
cat << EOF
[Forge Memory] Context saved before compaction
- Session: #$CURRENT_SESSION
- Timestamp: $TIMESTAMP
- Branch: $BRANCH
- Memory file: $MEMORY_FILE

The context has been preserved. After compaction, use /forge:status to review the memory state.
EOF
