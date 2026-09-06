import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wordle/models/game_state.dart';
import 'package:my_wordle/services/game_engine.dart';
import 'package:my_wordle/widgets/letter_tile.dart';
import 'package:my_wordle/widgets/word_grid.dart';

void main() {
  const engine = GameEngine();

  Future<void> pumpGrid(
    WidgetTester tester, {
    required String answer,
    List<String> guesses = const [],
    String currentGuess = '',
    double? width,
    double? height,
  }) {
    Widget grid = WordGrid(
      answer: answer,
      guesses: guesses,
      currentGuess: currentGuess,
    );

    if (width != null || height != null) {
      grid = SizedBox(width: width, height: height, child: grid);
    }

    return tester.pumpWidget(
      MaterialApp(home: Scaffold(body: Center(child: grid))),
    );
  }

  List<LetterTile> tiles(WidgetTester tester) {
    return tester.widgetList<LetterTile>(find.byType(LetterTile)).toList();
  }

  group('row content', () {
    for (final guessCount in [0, 1, 3, 6]) {
      testWidgets('always renders 30 tiles ($guessCount guesses)', (
        tester,
      ) async {
        final guesses = List.generate(guessCount, (_) => 'ABCDE');
        await pumpGrid(tester, answer: 'KRIST', guesses: guesses);

        expect(find.byType(LetterTile), findsNWidgets(30));
      });
    }

    testWidgets('scores a submitted guess row against the answer', (
      tester,
    ) async {
      await pumpGrid(tester, answer: 'KRIST', guesses: const ['TRICK']);

      final expected = engine.scoreGuess(guess: 'TRICK', answer: 'KRIST');
      final row = tiles(tester).take(5).toList();

      for (var i = 0; i < 5; i++) {
        expect(row[i].status, expected[i], reason: 'column $i');
        expect(row[i].letter, 'TRICK'[i]);
      }
    });

    testWidgets('shows the current guess unscored in the next row', (
      tester,
    ) async {
      await pumpGrid(
        tester,
        answer: 'KRIST',
        guesses: const ['ABCDE'],
        currentGuess: 'KR',
      );

      final currentRow = tiles(tester).skip(5).take(5).toList();

      expect(currentRow[0].letter, 'K');
      expect(currentRow[1].letter, 'R');
      expect(currentRow[2].letter, '');
      for (final tile in currentRow) {
        expect(tile.status, LetterStatus.empty);
      }
    });

    testWidgets('renders empty rows beyond the current guess', (
      tester,
    ) async {
      await pumpGrid(
        tester,
        answer: 'KRIST',
        guesses: const ['ABCDE'],
        currentGuess: 'KR',
      );

      final emptyRows = tiles(tester).skip(10).toList();

      expect(emptyRows, hasLength(20));
      for (final tile in emptyRows) {
        expect(tile.letter, '');
        expect(tile.status, LetterStatus.empty);
      }
    });

    testWidgets('shows no unscored current row once 6 guesses are submitted', (
      tester,
    ) async {
      final guesses = List.generate(6, (_) => 'ABCDE');
      await pumpGrid(
        tester,
        answer: 'KRIST',
        guesses: guesses,
        currentGuess: 'KR',
      );

      for (final tile in tiles(tester)) {
        expect(tile.status, isNot(LetterStatus.empty));
      }
    });
  });

  group('flip-reveal staggering', () {
    testWidgets('assigns strictly increasing reveal delays across a submitted row', (
      tester,
    ) async {
      await pumpGrid(tester, answer: 'KRIST', guesses: const ['TRICK']);

      final row = tiles(tester).take(5).toList();
      for (var i = 1; i < row.length; i++) {
        expect(
          row[i].revealDelay,
          greaterThan(row[i - 1].revealDelay),
          reason: 'column $i',
        );
      }
    });

    testWidgets('does not stagger the unscored current-guess row', (
      tester,
    ) async {
      await pumpGrid(tester, answer: 'KRIST', currentGuess: 'KRIST');

      final row = tiles(tester).take(5).toList();
      for (final tile in row) {
        expect(tile.revealDelay, Duration.zero);
      }
    });
  });

  group('responsive sizing', () {
    double tileDimension(WidgetTester tester) {
      final box = tester.renderObject<RenderBox>(
        find.byType(LetterTile).first,
      );
      return box.size.width;
    }

    testWidgets('caps tile size on a wide, tall container', (tester) async {
      await pumpGrid(
        tester,
        answer: 'KRIST',
        width: 2000,
        height: 2000,
      );

      expect(tileDimension(tester), lessThanOrEqualTo(70));
    });

    testWidgets('shrinks tile size to fit a narrow width', (tester) async {
      await pumpGrid(tester, answer: 'KRIST', width: 150, height: 800);

      final size = tileDimension(tester);
      expect(size, lessThan(70));
      // 5 columns + 4 gaps must fit within the given width.
      expect(size * WordGrid.columnCount, lessThanOrEqualTo(150));
    });

    testWidgets('shrinks tile size to fit a short height', (tester) async {
      await pumpGrid(tester, answer: 'KRIST', width: 800, height: 120);

      final size = tileDimension(tester);
      expect(size, lessThan(70));
      expect(size * WordGrid.rowCount, lessThanOrEqualTo(120));
    });
  });
}
