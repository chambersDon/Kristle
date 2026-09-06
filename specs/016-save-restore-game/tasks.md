---

description: "Task list template for feature implementation"
---

# Tasks: Save & Restore In-Progress Game

**Input**: Design documents from `/specs/016-save-restore-game/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [quickstart.md](quickstart.md)

**Tests**: Required by Constitution Principle II. Write the failing test(s) first,
confirm they fail, then implement `SavedGame`, `GameStorage.loadGame`/`saveGame`, and
the `GameScreen` save/restore wiring to make them pass.

## Phase 1: Setup

- [X] T001 Verify `flutter pub get`/`flutter analyze` are clean on the working tree.

## Phase 2: User Story 1 - Closing and reopening the app resumes the same round (P1) 🎯 MVP

### Tests ⚠️

- [X] T002 [P] [US1] In `test/game_storage_test.dart`, add/confirm a test that a
      well-formed `SavedGame` round-trips exactly through `saveGame`/`loadGame`
      (FR-001, FR-002, acceptance scenario 1).
- [X] T003 [P] [US1] In `test/game_storage_test.dart`, add a test that `loadGame`
      returns `null` when nothing has been saved (acceptance scenario 3 support).
- [X] T004 [P] [US1] In `test/widget_test.dart`, add/confirm a test that a structurally
      valid saved game is restored on launch, showing its saved guesses/current guess
      (FR-003, acceptance scenario 2) — the existing "restores a saved game" test
      already covers this.
- [X] T005 [US1] Run `flutter test test/game_storage_test.dart test/widget_test.dart`
      and confirm T002–T003 fail for the expected reason before implementing.

### Implementation

- [X] T006 [US1] Implement `SavedGame.toJson`/basic `fromJson` and
      `GameStorage.loadGame`/`saveGame` in
      [lib/models/saved_game.dart](../../lib/models/saved_game.dart) and
      [lib/services/game_storage.dart](../../lib/services/game_storage.dart)
      (FR-001, FR-002). Wire `_saveCurrentGame`/`_loadSavedData` in
      [lib/screens/game_screen.dart](../../lib/screens/game_screen.dart). Run
      `flutter test test/game_storage_test.dart test/widget_test.dart` and confirm
      T002–T004 now pass.

## Phase 3: User Story 2 - A corrupted or invalid save never breaks the app (P1)

### Tests ⚠️

- [X] T007 [P] [US2] In `test/widget_test.dart`, add a test that a saved game with a
      wrong-length answer results in a fresh round starting instead of restoring it
      (FR-003, acceptance scenario 1).
- [X] T008 [P] [US2] In `test/widget_test.dart`, add a test that a saved game with more
      guesses than the maximum allowed results in a fresh round starting (FR-003,
      acceptance scenario 2).
- [X] T009 [P] [US2] In `test/widget_test.dart`, add a test that a saved game with an
      over-long current guess results in a fresh round starting (FR-003, acceptance
      scenario 3).
- [X] T010 [P] [US2] In a new `test/saved_game_test.dart`, add tests that
      `SavedGame.fromJson` falls back to safe defaults for missing fields, wrong-typed
      fields, and an unrecognized `status` value, without throwing (FR-005, acceptance
      scenario 4).
- [X] T011 [US2] Run `flutter test test/widget_test.dart test/saved_game_test.dart` and
      confirm T007–T010 fail for the expected reason before implementing.

### Implementation

- [X] T012 [US2] Implement `_isValidSavedGame` in
      [lib/screens/game_screen.dart](../../lib/screens/game_screen.dart) (FR-003,
      FR-004) and the defensive-parsing branches of `SavedGame.fromJson` in
      [lib/models/saved_game.dart](../../lib/models/saved_game.dart) (FR-005). Run
      `flutter test test/widget_test.dart test/saved_game_test.dart` and confirm
      T007–T010 now pass.

## Phase 4: Polish

- [X] T013 Run `flutter analyze` and the full `flutter test` suite and confirm both are
      clean/passing.

## Notes

- No `lib/` changes are expected beyond what T006/T012 verify against; test files stay
  untracked per ROADMAP.md's Implementation rules.
