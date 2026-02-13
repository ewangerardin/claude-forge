#!/bin/bash
# Claude Forge — Test Suite
# Tests all hooks and validates the installation

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASSED=0
FAILED=0

echo "========================================"
echo "  Claude Forge Test Suite"
echo "========================================"
echo ""

# Helper function
test_hook() {
    local name=$1
    local hook=$2
    local input=$3
    local expected=$4

    printf "Testing %-35s " "$name..."

    result=$(echo "$input" | bash "$hook" 2>&1) || true

    if echo "$result" | grep -q "$expected"; then
        echo -e "${GREEN}PASS${NC}"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Expected: $expected"
        echo "  Got: $result"
        ((FAILED++))
    fi
}

# Test 1: Session Start Hook
test_hook "session-start-restore.sh" \
    ".claude/hooks/session-start-restore.sh" \
    "" \
    "Forge Memory"

# Test 2: Pre-Compact Hook
test_hook "pre-compact-save-context.sh" \
    ".claude/hooks/pre-compact-save-context.sh" \
    "{}" \
    "Context saved"

# Test 3: Security Hook - Block dangerous
test_hook "security-scan (block rm -rf /)" \
    ".claude/hooks/pre-tool-security-scan.sh" \
    '{"tool_input":{"command":"rm -rf /"}}' \
    "BLOCKED"

# Test 4: Security Hook - Allow safe
echo '{"tool_input":{"command":"ls -la"}}' | bash .claude/hooks/pre-tool-security-scan.sh > /dev/null 2>&1
if [ $? -eq 0 ]; then
    printf "Testing %-35s " "security-scan (allow ls)..."
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    printf "Testing %-35s " "security-scan (allow ls)..."
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 5: Security Hook - Warning
test_hook "security-scan (warn git push --force)" \
    ".claude/hooks/pre-tool-security-scan.sh" \
    '{"tool_input":{"command":"git push --force"}}' \
    "WARNING"

# Test 6: Post-Write Validate
test_hook "post-write-validate.sh (py file)" \
    ".claude/hooks/post-write-validate.sh" \
    '{"tool_input":{"file_path":"test.py"}}' \
    "validated"

# Test 7: Post-Write Suggest Tests
test_hook "post-write-suggest-tests.sh" \
    ".claude/hooks/post-write-suggest-tests.sh" \
    '{"tool_input":{"file_path":"src/auth.ts"}}' \
    "Consider adding tests"

# Test 8: Suggest Tests - Skip test files
result=$(echo '{"tool_input":{"file_path":"src/auth.test.ts"}}' | bash .claude/hooks/post-write-suggest-tests.sh 2>&1)
printf "Testing %-35s " "suggest-tests (skip test file)..."
if [ -z "$result" ]; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 9: Check all agent files exist
printf "Testing %-35s " "all agents exist..."
AGENTS=("orchestrator" "coder" "reviewer" "architect" "tester" "doc-writer" "agent-creator" "hook-advisor" "context-manager")
all_exist=true
for agent in "${AGENTS[@]}"; do
    if [ ! -f ".claude/agents/${agent}.md" ]; then
        all_exist=false
        break
    fi
done
if $all_exist; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 10: Check all skill files exist
printf "Testing %-35s " "all skills exist..."
SKILLS=("forge-init" "forge-status" "forge-review" "forge-parallel" "forge-memory")
all_exist=true
for skill in "${SKILLS[@]}"; do
    if [ ! -f ".claude/skills/${skill}/SKILL.md" ]; then
        all_exist=false
        break
    fi
done
if $all_exist; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 11: Check settings.json is valid JSON
printf "Testing %-35s " "settings.json valid..."
if python3 -c "import json; json.load(open('.claude/settings.json'))" 2>/dev/null || \
   python -c "import json; json.load(open('.claude/settings.json'))" 2>/dev/null; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 12: Check manifest.json is valid JSON
printf "Testing %-35s " "manifest.json valid..."
if python3 -c "import json; json.load(open('.claude/plugins/forge-plugin/manifest.json'))" 2>/dev/null || \
   python -c "import json; json.load(open('.claude/plugins/forge-plugin/manifest.json'))" 2>/dev/null; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 13: Check memory file exists
printf "Testing %-35s " "MEMORY.md exists..."
if [ -f ".claude/memory/MEMORY.md" ]; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Test 14: Check templates exist
printf "Testing %-35s " "templates exist..."
if [ -f ".claude/templates/agent-template.md" ] && \
   [ -f ".claude/templates/hook-template.sh" ] && \
   [ -f ".claude/templates/skill-template.md" ]; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC}"
    ((FAILED++))
fi

# Summary
echo ""
echo "========================================"
echo "  Results: ${PASSED} passed, ${FAILED} failed"
echo "========================================"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
