#!/bin/bash
# Hook: SessionStart — Restores full context at session start
# Pattern: Hot context (MEMORY.md) + Warm context (J+J-1 daily logs) + Heartbeat

MEMORY_DIR=".claude/memory"
DAILY_DIR="$MEMORY_DIR/daily"
TODAY=$(date +%Y-%m-%d)

# Yesterday's date (compatible Linux and macOS)
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d 2>/dev/null || date -v-1d +%Y-%m-%d 2>/dev/null || echo "")

# Create directories
mkdir -p "$DAILY_DIR"

# --- Session counter ---
SESSION_FILE="$MEMORY_DIR/session-history.md"
if [ -f "$SESSION_FILE" ]; then
  # Extract highest session number from any format (## Session #N or | #N |)
  LAST_SESSION=$(grep -oP '#\K[0-9]+' "$SESSION_FILE" 2>/dev/null | sort -n | tail -1)
  LAST_SESSION=${LAST_SESSION:-0}
  CURRENT_SESSION=$((LAST_SESSION + 1))
else
  CURRENT_SESSION=1
  echo "# Session History" > "$SESSION_FILE"
fi

# Log session start
echo "" >> "$SESSION_FILE"
echo "## Session #$CURRENT_SESSION — $(date '+%Y-%m-%d %H:%M')" >> "$SESSION_FILE"
echo "- Start: $(date '+%H:%M:%S')" >> "$SESSION_FILE"

# Get git branch
BRANCH="unknown"
if git rev-parse --git-dir > /dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
fi

echo "=== Forge Session #$CURRENT_SESSION on $BRANCH ==="
echo ""

# --- HOT CONTEXT --- MEMORY.md (durable facts)
if [ -f "$MEMORY_DIR/MEMORY.md" ]; then
  MEMORY_LINES=$(wc -l < "$MEMORY_DIR/MEMORY.md")
  echo "MEMORY.md ($MEMORY_LINES lines):"
  cat "$MEMORY_DIR/MEMORY.md"
  echo ""
  if [ "$MEMORY_LINES" -gt 200 ]; then
    echo "WARNING: MEMORY.md exceeds 200 lines — consolidate obsolete info."
    echo ""
  fi
else
  echo "No MEMORY.md found. Fresh project."
  echo ""
fi

# --- WARM CONTEXT --- Daily logs J + J-1
if [ -f "$DAILY_DIR/$TODAY.md" ]; then
  echo "Today ($TODAY):"
  cat "$DAILY_DIR/$TODAY.md"
  echo ""
fi

if [ -n "$YESTERDAY" ] && [ -f "$DAILY_DIR/$YESTERDAY.md" ]; then
  echo "Yesterday ($YESTERDAY) — last 30 lines:"
  tail -30 "$DAILY_DIR/$YESTERDAY.md"
  echo ""
fi

# --- HEARTBEAT --- Project checklist
if [ -f "$MEMORY_DIR/HEARTBEAT.md" ]; then
  echo "HEARTBEAT — Project state:"
  cat "$MEMORY_DIR/HEARTBEAT.md"
  echo ""
fi

# --- STATS ---
count_lines() { if [ -f "$1" ]; then wc -l < "$1"; else echo "0"; fi; }

echo "Memory stats:"
echo "  - Decisions: $(count_lines "$MEMORY_DIR/decisions.md") lines"
echo "  - Errors: $(count_lines "$MEMORY_DIR/errors.md") lines"
echo "  - Patterns: $(count_lines "$MEMORY_DIR/patterns.md") lines"
DAILY_COUNT=$(ls -1 "$DAILY_DIR"/*.md 2>/dev/null | wc -l)
echo "  - Daily logs: $DAILY_COUNT days"
echo ""

echo "Use /forge:status for full details or /forge:memory to edit."
echo "=== END CONTEXT RESTORE ==="
