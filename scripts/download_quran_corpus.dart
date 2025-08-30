#!/usr/bin/env dart

/// Script pour télécharger et formater le corpus complet du Coran
/// Sources : Tanzil.net pour l'arabe, et traductions françaises
///
/// Usage: dart run scripts/download_quran_corpus.dart

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

void main() async {
  print('📖 Téléchargement du corpus Coran...\n');

  final dio = Dio();
  final outputDir = Directory('assets/corpus');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  try {
    // Option 1: Utiliser une API publique pour obtenir le Coran
    // API al-quran-cloud est gratuite et fiable
    print('Téléchargement du texte arabe...');
    final arabicResponse = await dio.get(
      'https://api.alquran.cloud/v1/quran/ar.alafasy',
    );

    print('Téléchargement de la traduction française...');
    final frenchResponse = await dio.get(
      'https://api.alquran.cloud/v1/quran/fr.hamidullah',
    );

    if (arabicResponse.statusCode == 200 && frenchResponse.statusCode == 200) {
      final arabicData = arabicResponse.data['data']['surahs'] as List;
      final frenchData = frenchResponse.data['data']['surahs'] as List;

      // Combiner les données
      final combinedVerses = <Map<String, dynamic>>[];

      for (int i = 0; i < arabicData.length; i++) {
        final surahAr = arabicData[i];
        final surahFr = frenchData[i];
        final surahNumber = surahAr['number'];

        final ayahsAr = surahAr['ayahs'] as List;
        final ayahsFr = surahFr['ayahs'] as List;

        for (int j = 0; j < ayahsAr.length; j++) {
          combinedVerses.add({
            'surah': surahNumber,
            'ayah': ayahsAr[j]['numberInSurah'],
            'textAr': ayahsAr[j]['text'],
            'textFr': ayahsFr[j]['text'],
          });
        }
      }

      // Sauvegarder le fichier combiné
      final outputFile = File(p.join(outputDir.path, 'quran_full.json'));
      await outputFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(combinedVerses),
      );

      print('\n✅ Corpus téléchargé avec succès !');
      print('📊 Total : ${combinedVerses.length} versets');
      print('📁 Fichier : ${outputFile.path}');

      // Créer aussi un fichier de métadonnées des sourates
      final surahsInfo = <Map<String, dynamic>>[];
      for (final surah in arabicData) {
        surahsInfo.add({
          'number': surah['number'],
          'name': surah['name'],
          'englishName': surah['englishName'],
          'frenchName': _getFrenchSurahName(surah['number']),
          'numberOfAyahs': surah['numberOfAyahs'],
          'revelationType': surah['revelationType'],
        });
      }

      final metaFile = File(p.join(outputDir.path, 'surahs_metadata.json'));
      await metaFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(surahsInfo),
      );

      print('📁 Métadonnées : ${metaFile.path}');
    } else {
      print('❌ Erreur lors du téléchargement');
      exit(1);
    }
  } catch (e) {
    print('❌ Erreur : $e');
    print('\nAlternative : Téléchargez manuellement depuis :');
    print('- Arabe : https://tanzil.net/download/');
    print('- Français : https://www.islam-fr.com/coran/francais/');
    exit(1);
  }
}

// Noms français des sourates principales
String _getFrenchSurahName(int number) {
  const names = {
    1: 'Al-Fatiha (L\'ouverture)',
    2: 'Al-Baqara (La vache)',
    3: 'Al-Imran (La famille d\'Imran)',
    4: 'An-Nisa (Les femmes)',
    5: 'Al-Maida (La table)',
    6: 'Al-Anam (Les bestiaux)',
    7: 'Al-Araf',
    8: 'Al-Anfal (Le butin)',
    9: 'At-Tawba (Le repentir)',
    10: 'Yunus (Jonas)',
    11: 'Hud',
    12: 'Yusuf (Joseph)',
    13: 'Ar-Rad (Le tonnerre)',
    14: 'Ibrahim (Abraham)',
    15: 'Al-Hijr',
    16: 'An-Nahl (Les abeilles)',
    17: 'Al-Isra (Le voyage nocturne)',
    18: 'Al-Kahf (La caverne)',
    19: 'Maryam (Marie)',
    20: 'Ta-Ha',
    21: 'Al-Anbiya (Les prophètes)',
    22: 'Al-Hajj (Le pèlerinage)',
    23: 'Al-Muminun (Les croyants)',
    24: 'An-Nur (La lumière)',
    25: 'Al-Furqan (Le discernement)',
    26: 'Ash-Shuara (Les poètes)',
    27: 'An-Naml (Les fourmis)',
    28: 'Al-Qasas (Le récit)',
    29: 'Al-Ankabut (L\'araignée)',
    30: 'Ar-Rum (Les romains)',
    36: 'Ya-Sin',
    55: 'Ar-Rahman (Le Miséricordieux)',
    56: 'Al-Waqia (L\'événement)',
    67: 'Al-Mulk (La royauté)',
    78: 'An-Naba (La nouvelle)',
    112: 'Al-Ikhlas (Le monothéisme pur)',
    113: 'Al-Falaq (L\'aube naissante)',
    114: 'An-Nas (Les hommes)',
  };
  return names[number] ?? 'Sourate $number';
}
