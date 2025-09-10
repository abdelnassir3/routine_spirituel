#!/usr/bin/env dart

import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Script pour vider le cache TTS corrompu
/// Usage: dart run clear_tts_cache.dart

void main() async {
  print('=== Nettoyage du cache TTS ===\n');

  try {
    // Obtenir le répertoire temporaire
    final tempDir = await getTemporaryDirectory();
    final cacheDir = Directory('${tempDir.path}/tts_cache');

    if (await cacheDir.exists()) {
      print('📁 Répertoire cache trouvé: ${cacheDir.path}');

      // Lister les fichiers
      final files = await cacheDir.list().toList();
      print('📊 ${files.length} fichiers trouvés');

      // Supprimer le répertoire et tout son contenu
      await cacheDir.delete(recursive: true);
      print('✅ Cache vidé avec succès!\n');

      // Recréer le répertoire vide
      await cacheDir.create(recursive: true);
      print('📁 Répertoire cache recréé\n');
    } else {
      print('ℹ️  Aucun cache trouvé\n');
    }

    print('🎯 Actions recommandées:');
    print('1. Relancer l\'application');
    print('2. Tester à nouveau la synthèse vocale');
    print('3. Le cache sera reconstruit automatiquement');
  } catch (e) {
    print('❌ Erreur: $e');
  }
}
