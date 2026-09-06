# Quickstart: Win Celebration Overlay

## Try it

Win a round — after a brief pause, a "you won" image covers the board for a couple of
seconds, then disappears on its own.

## Validate with tests

```bash
flutter test test/widget_test.dart
```

Validates: no overlay immediately after a win; overlay appears after the show delay;
overlay disappears after the display duration; no overlay ever on a loss; a text
fallback appears if the image fails to load; a new game cancels any pending/showing
overlay.

See [spec.md](spec.md) for full acceptance scenarios.
