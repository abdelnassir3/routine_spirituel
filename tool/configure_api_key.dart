#!/usr/bin/env dart

/// Script pour configurer automatiquement l'API key Coqui
/// Usage: dart run tool/configure_api_key.dart

import 'package:spiritual_routines/core/services/tts_config_service.dart';

void main() async {
  print('=== Configuration Automatique Coqui TTS ===\n');

  // Configuration avec vos paramètres
  final config = TtsConfigService(
    coquiEndpoint: 'http://168.231.112.71:8001',
    coquiApiKey:
        '59be8c1f611576f7bd4436d7780426cc4bfcb10decd87e239a8ced6d843aa7c9a9541d8415d3c7a5313a427d1f7fff9a687cd23f60bba4338db0a580bed940c651f7bf2e-2dce-4105-a7ad-092fcc61560d',
    timeout: 3000,
    maxRetries: 3,
    cacheEnabled: true,
    cacheTTLDays: 7,
    preferredProvider: 'coqui',
  );

  try {
    print('Configuration en cours...');
    await config.save();

    print('\n✅ Configuration sauvegardée avec succès!');
    print('\nParamètres configurés:');
    print('  Endpoint: ${config.coquiEndpoint}');
    print('  API Key: ${config.maskedApiKey}');
    print('  Timeout: ${config.timeout}ms');
    print('  Max Retries: ${config.maxRetries}');
    print('  Cache TTL: ${config.cacheTTLDays} jours');
    print('  Provider préféré: ${config.preferredProvider}');

    print(
        '\n🚀 L\'application est maintenant configurée pour utiliser Coqui TTS!');
    print('\nPour tester:');
    print('  1. Lancez l\'application: flutter run');
    print('  2. Allez dans Paramètres > Voix et Lecture');
    print('  3. Testez une voix (elle utilisera automatiquement Coqui)');

    print('\n📝 Notes importantes:');
    print('  - L\'API key est stockée de manière sécurisée et chiffrée');
    print('  - Si Coqui échoue, l\'app utilisera automatiquement flutter_tts');
    print('  - Le cache audio est chiffré en AES-256');
    print('  - Pour effacer: dart run tool/clear_coqui_config.dart');
  } catch (e) {
    print('❌ Erreur lors de la configuration: $e');
  }
}
