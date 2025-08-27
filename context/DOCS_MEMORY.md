# PROJET SPIRITUAL ROUTINES (RISAQ) - DOCS SYNC

## ARCHITECTURE TECHNIQUE
- **Framework**: Flutter 3.x + Riverpod 2.5+ + GoRouter 14.2+
- **Persistance**: Drift 2.17+ (SQL) + Isar 3.1+ (NoSQL) + Supabase (cloud)
- **Audio**: just_audio 0.9+ + audio_service 0.18+ + TTS hybride
- **Sécurité**: flutter_secure_storage + local_auth + chiffrement AES-256
- **UI**: Material Design 3 avec 4 palettes thématiques

## SERVICES CORE (28+ services)
- **SmartTtsService**: Orchestration TTS avec fallback Coqui→Flutter
- **HybridAudioService**: Détection contenu + routage API Quran/Edge-TTS
- **SecureStorageService**: Stockage chiffré cross-platform
- **BiometricService**: Auth Face ID/Touch ID + PIN fallback
- **AutoResumeService**: Reprise session après interruption
- **QuranCorpusService**: Gestion corpus 6236 versets
- **SecureLoggingService**: Logs sans PII avec filtrage automatique

## FONCTIONNALITÉS PRINCIPALES
- **Compteur persistant**: Décrément avec haptic feedback, sauvegarde 5s
- **Lecteur bilingue**: FR/AR avec RTL/LTR, surlignage sync audio
- **TTS intelligent**: Détection coranique → API spécialisée vs synthèse
- **Mode mains-libres**: Auto-avance avec feedback contextuel
- **Export multi-format**: CSV/JSON/PDF avec cartes visuelles
- **OCR multilingue**: Apple Vision (iOS) + MLKit/Tesseract (Android)

## PARAMÈTRES SYSTÈME
- **VPS Edge-TTS**: 168.231.112.71:8010/api/tts
- **VPS Coqui**: 168.231.112.71:8001/api/xtts
- **Corpus**: assets/corpus/quran_full.json (6236 versets)
- **Cache TTS**: 7j/100MB, hit rate 85%, latence P95 450ms
- **Timeouts**: 15s API, 5s fallback, circuit breaker 5 échecs

## PERFORMANCE TARGETS
- **UI**: <200ms latence, <2s TTI, <150MB mémoire
- **Audio**: <450ms TTS, <100ms détection contenu
- **Sécurité**: Grade B OWASP (85/100), chiffrement bout-en-bout
- **Coverage**: >60% tests, >80% services critiques

## STRUCTURE FICHIERS
```
lib/
├── app/ (router.dart, performance_config.dart)
├── core/
│   ├── models/ (routine_models.dart, task_category.dart)
│   ├── persistence/ (drift_schema.dart, isar_collections.dart)
│   ├── services/ (28+ services modulaires)
│   └── utils/ (app_logger.dart, refs.dart)
├── features/
│   ├── home/ (modern_home_page.dart)
│   ├── reader/ (enhanced_modern_reader_page.dart + 5 variantes)
│   ├── routines/ (modern_routines_page.dart, routine_editor_page.dart)
│   └── settings/ (modern_settings_page.dart - CRASH TabController)
├── design_system/ (inspired_theme.dart + 2 autres)
└── l10n/ (app_localizations FR/AR)
```

## PROBLÈMES CRITIQUES CONNUS
1. **TabController crash**: modern_settings_page.dart manque TabController
2. **Corpus vide**: quran_combined.json (201 bytes au lieu 2MB)
3. **Dette technique**: 40% code dupliqué (3 thèmes, 6 readers)
4. **Config manquante**: Supabase non configuré, pas de RLS

## SOLUTIONS TECHNIQUES APPLIQUÉES
- **OCR arabe**: Migration Tesseract→Apple Vision (MissingPluginException)
- **TTS arabe**: Fix détection coranique 3.2%→85% confiance
- **UI Material 3**: Résolution contraste illisible, overflow 72px
- **Cross-platform**: Wrappers unifiés, permissions harmonisées
- **Performance**: Transitions 250ms, désactivation logs production

## EPIC COMPLÉTÉES (Phase 1)
- **T-D**: Infrastructure sécurité complète (biométrie, chiffrement, logging)
- **T-E**: Fonctionnalités avancées (haptic feedback, auto-resume)
- **T-F**: Analytics et export (CSV/JSON/PDF, partage social)
- **UI Redesign**: Migration Material 3, accessibilité WCAG AA

## COMMANDES CRITIQUES
```bash
flutter run --release  # Test performance
flutter analyze        # Contrôle qualité
flutter test           # Suite de tests (14 fichiers actuels)
dart run build_runner build  # Génération code
```

## PLATEFORMES SUPPORT
- ✅ **iOS/Android**: Production-ready (95% complet)
- ⚠️ **macOS**: Beta (60% - problèmes background audio)
- ⚠️ **Web**: Expérimental (40% - Isar stubs requis)
- ❌ **Windows/Linux**: Non supporté (20%)

## MÉTRIQUES KPI
- **Technique**: Crash rate <0.1%, bundle <35MB
- **Utilisateur**: Rétention D30 >50%, session >10min
- **Performance**: Cache hit 85%, coût TTS 8€/mois