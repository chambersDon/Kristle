---

description: "Task list template for feature implementation"
---

# Tasks: Word List Loading & Validation

**Input**: Design documents from `/specs/002-word-list-loading/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [quickstart.md](quickstart.md)

**Tests**: Required by Constitution Principle II (Test-First Development, NON-NEGOTIABLE).
For each user story below, write the failing unit test(s) first, confirm they fail for
the expected reason, then implement the minimum code in `lib/services/word_list.dart` to
make them pass.

**Organization**: Tasks are grouped by this feature's three user stories (P1, P2, P2).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

Single Flutter project: `lib/` (source), `test/` (tests), `assets/` (bundled data) at
repository root — per plan.md's Structure Decision. No `src/`, `backend/`, or
platform-specific test trees apply.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm the project structure this feature depends on is in place.

- [X] T001 Verify `flutter pub get` succeeds and `flutter analyze` is clean on the
      current working tree (repository root), per Constitution's Development Workflow.
- [X] T002 Confirm the bundled asset files
      [assets/words/kristle_answers.txt](../../assets/words/kristle_answers.txt) and
      [assets/words/allowed_guesses.txt](../../assets/words/allowed_guesses.txt) exist
      and are declared under `flutter.assets` in [pubspec.yaml](../../pubspec.yaml).

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: N/A for this feature — `WordList` has no shared infrastructure dependency
beyond the Flutter SDK and the two asset files, which Phase 1 already confirms are
available.

**Checkpoint**: No foundational work required; proceed directly to User Story 1.

---

## Phase 3: User Story 1 - App loads a validated word list on startup (Priority: P1) 🎯 MVP

**Goal**: The app loads both bundled word lists, validates every entry is exactly 5
letters (skipping blank/comment lines), fails loudly on malformed entries or an empty
answer list, and normalizes matching to be case-insensitive (FR-001–FR-005, SC-001,
SC-002).

**Independent Test**: Run `flutter test test/word_list_test.dart` with in-memory
good/bad word-list strings passed to `WordList.fromText(...)` — no asset bundle or UI
needed.

### Tests for User Story 1 ⚠️

> **NOTE**: Write these tests FIRST, confirm they fail for the expected reason, then
> implement `WordList` to make them pass.

- [X] T003 [P] [US1] In `test/word_list_test.dart`, add a test that `WordList.fromText`
      with well-formed answers/allowed-guesses strings loads successfully and exposes
      non-empty `answers`/`allowedGuesses` (FR-001).
- [X] T004 [P] [US1] In `test/word_list_test.dart`, add a test that a line with the
      wrong number of letters (e.g. `4` or `6` letters) in either list throws a
      `FormatException` identifying which list it came from (FR-002, edge case:
      malformed entry).
- [X] T005 [P] [US1] In `test/word_list_test.dart`, add a test that blank lines and
      `#`-prefixed comment lines in either list are skipped without error, including a
      comment line whose text itself is not 5 letters (FR-003, edge cases: blank lines,
      comment lines).
- [X] T006 [P] [US1] In `test/word_list_test.dart`, add a test that a line with
      leading/trailing whitespace around an otherwise-valid word loads successfully
      (whitespace edge case).
- [X] T007 [P] [US1] In `test/word_list_test.dart`, add a test that `isAllowedGuess` (or
      an equivalent lookup) returns the same result for a word regardless of input
      letter case (e.g. `"kite"`, `"KITE"`, `"Kite"`) (FR-004).
- [X] T008 [P] [US1] In `test/word_list_test.dart`, add a test that an answers source
      containing only blank/comment lines (zero valid words) throws a `StateError` when
      loaded (FR-005, edge case: empty answer list).
- [X] T009 [US1] Run `flutter test test/word_list_test.dart` and confirm the tests from
      T003–T008 fail for the expected reason (missing/incomplete implementation) before
      moving on to implementation.

### Implementation for User Story 1

- [X] T010 [US1] Implement `WordList.load`/`WordList.fromText`/`_parseWords` in
      [lib/services/word_list.dart](../../lib/services/word_list.dart) to satisfy
      FR-001–FR-005: load both bundled assets, validate each non-skipped line against
      `^[A-Z]{5}$` after trimming and uppercasing, skip blank/`#`-comment lines, throw
      `FormatException` naming the offending list on a malformed entry, and throw
      `StateError` if the answers list ends up empty. Run
      `flutter test test/word_list_test.dart` and confirm T003–T008 now pass.

**Checkpoint**: User Story 1 is fully covered by `test/word_list_test.dart` and passing.

---

## Phase 4: User Story 2 - A random answer is chosen for a new game (Priority: P2)

**Goal**: `pickRandomAnswer` always returns a member of the loaded answer list and is
not hard-coded to a single word (FR-006, SC-003).

**Independent Test**: Run `flutter test test/word_list_test.dart` against a small known
answer list and assert repeated picks are always list members.

### Tests for User Story 2 ⚠️

- [X] T011 [P] [US2] In `test/word_list_test.dart`, add a test that `pickRandomAnswer`
      (with an injected seeded `Random`) returns a word that is a member of the loaded
      `answers` list (FR-006, SC-003).
- [X] T012 [P] [US2] In `test/word_list_test.dart`, add a test using an answer list with
      2+ entries and multiple distinct `Random` seeds, asserting that not every pick
      returns the same word (the "not fixed to one entry" clause of FR-006).
