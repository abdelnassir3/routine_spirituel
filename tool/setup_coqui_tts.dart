#!/usr/bin/env dart

/// Script pour configurer l'API key Coqui de manière sécurisée
/// Usage: dart run tool/setup_coqui_tts.dart
///
/// IMPORTANT: Ne jamais commiter l'API key dans le code source!

import 'dart:io';
import 'package:spiritual_routines/core/services/tts_config_service.dart';

void main() async {
  print('=== Configuration Coqui TTS ===\n');

  // Vérifier si déjà configuré
  final existingConfig = await TtsConfigService.load();
  if (existingConfig.coquiApiKey.isNotEmpty) {
    print('✅ API key déjà configurée: ${existingConfig.maskedApiKey}');
    print('Endpoint: ${existingConfig.coquiEndpoint}');

    stdout.write('\nVoulez-vous reconfigurer? (o/n): ');
    final response = stdin.readLineSync()?.toLowerCase();
    if (response != 'o' && response != 'oui') {
      print('Configuration annulée.');
      exit(0);
    }
  }

  // Demander l'API key
  stdout.write(
      '\nEntrez votre API key Coqui (sera stockée de manière sécurisée): ');
  // Désactiver l'écho pour masquer l'API key pendant la saisie
  stdin.echoMode = false;
  final apiKey = stdin.readLineSync() ?? '';
  stdin.echoMode = true;
  print(''); // Nouvelle ligne après saisie masquée

  if (apiKey.isEmpty) {
    print('❌ API key invalide');
    exit(1);
  }

  // Demander l'endpoint (optionnel)
  stdout.write('\nEndpoint Coqui [http://168.231.112.71:8001]: ');
  var endpoint = stdin.readLineSync() ?? '';
  if (endpoint.isEmpty) {
    endpoint = 'http://168.231.112.71:8001';
  }

  // Demander le timeout (optionnel)
  stdout.write('\nTimeout en ms [3000]: ');
  final timeoutStr = stdin.readLineSync() ?? '3000';
  final timeout = int.tryParse(timeoutStr) ?? 3000;

  // Demander le nombre de retries (optionnel)
  stdout.write('\nNombre de retries [3]: ');
  final retriesStr = stdin.readLineSync() ?? '3';
  final maxRetries = int.tryParse(retriesStr) ?? 3;

  // Demander TTL du cache (optionnel)
  stdout.write('\nTTL du cache en jours [7]: ');
  final ttlStr = stdin.readLineSync() ?? '7';
  final cacheTTL = int.tryParse(ttlStr) ?? 7;

  // Créer et sauvegarder la configuration
  final config = TtsConfigService(
    coquiEndpoint: endpoint,
    coquiApiKey: apiKey,
    timeout: timeout,
    maxRetries: maxRetries,
    cacheEnabled: true,
    cacheTTLDays: cacheTTL,
    preferredProvider: 'coqui',
  );

  print('\n📝 Configuration à sauvegarder:');
  print('  Endpoint: $endpoint');
  print('  API Key: ${config.maskedApiKey}');
  print('  Timeout: ${timeout}ms');
  print('  Max Retries: $maxRetries');
  print('  Cache TTL: $cacheTTL jours');
  print('  Provider préféré: coqui');

  stdout.write('\nConfirmer la sauvegarde? (o/n): ');
  final confirm = stdin.readLineSync()?.toLowerCase();
  if (confirm != 'o' && confirm != 'oui') {
    print('Configuration annulée.');
    exit(0);
  }

  try {
    await config.save();
    print('\n✅ Configuration sauvegardée avec succès!');
    print('\nPour tester la configuration:');
    print('  1. Lancez l\'application: flutter run');
    print('  2. Allez dans Paramètres > Voix et Lecture');
    print('  3. Testez une voix Coqui');

    print('\n⚠️  IMPORTANT:');
    print('  - L\'API key est stockée de manière sécurisée');
    print('  - Ne partagez jamais votre API key');
    print(
        '  - Pour effacer la configuration: dart run tool/clear_coqui_config.dart');
  } catch (e) {
    print('❌ Erreur lors de la sauvegarde: $e');
    exit(1);
  }
}
