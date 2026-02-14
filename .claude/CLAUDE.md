# Claude Forge

Meta-framework d'orchestration pour Claude Code. Systeme multi-agents intelligent avec memoire persistante.

## Identite

Lis `.claude/identity/SOUL.md` pour la philosophie du projet.
Lis `.claude/identity/USER.md` pour le contexte du developpeur.
Lis `.claude/identity/CONVENTIONS.md` pour les conventions de code.

## Memoire

Au demarrage, le hook SessionStart charge automatiquement :
- `.claude/memory/MEMORY.md` (faits durables, index < 200 lignes)
- `.claude/memory/daily/{aujourd'hui}.md` (log du jour)
- `.claude/memory/daily/{hier}.md` (contexte recent, 30 dernieres lignes)
- `.claude/memory/HEARTBEAT.md` (etat du projet)

Avant chaque compaction, le hook PreCompact te demande de sauvegarder
les informations importantes dans les fichiers memoire :
- `daily/{DATE}.md` — travail en cours (append-only)
- `decisions.md` — decisions architecturales
- `errors.md` — erreurs et solutions
- `patterns.md` — patterns detectes
- `MEMORY.md` — faits durables (si changement)

## Quick Reference

| Action | Command |
|--------|---------|
| Init projet | `/forge:init` |
| Status | `/forge:status` |
| Review | `/forge:review` |
| Creer agent | `/forge:create-agent` |
| Chercher memoire | `/forge:memory-search` |
| Editer memoire | `/forge:memory` |

## Structure

```
.claude/
├── agents/          # Agents specialises
├── hooks/           # Scripts de hooks bash
├── skills/          # Skills /forge:*
├── memory/          # Memoire persistante
│   └── daily/       # Logs quotidiens YYYY-MM-DD.md
├── identity/        # SOUL.md, USER.md, CONVENTIONS.md
└── templates/       # Templates pour generation
```

## Conventions

- Scripts hook en bash, zero dependance externe
- Agents definis en Markdown avec instructions structurees
- Memoire en Markdown simple (pas de SQLite)
- Nommage: kebab-case pour fichiers, CAPS pour fichiers speciaux

## Hooks

| Hook | Trigger | Role |
|------|---------|------|
| `session-start-restore.sh` | SessionStart | Charge MEMORY + daily J/J-1 + HEARTBEAT |
| `pre-compact-prepare.sh` | PreCompact | Stats avant flush cognitif |
| PreCompact prompt | PreCompact | Demande a Claude de sauvegarder en memoire |
| `stop-session-finalize.sh` | Stop | Finalise session, nettoie logs > 30j |
| `post-write-validate.sh` | PostToolUse(Write) | Lint apres ecriture |
| `pre-tool-security-scan.sh` | PreToolUse(Bash) | Bloque commandes dangereuses |

## Agents

| Agent | Role |
|-------|------|
| `orchestrator` | Coordination et routage |
| `coder` | Implementation rapide |
| `reviewer` | Review et securite |
| `agent-creator` | Creation de nouveaux agents |
| `hook-advisor` | Conseil sur les hooks |
| `context-manager` | Gestion du contexte |
| `architect` | Architecture logicielle |
| `tester` | Tests et validation |
| `doc-writer` | Documentation |
