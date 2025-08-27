J’ai lu les deux PRD. Voici une conception complète et opérationnelle.

**Vision & Principes**
- Ergonomie: une main, friction minimale, reprise instantanée, retour haptique.
- Offline-first: tout fonctionne sans réseau; sync opportuniste et sûre.
- Bilingue/RTL: FR/AR distincts, alternance fluide, alignements impeccables.
- Accessibilité: tailles dynamiques, contrastes AA/AAA, lecteur d’écran.
- Performance: 60 fps, I/O en isolates, caches agressifs, audio robuste.

**Navigation & IA**
- Sections: `Aujourd’hui` (reprise rapide + suggestions IA), `Routines`, `Bibliothèque`, `Progression`, `Réglages`.
- Flows clés: onboarding (langue/voix/tailles), création routine, lecture synchronisée, mains libres, reprise après interruption.
- Recherche: versets, sourates, invocations, catégories; filtres multi-tags.
- IA: suggestions personnalisées de routines, ajustements de répétitions, génération de contenus (invocations/rappels), traduction/translittération.

**Écrans**
- Onboarding: choix FR/AR, sens LTR/RTL, polices (AR: Amiri/Scheherazade/Noto Naskh; FR: Inter), pack hors-ligne (texte + traductions), voix TTS, thème clair/sombre.
- Aujourd’hui: carte “Reprendre” (snapshot exact), rappels du jour, suggestions IA, accès rapide “Nouvelle routine”.
- Routines: liste par thèmes, indicateurs fréquence, DnD pour ordre des tâches, duplication, modèles.
- Éditeur de routine: builder par blocs (Sourate, Verset(s), Mix, Texte libre), répétitions par défaut, catégorie, notes, affichage AR/FR, audio/TTS.
- Bibliothèque: Coran (sourates/versets avec picker et multi-sélection), invocations préchargées, mes notes, téléchargements hors-ligne.
- Lecture/Player: affichage bilingue côte-à-côte ou alterné, surlignage synchrone, zoom/tailles/styles, plein écran, compteur intelligent, barre audio avec vitesse/voix, bouton mains libres, gestes (tap=−1, double‑tap=−5, swipe=task suivante), retour haptique/audio.
- Modale de reprise: “Reprendre exactement” vs “Réinitialiser”, détail du point, compteur, tâche, thème.
- Progression: séries, temps cumulé, achèvements, heatmap calendrier, insights IA.
- Réglages: voix/TTS, téléchargements, notifications/pg_cron, haptique/sons, confidentialité/exports, sauvegarde/synchronisation.

**Ergonomie clé**
- Touches 44px+, contrôles bas de l’écran (reachable), grandes cibles.
- Focus mode: UI épurée, verrouillage gestes, luminosité adaptée.
- Haptique: léger à chaque décrément, plus fort à zéro; son discret optionnel.
- Gestes: swipe latéral tâche ±1, long‑press pause, slider vitesse TTS.
- Mode mains libres: auto-décrément + auto-avance, verrouillage écran, écouteurs boutons mappés.

**Design System**
- Couleurs: palette apaisante (verts/indigos) + Material You/iOS semantic, haut contraste; mode sombre complet.
- Typo: AR (Naskh lisible), FR (Inter); ligatures AR, contrôle kashida; tailles adaptatives.
- Composants: `CategoryChip` avec emoji, `CounterChip`, `AudioBar`, `BilingualToggle`, `ReadingPane`, `ResumeBanner`, `TaskCard` DnD.
- Motion: transitions discrètes, micro‑animations (Lottie optionnel), 60 fps.
- Icono: SF Symbols/Material Icons, cohérence RTL (miroirs contextuels).

**Stack & Architecture**
- App: Flutter 3.x, Riverpod 2.x (state immutable), `go_router` (routes déclaratives).
- Données locales: Drift (SQL relationnel: routines, tâches, sessions) + Isar (documents: contenus volumineux, caches TTS/alignements).
- Backend: Supabase (Postgres, Auth, Storage, Realtime; `pg_cron` pour rappels), Redis (sessions optionnel).
- Audio/TTS: `just_audio` + `audio_service`; TTS Google Cloud (principal) + Amazon Polly (fallback); cache audio local par hash SSML.
- IA: OpenAI/Claude via service abstrait; cache prédictif; clés sécurisées.
- Réseau: Dio + interceptors (retry, cache ETag, trace).
- Observabilité: Firebase Analytics, Sentry; feature flags.
- CI/CD: GitHub Actions, tests unités/widget/intégration, distribution Firebase.

