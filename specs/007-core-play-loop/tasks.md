---

description: "Task list template for feature implementation"
---

# Tasks: Core Play Loop

**Input**: Design documents from `/specs/007-core-play-loop/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [quickstart.md](quickstart.md)

**Tests**: Required by Constitution Principle II (Test-First Development, NON-NEGOTIABLE).
For each user story below, write the failing widget test(s) first, confirm they fail for
the expected reason, then implement the minimum code in
`lib/screens/game_screen.dart` to make them pass.

**Organization**: Tasks are grouped by this feature's four user stories (P1, P1, P1, P2).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3, US4)
- Include exact file paths in descriptions

## Path Conventions

Single Flutter project: `lib/` (source), `test/` (tests) at repository root — per
plan.md's Structure Decision.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm the project structure and dependencies this feature builds on are
in place.

- [X] T001 Verify `flutter pub get` succeeds and `flutter analyze` is clean on the
      current working tree (repository root), per Constitution's Development Workflow.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Confirm the services/widgets this feature wires together are available.

- [X] T002 Confirm `WordList` (item 2), `GameEngine` (item 3), `WordGrid` (item 5), and
      `GameKeyboard` (item 6) are available at their existing locations under `lib/`.

**Checkpoint**: Dependencies are available; user story implementation can begin.

---

## Phase 3: User Story 1 - A player types and edits a guess (Priority: P1) 🎯 MVP

**Goal**: Typing letters builds the current row up to 5 letters; backspace removes the
last letter; both are no-ops past their bounds (FR-002, FR-003, SC-001).

**Independent Test**: Run `flutter test test/widget_test.dart` pumping `GameScreen`
(via `KristleApp`) and tapping on-screen keyboard letter/backspace keys.

### Tests for User Story 1 ⚠️

> **NOTE**: Write these tests FIRST, confirm they fail for the expected reason, then
> implement `_addLetter`/`_removeLetter` to make them pass.

- [X] T003 [P] [US1] In `test/widget_test.dart`, add a test that tapping letter keys
      appends each letter to the current row in order (FR-002, acceptance scenario 1).
- [X] T004 [P] [US1] In `test/widget_test.dart`, add a test that tapping backspace
      removes the last letter of the current row (FR-003, acceptance scenario 2).
- [X] T005 [P] [US1] In `test/widget_test.dart`, add a test that once 5 letters have
      been typed, tapping another letter key has no effect on the current row (FR-002,
      acceptance scenario 3).
- [X] T006 [P] [US1] In `test/widget_test.dart`, add a test that tapping backspace on an
      empty current guess has no effect (FR-003, acceptance scenario 4).
- [X] T007 [US1] Run `flutter test test/widget_test.dart` and confirm the tests from
      T003–T006 fail for the expected reason (missing/incomplete implementation) before
      moving on to implementation.

### Implementation for User Story 1

- [X] T008 [US1] Implement `_addLetter`/`_removeLetter` in
      [lib/screens/game_screen.dart](../../lib/screens/game_screen.dart): append/trim
      `_currentGuess` with the 5-letter cap and empty-guess guard (FR-002, FR-003). Run
      `flutter test test/widget_test.dart` and confirm T003–T006 now pass.

**Checkpoint**: User Story 1 is fully covered by `test/widget_test.dart` and passing.

---

## Phase 4: User Story 2 - A guess is only accepted if it's complete and valid (Priority: P1)

**Goal**: Submission is rejected (with a message) for incomplete or unrecognized
guesses, and accepted (clearing the message, adding a row) for a complete, allowed guess
(FR-004–FR-007, SC-002).

**Independent Test**: Run `flutter test test/widget_test.dart` attempting to submit
incomplete, invalid, and valid guesses in turn.

### Tests for User Story 2 ⚠️

- [X] T009 [P] [US2] In `test/widget_test.dart`, add a test that submitting fewer than 5
      letters shows a length-rejection message and adds no scored row (FR-004,
      acceptance scenario 1).
- [X] T010 [P] [US2] In `test/widget_test.dart`, add a test that submitting a 5-letter
      word not in the allowed-guess list shows a not-recognized message and adds no
      scored row (FR-005, acceptance scenario 2).
- [X] T011 [P] [US2] In `test/widget_test.dart`, add a test that submitting a 5-letter
      allowed word adds a new scored row, clears the current guess, and clears any prior
      rejection message (FR-006, acceptance scenario 3).
- [X] T012 [P] [US2] In `test/widget_test.dart`, add a test that editing the current
      guess (typing or backspacing) after a rejection clears the shown message (FR-007,
      edge case: stale message).
- [X] T013 [US2] Run `flutter test test/widget_test.dart` and confirm the tests from
      T009–T012 fail for the expected reason before moving on to implementation.

### Implementation for User Story 2

- [X] T014 [US2] Implement submission validation in `_submitGuess` in
      [lib/screens/game_screen.dart](../../lib/screens/game_screen.dart): reject on
      length, then on `wordList.isAllowedGuess`, each with its own message; on success,
      append to `_guesses` and clear `_currentGuess`/`_message` (FR-004–FR-006); clear
      `_message` in `_addLetter`/`_removeLetter` as well (FR-007). Run
      `flutter test test/widget_test.dart` and confirm T009–T012 now pass.

**Checkpoint**: User Stories 1 and 2 are both covered and passing.

---

## Phase 5: User Story 3 - The round ends on a win or a loss (Priority: P1)

**Goal**: Submitting the answer ends the round in a win; the sixth non-matching
submission ends it in a loss; once ended, all input is a no-op (FR-008–FR-010, SC-003,
SC-004).

**Independent Test**: Run `flutter test test/widget_test.dart` submitting the answer
(win path) and, separately, six non-matching guesses (loss path), then attempting
further input.

### Tests for User Story 3 ⚠️

- [X] T015 [P] [US3] In `test/widget_test.dart`, add a test that submitting a guess
      matching the answer ends the round in a win (FR-008, acceptance scenario 1).
- [X] T016 [P] [US3] In `test/widget_test.dart`, add a test that submitting a sixth
      non-matching guess ends the round in a loss (FR-009, acceptance scenario 2).
- [X] T017 [P] [US3] In `test/widget_test.dart`, add a test that once the round has
      ended (win or loss), attempting to type a letter, backspace, or submit has no
      effect (FR-010, acceptance scenario 3).
- [X] T018 [US3] Run `flutter test test/widget_test.dart` and confirm the tests from
      T015–T017 fail for the expected reason before moving on to implementation.

### Implementation for User Story 3

- [X] T019 [US3] Implement win/loss detection in `_submitGuess` in
      [lib/screens/game_screen.dart](../../lib/screens/game_screen.dart): set
      `_status = won` when the submitted guess equals `_answer`, else `_status = lost`
      once `_guesses.length == 6` (FR-008, FR-009); guard `_addLetter`/`_removeLetter`/
      `_submitGuess` on `_status == playing` (FR-010). Run
      `flutter test test/widget_test.dart` and confirm T015–T017 now pass.

**Checkpoint**: User Stories 1–3 are all covered and passing.

---

## Phase 6: User Story 4 - Every round starts with a freshly chosen answer (Priority: P2)

**Goal**: The round's answer is drawn from the loaded answer list at start, not fixed
(FR-001, SC-005).

**Independent Test**: Run `flutter test test/widget_test.dart` with a multi-word test
`WordList`, losing the round, and confirming the revealed answer is a list member.

### Tests for User Story 4 ⚠️

- [X] T020 [US4] In `test/widget_test.dart`, add a test using a `WordList` with more
      than one answer that starts a round, loses it (six non-matching guesses), and
      confirms the revealed answer is a member of the loaded answer list (FR-001, SC-005,
      acceptance scenario 1).
- [X] T021 [US4] Run `flutter test test/widget_test.dart` and confirm the test from T020
      fails for the expected reason before moving on to implementation.

### Implementation for User Story 4

- [X] T022 [US4] Implement answer selection in `initState` in
      [lib/screens/game_screen.dart](../../lib/screens/game_screen.dart):
      `_answer = widget.wordList.pickRandomAnswer(random: _random)` (FR-001). Run
      `flutter test test/widget_test.dart` and confirm T020 now passes.

**Checkpoint**: All four user stories are covered by `test/widget_test.dart` and
passing.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final validation across the whole feature.

- [X] T023 Run `flutter analyze` and the full `flutter test` suite (repository root) and
      confirm both are clean/passing, per Constitution's Development Workflow.
- [X] T024 Walk through [quickstart.md](quickstart.md)'s "Run it" and "Validate with
      tests" steps manually (or via `flutter run`) to confirm the play loop behaves as
      documented.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately.
- **Foundational (Phase 2)**: Depends on Phase 1; blocks all user stories (they all wire
  the same dependencies together).
- **User Story 1 (Phase 3)**: Depends on Phase 2.
- **User Story 2 (Phase 4)**: Depends on User Story 1 (submission acts on the current
  guess entry already builds) but is independently testable via its own assertions.
- **User Story 3 (Phase 5)**: Depends on User Story 2 (win/loss is detected during
  submission) but is independently testable via its own assertions.
- **User Story 4 (Phase 6)**: Depends on Phase 2 only; independent of User Stories 1–3.
- **Polish (Phase 7)**: Depends on Phases 3–6 completion.

### Within Each User Story

- Tests marked [P] within a story write to the same file (`test/widget_test.dart`) but
  assert independent behavior, so they are logically parallel even though a real edit
  session applies them sequentially to one file. Each story's "confirm tests fail" task
  depends on that story's test-writing tasks completing first, and its implementation
  task depends on that.

### Parallel Opportunities

- T003–T006 (User Story 1), T009–T012 (User Story 2), T015–T017 (User Story 3), and T020
  (User Story 4) are independent assertions and could be drafted in parallel by
  different contributors, then merged into the single test file.

---

## Implementation Strategy

### MVP First (User Stories 1–3 Only)

1. Complete Phase 1: Setup (T001).
2. Complete Phase 2: Foundational (T002).
3. Complete Phases 3–5: User Stories 1–3 (T003–T019) — this is the MVP: a full, playable
   round with entry, submission validation, and win/loss detection.
4. **STOP and VALIDATE**: `flutter test test/widget_test.dart` passes.

### Incremental Delivery

1. Complete Setup + Foundational → dependencies ready.
2. Add User Story 1 → validate independently → guess entry implemented.
3. Add User Story 2 → validate independently → submission validation implemented.
4. Add User Story 3 → validate independently → win/loss detection implemented (MVP
   complete).
5. Add User Story 4 → validate independently → random answer selection implemented.
6. Complete Phase 7: Polish (T023–T024) → full suite green, quickstart confirmed.

---

## Notes

- Tests before implementation, per Constitution Principle II (NON-NEGOTIABLE) — write
  the failing test, confirm it fails for the right reason, then write the minimum code
  to pass it, then refactor.
- This feature's tests share `test/widget_test.dart` with several later roadmap features
  (stats, persistence, animations, physical-keyboard input, the answer-reveal helper,
  the win-celebration overlay) that also exercise `GameScreen`. Add only the assertions
  listed above — do not add coverage for those later features' behavior here.
- Per ROADMAP.md's Implementation rules, `.gitignore` currently ignores everything
  except `.claude/`, `.specify/`, `specs/`, and itself — so `lib/` and
  `test/widget_test.dart` stay untracked (present on disk, not committed) even after
  this feature is done. Only this `specs/007-core-play-loop/` directory's own files are
  trackable output of this task list today.
