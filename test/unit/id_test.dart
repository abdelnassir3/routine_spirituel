import 'package:flutter_test/flutter_test.dart';
import 'package:spiritual_routines/core/utils/id.dart';

void main() {
  group('ID Utility Tests', () {
    test('newId() should generate non-empty string', () {
      final id = newId();
      expect(id, isNotNull);
      expect(id, isNotEmpty);
      expect(id, isA<String>());
    });

    test('newId() should generate unique IDs', () {
      final id1 = newId();
      final id2 = newId();
      
      expect(id1, isNot(equals(id2)));
    });

    test('newId() should generate numeric string', () {
      final id = newId();
      
      // Should be parsable as integer
      expect(() => int.parse(id), returnsNormally);
      
      // Should be a valid timestamp (microseconds since epoch)
      final timestamp = int.parse(id);
      expect(timestamp, greaterThan(0));
      
      // Should be a reasonable timestamp (after 2020)
      final year2020Microseconds = DateTime(2020).microsecondsSinceEpoch;
      expect(timestamp, greaterThan(year2020Microseconds));
    });

    test('newId() should generate IDs in ascending order', () async {
      final id1 = newId();
      // Small delay to ensure different timestamp
      await Future.delayed(const Duration(microseconds: 1));
      final id2 = newId();
      
      final timestamp1 = int.parse(id1);
      final timestamp2 = int.parse(id2);
      
      expect(timestamp2, greaterThanOrEqualTo(timestamp1));
    });

    test('newId() performance test - should be fast', () {
      final stopwatch = Stopwatch()..start();
      
      // Generate 1000 IDs
      for (int i = 0; i < 1000; i++) {
        newId();
      }
      
      stopwatch.stop();
      
      // Should complete in reasonable time (less than 100ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('newId() should be thread-safe', () async {
      final ids = <String>[];
      final futures = <Future<void>>[];
      
      // Create multiple concurrent futures
      for (int i = 0; i < 50; i++) {
        futures.add(
          Future.microtask(() {
            ids.add(newId());
          })
        );
      }
      
      await Future.wait(futures);
      
      // All IDs should be unique
      final uniqueIds = Set<String>.from(ids);
      expect(uniqueIds.length, equals(ids.length));
    });

    test('newId() multiple calls should have consistent format', () {
      final ids = List.generate(10, (_) => newId());
      
      for (final id in ids) {
        // Should be numeric string
        expect(() => int.parse(id), returnsNormally);
        
        // Should have reasonable length (timestamp in microseconds)
        expect(id.length, greaterThanOrEqualTo(16)); // Year 2023+ timestamp
        expect(id.length, lessThan(20)); // Reasonable upper bound
        
        // Should contain only digits
        expect(RegExp(r'^\d+$').hasMatch(id), isTrue);
      }
    });
  });
}