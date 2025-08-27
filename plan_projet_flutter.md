Oui. Voici un plan exhaustif jusqu’à la finalisation du projet, structuré par phases, lots fonctionnels, critères d’acceptation, dépendances et risques. Il est pensé pour aboutir à une app Flutter FR/AR complète avec persistance Drift/Isar, lecteur mains libres (TTS), pipeline OCR/transcription/diacritisation, et une mise en production App Store/Play Store.

**Portée & Hypothèses**
- **Plateformes**: Android 8+/iOS 14+, Flutter stable (3.22+), Dart 3.x.
- **Persistance**: Drift (données structurées/sessions) + Isar (contenus volumineux).
- **Contenu**: textes FR/AR, corpus interne JSON, import image/PDF/audio en local.
- **Audio**: TTS natif (FlutterTTS), sans backend externe obligatoire.
- **OCR/ASR**: OCR on-device (ML Kit/Tesseract), option ASR stub (Whisper ultérieurement).
- **Confidentialité**: offline-first, aucune donnée perso externe sans consentement.
- **i18n**: FR/AR via ARB + gen-l10n, typographie RTL soignée.

**Jalons & Timeline (indicatif 10–12 semaines, 1–2 devs)**
- **S0 – Cadrage (0.5 sem)**: objectifs, UX wireframes, backlog, risques.
- **S1 – Fondations (1 sem)**: archi, navigation, thèmes, providers, CI de base.
- **S2 – Persistance (1 sem)**: schémas Drift/Isar, DAOs/services, seeds, snapshots.
- **S3 – Routines & Éditeur (1.5 sem)**: CRUD routines/tâches, éditeur FR/AR, refs.
- **S4 – Lecteur & TTS (1.5 sem)**: affichage bilingue, focus, surlignage, mains libres.
- **S5 – Pipeline Contenu (2 sem)**: OCR, transcription stub, diacritiseur, validations.
- **S6 – i18n & UX (1 sem)**: ARB, RTL, prefs d’affichage, polissage UI.
- **S7 – Qualité & Store (1.5–2 sem)**: tests, perf, RGPD, icônes, build, soumissions.

**Plan Détaillé par Piste**

**Architecture & Fondations**
- **Structure**: `lib/app` (entrée, router, thème), `lib/core` (models, services, utils), `lib/features` (pages), `lib/data` (drift/isar), `assets` (corpus, i18n).
- **Routing**: GoRouter avec `MaterialApp.router`, routes nommées, deep-link simple.
- **State**: Riverpod/ProviderScope, providers global (session, progress, prefs).
- **UI/Thème**: ThemeData light/dark, couleurs accessibles, textTheme AR/FR.
- **CI**: GitHub Actions: `flutter analyze`, `format --set-exit-if-changed`, `test`.

**Persistance (Drift/Isar)**
- **Drift Tables**: `Themes`, `Routines`, `Tasks` (ordre, refs, type), `Sessions`, `TaskProgress`, `Snapshots`, `UserSettings`.
- **DAOs**: CRUD + requêtes composites (tâches par routine, progression courante).
- **Isar Collections**: `ContentDoc` (taskId, locale, kind, raw/corrected/diacritized/validated), `VerseDoc` (surah/ayah/textAr/textFr).
- **Services**: `SessionService`, `ProgressService`, `ContentService`, `QuranCorpusService`, `PersistenceService` (snapshot/restore/auto-save).
- **Seeds**: routine exemple, contenu minimal FR/AR, corpus de test JSON en `assets/corpus`.
- **Sauvegarde**: snapshot périodique (timer), détection d’interruption, reprise guidée.

**Routines & Éditeur**
- **Pages**: Home (reprise/continuer), Routines (liste, démarrer), RoutineEditor (ordre, refs), ContentEditor (FR/AR).
- **Références**: parser refs (`parseRefs`) type `Surah:Ayah-Ayah`, validation via `QuranCorpusService`.
- **Édition**: import FR/AR, onglets, sauvegarde Isar, validation des champs requis.
- **UX**: drag & drop tâches, confirmations suppression, indicateurs d’état (validé/à faire).

**Lecteur & TTS (Mains Libres)**
- **Affichage**: bilingue (FR/AR), prefs d’affichage (bilingue/mono), RTL correct.
- **Focus/Surlignage**: `highlightController`, `focusMode` pour minimiser distractions.
- **Mains libres**: contrôleur TTS (lecture, pause, vitesse, voix), auto-défilement, surlignage synchronisé.
- **Paramètres**: voix/speed par locale, beep/haptics optionnels, reprise au dernier point.

**Pipeline Contenu (OCR/Transcription/Diacritiseur)**
- **OCR**: import image/PDF, pages multiples, ML Kit/Tesseract wrapper, découpage.
- **Transcription**: stub (local), interface pour intégration Whisper ultérieure.
- **Diacritiseur**: service HTTP configurable (URL, clé), stub offline pour dev.
- **États**: `raw` → `corrected` → `diacritized` → `validated` avec métadonnées (source, score).
- **Éditeur de pipeline**: écran pour lancer, afficher erreurs, marquer comme validé.

