---

description: "Task list template for feature implementation"
---

# Tasks: Physical Keyboard Support

**Input**: Design documents from `/specs/009-physical-keyboard-support/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [quickstart.md](quickstart.md)

**Tests**: Required by Constitution Principle II. Write the failing widget test(s)
first, confirm they fail, then implement `_handleKeyEvent`/`KeyboardListener` in
`lib/screens/game_screen.dart` to make them pass.

## Phase 1: Setup

- [X] T001 Verify `flutter pub get`/`flutter analyze` are clean on the working tree.

## Phase 2: User Story 1 - A player uses a physical keyboard to play (P1) 🎯 MVP

### Tests ⚠️

- [X] T002 [P] [US1] In `test/widget_test.dart`, add a test that physical letter key
      presses append letters to the current row, matching on-screen tap behavior
      (FR-002, SC-001, acceptance scenario 1).
- [X] T003 [P] [US1] In `test/widget_test.dart`, add a test that a physical Backspace
      press removes the last letter (FR-003, acceptance scenario 2).
- [X] T004 [P] [US1] In `test/widget_test.dart`, add a test that a physical Enter press
      submits a complete, valid guess (FR-004, acceptance scenario 3).
- [X] T005 [P] [US1] In `test/widget_test.dart`, add a test that a physical Enter press
      on an incomplete guess shows the same rejection message as an incomplete on-screen
      submit (FR-004, acceptance scenario 4).
- [X] T006 [US1] Run `flutter test test/widget_test.dart` and confirm T002–T005 fail for
      the expected reason before implementing.

### Implementation

- [X] T007 [US1] Implement `_handleKeyEvent` and the `KeyboardListener` wrapper in
      [lib/screens/game_screen.dart](../../lib/screens/game_screen.dart), delegating to
      `_addLetter`/`_removeLetter`/`_submitGuess` (FR-001–FR-004). Run
      `flutter test test/widget_test.dart` and confirm T002–T005 now pass.

## Phase 3: User Story 2 - Non-game keys are ignored (P2)

### Tests ⚠️

- [X] T008 [P] [US2] In `test/widget_test.dart`, add a test that pressing a non-letter,
      non-Backspace, non-Enter key (e.g. Tab or Shift) leaves the current guess
      unchanged (FR-005, SC-003, acceptance scenario 1).
- [X] T009 [US2] Run `flutter test test/widget_test.dart` and confirm T008 fails for the
      expected reason before implementing.

### Implementation

- [X] T010 [US2] Confirm `_handleKeyEvent`'s letter-detection guard
      (`keyLabel.length == 1 && RegExp('[A-Z]').hasMatch(label)`) naturally excludes
      non-letter keys (FR-005). Run `flutter test test/widget_test.dart` and confirm T008
      now passes.

## Phase 4: Polish

- [X] T011 Run `flutter analyze` and the full `flutter test` suite and confirm both are
      clean/passing.

## Notes

- No `lib/` changes are expected beyond what T007/T010 verify against; `test/widget_test.dart`
  stays untracked per ROADMAP.md's Implementation rules.
