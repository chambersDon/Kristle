---

description: "Task list template for feature implementation"
---

# Tasks: Guess Scoring Engine

**Input**: Design documents from `/specs/003-guess-scoring-engine/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [quickstart.md](quickstart.md)

**Tests**: Required by Constitution Principle II (Test-First Development, NON-NEGOTIABLE).
For each user story below, write the failing unit test(s) first, confirm they fail for
the expected reason, then implement the minimum code in `lib/services/game_engine.dart`
(and `lib/models/game_state.dart` for the enum) to make them pass.

**Organization**: Tasks are grouped by this feature's three user stories (P1, P1, P3).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

Single Flutter project: `lib/` (source), `test/` (tests) at repository root — per
plan.md's Structure Decision.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm the project structure this feature depends on is in place.

- [X] T001 Verify `flutter pub get` succeeds and `flutter analyze` is clean on the
      current working tree (repository root), per Constitution's Development Workflow.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Define the shared `LetterStatus` enum every user story's tests depend on.

- [X] T002 Confirm `LetterStatus` (`empty`, `correct`, `present`, `absent`) is defined in
      [lib/models/game_state.dart](../../lib/models/game_state.dart).

**Checkpoint**: `LetterStatus` is available; user story implementation can begin.

---

## Phase 3: User Story 1 - A guess is scored letter-by-letter (Priority: P1) 🎯 MVP

**Goal**: `GameEngine.scoreGuess` classifies each guess letter as correct, present, or
absent against an answer with no duplicate letters involved (FR-001, FR-004, SC-001).

**Independent Test**: Run `flutter test test/game_engine_test.dart` calling
`scoreGuess` directly with literal guess/answer pairs — no UI needed.

### Tests for User Story 1 ⚠️

> **NOTE**: Write these tests FIRST, confirm they fail for the expected reason, then
> implement `GameEngine.scoreGuess` to make them pass.

- [X] T003 [P] [US1] In `test/game_engine_test.dart`, add a test that scoring a guess
      identical to the answer marks every letter correct (FR-001, acceptance scenario 1).
- [X] T004 [P] [US1] In `test/game_engine_test.dart`, add a test that scoring a guess
      sharing no letters with the answer marks every letter absent (FR-001, acceptance
      scenario 2).
- [X] T005 [P] [US1] In `test/game_engine_test.dart`, add a test that scoring a guess
      with a letter in the wrong position (that also appears elsewhere in the answer)
      marks that letter present (FR-001, acceptance scenario 3).
- [X] T006 [P] [US1] In `test/game_engine_test.dart`, add a test that scoring is
      case-insensitive (e.g. a lowercase guess against an uppercase answer, or vice
      versa, produces the same result as an all-uppercase comparison) (FR-004, edge
      case).
- [X] T007 [US1] Run `flutter test test/game_engine_test.dart` and confirm the tests from
      T003–T006 fail for the expected reason (missing/incomplete implementation) before
      moving on to implementation.

### Implementation for User Story 1

- [X] T008 [US1] Implement `GameEngine.scoreGuess` in
      [lib/services/game_engine.dart](../../lib/services/game_engine.dart) to satisfy
      FR-001 and FR-004: normalize guess/answer to uppercase, classify each position as
      correct/present/absent. Run `flutter test test/game_engine_test.dart` and confirm
      T003–T006 now pass.

**Checkpoint**: User Story 1 is fully covered by `test/game_engine_test.dart` and
passing.

---

## Phase 4: User Story 2 - Duplicate letters are scored fairly (Priority: P1)

**Goal**: A guess with more occurrences of a letter than the answer contains never gets
more correct/present credit for that letter than the answer actually has, with
correct-position matches resolved before present-elsewhere matches (FR-002, FR-003,
SC-002).

**Independent Test**: Run `flutter test test/game_engine_test.dart` with guesses
containing repeated letters against answers with 0, 1, or 2 occurrences of that letter.

### Tests for User Story 2 ⚠️

- [X] T009 [P] [US2] In `test/game_engine_test.dart`, add a test that a guess with a
      letter repeated twice, where the answer contains that letter only once (in a
      different position), marks exactly one occurrence present and the other absent
      (FR-003, acceptance scenario 1).
- [X] T010 [P] [US2] In `test/game_engine_test.dart`, add a test that a guess with a
      letter repeated twice — one occurrence correctly placed — where the answer
      contains that letter only once, marks the correctly-placed occurrence correct and
      the other absent, not present (FR-002, acceptance scenario 2).
- [X] T011 [P] [US2] In `test/game_engine_test.dart`, add a test that a guess with a
      letter repeated twice, where the answer also contains that letter twice, marks
      both occurrences correct and/or present as appropriate, with neither marked absent
      (FR-003, acceptance scenario 3).
- [X] T012 [US2] Run `flutter test test/game_engine_test.dart` and confirm the tests from
      T009–T011 fail for the expected reason before moving on to implementation.

### Implementation for User Story 2

- [X] T013 [US2] Implement the two-pass duplicate-letter handling in
      `GameEngine.scoreGuess` in
      [lib/services/game_engine.dart](../../lib/services/game_engine.dart): a
      correct-position pass building a remaining-count map from the answer's unmatched
      positions, then a present-elsewhere pass that consumes from that map (FR-002,
      FR-003). Run `flutter test test/game_engine_test.dart` and confirm T009–T011 now
      pass.

**Checkpoint**: User Stories 1 and 2 are both covered and passing.

---

## Phase 5: User Story 3 - Malformed scoring requests are rejected (Priority: P3)

**Goal**: Scoring a guess and answer of different lengths raises a clear error instead of
returning a result (FR-005, SC-004).

**Independent Test**: Run `flutter test test/game_engine_test.dart` calling `scoreGuess`
with a guess and answer of different lengths and asserting it throws.

### Tests for User Story 3 ⚠️

- [X] T014 [US3] In `test/game_engine_test.dart`, add a test that scoring a guess and
      answer of different lengths throws an error rather than returning a result
      (FR-005, acceptance scenario 1).
- [X] T015 [US3] Run `flutter test test/game_engine_test.dart` and confirm the test from
      T014 fails for the expected reason before moving on to implementation.

### Implementation for User Story 3

- [X] T016 [US3] Implement the length-mismatch guard at the top of
      `GameEngine.scoreGuess` in
      [lib/services/game_engine.dart](../../lib/services/game_engine.dart): raise an
      `ArgumentError` immediately when `guess.length != answer.length` (FR-005). Run
      `flutter test test/game_engine_test.dart` and confirm T014 now passes.

**Checkpoint**: All three user stories are covered by `test/game_engine_test.dart` and
passing.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final validation across the whole feature.

- [X] T017 Run `flutter analyze` and the full `flutter test` suite (repository root) and
      confirm both are clean/passing, per Constitution's Development Workflow.
- [X] T018 Walk through [quickstart.md](quickstart.md)'s "Try it" and "Validate with
      tests" steps manually (or via a small `dart`/`flutter` snippet) to confirm the
      engine behaves as documented.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately.
- **Foundational (Phase 2)**: Depends on Phase 1; blocks all user stories (they all use
  `LetterStatus`).
- **User Story 1 (Phase 3)**: Depends on Phase 2.
- **User Story 2 (Phase 4)**: Depends on Phase 2; builds on User Story 1's
  implementation but is independently testable (different guess/answer fixtures).
- **User Story 3 (Phase 5)**: Depends on Phase 2; independent of User Stories 1 and 2.
- **Polish (Phase 6)**: Depends on Phases 3–5 completion.

### Within Each User Story

- Tests marked [P] within a story write to the same file (`test/game_engine_test.dart`)
  but assert independent behavior, so they are logically parallel even though a real
  edit session applies them sequentially to one file. Each story's "confirm tests fail"
  task depends on that story's test-writing tasks completing first, and its
  implementation task depends on that.

### Parallel Opportunities

- T003–T006 (User Story 1), T009–T011 (User Story 2), and T014 (User Story 3) are
  independent assertions and could be drafted in parallel by different contributors,
  then merged into the single test file.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001).
2. Complete Phase 2: Foundational (T002).
3. Complete Phase 3: User Story 1 (T003–T008) — this is the MVP: basic
   correct/present/absent classification with no duplicate letters involved.
4. **STOP and VALIDATE**: `flutter test test/game_engine_test.dart` passes.

### Incremental Delivery

1. Complete Setup + Foundational → `LetterStatus` ready.
2. Add User Story 1 → validate independently → basic scoring implemented (MVP).
3. Add User Story 2 → validate independently → duplicate-letter handling implemented.
4. Add User Story 3 → validate independently → length-mismatch guard implemented.
5. Complete Phase 6: Polish (T017–T018) → full suite green, quickstart confirmed.

---

## Notes

- Tests before implementation, per Constitution Principle II (NON-NEGOTIABLE) — write
  the failing test, confirm it fails for the right reason, then write the minimum code
  to pass it, then refactor.
- Per ROADMAP.md's Implementation rules, `.gitignore` currently ignores everything
  except `.claude/`, `.specify/`, `specs/`, and itself — so `lib/` and
  `test/game_engine_test.dart` stay untracked (present on disk, not committed) even
  after this feature is done. Only this `specs/003-guess-scoring-engine/` directory's own
  files are trackable output of this task list today.
