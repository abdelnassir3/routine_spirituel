import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:spiritual_routines/features/home/modern_home_page.dart';
import 'golden_test_helper.dart';

void main() {
  group('Home Page Golden Tests', () {
    setUpAll(() async {
      await GoldenTestHelper.configureGoldenTests();
    });

    testGoldens('modern_home_page renders correctly', (tester) async {
      // Test page d'accueil moderne avec thème light
      await tester.pumpWidgetBuilder(
        GoldenTestHelper.wrapWithTheme(
          const ModernHomePage(),
        ),
        surfaceSize: GoldenTestHelper.phoneSize,
      );
    });

    testGoldens('modern_home_page dark theme', (tester) async {
      // Test page d'accueil moderne avec thème dark
      await tester.pumpWidgetBuilder(
        GoldenTestHelper.wrapWithTheme(
          const ModernHomePage(),
          isDark: true,
        ),
        surfaceSize: GoldenTestHelper.phoneSize,
      );
    });

    testGoldens('modern_home_page tablet size', (tester) async {
      // Test responsive sur tablette
      await tester.pumpWidgetBuilder(
        GoldenTestHelper.wrapWithTheme(
          const ModernHomePage(),
        ),
        surfaceSize: GoldenTestHelper.tabletSize,
      );
    });
  });
}
