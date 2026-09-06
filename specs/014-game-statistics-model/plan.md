# Implementation Plan: Game Statistics Model

**Branch**: `014-game-statistics-model` | **Date**: 2026-09-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/014-game-statistics-model/spec.md`

## Summary

Implement an immutable `GameStats` class (`played`, `wins`, `currentStreak`,
`maxStreak`, `guessDistribution` — a fixed 6-entry `List<int>`) with `recordWin(int
guessCount)`, `recordLoss()`, and `copyWith(...)`, each returning a new instance;
a `winPercent` getter (`0` when `played == 0`); `toJson()`/`GameStats.fromJson(...)`
where `fromJson` reads each field defensively (`_readInt`/`_readDistribution` helpers
that fall back to safe defaults for missing/wrong-typed/malformed data, and always
produce exactly 6 numeric distribution entries). This plan implements
[lib/models/game_stats.dart](../../lib/models/game_stats.dart) per ROADMAP.md item 14.

## Technical Context

**Language/Version**: Dart, SDK `^3.11.5`

**Primary Dependencies**: None beyond the Dart SDK — a pure data model, no Flutter
widget dependency

**Storage**: N/A for this feature — this model defines serialization shape only; actual
persistence is a later roadmap feature

**Testing**: `flutter_test` unit tests constructing `GameStats` directly and calling
`recordWin`/`recordLoss`/`toJson`/`fromJson`

**Target Platform**: All six configured Flutter targets (Constitution Principle IV) —
pure Dart logic runs identically everywhere

**Project Type**: Mobile/desktop/web app (single Flutter package)

**Constraints**: Must be immutable (Constitution Principle III) and must never throw
from `fromJson` regardless of input shape

**Scale/Scope**: One model class (`GameStats`); no widgets, screens, or storage I/O in
scope

## Constitution Check

- **I. Layered Architecture** — PASS. `GameStats` lives in `lib/models/` with no
  Flutter widget dependency.
- **II. Test-First Development** — PASS. Failing unit tests for `recordWin`/
  `recordLoss`/`winPercent`/round-trip serialization/defensive parsing are written
  before implementation.
- **III. Immutable State & Defensive Serialization** — PASS. `GameStats` fields are
  `final`; updates go through `copyWith`; `fromJson` never throws on missing/malformed
  data (this feature's core requirement).
- **IV/V/VI** — PASS.

No violations.

## Project Structure

```text
lib/models/game_stats.dart   # GameStats — this feature's subject
test/game_stats_test.dart    # unit tests for GameStats
```

**Structure Decision**: Single Flutter package at the repository root (`lib/`, `test/`).
No new directories; `GameStats` lives in `lib/models/`, alongside the project's other
plain data models.

## Complexity Tracking

*No violations — table not applicable.*
