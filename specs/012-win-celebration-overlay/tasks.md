---

description: "Task list template for feature implementation"
---

# Tasks: Win Celebration Overlay

**Input**: Design documents from `/specs/012-win-celebration-overlay/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [quickstart.md](quickstart.md)

**Tests**: Required by Constitution Principle II. Write the failing widget test(s)
first, confirm they fail, then implement the overlay timing in
`lib/screens/game_screen.dart` to make them pass.

## Phase 1: Setup

- [X] T001 Verify `flutter pub get`/`flutter analyze` are clean on the working tree.

## Phase 2: User Story 1 - A win is celebrated with a brief overlay (P1) 🎯 MVP

### Tests ⚠️

- [X] T002 [P] [US1] In `test/widget_test.dart`, add a test that immediately after a
      win, the celebration overlay is not shown (FR-001, acceptance scenario 1).
- [X] T003 [P] [US1] In `test/widget_test.dart`, add a test that after the show delay
      elapses, the celebration overlay appears (FR-001, FR-002, acceptance scenario 2).
- [X] T004 [P] [US1] In `test/widget_test.dart`, add a test that after the display
      duration elapses, the overlay disappears on its own (FR-003, acceptance scenario
      3).
- [X] T005 [P] [US1] In `test/widget_test.dart`, add a test that a loss never shows the
      celebration overlay, even after waiting past the show delay (FR-004, SC-002,
      acceptance scenario 4).
- [X] T006 [US1] Run `flutter test test/widget_test.dart` and confirm T002–T005 fail for
      the expected reason before implementing.

### Implementation

- [X] T007 [US1] Implement `_scheduleWinImage`/`_showWinImage`/the conditional overlay
      widget in [lib/screens/game_screen.dart](../../lib/screens/game_screen.dart),
      called from the win branch of `_submitGuess` (FR-001–FR-004). Run
      `flutter test test/widget_test.dart` and confirm T002–T005 now pass.

## Phase 3: User Story 2 - The celebration still works if its image can't load (P2)

### Tests ⚠️

- [X] T008 [US2] In `test/widget_test.dart`, add a test that cancelling any
      pending/showing celebration via starting a new game leaves no overlay visible in
      the new round (FR-006, edge case).
- [X] T009 [US2] Run `flutter test test/widget_test.dart` and confirm T008 fails for the
      expected reason before implementing.

### Implementation

- [X] T010 [US2] Implement `_cancelWinImageTimers()` and call it from `_startNewGame()`
      and at the start of `_scheduleWinImage()` (FR-006). Confirm the existing
      `errorBuilder` fallback (FR-005) renders a text acknowledgment if the image fails
      to load. Run `flutter test test/widget_test.dart` and confirm T008 now passes.

## Phase 4: Polish

- [X] T011 Run `flutter analyze` and the full `flutter test` suite and confirm both are
      clean/passing.

## Notes

- FR-005 (image-load-failure text fallback) is difficult to trigger deterministically in
  a widget test (the test asset bundle successfully resolves the real asset); this task
  list therefore verifies the `errorBuilder` wiring by inspection (T010) rather than by a
  simulated failure, consistent with this project's existing win-image test coverage.
- No `lib/` changes are expected beyond what T007/T010 verify against;
  `test/widget_test.dart` stays untracked per ROADMAP.md's Implementation rules.

## Phase 5: Convergence

- [ ] T012 Add automated coverage for the image-load-failure text fallback (FR-005,
      US2/AC1) — e.g. inject a `Widget Function(BuildContext, Object, StackTrace?)`
      override point or a test-only asset bundle that fails to resolve
      `assets/you_won.png`, then assert the "You Won!" fallback text renders in its
      place, rather than relying on inspection alone (partial).
