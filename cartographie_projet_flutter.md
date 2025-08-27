# Cartographie du Projet Flutter - Routines Spirituelles

## Aperçu
- **Objectif**: Application Flutter FR/AR de routines spirituelles avec lecteur, compteur “mains libres”, OCR/Transcription, diacritiseur, et persistance locale.
- **État**: Ossature fonctionnelle avec navigation, thèmes, modèles, persistance Drift/Isar, écrans Home/Routines/Reader/Settings/Éditeur de contenu.
- **Docs**: `README.md`, PRD/Conception (`PRD_App_Routines_Spirituelles_AI.md`, `prd_conception_complete.md`), backlog (`jira_backlog_prd.md`, `backlog_jira.csv`).

## Tech Stack
- **Flutter/Dart**: `flutter_riverpod`, `go_router`, `intl`, `dio`.
- **Persistance**: Drift (SQLite) pour structure/état; Isar pour contenus et corpus (versets).
- **Audio/TTS**: `flutter_tts` + service d’abstraction.
- **OCR/PDF**: MLKit (`google_mlkit_text_recognition`) + `native_pdf_renderer`, stubs Tesseract.
- **Fichiers/Permissions**: `file_picker`, `image_picker`, `permission_handler`.
- **Build tooling**: `build_runner`, `freezed` (annotations présentes; pas de modèles Freezed dans ce repo).

## Structure
- `lib/app/`: `router.dart` (GoRouter), `theme.dart` (Material 3 + Inter/NotoNaskh).
- `lib/core/`: modèles, repositories, persistance (`drift_schema.dart` + DAOs, `isar_collections.dart`), services (AI/Audio/OCR/Transcription/Diacritiseur/Persistence/Content/Corpus/Progress/UserSettings).
- `lib/features/`:
  - `home/`: reprise de session (dialog modal à l’ouverture).
  - `routines/`: liste + seed d’exemple + éditeur de tâches (reorder/dismiss/edit).
  - `reader/`: lecteur bilingue (AR/FR) + mode focus + highlight auto + barre de compteur.
  - `content/`: éditeur FR/AR (source manuelle, image OCR, PDF OCR, audio→texte, diacritisation).
  - `settings/`: import du corpus (assets/fichier), préférences d’affichage, diacritiseur.
  - `counter/`: contrôleur mains libres (TTS + décrément automatique).
  - `session/`: état global de session.
- `assets/`: polices; dossier `assets/corpus/` attendu pour JSONs du Coran.

## Modèle de Données (Drift + Isar)
- **Drift tables**: `Themes`, `Routines`, `Tasks`, `Sessions`, `TaskProgress`, `Snapshots`, `UserSettings`.
- **Isar collections**: `ContentDoc` (contenus FR/AR d’une tâche, pipeline raw→corrected→diacritized→body), `VerseDoc` (corpus AR/FR par `surah/ayah`).
- **Providers**: DAOs exposés via Riverpod; services orchestrent les opérations.

## Flux Clés
- **Démarrage routine**: `SessionService.startRoutine()` crée session, init `TaskProgress` par `defaultReps`, puis `ReaderPage`.
- **Reprise**: `DriftPersistenceService.detectInterruption()` + `HomePage` propose Resume/Reset (snapshots en DB).
- **Lecteur**: `current_progress.dart` sélectionne la tâche courante; `ReaderPage` affiche AR/FR selon préférence; bouton “Mains libres” active TTS + highlight par mots.
- **Éditeur de routine**: CRUD de `Tasks` + contenu (FR/AR) + références (verses/surah).
- **Éditeur de contenu**: importe texte (image/PDF/audio) → corrections → diacritisation (via provider HTTP ou stub) → validation finale.
- **Import corpus**: `SettingsPage` → `CorpusImporter` lit `assets/corpus/*.json` ou un fichier choisi → insertions chunkées dans Isar.

## Écrans
- **HomePage**: carte reprise, navigation Routines/Settings.
- **RoutinesPage**: liste, démarrage session, bouton “Créer un exemple” qui seed un thème+routine+3 tâches avec contenu FR/AR.
- **RoutineEditorPage**: liste réordonnable, suppression, édition avec validations (références, répétitions, notes).
- **ReaderPage**: affichage bilingue (AR/FR ou mono), mode focus, barre compteur (-1, mains libres).
- **SettingsPage**: import de corpus, test (2:255), préférences d’affichage, config diacritiseur.
- **ContentEditorPage**: onglets FR/AR, choix de source, import via `FilePicker`, mise à jour Isar, diacritisation AR.

## Services Notables
- **ProgressService**: init/lecture de la tâche en cours, décrément, timestamp.
- **ContentService**: lecture/écriture Isar; reconstruction de texte depuis références avec `QuranCorpusService`; getters d’édition.
- **DriftPersistenceService**: snapshots/restore, auto-save, interruption/reprise, sync stub.
- **HandsFreeController**: boucle TTS + décrément; highlight FR synchronisé simple (timer).

## Points à Vérifier / Incohérences
- Test template: `test/widget_test.dart` référence `MyApp` alors que l’app est `SpiritualRoutinesApp` → test brisera; à corriger ou supprimer.
- Partie vue: certains fichiers affichés semblent tronqués dans l’aperçu (p.ex. fin de `content_editor_page.dart`). À ouvrir localement pour confirmer l’intégrité; mais l’ossature globale est claire.
- i18n: `gen-l10n` non branché; `l10n/app_localizations.dart` est un placeholder.
- Assets corpus: `assets/corpus/` vide par défaut; l’import affichera une erreur tant qu’aucun JSON n’est fourni.
- Permissions mobiles: à compléter dans `AndroidManifest.xml`/`Info.plist` selon usages OCR/Pick/Audio.

## Commandes Utiles
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Suggestions
- Corriger le test widget pour correspondre à `SpiritualRoutinesApp`.
- Vérifier/compléter les morceaux potentiellement incomplets (`content_editor_page.dart`).
- Ajouter un petit corpus d’exemple dans `assets/corpus` pour tester le lecteur et l’import.
