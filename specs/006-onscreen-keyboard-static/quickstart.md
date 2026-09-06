# Quickstart: On-Screen Keyboard (Static)

## Prerequisites

- Flutter SDK matching `environment.sdk: ^3.11.5` in [pubspec.yaml](../../pubspec.yaml)
- Dependencies fetched: `flutter pub get`

## Try it

```dart
GameKeyboard(
  onLetterTap: (letter) => print('letter: $letter'),
  onBackspaceTap: () => print('backspace'),
  onEnterTap: () => print('submit'),
  canSubmit: false,
)
```

Expected outcome: a three-row QWERTY layout with a backspace key and a submit button
below it; tapping any letter prints it, tapping backspace prints "backspace", and the
submit button is visibly disabled and unresponsive until `canSubmit` becomes `true`.

## Validate with tests

```bash
flutter test test/game_keyboard_test.dart
```

This feature's acceptance criteria (FR-001–FR-009, SC-001–SC-004) are validated by
widget tests that pump `GameKeyboard` with fake callbacks and assert:

1. All 26 letters A–Z are present and tappable, each reporting the correct letter via
   `onLetterTap`.
2. A distinct backspace key is present and reports via `onBackspaceTap`.
3. The submit control is disabled when `canSubmit` is `false` and enabled when `true`,
   reporting via `onEnterTap` only when enabled.
4. The keyboard renders without overflow at narrow, medium, and wide container widths.

See [spec.md](spec.md) for the full acceptance scenarios and [data-model.md](data-model.md)
for the widget's properties and rendering rules.
