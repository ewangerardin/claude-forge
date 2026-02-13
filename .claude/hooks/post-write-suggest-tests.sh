#!/bin/bash
# Hook: PostToolUse(Write) — Suggests tests for newly written code
# Triggers on code file writes to remind about test coverage

# Read the hook input from stdin
INPUT=$(cat)

# Extract file_path from JSON
if command -v jq &> /dev/null; then
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)
else
    FILE_PATH=$(echo "$INPUT" | grep -oP '"file_path"\s*:\s*"\K[^"]+' 2>/dev/null || echo "")
    if [ -z "$FILE_PATH" ]; then
        FILE_PATH=$(echo "$INPUT" | grep -oP '"path"\s*:\s*"\K[^"]+' 2>/dev/null || echo "")
    fi
fi

# Exit if no file path found
if [ -z "$FILE_PATH" ] || [ "$FILE_PATH" = "null" ]; then
    exit 0
fi

# Only suggest tests for code files
case "$FILE_PATH" in
    *.test.ts|*.test.js|*.spec.ts|*.spec.js|*_test.go|*_test.py|*.test.py)
        # Already a test file, skip
        exit 0
        ;;
    *.ts|*.tsx|*.js|*.jsx)
        TEST_EXT=".test.ts"
        TEST_FRAMEWORK="Jest/Vitest"
        ;;
    *.py)
        TEST_EXT="_test.py"
        TEST_FRAMEWORK="Pytest"
        ;;
    *.go)
        TEST_EXT="_test.go"
        TEST_FRAMEWORK="Go test"
        ;;
    *.rs)
        TEST_EXT="" # Rust tests are inline
        TEST_FRAMEWORK="Cargo test"
        ;;
    *)
        # Not a code file we track
        exit 0
        ;;
esac

# Derive test file path
BASENAME=$(basename "$FILE_PATH")
DIRNAME=$(dirname "$FILE_PATH")
NAME_WITHOUT_EXT="${BASENAME%.*}"

if [ -n "$TEST_EXT" ]; then
    TEST_FILE="$DIRNAME/$NAME_WITHOUT_EXT$TEST_EXT"
else
    TEST_FILE="(inline in $FILE_PATH)"
fi

# Check if test file exists
if [ -n "$TEST_EXT" ] && [ -f "$TEST_FILE" ]; then
    echo "[Forge Tests] Test file exists: $TEST_FILE"
else
    cat << EOF
[Forge Tests] Consider adding tests for: $FILE_PATH

Suggested test file: $TEST_FILE
Framework: $TEST_FRAMEWORK

Quick test template:
  - Test happy path
  - Test error cases
  - Test edge cases

Use /forge:review --full for test coverage analysis.
EOF
fi