**Modèles & Tables (principales)**
- `themes`: `id`, `name_fr`, `name_ar`, `frequency`, `created_at`, `metadata`.
- `routines`: `id`, `theme_id`, `name_fr`, `name_ar`, `order`, `is_active`.
- `tasks`: `id`, `routine_id`, `type` (surah|verses|mixed|text), `category`, `default_reps`, `audio_settings`, `display_settings`, `content_ref` (vers document Isar), `notes_fr/ar`.
- `contents` (Isar): `id`, `locale`, `kind`, `payload` (texte, références sourate/versets, translit, traductions), `tts_cache_keys`.
- `sessions`: `id`, `routine_id`, `started_at`, `ended_at`, `state` (active|paused|completed), `snapshot_ref`.
- `task_progress`: `id`, `session_id`, `task_id`, `remaining_reps`, `elapsed_ms`, `text_cursor` (mot/verset), `last_update`.
- `snapshots`: `id`, `session_id`, `payload` (JSON compressé), `created_at`.
- `user_settings`: `id`, `user_id`, `language`, `rtl_pref`, `font_prefs`, `tts_voice`, `speed`, `haptics`, `notifications`.

**Persistance & Reprise**
- Snapshot incrémental debouncé (p. ex. 500 ms) sur changements critiques: décrément, navigation, curseur texte, audio pos.
- Restauration atomique: transaction + mise en place UI/Audio/Compteur à l’identique; modale proposition reprise/réinit.
- Sauvegarde crash-safe: WAL + checkpoints; tests de coupure brutale.
- Sync cloud: last-write-wins pour metadata; sessions en local par défaut (option backup), consolidation des compteurs (merge par timestamp).

**Lecture synchronisée**
- SSML + speech marks pour timings; si indisponible: heuristique syllabique + alignement par texte; dictionnaire AR pour pauses.
- `HighlightStream`: émet `wordIndex/verseIndex`, mis en phase avec `just_audio` position; tolérance drift avec correctifs périodiques.

**Mode mains libres**
- `SmartCounter`: décrément via marqueurs audio/voix; auto-avance à zéro; réglage délai entre tâches, confirmation sonore.
- Verrouillage gestuel, prévention veille (wake lock), low‑power adaptatif.

**Hors-ligne & Caches**
- Packs: Coran AR + traductions FR, translittérations; téléchargements par lot; vérification ETag.
- Cache TTS: clé par texte+voix+vitesse; LRU et quotas; gestion stockage.
- Requêtes: cache 80%+, backoff réseau, reprise.

**Notifications & Rappels**
- Local scheduling par fréquence thème/routine; `pg_cron` pour sync cloud; deep‑links vers reprise.
- Respect DND; regroupement; action “Reprendre”.

**Sécurité & Vie privée**
- Chiffrement local (Drift chiffré/SQLCipher; Isar encryption); clés dans `flutter_secure_storage`.
- PII minimale; analytics opt‑in; export/import chiffré; RGPD (suppression compte, data portability).

**Accessibilité & RTL**
- Semantics, labels descriptifs, ordre focus logique; tests capture écran RTL; gestes alternatifs pour lecteurs d’écran.
- Contrastes vérifiés; tailles dynamiques; options daltonisme.

**Tests**
- Unitaires: logique compteur, snapshot, filtres catégories.
- Widget: lecture bicolonne, modale reprise, DnD éditeur.
- Intégration: mains libres, audio focus, interruptions (appel, écouteurs).
- Golden tests: LTR/RTL, sombre/clair, grandes polices.
- Perf: jank < 1%, démarrage < 2s, mémoire < 150MB.

**API locales & Services (interfaces)**
- `TaskRepository`, `RoutineRepository`: CRUD + flux par catégorie.
- `PersistenceService`: `autoSave`, `captureSnapshot/restore`, `syncWithCloud`, `watchSyncStatus`.
- `AIService`: `suggestRoutines(profile)`, `generateContent(theme, category, lang)`, `translate`, `transliterate`, `analyzeUserPattern`.
- `ReadingController`: `buildBilingualView`, `syncAudioWithText`, `adjustReadingSpeed`, `buildTextHighlight`.
- `SmartCounter`: `decrementWithFeedback`, `shouldAutoAdvance`, `watchHandsFreeMode`.

**Roadmap**
- MVP (S1–S4): structure clean, DB Drift/Isar, éditeur routines, lecture bilingue, compteur persistant, reprise, TTS + cache, hors‑ligne de base, notifications, FR/AR, tests >80%.
- V1 (S5–S8): sync Supabase, IA suggestions/génération, audio‑texte sync avancé, mains libres complet, analytics/Sentry, polissage UX.
- V1.1+: widgets écran d’accueil, Shortcuts/Siri/App Intents, WearOS/Watch, thèmes dynamiques, partage modèles, export/backup cloud.

