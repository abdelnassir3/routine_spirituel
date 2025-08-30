import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

void main() {
  group('QuranCorpusWebService Fix Verification', () {
    test('should confirm quran_full_fixed.json file path is used in service', () async {
      // Arrange - lire le fichier service
      final serviceFile = File('/Users/mac/Documents/Projet_sprit/lib/core/services/quran_corpus_web_service.dart');
      final serviceContent = await serviceFile.readAsString();

      // Assert - vérifier que le bon fichier est référencé
      expect(serviceContent.contains('assets/corpus/quran_full_fixed.json'), isTrue,
          reason: 'Le service devrait référencer quran_full_fixed.json');
      
      expect(serviceContent.contains('assets/corpus/quran_combined.json'), isFalse,
          reason: 'Le service ne devrait plus référencer quran_combined.json');

      print('✅ Test réussi: Le service utilise bien quran_full_fixed.json');
    });

    test('should verify quran_full_fixed.json contains target verses', () async {
      // Arrange - vérifier que le fichier JSON complet existe
      final jsonFile = File('/Users/mac/Documents/Projet_sprit/assets/corpus/quran_full_fixed.json');
      expect(await jsonFile.exists(), isTrue, 
          reason: 'Le fichier quran_full_fixed.json doit exister');

      // Act - lire le contenu du fichier
      final jsonContent = await jsonFile.readAsString();

      // Assert - vérifier que les versets cibles existent
      expect(jsonContent.contains('"surah": 7'), isTrue,
          reason: 'Le fichier doit contenir la Sourate 7');
      
      expect(jsonContent.contains('"ayah": 2'), isTrue,
          reason: 'Le fichier doit contenir le verset 2');
      
      expect(jsonContent.contains('"ayah": 3'), isTrue,
          reason: 'Le fichier doit contenir le verset 3');

      // Vérifier la taille approximative (6236 versets)
      final versesCount = '"surah":'.allMatches(jsonContent).length;
      expect(versesCount, greaterThan(6000), 
          reason: 'Le fichier doit contenir plus de 6000 versets');

      print('✅ Test réussi: quran_full_fixed.json contient les versets cibles');
      print('✅ Test réussi: Le fichier contient $versesCount versets');
    });

    test('should verify isar_web_stub.dart uses QuranCorpusWebService', () async {
      // Arrange - lire le fichier stub
      final stubFile = File('/Users/mac/Documents/Projet_sprit/lib/core/persistence/isar_web_stub.dart');
      final stubContent = await stubFile.readAsString();

      // Assert - vérifier l'intégration avec QuranCorpusWebService
      expect(stubContent.contains('QuranCorpusWebService'), isTrue,
          reason: 'Le stub doit utiliser QuranCorpusWebService');
      
      expect(stubContent.contains('service.getRange'), isTrue,
          reason: 'Le stub doit appeler getRange du service');

      print('✅ Test réussi: isar_web_stub.dart utilise bien QuranCorpusWebService');
    });
  });
}