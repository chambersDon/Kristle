---

description: "Task list template for feature implementation"
---

# Tasks: New Game Flow

**Input**: Design documents from `/specs/013-new-game-flow/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [quickstart.md](quickstart.md)

**Tests**: Required by Constitution Principle II. Write the failing widget test(s)
first, confirm they fail, then implement `_startNewGame` and its trigger in
`lib/screens/game_screen.dart` to make them pass.

## Phase 1: Setup

- [X] T001 Verify `flutter pub get`/`flutter analyze` are clean on the working tree.

## Phase 2: User Story 1 - A player starts a fresh round after one ends (P1) 🎯 MVP

### Tests ⚠️

- [X] T002 [P] [US1] In `test/widget_test.dart`, add a test that the "New Game" control
      is absent while a round is in progress (FR-001, acceptance scenario 1).
- [X] T003 [P] [US1] In `test/widget_test.dart`, add a test that "New Game" appears once
      a round has ended (win and loss) (FR-001, acceptance scenario 2).
- [X] T004 [P] [US1] In `test/widget_test.dart`, add a test that tapping "New Game"
      clears all guesses and the current guess (FR-002, FR-003, acceptance scenario 3).
- [X] T005 [P] [US1] In `test/widget_test.dart`, add a test that tapping "New Game"
      resets every keyboard key to its default color after a round with colored keys
      (FR-005, acceptance scenario 4).
- [X] T006 [P] [US1] In `test/widget_test.dart`, add a test that tapping "New Game"
      clears a leftover rejection/end-of-round message (FR-006, acceptance scenario 5).
- [X] T007 [P] [US1] In `test/widget_test.dart`, add a test that tapping "New Game"
      hides a revealed answer and resets its tap-count progress (FR-007, acceptance
      scenario 6).
- [X] T008 [US1] Run `flutter test test/widget_test.dart` and confirm T002–T007 fail for
      the expected reason before implementing.

### Implementation

- [X] T009 [US1] Implement `_startNewGame` and the "New Game" control's visibility in
      [lib/screens/game_screen.dart](../../lib/screens/game_screen.dart)
      (FR-001–FR-007). Run `flutter test test/widget_test.dart` and confirm T002–T007
      now pass.

## Phase 3: Polish

- [X] T010 Run `flutter analyze` and the full `flutter test` suite and confirm both are
      clean/passing.

## Notes

- No `lib/` changes are expected beyond what T009 verifies against; `test/widget_test.dart`
  stays untracked per ROADMAP.md's Implementation rules.
