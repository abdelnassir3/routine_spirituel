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

      // Should be a valid counter number
      final number = int.parse(id);
      expect(number, greaterThan(0));

      // Should be a reasonable counter (starts from 1000+)
      expect(number, greaterThan(1000));
    });

    test('newId() should generate IDs in ascending order', () {
      final id1 = newId();
      final id2 = newId();

      final number1 = int.parse(id1);
      final number2 = int.parse(id2);

      expect(number2, greaterThan(number1));
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
        futures.add(Future.microtask(() {
          ids.add(newId());
        }));
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

        // Should have reasonable length (counter number)
        expect(id.length, greaterThanOrEqualTo(4)); // At least 4 digits (1000+)
        expect(id.length, lessThan(10)); // Reasonable upper bound

        // Should contain only digits
        expect(RegExp(r'^\d+$').hasMatch(id), isTrue);
      }
    });
  });
}
