# Quickstart: Game Statistics Model

## Try it

```dart
const stats = GameStats();
final afterWin = stats.recordWin(3);
print(afterWin.played);       // 1
print(afterWin.wins);         // 1
print(afterWin.winPercent);   // 100.0
print(afterWin.guessDistribution); // [0, 0, 1, 0, 0, 0]

final restored = GameStats.fromJson({'played': 'oops', 'wins': 1});
print(restored.played); // 0 — falls back safely, does not throw
```

## Validate with tests

```bash
flutter test test/game_stats_test.dart
```

Validates: `recordWin`/`recordLoss` update played/wins/streak/maxStreak/distribution
correctly; `winPercent` is 0 at zero games played and correct otherwise; `toJson`/
`fromJson` round-trip exactly; `fromJson` never throws on missing/wrong-typed/malformed
input and always yields a well-formed 6-entry distribution.

See [spec.md](spec.md) for full acceptance scenarios.
