import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import '../lib/core/persistence/isar_web_stub.dart';
import '../lib/core/persistence/drift_web_stub.dart';

void main() {
  group('Persistence Fix Tests', () {
    test('Isar web stub should store and retrieve ContentDoc data', () async {
      // Arrange
      final stub = IsarStub();
      final contentDoc = ContentDoc()
        ..id = 1
        ..taskId = 'test-task'
        ..locale = 'fr'
        ..kind = 'text'
        ..body = 'Ceci est un test avec des versets du Coran Sourate 7:2-3';

      // Act - Store the document
      await stub.writeTxn(() async {
        await stub.contentDocs.put(contentDoc);
      });

      // Act - Retrieve the document
      final retrieved = await stub.contentDocs
          .filter()
          .taskIdEqualTo('test-task')
          .and()
          .localeEqualTo('fr')
          .findFirst();

      // Assert
      expect(retrieved, isNotNull);
      expect(retrieved!.taskId, equals('test-task'));
      expect(retrieved.locale, equals('fr'));
      expect(retrieved.body, contains('Sourate 7:2-3'));
      
      print('✅ Test successful: Isar web stub persistence works correctly');
    });

    test('WebStub should create session records with required fields', () async {
      // Arrange
      final webStub = WebStubExecutor();
      
      // Act - Insert a session record
      final sessionId = await webStub.runInsert(
        'INSERT INTO sessions (id, routine_id, state) VALUES (?, ?, ?)',
        ['test-session-1', 'routine-123', 'active']
      );

      // Assert - Should not throw and return valid ID
      expect(sessionId, isA<int>());
      expect(sessionId, greaterThan(0));

      // Act - Retrieve the session
      final results = await webStub.runSelect(
        'SELECT * FROM sessions WHERE id = ?',
        ['test-session-1']
      );

      // Assert - Should have the required fields
      expect(results, isNotEmpty);
      final session = results.first;
      expect(session['id'], equals('test-session-1'));
      expect(session['routine_id'], equals('routine-123'));
      expect(session['state'], equals('active'));
      expect(session['started_at'], isNotNull); // Required field should be present
      expect(session['ended_at'], isNull); // Nullable field
      expect(session['snapshot_ref'], isNull); // Nullable field
      
      print('✅ Test successful: WebStub session mapping works correctly');
    });

    test('Column mapping should handle sessions table correctly', () async {
      // Arrange
      final webStub = WebStubExecutor();
      
      // Act - Insert with column mapping
      final sessionId = await webStub.runInsert(
        'INSERT INTO sessions (id, routine_id, state, created_at) VALUES (?, ?, ?, ?)',
        ['test-session-2', 'routine-456', 'paused', '2025-08-30T12:00:00.000Z']
      );

      // Assert
      expect(sessionId, isA<int>());
      
      print('✅ Test successful: Column mapping handles sessions correctly');
    });
  });
}