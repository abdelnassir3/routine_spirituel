# Product Requirements Document (PRD) – Application Mobile de Routines Spirituelles et d’Invocations

## 1. Introduction
Cette application mobile accompagne les utilisateurs dans leurs pratiques spirituelles, qu’elles soient quotidiennes, hebdomadaires ou mensuelles. Elle permet de créer et personnaliser des routines composées de contenus mixtes : une ou plusieurs sourates, un ou plusieurs versets, un mélange de versets provenant de différentes sourates, et/ou des textes libres personnalisés (invocations, hadiths, rappels). Chaque tâche peut inclure annotations, traduction et translittération, et être classée par **catégorie** afin de différencier les types de contenu ou les objectifs spirituels (ex. louange, protection, pardon). Un système de lecture vocale (TTS/audio) avec choix de voix et vitesse, un compteur intelligent de répétitions **persistant** (mémorisant en temps réel le nombre de répétitions restantes), et la possibilité de reprendre après interruption sont intégrés. Lors d’une fermeture brusque ou mise en pause, l’application affiche au redémarrage une fenêtre proposant soit de reprendre la routine exactement là où elle a été interrompue (en incluant l’état exact du compteur, le point précis de lecture, la tâche en cours et le thème associé), soit de la réinitialiser depuis le début. L’interface de lecture inclut des options avancées : zoom sur le texte, ajustement de la taille et du style de police, mise en évidence synchronisée du texte en cours de lecture avec l’audio, affichage bilingue côte à côte FR/AR, et mode plein écran. En mode mains libres, le compteur décrémente automatiquement et déclenche le passage à la tâche suivante une fois à zéro. L’interface et le contenu sont gérés en français et en arabe de façon distincte. Les paramètres de répétition définis par défaut pour chaque tâche sont automatiquement appliqués à chaque lancement, tout en restant modifiables par l’utilisateur pour les sessions futures.

## 2. Objectifs
- Créer un outil flexible et intuitif pour organiser des routines spirituelles personnalisées.
- Offrir un contenu composite riche et modulable avec affichage bilingue.
- Intégrer un compteur de répétitions persistant, intelligent et configurable par tâche, avec gestion complète en mode mains libres.
- Sauvegarder la progression en temps réel et permettre la reprise ou la réinitialisation après interruption.
- Appliquer automatiquement les paramètres de répétition définis par défaut pour chaque tâche à chaque lancement, tout en laissant la possibilité de les modifier.
- Passer automatiquement à la tâche suivante une fois le compteur à zéro.
- Classer et filtrer les tâches par catégories pour faciliter l’organisation.
- Fonctionner de manière fiable hors ligne.

## 3. Fonctionnalités Clés

### 3.1 Gestion des thèmes et routines
- Création, modification, suppression de thèmes.
- Association de plusieurs routines à un thème.
- Fréquences paramétrables (quotidienne, hebdomadaire, mensuelle).
- Réorganisation de l’ordre des tâches par glisser-déposer.

### 3.2 Tâches riches et flexibles
- Contenu possible :
  - Une ou plusieurs sourates complètes.
  - Un ou plusieurs versets spécifiques.
  - Mélange de versets issus de plusieurs sourates.
  - Texte libre personnalisé.
- Annotations et notes personnelles.
- Affichage bilingue : arabe, français, ou AR+FR côte à côte.
- Lecture audio humaine ou TTS.
- Paramétrage du nombre de répétitions par défaut, appliqué automatiquement à chaque lancement et modifiable pour les futures sessions.
- Classification des tâches par catégorie (objectif spirituel ou type de contenu).

### 3.3 Compteur intelligent et persistant
- Décrément automatique à chaque lecture ou validation.
- Sauvegarde automatique de la progression, y compris hors ligne.
- Mémorisation précise du nombre de répétitions restantes par tâche.
- Option de reprise ou de réinitialisation au redémarrage, avec récupération de l’état exact.
- Passage automatique à la tâche suivante lorsque le compteur atteint zéro, y compris en mode mains libres.

### 3.4 Lecture vocale et interaction
- Lecture alignée sur la langue du texte.
- TTS multilingue avec contrôle de vitesse et choix de voix.
- Mode mains libres avec enchaînement automatique des répétitions et tâches.
- Signal sonore ou vibration à chaque décrément.
- Mode « focus » pour éviter les distractions.
- Zoom sur le texte, ajustement de la taille et du style de police.
- Mise en évidence synchronisée du texte en cours de lecture avec l’audio.
- Mode plein écran.

### 3.5 Sauvegarde et hors-ligne
- Sauvegarde locale sécurisée et/ou cloud (Supabase).
- Téléchargement de textes et audios pour usage hors connexion.

### 3.6 Personnalisation et notifications
- Choix de langue pour l’interface et le contenu.
- Rappels paramétrables par routine ou thème.
- Notifications intelligentes liées aux habitudes d’usage ou aux horaires de prière.

### 3.7 Fonctions IA (optionnel)
- Suggestions automatiques de routines en fonction du profil utilisateur.
- Génération de contenus personnalisés à partir d’un thème ou d’une catégorie.
- Traductions et translittérations automatiques.

## 4. Exigences Techniques
- **Frontend** : Flutter (Android, iOS, responsive web/PC).
- **Backend** : Supabase (PostgreSQL, Auth, Storage) + option sauvegarde locale.
- **TTS** : Google Cloud TTS / Amazon Polly (FR & AR).
- **Base hors-ligne** : Drift/Isar.
- **IA** : API GPT/LLM pour suggestions et génération.

## 5. Exigences Non Fonctionnelles
- Latence UI < 200 ms.
- Accessibilité : mode sombre, taille police ajustable, compatibilité lecteurs d’écran.
- Respect du RTL pour l’arabe.
- Sécurité et confidentialité renforcées.

## 6. Critères d’Acceptation
- Création et exécution d’une routine avec compteur persistant et paramètres par défaut appliqués.
- Reprise après interruption avec choix continuer/réinitialiser, incluant l’état exact du compteur et du point de lecture.
- Lecture correcte et synchronisée du contenu en FR/AR.
- Fonctionnement hors ligne complet pour les contenus téléchargés.
- Affichage et filtrage par catégorie de tâches.

## 7. Roadmap
**Phase 1 (S1-S2)** : Maquettes, spécifications finales.
**Phase 2 (S3-S6)** : MVP avec gestion thèmes/routines/tâches, compteur persistant complet, lecture TTS/audio, reprise après interruption.
**Phase 3 (S7-S8)** : Améliorations UI/UX, bibliothèque de modèles, notifications avancées, fonctions IA basiques.
**Phase 4 (S9)** : Optimisations, tests finaux, lancement Beta.

## 8. Risques & Mitigation
- Qualité TTS → multi-fournisseurs + cache local.
- Perte de données → sauvegarde cloud + hors-ligne.
- Latence IA → pré-génération de contenu.

## 9. KPIs
- Taux de complétion des routines.
- Moyenne de répétitions réalisées par session.
- Fréquence d’utilisation de la reprise.
- Temps moyen d’exécution d’une routine.
- Engagement avec les suggestions IA.
- Utilisation et efficacité du classement par catégorie.

