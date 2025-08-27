#!/usr/bin/env dart

/*
Script pour supprimer la base de données Isar et forcer une réimportation
du corpus Coran avec les modifications de formatage de la Basmalah.

Usage: dart reset_database.dart
*/

import 'dart:io';

void main() async {
  print('🔄 Script de réinitialisation de la base de données');
  print('');
  
  // Chemins possibles pour la base de données Isar
  final possiblePaths = [
    'ios/default.isar', // Pour iOS Simulator
    'macos/default.isar', // Pour macOS
    '~/.local/share/spiritual_routines/default.isar', // Linux
    'windows/default.isar', // Windows
  ];
  
  var deleted = false;
  
  for (final path in possiblePaths) {
    final file = File(path);
    if (await file.exists()) {
      try {
        await file.delete();
        print('✅ Base de données supprimée: $path');
        deleted = true;
      } catch (e) {
        print('❌ Erreur lors de la suppression de $path: $e');
      }
    }
  }
  
  // Vérifier dans le répertoire de support d'application système
  final homeDir = Platform.environment['HOME'];
  if (homeDir != null) {
    final appSupportPaths = [
      '$homeDir/Library/Application Support/spiritual_routines/default.isar', // macOS
      '$homeDir/.local/share/spiritual_routines/default.isar', // Linux
    ];
    
    for (final path in appSupportPaths) {
      final file = File(path);
      if (await file.exists()) {
        try {
          await file.delete();
          print('✅ Base de données supprimée: $path');
          deleted = true;
        } catch (e) {
          print('❌ Erreur lors de la suppression de $path: $e');
        }
      }
    }
  }
  
  if (deleted) {
    print('');
    print('🎉 Base de données réinitialisée avec succès !');
    print('');
    print('📱 Au prochain lancement de l\'application, les versets');
    print('   seront réimportés avec le nouveau formatage de la Basmalah.');
    print('');
    print('🚀 Vous pouvez maintenant lancer l\'application :');
    print('   flutter run');
  } else {
    print('ℹ️  Aucune base de données trouvée à supprimer.');
    print('');
    print('📱 Lancez l\'application et allez dans Paramètres > Import du corpus');
    print('   pour recharger manuellement les données modifiées.');
  }
}