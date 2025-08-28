import 'package:flutter_test/flutter_test.dart';
import 'package:spiritual_routines/core/models/task_category.dart';

void main() {
  group('TaskCategory Enum Tests', () {
    test('should have correct number of categories', () {
      expect(TaskCategory.values.length, equals(7));
    });

    test('should have all expected categories', () {
      expect(TaskCategory.values, contains(TaskCategory.louange));
      expect(TaskCategory.values, contains(TaskCategory.protection));
      expect(TaskCategory.values, contains(TaskCategory.pardon));
      expect(TaskCategory.values, contains(TaskCategory.guidance));
      expect(TaskCategory.values, contains(TaskCategory.gratitude));
      expect(TaskCategory.values, contains(TaskCategory.healing));
      expect(TaskCategory.values, contains(TaskCategory.custom));
    });

    test('louange category should have correct properties', () {
      const category = TaskCategory.louange;
      
      expect(category.label, equals('Louange'));
      expect(category.emoji, equals('📿'));
    });

    test('protection category should have correct properties', () {
      const category = TaskCategory.protection;
      
      expect(category.label, equals('Protection'));
      expect(category.emoji, equals('🛡️'));
    });

    test('pardon category should have correct properties', () {
      const category = TaskCategory.pardon;
      
      expect(category.label, equals('Pardon'));
      expect(category.emoji, equals('🤲'));
    });

    test('guidance category should have correct properties', () {
      const category = TaskCategory.guidance;
      
      expect(category.label, equals('Guidance'));
      expect(category.emoji, equals('🌟'));
    });

    test('gratitude category should have correct properties', () {
      const category = TaskCategory.gratitude;
      
      expect(category.label, equals('Gratitude'));
      expect(category.emoji, equals('🙏'));
    });

    test('healing category should have correct properties', () {
      const category = TaskCategory.healing;
      
      expect(category.label, equals('Guérison'));
      expect(category.emoji, equals('💚'));
    });

    test('custom category should have correct properties', () {
      const category = TaskCategory.custom;
      
      expect(category.label, equals('Personnalisé'));
      expect(category.emoji, equals('✨'));
    });

    test('should support enum comparison', () {
      const category1 = TaskCategory.louange;
      const category2 = TaskCategory.louange;
      const category3 = TaskCategory.protection;
      
      expect(category1, equals(category2));
      expect(category1, isNot(equals(category3)));
    });

    test('should support switch statements', () {
      String getDescription(TaskCategory category) {
        switch (category) {
          case TaskCategory.louange:
            return 'Praise and worship';
          case TaskCategory.protection:
            return 'Divine protection';
          case TaskCategory.pardon:
            return 'Forgiveness requests';
          case TaskCategory.guidance:
            return 'Seeking guidance';
          case TaskCategory.gratitude:
            return 'Expressing gratitude';
          case TaskCategory.healing:
            return 'Healing prayers';
          case TaskCategory.custom:
            return 'Custom prayers';
        }
      }
      
      expect(getDescription(TaskCategory.louange), equals('Praise and worship'));
      expect(getDescription(TaskCategory.protection), equals('Divine protection'));
      expect(getDescription(TaskCategory.pardon), equals('Forgiveness requests'));
      expect(getDescription(TaskCategory.guidance), equals('Seeking guidance'));
      expect(getDescription(TaskCategory.gratitude), equals('Expressing gratitude'));
      expect(getDescription(TaskCategory.healing), equals('Healing prayers'));
      expect(getDescription(TaskCategory.custom), equals('Custom prayers'));
    });

    test('should have unique labels', () {
      final labels = TaskCategory.values.map((e) => e.label).toList();
      final uniqueLabels = Set<String>.from(labels);
      
      expect(uniqueLabels.length, equals(labels.length));
    });

    test('should have unique emojis', () {
      final emojis = TaskCategory.values.map((e) => e.emoji).toList();
      final uniqueEmojis = Set<String>.from(emojis);
      
      expect(uniqueEmojis.length, equals(emojis.length));
    });

    test('should support name property', () {
      expect(TaskCategory.louange.name, equals('louange'));
      expect(TaskCategory.protection.name, equals('protection'));
      expect(TaskCategory.pardon.name, equals('pardon'));
      expect(TaskCategory.guidance.name, equals('guidance'));
      expect(TaskCategory.gratitude.name, equals('gratitude'));
      expect(TaskCategory.healing.name, equals('healing'));
      expect(TaskCategory.custom.name, equals('custom'));
    });

    test('should support index property', () {
      expect(TaskCategory.louange.index, equals(0));
      expect(TaskCategory.protection.index, equals(1));
      expect(TaskCategory.pardon.index, equals(2));
      expect(TaskCategory.guidance.index, equals(3));
      expect(TaskCategory.gratitude.index, equals(4));
      expect(TaskCategory.healing.index, equals(5));
      expect(TaskCategory.custom.index, equals(6));
    });

    test('should support collection operations', () {
      // Filter spiritual categories (exclude custom)
      final spiritualCategories = TaskCategory.values
          .where((category) => category != TaskCategory.custom)
          .toList();
      
      expect(spiritualCategories.length, equals(6));
      expect(spiritualCategories, isNot(contains(TaskCategory.custom)));
      
      // Map to display strings
      final displayStrings = TaskCategory.values
          .map((category) => '${category.emoji} ${category.label}')
          .toList();
      
      expect(displayStrings, contains('📿 Louange'));
      expect(displayStrings, contains('🛡️ Protection'));
      expect(displayStrings, contains('✨ Personnalisé'));
    });

    test('toString should return name', () {
      expect(TaskCategory.louange.toString(), equals('TaskCategory.louange'));
      expect(TaskCategory.protection.toString(), equals('TaskCategory.protection'));
      expect(TaskCategory.custom.toString(), equals('TaskCategory.custom'));
    });

    test('should be serializable to name', () {
      // This tests that enum names can be used for serialization
      final categoryNames = TaskCategory.values.map((e) => e.name).toList();
      
      for (final name in categoryNames) {
        final category = TaskCategory.values.firstWhere((e) => e.name == name);
        expect(category.name, equals(name));
      }
    });
  });
}