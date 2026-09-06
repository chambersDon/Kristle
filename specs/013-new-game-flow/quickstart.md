# Quickstart: New Game Flow

## Try it

Finish a round (win or lose), then tap "New Game" — the board clears, the keyboard
returns to its default colors, any message disappears, and a fresh round begins.

## Validate with tests

```bash
flutter test test/widget_test.dart
```

Validates: "New Game" is hidden while playing and shown once ended; tapping it clears
guesses/current guess, resets keyboard colors, clears messages, and resets reveal state.

See [spec.md](spec.md) for full acceptance scenarios.
