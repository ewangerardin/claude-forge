# /forge:parallel

Decompose a complex task into subtasks and distribute them across multiple agents running in parallel.

## What This Skill Does

1. **Analyze** the task to identify parallelizable subtasks
2. **Assign** each subtask to the appropriate specialist agent
3. **Launch** agents in parallel using background tasks
4. **Monitor** progress and collect results
5. **Synthesize** results into a unified response

## Arguments

```
/forge:parallel "<task description>" [--agents=coder,reviewer] [--max=4]
```

| Argument | Description |
|----------|-------------|
| `task` | The complex task to parallelize |
| `--agents` | Limit to specific agents (default: auto-select) |
| `--max` | Maximum parallel agents (default: 4) |

## Instructions

When `/forge:parallel` is invoked:

### 1. Analyze the Task
Break down the task into independent subtasks:
- Identify components that can run concurrently
- Detect dependencies between subtasks
- Group related work

### 2. Assign Agents
For each subtask, select the best agent:

| Subtask Type | Agent |
|--------------|-------|
| Write new code | coder |
| Review existing code | reviewer |
| Design/architecture | architect |
| Write tests | tester |
| Documentation | doc-writer |

### 3. Launch in Parallel
Use the Task tool with `run_in_background: true`:

```
Task(subagent_type="general-purpose",
     prompt="[Subtask details]",
     run_in_background=true)
```

### 4. Monitor Progress
- Track each background task
- Report progress updates
- Handle failures gracefully

### 5. Synthesize Results
Combine all agent outputs into a coherent response.

## Example

```
User: /forge:parallel "Add user authentication with login, register, and password reset"

[Forge Parallel] Analyzing task...

Decomposition:
┌─────────────────────────────────────────────────┐
│ Task: User Authentication System                │
├─────────────────────────────────────────────────┤
│ Subtask 1: Login endpoint         → coder      │
│ Subtask 2: Register endpoint      → coder      │
│ Subtask 3: Password reset flow    → coder      │
│ Subtask 4: Auth middleware        → coder      │
│ Subtask 5: Security review        → reviewer   │
└─────────────────────────────────────────────────┘

Launching 4 parallel agents...

Progress:
[████████░░] Subtask 1: Login endpoint (complete)
[██████░░░░] Subtask 2: Register endpoint (in progress)
[████░░░░░░] Subtask 3: Password reset (in progress)
[██████████] Subtask 4: Auth middleware (complete)
[░░░░░░░░░░] Subtask 5: Security review (waiting for code)

Results synthesized. See below for summary.
```

## Output Format

```markdown
# Parallel Execution Report

**Task**: {original task}
**Agents Used**: {list}
**Duration**: {time}

## Subtasks Completed

### 1. {Subtask Name} (coder)
- Files created/modified: {list}
- Status: Complete

### 2. {Subtask Name} (coder)
- Files created/modified: {list}
- Status: Complete

## Combined Results
{Summary of all work done}

## Issues Found
{Any problems encountered}

## Next Steps
{Recommended follow-up actions}
```

## Dependency Handling

When subtasks have dependencies:

```
Independent tasks → Run in parallel
         │
         ▼
Dependent tasks → Run sequentially after dependencies complete
         │
         ▼
Final synthesis → Combine all results
```

## Limits

- Maximum 4 concurrent agents (configurable)
- Each subtask has 10-minute timeout
- Failed subtasks are reported, don't block others

## Error Handling

```
[Forge Parallel] Warning: Subtask 3 failed

Continuing with remaining subtasks...
Partial results available.

Failed: Password reset flow
Error: Missing email service configuration

Completed: 4/5 subtasks
```
