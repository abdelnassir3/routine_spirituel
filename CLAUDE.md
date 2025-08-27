# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Contexte du Projet

Application mobile de routines spirituelles bilingue (français/arabe) développée avec Flutter. L'application permet aux utilisateurs de créer et suivre des routines de prières et invocations avec compteur persistant, TTS multi-langue, et mode hors-ligne complet.

## Architecture Technique

**Stack principal :**
- Framework : Flutter 3.x avec Dart 3.x
- State Management : Riverpod 2.x
- Navigation : go_router
- Base de données : Drift (SQL) + Isar (NoSQL)
- Localisation : flutter_localizations + intl
- Audio/TTS : just_audio, audio_service, flutter_tts

## Commandes Essentielles

```bash
# Installation et configuration initiale
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Développement
flutter run                                              # Lancer l'app en mode debug
flutter run --release                                    # Mode release pour tests performance

# Génération de code (OBLIGATOIRE après modifications des modèles)
dart run build_runner build --delete-conflicting-outputs # Génère Drift/Isar/freezed
dart run build_runner watch --delete-conflicting-outputs # Mode watch pour dev

# Tests et qualité
flutter test                                             # Tests unitaires et widgets
flutter analyze                                          # Analyse statique du code
dart format .                                           # Formatage du code

# Build pour production
flutter build apk --release                            # Android APK
flutter build appbundle --release                      # Android App Bundle
flutter build ios --release                            # iOS (nécessite Mac)
flutter build ipa --release                            # iOS App Store
```

## Architecture et Organisation du Code

### Structure Modulaire en Couches

```
lib/
├── app/           # Configuration globale (routing, thème)
├── core/          # Logique métier partagée
│   ├── models/    # Modèles de données avec freezed/json_annotation
│   ├── persistence/ # Couche de persistance Drift + Isar
│   ├── repositories/ # Pattern Repository pour l'accès aux données
│   └── services/  # Services métiers (IA, audio, OCR, session)
├── features/      # Modules fonctionnels par domaine
│   ├── counter/   # Compteur intelligent avec mode mains-libres
│   ├── reader/    # Interface de lecture avec synchronisation audio-texte
│   ├── routines/  # Gestion des routines et thèmes
│   └── session/   # État de session et reprise après interruption
└── l10n/         # Localisation FR/AR avec ARB files
```

### Patterns Architecturaux Clés

1. **Clean Architecture** : Séparation claire entre UI, logique métier et données
2. **Repository Pattern** : Abstraction de l'accès aux données avec cache local
3. **Service Layer** : Services singleton pour les fonctionnalités transverses
4. **State Management Riverpod** : Providers immutables avec AsyncValue pour états async

### Services Critiques

- **PersistenceService** : Sauvegarde automatique et récupération de session avec Drift
- **SessionService** : Gestion de l'état global de la session de prière
- **AudioTtsService** : TTS multi-langue avec gestion de la queue audio
- **QuranCorpusService** : Accès au corpus Coran hors-ligne depuis assets/corpus/

## Points d'Attention Spécifiques

### Gestion Bilingue FR/AR

- **RTL Support** : Utiliser `Directionality` widget pour l'arabe
- **Polices** : Inter pour FR, NotoNaskhArabic pour AR (dans assets/fonts/)
- **Localisation** : ARB files dans lib/l10n/ avec génération automatique

### Persistance et Reprise de Session

- **Auto-save** : Sauvegarde toutes les 5 secondes pendant une session active
- **Reprise** : Détection automatique de session interrompue au démarrage
- **Compteur** : État persistant avec position exacte dans le texte

### Mode Hors-Ligne

- **Corpus Coran** : JSON dans assets/corpus/quran_combined.json
- **Cache TTS** : Audio généré stocké localement avec flutter_secure_storage
- **Sync différée** : Queue de synchronisation pour mode online

### Performances Cibles

- Démarrage app < 2 secondes
- Latence UI < 200ms
- Memory usage < 150MB
- Bundle size < 35MB

## Flux de Développement de Fonctionnalités

1. **Modèles** : Définir dans core/models/ avec freezed annotations
2. **Persistence** : Ajouter tables Drift ou collections Isar
3. **Repository** : Créer repository avec méthodes CRUD
4. **Service** : Implémenter logique métier dans services/
5. **UI** : Créer feature dans features/ avec providers Riverpod
6. **Tests** : Ajouter tests unitaires et d'intégration

## Conventions et Standards

- **Null Safety** : Toujours utiliser null safety strict
- **Error Handling** : Pattern Result<T> ou Either pour les erreurs
- **Async** : Préférer FutureProvider et StreamProvider de Riverpod
- **Tests** : Coverage minimum 80% pour services critiques
- **Documentation** : Commentaires en français pour la logique métier