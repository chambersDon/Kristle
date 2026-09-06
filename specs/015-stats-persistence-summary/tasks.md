---

description: "Task list template for feature implementation"
---

# Tasks: Stats Persistence & Summary Display

**Input**: Design documents from `/specs/015-stats-persistence-summary/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [quickstart.md](quickstart.md)

**Tests**: Required by Constitution Principle II. Write the failing test(s) first,
confirm they fail, then implement `loadStats`/`saveStats` in
`lib/services/game_storage.dart` and the summary display in
`lib/screens/game_screen.dart` to make them pass.

## Phase 1: Setup

- [X] T001 Verify `flutter pub get`/`flutter analyze` are clean on the working tree.

## Phase 2: User Story 1 - Lifetime stats persist across app launches (P1) 🎯 MVP

### Tests ⚠️

- [X] T002 [P] [US1] In `test/game_storage_test.dart`, add a test that `loadStats`
      returns brand-new (all-zero) stats when nothing has been saved yet (FR-001,
      acceptance scenario 1).
- [X] T003 [P] [US1] In `test/game_storage_test.dart`, add a test that `loadStats`
      returns previously `saveStats`-persisted values (FR-001, acceptance scenario 2)
      — extend the existing round-trip test if one already covers well-formed data.
- [X] T004 [P] [US1] In `test/widget_test.dart`, add a test that completing a round
      (win or loss) results in updated stats being persisted (FR-002, SC-002,
      acceptance scenario 3) — verified by relaunching `GameScreen` against the same
      mocked `SharedPreferences` and confirming the summary reflects the update.
- [X] T005 [US1] Run `flutter test test/game_storage_test.dart test/widget_test.dart`
      and confirm T002–T004 fail for the expected reason before implementing.

### Implementation

- [X] T006 [US1] Implement `loadStats`/`saveStats` in
      [lib/services/game_storage.dart](../../lib/services/game_storage.dart)
      (FR-001, FR-002) and wire `_loadSavedData`/the win-loss branches of
      `_submitGuess` in
      [lib/screens/game_screen.dart](../../lib/screens/game_screen.dart) to call them.
      Run `flutter test test/game_storage_test.dart test/widget_test.dart` and confirm
      T002–T004 now pass.

## Phase 3: User Story 2 - A quick stats summary is visible while playing (P2)

### Tests ⚠️

- [X] T007 [P] [US2] In `test/widget_test.dart`, add a test that with known pre-saved
      stats, the summary line shows the matching played/wins/streak numbers while a
      round is in progress (FR-003, SC-003, acceptance scenario 1).
- [X] T008 [P] [US2] In `test/widget_test.dart`, add a test that the summary is not
      shown when a rejection message is showing instead (FR-004, acceptance scenario
      2).
- [X] T009 [US2] Run `flutter test test/widget_test.dart` and confirm T007–T008 fail for
      the expected reason before implementing.

### Implementation

- [X] T010 [US2] Implement `_statsSummary` and its display slot in
      [lib/screens/game_screen.dart](../../lib/screens/game_screen.dart) (FR-003,
      FR-004). Run `flutter test test/widget_test.dart` and confirm T007–T008 now pass.

## Phase 4: Polish

- [X] T011 Run `flutter analyze` and the full `flutter test` suite and confirm both are
      clean/passing.

## Notes

- No `lib/` changes are expected beyond what T006/T010 verify against; test files stay
  untracked per ROADMAP.md's Implementation rules.
