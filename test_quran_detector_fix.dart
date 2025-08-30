import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

/// Script simple pour vérifier que le corpus Coran est correctement chargé
void main() async {
  print('🧪 Test de vérification du corpus Coran');
  print('=====================================');

  try {
    // Vérifier que les fichiers corpus existent physiquement
    final quranCombined = File('assets/corpus/quran_combined.json');
    final quranFull = File('assets/corpus/quran_full.json');

    print('📁 Vérification des fichiers:');
    print(
        '  - quran_combined.json: ${await quranCombined.exists() ? "✅ Existe" : "❌ Manquant"}');
    print(
        '  - quran_full.json: ${await quranFull.exists() ? "✅ Existe" : "❌ Manquant"}');

    if (await quranFull.exists()) {
      final fullContent = await quranFull.readAsString();
      final fullData = jsonDecode(fullContent) as List;
      print('  - Nombre de versets dans quran_full.json: ${fullData.length}');

      if (fullData.length >= 6000) {
        print('✅ Corpus complet détecté (${fullData.length} versets)');
      } else {
        print('⚠️  Corpus partiel (${fullData.length} versets, attendu: 6236)');
      }

      // Vérifier quelques versets spécifiques
      final fatiha1 = fullData.firstWhere(
          (v) => v['surah'] == 1 && v['ayah'] == 1,
          orElse: () => null);
      final bakara1 = fullData.firstWhere(
          (v) => v['surah'] == 2 && v['ayah'] == 1,
          orElse: () => null);

      print('📖 Vérification de versets clés:');
      print(
          '  - Al-Fatiha 1:1: ${fatiha1 != null ? "✅ Trouvé" : "❌ Manquant"}');
      print(
          '  - Al-Bakara 2:1: ${bakara1 != null ? "✅ Trouvé" : "❌ Manquant"}');

      if (fatiha1 != null) {
        print('  - Texte Al-Fatiha 1:1: "${fatiha1['textAr']}"');
      }
    }

    if (await quranCombined.exists()) {
      final combinedContent = await quranCombined.readAsString();
      final combinedData = jsonDecode(combinedContent) as List;
      print(
          '  - Nombre de versets dans quran_combined.json: ${combinedData.length}');

      if (combinedData.length == 1) {
        print('⚠️  Corpus réduit détecté (ancien problème)');
      }
    }
  } catch (e) {
    print('❌ Erreur lors de la vérification: $e');
  }

  print('\n💡 Changement appliqué:');
  print(
      '   QuranContentDetector charge maintenant quran_full.json au lieu de quran_combined.json');
  print('\n🚀 Résultat attendu après le changement:');
  print('   - Détection coranique: confidence >85% au lieu de 3.2%');
  print('   - Texte coranique routé vers QuranRecitationService');
  print('   - Texte arabe normal routé vers TTS arabe');
}
