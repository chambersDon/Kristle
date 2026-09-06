---

description: "Task list template for feature implementation"
---

# Tasks: Answer-Reveal Easter Egg

**Input**: Design documents from `/specs/017-answer-reveal-easter-egg/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [quickstart.md](quickstart.md)

**Tests**: Required by Constitution Principle II. Write the failing widget test(s)
first, confirm they fail, then implement `AppConfig`/`_handleHeaderTap` to make them
pass.

## Phase 1: Setup

- [X] T001 Verify `flutter pub get`/`flutter analyze` are clean on the working tree.

## Phase 2: User Story 1 - Tapping the header reveals the answer (P1) 🎯 MVP

### Tests ⚠️

- [X] T002 [P] [US1] In `test/widget_test.dart`, add/confirm a test that fewer than
      five header taps leave the header image showing (FR-001, acceptance scenario 1).
- [X] T003 [P] [US1] In `test/widget_test.dart`, add/confirm a test that a fifth header
      tap reveals the answer as text in place of the header image (FR-001, acceptance
      scenario 2).
- [X] T004 [US1] Run `flutter test test/widget_test.dart` and confirm T002–T003 fail for
      the expected reason before implementing.

### Implementation

- [X] T005 [US1] Implement `_headerTapCount`/the reveal branch of `_handleHeaderTap` in
      [lib/screens/game_screen.dart](../../lib/screens/game_screen.dart) (FR-001). Run
      `flutter test test/widget_test.dart` and confirm T002–T003 now pass.

## Phase 3: User Story 2 - Tapping the revealed answer hides it again (P2)

### Tests ⚠️

- [X] T006 [P] [US2] In `test/widget_test.dart`, add/confirm a test that fewer than
      five taps on the revealed answer leave it revealed (FR-002, acceptance scenario
      1).
- [X] T007 [P] [US2] In `test/widget_test.dart`, add/confirm a test that a fifth tap on
      the revealed answer restores the header image (FR-002, acceptance scenario 2).
- [X] T008 [US2] Run `flutter test test/widget_test.dart` and confirm T006–T007 fail for
      the expected reason before implementing.

### Implementation

- [X] T009 [US2] Implement `_answerTapCount`/the hide branch of `_handleHeaderTap`
      (FR-002). Run `flutter test test/widget_test.dart` and confirm T006–T007 now pass.

## Phase 4: User Story 3 - The reveal is force-hidden on a new game (P2)

### Tests ⚠️

- [X] T010 [P] [US3] In `test/widget_test.dart`, add/confirm a test that starting a new
      game while revealed shows the header image again (FR-003, acceptance scenario 1).
- [X] T011 [P] [US3] In `test/widget_test.dart`, add/confirm a test that after a new
      game, the full five taps are required again to reveal (no leftover progress)
      (FR-003, acceptance scenario 2).
- [X] T012 [US3] Run `flutter test test/widget_test.dart` and confirm T010–T011 fail for
      the expected reason before implementing.

### Implementation

- [X] T013 [US3] Reset `_headerTapCount`/`_answerTapCount`/`_isAnswerRevealed` in
      `_startNewGame` (FR-003). Run `flutter test test/widget_test.dart` and confirm
      T010–T011 now pass.

## Phase 5: User Story 4 - The helper can be fully disabled at build time (P3)

### Tests ⚠️

- [X] T014 [US4] In `test/widget_test.dart`, add/confirm a test that with
      `enableAnswerReveal: false`, five header taps never reveal the answer (FR-004,
      acceptance scenario 1).
- [X] T015 [US4] Run `flutter test test/widget_test.dart` and confirm T014 fails for the
      expected reason before implementing.

### Implementation

- [X] T016 [US4] Implement `AppConfig.enableAnswerReveal` in
      [lib/config/app_config.dart](../../lib/config/app_config.dart) (FR-004, FR-005)
      and guard `_handleHeaderTap` on `widget.enableAnswerReveal`. Run
      `flutter test test/widget_test.dart` and confirm T014 now passes.

## Phase 6: Polish

- [X] T017 Run `flutter analyze` and the full `flutter test` suite and confirm both are
      clean/passing.

## Notes

- No `lib/` changes are expected beyond what T005/T009/T013/T016 verify against;
  `test/widget_test.dart` stays untracked per ROADMAP.md's Implementation rules.
