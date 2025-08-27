#!/usr/bin/env dart

/*
Script de test pour vérifier si QuranCorpusService fonctionne correctement.
*/

import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 Test de QuranCorpusService');
  print('=' * 50);
  
  await testQuranCorpusService();
}

Future<void> testQuranCorpusService() async {
  try {
    // Simuler ce que fait QuranCorpusService.getRange()
    final file = File('/Users/mac/Documents/Projet_sprit/assets/corpus/quran_full.json');
    print('📁 Chargement du fichier: ${file.path}');
    
    if (!await file.exists()) {
      print('❌ ERREUR: Le fichier corpus n\'existe pas !');
      return;
    }
    
    final jsonString = await file.readAsString();
    final List<dynamic> data = jsonDecode(jsonString);
    
    print('📊 Corpus chargé: ${data.length} versets au total');
    
    // Test de récupération sourate 112 versets 1-4
    const surah = 112;
    const start = 1;
    const end = 4;
    
    print('🔍 Test: Récupération sourate $surah, versets $start-$end');
    
    final verses = data.where((v) => 
        v['surah'] == surah && 
        v['ayah'] >= start && 
        v['ayah'] <= end
    ).toList();
    
    print('📖 Versets trouvés: ${verses.length}');
    
    if (verses.isEmpty) {
      print('❌ PROBLÈME: Aucun verset trouvé !');
      return;
    }
    
    // Afficher les versets pour débug
    for (final v in verses) {
      final ayah = v['ayah'];
      final textAr = v['textAr'] ?? '';
      final textFr = v['textFr'] ?? '';
      
      print('Verset $ayah:');
      print('  AR: ${textAr.substring(0, textAr.length > 50 ? 50 : textAr.length)}...');
      print('  FR: ${textFr.substring(0, textFr.length > 50 ? 50 : textFr.length)}...');
    }
    
    // Vérifier le premier verset (devrait contenir la Basmalah)
    final firstVerse = verses.first;
    final firstTextAr = firstVerse['textAr'] ?? '';
    
    print('🔍 Premier verset complet:');
    print('"$firstTextAr"');
    
    if (firstTextAr.contains('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ')) {
      print('✅ Premier verset contient la Basmalah');
      if (firstTextAr.startsWith('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ')) {
        print('✅ Basmalah au début (format correct)');
      } else {
        print('⚠️ Basmalah présente mais pas au début');
      }
    } else {
      print('⚠️ Premier verset sans Basmalah détectable');
    }
    
    if (firstTextAr.contains('\n')) {
      print('✅ Premier verset contient des retours à la ligne');
    } else {
      print('⚠️ Premier verset sans retour à la ligne');
    }
    
    // Test de la méthode _appendVersesToBuffer simulée
    final buffer = StringBuffer();
    for (final verse in verses) {
      final text = verse['textAr'] ?? '';
      if (text.isNotEmpty) {
        buffer.writeln(text.trim());
      }
    }
    
    final result = buffer.toString();
    print('\n📄 Résultat de _appendVersesToBuffer:');
    print('-' * 40);
    print(result);
    print('-' * 40);
    
    // Vérifications finales
    final hasBasmalah = result.contains('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ');
    final hasFirstVerse = result.contains('قُلْ هُوَ ٱللَّهُ أَحَدٌ');
    
    print('\n🧪 Vérifications:');
    print('- Basmalah présente: ${hasBasmalah ? "✅" : "❌"}');
    print('- Premier verset présent: ${hasFirstVerse ? "✅" : "❌"}');
    
    if (hasBasmalah && hasFirstVerse) {
      print('\n🎉 SUCCESS: QuranCorpusService devrait fonctionner parfaitement !');
      print('📝 Le problème n\'est PAS dans le corpus ou le service.');
      print('🔍 Il faut chercher ailleurs : interface utilisateur, état, callback...');
    } else {
      print('\n❌ PROBLEM: Données manquantes ou corrompues');
    }
    
  } catch (e, stackTrace) {
    print('❌ ERREUR: $e');
    print('Stack trace: $stackTrace');
  }
}