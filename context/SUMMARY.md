# Mémos Projet - Projet_sprit

---

## [2025-08-27 14:30] Projet_sprit | memo | SPARC Development Environment

### CONTEXTE
Flutter 3.x • App mobile routines spirituelles bilingue FR-AR • Stack: Riverpod 2.5+, Drift/Isar, Material Design 3, just_audio, TTS hybride (Edge-TTS/Coqui/APIs Quran), OCR ML Kit/Tesseract • Plateformes: iOS/Android (95%), macOS Beta (60%), Web expérimental (40%) • Modules clés: smart_tts_service, quran_content_detector, hybrid_audio_service, secure_storage_service

### CONTRAINTES
Techniques: Latence UI <200ms, TTI <2s, mémoire <150MB, bundle <35MB • Sécurité: AES-256, biométrique+PIN, HTTPS+pinning, OWASP B+ (85/100), logs PII filtrés • Performance: TTS <450ms P95, cache hit 85%, crash <0.1% • Offline-first: fonctionnement complet sans connexion, cache 7j/100MB TTS, 30j Quran

### DÉCISIONS
- Architecture TTS: Edge-TTS (168.231.112.71:8010) priorité + APIs Quran spécialisées + Flutter TTS fallback 
- BDD: Drift (SQL) + Isar (NoSQL), isar_generator temporairement désactivé (conflit freezed 3.2.0)
- Tests: Coverage 60% min (80% services critiques), 45+ tests créés
- Circuit breaker: 5 échecs → fallback auto
- RTL/LTR: Noto Naskh Arabic + Inter, auto-détection direction

MANQUANTES: Config Supabase, production HTTPS endpoints, build.sh script

### TODO PRIORISÉ
1. Réactiver isar_generator après résolution conflit freezed
2. Implémenter endpoints HTTPS production + certificate pinning
3. Finaliser tests coverage 60%+ (actuellement 45+ tests)
4. Configurer Supabase pour sync multi-devices
5. Créer scripts/build.sh pour CI/CD production
6. Monitoring crash rate et métriques P95
7. Documentation technique à jour (tests, déploiement)

### ERREURS RÉSOLUES
- Edge-TTS endpoint stabilisé 168.231.112.71:8010 
- Design system M3 réparé (colors, shadows, typography, secure_logging)
- 72 dépendances mises à jour, js package forcé 0.7.2
- TabController crash fixé, doublons/orphelins nettoyés
- Responsiveness web/macOS améliorée

### PARAMÈTRES CRITIQUES
Endpoints: Edge-TTS :8010/api/tts, Coqui :8001/api/xtts • Timeouts: 15s • Voices: fr-FR-DeniseNeural, ar-SA-HamedNeural • Commandes: flutter pub get → dart run build_runner build --delete-conflicting-outputs → flutter run • Scripts: ./scripts/{lint.sh,test.sh} • Cache: 100MB max, purge 7j auto • Fonts: assets/fonts/{Inter,NotoNaskhArabic}

---

## [2025-08-27 10:30] Projet_sprit | audit complet

## CONTEXTE
App Flutter "Spiritual Routines (RISAQ)" multiplateforme pour routines spirituelles musulmanes. Bilingue FR/AR avec TTS hybride et mode offline complet. Architecture: Flutter 3.32.8 + Riverpod 2.x + Drift/Isar + just_audio. 110+ fichiers Dart, 28 services modulaires.

## AUDIT QUALITÉ (TERMINÉ)
### Forces identifiées
- Architecture modulaire propre avec séparation claire
- Approche offline-first robuste avec persistance multi-niveaux
- Support bilingue avancé (FR/AR RTL/LTR)
- Architecture TTS hybride avec routage intelligent
- Conformité Material Design 3

### Issues critiques (2240 warnings)
- avoid_print: 1800+ violations
- unused_import: 440+ violations (EN COURS)
- Dépendances: 39 packages obsolètes
- Tests: coverage 30% actuel vs 60% requis
- Infrastructure: hooks pre-commit manquants

### Améliorations appliquées
- analysis_options.yaml: 25+ règles de linting
- scripts/lint.sh et scripts/test.sh créés
- CI/CD .github/workflows/ci.yml ajouté
- docs/CONTRAINTES.md mis à jour avec charte qualité
- Conflit dépendances isar_generator résolu

## CONTRAINTES
- Perf: latence UI <200ms, TTI <2s, mémoire <150MB, bundle <35MB
- Sécu: AES-256, auth biométrique, OWASP Grade B (85/100)
- Multi: RTL/LTR natif, polices Noto/Inter
- Plateformes: iOS/Android 95%, macOS 60%, Web 40%
- Tests: coverage 60% min (actuellement ~30%)

## DÉCISIONS
- TTS hybride: Edge-TTS primaire → Coqui fallback → Flutter local
- Détection coranique confidence >85% → APIs Quran dédiées
- Persistance triple: Drift SQL + Isar NoSQL + secure_storage
- Scripts protection: cc-save.sh, cc-guard.sh pour savepoints Git
- Material Design 3 avec thème InspiredTheme unifié

