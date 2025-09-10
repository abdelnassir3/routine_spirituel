# Scripts de Développement - Archive

## Contenu

Ce dossier contient les scripts de développement temporaires qui ont été utilisés pendant le processus de développement et debugging :

### Fichiers Archivés
- `test_content_service.dart` - Tests expérimentaux ContentService
- `test_content_service_fixed.dart` - Version corrigée des tests ContentService
- `test_performance.dart` - Tests de performance navigation
- `test_playwright.dart` - Tests expérimentaux Playwright  
- `test_quran_corpus_service.dart` - Tests expérimentaux service Corpus
- `test_quran_detector_fix.dart` - Corrections détecteur Coran
- `verify_corpus.dart` - Script de validation corpus
- `clear_tts_cache.dart` - Script nettoyage cache TTS

## Raison du Déplacement

Ces fichiers ont été déplacés ici car :
1. **Erreurs de linting** : Scripts de développement avec nombreux warnings
2. **Tests temporaires** : Code expérimental non finalisé
3. **Scripts utilitaires** : Outils ponctuels de debugging/maintenance
4. **Séparation claire** : Focus sur les tests principaux dans `test/`

## Utilisation

Ces scripts peuvent être utilisés directement avec :
```bash
dart run dev_scripts/script_name.dart
```

**Note** : Ces fichiers sont exclus du linting et de la CI/CD pour maintenir la qualité du code principal.

## Tests Officiels

Les tests officiels et maintenus sont dans :
- `test/unit/` - Tests unitaires (47 tests ✅)
- `test/widgets/` - Tests widgets (26+ tests ✅)
- `test/stubs/` - Stubs cross-platform