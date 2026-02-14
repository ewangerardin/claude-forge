#!/bin/bash
# Hook: Stop — Finalizes session and cleans up old daily logs

MEMORY_DIR=".claude/memory"
SESSION_FILE="$MEMORY_DIR/session-history.md"

# Log session end
if [ -f "$SESSION_FILE" ]; then
  echo "- End: $(date '+%H:%M:%S')" >> "$SESSION_FILE"
fi

# Check memory health
if [ -f "$MEMORY_DIR/MEMORY.md" ]; then
  LINES=$(wc -l < "$MEMORY_DIR/MEMORY.md")
  if [ "$LINES" -gt 200 ]; then
    echo "WARNING: MEMORY.md has $LINES lines (recommended max: 200). Consolidate next session."
  fi
fi

# Clean up daily logs older than 30 days
DAILY_DIR="$MEMORY_DIR/daily"
if [ -d "$DAILY_DIR" ]; then
  OLD_COUNT=$(find "$DAILY_DIR" -name "*.md" -mtime +30 2>/dev/null | wc -l)
  if [ "$OLD_COUNT" -gt 0 ]; then
    find "$DAILY_DIR" -name "*.md" -mtime +30 -delete 2>/dev/null
    echo "Cleaned $OLD_COUNT daily logs older than 30 days."
  fi
fi
