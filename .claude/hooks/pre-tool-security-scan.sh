#!/bin/bash
# Hook: PreToolUse(Bash) — Security scan before command execution
# Blocks potentially dangerous commands

# Read the hook input from stdin
INPUT=$(cat)

# Extract command from JSON (works without jq)
# Try jq first, fallback to grep/sed
if command -v jq &> /dev/null; then
    COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
else
    # Fallback: extract command using grep/sed
    COMMAND=$(echo "$INPUT" | grep -oP '"command"\s*:\s*"\K[^"]+' 2>/dev/null || echo "")
fi

# Exit if no command found
if [ -z "$COMMAND" ]; then
    exit 0
fi

# Dangerous patterns to block
DANGEROUS_PATTERNS=(
    # Destructive file operations
    "rm -rf /"
    "rm -rf /*"
    "rm -rf ~"
    "rm -rf \$HOME"
    "> /dev/sda"
    "mkfs\."
    "dd if=.* of=/dev/"

    # Fork bombs
    ":(){ :|:& };:"

    # Credential/sensitive file access
    "cat.*\.env"
    "cat.*/etc/shadow"
    "cat.*/etc/passwd"

    # Network exfiltration patterns
    "curl.*\| *sh"
    "wget.*\| *sh"
    "curl.*\| *bash"
    "wget.*\| *bash"

    # Privilege escalation
    "chmod 777 /"
    "chmod -R 777 /"
    "chown -R.*/"

    # Git destructive operations without explicit intent
    "git push.*--force.*main"
    "git push.*--force.*master"
    "git reset --hard origin"
    "git clean -fdx /"
)

# Warning patterns (allow but warn)
WARNING_PATTERNS=(
    "rm -rf"
    "git push --force"
    "git reset --hard"
    "chmod -R"
    "sudo"
    "DROP TABLE"
    "DROP DATABASE"
    "TRUNCATE"
    "DELETE FROM.*WHERE 1"
)

# Check for dangerous patterns
for pattern in "${DANGEROUS_PATTERNS[@]}"; do
    if echo "$COMMAND" | grep -qiE "$pattern"; then
        cat << EOF
{"decision": "block", "reason": "[Forge Security] BLOCKED: Potentially dangerous command detected matching pattern: $pattern"}
EOF
        exit 0
    fi
done

# Check for warning patterns
for pattern in "${WARNING_PATTERNS[@]}"; do
    if echo "$COMMAND" | grep -qiE "$pattern"; then
        cat << EOF
[Forge Security] WARNING: Command contains potentially destructive pattern: $pattern
Command: $COMMAND
Proceeding with caution...
EOF
        exit 0
    fi
done

# Command is safe
exit 0
