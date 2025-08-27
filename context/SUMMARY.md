# Projet_sprit | memo | 2025-08-27 02:15

## CONTEXTE
App Flutter "Spiritual Routines (RISAQ)" multiplateforme pour routines spirituelles musulmanes. Bilingue FR/AR avec TTS hybride et mode offline complet. Architecture: Flutter 3.x + Riverpod 2.5 + Drift/Isar + just_audio. 110+ fichiers Dart, 28 services modulaires.

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

## TODO
1. 🚨 Import corpus Coran vide (assets/corpus/quran_combined.json)
2. 🔴 Fix TabController crash (modern_settings_page.dart)
3. 🟡 Refactoring duplication 40% (3 readers, 6 thèmes)
4. 🟢 Coverage tests 30% → 60%
5. ⚪ Config Supabase + RLS pour sync cloud

## ERREURS RÉSOLUES
- Edge-TTS timeout → circuit breaker 5 échecs
- Détection coranique → threshold confidence 85%
- RTL/LTR → Directionality widgets auto
- Cache TTS → 100MB/7j avec hit rate 85%

## PARAMS CRITIQUES
- Edge-TTS: http://168.231.112.71:8010/api/tts (timeout 15s)
- Coqui: http://168.231.112.71:8001/api/xtts (timeout 15s)
- Corpus: assets/corpus/quran_combined.json (6236 versets)
- Build: dart run build_runner build --delete-conflicting-outputs
- Tests: flutter test --coverage
- Scripts: scripts/cc-save.sh, cc-guard.sh, cc-restore.sh

---
Tags: [Projet_sprit, TTS, Edge, XTTS, Flutter]