---

description: "Task list template for feature implementation"
---

# Tasks: Letter Tile Flip-Reveal Animation

**Input**: Design documents from `/specs/011-letter-tile-flip-reveal/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [quickstart.md](quickstart.md)

**Tests**: Required by Constitution Principle II. Write the failing widget test(s)
first, confirm they fail, then implement the animation in
`lib/widgets/letter_tile.dart` (and the delay calculation in
`lib/widgets/word_grid.dart`) to make them pass.

## Phase 1: Setup

- [X] T001 Verify `flutter pub get`/`flutter analyze` are clean on the working tree.

## Phase 2: User Story 1 - A submitted row flips to reveal its result (P1) 🎯 MVP

### Tests ⚠️

- [X] T002 [P] [US1] In `test/letter_tile_test.dart`, add a test that a tile
      transitioning from `empty` to a scored status still shows its unscored face
      before `revealDelay` has elapsed (FR-001, acceptance scenario 1).
- [X] T003 [P] [US1] In `test/letter_tile_test.dart`, add a test that once
      `revealDelay` and the flip duration have elapsed, the tile shows its scored face
      and color (FR-002, SC-002, acceptance scenario 2).
- [X] T004 [P] [US1] In `test/letter_tile_test.dart`, add a test that a `LetterTile`
      constructed directly with a scored status shows that status immediately, with no
      unscored face ever rendered (FR-004, SC-003, acceptance scenario 4).
- [X] T005 [P] [US1] In `test/letter_tile_test.dart`, add a test that a tile
      transitioning from a scored status back to `empty` shows its unscored face
      immediately (FR-005, edge case).
- [X] T006 [P] [US1] In `test/word_grid_test.dart`, add a test that a submitted row's
      tiles receive strictly increasing `revealDelay` values from left to right
      (FR-003, SC-001, acceptance scenario 3).
- [X] T007 [US1] Run `flutter test test/letter_tile_test.dart test/word_grid_test.dart`
      and confirm T002–T006 fail for the expected reason before implementing.

### Implementation

- [X] T008 [US1] Implement `_revealController`/`didUpdateWidget`/the `AnimatedBuilder`
      rotation in [lib/widgets/letter_tile.dart](../../lib/widgets/letter_tile.dart)
      (FR-001, FR-002, FR-004, FR-005, FR-006) and the per-column `revealDelay`
      calculation in [lib/widgets/word_grid.dart](../../lib/widgets/word_grid.dart)
      (FR-003). Run `flutter test test/letter_tile_test.dart test/word_grid_test.dart`
      and confirm T002–T006 now pass.

## Phase 3: Polish

- [X] T009 Run `flutter analyze` and the full `flutter test` suite and confirm both are
      clean/passing.

## Notes

- No `lib/` changes are expected beyond what T008 verifies against; test files stay
  untracked per ROADMAP.md's Implementation rules.

## Phase 4: Convergence

- [ ] T010 Add a test in `test/letter_tile_test.dart` that a tile receiving a new status
      change while its flip animation is still in progress restarts cleanly (e.g. ends
      showing the newest status's face with no stuck intermediate rotation) per FR-006
      (partial).
