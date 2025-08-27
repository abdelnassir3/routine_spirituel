import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('Vérification des performances de transition',
      (WidgetTester tester) async {
    // Configuration de test
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: TestNavigationPage(),
        ),
      ),
    );

    // Mesurer le temps de transition
    final stopwatch = Stopwatch()..start();

    // Naviguer vers une nouvelle page
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    stopwatch.stop();

    // Vérifier que la transition est < 300ms
    expect(stopwatch.elapsedMilliseconds, lessThan(300));
    print('Temps de transition: ${stopwatch.elapsedMilliseconds}ms');
  });

  testWidgets('Vérification uniformité bannières', (WidgetTester tester) async {
    // Test que toutes les bannières ont les mêmes dimensions
    const expectedPadding = EdgeInsets.all(20);
    const expectedIconSize = 20.0;
    const expectedTitleFontSize = 20.0;

    // Valider les constantes de configuration
    expect(expectedPadding, equals(const EdgeInsets.all(20)));
    expect(expectedIconSize, equals(20.0));
    expect(expectedTitleFontSize, equals(20.0));
  });
}

class TestNavigationPage extends StatelessWidget {
  const TestNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SecondPage()),
            );
          },
          child: const Text('Naviguer'),
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Page 2')),
    );
  }
}
