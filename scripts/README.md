# Scripts de Test - Projet Spiritual Routines

Scripts utilitaires pour l'exécution des tests selon la plateforme.

## Scripts Disponibles

### `test.sh` - Tests Desktop/Mobile (Recommandé)
```bash
./scripts/test.sh
```
- Exécute uniquement les tests unitaires et widgets
- Compatible avec macOS, Linux, Windows
- Évite les erreurs dart:html sur plateformes non-web
- **Utilisation**: Développement quotidien et CI/CD

### `test_web.sh` - Tests Web (Expérimental)
```bash
./scripts/test_web.sh
```
- Exécute TOUS les tests incluant intégration web
- Nécessite plateforme web ou émulation
- Peut échouer sur macOS/Linux si pas de support web
- **Utilisation**: Tests spécifiques web avant déploiement

### `lint.sh` - Analyse de Code
```bash
./scripts/lint.sh
```
- Analyse complète avec flutter analyze
- Formatage automatique avec dart format
- Exclusion des fichiers tools/ (scripts de développement)

## Configuration des Tests

### Exclusions Automatiques
Les tests suivants sont automatiquement exclus sur plateformes non-web :
- `test/integration/desktop_interaction_test.dart`
- `test/integration/responsive_integration_test.dart`
- Tests utilisant dart:html

### Variables d'Environnement
```bash
# Forcer l'exécution des tests web
export FLUTTER_WEB=true
export FLUTTER_TEST_PLATFORM=web

# Forcer l'exécution des tests d'intégration
export RUN_INTEGRATION_TESTS=true
```

## Résultats Attendus

### Tests Desktop/Mobile (test.sh)
- ✅ 47 tests unitaires (100% succès)
- ✅ ~26 tests widgets (90%+ succès)
- ⚠️ Quelques warnings base de données (normaux en tests)

### Métriques de Qualité
- **Coverage**: Rapport généré dans `coverage/lcov.info`
- **Performance**: Tests d'ID, refs, task categories
- **Services**: TTS, content, persistence
- **UI**: Responsive layouts, navigation

## Dépendances

Les scripts gèrent automatiquement :
- Installation du package test
- Résolution des dépendances Flutter
- Build des fichiers générés (Drift, Freezed)
- Configuration de coverage

## Support

Pour les erreurs de tests web sur macOS :
1. Utiliser `test.sh` (tests desktop/mobile uniquement)
2. Pour tester le web : déployer sur serveur web ou utiliser CI/CD

Les scripts tools/ sont exclus du linting Flutter pour éviter les warnings de développement.