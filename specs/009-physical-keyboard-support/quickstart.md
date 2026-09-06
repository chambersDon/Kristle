# Quickstart: Physical Keyboard Support

## Try it

```bash
flutter run -d chrome
```

Type letters, Backspace, and Enter on a physical keyboard — behavior matches tapping the
on-screen keyboard exactly.

## Validate with tests

```bash
flutter test test/widget_test.dart
```

Validates: physical letter/backspace/enter presses match on-screen behavior; a
non-letter, non-backspace, non-enter key has no effect; input is ignored once the round
has ended.

See [spec.md](spec.md) for full acceptance scenarios.
