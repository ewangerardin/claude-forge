# Conventions — Claude Forge

## Detecte automatiquement
- Langage : Bash (hooks), Markdown (agents/skills/memory)
- Framework : Claude Code CLI (native hooks + skills)
- Linter : shellcheck (hooks bash)
- Formatter : N/A
- Tests : manual (`bash .claude/hooks/*.sh`)

## Conventions de code
- Nommage fichiers : kebab-case
- Fichiers speciaux : CAPS (MEMORY.md, SOUL.md, etc.)
- Indentation : 2 espaces (bash), N/A (markdown)

## Structure du projet
```
.claude/
├── agents/          # Agents specialises (orchestrator, coder, reviewer...)
├── hooks/           # Scripts de hooks bash
├── skills/          # Skills invocables via /forge:*
├── memory/          # Memoire persistante (MEMORY.md, daily/, decisions.md...)
│   └── daily/       # Logs quotidiens YYYY-MM-DD.md
├── identity/        # SOUL.md, USER.md, CONVENTIONS.md
└── templates/       # Templates pour generation
```