**i18n & Typographie**
- **ARB**: `lib/l10n/arb/app_fr.arb`, `app_ar.arb`, génération via `gen-l10n`.
- **RTL**: `Directionality`, fonts AR (Amiri, Noto Naskh), fallback, ligatures.
- **Traductions**: textes UI complets, formats de dates/nombres locaux.

**Reprise & Résilience**
- **Autosave**: intervalle adaptatif (activité), flush sur `AppLifecycleState.paused`.
- **Reprise**: dialogue au lancement si session interrompue, choix “reprendre/ignorer”.
- **Bords**: fin de routine (auto-avance/arrêt), tâches vides, TTS indispo, permissions refusées.

**Qualité, Tests & Perf**
- **Tests unitaires**: parsers, services persistance, diacritiseur (stub/mocks).
- **Widget tests**: navigation, éditeur, lecteur (goldens AR/FR).
- **Intégration**: flows clés (créer routine → lire → reprise).
- **Perf**: jank ≤ 16ms, mémoire stable sur longs textes, TTS non bloquant.
- **Accessibilité**: contrastes AA, tailles dynamiques, lecteurs d’écran, focus traversal.
- **Logs**: niveaux, redaction données, analytics optionnel (désactivable), Sentry.

**Distribution & Conformité**
- **Permissions**: Android `RECORD_AUDIO`/`READ_EXTERNAL_STORAGE`, iOS `NSMicrophoneUsageDescription`/`NSPhotoLibraryUsageDescription`.
- **Icônes/branding**: `flutter_launcher_icons`, splash, couleurs de thème cohérentes.
- **Polices**: licences vérifiées/embarquées, cache.
- **RGPD**: politique de confidentialité, écran consentement si endpoints externes.
- **Builds**: Fastlane GitHub Actions (beta), signing, TestFlight/Closed testing.

**Livrables par Sprint (extraits)**
- **S1**: squelette app fonctionnel, routes, thème, CI verte.
- **S2**: schémas Drift/Isar + services, seeds, snapshots de base.
- **S3**: CRUD routines/tâches, éditeur FR/AR minimal, validations refs.
- **S4**: lecteur bilingue avec TTS mains libres, surlignage/sync.
- **S5**: pipeline OCR/diacritiseur opérationnel avec écran de suivi.
- **S6**: i18n complet FR/AR, RTL nickel, prefs persistées.
- **S7**: suite de tests robuste, perf validée, builds signés, kits stores.

**Critères d’Acceptation (résumé)**
- **Routines**: créer/éditer/ordonner/supprimer; validation des champs; UX sans crash.
- **Lecteur**: bascule FR/AR/bilingue; TTS contrôlable; surlignage synchronisé.
- **Pipeline**: importer image/PDF/audio; diacritiser; corriger/valider; états persistés.
- **Persistance**: autosave + reprise; fin de routine gérée.
- **i18n/RTL**: 100% UI traduite; typographie AR lisible; direction correcte.
- **Qualité**: >80% couverture unités clés; 0 jank visible; a11y basique OK.
- **Distribution**: builds CI, icônes, permissions, politique confidentialité prête.

**Dépendances & Pré-requis**
- **Plugins**: `flutter_tts`, `isar`, `drift`, `go_router`, OCR (mlkit/tesseract wrapper).
- **Env**: clés optionnelles diacritiseur; configuration `secrets` CI.
- **Assets**: corpus JSON FR/AR, polices AR, images d’icônes.

**Risques & Mitigations**
- **OCR qualité**: textes arabes complexes → réserver Tesseract custom, post-correction manuelle.
- **Sync TTS/surlignage**: granularité par token difficile → opter phrase/verset, fallback.
- **Perf Isar volumétrie**: indexer champs, pagination, lazy load.
- **Permissions refusées**: parcours sans OCR/ASR, messages clairs, alternatives.
- **Endpoints externes**: diacritiseur down → stub local; timeouts + retry.

**Backlog “Plus” (post-MVP)**
- **Cache audio**: pré-synthèse TTS et cache local.
- **Stats & gamification**: séries, objectifs, historique détaillé.
- **Export/Import**: routines en JSON, partage.
- **Whisper local/serveur**: meilleure transcription.
- **Thèmes avancés**: mode focus profond, couleurs personnalisées.

**Prochaines Étapes Actionnables**
- **Alignement**: valider hypothèses (OCR/ASR niveau, scope offline, stores cibles).
- **Backlog**: créer tickets par item ci-dessus avec critères d’acceptation et estimation.
- **Fondations**: mettre en place ARB, thèmes, routes, CI, schémas persistences.
- **Corpora**: ajouter `assets/corpus/*.json`, polices AR/FR, exemples de routines.
- **Plan de tests**: définir scénarios e2e prioritaires et golden tests.

Souhaitez-vous que je décline ce plan en backlog JIRA/GitHub Issues prêt à créer, avec titres, descriptions, critères d’acceptation et estimations par tâche? Je peux aussi adapter le calendrier à votre capacité (1 vs 2 devs) et prioriser un MVP plus court si nécessaire.
