import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:spiritual_routines/design_system/inspired_theme.dart';
import 'package:spiritual_routines/l10n/app_localizations.dart';

/// Helper pour les tests Golden avec thème et localisation
class GoldenTestHelper {
  /// Wrapper standard pour les tests golden avec thème
  static Widget wrapWithTheme(
    Widget child, {
    bool isDark = false,
    ProviderContainer? container,
  }) {
    return ProviderScope(
      overrides: [],
      child: MaterialApp(
        theme: isDark ? InspiredTheme.dark : InspiredTheme.light,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: const Locale('fr', 'FR'),
        home: container != null
            ? UncontrolledProviderScope(
                container: container,
                child: Scaffold(body: child),
              )
            : Scaffold(body: child),
      ),
    );
  }

  /// Configuration standard pour les tests golden
  static Future<void> configureGoldenTests() async {
    await loadAppFonts();
  }

  /// Taille d'écran pour les tests golden
  static const Size phoneSize = Size(375, 667); // iPhone SE
  static const Size tabletSize = Size(768, 1024); // iPad
  static const Size desktopSize = Size(1440, 900); // Desktop
}

/// Extension pour simplifier les tests golden
extension GoldenTestExtension on Widget {
  /// Test golden avec thème light
  Future<void> testGoldenLight(String name) async {
    return testGoldens(
      name,
      (tester) async {
        await tester.pumpWidgetBuilder(
          GoldenTestHelper.wrapWithTheme(this),
          surfaceSize: GoldenTestHelper.phoneSize,
        );
      },
    );
  }

  /// Test golden avec thème dark
  Future<void> testGoldenDark(String name) async {
    return testGoldens(
      '${name}_dark',
      (tester) async {
        await tester.pumpWidgetBuilder(
          GoldenTestHelper.wrapWithTheme(this, isDark: true),
          surfaceSize: GoldenTestHelper.phoneSize,
        );
      },
    );
  }

  /// Test golden avec les deux thèmes
  Future<void> testGoldenBoth(String name) async {
    await testGoldenLight(name);
    await testGoldenDark(name);
  }
}
