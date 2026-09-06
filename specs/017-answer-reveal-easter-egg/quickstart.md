# Quickstart: Answer-Reveal Easter Egg

## Try it

```bash
flutter run                                                   # enabled by default
flutter run --dart-define=KRISTLE_ENABLE_ANSWER_REVEAL=false  # disabled
```

Tap the header five times to reveal the answer; tap the revealed answer five times to
hide it again; start a new game to force-hide it and reset tap progress.

## Validate with tests

```bash
flutter test test/widget_test.dart
```

Validates: fewer than five header taps don't reveal; the fifth tap reveals; fewer than
five taps on the revealed answer don't hide; the fifth hides; "New Game" force-hides and
resets tap progress; disabling the flag prevents any reveal.

See [spec.md](spec.md) for full acceptance scenarios.
