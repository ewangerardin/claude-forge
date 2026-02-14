# Forge Heartbeat — Claude Forge

## Checks au demarrage
- [ ] Tests passent ? (`bash .claude/hooks/session-start-restore.sh`)
- [ ] Branche courante et etat du git ?
- [ ] Taches en cours dans MEMORY.md ?
- [ ] Erreurs recurrentes dans errors.md a surveiller ?

## Etat courant
- Branche : main
- Derniere action : Implementation OpenClaw features (P0-P2)
- Prochaine priorite : Phase 3 (parallel, tester, doc-writer)

## Notes
- Le PreCompact utilise maintenant un prompt cognitif (type: prompt) au lieu d'un script shell seul
- Daily logs dans .claude/memory/daily/ avec nettoyage auto > 30 jours
- Identity separee en SOUL.md / USER.md / CONVENTIONS.md
