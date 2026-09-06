---

description: "Task list template for feature implementation"
---

# Tasks: Invalid-Guess Shake Feedback

**Input**: Design documents from `/specs/010-invalid-guess-shake/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [quickstart.md](quickstart.md)

**Tests**: Required by Constitution Principle II. Write the failing widget test(s)
first, confirm they fail, then implement `ShakeTransition`/`_shakeController`/
`_shakeGrid` in `lib/screens/game_screen.dart` to make them pass.

## Phase 1: Setup

- [X] T001 Verify `flutter pub get`/`flutter analyze` are clean on the working tree.

## Phase 2: User Story 1 - The board shakes to signal a rejected guess (P1) 🎯 MVP

### Tests ⚠️

- [X] T002 [P] [US1] In `test/widget_test.dart`, add a test that submitting fewer than 5
      letters triggers a non-zero horizontal shake translation (FR-001, SC-001,
      acceptance scenario 1).
- [X] T003 [P] [US1] In `test/widget_test.dart`, add a test that submitting a
      5-letter word not in the allowed-guess list triggers a non-zero horizontal shake
      translation (FR-001, SC-001, acceptance scenario 2).
- [X] T004 [P] [US1] In `test/widget_test.dart`, add a test that submitting a valid
      guess does not trigger a shake translation (FR-002, SC-002, acceptance scenario
      3).
- [X] T005 [US1] Run `flutter test test/widget_test.dart` and confirm T002–T004 fail for
      the expected reason before implementing.

### Implementation

- [X] T006 [US1] Implement `ShakeTransition`, `_shakeController`, and `_shakeGrid` in
      [lib/screens/game_screen.dart](../../lib/screens/game_screen.dart), calling
      `_shakeGrid()` from both rejection branches of `_submitGuess` (FR-001–FR-004). Run
      `flutter test test/widget_test.dart` and confirm T002–T004 now pass.

## Phase 3: Polish

- [X] T007 Run `flutter analyze` and the full `flutter test` suite and confirm both are
      clean/passing.

## Notes

- No `lib/` changes are expected beyond what T006 verifies against; `test/widget_test.dart`
  stays untracked per ROADMAP.md's Implementation rules.
