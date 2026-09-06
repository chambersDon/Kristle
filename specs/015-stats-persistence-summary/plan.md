# Implementation Plan: Stats Persistence & Summary Display

**Branch**: `015-stats-persistence-summary` | **Date**: 2026-09-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/015-stats-persistence-summary/spec.md`

## Summary

Add `GameStorage.loadStats()`/`saveStats(GameStats)` (`SharedPreferences`-backed,
JSON-encoded under a fixed key, defaulting to `const GameStats()` when nothing is
saved or the saved data is malformed) and wire `GameScreen` to call `loadStats()` in
`_loadSavedData()` at startup and `saveStats(_stats)` after every completed round in
`_submitGuess`'s win/loss branches. Display `_statsSummary` ("Played X | Wins Y | Streak
Z") in the message row whenever `_status == playing` and no rejection `_message` is set.
This plan implements the stats slice of
[lib/services/game_storage.dart](../../lib/services/game_storage.dart) and
[lib/screens/game_screen.dart](../../lib/screens/game_screen.dart) per ROADMAP.md item
15, on top of the `GameStats` model (item 14).

## Technical Context

**Language/Version**: Dart, SDK `^3.11.5`

**Primary Dependencies**: `shared_preferences`; this project's own `GameStats`

**Storage**: `SharedPreferences`, JSON-encoded, under a fixed key
(`kristle.stats.v1`) — local only, per Constitution Principle V

**Testing**: `flutter_test` unit tests for `GameStorage.loadStats`/`saveStats`
(`SharedPreferences.setMockInitialValues`) and widget tests for the summary line's
visibility/content

**Target Platform**: All six configured Flutter targets (Constitution Principle IV)

**Constraints**: Must never crash on load regardless of what's stored (relies on
`GameStats.fromJson`'s defensive parsing, item 14)

**Scale/Scope**: Two `GameStorage` methods and the `_statsSummary` display slice of
`GameScreen`

## Constitution Check

- **I. Layered Architecture** — PASS. `GameStorage` (a service) owns persistence;
  `GameScreen` only calls it and displays the result.
- **II. Test-First Development** — PASS. Failing tests for default-when-nothing-saved,
  save-then-load round-trip, and summary visibility/content are written before
  implementation.
- **III. Immutable State & Defensive Serialization** — PASS. Relies on `GameStats`'s
  immutability and defensive `fromJson` (item 14); `GameStorage` itself does no
  additional parsing.
- **IV/V/VI** — PASS. Local-only storage, no platform branching.

No violations.

## Project Structure

```text
lib/services/game_storage.dart   # loadStats / saveStats
lib/screens/game_screen.dart     # _stats field, _statsSummary display
test/game_storage_test.dart      # unit tests for loadStats/saveStats
test/widget_test.dart            # widget tests for the summary line
```

**Structure Decision**: No new files.

## Complexity Tracking

*No violations — table not applicable.*
