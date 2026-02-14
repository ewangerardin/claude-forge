#!/bin/bash
# Hook: PreCompact (command) — Prepares environment for cognitive memory flush
# Runs BEFORE the prompt-based flush so Claude has stats available

MEMORY_DIR=".claude/memory"
DAILY_DIR="$MEMORY_DIR/daily"
TODAY=$(date +%Y-%m-%d)

# Create directories
mkdir -p "$DAILY_DIR"

# Create today's daily log if it doesn't exist
if [ ! -f "$DAILY_DIR/$TODAY.md" ]; then
  echo "# Daily Log — $TODAY" > "$DAILY_DIR/$TODAY.md"
  echo "" >> "$DAILY_DIR/$TODAY.md"
fi

# Helper: count lines in a file (0 if missing)
count_lines() { if [ -f "$1" ]; then wc -l < "$1"; else echo "0"; fi; }

# Output stats for Claude's context
echo "=== PRE-COMPACT STATS ==="
echo "MEMORY.md : $(count_lines "$MEMORY_DIR/MEMORY.md") lignes"
echo "Daily log ($TODAY) : $(count_lines "$DAILY_DIR/$TODAY.md") lignes"
echo "Decisions : $(count_lines "$MEMORY_DIR/decisions.md") lignes"
echo "Errors : $(count_lines "$MEMORY_DIR/errors.md") lignes"
echo "Patterns : $(count_lines "$MEMORY_DIR/patterns.md") lignes"
echo "Open tasks : $(grep -c '^\- \[ \]' "$MEMORY_DIR/MEMORY.md" 2>/dev/null || echo '0')"
echo "========================="
