# Quickstart: Keyboard Key-Status Coloring

## Try it

Submit a few guesses in a running game and watch the on-screen keyboard's letter keys
change color to green/yellow/gray as letters are confirmed correct, present, or ruled
out.

## Validate with tests

```bash
flutter test test/widget_test.dart
```

Validates: a correct letter's key turns green; an unseen letter stays default; a letter
that was absent then later present upgrades to yellow; a letter that was present then
later correct upgrades to green (never downgrades).

See [spec.md](spec.md) for full acceptance scenarios.
