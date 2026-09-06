# Quickstart: Invalid-Guess Shake Feedback

## Try it

Type fewer than 5 letters (or an unrecognized 5-letter word) and submit — the board
shakes horizontally, then settles back to rest. Submit a valid word — no shake.

## Validate with tests

```bash
flutter test test/widget_test.dart
```

Validates: a rejected submission (either reason) triggers a non-zero horizontal
translation partway through the shake; a successful submission does not.

See [spec.md](spec.md) for full acceptance scenarios.
