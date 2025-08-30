import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spiritual_routines/core/widgets/responsive_breakpoints.dart';
import 'package:spiritual_routines/design_system/components/adaptive_navigation.dart';

void main() {
  group('ResponsiveBuilder Tests', () {
    testWidgets('Mobile layout renders for width < 640px', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveBuilder(
              builder: (context, constraints, screenType) {
                return Text(screenType.toString());
              },
            ),
          ),
        ),
      );

      // Simulate mobile screen size
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      await tester.pump();

      expect(find.text('ScreenType.mobile'), findsOneWidget);
    });

    testWidgets('Tablet layout renders for width 640-1024px', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveBuilder(
              builder: (context, constraints, screenType) {
                return Text(screenType.toString());
              },
            ),
          ),
        ),
      );

      // Simulate tablet screen size
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      await tester.pump();

      expect(find.text('ScreenType.tablet'), findsOneWidget);
    });

    testWidgets('Desktop layout renders for width > 1024px', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveBuilder(
              builder: (context, constraints, screenType) {
                return Text(screenType.toString());
              },
            ),
          ),
        ),
      );

      // Simulate desktop screen size
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      await tester.pump();

      expect(find.text('ScreenType.desktop'), findsOneWidget);
    });
  });

  group('AdaptiveNavigationScaffold Tests', () {
    final destinations = [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Accueil',
      ),
      const NavigationDestination(
        icon: Icon(Icons.list_outlined),
        selectedIcon: Icon(Icons.list),
        label: 'Routines',
      ),
      const NavigationDestination(
        icon: Icon(Icons.book_outlined),
        selectedIcon: Icon(Icons.book),
        label: 'Lecture',
      ),
    ];

    testWidgets('Mobile shows NavigationBar at bottom', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveNavigationScaffold(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            destinations: destinations,
            body: const Text('Content'),
          ),
        ),
      );

      // Simulate mobile screen
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      await tester.pump();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('Tablet shows NavigationRail on side', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveNavigationScaffold(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            destinations: destinations,
            body: const Text('Content'),
          ),
        ),
      );

      // Simulate tablet screen
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      await tester.pump();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('Desktop shows extended NavigationRail', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveNavigationScaffold(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            destinations: destinations,
            body: const Text('Content'),
          ),
        ),
      );

      // Simulate desktop screen
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      await tester.pump();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      // Verify rail is extended on large desktop
      final NavigationRail rail = tester.widget(find.byType(NavigationRail));
      expect(rail.extended, isTrue);
    });
  });

  group('ResponsiveContext Extension Tests', () {
    testWidgets('Context extensions return correct values', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return Container();
            },
          ),
        ),
      );

      // Test mobile
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      await tester.pump();

      expect(capturedContext.isMobile, isTrue);
      expect(capturedContext.isTablet, isFalse);
      expect(capturedContext.isDesktop, isFalse);

      // Test responsive values
      expect(
        capturedContext.responsive(
          mobile: 'mobile',
          tablet: 'tablet',
          desktop: 'desktop',
        ),
        equals('mobile'),
      );

      // Test responsive padding
      expect(
        capturedContext.responsivePadding,
        equals(const EdgeInsets.all(16.0)),
      );

      // Test responsive columns
      expect(capturedContext.responsiveColumns, equals(2));
    });
  });

  group('ResponsiveVisibility Tests', () {
    testWidgets('Hides content based on screen type', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveVisibility(
              hiddenOnMobile: true,
              child: Text('Desktop Only'),
            ),
          ),
        ),
      );

      // Mobile: should be hidden
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      await tester.pump();

      expect(find.text('Desktop Only'), findsNothing);

      // Desktop: should be visible
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      await tester.pump();

      expect(find.text('Desktop Only'), findsOneWidget);
    });
  });

  group('ResponsiveContainer Tests', () {
    testWidgets('Applies correct max width based on screen', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveContainer(
              child: Text('Content'),
            ),
          ),
        ),
      );

      // Test that widget builds without errors
      expect(find.text('Content'), findsOneWidget);

      // Desktop: should have constrained width
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      await tester.pump();

      final Container container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ResponsiveContainer),
          matching: find.byType(Container),
        ),
      );

      expect(container.constraints?.maxWidth, equals(1200.0));
    });
  });

  // Clean up after tests
  tearDown(() {
    // Reset to default test size
    TestWidgetsFlutterBinding.ensureInitialized().window.physicalSizeTestValue =
        null;
    TestWidgetsFlutterBinding.ensureInitialized()
        .window
        .devicePixelRatioTestValue = null;
  });
}
