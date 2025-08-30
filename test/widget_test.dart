// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('Basic widget test - MaterialApp creation',
      (WidgetTester tester) async {
    // Simple test to verify MaterialApp can be created
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Test App'),
            ),
          ),
        ),
      ),
    );

    // Verify the app loads
    expect(find.text('Test App'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('Provider scope functionality test', (WidgetTester tester) async {
    // Test that ProviderScope works correctly
    final testProvider = StateProvider<int>((ref) => 0);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, child) {
              final count = ref.watch(testProvider);
              return Text('Count: $count');
            },
          ),
        ),
      ),
    );

    expect(find.text('Count: 0'), findsOneWidget);
  });
}
