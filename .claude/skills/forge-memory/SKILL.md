# /forge:memory

View and manage Claude Forge's persistent memory system.

## What This Skill Does

1. **View** current memory state
2. **Edit** memory entries
3. **Prune** outdated information
4. **Reset** memory to fresh state

## Arguments

```
/forge:memory [action] [--file=MEMORY.md]
```

| Argument | Description |
|----------|-------------|
| (none) | View current memory |
| `save` | Force save current context |
| `prune` | Clean up old entries |
| `reset` | Clear and reinitialize memory |
| `--file=X` | Target specific memory file |

## Instructions

### Default: View Memory
When `/forge:memory` is invoked without arguments:

1. Read `.claude/memory/MEMORY.md`
2. Display formatted content
3. Show memory statistics

Output:
```
=== FORGE MEMORY ===

Session: #14 (2026-02-13)
Branch: feature/auth

Context: Refactoring auth module
Last Action: Extracted JWT middleware

Active Decisions (3):
  1. Use passport.js for auth
  2. Separate admin/user routes
  3. JWT tokens with 24h expiry

Tasks:
  [ ] Migrate auth tests
  [ ] Update API docs
  [x] Extract JWT middleware

Patterns:
  - Express + TypeScript + Prisma
  - kebab-case files

Memory Files:
  - MEMORY.md (32 lines)
  - session-history.md (45 entries)
  - decisions.md (12 decisions)
  - patterns.md (8 patterns)
  - errors.md (3 errors)
```

### Action: save
Force save current context to memory:

1. Extract key information from conversation
2. Update MEMORY.md with current state
3. Log to session-history.md

Output:
```
[Forge Memory] Context saved

Updated:
- Session state
- Current branch
- Last action

Memory file: .claude/memory/MEMORY.md
```

### Action: prune
Clean up outdated entries:

1. Remove completed tasks older than 5 sessions
2. Archive superseded decisions
3. Consolidate similar errors
4. Ensure MEMORY.md stays under 200 lines

Output:
```
[Forge Memory] Pruned

Removed:
- 12 old completed tasks
- 3 superseded decisions
- 2 duplicate errors

MEMORY.md: 156 → 98 lines
```

### Action: reset
Clear and reinitialize memory:

1. Confirm with user (destructive action)
2. Archive current memory to `.claude/memory/archive/`
3. Create fresh MEMORY.md
4. Reset session counter

Output:
```
[Forge Memory] Reset complete

Archived to: .claude/memory/archive/2026-02-13/
New memory initialized.
Session counter reset to #0.
```

## Memory File Details

| File | Purpose | Max Size |
|------|---------|----------|
| `MEMORY.md` | Main index, auto-loaded | 200 lines |
| `session-history.md` | Session log | Unlimited |
| `decisions.md` | Architectural decisions | Unlimited |
| `patterns.md` | Project patterns | Unlimited |
| `errors.md` | Recurring errors | Unlimited |

## Editing Memory

To edit specific sections:
```
/forge:memory --file=decisions.md
```

Then use normal editing to modify the file.

## Error Handling

| Error | Solution |
|-------|----------|
| Memory file not found | Run `/forge:init` first |
| Memory file corrupted | Use `/forge:memory reset` |
| Memory too large | Use `/forge:memory prune` |
