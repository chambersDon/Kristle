# Quickstart: Word Grid (Static)

## Prerequisites

- Flutter SDK matching `environment.sdk: ^3.11.5` in [pubspec.yaml](../../pubspec.yaml)
- Dependencies fetched: `flutter pub get`

## Try it

```dart
WordGrid(
  answer: 'KRIST',
  guesses: const ['KITES'],
  currentGuess: 'KR',
)
```

Expected outcome: row 0 shows `KITES` scored against `KRIST`; row 1 shows `K`, `R`, and
three empty tiles with no scored color; rows 2–5 are fully empty. The grid always
contains 30 tiles and resizes to fit whatever width/height it's given, without exceeding
its maximum tile size.

## Validate with tests

```bash
flutter test test/word_grid_test.dart
```

This feature's acceptance criteria (FR-001–FR-006, SC-001–SC-004) are validated by
widget tests that pump `WordGrid` with different `guesses`/`currentGuess` combinations
and container sizes, and assert:

1. Exactly 30 `LetterTile`s are always present, regardless of guess count (0, 1, 3, 6).
2. A submitted guess's row shows statuses matching `GameEngine.scoreGuess`'s output.
3. The current-guess row's tiles are never scored (all `LetterStatus.empty`).
4. Rows beyond the current guess are fully empty (no letters, no scored status).
5. Tile size stays within its maximum on a wide/tall container and shrinks to fit a
   narrow or short one.

See [spec.md](spec.md) for the full acceptance scenarios and [data-model.md](data-model.md)
for the per-row rendering rules.
