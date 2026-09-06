---

description: "Task list template for feature implementation"
---

# Tasks: Letter Tile (Static)

**Input**: Design documents from `/specs/004-letter-tile-static/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [quickstart.md](quickstart.md)

**Tests**: Required by Constitution Principle II (Test-First Development, NON-NEGOTIABLE).
For each user story below, write the failing widget test(s) first, confirm they fail for
the expected reason, then implement the minimum code in
`lib/widgets/letter_tile.dart`/`lib/theme/game_colors.dart` to make them pass.

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

**Purpose**: Confirm the shared color constants every user story's tests depend on.

- [X] T002 Confirm `GameColors` in
      [lib/theme/game_colors.dart](../../lib/theme/game_colors.dart) defines distinct
      constants for `correct`, `present`, `absent`, and `tileEmpty`.

**Checkpoint**: Color constants are available; user story implementation can begin.

---

## Phase 3: User Story 1 - A tile shows its letter and scored color (Priority: P1) 🎯 MVP

**Goal**: A tile given a scored status renders the matching background color and its
letter legibly (FR-002, FR-003, FR-004, SC-001, SC-003).

**Independent Test**: Run `flutter test test/letter_tile_test.dart` pumping a single
`LetterTile` per status — no grid or screen needed.

### Tests for User Story 1 ⚠️

> **NOTE**: Write these tests FIRST, confirm they fail for the expected reason, then
> implement `LetterTile`'s static rendering to make them pass.

- [X] T003 [P] [US1] In `test/letter_tile_test.dart`, add a test that a tile with status
      `correct` renders a background matching `GameColors.correct` and displays its
      letter (FR-002, FR-003, acceptance scenario 1).
- [X] T004 [P] [US1] In `test/letter_tile_test.dart`, add a test that a tile with status
      `present` renders a background matching `GameColors.present` (acceptance scenario
      2).
- [X] T005 [P] [US1] In `test/letter_tile_test.dart`, add a test that a tile with status
      `absent` renders a background matching `GameColors.absent` (acceptance scenario 3).
- [X] T006 [P] [US1] In `test/letter_tile_test.dart`, add a test that every scored tile
      (correct/present/absent) renders its letter text in a color that contrasts with
      its background (e.g. white on each status color) (FR-004, acceptance scenario 4).
- [X] T007 [US1] Run `flutter test test/letter_tile_test.dart` and confirm the tests from
      T003–T006 fail for the expected reason (missing/incomplete implementation) before
      moving on to implementation.

### Implementation for User Story 1

- [X] T008 [US1] Implement the scored-status rendering branch of `LetterTile` in
      [lib/widgets/letter_tile.dart](../../lib/widgets/letter_tile.dart): map each
      `LetterStatus` to its `GameColors` background, render white letter text, and
      display the given letter (FR-002, FR-003, FR-004). Run
      `flutter test test/letter_tile_test.dart` and confirm T003–T006 now pass.

**Checkpoint**: User Story 1 is fully covered by `test/letter_tile_test.dart` and
passing.

---

## Phase 4: User Story 2 - An unscored tile looks distinct from a scored one (Priority: P2)

**Goal**: An unscored tile (empty or mid-typing) renders as an outlined, unfilled box,
with a visibly different border once a letter is typed into it (FR-005, FR-006, SC-002).

**Independent Test**: Run `flutter test test/letter_tile_test.dart` pumping an unscored
tile with and without a letter.

### Tests for User Story 2 ⚠️

- [X] T009 [P] [US2] In `test/letter_tile_test.dart`, add a test that a tile with no
      letter and status `empty` renders no fill color and no visible letter (FR-005,
      acceptance scenario 1, edge case: empty letter).
- [X] T010 [P] [US2] In `test/letter_tile_test.dart`, add a test that a tile with a
      letter and status `empty` (mid-typing) renders that letter with no scored fill
      color (FR-005, acceptance scenario 2).
- [X] T011 [P] [US2] In `test/letter_tile_test.dart`, add a test that an unscored tile
      with a letter uses a visibly different (more prominent) border than an unscored
      tile with no letter, while neither matches any scored fill color (FR-006,
      acceptance scenario 3).
- [X] T012 [US2] Run `flutter test test/letter_tile_test.dart` and confirm the tests from
      T009–T011 fail for the expected reason before moving on to implementation.

### Implementation for User Story 2

- [X] T013 [US2] Implement the unscored-status rendering branch of `LetterTile` in
      [lib/widgets/letter_tile.dart](../../lib/widgets/letter_tile.dart): no fill color,
      an outlined border that is more prominent once a letter is present than when fully
      empty (FR-005, FR-006). Run `flutter test test/letter_tile_test.dart` and confirm
      T009–T011 now pass.

**Checkpoint**: Both user stories are covered by `test/letter_tile_test.dart` and
passing.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Final validation across the whole feature.

- [X] T014 [P] Add a test in `test/letter_tile_test.dart` that `LetterTile` renders as a
      perfect square across at least three different size constraints (FR-001, SC-004,
      edge case: varying screen widths).
- [X] T015 Run `flutter analyze` and the full `flutter test` suite (repository root) and
      confirm both are clean/passing, per Constitution's Development Workflow.
- [X] T016 Walk through [quickstart.md](quickstart.md)'s "Try it" and "Validate with
      tests" steps manually (or via `flutter run`/a small harness) to confirm the tile
      behaves as documented.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately.
- **Foundational (Phase 2)**: Depends on Phase 1; blocks all user stories (they all read
  `GameColors`).
- **User Story 1 (Phase 3)**: Depends on Phase 2.
- **User Story 2 (Phase 4)**: Depends on Phase 2; independently testable from User Story
  1 (different status inputs).
- **Polish (Phase 5)**: Depends on Phases 3–4 completion.

### Within Each User Story

- Tests marked [P] within a story write to the same file (`test/letter_tile_test.dart`)
  but assert independent behavior, so they are logically parallel even though a real
  edit session applies them sequentially to one file.

### Parallel Opportunities

- T003–T006 (User Story 1) and T009–T011 (User Story 2) are independent assertions and
  could be drafted in parallel by different contributors, then merged into the single
  test file.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001).
2. Complete Phase 2: Foundational (T002).
3. Complete Phase 3: User Story 1 (T003–T008) — this is the MVP: a tile that correctly
   shows its scored color and letter.
4. **STOP and VALIDATE**: `flutter test test/letter_tile_test.dart` passes.

### Incremental Delivery

1. Complete Setup + Foundational → color constants ready.
2. Add User Story 1 → validate independently → scored rendering implemented (MVP).
3. Add User Story 2 → validate independently → unscored rendering implemented.
4. Complete Phase 5: Polish (T014–T016) → full suite green, quickstart confirmed.

---

## Notes

- Tests before implementation, per Constitution Principle II (NON-NEGOTIABLE) — write
  the failing test, confirm it fails for the right reason, then write the minimum code
  to pass it, then refactor.
- Per ROADMAP.md's Implementation rules, `.gitignore` currently ignores everything
  except `.claude/`, `.specify/`, `specs/`, and itself — so `lib/` and
  `test/letter_tile_test.dart` stay untracked (present on disk, not committed) even
  after this feature is done. Only this `specs/004-letter-tile-static/` directory's own
  files are trackable output of this task list today.
