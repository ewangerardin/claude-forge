# Claude Forge — Architecture du Meta-Framework

## Vision

**Claude Forge** est un kit `.claude/` auto-contenu et portable qui se drop dans n'importe quel projet pour transformer Claude Code en système d'orchestration multi-agents intelligent. Zéro dépendance externe. Une seule commande d'installation. Les agents se conseillent mutuellement et le contexte persiste entre les sessions.

---

## Principes fondamentaux

1. **Drop-in** — Copier `.claude/` dans un projet suffit. `/forge:init` adapte la config au projet détecté.
2. **Zéro dépendance externe** — Tout est natif Claude Code : subagents, hooks, skills, plugins. Pas de npm/pip à installer.
3. **Contexte persistant** — Un hook `PreCompact` sauvegarde l'état dans `.claude/memory/` (fichiers Markdown, pas SQLite — compatible avec Claude Code natif). Un hook `SessionStart` le recharge.
4. **Agents-qui-conseillent-des-agents** — L'Agent Creator invoque le Hook Advisor pour recommander des hooks pertinents. L'Orchestrator décide quel spécialiste appeler.
5. **Qualité d'abord** — Chaque écriture de fichier déclenche validation, linting, et suggestion de tests.

---

## Structure du répertoire

```
.claude/                              # ← On drop tout ça dans n'importe quel projet
├── settings.json                     # Config projet : hooks, permissions, modèles
├── settings.local.json               # Config perso (git-ignored)
├── CLAUDE.md                         # ← Généré par /forge:init selon le projet
│
├── agents/                           # Sous-agents spécialisés
│   ├── orchestrator.md               # 🧠 Chef d'orchestre — route vers le bon agent
│   ├── architect.md                  # 📐 Analyse de code, design patterns, refactoring
│   ├── coder.md                      # ⚡ Implémentation rapide, mode focused
│   ├── reviewer.md                   # 🔍 Code review, security audit, best practices
│   ├── tester.md                     # 🧪 Génération et exécution de tests
│   ├── agent-creator.md              # 🏭 Crée de nouveaux agents, consulte hook-advisor
│   ├── hook-advisor.md               # 🪝 Expert hooks — recommande quels hooks pour quel agent/workflow
│   ├── context-manager.md            # 📦 Gère la mémoire persistante, compaction intelligente
│   └── doc-writer.md                 # 📝 Documentation, README, changelogs
│
├── skills/                           # Skills invocables via /commandes
│   ├── forge-init/                   # /forge:init — Setup initial du projet
│   │   └── SKILL.md
│   ├── forge-status/                 # /forge:status — État du contexte et de la mémoire
│   │   └── SKILL.md
│   ├── forge-review/                 # /forge:review — Review complète avec multi-agents
│   │   └── SKILL.md
│   ├── forge-create-agent/           # /forge:create-agent — Workflow guidé de création d'agent
│   │   └── SKILL.md
│   ├── forge-parallel/               # /forge:parallel — Lance N tâches en parallèle
│   │   └── SKILL.md
│   └── forge-memory/                 # /forge:memory — Consulte/édite la mémoire persistante
│       └── SKILL.md
│
├── hooks/                            # Scripts de hooks
│   ├── pre-compact-save-context.sh   # Sauvegarde le contexte avant compaction
│   ├── session-start-restore.sh      # Restaure le contexte au démarrage
│   ├── post-write-validate.sh        # Lint + format après chaque écriture
│   ├── post-write-suggest-tests.sh   # Suggère des tests pour le code écrit
│   ├── pre-tool-security-scan.sh     # Bloque les commandes dangereuses
│   ├── stop-quality-gate.sh          # Vérifie la qualité avant de terminer
│   └── subagent-stop-log.sh          # Log les résultats des sous-agents
│
├── memory/                           # Mémoire persistante (git-ignored)
│   ├── MEMORY.md                     # Index — auto-chargé (< 200 lignes)
│   ├── session-history.md            # Historique des sessions
│   ├── decisions.md                  # Décisions architecturales prises
│   ├── patterns.md                   # Patterns détectés dans le projet
│   └── errors.md                     # Erreurs rencontrées et solutions
│
├── templates/                        # Templates pour la génération d'agents/hooks
│   ├── agent-template.md             # Template de base pour un nouvel agent
│   ├── hook-template.sh              # Template de base pour un nouveau hook
│   └── skill-template.md             # Template de base pour un nouveau skill
│
└── plugins/                          # Plugins Claude Code (beta)
    └── forge-plugin/                 # Le plugin principal
        ├── manifest.json             # Manifeste du plugin
        ├── agents/                   # Agents packagés dans le plugin
        ├── hooks/                    # Hooks packagés
        └── skills/                   # Skills packagées
```

