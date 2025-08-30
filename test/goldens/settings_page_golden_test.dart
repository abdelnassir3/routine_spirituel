import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:spiritual_routines/features/settings/modern_settings_page.dart';
import 'golden_test_helper.dart';

void main() {
  group('Settings Page Golden Tests', () {
    setUpAll(() async {
      await GoldenTestHelper.configureGoldenTests();
    });

    testGoldens('modern_settings_page renders correctly', (tester) async {
      // Test page de paramètres moderne
      await tester.pumpWidgetBuilder(
        GoldenTestHelper.wrapWithTheme(
          const ModernSettingsPage(),
        ),
        surfaceSize: GoldenTestHelper.phoneSize,
      );
    });

    testGoldens('modern_settings_page dark theme', (tester) async {
      // Test paramètres en mode sombre
      await tester.pumpWidgetBuilder(
        GoldenTestHelper.wrapWithTheme(
          const ModernSettingsPage(),
          isDark: true,
        ),
        surfaceSize: GoldenTestHelper.phoneSize,
      );
    });

    testGoldens('modern_settings_page tablet responsive', (tester) async {
      // Test responsive sur tablette
      await tester.pumpWidgetBuilder(
        GoldenTestHelper.wrapWithTheme(
          const ModernSettingsPage(),
        ),
        surfaceSize: GoldenTestHelper.tabletSize,
      );
    });
  });
}
