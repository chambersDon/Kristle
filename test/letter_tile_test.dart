import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wordle/models/game_state.dart';
import 'package:my_wordle/theme/game_colors.dart';
import 'package:my_wordle/widgets/letter_tile.dart';

void main() {
  Future<void> pumpTile(
    WidgetTester tester, {
    String letter = '',
    LetterStatus status = LetterStatus.empty,
    Duration revealDelay = Duration.zero,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 60,
              height: 60,
              child: LetterTile(
                letter: letter,
                status: status,
                revealDelay: revealDelay,
              ),
            ),
          ),
        ),
      ),
    );
  }

  DecoratedBox findFace(WidgetTester tester) {
    return tester.widget<DecoratedBox>(find.byType(DecoratedBox));
  }

  Color? faceColor(WidgetTester tester) {
    final decoration = findFace(tester).decoration as BoxDecoration;
    return decoration.color;
  }

  Border? faceBorder(WidgetTester tester) {
    final decoration = findFace(tester).decoration as BoxDecoration;
    return decoration.border as Border?;
  }

  Color? letterTextColor(WidgetTester tester) {
    return tester.widget<Text>(find.byType(Text)).style?.color;
  }

  group('scored tiles', () {
    testWidgets('correct status shows the correct color and letter', (
      tester,
    ) async {
      await pumpTile(tester, letter: 'K', status: LetterStatus.correct);

      expect(faceColor(tester), GameColors.correct);
      expect(find.text('K'), findsOneWidget);
    });

    testWidgets('present status shows the present color', (tester) async {
      await pumpTile(tester, letter: 'R', status: LetterStatus.present);

      expect(faceColor(tester), GameColors.present);
    });

    testWidgets('absent status shows the absent color', (tester) async {
      await pumpTile(tester, letter: 'X', status: LetterStatus.absent);

      expect(faceColor(tester), GameColors.absent);
    });

    testWidgets('scored tiles render white letter text for contrast', (
      tester,
    ) async {
      for (final status in [
        LetterStatus.correct,
        LetterStatus.present,
        LetterStatus.absent,
      ]) {
        await pumpTile(tester, letter: 'A', status: status);
        expect(letterTextColor(tester), Colors.white, reason: '$status');
      }
    });
  });

  group('unscored tiles', () {
    testWidgets('empty tile with no letter shows no fill and no letter', (
      tester,
    ) async {
      await pumpTile(tester);

      expect(faceColor(tester), GameColors.tileEmpty);
      expect(find.text(''), findsOneWidget);
      expect(
        (tester.widget<Text>(find.byType(Text)).data ?? ''),
        isEmpty,
      );
    });

    testWidgets('empty tile with a typed letter shows no scored fill color', (
      tester,
    ) async {
      await pumpTile(tester, letter: 'A');

      expect(faceColor(tester), GameColors.tileEmpty);
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets(
      'a typed unscored tile has a more prominent border than an empty one',
      (tester) async {
        await pumpTile(tester);
        final emptyBorderWidth = faceBorder(tester)?.top.width;

        await pumpTile(tester, letter: 'A');
        final typedBorderWidth = faceBorder(tester)?.top.width;

        expect(emptyBorderWidth, isNotNull);
        expect(typedBorderWidth, isNotNull);
        expect(typedBorderWidth, greaterThan(emptyBorderWidth!));
      },
    );
  });

  testWidgets('renders as a perfect square at different available widths', (
    tester,
  ) async {
    for (final width in [40.0, 60.0, 90.0]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: width,
                child: const LetterTile(
                  letter: 'A',
                  status: LetterStatus.correct,
                ),
              ),
            ),
          ),
        ),
      );

      final renderBox = tester.renderObject<RenderBox>(
        find.byType(AspectRatio),
      );
      expect(renderBox.size.width, closeTo(width, 0.01));
      expect(renderBox.size.height, closeTo(width, 0.01));
    }
  });

  group('flip-reveal animation', () {
    testWidgets(
      'stays on the unscored face until revealDelay has elapsed',
      (tester) async {
        await pumpTile(tester);
        await pumpTile(
          tester,
          letter: 'K',
          status: LetterStatus.correct,
          revealDelay: const Duration(milliseconds: 200),
        );

        expect(faceColor(tester), GameColors.tileEmpty);

        await tester.pump(const Duration(milliseconds: 100));
        expect(faceColor(tester), GameColors.tileEmpty);
      },
    );

    testWidgets(
      'flips to the scored face once revealDelay and the animation elapse',
      (tester) async {
        await pumpTile(tester);
        await pumpTile(
          tester,
          letter: 'K',
          status: LetterStatus.correct,
          revealDelay: const Duration(milliseconds: 100),
        );

        await tester.pump(const Duration(milliseconds: 110));
        await tester.pump(const Duration(milliseconds: 460));

        expect(faceColor(tester), GameColors.correct);
      },
    );

    testWidgets(
      'shows a scored status immediately when created that way, with no '
      'animation',
      (tester) async {
        await pumpTile(tester, letter: 'K', status: LetterStatus.correct);

        expect(faceColor(tester), GameColors.correct);
      },
    );

    testWidgets(
      'shows the unscored face immediately when transitioning back to empty',
      (tester) async {
        await pumpTile(tester, letter: 'K', status: LetterStatus.correct);
        await pumpTile(tester);

        expect(faceColor(tester), GameColors.tileEmpty);
      },
    );
  });
}
