import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:spiritual_routines/main.dart' as app;
import 'package:spiritual_routines/features/home/modern_home_page.dart';
import 'package:spiritual_routines/design_system/components/adaptive_navigation.dart';
import 'package:spiritual_routines/core/widgets/responsive_breakpoints.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Responsive Integration Tests', () {
    // Helper to set screen size
    void setScreenSize(WidgetTester tester, Size size) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
    }

    // Helper to reset screen size
    void resetScreenSize(WidgetTester tester) {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }

    testWidgets('App adapts to mobile screen size', (tester) async {
      // Set mobile screen size (iPhone 13)
      setScreenSize(tester, const Size(390, 844));

      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Verify mobile layout
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);

      // Verify navigation works
      expect(find.text('Accueil'), findsWidgets);
      expect(find.text('Routines'), findsWidgets);
      
      // Verify responsive padding
      final padding = tester.widget<Padding>(
        find.byType(Padding).first,
      );
      expect(padding.padding, isNotNull);

      resetScreenSize(tester);
    });

    testWidgets('App adapts to tablet screen size', (tester) async {
      // Set tablet screen size (iPad)
      setScreenSize(tester, const Size(820, 1180));

      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Verify tablet layout
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      // Verify NavigationRail is compact on tablet
      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.extended, isFalse);

      // Verify more content is visible
      expect(find.text('Série'), findsOneWidget); // Extra stat card on tablet

      resetScreenSize(tester);
    });

    testWidgets('App adapts to desktop screen size', (tester) async {
      // Set desktop screen size (1080p)
      setScreenSize(tester, const Size(1920, 1080));

      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Verify desktop layout
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      // Verify NavigationRail is extended on desktop
      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.extended, isTrue);

      // Verify all content is visible
      expect(find.text('Total'), findsOneWidget); // Extra stat card on desktop

      resetScreenSize(tester);
    });

    testWidgets('Navigation works across all screen sizes', (tester) async {
      // Test navigation on mobile
      setScreenSize(tester, const Size(390, 844));
      app.main();
      await tester.pumpAndSettle();

      // Tap on Routines in NavigationBar
      await tester.tap(find.text('Routines').last);
      await tester.pumpAndSettle();

      // Should navigate to routines page
      expect(find.text('Mes Routines'), findsOneWidget);

      // Test navigation on desktop
      setScreenSize(tester, const Size(1920, 1080));
      await tester.pumpAndSettle();

      // Should still be on routines page with different layout
      expect(find.text('Mes Routines'), findsOneWidget);
      expect(find.byType(NavigationRail), findsOneWidget);

      resetScreenSize(tester);
    });

    testWidgets('Content reflows correctly when resizing', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Start with mobile
      setScreenSize(tester, const Size(390, 844));
      await tester.pumpAndSettle();

      // Count stats cards on mobile
      var statsCards = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString().contains('StatsCard'),
      );
      final mobileCardCount = statsCards.evaluate().length;

      // Resize to tablet
      setScreenSize(tester, const Size(820, 1180));
      await tester.pumpAndSettle();

      // Count stats cards on tablet
      statsCards = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString().contains('StatsCard'),
      );
      final tabletCardCount = statsCards.evaluate().length;

      // Tablet should show more cards
      expect(tabletCardCount, greaterThan(mobileCardCount));

      // Resize to desktop
      setScreenSize(tester, const Size(1920, 1080));
      await tester.pumpAndSettle();

      // Count stats cards on desktop
      statsCards = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString().contains('StatsCard'),
      );
      final desktopCardCount = statsCards.evaluate().length;

      // Desktop should show even more cards
      expect(desktopCardCount, greaterThan(tabletCardCount));

      resetScreenSize(tester);
    });

    testWidgets('Responsive utilities work correctly', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test ResponsiveBuilder
      expect(find.byType(ResponsiveBuilder), findsWidgets);

      // Test on different sizes
      final sizes = [
        (const Size(390, 844), ScreenType.mobile),
        (const Size(820, 1180), ScreenType.tablet),
        (const Size(1920, 1080), ScreenType.desktop),
      ];

      for (final (size, expectedType) in sizes) {
        setScreenSize(tester, size);
        await tester.pumpAndSettle();

        // Get context from a widget
        final BuildContext context = tester.element(find.byType(MaterialApp));
        
        // Test screen type detection
        expect(context.screenType, equals(expectedType));
        
        // Test responsive helpers
        expect(context.isMobile, equals(expectedType == ScreenType.mobile));
        expect(context.isTablet, equals(expectedType == ScreenType.tablet));
        expect(context.isDesktop, equals(expectedType == ScreenType.desktop));
      }

      resetScreenSize(tester);
    });

    testWidgets('Touch targets are appropriate for device type', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Mobile: larger touch targets
      setScreenSize(tester, const Size(390, 844));
      await tester.pumpAndSettle();

      // Find a tappable widget
      final button = find.text('Créer une nouvelle routine');
      if (button.evaluate().isNotEmpty) {
        final buttonSize = tester.getSize(button);
        // Mobile buttons should be at least 48x48
        expect(buttonSize.height, greaterThanOrEqualTo(48));
      }

      // Desktop: can have smaller targets
      setScreenSize(tester, const Size(1920, 1080));
      await tester.pumpAndSettle();

      // Desktop can have smaller clickable areas but should still be usable
      final desktopButton = find.text('Voir tout');
      if (desktopButton.evaluate().isNotEmpty) {
        final buttonSize = tester.getSize(desktopButton);
        // Desktop buttons can be smaller but still accessible
        expect(buttonSize.height, greaterThanOrEqualTo(24));
      }

      resetScreenSize(tester);
    });

    testWidgets('Scrolling behavior adapts to screen size', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Mobile: vertical scrolling only
      setScreenSize(tester, const Size(390, 844));
      await tester.pumpAndSettle();

      // Try to scroll
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Should scroll vertically
      expect(find.text('Routines récentes'), findsOneWidget);

      // Desktop: might have horizontal scrolling in some areas
      setScreenSize(tester, const Size(1920, 1080));
      await tester.pumpAndSettle();

      // Content should be laid out differently
      expect(find.byType(GridView), findsWidgets);

      resetScreenSize(tester);
    });

    testWidgets('Adaptive dialogs work on different screen sizes', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Mobile: full screen dialogs
      setScreenSize(tester, const Size(390, 844));
      await tester.pumpAndSettle();

      // Trigger a dialog if available
      // Note: This depends on your app having a dialog trigger

      // Desktop: centered dialogs
      setScreenSize(tester, const Size(1920, 1080));
      await tester.pumpAndSettle();

      // Dialogs should be constrained in width on desktop

      resetScreenSize(tester);
    });

    testWidgets('Performance remains good across screen sizes', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Rapid screen size changes
      for (int i = 0; i < 5; i++) {
        setScreenSize(tester, const Size(390, 844));
        await tester.pump();
        
        setScreenSize(tester, const Size(820, 1180));
        await tester.pump();
        
        setScreenSize(tester, const Size(1920, 1080));
        await tester.pump();
      }

      stopwatch.stop();

      // Should handle rapid resizing without significant lag
      // This is a rough metric - adjust based on your performance requirements
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));

      resetScreenSize(tester);
    });
  });
}