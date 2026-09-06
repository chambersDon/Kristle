# Quickstart: Core Play Loop

## Prerequisites

- Flutter SDK matching `environment.sdk: ^3.11.5` in [pubspec.yaml](../../pubspec.yaml)
- Dependencies fetched: `flutter pub get`

## Run it

```bash
flutter run
```

Expected outcome: the app starts a round with a randomly chosen answer; tapping letters
builds the current row, backspace removes the last letter, and the submit button (via
`GameKeyboard`) only accepts a complete, recognized 5-letter word — otherwise an inline
message explains why. Matching the answer ends the round in a win; six non-matching
guesses end it in a loss; either way, further input has no effect.

## Validate with tests

```bash
flutter test test/widget_test.dart
```

This feature's acceptance criteria (FR-001–FR-010, SC-001–SC-005) are validated by
widget tests that pump `GameScreen` with a small test `WordList` and, via the on-screen
keyboard, assert:

1. Typed letters appear in the current row in order, capped at 5; a 6th tap is a no-op.
2. Backspace removes the last letter; backspacing an empty guess is a no-op.
3. Submitting fewer than 5 letters shows a length-rejection message and adds no row.
4. Submitting a 5-letter word not in the allowed-guess list shows a not-recognized
   message and adds no row.
5. Editing the current guess after a rejection clears the message.
6. Submitting the answer ends the round in a win; six non-matching submissions end it in
   a loss.
7. Once the round ends, further typing/backspace/submit attempts have no effect.
8. The answer used in a new round is a member of the loaded answer list.

See [spec.md](spec.md) for the full acceptance scenarios and [data-model.md](data-model.md)
for the state transitions.
