# Quickstart: Letter Tile Flip-Reveal Animation

## Try it

Submit a guess in a running game — each tile in that row flips over left to right,
revealing its scored color.

## Validate with tests

```bash
flutter test test/letter_tile_test.dart
```

Validates: a tile stays on its unscored face until its `revealDelay` elapses, then
flips to its scored face; a tile constructed already scored shows no animation; a tile
transitioning to `empty` shows no animation; increasing `revealDelay`s across a row start
progressively later.

See [spec.md](spec.md) for full acceptance scenarios.
