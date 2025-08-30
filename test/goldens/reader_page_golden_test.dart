import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:spiritual_routines/features/reader/modern_reader_page.dart';
import 'golden_test_helper.dart';

void main() {
  group('Reader Page Golden Tests', () {
    setUpAll(() async {
      await GoldenTestHelper.configureGoldenTests();
    });

    testGoldens('modern_reader_page renders correctly', (tester) async {
      // Test interface de lecture moderne
      await tester.pumpWidgetBuilder(
        GoldenTestHelper.wrapWithTheme(
          const ModernReaderPage(),
        ),
        surfaceSize: GoldenTestHelper.phoneSize,
      );
    });

    testGoldens('modern_reader_page dark theme', (tester) async {
      // Test interface de lecture en mode sombre
      await tester.pumpWidgetBuilder(
        GoldenTestHelper.wrapWithTheme(
          const ModernReaderPage(),
          isDark: true,
        ),
        surfaceSize: GoldenTestHelper.phoneSize,
      );
    });

    testGoldens('modern_reader_page desktop size', (tester) async {
      // Test responsive sur desktop
      await tester.pumpWidgetBuilder(
        GoldenTestHelper.wrapWithTheme(
          const ModernReaderPage(),
        ),
        surfaceSize: GoldenTestHelper.desktopSize,
      );
    });
  });
}
