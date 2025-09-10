---
description: Génère un message de commit (Conventional Commits) à partir du diff *staged* puis commit.
allowed-tools:
  - Bash(git status:*)
  - Bash(git diff --staged:*)
  - Bash(git commit -m:*)
---

1) Lis `git status` et `git diff --staged`.
2) Propose un message **type(scope): résumé** + body concis.
3) Affiche d’abord:
COMMIT: <message>
4) Si cohérent, exécute:
git commit -m "<message>"
