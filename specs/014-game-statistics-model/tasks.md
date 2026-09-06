---

description: "Task list template for feature implementation"
---

# Tasks: Game Statistics Model

**Input**: Design documents from `/specs/014-game-statistics-model/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [quickstart.md](quickstart.md)

**Tests**: Required by Constitution Principle II. Write the failing unit test(s) first,
confirm they fail, then implement `GameStats` in `lib/models/game_stats.dart` to make
them pass.

## Phase 1: Setup

- [X] T001 Verify `flutter pub get`/`flutter analyze` are clean on the working tree.

## Phase 2: User Story 1 - A completed round updates lifetime statistics (P1) 🎯 MVP

### Tests ⚠️

- [X] T002 [P] [US1] In `test/game_stats_test.dart`, add a test that `recordWin`
      increases `played`/`wins`/`currentStreak` by one (FR-002, acceptance scenario 1).
- [X] T003 [P] [US1] In `test/game_stats_test.dart`, add a test that `recordLoss`
      increases `played`, resets `currentStreak` to 0, and leaves `wins` unchanged
      (FR-003, acceptance scenario 2).
- [X] T004 [P] [US1] In `test/game_stats_test.dart`, add a test that `recordWin(n)`
      increments `guessDistribution[n - 1]` (FR-002, acceptance scenario 3).
- [X] T005 [P] [US1] In `test/game_stats_test.dart`, add a test that `maxStreak` updates
      when a win extends `currentStreak` past the previous max, and stays unchanged
      when it doesn't (FR-002, acceptance scenarios 4 and 5).
- [X] T006 [P] [US1] In `test/game_stats_test.dart`, add a test that `recordWin` with an
      out-of-range guess count (0 or 7) leaves `guessDistribution` unchanged while still
      updating `played`/`wins`/`currentStreak` (edge case: out-of-range guess count).
- [X] T007 [US1] Run `flutter test test/game_stats_test.dart` and confirm T002–T006 fail
      for the expected reason before implementing.

### Implementation

- [X] T008 [US1] Implement `GameStats`'s fields, `recordWin`, `recordLoss`, and
      `copyWith` in [lib/models/game_stats.dart](../../lib/models/game_stats.dart)
      (FR-001–FR-004). Run `flutter test test/game_stats_test.dart` and confirm
      T002–T006 now pass.

## Phase 3: User Story 2 - Win percentage is always derivable from the stats (P2)

### Tests ⚠️

- [X] T009 [P] [US2] In `test/game_stats_test.dart`, add a test that `winPercent` is 0
      when `played` is 0 (FR-005, acceptance scenario 1).
- [X] T010 [P] [US2] In `test/game_stats_test.dart`, add a test that `winPercent` equals
      `wins / played * 100` for a known played/wins pair (FR-005, acceptance scenario
      2).
- [X] T011 [US2] Run `flutter test test/game_stats_test.dart` and confirm T009–T010 fail
      for the expected reason before implementing.

### Implementation

- [X] T012 [US2] Implement the `winPercent` getter in
      [lib/models/game_stats.dart](../../lib/models/game_stats.dart) (FR-005). Run
      `flutter test test/game_stats_test.dart` and confirm T009–T010 now pass.

## Phase 4: User Story 3 - Statistics survive being saved and loaded as data (P1)

### Tests ⚠️

- [X] T013 [P] [US3] In `test/game_stats_test.dart`, add a test that a fully-populated
      `GameStats` round-trips exactly through `toJson`/`fromJson` (FR-006, SC-003,
      acceptance scenario 1).
- [X] T014 [P] [US3] In `test/game_stats_test.dart`, add a test that `fromJson` with
      missing fields falls back to safe defaults for each (FR-007, acceptance scenario
      2).
- [X] T015 [P] [US3] In `test/game_stats_test.dart`, add a test that `fromJson` with
      wrong-typed fields (e.g. a string where an int is expected, a number where the
      distribution list is expected) falls back to safe defaults rather than throwing
      (FR-007, acceptance scenario 3).
- [X] T016 [P] [US3] In `test/game_stats_test.dart`, add a test that `fromJson` with a
      malformed distribution (wrong length, non-numeric entries) always produces a
      well-formed 6-entry numeric distribution (FR-008, acceptance scenario 4).
- [X] T017 [P] [US3] In `test/game_stats_test.dart`, add a test that `fromJson({})`
      produces a value identical to `const GameStats()` (edge case: empty input).
- [X] T018 [US3] Run `flutter test test/game_stats_test.dart` and confirm T013–T017 fail
      for the expected reason before implementing.

### Implementation

- [X] T019 [US3] Implement `toJson`/`fromJson`/`_readInt`/`_readDistribution` in
      [lib/models/game_stats.dart](../../lib/models/game_stats.dart) (FR-006–FR-008).
      Run `flutter test test/game_stats_test.dart` and confirm T013–T017 now pass.

## Phase 5: Polish

- [X] T020 Run `flutter analyze` and the full `flutter test` suite and confirm both are
      clean/passing.

## Notes

- No `lib/` changes are expected beyond what T008/T012/T019 verify against;
  `test/game_stats_test.dart` stays untracked per ROADMAP.md's Implementation rules.