## TODO PRIORISÉ
✅ Conflit dépendances isar_generator résolu
🔄 Correction warnings unused_import (EN COURS)
⏳ Formatage code complet avec dart format
⏳ Mise à jour 39 dépendances critiques
⏳ Fix widget_test.dart avec SpiritualRoutinesApp
⏳ Tests unitaires services critiques
⏳ Tests widgets modern_reader_page
⏳ Pre-commit hooks avec husky
⏳ Nettoyage imports relatifs → package imports
⏳ Script build.sh production
⏳ Validation complète avec tests

## ERREURS RÉSOLUES
- Edge-TTS timeout → circuit breaker 5 échecs
- Détection coranique → threshold confidence 85%
- RTL/LTR → Directionality widgets auto
- Cache TTS → 100MB/7j avec hit rate 85%
- Conflit isar_generator → temporairement désactivé

## PARAMS CRITIQUES
- Edge-TTS: http://168.231.112.71:8010/api/tts (timeout 15s)
- Coqui: http://168.231.112.71:8001/api/xtts (timeout 15s)
- Corpus: assets/corpus/quran_combined.json (6236 versets)
- Build: dart run build_runner build --delete-conflicting-outputs
- Tests: flutter test --coverage
- Scripts: scripts/cc-save.sh, cc-guard.sh, cc-restore.sh

---

## [2025-08-27 14:30] Projet_sprit | memo | Context Persist

### CONTEXTE
**But**: Application mobile routines spirituelles bilingue FR-AR avec compteur intelligent, TTS hybride, mode offline-first
**Stack**: Flutter 3.x, Riverpod 2.5+, Drift/Isar persistance, Material Design 3, just_audio, TTS Edge/Coqui/Flutter
**Plateformes**: iOS/Android (95%), macOS (60% beta), Web (40% expérimental) 
**Modules clés**: smart_tts_service, quran_content_detector, hybrid_audio_service, secure_storage_service (AES-256)

### CONTRAINTES  
**Techniques**: Flutter 3.x+, null safety strict, build_runner requis après modèles, isar_generator désactivé (conflit freezed 3.2.0)
**Performance**: TTI <2s, UI <200ms, mémoire <150MB, bundle <35MB, TTS <450ms P95
**Sécurité**: Biométrique+PIN, OWASP Grade B, AES-256 local, HTTPS+pinning prod, logs sans PII
**Offline**: Fonctionnement complet sans réseau, cache TTS 7j/100MB, Quran 30j, hit rate 85%

### DÉCISIONS
**Actées**: Edge-TTS prioritaire (168.231.112.71:8010) → circuit breaker 5 échecs → Flutter fallback • Drift SQL + Isar NoSQL • RTL/LTR natif polices Noto/Inter • Material 3 thème unifié • Scripts lint.sh/test.sh opérationnels • 45+ tests créés, GitHub Actions CI/CD

**Manquantes**: Config Supabase sync multi-devices • HTTPS production endpoints • build.sh script complet

### TODO priorisé
1. **Résoudre conflit isar_generator/freezed** - Débloquer génération modèles NoSQL
2. **Coverage tests → 60%** - Ajouter tests widgets/integration manquants  
3. **Build script production** - Automatiser releases multi-plateformes
4. **HTTPS prod + pinning** - Sécuriser endpoints TTS
5. **Supabase setup** - Sync multi-devices avec RLS
6. **Cache hit 85%** - Optimiser coûts serveur
7. **Monitoring <0.1% crash** - Alertes production

### ERREURS RÉSOLUES
- Design system M3: colors.dart, shadows.dart, typography.dart, secure_logging_service.dart réparés
- 72 dépendances mises à jour, js forcé vers 0.7.2  
- Infrastructure qualité: 45 tests unitaires, GitHub Actions
- TabController crash, doublons/orphelins nettoyés, responsiveness web/macOS

### PARAMÈTRES CRITIQUES
**Endpoints**: Edge-TTS :8010/api/tts, Coqui :8001/api/xtts (timeout 15s chacun)
**Commandes**: `dart run build_runner build --delete-conflicting-outputs` • `./scripts/test.sh` • `flutter run --release`
**Timeouts**: TTS 15s, circuit breaker 5 échecs → fallback auto
**Chemins**: tests 60% min, assets/{fonts,corpus,tessdata}/, spiritual_routines v0.1.0+1

---

## [2025-08-27 12:00] Projet_sprit | memo | PERSIST-CONTEXT

### CONTEXTE
Application Flutter 3.x de routines spirituelles bilingue français-arabe. Stack: Riverpod + Drift/Isar + Material Design 3. Plateformes: iOS/Android (95%), macOS (60% beta), Web (40% expérimental). Modules clés: TTS hybride Edge-TTS/Coqui/Flutter, OCR arabe/français avec ML Kit, compteur intelligent avec haptic feedback, authentification biométrique, mode offline-first.

