import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spiritual_routines/features/home/modern_home_page.dart';
import 'package:spiritual_routines/design_system/components/adaptive_navigation.dart';

void main() {
  // Helper to create a test app with ModernHomePage
  Widget createTestApp({Size? screenSize}) {
    return ProviderScope(
      child: MaterialApp.router(
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const ModernHomePage(),
            ),
            GoRoute(
              path: '/routines',
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Routines')),
              ),
            ),
            GoRoute(
              path: '/reader',
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Reader')),
              ),
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Settings')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  group('ModernHomePage Responsive Tests', () {
    testWidgets('Uses AdaptiveNavigationScaffold', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify AdaptiveNavigationScaffold is used
      expect(find.byType(AdaptiveNavigationScaffold), findsOneWidget);
    });

    testWidgets('Mobile layout shows NavigationBar', (tester) async {
      // Set mobile screen size
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Should show NavigationBar on mobile
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('Tablet layout shows NavigationRail', (tester) async {
      // Set tablet screen size
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Should show NavigationRail on tablet
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('Desktop layout shows extended NavigationRail', (tester) async {
      // Set desktop screen size
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Should show NavigationRail on desktop
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('Navigation destinations are correct', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Check navigation destinations exist
      expect(find.text('Accueil'), findsWidgets);
      expect(find.text('Routines'), findsWidgets);
      expect(find.text('Lecture'), findsWidgets);
      expect(find.text('Réglages'), findsWidgets);
    });

    testWidgets('Stats cards adapt to screen size', (tester) async {
      // Desktop: should show more stats cards
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Desktop shows additional stats
      expect(find.text('Série'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);

      // Mobile: should show fewer stats cards
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      await tester.pump();

      // Mobile doesn't show extra stats
      expect(find.text('Série'), findsNothing);
      expect(find.text('Total'), findsNothing);
    });

    testWidgets('CTA button is present', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Check CTA button exists
      expect(find.text('Créer une nouvelle routine'), findsOneWidget);
    });

    testWidgets('Routine cards are displayed', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Check routine cards exist
      expect(find.text('Prière du matin'), findsOneWidget);
      expect(find.text('Protection quotidienne'), findsOneWidget);
      expect(find.text('Gratitude du soir'), findsOneWidget);
    });
  });

  // Clean up after tests
  tearDown(() {
    TestWidgetsFlutterBinding.ensureInitialized().window.physicalSizeTestValue =
        null;
    TestWidgetsFlutterBinding.ensureInitialized()
        .window
        .devicePixelRatioTestValue = null;
  });
}
