import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import '../lib/core/persistence/isar_web_stub.dart';
import '../lib/core/persistence/drift_web_stub.dart';

void main() {
  group('Persistence Complete Fix Tests', () {
    test('Should fix ID overflow issues and generate safe IDs', () async {
      // Arrange
      final webStub = WebStubExecutor();
      
      // Act - Créer plusieurs enregistrements pour tester les IDs
      final sessionId1 = await webStub.runInsert(
        'INSERT INTO sessions (id, routine_id, state) VALUES (?, ?, ?)',
        ['session-test-1', 'routine-1', 'active']
      );
      
      final sessionId2 = await webStub.runInsert(
        'INSERT INTO sessions (id, routine_id, state) VALUES (?, ?, ?)',
        ['session-test-2', 'routine-2', 'active']
      );
      
      // Assert - Les IDs générés ne doivent pas causer d'overflow
      expect(sessionId1, isA<int>());
      expect(sessionId2, isA<int>());
      expect(sessionId1, lessThan(10000000)); // ID raisonnable
      expect(sessionId2, lessThan(10000000));
      expect(sessionId2, greaterThan(sessionId1)); // Incrémental
      
      print('✅ Test réussi: IDs générés sans overflow: $sessionId1, $sessionId2');
    });

    test('Should persist and retrieve ContentDoc with correct taskId matching', () async {
      // Arrange
      final stub = IsarStub();
      const testTaskId = 'task-123-test';
      const testLocale = 'fr';
      const testContent = 'Test content avec versets du Coran Sourate 2:255';
      
      // Créer un ContentDoc avec des données spécifiques
      final contentDoc = ContentDoc()
        ..id = 3001
        ..taskId = testTaskId
        ..locale = testLocale
        ..kind = 'text'
        ..body = testContent
        ..source = 'test'
        ..validated = true;

      // Act - Stocker le document
      await stub.writeTxn(() async {
        await stub.contentDocs.put(contentDoc);
      });

      print('📝 Stockage terminé, tentative de récupération...');

      // Act - Récupérer le document avec les mêmes critères
      final retrieved = await stub.contentDocs
          .filter()
          .taskIdEqualTo(testTaskId)
          .and()
          .localeEqualTo(testLocale)
          .findFirst();

      // Assert
      expect(retrieved, isNotNull, 
          reason: 'Le ContentDoc devrait être retrouvé avec taskId=$testTaskId et locale=$testLocale');
      
      if (retrieved != null) {
        expect(retrieved.taskId, equals(testTaskId));
        expect(retrieved.locale, equals(testLocale));
        expect(retrieved.body, equals(testContent));
        expect(retrieved.kind, equals('text'));
        expect(retrieved.validated, equals(true));
        
        print('✅ Test réussi: ContentDoc persisté et récupéré correctement');
        print('   - TaskId: ${retrieved.taskId}');
        print('   - Locale: ${retrieved.locale}');
        print('   - Body: ${retrieved.body?.substring(0, (retrieved.body?.length ?? 0).clamp(0, 50))}...');
      }
    });

    test('Should handle multiple ContentDocs for same task with different locales', () async {
      // Arrange
      final stub = IsarStub();
      const testTaskId = 'task-456-multilang';
      
      // Créer ContentDocs en français et arabe
      final contentDocFr = ContentDoc()
        ..id = 3002
        ..taskId = testTaskId
        ..locale = 'fr'
        ..kind = 'text'
        ..body = 'Contenu français avec versets'
        ..validated = true;
        
      final contentDocAr = ContentDoc()
        ..id = 3003
        ..taskId = testTaskId
        ..locale = 'ar'
        ..kind = 'text'
        ..body = 'محتوى عربي مع آيات القرآن'
        ..validated = true;

      // Act - Stocker les deux documents
      await stub.writeTxn(() async {
        await stub.contentDocs.put(contentDocFr);
        await stub.contentDocs.put(contentDocAr);
      });

      // Act - Récupérer chaque document séparément
      final retrievedFr = await stub.contentDocs
          .filter()
          .taskIdEqualTo(testTaskId)
          .and()
          .localeEqualTo('fr')
          .findFirst();
          
      final retrievedAr = await stub.contentDocs
          .filter()
          .taskIdEqualTo(testTaskId)
          .and()
          .localeEqualTo('ar')
          .findFirst();

      // Assert
      expect(retrievedFr, isNotNull, reason: 'ContentDoc FR devrait être trouvé');
      expect(retrievedAr, isNotNull, reason: 'ContentDoc AR devrait être trouvé');
      
      if (retrievedFr != null && retrievedAr != null) {
        expect(retrievedFr.taskId, equals(testTaskId));
        expect(retrievedFr.locale, equals('fr'));
        expect(retrievedFr.body, contains('français'));
        
        expect(retrievedAr.taskId, equals(testTaskId));
        expect(retrievedAr.locale, equals('ar'));
        expect(retrievedAr.body, contains('عربي'));
        
        print('✅ Test réussi: Contenus multilingues gérés correctement');
      }
    });

    test('Should create sessions with proper started_at field', () async {
      // Arrange
      final webStub = WebStubExecutor();
      
      // Act - Créer une session
      final sessionId = await webStub.runInsert(
        'INSERT INTO sessions (id, routine_id, state) VALUES (?, ?, ?)',
        ['session-started-at-test', 'routine-999', 'active']
      );
      
      // Act - Récupérer la session
      final sessions = await webStub.runSelect(
        'SELECT * FROM sessions WHERE id = ?',
        ['session-started-at-test']
      );

      // Assert
      expect(sessions, isNotEmpty);
      final session = sessions.first;
      expect(session['started_at'], isNotNull, 
          reason: 'Le champ started_at doit être présent et non null');
      expect(session['ended_at'], isNull, 
          reason: 'Le champ ended_at doit être null par défaut');
      expect(session['snapshot_ref'], isNull, 
          reason: 'Le champ snapshot_ref doit être null par défaut');
          
      print('✅ Test réussi: Session créée avec started_at = ${session['started_at']}');
    });
  });
}