### CONTRAINTES
- Performance: Latence UI <200ms, TTI <2s, mémoire <150MB, bundle <35MB
- Sécurité: AES-256, biométrique + PIN, logging PII filtré, OWASP Mobile grade B minimum
- Multilingue: RTL/LTR natif, polices Noto Naskh Arabic + Inter, auto-détection direction
- Offline: Fonctionnement complet sans réseau, cache TTS 7j/100MB
- Tests: Coverage 60% global, 80% services critiques, 45 tests unitaires créés

### DÉCISIONS
✅ Architecture audio hybride: détection contenu coranique → APIs Quran, sinon Edge-TTS → Flutter TTS fallback
✅ Persistance multi-niveau: Drift (SQL) + Isar (NoSQL) + cache sécurisé
✅ Design System Material 3 avec thème unifié, accessibilité WCAG AA
✅ Infrastructure qualité: 72 dépendances mises à jour, GitHub Actions déployé
❓ Manquant: HTTPS production, Supabase sync multi-devices, build script production

### TODO PRIORISÉ
1. Finaliser HTTPS endpoints production avec certificate pinning
2. Créer script build.sh pour déploiement stores
3. Implémenter synchronisation Supabase avec RLS
4. Améliorer coverage tests vers 60% (actuellement 45 tests)
5. Optimiser cache hit rate vers 85% objectif

### ERREURS RÉSOLUES
- isar_generator désactivé (conflit freezed 3.2.0)
- js package forcé vers 0.7.2 pour compatibilité
- Design system réparé: colors.dart, shadows.dart, typography.dart
- StreamController fixes appliqués pour audio service

### PARAMÈTRES CRITIQUES
- Edge-TTS: http://168.231.112.71:8010/api/tts (timeout 15s)
- Coqui: http://168.231.112.71:8001/api/xtts (timeout 15s)
- Circuit breaker: 5 échecs → fallback automatique
- Build runner requis: dart run build_runner build --delete-conflicting-outputs
- Scripts: ./scripts/lint.sh, ./scripts/test.sh
- Commands: flutter analyze, flutter test --coverage

---
---

## [2025-08-27 14:45] Projet_sprit | memo | Context Update

### CONTEXTE
Application Flutter de routines spirituelles bilingue français-arabe (RISAQ). Stack: Flutter 3.x, Riverpod 2.5+, Drift/Isar, Material Design 3, TTS hybride. Plateformes: iOS/Android (95%), macOS (60% beta), Web (40% expérimental). Mission: moderniser pratiques spirituelles quotidiennes avec technologie mobile. Cible: pratiquants musulmans francophones/arabophones.

### CONTRAINTES
- Performance: UI <200ms, TTI <2s, mémoire <150MB, bundle <35MB, TTS <450ms P95
- Sécurité: AES-256, biométrique+PIN, OWASP Mobile B (85/100), HTTPS+pinning prod
- Multilingue: FR+AR RTL/LTR natif, Noto Naskh Arabic, auto-détection direction
- Offline-first: fonctionnement complet sans connexion, cache 7j/100MB TTS
- Qualité: coverage 60% global/80% services critiques, 45 tests unitaires créés

### DÉCISIONS
✅ Edge-TTS principal (168.231.112.71:8010), Coqui backup (8001)
✅ APIs Quran pour contenu coranique (confidence >85%), sinon Edge-TTS
✅ Circuit breaker 5 échecs, fallback Flutter TTS local
✅ Infrastructure qualité déployée: scripts lint/test, GitHub Actions, 72 deps maj
❓ Supabase sync multi-devices (non configuré)
❓ HTTPS production avec certificate pinning
❓ Build script manquant

### TODO PRIORISÉ
1. Créer scripts/build.sh production
2. Configurer environnement HTTPS production 
3. Implémenter sync Supabase optionnelle
4. Résoudre conflit isar_generator/freezed 3.2.0
5. Atteindre coverage 60% (actuellement 45 tests)
6. Tests integration complets
7. Monitoring crash rate <0.1%

### ERREURS RÉSOLUES
- Design system réparé (colors/shadows/typography/secure_logging_service)
- js package forcé vers 0.7.2 pour stabilité
- 72 dépendances mises à jour avec succès

### PARAMÈTRES CRITIQUES
- Edge-TTS: 168.231.112.71:8010/api/tts, timeout 15s
- Coqui: 168.231.112.71:8001/api/xtts, timeout 15s  
- Commandes: flutter pub get && dart run build_runner build --delete-conflicting-outputs
- Scripts: ./scripts/test.sh, ./scripts/lint.sh
- KPIs: rétention D30 >50%, session >10min, complétion >75%

---

Tags: [Projet_sprit, context, docs, TTS, Edge, XTTS, Flutter]