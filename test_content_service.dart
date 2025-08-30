#!/usr/bin/env dart
/*
Script de test pour vérifier si ContentService.buildTextFromRefs() 
fonctionne correctement après nos modifications.
*/

import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 Test de ContentService.buildTextFromRefs()');
  print('=' * 50);

  // Simuler ce que fait ContentService.buildTextFromRefs()
  await testBuildTextFromRefs();
}

Future<void> testBuildTextFromRefs() async {
  try {
    // Charger le corpus comme le fait QuranCorpusService
    final file =
        File('/Users/mac/Documents/Projet_sprit/assets/corpus/quran_full.json');
    final jsonString = await file.readAsString();
    final List<dynamic> data = jsonDecode(jsonString);

    // Simuler la recherche de versets pour la sourate 112, versets 1-4
    final verses = data
        .where((v) => v['surah'] == 112 && v['ayah'] >= 1 && v['ayah'] <= 4)
        .toList();

    print('📖 Versets trouvés: ${verses.length}');

    // Simuler buildTextFromRefs() avec notre logique modifiée
    final buffer = StringBuffer();
    const locale = 'ar';

    for (final v in verses) {
      final line = v['textAr'] ?? '';
      if (line.isEmpty) continue;

      String processedLine = line.trim();

      // Notre logique modifiée pour détecter la Basmalah
      String? bismillahFound;
      String? restOfVerse;

      final bismillahVariants = [
        'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
        'بسم الله الرحمن الرحيم',
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        'بِسْمِ اللهِ الرَّحْمنِ الرَّحِيمِ'
      ];

      // Vérifier si le texte contient déjà un \n (nouveau format)
      if (processedLine.contains('\n')) {
        final parts = processedLine.split('\n');
        final firstPart = parts[0].trim();

        print('🕌 Verset ${v['ayah']} contient \\n');
        print('   Première partie: "$firstPart"');
        print('   Autres parties: ${parts.skip(1).toList()}');

        // Vérifier si la première partie est une Basmalah
        for (final variant in bismillahVariants) {
          if (firstPart == variant) {
            bismillahFound = variant;
            restOfVerse = parts
                .skip(1)
                .where((p) => p.trim().isNotEmpty)
                .join(' ')
                .trim();
            print('   ✅ Basmalah détectée: "$bismillahFound"');
            print('   📝 Reste: "$restOfVerse"');
            break;
          }
        }
      }

      // Sinon vérifier le format ancien
      if (bismillahFound == null) {
        for (final variant in bismillahVariants) {
          if (processedLine.startsWith(variant)) {
            bismillahFound = variant;
            restOfVerse = processedLine.substring(variant.length).trim();
            print('   ✅ Basmalah détectée (ancien format): "$bismillahFound"');
            print('   📝 Reste: "$restOfVerse"');
            break;
          }
        }
      }

      if (bismillahFound != null) {
        // Ajouter Basmalah avec séparation
        buffer.write(bismillahFound);
        buffer.writeln(); // Premier retour à la ligne
        buffer.writeln(''); // Ligne vide pour créer un espacement visible

        // Ajouter le reste du verset s'il y en a un
        if (restOfVerse != null && restOfVerse.isNotEmpty) {
          buffer.write(restOfVerse);
        }
      } else {
        // Verset normal sans Bismillah
        buffer.write(processedLine);
      }

      // Ajouter le marqueur de numéro à la fin
      buffer.write(' {{V:${v['ayah']}}}');
      buffer.writeln();
    }

    final result = buffer.toString();
    print('\n📄 Résultat final:');
    print('-' * 30);
    print(result);
    print('-' * 30);

    // Vérifier si la Basmalah est bien séparée
    if (result.contains(
        'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ\n\n\nقُلْ هُوَ ٱللَّهُ أَحَدٌ')) {
      print('✅ SUCCESS: Basmalah correctement séparée !');
    } else {
      print('❌ PROBLEM: Basmalah non séparée correctement');
    }
  } catch (e) {
    print('❌ Erreur: $e');
  }
}
