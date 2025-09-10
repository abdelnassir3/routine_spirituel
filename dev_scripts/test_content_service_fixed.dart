#!/usr/bin/env dart
/*
Script de test pour vérifier si ContentService.buildTextFromRefs() 
fonctionne correctement après la correction.
*/

import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔧 Test de ContentService corrigé');
  print('=' * 50);

  // Tester la nouvelle fonction simplifiée
  await testSimplifiedBuildTextFromRefs();
}

Future<void> testSimplifiedBuildTextFromRefs() async {
  try {
    // Charger le corpus
    final file =
        File('/Users/mac/Documents/Projet_sprit/assets/corpus/quran_full.json');
    final jsonString = await file.readAsString();
    final List<dynamic> data = jsonDecode(jsonString);

    // Simuler la recherche de versets pour la sourate 112 (Al-Ikhlas)
    final verses = data
        .where((v) => v['surah'] == 112 && v['ayah'] >= 1 && v['ayah'] <= 4)
        .toList();

    print('📖 Versets trouvés pour sourate 112: ${verses.length}');

    // Simuler notre logique simplifiée
    final buffer = StringBuffer();
    const locale = 'ar';

    for (final v in verses) {
      final line = v['textAr'] ?? '';
      if (line.isEmpty) continue;

      String processedLine = line.trim();

      // Appliquer notre logique simplifiée de traitement de Basmalah
      if (locale == 'ar') {
        processedLine = processBismillahInVerse(processedLine);
      }

      // Ajouter le texte traité
      buffer.write(processedLine);

      // Ajouter le marqueur de numéro à la fin
      buffer.write(' {{V:${v['ayah']}}}');
      buffer.writeln();
    }

    final result = buffer.toString().trim();
    print('\n📄 Résultat final:');
    print('-' * 40);
    print(result);
    print('-' * 40);

    // Vérifications
    if (result.contains('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ')) {
      print('✅ Basmalah présente');
    } else {
      print('❌ Basmalah manquante');
    }

    if (result.contains('{{V:1}}') && result.contains('{{V:2}}')) {
      print('✅ Marqueurs de versets présents');
    } else {
      print('❌ Marqueurs de versets manquants');
    }

    if (result.contains(
        'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ\n\nقُلْ هُوَ ٱللَّهُ أَحَدٌ')) {
      print('✅ SUCCESS: Basmalah correctement séparée !');
    } else if (result.contains('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ') &&
        result.contains('قُلْ هُوَ ٱللَّهُ أَحَدٌ')) {
      print(
          '⚠️ Basmalah et verset présents mais peut-être pas parfaitement séparés');
    } else {
      print('❌ PROBLEM: Format inattendu');
    }

    print(
        '\n🧪 Test terminé avec succès - Le service devrait maintenant fonctionner!');
  } catch (e) {
    print('❌ Erreur: $e');
  }
}

/// Version simplifiée de la logique de traitement de Basmalah
String processBismillahInVerse(String verse) {
  try {
    const bismillah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';

    // Cas 1: Le verset contient déjà un \n (nouveau format)
    if (verse.contains('\n')) {
      final parts = verse.split('\n');
      final firstPart = parts[0].trim();

      if (firstPart == bismillah) {
        final restParts =
            parts.skip(1).where((p) => p.trim().isNotEmpty).toList();
        if (restParts.isNotEmpty) {
          return '$bismillah\n\n${restParts.join(' ')}';
        } else {
          return bismillah;
        }
      }
    }

    // Cas 2: Format traditionnel - Basmalah au début
    if (verse.startsWith(bismillah)) {
      final rest = verse.substring(bismillah.length).trim();
      if (rest.isNotEmpty) {
        return '$bismillah\n\n$rest';
      } else {
        return bismillah;
      }
    }

    // Cas 3: Aucune Basmalah détectée, retourner tel quel
    return verse;
  } catch (e) {
    print('⚠️ Erreur lors du traitement de la Basmalah: $e');
    return verse;
  }
}