- [X] T013 [US2] Run `flutter test test/word_list_test.dart` and confirm the tests from
      T011–T012 fail for the expected reason before moving on to implementation.

### Implementation for User Story 2

- [X] T014 [US2] Implement `pickRandomAnswer` in
      [lib/services/word_list.dart](../../lib/services/word_list.dart) to satisfy
      FR-006: uniformly select from `answers` using the given or a new `Random`. Run
      `flutter test test/word_list_test.dart` and confirm T011–T012 now pass.

**Checkpoint**: User Stories 1 and 2 are both covered and passing.

---

## Phase 5: User Story 3 - A submitted guess is checked against the allowed word list (Priority: P2)

**Goal**: `isAllowedGuess` correctly accepts allowed-guess-list members, rejects
non-members, and always accepts every answer-list word even if it is not separately
listed in the allowed-guess source (FR-007, FR-008, SC-004).

**Independent Test**: Run `flutter test test/word_list_test.dart` against small known
answer/allowed-guess lists and assert accept/reject behavior for member and non-member
words.

### Tests for User Story 3 ⚠️

- [X] T015 [P] [US3] In `test/word_list_test.dart`, add a test that a guess matching an
      allowed-guess-list entry (in any letter case) is reported as allowed (FR-007,
      acceptance scenario 1).
- [X] T016 [P] [US3] In `test/word_list_test.dart`, add a test that a guess not present
      in either list is reported as not allowed (FR-007, acceptance scenario 2).
- [X] T017 [P] [US3] In `test/word_list_test.dart`, add a test that a word present only
      in the answers list (not separately listed in the allowed-guesses source) is
      still reported as an allowed guess (FR-008, acceptance scenario 3).
- [X] T018 [US3] Run `flutter test test/word_list_test.dart` and confirm the tests from
      T015–T017 fail for the expected reason before moving on to implementation.

### Implementation for User Story 3

- [X] T019 [US3] Implement `isAllowedGuess` in
      [lib/services/word_list.dart](../../lib/services/word_list.dart) to satisfy
      FR-007/FR-008: case-insensitive membership check against `allowedGuesses`, with
      every answer unioned into `allowedGuesses` at load time. Run
      `flutter test test/word_list_test.dart` and confirm T015–T017 now pass.

**Checkpoint**: All three user stories are covered by `test/word_list_test.dart` and
passing.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final validation across the whole feature.

- [X] T020 Run `flutter analyze` and the full `flutter test` suite (repository root) and
      confirm both are clean/passing, per Constitution's Development Workflow.
- [X] T021 Walk through [quickstart.md](quickstart.md)'s "Try it" and "Validate with
      tests" steps manually (or via a small `dart`/`flutter` snippet) to confirm the
      service behaves as documented against the real bundled assets.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately.
- **Foundational (Phase 2)**: N/A — nothing to complete.
- **User Story 1 (Phase 3)**: Depends on Phase 1 (T001–T002) only.
- **User Story 2 (Phase 4)**: Depends on Phase 1; independent of User Story 1's tests
  (different assertions on the same `WordList`), but reads/writes the same test file.
- **User Story 3 (Phase 5)**: Depends on Phase 1; independent of User Stories 1 and 2.
- **Polish (Phase 6)**: Depends on Phases 3–5 completion.

### Within Each User Story

- Tests marked [P] within a story write to the same file (`test/word_list_test.dart`)
  but assert independent behavior, so they are logically parallel (no shared mutable
  state) even though a real edit session applies them sequentially to one file. Each
  story's "confirm tests fail" task depends on that story's test-writing tasks
  completing first, and its implementation task depends on that.

### Parallel Opportunities

- T003–T008 (User Story 1's tests) are independent assertions and can be drafted in
  parallel before being merged into `test/word_list_test.dart`.
- T011–T012 (User Story 2) and T015–T017 (User Story 3) are likewise independent of each
  other and of User Story 1's tests — all three stories' test tasks could be authored in
  parallel by different contributors, then merged into the single test file.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T002).
2. Complete Phase 3: User Story 1 (T003–T010) — this is the MVP: a validated,
   case-insensitive word list the app can trust at startup.
3. **STOP and VALIDATE**: `flutter test test/word_list_test.dart` passes.

### Incremental Delivery

1. Complete Setup → Foundation ready (nothing further needed).
2. Add User Story 1 → validate independently → loading/validation implemented (MVP).
3. Add User Story 2 → validate independently → random-answer selection implemented.
4. Add User Story 3 → validate independently → guess-validity checking implemented.
5. Complete Phase 6: Polish (T020–T021) → full suite green, quickstart confirmed.

---

## Notes

- Tests before implementation, per Constitution Principle II (NON-NEGOTIABLE) — write
  the failing test, confirm it fails for the right reason, then write the minimum code
  to pass it, then refactor.
- Per ROADMAP.md's Implementation rules, `.gitignore` currently ignores everything
  except `.claude/`, `.specify/`, `specs/`, and itself — so `lib/` and
  `test/word_list_test.dart` stay untracked (present on disk, not committed) even after
  this feature is done. Only this `specs/002-word-list-loading/` directory's own files
  are trackable output of this task list today.