---

## L'architecture des agents en détail

### Le flux d'orchestration

```
Utilisateur
    │
    ▼
🧠 Orchestrator ──────────────────────────────────────────────┐
    │                                                          │
    ├──▶ 📐 Architect   (analyse, design, refactoring)        │
    ├──▶ ⚡ Coder       (implémentation focused)               │
    ├──▶ 🔍 Reviewer    (review, security, best practices)    │
    ├──▶ 🧪 Tester      (tests, coverage, benchmarks)         │
    ├──▶ 📝 Doc-Writer  (docs, README, changelogs)            │
    ├──▶ 📦 Context-Mgr (mémoire, compaction, état)           │
    │                                                          │
    └──▶ 🏭 Agent-Creator ──▶ 🪝 Hook-Advisor                │
              │                    │                           │
              │  "Je crée un       │  "Pour cet agent,        │
              │   agent de         │   je recommande ces       │
              │   migration DB"    │   hooks: PreToolUse       │
              │                    │   pour valider les SQL,   │
              │                    │   PostToolUse pour        │
              └────────────────────┘   backup avant ALTER"     │
                                                               │
    ◀──────────────────────────────────────────────────────────┘
```

### Principe clé : les agents qui se consultent

L'Agent Creator ne travaille jamais seul. Quand il crée un nouvel agent, il :
1. Analyse le besoin (type d'agent, outils nécessaires, modèle)
2. **Invoque Hook Advisor** pour obtenir des recommandations de hooks
3. **Invoque Reviewer** pour valider la qualité de l'agent créé
4. Génère l'agent + ses hooks recommandés + la doc

Le Hook Advisor maintient une **base de connaissances** des patterns hook → situation :
- Agent qui écrit du code → PostToolUse(Write) pour lint
- Agent qui exécute du bash → PreToolUse(Bash) pour security scan
- Agent long-running → PreCompact pour sauvegarder le contexte
- Agent qui modifie la DB → PreToolUse(Bash) pour backup
- etc.

---

## Le système de mémoire persistante

### Cycle de vie du contexte

```
SessionStart ──▶ [Hook: session-start-restore.sh]
    │               │
    │               ├── Lit .claude/memory/MEMORY.md
    │               ├── Résume : "Session #14. Dernière fois : refactoring auth module.
    │               │             Contexte actuel : 12% utilisé. Décisions en cours : 3."
    │               └── Injecte dans le contexte via stdout
    │
    ▼
[... travail normal ...]
    │
    ▼
PreCompact ──▶ [Hook: pre-compact-save-context.sh]
    │               │
    │               ├── Extrait les infos clés de la session courante
    │               ├── Met à jour MEMORY.md, decisions.md, errors.md
    │               └── Log le % de contexte avant compaction
    │
    ▼
[Compaction automatique par Claude Code]
    │
    ▼
Stop ──▶ [Hook: stop-quality-gate.sh]
                │
                ├── Vérifie que les tests passent (si pertinent)
                ├── Met à jour session-history.md
                └── Affiche le résumé de session
```

### Format de MEMORY.md

```markdown
# Forge Memory — {project-name}

## État courant
- **Session** : #14 (2025-02-13)
- **Branche** : feature/auth-refactor
- **Contexte** : Refactoring du module d'authentification
- **Dernière action** : Extraction du middleware JWT dans un service dédié

## Décisions actives
1. Utiliser passport.js au lieu de l'auth custom (décidé session #12)
2. Séparer les routes admin des routes user (décidé session #13)

## Tâches en cours
- [ ] Migrer les tests d'auth vers le nouveau service
- [ ] Mettre à jour la doc API
- [x] Extraire le middleware JWT

## Patterns détectés
- Le projet utilise Express + TypeScript + Prisma
- Convention : fichiers en kebab-case, exports nommés
- Tests : Vitest avec @testing-library

## Erreurs récurrentes
- Prisma generate oublié après modification de schema
- Import circulaire entre auth/ et middleware/
```

---

## Le système de hooks en détail

### settings.json — Configuration complète

```json
{
  "permissions": {
    "allow": [
      "Read(*)",
      "Grep(*)",
      "Glob(*)",
      "Write(.claude/**)",
      "Bash(npm test*)",
      "Bash(npx prettier*)",
      "Bash(npx eslint*)",
      "Bash(git diff*)",
      "Bash(git log*)",
      "Bash(cat .claude/memory/*)"
    ]
  },
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/session-start-restore.sh"
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/pre-compact-save-context.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/post-write-validate.sh"
          }
        ]
      },
      {
        "matcher": "Write(*.ts)|Write(*.tsx)|Write(*.js)|Write(*.jsx)|Write(*.py)",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/post-write-suggest-tests.sh"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/pre-tool-security-scan.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/stop-quality-gate.sh"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/subagent-stop-log.sh"
          }
        ]
      }
    ]
  }
}
```

---

## Les skills : commandes utilisateur

### /forge:init — Le point d'entrée

Détecte le type de projet (langage, framework, structure), génère un CLAUDE.md adapté,
configure les linters/formatters dans les hooks, et initialise la mémoire.

### /forge:status — Dashboard rapide

Affiche : % de contexte utilisé, mémoire chargée, décisions actives, tâches en cours,
dernière session, agents disponibles.

### /forge:review — Review multi-agents

Lance Reviewer (code quality) + Tester (coverage) + Architect (design) en séquence,
consolide les résultats.

### /forge:create-agent — Workflow guidé

1. Demande le nom et la description de l'agent
2. Invoque Agent Creator qui analyse le besoin
3. Agent Creator invoque Hook Advisor pour les recommandations
4. Génère l'agent .md + les hooks recommandés
5. Invoque Reviewer pour valider

### /forge:parallel — Tâches parallèles

Décompose une tâche en sous-tâches, les distribue à des subagents spécialisés.

### /forge:memory — Gestion de la mémoire

Permet de consulter, éditer, ou reset la mémoire persistante.

---

## Le plugin forge-plugin

Le plugin package tout le système pour une installation via le marketplace :

```json
{
  "name": "claude-forge",
  "version": "1.0.0",
  "description": "Meta-framework d'orchestration pour Claude Code",
  "author": "Ewan",
  "agents": ["orchestrator", "architect", "coder", "reviewer", "tester",
             "agent-creator", "hook-advisor", "context-manager", "doc-writer"],
  "skills": ["forge-init", "forge-status", "forge-review",
             "forge-create-agent", "forge-parallel", "forge-memory"],
  "hooks": {
    "PostToolUse": [...],
    "PreCompact": [...],
    "SessionStart": [...],
    "PreToolUse": [...],
    "Stop": [...],
    "SubagentStop": [...]
  }
}
```

---

## Phases d'implémentation

### Phase 1 — Fondations (prioritaire)
- [ ] CLAUDE.md template + /forge:init
- [ ] Système de mémoire (hooks PreCompact + SessionStart)
- [ ] Hooks qualité (post-write-validate, pre-tool-security-scan)
- [ ] Agents de base (orchestrator, coder, reviewer)

### Phase 2 — Intelligence
- [ ] Agent Creator + Hook Advisor (le duo qui se consulte)
- [ ] Context Manager (gestion intelligente de la mémoire)
- [ ] /forge:review multi-agents
- [ ] /forge:status dashboard

### Phase 3 — Productivité
- [ ] /forge:parallel
- [ ] Tester agent + post-write-suggest-tests
- [ ] Architect agent + Doc-Writer
- [ ] Templates de génération

### Phase 4 — Distribution
- [ ] Plugin manifest + packaging
- [ ] Script d'installation one-liner
- [ ] Documentation
- [ ] Tests du framework lui-même