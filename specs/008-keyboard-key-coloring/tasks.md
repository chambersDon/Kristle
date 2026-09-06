---

description: "Task list template for feature implementation"
---

# Tasks: Keyboard Key-Status Coloring

**Input**: Design documents from `/specs/008-keyboard-key-coloring/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [quickstart.md](quickstart.md)

**Tests**: Required by Constitution Principle II. Write the failing widget test(s)
first, confirm they fail, then implement `_keyStatuses`/`_statusRank` in
`lib/screens/game_screen.dart` to make them pass.

## Phase 1: Setup

- [X] T001 Verify `flutter pub get`/`flutter analyze` are clean on the working tree.

## Phase 2: User Story 1 - Keyboard letters reflect what's been learned so far (P1) 🎯 MVP

### Tests ⚠️

- [X] T002 [P] [US1] In `test/widget_test.dart`, add a test that after submitting a
      guess containing a correct letter, that letter's on-screen key shows the
      correct-status color (FR-001, FR-002, acceptance scenario 1).
- [X] T003 [P] [US1] In `test/widget_test.dart`, add a test that a letter never guessed
      shows the default key color (FR-004, acceptance scenario 2).
- [X] T004 [P] [US1] In `test/widget_test.dart`, add a test that a letter scored absent
      in one guess and present in a later guess shows the present-status color, not
      absent (FR-003, acceptance scenario 3, edge case: never downgrade).
- [X] T005 [P] [US1] In `test/widget_test.dart`, add a test that a letter scored present
      in one guess and correct in a later guess shows the correct-status color, not
      present (FR-003, acceptance scenario 4).
- [X] T006 [US1] Run `flutter test test/widget_test.dart` and confirm T002–T005 fail for
      the expected reason before implementing.

### Implementation

- [X] T007 [US1] Implement `_keyStatuses`/`_statusRank` in
      [lib/screens/game_screen.dart](../../lib/screens/game_screen.dart) and pass the
      result to `GameKeyboard`'s `keyStatuses` (FR-001–FR-004). Run
      `flutter test test/widget_test.dart` and confirm T002–T005 now pass.

## Phase 3: Polish

- [X] T008 Run `flutter analyze` and the full `flutter test` suite and confirm both are
      clean/passing.

## Notes

- No `lib/` changes are expected beyond what T007 verifies against; `test/widget_test.dart`
  stays untracked per ROADMAP.md's Implementation rules.
