import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wordle/main.dart';
import 'package:my_wordle/services/word_list.dart';

const _testWordList = WordList(
  answers: ['KRIST'],
  allowedGuesses: {'KRIST'},
);

void main() {
  testWidgets('boots into a single Material 3 app shell titled Kristle', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KristleApp(wordList: _testWordList));

    expect(find.byType(MaterialApp), findsOneWidget);

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, 'Kristle');

    final theme = materialApp.theme;
    expect(theme, isNotNull);
    expect(theme!.useMaterial3, isTrue);

    final expectedScheme = ColorScheme.fromSeed(seedColor: Colors.green);
    expect(theme.colorScheme.primary, expectedScheme.primary);
  });
}
