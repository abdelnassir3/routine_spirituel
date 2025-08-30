import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spiritual_routines/core/widgets/desktop_interactions.dart';

void main() {
  group('DesktopInteractiveWidget Tests', () {
    testWidgets('Shows hover effect on mouse enter', (tester) async {
      bool hovered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DesktopInteractiveWidget(
              onTap: () {},
              child: const Text('Test'),
            ),
          ),
        ),
      );

      // Initially not hovering
      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(DesktopInteractiveWidget),
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect((container.decoration as BoxDecoration).color, Colors.transparent);

      // Simulate mouse enter
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: tester.getCenter(find.text('Test')));
      await tester.pump();

      // Should show hover color
      await tester.pump(const Duration(milliseconds: 200));
      final hoveredContainer = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(DesktopInteractiveWidget),
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect((hoveredContainer.decoration as BoxDecoration).color,
          isNot(Colors.transparent));
    });

    testWidgets('Handles tap callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DesktopInteractiveWidget(
              onTap: () => tapped = true,
              child: const Text('Tap me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap me'));
      expect(tapped, isTrue);
    });

    testWidgets('Handles double tap callback', (tester) async {
      bool doubleTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DesktopInteractiveWidget(
              onDoubleTap: () => doubleTapped = true,
              child: const Text('Double tap me'),
            ),
          ),
        ),
      );

      // Simulate double tap
      await tester.tap(find.text('Double tap me'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Double tap me'));

      expect(doubleTapped, isTrue);
    });

    testWidgets('Shows tooltip when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DesktopInteractiveWidget(
              tooltip: 'This is a tooltip',
              child: Text('Hover me'),
            ),
          ),
        ),
      );

      // Tooltip widget should exist
      expect(find.byType(Tooltip), findsOneWidget);

      // Trigger tooltip
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(
          location: tester.getCenter(find.text('Hover me')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      // Tooltip text should be visible
      expect(find.text('This is a tooltip'), findsOneWidget);
    });

    testWidgets('Shows focus ring when focused', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DesktopInteractiveWidget(
              onTap: () {},
              child: const Text('Focus me'),
            ),
          ),
        ),
      );

      // Focus the widget
      await tester.tap(find.text('Focus me'));
      await tester.pump();

      // Check for focus border
      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(DesktopInteractiveWidget),
          matching: find.byType(AnimatedContainer),
        ),
      );

      // Should have border when focused
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });
  });

  group('KeyboardShortcuts Tests', () {
    testWidgets('Executes callback on shortcut activation', (tester) async {
      bool shortcutTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: KeyboardShortcuts(
            shortcuts: {
              const SingleActivator(LogicalKeyboardKey.keyN, control: true):
                  () {
                shortcutTriggered = true;
              },
            },
            child: const Scaffold(
              body: Text('Press Ctrl+N'),
            ),
          ),
        ),
      );

      // Simulate Ctrl+N
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pump();

      expect(shortcutTriggered, isTrue);
    });

    testWidgets('Multiple shortcuts work', (tester) async {
      String lastAction = '';

      await tester.pumpWidget(
        MaterialApp(
          home: KeyboardShortcuts(
            shortcuts: {
              const SingleActivator(LogicalKeyboardKey.keyN, control: true):
                  () {
                lastAction = 'new';
              },
              const SingleActivator(LogicalKeyboardKey.keyS, control: true):
                  () {
                lastAction = 'save';
              },
              const SingleActivator(LogicalKeyboardKey.escape): () {
                lastAction = 'escape';
              },
            },
            child: const Scaffold(
              body: Text('Test shortcuts'),
            ),
          ),
        ),
      );

      // Test Ctrl+N
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pump();
      expect(lastAction, 'new');

      // Test Ctrl+S
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pump();
      expect(lastAction, 'save');

      // Test Escape
      await tester.sendKeyDownEvent(LogicalKeyboardKey.escape);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(lastAction, 'escape');
    });
  });

  group('DesktopScrollbar Tests', () {
    testWidgets('Shows scrollbar with custom thickness', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DesktopScrollbar(
              thickness: 16.0,
              child: ListView.builder(
                itemCount: 50,
                itemBuilder: (context, index) => ListTile(
                  title: Text('Item $index'),
                ),
              ),
            ),
          ),
        ),
      );

      // Scrollbar should be visible
      expect(find.byType(Scrollbar), findsOneWidget);

      // Get scrollbar theme
      final scrollbar = tester.widget<Scrollbar>(find.byType(Scrollbar));
      expect(scrollbar, isNotNull);
    });
  });

  group('DesktopContextMenu Tests', () {
    testWidgets('Shows context menu on right click', (tester) async {
      bool copyClicked = false;
      bool pasteClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DesktopContextMenu(
              items: [
                ContextMenuItem(
                  label: 'Copy',
                  icon: Icons.copy,
                  shortcut: 'Ctrl+C',
                  onTap: () => copyClicked = true,
                ),
                ContextMenuItem(
                  label: 'Paste',
                  icon: Icons.paste,
                  shortcut: 'Ctrl+V',
                  onTap: () => pasteClicked = true,
                ),
              ],
              child: Container(
                width: 200,
                height: 200,
                color: Colors.blue,
                child: const Center(
                  child: Text('Right click me'),
                ),
              ),
            ),
          ),
        ),
      );

      // Simulate right click
      await tester.tapAt(
        tester.getCenter(find.text('Right click me')),
        buttons: kSecondaryMouseButton,
      );
      await tester.pumpAndSettle();

      // Context menu should be visible
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Paste'), findsOneWidget);
      expect(find.text('Ctrl+C'), findsOneWidget);
      expect(find.text('Ctrl+V'), findsOneWidget);

      // Click on Copy
      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();

      expect(copyClicked, isTrue);
      expect(pasteClicked, isFalse);
    });
  });

  group('SpiritualKeyboardShortcuts', () {
    test('Shortcuts are defined correctly', () {
      // Navigation shortcuts
      expect(
          SpiritualKeyboardShortcuts.home,
          equals(
              const SingleActivator(LogicalKeyboardKey.keyH, control: true)));
      expect(
          SpiritualKeyboardShortcuts.routines,
          equals(
              const SingleActivator(LogicalKeyboardKey.keyR, control: true)));
      expect(
          SpiritualKeyboardShortcuts.reader,
          equals(
              const SingleActivator(LogicalKeyboardKey.keyL, control: true)));
      expect(
          SpiritualKeyboardShortcuts.settings,
          equals(
              const SingleActivator(LogicalKeyboardKey.keyS, control: true)));

      // Action shortcuts
      expect(
          SpiritualKeyboardShortcuts.newRoutine,
          equals(
              const SingleActivator(LogicalKeyboardKey.keyN, control: true)));
      expect(
          SpiritualKeyboardShortcuts.search,
          equals(
              const SingleActivator(LogicalKeyboardKey.keyF, control: true)));
      expect(SpiritualKeyboardShortcuts.escape,
          equals(const SingleActivator(LogicalKeyboardKey.escape)));

      // Counter shortcuts
      expect(SpiritualKeyboardShortcuts.increment,
          equals(const SingleActivator(LogicalKeyboardKey.space)));
      expect(SpiritualKeyboardShortcuts.decrement,
          equals(const SingleActivator(LogicalKeyboardKey.backspace)));
      expect(
          SpiritualKeyboardShortcuts.reset,
          equals(const SingleActivator(LogicalKeyboardKey.keyR,
              control: true, shift: true)));
    });
  });
}
