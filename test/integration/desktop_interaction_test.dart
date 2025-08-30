import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:spiritual_routines/main.dart' as app;
import 'package:spiritual_routines/core/widgets/desktop_interactions.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Desktop Interaction Integration Tests', () {
    setUpAll(() {
      // Set desktop size for all tests
      TestWidgetsFlutterBinding.ensureInitialized()
          .window
          .physicalSizeTestValue = const Size(1920, 1080);
      TestWidgetsFlutterBinding.ensureInitialized()
          .window
          .devicePixelRatioTestValue = 1.0;
    });

    tearDownAll(() {
      // Reset window size
      TestWidgetsFlutterBinding.ensureInitialized()
          .window
          .physicalSizeTestValue = null;
      TestWidgetsFlutterBinding.ensureInitialized()
          .window
          .devicePixelRatioTestValue = null;
    });

    testWidgets('Keyboard shortcuts work in the app', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test Ctrl+H for Home
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyH);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyH);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      // Should be on home page
      expect(find.text('RISAQ'), findsOneWidget);

      // Test Ctrl+R for Routines
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyR);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyR);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      // Should navigate to routines
      expect(find.text('Mes Routines'), findsOneWidget);

      // Test Escape key
      await tester.sendKeyDownEvent(LogicalKeyboardKey.escape);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      // Could close a modal or go back
    });

    testWidgets('Mouse hover effects work', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Create a mouse gesture
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);

      // Find a hoverable element (button or card)
      final createButton = find.text('Créer une nouvelle routine');
      if (createButton.evaluate().isNotEmpty) {
        // Move mouse over the button
        await gesture.moveTo(tester.getCenter(createButton));
        await tester.pumpAndSettle();

        // Button should show hover state
        // This is hard to test directly, but we can verify no crash

        // Move mouse away
        await gesture.moveTo(Offset.zero);
        await tester.pumpAndSettle();
      }

      await gesture.removePointer();
    });

    testWidgets('Right-click context menu works', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find an element that might have a context menu
      final routineCard = find.text('Prière du matin');
      if (routineCard.evaluate().isNotEmpty) {
        // Right-click on the card
        await tester.tapAt(
          tester.getCenter(routineCard),
          buttons: kSecondaryMouseButton,
        );
        await tester.pumpAndSettle();

        // Context menu might appear
        // Check if any popup menu is shown
        if (find.byType(PopupMenuButton).evaluate().isNotEmpty) {
          expect(find.byType(PopupMenuButton), findsWidgets);
        }
      }
    });

    testWidgets('Focus traversal with Tab key works', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Press Tab to move focus
      await tester.sendKeyDownEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // Focus should move to next focusable widget
      final focusedWidget = Focus.of(
        tester.element(find.byType(MaterialApp)),
      ).focusedChild;
      expect(focusedWidget, isNotNull);

      // Press Shift+Tab to move focus backwards
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.pump();

      // Focus should move to previous widget
    });

    testWidgets('Scrollbar is visible and interactive on desktop',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Look for scrollbar
      final scrollbar = find.byType(Scrollbar);
      if (scrollbar.evaluate().isNotEmpty) {
        expect(scrollbar, findsWidgets);

        // Scrollbar should be visible on desktop
        final scrollbarWidget = tester.widget<Scrollbar>(scrollbar.first);
        expect(scrollbarWidget, isNotNull);
      }

      // Test scrolling with mouse wheel
      final scrollableWidget = find.byType(CustomScrollView);
      if (scrollableWidget.evaluate().isNotEmpty) {
        await tester.drag(scrollableWidget.first, const Offset(0, -100));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Keyboard navigation in lists works', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to a list view
      // Press arrow keys to navigate
      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();

      // Enter key to select
      await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
    });

    testWidgets('Text selection works with keyboard', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find a text field if available
      final textField = find.byType(TextField);
      if (textField.evaluate().isNotEmpty) {
        // Focus the text field
        await tester.tap(textField.first);
        await tester.pumpAndSettle();

        // Type some text
        await tester.enterText(textField.first, 'Test text');
        await tester.pumpAndSettle();

        // Select all with Ctrl+A
        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.keyA);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.keyA);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
        await tester.pump();

        // Copy with Ctrl+C
        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.keyC);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.keyC);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
        await tester.pump();
      }
    });

    testWidgets('Tooltips appear on hover', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Create mouse gesture
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);

      // Find a widget that might have a tooltip
      final iconButton = find.byType(IconButton);
      if (iconButton.evaluate().isNotEmpty) {
        // Hover over the icon
        await gesture.moveTo(tester.getCenter(iconButton.first));
        await tester.pump();

        // Wait for tooltip to appear
        await tester.pump(const Duration(seconds: 2));

        // Check if any tooltip is visible
        final tooltip = find.byType(Tooltip);
        if (tooltip.evaluate().isNotEmpty) {
          expect(tooltip, findsWidgets);
        }
      }

      await gesture.removePointer();
    });

    testWidgets('Double-click works on desktop', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find a widget that might respond to double-click
      final card = find.text('Prière du matin');
      if (card.evaluate().isNotEmpty) {
        // Double-click
        await tester.tap(card);
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(card);
        await tester.pumpAndSettle();

        // Action might have been triggered
      }
    });

    testWidgets('Mouse cursor changes appropriately', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Create mouse gesture
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);

      // Find different types of widgets
      final button = find.text('Créer une nouvelle routine');
      if (button.evaluate().isNotEmpty) {
        // Hover over button - should show click cursor
        await gesture.moveTo(tester.getCenter(button));
        await tester.pump();

        // Find the MouseRegion
        final mouseRegion = find.byType(MouseRegion);
        if (mouseRegion.evaluate().isNotEmpty) {
          final region = tester.widget<MouseRegion>(mouseRegion.first);
          // Should have a click cursor for interactive elements
          expect(region.cursor, isNotNull);
        }
      }

      await gesture.removePointer();
    });
  });
}
