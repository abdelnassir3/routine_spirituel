# Glossaire — Routines Spirituelles
**Vocabulaire métier, technique et acronymes du projet**

## Vocabulaire Métier / Domaine

### Termes Spirituels
- **Dhikr** (ذِكْر) : Invocation, rappel d'Allah. Pratique de répétition de formules sacrées
- **Wird** (وِرْد) : Routine spirituelle quotidienne composée de plusieurs dhikr
- **Tasbih** (تَسْبِيح) : Glorification, formule "Subhan Allah" 
- **Awrad** (أَوْرَاد) : Pluriel de wird, ensemble de routines
- **Du'a** (دُعَاء) : Invocation personnelle, prière libre
- **Adhkar** (أَذْكَار) : Pluriel de dhikr, collection d'invocations

### Catégories Spirituelles (task_category.dart)
- **Louange** (louange) : Invocations de glorification 📿
- **Protection** (protection) : Invocations de protection 🛡️
- **Pardon** (pardon) : Demandes de pardon 🤲
- **Guidance** (guidance) : Demandes de guidée 🌟
- **Gratitude** (gratitude) : Remerciements 🙏
- **Guérison** (healing) : Invocations de guérison 💚
- **Personnalisé** (custom) : Catégorie libre ✨

### Types de Contenu
- **Surah** : Chapitre du Coran (114 au total)
- **Ayah/Verset** : Verset d'une sourate
- **Mixed** : Combinaison sourate + versets spécifiques
- **Text** : Texte libre (du'a, invocation)

## Acronymes Techniques

### Frameworks & Libraries
- **TTS** : Text-To-Speech (synthèse vocale)
- **OCR** : Optical Character Recognition (reconnaissance de texte)
- **RTL** : Right-To-Left (direction arabe)
- **LTR** : Left-To-Right (direction latine)
- **PWA** : Progressive Web App
- **ARB** : Application Resource Bundle (format i18n Flutter)

### Architecture
- **CRUD** : Create, Read, Update, Delete
- **DAO** : Data Access Object
- **UI** : User Interface
- **UX** : User Experience  
- **API** : Application Programming Interface
- **SDK** : Software Development Kit

### Performance
- **TTI** : Time To Interactive
- **FPS** : Frames Per Second
- **LCP** : Largest Contentful Paint
- **FID** : First Input Delay
- **CLS** : Cumulative Layout Shift

## Concepts Techniques Projet

### Persistance
- **Drift** : ORM SQL pour Flutter (anciennement Moor)
- **Isar** : Base NoSQL embarquée haute performance
- **Session Snapshot** : Capture complète de l'état pour reprise
- **Recovery Options** : Choix de récupération après interruption

### Audio
- **Audio Queue** : File d'attente pour lecture séquentielle
- **Audio Service** : Service Android/iOS pour audio background
- **TTS Cache** : Stockage local des synthèses vocales
- **Cloud Voices** : Voix premium via API cloud

### Features
- **Smart Counter** : Compteur avec décrément intelligent et persistance
- **Hands-Free Mode** : Mode mains libres avec auto-avance
- **Focus Mode** : Mode lecture immersif sans distractions
- **Reading Prefs** : Préférences de lecture (taille, police, espacement)

### État & Navigation
- **Riverpod** : State management réactif
- **Provider** : Fournisseur de dépendances Riverpod
- **go_router** : Routing déclaratif Flutter
- **AsyncValue** : Wrapper pour états asynchrones

## Entités de Données Principales

### RoutineTheme
- Thème regroupant plusieurs routines
- Fréquence : daily, weekly, monthly
- Métadonnées : configuration additionnelle

### SpiritualTask  
- Tâche spirituelle atomique
- Type : surah, verses, mixed, text
- Répétitions : nombre de fois à réciter
- Settings : audio, display configurations

### TaskProgress
- État d'avancement d'une tâche
- Position : mot et verset courants
- Remaining : répétitions restantes
- State : active, paused, completed

### SessionState
- État global de la session de prière
- Current task : tâche en cours
- Elapsed time : durée écoulée totale
- Interruption : détection et récupération

## Événements & États Clés

### Lifecycle Events
- **App Launch** : Détection session interrompue
- **Session Start** : Début routine spirituelle
- **Task Complete** : Fin d'une tâche, passage suivante
- **Session End** : Completion routine complète
- **Auto-Save** : Sauvegarde périodique (5s)

### User Actions
- **Tap Counter** : Décrément manuel compteur
- **Swipe Task** : Navigation entre tâches
- **Toggle Audio** : Play/pause TTS
- **Switch Language** : Bascule FR/AR
- **Enter Focus** : Mode immersif

### System States
- **Online/Offline** : Détection connectivité
- **Background/Foreground** : État application
- **Audio Focus** : Gestion focus audio OS
- **Permission State** : État permissions (audio, storage)

## Métriques & KPI

### Engagement
- **DAU** : Daily Active Users
- **MAU** : Monthly Active Users  
- **D30** : Rétention à 30 jours

### Performance
- **P95** : 95e percentile latence
- **QPS** : Queries Per Second
- **TTL** : Time To Live (cache)

### Business
- **ARPU** : Average Revenue Per User
- **CAC** : Customer Acquisition Cost
- **LTV** : Lifetime Value

## Conventions Projet

### Nommage
- **Pages** : *Page (ex: ModernHomePage)
- **Services** : *Service (ex: AudioTtsService)
- **Providers** : *Provider (ex: themeProvider)
- **Models** : *Model ou sans suffixe

### Fichiers
- **.dart** : Code Dart/Flutter
- **.arb** : Fichiers localisation
- **.g.dart** : Fichiers générés (ne pas éditer)
- **.md** : Documentation Markdown

### Versions
- **v0.1.0** : Version actuelle prototype
- **v1.0** : Release mobile iOS/Android
- **v1.5** : Support Web beta
- **v2.0** : Multi-plateforme complet