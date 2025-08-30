#!/usr/bin/env dart

/// Script pour effacer la configuration Coqui TTS
/// Usage: dart run tool/clear_coqui_config.dart

import 'dart:io';
import 'package:spiritual_routines/core/services/tts_config_service.dart';

void main() async {
  print('=== Effacement Configuration Coqui TTS ===\n');

  // Vérifier configuration actuelle
  final config = await TtsConfigService.load();
  if (config.coquiApiKey.isEmpty) {
    print('ℹ️  Aucune configuration Coqui trouvée.');
    exit(0);
  }

  print('Configuration actuelle:');
  print('  Endpoint: ${config.coquiEndpoint}');
  print('  API Key: ${config.maskedApiKey}');
  print('  Timeout: ${config.timeout}ms');
  print('  Provider préféré: ${config.preferredProvider}');

  stdout
      .write('\n⚠️  Voulez-vous vraiment effacer cette configuration? (o/n): ');
  final confirm = stdin.readLineSync()?.toLowerCase();

  if (confirm != 'o' && confirm != 'oui') {
    print('Effacement annulé.');
    exit(0);
  }

  try {
    await TtsConfigService.clear();
    print('\n✅ Configuration effacée avec succès!');
    print('L\'application utilisera maintenant flutter_tts par défaut.');
  } catch (e) {
    print('❌ Erreur lors de l\'effacement: $e');
    exit(1);
  }
}
