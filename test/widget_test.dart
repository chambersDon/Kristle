import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wordle/main.dart';
import 'package:my_wordle/models/game_state.dart';
import 'package:my_wordle/models/saved_game.dart';
import 'package:my_wordle/models/game_stats.dart';
import 'package:my_wordle/services/game_storage.dart';
import 'package:my_wordle/services/word_list.dart';
import 'package:my_wordle/theme/game_colors.dart';
import 'package:my_wordle/widgets/game_keyboard.dart';
import 'package:my_wordle/widgets/letter_tile.dart';
import 'package:my_wordle/widgets/word_grid.dart';
import 'package:shared_preferences/shared_preferences.dart';

const testWordList = WordList(
  answers: ['KRIST'],
  allowedGuesses: {'ABCDE', 'KITES', 'KRABC', 'KRIST'},
);

const keyColorWordList = WordList(
  answers: ['TRAIN'],
  allowedGuesses: {'RATIO', 'TRICK', 'TRAIN'},
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('fits on a narrow phone-sized screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const KristleApp(wordList: testWordList));

    expect(find.byType(LetterTile), findsNWidgets(30));
  });

  testWidgets('shows typed letters in the current guess row', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KristleApp(wordList: testWordList));

    expect(find.byType(LetterTile), findsNWidgets(30));

    await tapKey(tester, 'K');
    await tapKey(tester, 'R');
    await tapKey(tester, 'I');
    await tester.pump();

    expect(find.text('K'), findsNWidgets(2));
    expect(find.text('R'), findsNWidgets(2));
    expect(find.text('I'), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pump();

    expect(find.text('K'), findsNWidgets(2));
    expect(find.text('R'), findsNWidgets(2));
    expect(find.text('I'), findsOneWidget);

    await tapKey(tester, 'A');
    await tapKey(tester, 'B');
    await tapKey(tester, 'C');
    await tapKey(tester, 'ENTER');
    await tester.pump();

    expect(find.text('K'), findsNWidgets(2));
    expect(find.text('R'), findsNWidgets(2));
    expect(find.text('A'), findsNWidgets(2));
    expect(find.text('B'), findsNWidgets(2));
    expect(find.text('C'), findsNWidgets(2));

    await tapKey(tester, 'D');
    await tester.pump();

    expect(find.text('D'), findsNWidgets(2));
  });

  testWidgets('restores a saved game', (WidgetTester tester) async {
    const storage = GameStorage();
    await storage.saveGame(
      const SavedGame(
        gameNumber: 0,
        answer: 'KRIST',
        guesses: ['ABCDE'],
        currentGuess: 'KR',
        status: GameStatus.playing,
      ),
    );

    await tester.pumpWidget(const KristleApp(wordList: testWordList));
    await tester.pump();

    expect(find.text('A'), findsNWidgets(2));
    expect(find.text('K'), findsNWidgets(2));
    expect(find.text('R'), findsNWidgets(2));
  });

  testWidgets(
    'starts a fresh round instead of restoring a wrong-length answer',
    (WidgetTester tester) async {
      const storage = GameStorage();
      await storage.saveGame(
        const SavedGame(
          gameNumber: 0,
          answer: 'BAD',
          guesses: [],
          currentGuess: '',
          status: GameStatus.playing,
        ),
      );

      await tester.pumpWidget(const KristleApp(wordList: testWordList));
      await tester.pump();

      for (var guessCount = 0; guessCount < WordGrid.rowCount; guessCount++) {
        for (final letter in ['A', 'B', 'C', 'D', 'E']) {
          await tapKey(tester, letter);
        }
        await tapKey(tester, 'ENTER');
        await tester.pump();
      }

      // testWordList's only answer is KRIST — restoring "BAD" would be
      // impossible to reach this message with the expected answer.
      expect(find.text('The answer was KRIST'), findsOneWidget);
    },
  );

  testWidgets(
    'starts a fresh round instead of restoring too many saved guesses',
    (WidgetTester tester) async {
      const storage = GameStorage();
      await storage.saveGame(
        SavedGame(
          gameNumber: 0,
          answer: 'KRIST',
          guesses: List.generate(WordGrid.rowCount + 1, (_) => 'ABCDE'),
          currentGuess: '',
          status: GameStatus.playing,
        ),
      );

      await tester.pumpWidget(const KristleApp(wordList: testWordList));
      await tester.pump();

      expect(find.text('A'), findsOneWidget);
    },
  );

  testWidgets(
    'starts a fresh round instead of restoring an over-long current guess',
    (WidgetTester tester) async {
      const storage = GameStorage();
      await storage.saveGame(
        const SavedGame(
          gameNumber: 0,
          answer: 'KRIST',
          guesses: [],
          currentGuess: 'ABCDEF',
          status: GameStatus.playing,
        ),
      );

      await tester.pumpWidget(const KristleApp(wordList: testWordList));
      await tester.pump();

      expect(find.text('F'), findsOneWidget);
    },
  );

  testWidgets('reveals the answer after five header taps when enabled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KristleApp(wordList: testWordList));

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.byKey(const Key('header-image')));
      await tester.pump();
    }

    expect(find.byKey(const Key('header-image')), findsNothing);
    expect(find.byKey(const Key('revealed-answer')), findsOneWidget);
    expect(find.text('KRIST'), findsOneWidget);
  });

  testWidgets('hides the revealed answer after five answer taps', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KristleApp(wordList: testWordList));

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.byKey(const Key('header-image')));
      await tester.pump();
    }

    expect(find.byKey(const Key('revealed-answer')), findsOneWidget);

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.byKey(const Key('revealed-answer')));
      await tester.pump();
    }

    expect(find.byKey(const Key('header-image')), findsOneWidget);
    expect(find.byKey(const Key('revealed-answer')), findsNothing);

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byKey(const Key('header-image')));
      await tester.pump();
    }

    expect(find.byKey(const Key('header-image')), findsOneWidget);
    expect(find.byKey(const Key('revealed-answer')), findsNothing);

    await tester.tap(find.byKey(const Key('header-image')));
    await tester.pump();

    expect(find.byKey(const Key('header-image')), findsNothing);
    expect(find.byKey(const Key('revealed-answer')), findsOneWidget);
  });

  testWidgets('does not reveal the answer when the helper is disabled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const KristleApp(wordList: testWordList, enableAnswerReveal: false),
    );

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.byKey(const Key('header-image')));
      await tester.pump();
    }

    expect(find.byKey(const Key('header-image')), findsOneWidget);
    expect(find.byKey(const Key('revealed-answer')), findsNothing);
  });

  testWidgets('hides the revealed answer when starting a new game', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KristleApp(wordList: testWordList));

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.byKey(const Key('header-image')));
      await tester.pump();
    }

    expect(find.byKey(const Key('revealed-answer')), findsOneWidget);

    for (final letter in ['K', 'R', 'I', 'S', 'T']) {
      await tapKey(tester, letter);
    }
    await tapKey(tester, 'ENTER');
    await tester.pump();

    await tester.tap(find.text('New Game'));
    await tester.pump();

    expect(find.byKey(const Key('header-image')), findsOneWidget);
    expect(find.byKey(const Key('revealed-answer')), findsNothing);

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byKey(const Key('header-image')));
      await tester.pump();
    }

    expect(find.byKey(const Key('header-image')), findsOneWidget);
    expect(find.byKey(const Key('revealed-answer')), findsNothing);
  });

  testWidgets('shows win image and stops accepting letters after winning', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KristleApp(wordList: testWordList));

    for (final letter in ['K', 'R', 'I', 'S', 'T']) {
      await tapKey(tester, letter);
    }
    await tapKey(tester, 'ENTER');
    await tester.pump();

    expect(find.text('You won!'), findsNothing);
    expect(findWinImage(), findsNothing);
    expect(find.text('New Game'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(findWinImage(), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    expect(findWinImage(), findsNothing);

    await tapKey(tester, 'A');
    await tester.pump();

    expect(find.text('A'), findsOneWidget);

    await tester.tap(find.text('New Game'));
    await tester.pump();

    expect(find.text('You won!'), findsNothing);
    expect(find.text('New Game'), findsNothing);

    await tapKey(tester, 'A');
    await tester.pump();

    expect(find.text('A'), findsNWidgets(2));

    for (var i = 0; i < WordGrid.columnCount; i++) {
      await tester.tap(find.byIcon(Icons.backspace_outlined));
    }
    for (final letter in ['K', 'R', 'I', 'S', 'T']) {
      await tapKey(tester, letter);
    }
    await tapKey(tester, 'ENTER');
    await tester.pump();

    expect(find.text('You won!'), findsNothing);
    expect(findWinImage(), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    expect(findWinImage(), findsOneWidget);
  });

  testWidgets('does not show a New Game control while a round is in progress', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KristleApp(wordList: testWordList));

    expect(find.text('New Game'), findsNothing);

    await tapKey(tester, 'K');
    await tester.pump();

    expect(find.text('New Game'), findsNothing);
  });

  testWidgets(
    'resets keyboard key colors and clears the message on New Game',
    (WidgetTester tester) async {
      await tester.pumpWidget(const KristleApp(wordList: keyColorWordList));

      for (final letter in ['R', 'A', 'T', 'I', 'O']) {
        await tapKey(tester, letter);
      }
      await tapKey(tester, 'ENTER');
      await tester.pump();

      expect(keyBackgroundColor(tester, 'I'), GameColors.correct);

      for (var guessCount = 1; guessCount < WordGrid.rowCount; guessCount++) {
        for (final letter in ['R', 'A', 'T', 'I', 'O']) {
          await tapKey(tester, letter);
        }
        await tapKey(tester, 'ENTER');
        await tester.pump();
      }

      expect(find.text('The answer was TRAIN'), findsOneWidget);

      await tester.tap(find.text('New Game'));
      await tester.pump();

      expect(keyBackgroundColor(tester, 'I'), GameColors.keyboardDefault);
      expect(find.text('The answer was TRAIN'), findsNothing);
    },
  );

  testWidgets('never shows the celebration overlay on a loss', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KristleApp(wordList: testWordList));

    for (var guessCount = 0; guessCount < WordGrid.rowCount; guessCount++) {
      for (final letter in ['A', 'B', 'C', 'D', 'E']) {
        await tapKey(tester, letter);
      }
      await tapKey(tester, 'ENTER');
      await tester.pump();
    }

    await tester.pump(const Duration(seconds: 1));
    expect(findWinImage(), findsNothing);

    await tester.pump(const Duration(seconds: 3));
    expect(findWinImage(), findsNothing);
  });

  testWidgets(
    'cancels a pending celebration overlay when a new game starts',
    (WidgetTester tester) async {
      await tester.pumpWidget(const KristleApp(wordList: testWordList));

      for (final letter in ['K', 'R', 'I', 'S', 'T']) {
        await tapKey(tester, letter);
      }
      await tapKey(tester, 'ENTER');
      await tester.pump();

      expect(findWinImage(), findsNothing);

      await tester.tap(find.text('New Game'));
      await tester.pump();

      await tester.pump(const Duration(seconds: 1));
      expect(findWinImage(), findsNothing);

      await tester.pump(const Duration(seconds: 3));
      expect(findWinImage(), findsNothing);
    },
  );

  testWidgets('shows a played/wins/streak summary while a round is in progress', (
    WidgetTester tester,
  ) async {
    const storage = GameStorage();
    await storage.saveStats(
      const GameStats(played: 4, wins: 3, currentStreak: 2, maxStreak: 3),
    );

    await tester.pumpWidget(const KristleApp(wordList: testWordList));
    await tester.pump();

    expect(find.text('Played 4 | Wins 3 | Streak 2'), findsOneWidget);
  });

  testWidgets('hides the summary in favor of a rejection message', (
    WidgetTester tester,
  ) async {
    const storage = GameStorage();
    await storage.saveStats(
      const GameStats(played: 4, wins: 3, currentStreak: 2, maxStreak: 3),
    );

    await tester.pumpWidget(const KristleApp(wordList: testWordList));
    await tester.pump();

    for (final letter in ['A', 'A', 'A', 'A', 'A']) {
      await tapKey(tester, letter);
    }
    await tapKey(tester, 'ENTER');
    await tester.pump();

    expect(find.text('Played 4 | Wins 3 | Streak 2'), findsNothing);
    expect(find.text('That word is not in the word list'), findsOneWidget);
  });

  testWidgets('persists updated stats after a round completes', (
    WidgetTester tester,
  ) async {
    const storage = GameStorage();

    await tester.pumpWidget(const KristleApp(wordList: testWordList));
    await tester.pump();

    for (final letter in ['K', 'R', 'I', 'S', 'T']) {
      await tapKey(tester, letter);
    }
    await tapKey(tester, 'ENTER');
    await tester.pump();

    final savedStats = await storage.loadStats();
    expect(savedStats.played, 1);
    expect(savedStats.wins, 1);
    expect(savedStats.currentStreak, 1);
  });

  testWidgets('rejects guesses that are not in the word list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KristleApp(wordList: testWordList));

    for (final letter in ['A', 'A', 'A', 'A', 'A']) {
      await tapKey(tester, letter);
    }
    await tapKey(tester, 'ENTER');
    await tester.pump();

    expect(find.text('That word is not in the word list'), findsOneWidget);
    expect(find.text('A'), findsNWidgets(6));

    for (var i = 0; i < WordGrid.columnCount; i++) {
      await tester.tap(find.byIcon(Icons.backspace_outlined));
    }
    for (final letter in ['K', 'R', 'I', 'S', 'T']) {
      await tapKey(tester, letter);
    }
    await tapKey(tester, 'ENTER');
    await tester.pump();

    expect(find.text('That word is not in the word list'), findsNothing);
    expect(findWinImage(), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    expect(findWinImage(), findsOneWidget);
  });

  testWidgets('disables submit until five letters are typed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KristleApp(wordList: testWordList));

    expect(submitButton(tester).onPressed, isNull);

    for (final letter in ['K', 'R', 'I', 'S']) {
      await tapKey(tester, letter);
    }
    await tester.pump();

    expect(submitButton(tester).onPressed, isNull);

    await tapKey(tester, 'T');
    await tester.pump();

    expect(submitButton(tester).onPressed, isNotNull);
  });

  testWidgets('accepts physical keyboard input', (WidgetTester tester) async {
    await tester.pumpWidget(const KristleApp(wordList: testWordList));

    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyI);
    await tester.pump();

    expect(find.text('K'), findsNWidgets(2));
    expect(find.text('R'), findsNWidgets(2));
    expect(find.text('I'), findsNWidgets(2));

    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();

    expect(find.text('I'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyI);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyT);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(findWinImage(), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    expect(findWinImage(), findsOneWidget);
  });

  double shakeTranslationX(WidgetTester tester) {
    final transform = tester.widget<Transform>(
      find
          .ancestor(of: find.byType(WordGrid), matching: find.byType(Transform))
          .first,
    );
    return transform.transform.getTranslation().x;
  }

  testWidgets('shakes the grid for a guess not in the word list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KristleApp(wordList: testWordList));

    for (final letter in ['A', 'A', 'A', 'A', 'A']) {
      await tapKey(tester, letter);
    }
    await tapKey(tester, 'ENTER');
    await tester.pump(const Duration(milliseconds: 80));

    expect(shakeTranslationX(tester), isNonZero);
  });

  testWidgets('shakes the grid for a guess with fewer than 5 letters', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KristleApp(wordList: testWordList));

    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump(const Duration(milliseconds: 80));

    expect(shakeTranslationX(tester), isNonZero);
  });

  testWidgets('does not shake the grid for a valid submission', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KristleApp(wordList: testWordList));
    final restingTranslationX = shakeTranslationX(tester);

    for (final letter in ['K', 'R', 'I', 'S', 'T']) {
      await tapKey(tester, letter);
    }
    await tapKey(tester, 'ENTER');
    await tester.pump(const Duration(milliseconds: 80));

    expect(shakeTranslationX(tester), restingTranslationX);
  });

  testWidgets('shows a message for short physical keyboard submits', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KristleApp(wordList: testWordList));

    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(find.text('Enter a 5-letter word'), findsOneWidget);
  });

  testWidgets('ignores non-letter, non-backspace, non-enter physical keys', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KristleApp(wordList: testWordList));

    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.pump();
    expect(find.text('K'), findsNWidgets(2));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.f1);
    await tester.pump();

    expect(find.text('K'), findsNWidgets(2));
  });

  testWidgets('shows answer after six wrong guesses', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KristleApp(wordList: testWordList));

    for (var guessCount = 0; guessCount < WordGrid.rowCount; guessCount++) {
      for (final letter in ['A', 'B', 'C', 'D', 'E']) {
        await tapKey(tester, letter);
      }
      await tapKey(tester, 'ENTER');
      await tester.pump();
    }

    expect(find.text('The answer was KRIST'), findsOneWidget);

    await tapKey(tester, 'F');
    await tester.pump();

    expect(find.text('F'), findsOneWidget);
  });

  testWidgets('scores submitted guesses with tile statuses', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WordGrid(answer: 'KRIST', guesses: ['KITES']),
        ),
      ),
    );

    final tiles = tester.widgetList<LetterTile>(find.byType(LetterTile));
    final submittedTiles = tiles.take(5).toList();

    expect(submittedTiles[0].status, LetterStatus.correct);
    expect(submittedTiles[1].status, LetterStatus.present);
    expect(submittedTiles[2].status, LetterStatus.present);
    expect(submittedTiles[3].status, LetterStatus.absent);
    expect(submittedTiles[4].status, LetterStatus.present);
  });

  testWidgets('colors keyboard letters by status', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameKeyboard(
            keyStatuses: const {
              'K': LetterStatus.correct,
              'R': LetterStatus.present,
              'A': LetterStatus.absent,
            },
            onLetterTap: (_) {},
            onBackspaceTap: () {},
            onEnterTap: () {},
            canSubmit: true,
          ),
        ),
      ),
    );

    expect(keyBackgroundColor(tester, 'K'), GameColors.correct);
    expect(keyBackgroundColor(tester, 'R'), GameColors.present);
    expect(keyBackgroundColor(tester, 'A'), GameColors.absent);
    expect(keyBackgroundColor(tester, 'B'), GameColors.keyboardDefault);
    expect(find.widgetWithText(FilledButton, 'ENTER'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Submit'), findsOneWidget);
  });

  testWidgets('shows the Kristle header image instead of a plain title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KristleApp(wordList: testWordList));

    final headerImage = tester.widget<Image>(
      find.byKey(const Key('header-image')),
    );

    expect((headerImage.image as AssetImage).assetName, 'assets/kristle_header.png');
  });

  testWidgets('shows an inert placeholder bar reserved for a future ad', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KristleApp(wordList: testWordList));

    final placeholder = find.text('Might Be An Ad One day');
    expect(placeholder, findsOneWidget);
    expect(
      find.ancestor(of: placeholder, matching: find.byType(GestureDetector)),
      findsNothing,
    );
    expect(
      find.ancestor(of: placeholder, matching: find.byType(InkWell)),
      findsNothing,
    );
  });

  testWidgets('uses the requested game palette', (WidgetTester tester) async {
    expect(GameColors.background, const Color(0xFFF5F5F5));
    expect(GameColors.correct, const Color(0xFF29CC29));
    expect(GameColors.tileEmpty, Colors.white);
  });

  testWidgets(
    'clears a rejection message once the player edits the current guess',
    (WidgetTester tester) async {
      await tester.pumpWidget(const KristleApp(wordList: testWordList));

      for (final letter in ['A', 'A', 'A', 'A', 'A']) {
        await tapKey(tester, letter);
      }
      await tapKey(tester, 'ENTER');
      await tester.pump();

      expect(find.text('That word is not in the word list'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();

      expect(find.text('That word is not in the word list'), findsNothing);
    },
  );

  testWidgets(
    'submitting a valid guess after a rejection clears the message and '
    'adds a scored row',
    (WidgetTester tester) async {
      await tester.pumpWidget(const KristleApp(wordList: testWordList));

      for (final letter in ['A', 'A', 'A', 'A', 'A']) {
        await tapKey(tester, letter);
      }
      await tapKey(tester, 'ENTER');
      await tester.pump();

      expect(find.text('That word is not in the word list'), findsOneWidget);

      for (var i = 0; i < WordGrid.columnCount; i++) {
        await tester.tap(find.byIcon(Icons.backspace_outlined));
      }
      for (final letter in ['K', 'I', 'T', 'E', 'S']) {
        await tapKey(tester, letter);
      }
      await tapKey(tester, 'ENTER');
      await tester.pump();

      expect(find.text('That word is not in the word list'), findsNothing);
      expect(find.text('K'), findsNWidgets(2));
      expect(find.text('I'), findsNWidgets(2));
    },
  );

  testWidgets('ends the round in a win as soon as the answer is submitted', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KristleApp(wordList: testWordList));

    for (final letter in ['K', 'R', 'I', 'S', 'T']) {
      await tapKey(tester, letter);
    }
    await tapKey(tester, 'ENTER');
    await tester.pump();

    expect(find.text('New Game'), findsOneWidget);
    expect(submitButton(tester).onPressed, isNull);
  });

  testWidgets(
    'ignores backspace and submit attempts once the round has ended',
    (WidgetTester tester) async {
      await tester.pumpWidget(const KristleApp(wordList: testWordList));

      for (var guessCount = 0; guessCount < WordGrid.rowCount; guessCount++) {
        for (final letter in ['A', 'B', 'C', 'D', 'E']) {
          await tapKey(tester, letter);
        }
        await tapKey(tester, 'ENTER');
        await tester.pump();
      }

      expect(find.text('The answer was KRIST'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();

      expect(find.text('The answer was KRIST'), findsOneWidget);
    },
  );

  testWidgets('starts each round with an answer drawn from the answer list', (
    WidgetTester tester,
  ) async {
    const multiAnswerWordList = WordList(
      answers: ['KRIST', 'KITES', 'KRABS'],
      allowedGuesses: {'ABCDE', 'KRIST', 'KITES', 'KRABS'},
    );

    await tester.pumpWidget(const KristleApp(wordList: multiAnswerWordList));

    for (var guessCount = 0; guessCount < WordGrid.rowCount; guessCount++) {
      for (final letter in ['A', 'B', 'C', 'D', 'E']) {
        await tapKey(tester, letter);
      }
      await tapKey(tester, 'ENTER');
      await tester.pump();
    }

    final revealed = find.byWidgetPredicate((widget) {
      return widget is Text &&
          (widget.data ?? '').startsWith('The answer was ');
    });
    expect(revealed, findsOneWidget);

    final revealedText = tester.widget<Text>(revealed).data!;
    final revealedAnswer = revealedText.replaceFirst('The answer was ', '');
    expect(multiAnswerWordList.answers, contains(revealedAnswer));
  });

  testWidgets(
    'keyboard key colors track the best status seen per letter across guesses',
    (WidgetTester tester) async {
      await tester.pumpWidget(const KristleApp(wordList: keyColorWordList));

      for (final letter in ['R', 'A', 'T', 'I', 'O']) {
        await tapKey(tester, letter);
      }
      await tapKey(tester, 'ENTER');
      await tester.pump();

      expect(keyBackgroundColor(tester, 'I'), GameColors.correct);
      expect(keyBackgroundColor(tester, 'R'), GameColors.present);
      expect(keyBackgroundColor(tester, 'N'), GameColors.keyboardDefault);

      for (final letter in ['T', 'R', 'I', 'C', 'K']) {
        await tapKey(tester, letter);
      }
      await tapKey(tester, 'ENTER');
      await tester.pump();

      // I was already correct; TRICK only scores it present again, so it
      // must not downgrade.
      expect(keyBackgroundColor(tester, 'I'), GameColors.correct);
      // T and R upgrade from present to correct.
      expect(keyBackgroundColor(tester, 'T'), GameColors.correct);
      expect(keyBackgroundColor(tester, 'R'), GameColors.correct);
    },
  );
}

Future<void> tapKey(WidgetTester tester, String label) async {
  final buttonLabel = label == 'ENTER' ? 'Submit' : label;
  await tester.tap(find.widgetWithText(FilledButton, buttonLabel));
  await tester.pump();
}

FilledButton submitButton(WidgetTester tester) {
  return tester.widget<FilledButton>(
    find.widgetWithText(FilledButton, 'Submit'),
  );
}

Finder findWinImage() {
  return find.byWidgetPredicate((widget) {
    final image = widget is Image ? widget.image : null;
    return image is AssetImage && image.assetName == 'assets/you_won.png';
  });
}

Color? keyBackgroundColor(WidgetTester tester, String label) {
  final button = tester.widget<FilledButton>(
    find.widgetWithText(FilledButton, label),
  );

  return button.style?.backgroundColor?.resolve({});
}
