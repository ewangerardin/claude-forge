# /forge:status

Display the Claude Forge dashboard showing context usage, memory state, active decisions, tasks, and available agents.

## What This Skill Does

Provides a quick overview of the current Forge state:
1. **Context Usage** — How much context is used vs. available
2. **Memory State** — Current session, branch, last action
3. **Active Decisions** — Decisions in effect
4. **Tasks** — Pending and recently completed
5. **Agents** — Available specialized agents

## Instructions

When `/forge:status` is invoked:

### 1. Check Context Usage
Estimate current context usage (if available from system).

### 2. Read Memory Files
Read `.claude/memory/MEMORY.md` and extract:
- Session number and date
- Current branch
- Current context/focus
- Last action taken

### 3. Count Items
- Count active decisions (numbered items under "## Active Decisions")
- Count pending tasks (`- [ ]`)
- Count completed tasks (`- [x]`)

### 4. List Agents
Read `.claude/agents/` directory and list available agents.

### 5. Check Hooks
Read `.claude/settings.json` and list active hooks.

## Output Format

Display in this format:

```
╔══════════════════════════════════════════════════════════════╗
║                    FORGE STATUS                              ║
╠══════════════════════════════════════════════════════════════╣
║ Context: ████████░░░░░░░░░░░░ 42% (84k/200k tokens)         ║
╠══════════════════════════════════════════════════════════════╣
║ Session: #14                    Branch: feature/auth        ║
║ Focus: Refactoring auth module                               ║
║ Last: Extracted JWT middleware                               ║
╠══════════════════════════════════════════════════════════════╣
║ DECISIONS (3 active)                                         ║
║ • Use passport.js for auth                                   ║
║ • Separate admin/user routes                                 ║
║ • JWT tokens with 24h expiry                                 ║
╠══════════════════════════════════════════════════════════════╣
║ TASKS                                                        ║
║ ○ Migrate auth tests           ○ Update API docs            ║
║ ● Extract JWT middleware (done)                              ║
╠══════════════════════════════════════════════════════════════╣
║ AGENTS                                                       ║
║ orchestrator │ coder │ reviewer │ agent-creator │           ║
║ hook-advisor │ context-manager                               ║
╠══════════════════════════════════════════════════════════════╣
║ HOOKS (4 active)                                             ║
║ SessionStart │ PreCompact │ PostToolUse(Write) │            ║
║ PreToolUse(Bash)                                             ║
╚══════════════════════════════════════════════════════════════╝
```

## Simplified ASCII Version

If rendering issues, use simpler format:

```
=== FORGE STATUS ===

Context: 42% (84k/200k tokens)

Session: #14 | Branch: feature/auth
Focus: Refactoring auth module
Last: Extracted JWT middleware

Decisions (3):
  1. Use passport.js for auth
  2. Separate admin/user routes
  3. JWT tokens with 24h expiry

Tasks:
  [ ] Migrate auth tests
  [ ] Update API docs
  [x] Extract JWT middleware

Agents: orchestrator, coder, reviewer, agent-creator, hook-advisor, context-manager

Hooks: SessionStart, PreCompact, PostToolUse(Write), PreToolUse(Bash)
```

## Color Coding (if terminal supports)

| Context Level | Color | Meaning |
|---------------|-------|---------|
| 0-50% | Green | Plenty of space |
| 50-70% | Yellow | Getting full |
| 70-85% | Orange | Consider summarizing |
| 85%+ | Red | Compaction imminent |

## Quick Actions

After displaying status, suggest relevant actions:

```
Quick Actions:
  /forge:memory     - View full memory
  /forge:review     - Run code review
  /forge:init       - Reinitialize project
```
