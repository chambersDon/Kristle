---

description: "Task list template for feature implementation"
---

# Tasks: On-Screen Keyboard (Static)

**Input**: Design documents from `/specs/006-onscreen-keyboard-static/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [quickstart.md](quickstart.md)

**Tests**: Required by Constitution Principle II (Test-First Development, NON-NEGOTIABLE).
For each user story below, write the failing widget test(s) first, confirm they fail for
the expected reason, then implement the minimum code in
`lib/widgets/game_keyboard.dart` to make them pass.

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

**Purpose**: N/A for this feature — `GameKeyboard` has no shared infrastructure
dependency beyond the Flutter SDK itself, which Phase 1 already confirms is available.

**Checkpoint**: No foundational work required; proceed directly to User Story 1.

---

## Phase 3: User Story 1 - A player types letters using the on-screen keyboard (Priority: P1) 🎯 MVP

**Goal**: All 26 letters render in the QWERTY layout, and tapping a letter or backspace
reports the correct action via callback (FR-001–FR-004, FR-008, SC-001, SC-002).

**Independent Test**: Run `flutter test test/game_keyboard_test.dart` pumping
`GameKeyboard` with fake callbacks and tapping keys — no game screen needed.

### Tests for User Story 1 ⚠️

> **NOTE**: Write these tests FIRST, confirm they fail for the expected reason, then
> implement `GameKeyboard`'s layout and tap-reporting to make them pass.

- [X] T002 [P] [US1] In `test/game_keyboard_test.dart`, add a test that all 26 letters
      A–Z are present exactly once in the rendered keyboard (FR-001, SC-001).
- [X] T003 [P] [US1] In `test/game_keyboard_test.dart`, add a test that tapping each of
      several letter keys invokes `onLetterTap` with that exact letter (FR-003, SC-002,
      acceptance scenario 2).
- [X] T004 [P] [US1] In `test/game_keyboard_test.dart`, add a test that a distinct
      backspace key is present and tapping it invokes `onBackspaceTap` (not
      `onLetterTap`) (FR-002, FR-004, acceptance scenario 3).
- [X] T005 [P] [US1] In `test/game_keyboard_test.dart`, add a test that every letter key
      renders the same single default background color, with no per-key color variation
      (FR-008, edge case: no per-key coloring in this feature).
- [X] T006 [US1] Run `flutter test test/game_keyboard_test.dart` and confirm the tests
      from T002–T005 fail for the expected reason (missing/incomplete implementation)
      before moving on to implementation.

### Implementation for User Story 1

- [X] T007 [US1] Implement the QWERTY row layout and letter/backspace tap-reporting in
      `GameKeyboard` in
      [lib/widgets/game_keyboard.dart](../../lib/widgets/game_keyboard.dart): three
      fixed rows covering A–Z, a distinct backspace key, `onLetterTap`/`onBackspaceTap`
      callbacks, one default key color (FR-001–FR-004, FR-008). Run
      `flutter test test/game_keyboard_test.dart` and confirm T002–T005 now pass.

**Checkpoint**: User Story 1 is fully covered by `test/game_keyboard_test.dart` and
passing.

---

## Phase 4: User Story 2 - Submitting is only possible with a complete guess (Priority: P2)

**Goal**: The submit control is disabled unless `canSubmit` is true, and reports a submit
action only while enabled (FR-005–FR-007, SC-003).

**Independent Test**: Run `flutter test test/game_keyboard_test.dart` pumping
`GameKeyboard` with `canSubmit` toggled true/false and tapping the submit control.

### Tests for User Story 2 ⚠️

- [X] T008 [P] [US2] In `test/game_keyboard_test.dart`, add a test that with
      `canSubmit: false`, the submit control is disabled and does not invoke
      `onEnterTap` when tapped (FR-006, acceptance scenario 1).
- [X] T009 [P] [US2] In `test/game_keyboard_test.dart`, add a test that with
      `canSubmit: true`, the submit control is enabled (FR-006, acceptance scenario 2).
- [X] T010 [P] [US2] In `test/game_keyboard_test.dart`, add a test that tapping the
      enabled submit control invokes `onEnterTap` (FR-007, acceptance scenario 3).
- [X] T011 [US2] Run `flutter test test/game_keyboard_test.dart` and confirm the tests
      from T008–T010 fail for the expected reason before moving on to implementation.

### Implementation for User Story 2

- [X] T012 [US2] Implement the submit control in `GameKeyboard` in
      [lib/widgets/game_keyboard.dart](../../lib/widgets/game_keyboard.dart): a distinct
      button below the key rows whose `onPressed` is `canSubmit ? onEnterTap : null`
      (FR-005–FR-007). Run `flutter test test/game_keyboard_test.dart` and confirm
      T008–T010 now pass.

**Checkpoint**: Both user stories are covered by `test/game_keyboard_test.dart` and
passing.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Final validation across the whole feature.

- [X] T013 [P] Add a test in `test/game_keyboard_test.dart` that the keyboard renders
      without overflow errors at narrow, medium, and wide container widths (FR-009,
      SC-004, edge case: very little available width).
- [X] T014 Run `flutter analyze` and the full `flutter test` suite (repository root) and
      confirm both are clean/passing, per Constitution's Development Workflow.
- [X] T015 Walk through [quickstart.md](quickstart.md)'s "Try it" and "Validate with
      tests" steps manually (or via `flutter run`/a small harness) to confirm the
      keyboard behaves as documented.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately.
- **Foundational (Phase 2)**: N/A — nothing to complete.
- **User Story 1 (Phase 3)**: Depends on Phase 1 only.
- **User Story 2 (Phase 4)**: Depends on Phase 1; independently testable from User Story
  1 (submit behavior vs. letter/backspace behavior).
- **Polish (Phase 5)**: Depends on Phases 3–4 completion.

### Within Each User Story

- Tests marked [P] within a story write to the same file
  (`test/game_keyboard_test.dart`) but assert independent behavior, so they are
  logically parallel even though a real edit session applies them sequentially to one
  file.

### Parallel Opportunities

- T002–T005 (User Story 1) and T008–T010 (User Story 2) are independent assertions and
  could be drafted in parallel by different contributors, then merged into the single
  test file.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001).
2. Complete Phase 3: User Story 1 (T002–T007) — this is the MVP: a keyboard that
   reports letter and backspace taps correctly.
3. **STOP and VALIDATE**: `flutter test test/game_keyboard_test.dart` passes.

### Incremental Delivery

1. Complete Setup → Foundation ready (nothing further needed).
2. Add User Story 1 → validate independently → layout and letter/backspace reporting
   implemented (MVP).
3. Add User Story 2 → validate independently → submit control implemented.
4. Complete Phase 5: Polish (T013–T015) → full suite green, quickstart confirmed.

---

## Notes

- Tests before implementation, per Constitution Principle II (NON-NEGOTIABLE) — write
  the failing test, confirm it fails for the right reason, then write the minimum code
  to pass it, then refactor.
- Per ROADMAP.md's Implementation rules, `.gitignore` currently ignores everything
  except `.claude/`, `.specify/`, `specs/`, and itself — so `lib/` and
  `test/game_keyboard_test.dart` stay untracked (present on disk, not committed) even
  after this feature is done. Only this `specs/006-onscreen-keyboard-static/` directory's
  own files are trackable output of this task list today.
