# Quickstart: Letter Tile (Static)

## Prerequisites

- Flutter SDK matching `environment.sdk: ^3.11.5` in [pubspec.yaml](../../pubspec.yaml)
- Dependencies fetched: `flutter pub get`

## Try it

```dart
LetterTile(letter: 'K', status: LetterStatus.correct)
LetterTile(letter: 'R', status: LetterStatus.present)
LetterTile(letter: 'X', status: LetterStatus.absent)
LetterTile() // empty, unscored
LetterTile(letter: 'A') // typed, unscored
```

Expected outcome: the first three render as solid green/yellow/gray squares with a white
letter; the last two render as outlined boxes with no fill, the typed one showing a more
prominent border than the empty one.

## Validate with tests

```bash
flutter test test/letter_tile_test.dart
```

This feature's acceptance criteria (FR-001–FR-006, SC-001–SC-004) are validated by
widget tests that pump a single `LetterTile` and assert:

1. `correct`/`present`/`absent` statuses each render their own distinct background
   color.
2. Scored tiles render white letter text; unscored tiles render theme-derived text.
3. An `empty`-status tile with no letter shows no fill and no visible letter.
4. An `empty`-status tile with a letter shows that letter with an outlined, unfilled
   style, distinguishable from a fully empty tile.
5. The tile is a perfect square across at least three different size constraints.

See [spec.md](spec.md) for the full acceptance scenarios and [data-model.md](data-model.md)
for the rendering rules.
