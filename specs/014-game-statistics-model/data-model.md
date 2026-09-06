# Phase 1 Data Model: Game Statistics Model

## GameStats

| Field | Type | Default | Description |
|---|---|---|---|
| `played` | `int` | `0` | Total rounds completed (win or loss). |
| `wins` | `int` | `0` | Total rounds won. |
| `currentStreak` | `int` | `0` | Consecutive wins ending at the most recent round. |
| `maxStreak` | `int` | `0` | Longest `currentStreak` ever reached. |
| `guessDistribution` | `List<int>` (length 6) | `[0,0,0,0,0,0]` | Count of wins by guess count (index 0 = won in 1 guess, ..., index 5 = won in 6). |

**Derived**: `winPercent` = `played == 0 ? 0 : wins / played * 100` (FR-005).

**Operations**:

- `recordWin(int guessCount)`: `played += 1`, `wins += 1`, `currentStreak += 1`,
  `maxStreak = max(maxStreak, currentStreak)`; if `1 <= guessCount <= 6`, increment
  `guessDistribution[guessCount - 1]` (FR-002).
- `recordLoss()`: `played += 1`, `currentStreak = 0`; `wins`, `maxStreak`,
  `guessDistribution` unchanged (FR-003).
- `copyWith({...})`: returns a new `GameStats` with any given fields replaced (FR-004).
- `toJson()` / `GameStats.fromJson(Map<String, Object?>)`: plain-map (de)serialization;
  `fromJson` defensively defaults every missing/wrong-typed field and always returns a
  well-formed 6-entry `guessDistribution` (FR-006–FR-008).

**State transitions**: None beyond the above — `GameStats` is immutable; every update
produces a new instance.

**Relationships**: Consumed by `GameStorage` (item 15, for persistence) and `GameScreen`
(items 15/7, to record outcomes and display a summary). `GameStats` itself has no
dependency on either.
