# /forge:review

Run a comprehensive multi-agent code review combining Reviewer, Architect, and optionally Tester perspectives.

## What This Skill Does

Orchestrates multiple specialized agents to provide thorough code review:
1. **Reviewer** — Code quality, security, best practices
2. **Architect** — Design patterns, structure, maintainability
3. **Tester** — Test coverage implications (if available)

## Arguments

```
/forge:review [target] [--quick] [--security] [--full]
```

| Argument | Description |
|----------|-------------|
| `target` | File, directory, or git diff to review (default: staged changes) |
| `--quick` | Reviewer only, fast pass |
| `--security` | Focus on security issues |
| `--full` | All agents, comprehensive review |

## Instructions

When `/forge:review` is invoked:

### 1. Determine Target
- If argument provided, use that path
- If no argument, check for staged git changes (`git diff --cached`)
- If no staged changes, check for unstaged changes (`git diff`)
- If no changes, ask user what to review

### 2. Gather Context
- Read the files to be reviewed
- Check MEMORY.md for project conventions
- Note any relevant past decisions

### 3. Run Reviewer Agent
Invoke the reviewer agent with the code:
```
Review this code for:
- Security vulnerabilities (OWASP Top 10)
- Code quality issues
- Best practice violations
- Potential bugs
```

### 4. Run Architect Agent (if --full or default)
Invoke the architect agent:
```
Analyze this code for:
- Design pattern adherence
- Structural concerns
- Maintainability issues
- Coupling/cohesion
```

### 5. Consolidate Results
Combine findings into a unified report.

## Output Format

```markdown
# Forge Review Report

**Target**: {files/diff reviewed}
**Agents**: Reviewer, Architect
**Date**: {timestamp}

## Summary
{One-paragraph overall assessment}

## Critical Issues (must fix)
| # | File | Line | Issue | Agent |
|---|------|------|-------|-------|
| 1 | auth.ts | 42 | SQL injection vulnerability | Reviewer |
| 2 | user.ts | 15 | Exposed password in logs | Reviewer |

## Improvements (should fix)
| # | File | Line | Issue | Agent |
|---|------|------|-------|-------|
| 1 | api.ts | 88 | Missing error handling | Reviewer |
| 2 | db.ts | 23 | Tight coupling to ORM | Architect |

## Suggestions (nice to have)
| # | File | Line | Suggestion | Agent |
|---|------|------|------------|-------|
| 1 | utils.ts | 5 | Extract to shared module | Architect |

## Positive Observations
- {What's done well}

## Recommendation
[ ] Ready to merge
[x] Needs fixes before merge
[ ] Needs significant rework

## Next Steps
1. Fix critical issues #1 and #2
2. Address improvement #1
3. Consider suggestion #1 for future refactor
```

## Quick Mode (--quick)

Only runs Reviewer, outputs abbreviated format:

```markdown
# Quick Review: {target}

**Issues Found**: 3 critical, 5 improvements

Critical:
1. [auth.ts:42] SQL injection - use parameterized queries
2. [user.ts:15] Password logged - remove console.log

Improvements:
1. [api.ts:88] Add try/catch for async call
...

Verdict: Needs fixes before merge
```

## Security Mode (--security)

Focuses Reviewer on security only:

```markdown
# Security Review: {target}

## Vulnerabilities Found

### HIGH
- [auth.ts:42] SQL Injection
  Pattern: String concatenation in query
  Fix: Use parameterized queries

### MEDIUM
- [api.ts:15] Missing rate limiting
  Risk: DoS vulnerability
  Fix: Add rate limiter middleware

### LOW
- [config.ts:3] Hardcoded timeout
  Risk: Configuration inflexibility
  Fix: Move to environment variable

## Security Score: 6/10
```

## Integration with Memory

After review:
1. Log review in session-history.md
2. If patterns detected, update patterns.md
3. If recurring issues, update errors.md

## Error Handling

If no code to review:
```
[Forge Review] No changes detected.

Options:
- Specify a file: /forge:review src/auth.ts
- Specify a directory: /forge:review src/
- Stage changes: git add <files>
```
