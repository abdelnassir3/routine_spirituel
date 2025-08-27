import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/features/content/quran_verse_selector.dart';

void main() {
  testWidgets('QuranVerseSelector affiche les 4 modes de sélection', (WidgetTester tester) async {
    String? versesText;
    String? versesRefs;
    
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: QuranVerseSelector(
              locale: 'fr',
              onVersesSelected: (text, refs) {
                versesText = text;
                versesRefs = refs;
              },
            ),
          ),
        ),
      ),
    );
    
    // Vérifier que les 4 modes sont présents
    expect(find.text('Verset unique'), findsOneWidget);
    expect(find.text('Plage de versets'), findsOneWidget);
    expect(find.text('Versets mixtes'), findsOneWidget);
    expect(find.text('Sourate complète'), findsOneWidget);
    
    // Vérifier que le mode par défaut est 'Verset unique'
    final singleChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Verset unique')
    );
    expect(singleChip.selected, isTrue);
    
    // Tester le changement de mode vers 'Plage de versets'
    await tester.tap(find.text('Plage de versets'));
    await tester.pumpAndSettle();
    
    final rangeChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Plage de versets')
    );
    expect(rangeChip.selected, isTrue);
    
    // Vérifier que le bouton d'ajout est présent
    expect(find.text('Ajouter les versets'), findsOneWidget);
  });
}