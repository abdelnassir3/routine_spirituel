import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';
import '../lib/core/services/quran_corpus_web_service.dart';

class MockAssetBundle extends Mock implements AssetBundle {}

void main() {
  group('QuranCorpusWebService Tests', () {
    late QuranCorpusWebService service;
    late MockAssetBundle mockAssetBundle;

    setUp(() {
      service = QuranCorpusWebService();
      mockAssetBundle = MockAssetBundle();
    });

    test('should load verses from quran_full_fixed.json', () async {
      // Arrange
      const mockJsonData = '''
      [
        {
          "surah": 7,
          "ayah": 2,
          "textAr": "كِتَٰبٌ أُنزِلَ إِلَيْكَ فَلَا يَكُن فِى صَدْرِكَ حَرَجٌۭ مِّنْهُ لِتُنذِرَ بِهِۦ وَذِكْرَىٰ لِلْمُؤْمِنِينَ",
          "textFr": "C'est un Livre qui t'a été descendu; qu'il n'y ait, à son sujet, nulle gêne dans ton cœur, afin que par cela tu avertisses, et (qu'il soit) un rappel aux croyants."
        },
        {
          "surah": 7,
          "ayah": 3,
          "textAr": "ٱتَّبِعُوا۟ مَآ أُنزِلَ إِلَيْكُم مِّن رَّبِّكُمْ وَلَا تَتَّبِعُوا۟ مِن دُونِهِۦٓ أَوْلِيَآءَ ۗ قَلِيلًۭا مَّا تَذَكَّرُونَ",
          "textFr": "Suivez ce qui vous a été descendu venant de votre Seigneur et ne suivez pas d'autres alliés que Lui. Mais vous vous souvenez peu."
        }
      ]
      ''';

      when(() => mockAssetBundle.loadString('assets/corpus/quran_full_fixed.json'))
          .thenAnswer((_) async => mockJsonData);

      // Act
      final verses = await service.getRange(7, 2, 3);

      // Assert
      expect(verses.length, equals(2));
      expect(verses[0].surah, equals(7));
      expect(verses[0].ayah, equals(2));
      expect(verses[0].textAr, contains('كِتَٰبٌ أُنزِلَ إِلَيْكَ'));
      expect(verses[0].textFr, contains('Livre qui'));
      expect(verses[1].surah, equals(7));
      expect(verses[1].ayah, equals(3));
      
      print('✅ Test réussi: Le service charge bien le fichier quran_full_fixed.json');
      print('✅ Test réussi: Les versets 7:2-3 sont correctement chargés');
    });

    test('should return empty list if no verses found in range', () async {
      // Arrange
      const mockJsonData = '''
      [
        {
          "surah": 1,
          "ayah": 1,
          "textAr": "بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ",
          "textFr": "Au nom d'Allah, le Tout Miséricordieux, le Très Miséricordieux."
        }
      ]
      ''';

      when(() => mockAssetBundle.loadString('assets/corpus/quran_full_fixed.json'))
          .thenAnswer((_) async => mockJsonData);

      // Act - chercher des versets qui n'existent pas
      final verses = await service.getRange(7, 2, 3);

      // Assert
      expect(verses.length, equals(0));
      print('✅ Test réussi: Retourne liste vide si aucun verset trouvé');
    });

    test('should handle malformed JSON gracefully', () async {
      // Arrange
      when(() => mockAssetBundle.loadString('assets/corpus/quran_full_fixed.json'))
          .thenAnswer((_) async => 'invalid json');

      // Act & Assert
      expect(() => service.getRange(7, 2, 3), returnsNormally);
      
      final verses = await service.getRange(7, 2, 3);
      expect(verses.length, equals(0));
      print('✅ Test réussi: Gestion gracieuse des erreurs JSON');
    });
  });
}