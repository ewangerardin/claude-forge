# /forge:init

Initialize Claude Forge for the current project. Detects project type, language, and framework to generate an appropriate CLAUDE.md configuration.

## What This Skill Does

1. **Detect Project Type** - Analyzes files to determine language and framework
2. **Generate CLAUDE.md** - Creates project-specific instructions
3. **Initialize Memory** - Sets up persistent memory with project context
4. **Configure Hooks** - Adapts hooks to project's tooling (linters, test runners)

## Detection Logic

Check for these files to determine project type:

| Files | Detection |
|-------|-----------|
| `package.json` | Node.js project |
| `tsconfig.json` | TypeScript project |
| `Cargo.toml` | Rust project |
| `go.mod` | Go project |
| `pyproject.toml`, `setup.py`, `requirements.txt` | Python project |
| `Gemfile` | Ruby project |
| `composer.json` | PHP project |
| `pom.xml`, `build.gradle` | Java project |
| `*.csproj`, `*.sln` | .NET project |

### Framework Detection (Node.js)

| Files/Patterns | Framework |
|----------------|-----------|
| `next.config.*` | Next.js |
| `nuxt.config.*` | Nuxt |
| `vite.config.*` | Vite |
| `angular.json` | Angular |
| `svelte.config.*` | SvelteKit |
| `remix.config.*` | Remix |
| `package.json` contains `express` | Express |
| `package.json` contains `fastify` | Fastify |

### Framework Detection (Python)

| Files/Patterns | Framework |
|----------------|-----------|
| `manage.py` | Django |
| `app.py` with Flask imports | Flask |
| `main.py` with FastAPI imports | FastAPI |

## Instructions

When `/forge:init` is invoked:

1. **Scan the project root** for detection files
2. **Read package.json** (if exists) for dependencies
3. **Identify the test runner** (jest, vitest, pytest, cargo test, go test)
4. **Identify the linter** (eslint, prettier, ruff, clippy, golint)
5. **Generate CLAUDE.md** with:
   - Project description
   - Key commands (build, test, lint)
   - Project structure overview
   - Conventions detected
6. **Update MEMORY.md** with detected patterns
7. **Report** what was detected and configured

## CLAUDE.md Template

Generate based on detection:

```markdown
# {Project Name}

{Brief description based on package.json/pyproject.toml/Cargo.toml}

## Quick Reference

| Action | Command |
|--------|---------|
| Install | `{detected install command}` |
| Build | `{detected build command}` |
| Test | `{detected test command}` |
| Lint | `{detected lint command}` |

## Project Structure

{Overview of main directories}

## Conventions

- {Detected naming convention}
- {Detected code style}
- {Import patterns}

## Key Files

- `{main entry point}` - Application entry
- `{config file}` - Configuration
- `{test directory}` - Tests location

## Claude Forge Agents

This project uses Claude Forge orchestration:
- `/forge:status` - Check memory and context
- `/forge:review` - Multi-agent code review
- `/forge:parallel` - Parallel task execution
```

## Output

After running, display:

```
[Forge Init] Project initialized

Detected:
- Language: {language}
- Framework: {framework}
- Test runner: {test runner}
- Linter: {linter}

Generated:
- .claude/CLAUDE.md
- .claude/memory/MEMORY.md (updated)

Run /forge:status to see the full configuration.
```
