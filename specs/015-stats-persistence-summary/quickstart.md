# Quickstart: Stats Persistence & Summary Display

## Try it

Play and finish a few rounds, then relaunch the app — the "Played / Wins / Streak"
summary under the board reflects everything from before.

## Validate with tests

```bash
flutter test test/game_storage_test.dart test/widget_test.dart
```

Validates: `loadStats` returns all-zero defaults when nothing is saved; a saved stats
value round-trips through `saveStats`/`loadStats`; the summary line shows the loaded
played/wins/streak while playing; the summary is replaced by a rejection or
end-of-round message when one is showing.

See [spec.md](spec.md) for full acceptance scenarios.
