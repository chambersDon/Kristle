# Quickstart: Guess Scoring Engine

## Prerequisites

- Flutter SDK matching `environment.sdk: ^3.11.5` in [pubspec.yaml](../../pubspec.yaml)
- Dependencies fetched: `flutter pub get`

## Try it

```dart
const engine = GameEngine();
final statuses = engine.scoreGuess(guess: 'ALLEY', answer: 'PLANT');
print(statuses); // [present, correct, absent, absent, absent]
```

Expected outcome: each position in `statuses` reflects whether that guess letter is in
the right spot, present elsewhere, or absent — with duplicate letters never credited more
times than the answer actually contains them.

## Validate with tests

```bash
flutter test test/game_engine_test.dart
```

This feature's acceptance criteria (FR-001–FR-006, SC-001–SC-004) are validated by unit
tests that call `GameEngine().scoreGuess(...)` and assert:

1. An exact-match guess scores every letter correct.
2. A guess sharing no letters with the answer scores every letter absent.
3. A guess with a letter present in the wrong position scores that letter present.
4. A guess with a duplicate letter, where the answer has fewer occurrences, scores no
   more occurrences correct/present than the answer contains.
5. Correct-position matches are resolved before present-elsewhere matches for the same
   letter.
6. Scoring is case-insensitive.
7. A guess/answer length mismatch raises an error instead of returning a result.

See [spec.md](spec.md) for the full acceptance scenarios and [data-model.md](data-model.md)
for the scoring algorithm.
