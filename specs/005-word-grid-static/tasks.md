---

description: "Task list template for feature implementation"
---

# Tasks: Word Grid (Static)

**Input**: Design documents from `/specs/005-word-grid-static/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [quickstart.md](quickstart.md)

**Tests**: Required by Constitution Principle II (Test-First Development, NON-NEGOTIABLE).
For each user story below, write the failing widget test(s) first, confirm they fail for
the expected reason, then implement the minimum code in `lib/widgets/word_grid.dart` to
make them pass.

**Organization**: Tasks are grouped by this feature's two user stories (P1, P2).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2)
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

**Purpose**: Confirm the widgets/services this feature composes are in place.

- [X] T002 Confirm `LetterTile` (item 4) and `GameEngine.scoreGuess` (item 3) are
      available at [lib/widgets/letter_tile.dart](../../lib/widgets/letter_tile.dart) and
      [lib/services/game_engine.dart](../../lib/services/game_engine.dart).

**Checkpoint**: Dependencies are available; user story implementation can begin.

---

## Phase 3: User Story 1 - The board shows every guess row in its correct state (Priority: P1) 🎯 MVP

**Goal**: The grid always renders 6×5 tiles, with submitted rows scored, the current row
unscored, and remaining rows empty (FR-001–FR-004, SC-001–SC-003).

**Independent Test**: Run `flutter test test/word_grid_test.dart` pumping `WordGrid`
with different `guesses`/`currentGuess` combinations — no full screen needed.

### Tests for User Story 1 ⚠️

> **NOTE**: Write these tests FIRST, confirm they fail for the expected reason, then
> implement `WordGrid`'s row-content logic to make them pass.

- [X] T003 [P] [US1] In `test/word_grid_test.dart`, add a test that `WordGrid` always
      renders exactly 30 `LetterTile`s, checked with 0, 1, 3, and 6 submitted guesses
      (FR-001, SC-001, acceptance scenario 4).
- [X] T004 [P] [US1] In `test/word_grid_test.dart`, add a test that a submitted guess's
      row shows `LetterTile`s whose statuses match `GameEngine.scoreGuess`'s output for
      that guess/answer pair (FR-002, SC-002, acceptance scenario 1).
- [X] T005 [P] [US1] In `test/word_grid_test.dart`, add a test that the row following the
      last submitted guess shows the current guess's typed letters with every tile's
      status `LetterStatus.empty` (FR-003, SC-003, acceptance scenario 2).
- [X] T006 [P] [US1] In `test/word_grid_test.dart`, add a test that rows beyond the
      current guess render five empty tiles each (no letter, `LetterStatus.empty`)
      (FR-004, acceptance scenario 3).
- [X] T007 [P] [US1] In `test/word_grid_test.dart`, add a test that with exactly 6
      submitted guesses, all 6 rows are scored and no unscored "current guess" row is
      shown (FR-001, FR-003, edge case: round-ending case).
- [X] T008 [US1] Run `flutter test test/word_grid_test.dart` and confirm the tests from
      T003–T007 fail for the expected reason (missing/incomplete implementation) before
      moving on to implementation.

### Implementation for User Story 1

- [X] T009 [US1] Implement the per-row/per-cell content selection in `WordGrid` in
      [lib/widgets/word_grid.dart](../../lib/widgets/word_grid.dart): submitted rows
      scored via `GameEngine.scoreGuess`, the current-guess row unscored, remaining rows
      empty (FR-001–FR-004). Run `flutter test test/word_grid_test.dart` and confirm
      T003–T007 now pass.

**Checkpoint**: User Story 1 is fully covered by `test/word_grid_test.dart` and passing.

---

## Phase 4: User Story 2 - The board fits the space it's given (Priority: P2)

**Goal**: Tile size adapts to available width/height, never exceeding a fixed maximum
(FR-005, FR-006, SC-004).

**Independent Test**: Run `flutter test test/word_grid_test.dart` pumping `WordGrid`
inside containers of different sizes and checking the resulting tile size.

### Tests for User Story 2 ⚠️

- [X] T010 [P] [US2] In `test/word_grid_test.dart`, add a test that on a wide/tall
      container, tile size does not exceed the grid's fixed maximum tile size
      (FR-006, acceptance scenario 1).
- [X] T011 [P] [US2] In `test/word_grid_test.dart`, add a test that on a narrow
      container, tile size shrinks so all 5 columns fit within the available width
      (FR-005, acceptance scenario 2).
- [X] T012 [P] [US2] In `test/word_grid_test.dart`, add a test that on a short container,
      tile size shrinks so all 6 rows fit within the available height, even when width
      would otherwise allow larger tiles (FR-005, acceptance scenario 3, edge case:
      constrained on both dimensions).
- [X] T013 [US2] Run `flutter test test/word_grid_test.dart` and confirm the tests from
      T010–T012 fail for the expected reason before moving on to implementation.

### Implementation for User Story 2

- [X] T014 [US2] Implement the `LayoutBuilder`-based tile-sizing calculation in
      `WordGrid` in [lib/widgets/word_grid.dart](../../lib/widgets/word_grid.dart):
      width-based and height-based tile sizes, each capped at the fixed maximum, using
      the smaller of the two (FR-005, FR-006). Run `flutter test test/word_grid_test.dart`
      and confirm T010–T012 now pass.

**Checkpoint**: Both user stories are covered by `test/word_grid_test.dart` and passing.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Final validation across the whole feature.

- [X] T015 Run `flutter analyze` and the full `flutter test` suite (repository root) and
      confirm both are clean/passing, per Constitution's Development Workflow.
- [X] T016 Walk through [quickstart.md](quickstart.md)'s "Try it" and "Validate with
      tests" steps manually (or via `flutter run`/a small harness) to confirm the grid
      behaves as documented.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately.
- **Foundational (Phase 2)**: Depends on Phase 1; blocks all user stories (they all
  compose `LetterTile`/`GameEngine`).
- **User Story 1 (Phase 3)**: Depends on Phase 2.
- **User Story 2 (Phase 4)**: Depends on Phase 2; independently testable from User Story
  1 (sizing behavior vs. content correctness).
- **Polish (Phase 5)**: Depends on Phases 3–4 completion.

### Within Each User Story

- Tests marked [P] within a story write to the same file (`test/word_grid_test.dart`)
  but assert independent behavior, so they are logically parallel even though a real
  edit session applies them sequentially to one file.

### Parallel Opportunities

- T003–T007 (User Story 1) and T010–T012 (User Story 2) are independent assertions and
  could be drafted in parallel by different contributors, then merged into the single
  test file.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001).
2. Complete Phase 2: Foundational (T002).
3. Complete Phase 3: User Story 1 (T003–T009) — this is the MVP: a grid that correctly
   shows submitted/current/empty rows.
4. **STOP and VALIDATE**: `flutter test test/word_grid_test.dart` passes.

### Incremental Delivery

1. Complete Setup + Foundational → dependencies ready.
2. Add User Story 1 → validate independently → row content implemented (MVP).
3. Add User Story 2 → validate independently → responsive sizing implemented.
4. Complete Phase 5: Polish (T015–T016) → full suite green, quickstart confirmed.

---

## Notes

- Tests before implementation, per Constitution Principle II (NON-NEGOTIABLE) — write
  the failing test, confirm it fails for the right reason, then write the minimum code
  to pass it, then refactor.
- Per ROADMAP.md's Implementation rules, `.gitignore` currently ignores everything
  except `.claude/`, `.specify/`, `specs/`, and itself — so `lib/` and
  `test/word_grid_test.dart` stay untracked (present on disk, not committed) even after
  this feature is done. Only this `specs/005-word-grid-static/` directory's own files
  are trackable output of this task list today.
