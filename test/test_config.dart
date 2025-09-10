/// Configuration des tests selon la plateforme
library test_config;

import 'dart:io' show Platform;

/// Indique si les tests web doivent être exécutés
bool get shouldRunWebTests => 
    Platform.environment['FLUTTER_TEST_PLATFORM'] == 'web' ||
    Platform.environment['FLUTTER_WEB'] == 'true';

/// Indique si les tests d'intégration doivent être exécutés
bool get shouldRunIntegrationTests => 
    shouldRunWebTests || 
    Platform.environment['RUN_INTEGRATION_TESTS'] == 'true';

/// Liste des tests à exclure sur les plateformes non-web
const List<String> webOnlyTests = [
  'test/integration/desktop_interaction_test.dart',
  'test/integration/responsive_integration_test.dart',
  'test/unit/adapters/tts_web_adapter_test.dart',
];

/// Vérifie si un test doit être exécuté sur la plateforme actuelle
bool shouldRunTest(String testPath) {
  if (!shouldRunWebTests && webOnlyTests.contains(testPath)) {
    return false;
  }
  return true;
}
