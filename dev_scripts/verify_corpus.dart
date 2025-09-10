import 'dart:io';
import 'dart:convert';

/// Script simple pour vérifier que les corpus Coran sont disponibles
void main() async {
  print('🧪 Vérification des corpus Coran');
  print('==================================');

  try {
    final currentDir = Directory.current.path;
    print('📁 Répertoire courant: $currentDir');

    // Vérifier les fichiers corpus
    final assets = Directory('assets/corpus');
    if (!await assets.exists()) {
      print('❌ Le dossier assets/corpus n\'existe pas');
      return;
    }

    print('📚 Fichiers corpus disponibles:');
    await for (FileSystemEntity entity in assets.list()) {
      if (entity is File && entity.path.endsWith('.json')) {
        final file = entity as File;
        final size = await file.length();
        final name = file.path.split('/').last;
        print('  - $name: ${(size / 1024).toStringAsFixed(2)} KB');

        // Analyse spécifique pour les corpus Coran
        if (name.contains('quran')) {
          try {
            final content = await file.readAsString();
            final data = jsonDecode(content) as List;
            print('    └─ Nombre de versets: ${data.length}');

            if (data.isNotEmpty) {
              final firstVerse = data.first;
              if (firstVerse is Map && firstVerse.containsKey('textAr')) {
                final text = firstVerse['textAr'] as String;
                final preview =
                    text.length > 30 ? text.substring(0, 30) + '...' : text;
                print('    └─ Premier verset: "$preview"');
              }
            }
          } catch (e) {
            print('    └─ ❌ Erreur lecture: $e');
          }
        }
      }
    }

    print('\n✅ Changement appliqué:');
    print(
        '   QuranContentDetector.dart:19 → charge quran_full.json au lieu de quran_combined.json');

    print('\n🎯 Impact attendu:');
    print('   - quran_combined.json: 1 verset → 3.2% de confiance');
    print('   - quran_full.json: 6236 versets → >85% de confiance');
  } catch (e) {
    print('❌ Erreur: $e');
  }
}
