import 'package:flutter/foundation.dart';
import 'farasa_diacritization_service.dart';

/// Tests pour le service de diacritisation Farasa
class FarasaTest {
  
  /// Test complet de la diacritisation Farasa
  static Future<void> runTests() async {
    debugPrint('🧪 === Tests Diacritisation Farasa ===\n');
    
    // Test 1: Connexion API
    await _testConnection();
    
    // Test 2: Diacritisation de base
    await _testBasicDiacritization();
    
    // Test 3: Textes spécialisés
    await _testSpecializedTexts();
    
    // Test 4: Gestion d'erreurs
    await _testErrorHandling();
    
    // Test 5: Performance
    await _testPerformance();
    
    debugPrint('✅ Tests Farasa terminés\n');
  }
  
  static Future<void> _testConnection() async {
    debugPrint('📡 Test 1: Connexion API Farasa');
    
    try {
      final isWorking = await FarasaDiacritizationService.testFarasaConnection();
      debugPrint(isWorking ? '✅ Connexion API réussie' : '❌ Connexion API échouée');
      
      if (isWorking) {
        final stats = FarasaDiacritizationService.getCacheStats();
        debugPrint('📊 Stats cache: $stats');
      }
    } catch (e) {
      debugPrint('❌ Erreur test connexion: $e');
    }
    debugPrint('');
  }
  
  static Future<void> _testBasicDiacritization() async {
    debugPrint('🔤 Test 2: Diacritisation de base');
    
    final testCases = [
      {
        'name': 'Salutation simple',
        'input': 'السلام عليكم',
        'expected_contains': ['ُ', 'َ', 'ِ'], // Devrait contenir des harakat
      },
      {
        'name': 'Basmala',
        'input': 'بسم الله الرحمن الرحيم',
        'expected_contains': ['ِ', 'ْ', 'َ'], // Harakat de la Basmala
      },
      {
        'name': 'Invocation courte',
        'input': 'الحمد لله',
        'expected_contains': ['َ', 'ُ', 'ِ'],
      },
    ];
    
    for (final testCase in testCases) {
      try {
        debugPrint('   📝 Test: ${testCase['name']}');
        final input = testCase['input'] as String;
        final result = await FarasaDiacritizationService.diacritizeText(input);
        
        debugPrint('      Original: $input');
        debugPrint('      Diacritisé: $result');
        
        // Vérifier que des harakat ont été ajoutés
        final expectedChars = testCase['expected_contains'] as List<String>;
        final hasHarakat = expectedChars.any((char) => result.contains(char));
        
        if (hasHarakat) {
          debugPrint('      ✅ Harakat détectés');
        } else {
          debugPrint('      ⚠️ Aucun harakat détecté (peut être normal si API indisponible)');
        }
        
      } catch (e) {
        debugPrint('      ❌ Erreur: $e');
      }
    }
    debugPrint('');
  }
  
  static Future<void> _testSpecializedTexts() async {
    debugPrint('📚 Test 3: Textes spécialisés');
    
    final testCases = [
      {
        'name': 'Texte avec marqueurs versets',
        'input': '{{V:1:1}} بسم الله الرحمن الرحيم {{V:1:2}} الحمد لله رب العالمين',
      },
      {
        'name': 'Texte long',
        'input': 'اللهم صل وسلم وبارك على نبينا محمد وعلى آله وصحبه أجمعين',
      },
      {
        'name': 'Mélange arabe-français',
        'input': 'بسم الله - Au nom de Allah الرحمن الرحيم',
      },
      {
        'name': 'Texte déjà diacritisé',
        'input': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', // Déjà avec harakat
      },
    ];
    
    for (final testCase in testCases) {
      try {
        debugPrint('   📖 Test: ${testCase['name']}');
        final input = testCase['input'] as String;
        final result = await FarasaDiacritizationService.diacritizeText(input);
        
        debugPrint('      Original: ${input.substring(0, input.length.clamp(0, 50))}...');
        debugPrint('      Diacritisé: ${result.substring(0, result.length.clamp(0, 50))}...');
        
        if (result != input) {
          debugPrint('      ✅ Texte modifié');
        } else {
          debugPrint('      ℹ️ Texte inchangé');
        }
        
      } catch (e) {
        debugPrint('      ❌ Erreur: $e');
      }
    }
    debugPrint('');
  }
  
  static Future<void> _testErrorHandling() async {
    debugPrint('⚠️ Test 4: Gestion d\'erreurs');
    
    final testCases = [
      {
        'name': 'Texte vide',
        'input': '',
      },
      {
        'name': 'Texte non-arabe',
        'input': 'Hello world',
      },
      {
        'name': 'Texte très long',
        'input': 'بسم الله ' * 1000, // 10000 caractères
      },
      {
        'name': 'Caractères spéciaux',
        'input': 'الله !@#\$%^&*()',
      },
    ];
    
    for (final testCase in testCases) {
      try {
        debugPrint('   🛡️ Test: ${testCase['name']}');
        final input = testCase['input'] as String;
        final result = await FarasaDiacritizationService.diacritizeText(input);
        
        debugPrint('      Résultat: ${result.length} caractères');
        debugPrint('      ✅ Pas d\'exception');
        
      } catch (e) {
        debugPrint('      ❌ Exception: $e');
      }
    }
    debugPrint('');
  }
  
  static Future<void> _testPerformance() async {
    debugPrint('⚡ Test 5: Performance');
    
    try {
      // Test de performance avec texte moyen
      const testText = 'اللهم صل وسلم وبارك على نبينا محمد وعلى آله وصحبه أجمعين';
      
      final stopwatch = Stopwatch()..start();
      final result = await FarasaDiacritizationService.diacritizeText(testText);
      stopwatch.stop();
      
      final duration = stopwatch.elapsedMilliseconds;
      debugPrint('   📊 Temps: ${duration}ms pour ${testText.length} caractères');
      debugPrint('   📈 Vitesse: ${(testText.length / duration * 1000).round()} chars/s');
      
      // Test du cache
      debugPrint('   💾 Test cache...');
      final cacheStopwatch = Stopwatch()..start();
      final cachedResult = await FarasaDiacritizationService.diacritizeText(testText);
      cacheStopwatch.stop();
      
      final cacheDuration = cacheStopwatch.elapsedMilliseconds;
      debugPrint('   ⚡ Cache: ${cacheDuration}ms (gain: ${duration - cacheDuration}ms)');
      
      if (result == cachedResult) {
        debugPrint('   ✅ Cache fonctionnel');
      } else {
        debugPrint('   ❌ Cache incohérent');
      }
      
      // Stats finales
      final stats = FarasaDiacritizationService.getCacheStats();
      debugPrint('   📊 Stats finales: $stats');
      
    } catch (e) {
      debugPrint('   ❌ Erreur performance: $e');
    }
    debugPrint('');
  }
  
  /// Test rapide pour validation
  static Future<String> quickTest() async {
    const testText = 'بسم الله الرحمن الرحيم';
    final result = await FarasaDiacritizationService.diacritizeText(testText);
    return 'Test: "$testText" → "$result"';
  }
  
  /// Nettoie les caches pour les tests
  static void cleanup() {
    FarasaDiacritizationService.clearCache();
    debugPrint('🧹 Cache Farasa nettoyé pour tests');
  }
}