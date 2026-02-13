# Claude Forge

**Meta-framework d'orchestration multi-agents pour Claude Code.**

Drop `.claude/` dans n'importe quel projet pour transformer Claude Code en système d'orchestration intelligent avec mémoire persistante.

## Features

- **9 Agents Spécialisés** — Orchestrator, Coder, Reviewer, Architect, Tester, Doc-Writer, Agent-Creator, Hook-Advisor, Context-Manager
- **Mémoire Persistante** — Le contexte survit entre les sessions
- **Hooks Automatiques** — Qualité, sécurité, suggestions de tests
- **5 Skills** — `/forge:init`, `/forge:status`, `/forge:review`, `/forge:parallel`, `/forge:memory`
- **Zéro Dépendance** — Tout est natif Claude Code

## Installation

### One-liner
```bash
curl -fsSL https://raw.githubusercontent.com/ewan/claude-forge/main/install.sh | bash
```

### Manuel
```bash
git clone https://github.com/ewan/claude-forge.git
cp -r claude-forge/.claude your-project/
```

## Quick Start

```bash
# 1. Installer dans votre projet
cd your-project
curl -fsSL https://raw.githubusercontent.com/ewan/claude-forge/main/install.sh | bash

# 2. Lancer Claude Code
claude

# 3. Initialiser Forge
/forge:init

# 4. Voir le dashboard
/forge:status
```

## Skills

| Command | Description |
|---------|-------------|
| `/forge:init` | Détecte le projet et génère CLAUDE.md |
| `/forge:status` | Dashboard: contexte, mémoire, agents |
| `/forge:review` | Review multi-agents (Reviewer + Architect) |
| `/forge:parallel` | Exécution parallèle de tâches |
| `/forge:memory` | Voir/éditer la mémoire persistante |

## Agents

| Agent | Role |
|-------|------|
| **orchestrator** | Route les tâches vers le bon spécialiste |
| **coder** | Implémentation rapide et focused |
| **reviewer** | Review, sécurité, best practices |
| **architect** | Design, patterns, refactoring |
| **tester** | Tests et coverage |
| **doc-writer** | Documentation, README, changelogs |
| **agent-creator** | Crée de nouveaux agents |
| **hook-advisor** | Recommande les hooks appropriés |
| **context-manager** | Gère la mémoire persistante |

## Hooks

| Hook | Trigger | Action |
|------|---------|--------|
| `session-start-restore` | SessionStart | Restaure la mémoire |
| `pre-compact-save-context` | PreCompact | Sauvegarde avant compaction |
| `post-write-validate` | Write/Edit | Lint les fichiers |
| `post-write-suggest-tests` | Write(code) | Suggère des tests |
| `pre-tool-security-scan` | Bash | Bloque commandes dangereuses |

## Architecture

```
.claude/
├── agents/          # 9 agents spécialisés
├── hooks/           # 5 hooks d'automatisation
├── skills/          # 5 slash commands
├── memory/          # Mémoire persistante
├── templates/       # Templates de génération
├── plugins/         # Plugin manifest
├── settings.json    # Configuration hooks
└── CLAUDE.md        # Instructions projet
```

## Mémoire Persistante

Forge maintient le contexte entre les sessions :

```markdown
# Forge Memory

## Current State
- Session: #14
- Branch: feature/auth
- Context: Refactoring auth module

## Active Decisions
1. Use passport.js for auth
2. JWT tokens with 24h expiry

## Tasks In Progress
- [ ] Migrate tests
- [x] Extract middleware
```

## Créer un Nouvel Agent

Utilisez Agent Creator qui consulte automatiquement Hook Advisor :

```
"Crée un agent database-migrator qui gère les migrations SQL"

→ Agent Creator analyse le besoin
→ Consulte Hook Advisor pour les hooks recommandés
→ Génère l'agent + hooks + documentation
```

## Configuration

### settings.json

```json
{
  "hooks": {
    "SessionStart": [...],
    "PreCompact": [...],
    "PostToolUse": [...],
    "PreToolUse": [...]
  }
}
```

### Désactiver un hook

Commentez ou supprimez le hook dans `settings.json`.

## Tests

```bash
# Tester tous les hooks
bash test-forge.sh

# Tester un hook spécifique
echo '{}' | bash .claude/hooks/session-start-restore.sh
```

## License

MIT

## Contributing

1. Fork le repo
2. Créez une branche (`git checkout -b feature/amazing`)
3. Committez (`git commit -m 'Add amazing feature'`)
4. Push (`git push origin feature/amazing`)
5. Ouvrez une Pull Request
