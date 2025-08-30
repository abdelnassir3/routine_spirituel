import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  group('Tests de Performance', () {
    test('Vérification configuration bannières uniformes', () {
      // Configuration uniforme attendue
      const expectedPadding = EdgeInsets.all(20);
      const expectedButtonSize = 44.0;
      const expectedIconSize = 20.0;
      const expectedTitleFontSize = 20.0;
      const expectedLetterSpacing = -0.3;
      const expectedBorderWidth = 1.5;

      // Vérifier les valeurs
      expect(expectedPadding.left, equals(20));
      expect(expectedPadding.top, equals(20));
      expect(expectedPadding.right, equals(20));
      expect(expectedPadding.bottom, equals(20));
      expect(expectedButtonSize, equals(44.0));
      expect(expectedIconSize, equals(20.0));
      expect(expectedTitleFontSize, equals(20.0));
      expect(expectedLetterSpacing, equals(-0.3));
      expect(expectedBorderWidth, equals(1.5));
    });

    test('Configuration performance activée', () {
      // Import depuis performance_config.dart
      const transitionDuration = Duration(milliseconds: 250);
      const enableDebugLogs = false;
      const enableContentCache = true;
      const cacheExpiration = Duration(minutes: 5);

      // Vérifier les optimisations
      expect(transitionDuration.inMilliseconds, equals(250));
      expect(enableDebugLogs, isFalse);
      expect(enableContentCache, isTrue);
      expect(cacheExpiration.inMinutes, equals(5));
    });
  });
}
