#!/bin/bash
# Claude Forge — One-liner Installation Script
# Usage: curl -fsSL https://raw.githubusercontent.com/ewan/claude-forge/main/install.sh | bash

set -e

FORGE_VERSION="1.0.0"
FORGE_REPO="https://github.com/ewan/claude-forge"
FORGE_ARCHIVE="https://github.com/ewan/claude-forge/archive/refs/heads/main.tar.gz"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
cat << 'EOF'
   _____ _                 _        ______
  / ____| |               | |      |  ____|
 | |    | | __ _ _   _  __| | ___  | |__ ___  _ __ __ _  ___
 | |    | |/ _` | | | |/ _` |/ _ \ |  __/ _ \| '__/ _` |/ _ \
 | |____| | (_| | |_| | (_| |  __/ | | | (_) | | | (_| |  __/
  \_____|_|\__,_|\__,_|\__,_|\___| |_|  \___/|_|  \__, |\___|
                                                   __/ |
                                                  |___/
EOF
echo -e "${NC}"
echo -e "${GREEN}Claude Forge v${FORGE_VERSION}${NC}"
echo -e "Meta-framework d'orchestration pour Claude Code"
echo ""

# Check if we're in a project directory
if [ ! -d ".git" ] && [ ! -f "package.json" ] && [ ! -f "Cargo.toml" ] && [ ! -f "go.mod" ] && [ ! -f "pyproject.toml" ]; then
    echo -e "${YELLOW}Warning: Not in a project root. Continue anyway? (y/n)${NC}"
    read -r response
    if [ "$response" != "y" ]; then
        echo "Installation cancelled."
        exit 0
    fi
fi

# Check if .claude already exists
if [ -d ".claude" ]; then
    echo -e "${YELLOW}Warning: .claude directory already exists.${NC}"
    echo "Options:"
    echo "  1) Backup and replace"
    echo "  2) Merge (keep existing, add missing)"
    echo "  3) Cancel"
    read -r -p "Choice [1/2/3]: " choice
    case $choice in
        1)
            BACKUP_DIR=".claude.backup.$(date +%Y%m%d%H%M%S)"
            mv .claude "$BACKUP_DIR"
            echo -e "${GREEN}Backed up to $BACKUP_DIR${NC}"
            ;;
        2)
            MERGE_MODE=true
            ;;
        *)
            echo "Installation cancelled."
            exit 0
            ;;
    esac
fi

echo ""
echo "Installing Claude Forge..."

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Download and extract
echo "  Downloading..."
if command -v curl &> /dev/null; then
    curl -fsSL "$FORGE_ARCHIVE" -o "$TEMP_DIR/forge.tar.gz"
elif command -v wget &> /dev/null; then
    wget -q "$FORGE_ARCHIVE" -O "$TEMP_DIR/forge.tar.gz"
else
    echo -e "${RED}Error: curl or wget required${NC}"
    exit 1
fi

echo "  Extracting..."
tar -xzf "$TEMP_DIR/forge.tar.gz" -C "$TEMP_DIR"

# Find the extracted directory
EXTRACTED_DIR=$(find "$TEMP_DIR" -maxdepth 1 -type d -name "claude-forge*" | head -1)

if [ -z "$EXTRACTED_DIR" ]; then
    echo -e "${RED}Error: Failed to extract archive${NC}"
    exit 1
fi

# Install
echo "  Installing..."
if [ "$MERGE_MODE" = true ]; then
    # Merge mode: copy only missing files
    cp -rn "$EXTRACTED_DIR/.claude/"* .claude/ 2>/dev/null || true
else
    # Replace mode: copy everything
    cp -r "$EXTRACTED_DIR/.claude" .
fi

# Make hooks executable
chmod +x .claude/hooks/*.sh

# Initialize memory if not exists
mkdir -p .claude/memory
if [ ! -f ".claude/memory/MEMORY.md" ]; then
    cat > .claude/memory/MEMORY.md << 'MEMEOF'
# Forge Memory

## Current State
- **Session**: #0 (not started)
- **Branch**: unknown
- **Context**: Fresh installation
- **Last Action**: Claude Forge installed

## Active Decisions
(none yet)

## Tasks In Progress
- [ ] Run /forge:init to configure project

## Detected Patterns
(run /forge:init to detect)

## Recurring Errors
(none recorded)
MEMEOF
fi

echo ""
echo -e "${GREEN}✓ Claude Forge installed successfully!${NC}"
echo ""
echo "Files installed:"
echo "  .claude/agents/      — 9 specialized agents"
echo "  .claude/hooks/       — 5 automation hooks"
echo "  .claude/skills/      — 5 slash commands"
echo "  .claude/memory/      — Persistent memory"
echo "  .claude/templates/   — Generation templates"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Start Claude Code in this directory"
echo "  2. Run /forge:init to configure for your project"
echo "  3. Run /forge:status to see the dashboard"
echo ""
echo -e "${YELLOW}Quick commands:${NC}"
echo "  /forge:init      — Initialize for this project"
echo "  /forge:status    — Show dashboard"
echo "  /forge:review    — Multi-agent code review"
echo "  /forge:parallel  — Parallel task execution"
echo "  /forge:memory    — View/edit memory"
echo ""
