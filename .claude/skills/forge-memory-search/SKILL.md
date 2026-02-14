# /forge:memory-search — Recherche dans la memoire Forge

## Usage
L'utilisateur invoque cette skill quand il cherche une information dans la memoire
persistante : une decision passee, une erreur deja resolue, un pattern detecte,
ou un contexte de session anterieure.

## Etapes

1. **Identifie les termes de recherche** a partir de la demande de l'utilisateur

2. **Cherche dans les fichiers memoire** avec grep recursif :
   - Utilise l'outil Grep avec le pattern sur `.claude/memory/` (include `*.md`)
   - Mode `content` avec contexte (3 lignes avant/apres)

3. **Si pas de resultats**, essaye des variantes :
   - Termes plus larges ou synonymes
   - Recherche dans les noms de fichiers avec Glob : `.claude/memory/**/*{terme}*`
   - Liste les daily logs recents : Glob `.claude/memory/daily/*.md`

4. **Presente les resultats** de maniere structuree :
   - Fichier source et numero de ligne
   - Contexte (3 lignes avant/apres le match)
   - Date si c'est un daily log

5. **Si l'utilisateur cherche "quand est-ce qu'on a decide..."** :
   - Cherche d'abord dans `decisions.md`
   - Puis dans les daily logs
   - Affiche la date et le contexte de la decision

## Exemples d'invocation
- `/forge:memory-search JWT` — cherche toute mention de JWT
- `/forge:memory-search decision auth` — cherche les decisions liees a l'auth
- `/forge:memory-search erreur prisma` — cherche les erreurs Prisma et leurs solutions
- `/forge:memory-search quand hook` — cherche quand les hooks ont ete modifies
