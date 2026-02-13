# Claude Forge

Meta-framework d'orchestration pour Claude Code. Transforme Claude Code en système multi-agents intelligent avec mémoire persistante.

## Quick Reference

| Action | Command |
|--------|---------|
| Init projet | `/forge:init` |
| Status | `/forge:status` |
| Review | `/forge:review` |
| Créer agent | `/forge:create-agent` |

## Structure du Projet

```
.claude/
├── agents/          # Agents spécialisés (orchestrator, coder, reviewer...)
├── hooks/           # Scripts de hooks (qualité, sécurité, mémoire)
├── skills/          # Skills invocables via /commandes
├── memory/          # Mémoire persistante
└── templates/       # Templates pour génération
```

## Conventions

- Scripts hook en bash, compatibles sans dépendances externes
- Agents définis en Markdown avec instructions structurées
- Mémoire en Markdown simple (pas de SQLite)
- Nommage: kebab-case pour fichiers, CAPS pour fichiers spéciaux

## Hooks Disponibles

| Hook | Trigger | Rôle |
|------|---------|------|
| `session-start-restore.sh` | SessionStart | Restaure le contexte |
| `pre-compact-save-context.sh` | PreCompact | Sauvegarde avant compaction |
| `post-write-validate.sh` | PostToolUse(Write) | Lint après écriture |
| `pre-tool-security-scan.sh` | PreToolUse(Bash) | Bloque commandes dangereuses |

## Agents Disponibles

| Agent | Rôle |
|-------|------|
| `orchestrator` | Coordination et routage |
| `coder` | Implémentation rapide |
| `reviewer` | Review et sécurité |

## Development

Ce projet est le meta-framework lui-même. Pour tester:

```bash
# Test hook mémoire
bash .claude/hooks/session-start-restore.sh

# Test hook sécurité
echo '{"tool_input":{"command":"ls"}}' | bash .claude/hooks/pre-tool-security-scan.sh
```
