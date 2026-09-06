import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wordle/theme/game_colors.dart';
import 'package:my_wordle/widgets/game_keyboard.dart';

void main() {
  Future<void> pumpKeyboard(
    WidgetTester tester, {
    ValueChanged<String>? onLetterTap,
    VoidCallback? onBackspaceTap,
    VoidCallback? onEnterTap,
    bool canSubmit = false,
    double width = 400,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: width,
            child: GameKeyboard(
              onLetterTap: onLetterTap ?? (_) {},
              onBackspaceTap: onBackspaceTap ?? () {},
              onEnterTap: onEnterTap ?? () {},
              canSubmit: canSubmit,
            ),
          ),
        ),
      ),
    );
  }

  const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  testWidgets('renders all 26 letters exactly once', (tester) async {
    await pumpKeyboard(tester);

    for (final letter in alphabet.split('')) {
      expect(find.widgetWithText(FilledButton, letter), findsOneWidget);
    }
  });

  testWidgets('tapping a letter key reports that letter', (tester) async {
    final tapped = <String>[];
    await pumpKeyboard(tester, onLetterTap: tapped.add);

    await tester.tap(find.widgetWithText(FilledButton, 'K'));
    await tester.tap(find.widgetWithText(FilledButton, 'Q'));

    expect(tapped, ['K', 'Q']);
  });

  testWidgets('backspace key is distinct and reports a backspace action', (
    tester,
  ) async {
    var backspaceCount = 0;
    final lettersTapped = <String>[];
    await pumpKeyboard(
      tester,
      onLetterTap: lettersTapped.add,
      onBackspaceTap: () => backspaceCount++,
    );

    expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.backspace_outlined));

    expect(backspaceCount, 1);
    expect(lettersTapped, isEmpty);
  });

  testWidgets('every letter key uses the same single default color', (
    tester,
  ) async {
    await pumpKeyboard(tester);

    for (final letter in ['A', 'M', 'Z']) {
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, letter),
      );
      expect(
        button.style?.backgroundColor?.resolve({}),
        GameColors.keyboardDefault,
        reason: letter,
      );
    }
  });

  group('submit control', () {
    testWidgets('is disabled and unresponsive when canSubmit is false', (
      tester,
    ) async {
      var submitted = false;
      await pumpKeyboard(
        tester,
        canSubmit: false,
        onEnterTap: () => submitted = true,
      );

      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Submit'),
      );
      expect(button.onPressed, isNull);

      await tester.tap(find.widgetWithText(FilledButton, 'Submit'), warnIfMissed: false);
      expect(submitted, isFalse);
    });

    testWidgets('is enabled when canSubmit is true', (tester) async {
      await pumpKeyboard(tester, canSubmit: true);

      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Submit'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('tapping it while enabled reports a submit action', (
      tester,
    ) async {
      var submitted = false;
      await pumpKeyboard(
        tester,
        canSubmit: true,
        onEnterTap: () => submitted = true,
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Submit'));

      expect(submitted, isTrue);
    });
  });

  group('responsive layout', () {
    for (final width in [300.0, 400.0, 600.0]) {
      testWidgets('renders without overflow at width $width', (tester) async {
        await pumpKeyboard(tester, width: width);

        expect(tester.takeException(), isNull);
      });
    }
  });
}
