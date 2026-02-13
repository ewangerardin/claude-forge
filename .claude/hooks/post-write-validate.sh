#!/bin/bash
# Hook: PostToolUse(Write|Edit) — Validates written files
# Runs linting and formatting checks after file modifications

# Read the hook input from stdin
INPUT=$(cat)

# Extract file_path from JSON (works without jq)
if command -v jq &> /dev/null; then
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)
else
    # Fallback: extract file_path using grep
    FILE_PATH=$(echo "$INPUT" | grep -oP '"file_path"\s*:\s*"\K[^"]+' 2>/dev/null || echo "")
    if [ -z "$FILE_PATH" ]; then
        FILE_PATH=$(echo "$INPUT" | grep -oP '"path"\s*:\s*"\K[^"]+' 2>/dev/null || echo "")
    fi
fi

# Exit if no file path found
if [ -z "$FILE_PATH" ] || [ "$FILE_PATH" = "null" ]; then
    exit 0
fi

# Skip non-code files
case "$FILE_PATH" in
    *.md|*.txt|*.json|*.yaml|*.yml|*.toml|*.lock|*.log)
        exit 0
        ;;
esac

# Determine file type and run appropriate linter
EXTENSION="${FILE_PATH##*.}"
ERRORS=""

case "$EXTENSION" in
    ts|tsx)
        if command -v npx &> /dev/null && [ -f "node_modules/.bin/eslint" ]; then
            LINT_OUTPUT=$(npx eslint "$FILE_PATH" 2>&1) || ERRORS="$LINT_OUTPUT"
        elif command -v npx &> /dev/null && [ -f "node_modules/.bin/tsc" ]; then
            LINT_OUTPUT=$(npx tsc --noEmit "$FILE_PATH" 2>&1) || ERRORS="$LINT_OUTPUT"
        fi
        ;;
    js|jsx)
        if command -v npx &> /dev/null && [ -f "node_modules/.bin/eslint" ]; then
            LINT_OUTPUT=$(npx eslint "$FILE_PATH" 2>&1) || ERRORS="$LINT_OUTPUT"
        fi
        ;;
    py)
        if command -v ruff &> /dev/null; then
            LINT_OUTPUT=$(ruff check "$FILE_PATH" 2>&1) || ERRORS="$LINT_OUTPUT"
        elif command -v flake8 &> /dev/null; then
            LINT_OUTPUT=$(flake8 "$FILE_PATH" 2>&1) || ERRORS="$LINT_OUTPUT"
        elif command -v pylint &> /dev/null; then
            LINT_OUTPUT=$(pylint --errors-only "$FILE_PATH" 2>&1) || ERRORS="$LINT_OUTPUT"
        fi
        ;;
    go)
        if command -v go &> /dev/null; then
            LINT_OUTPUT=$(go vet "$FILE_PATH" 2>&1) || ERRORS="$LINT_OUTPUT"
        fi
        ;;
    rs)
        if command -v cargo &> /dev/null; then
            # For Rust, we check the whole project
            LINT_OUTPUT=$(cargo check --message-format=short 2>&1) || ERRORS="$LINT_OUTPUT"
        fi
        ;;
    sh|bash)
        if command -v shellcheck &> /dev/null; then
            LINT_OUTPUT=$(shellcheck "$FILE_PATH" 2>&1) || ERRORS="$LINT_OUTPUT"
        fi
        ;;
esac

# Output results
if [ -n "$ERRORS" ]; then
    cat << EOF
[Forge Quality] Validation issues found in $FILE_PATH:
$ERRORS

Please review and fix these issues.
EOF
else
    echo "[Forge Quality] $FILE_PATH validated successfully"
fi
