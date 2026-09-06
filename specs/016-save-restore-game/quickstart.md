# Quickstart: Save & Restore In-Progress Game

## Try it

Type a few letters or submit a guess, then relaunch the app — the exact same
in-progress round is waiting.

## Validate with tests

```bash
flutter test test/game_storage_test.dart test/widget_test.dart
```

Validates: `SavedGame.fromJson` never throws on missing/wrong-typed fields;
`saveGame`/`loadGame` round-trip a well-formed game exactly; a structurally valid saved
game is restored on launch; a structurally invalid saved game (wrong-length answer, too
many guesses, over-long current guess) results in a fresh round instead.

See [spec.md](spec.md) for full acceptance scenarios.
