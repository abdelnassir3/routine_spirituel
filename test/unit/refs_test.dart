import 'package:flutter_test/flutter_test.dart';
import 'package:spiritual_routines/core/utils/refs.dart';

void main() {
  group('VerseRange Tests', () {
    test('VerseRange should be created with correct values', () {
      const range = VerseRange(2, 5, 10);

      expect(range.surah, equals(2));
      expect(range.start, equals(5));
      expect(range.end, equals(10));
    });

    test('VerseRange equality', () {
      const range1 = VerseRange(2, 5, 10);
      const range2 = VerseRange(2, 5, 10);
      const range3 = VerseRange(2, 5, 11);

      // Note: Dart doesn't auto-generate equality for classes without override
      // These tests verify the constructor works correctly
      expect(range1.surah, equals(range2.surah));
      expect(range1.start, equals(range2.start));
      expect(range1.end, equals(range2.end));

      expect(range1.end, isNot(equals(range3.end)));
    });
  });

  group('parseRefs Function Tests', () {
    test('should parse empty input', () {
      expect(parseRefs(''), isEmpty);
      expect(parseRefs('  '), isEmpty);
      expect(parseRefs('   '), isEmpty);
    });

    test('should parse single surah number', () {
      final result = parseRefs('2');

      expect(result, hasLength(1));
      expect(result[0].surah, equals(2));
      expect(result[0].start, equals(1));
      expect(result[0].end, equals(999));
    });

    test('should parse multiple surah numbers', () {
      final result = parseRefs('2, 3, 114');

      expect(result, hasLength(3));

      expect(result[0].surah, equals(2));
      expect(result[0].start, equals(1));
      expect(result[0].end, equals(999));

      expect(result[1].surah, equals(3));
      expect(result[1].start, equals(1));
      expect(result[1].end, equals(999));

      expect(result[2].surah, equals(114));
      expect(result[2].start, equals(1));
      expect(result[2].end, equals(999));
    });

    test('should parse single verse reference', () {
      final result = parseRefs('2:255');

      expect(result, hasLength(1));
      expect(result[0].surah, equals(2));
      expect(result[0].start, equals(255));
      expect(result[0].end, equals(255));
    });

    test('should parse verse range reference', () {
      final result = parseRefs('2:1-5');

      expect(result, hasLength(1));
      expect(result[0].surah, equals(2));
      expect(result[0].start, equals(1));
      expect(result[0].end, equals(5));
    });

    test('should parse mixed references with comma separator', () {
      final result = parseRefs('1, 2:255, 3:1-5');

      expect(result, hasLength(3));

      // Full surah
      expect(result[0].surah, equals(1));
      expect(result[0].start, equals(1));
      expect(result[0].end, equals(999));

      // Single verse
      expect(result[1].surah, equals(2));
      expect(result[1].start, equals(255));
      expect(result[1].end, equals(255));

      // Verse range
      expect(result[2].surah, equals(3));
      expect(result[2].start, equals(1));
      expect(result[2].end, equals(5));
    });

    test('should parse mixed references with semicolon separator', () {
      final result = parseRefs('1; 2:255; 3:1-5');

      expect(result, hasLength(3));

      expect(result[0].surah, equals(1));
      expect(result[1].surah, equals(2));
      expect(result[2].surah, equals(3));
    });

    test('should handle whitespace correctly', () {
      final result = parseRefs('  1  ,  2:255  ,  3:1-5  ');

      expect(result, hasLength(3));
      expect(result[0].surah, equals(1));
      expect(result[1].surah, equals(2));
      expect(result[2].surah, equals(3));
    });

    test('should handle mixed separators', () {
      final result = parseRefs('1, 2:255; 3:1-5, 4');

      expect(result, hasLength(4));
      expect(result[0].surah, equals(1));
      expect(result[1].surah, equals(2));
      expect(result[2].surah, equals(3));
      expect(result[3].surah, equals(4));
    });

    test('should ignore invalid formats', () {
      final result = parseRefs('1, invalid, 2:255, bad:format:extra, 3');

      expect(result, hasLength(3));
      expect(result[0].surah, equals(1));
      expect(result[1].surah, equals(2));
      expect(result[2].surah, equals(3));
    });

    test('should handle edge cases for surah numbers', () {
      // Test valid surah numbers (1-114)
      final result = parseRefs('1, 114');

      expect(result, hasLength(2));
      expect(result[0].surah, equals(1));
      expect(result[1].surah, equals(114));
    });

    test('should handle three-digit surah and verse numbers', () {
      final result = parseRefs('114:1-6');

      expect(result, hasLength(1));
      expect(result[0].surah, equals(114));
      expect(result[0].start, equals(1));
      expect(result[0].end, equals(6));
    });

    test('should handle large verse numbers', () {
      final result = parseRefs('2:100-286');

      expect(result, hasLength(1));
      expect(result[0].surah, equals(2));
      expect(result[0].start, equals(100));
      expect(result[0].end, equals(286));
    });

    test('should handle empty segments', () {
      final result = parseRefs('1,, 2:255,; 3');

      expect(result, hasLength(3));
      expect(result[0].surah, equals(1));
      expect(result[1].surah, equals(2));
      expect(result[2].surah, equals(3));
    });

    test('should handle complex real-world example', () {
      final result = parseRefs('1; 2:1-5, 2:255; 3:1-3, 114');

      expect(result, hasLength(5));

      // Al-Fatiha (full surah)
      expect(result[0].surah, equals(1));
      expect(result[0].start, equals(1));
      expect(result[0].end, equals(999));

      // Al-Baqarah first 5 verses
      expect(result[1].surah, equals(2));
      expect(result[1].start, equals(1));
      expect(result[1].end, equals(5));

      // Ayat al-Kursi
      expect(result[2].surah, equals(2));
      expect(result[2].start, equals(255));
      expect(result[2].end, equals(255));

      // Al-Imran first 3 verses
      expect(result[3].surah, equals(3));
      expect(result[3].start, equals(1));
      expect(result[3].end, equals(3));

      // An-Nas (full surah)
      expect(result[4].surah, equals(114));
      expect(result[4].start, equals(1));
      expect(result[4].end, equals(999));
    });

    test('performance test with large input', () {
      // Generate a large input with many references
      final largeInput =
          List.generate(100, (i) => '${i + 1}:1-${i + 1}').join(', ');

      final stopwatch = Stopwatch()..start();
      final result = parseRefs(largeInput);
      stopwatch.stop();

      expect(result, hasLength(100));
      expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should be fast
    });
  });
}
