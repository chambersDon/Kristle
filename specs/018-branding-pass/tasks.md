---

description: "Task list template for feature implementation"
---

# Tasks: Branding Pass

**Input**: Design documents from `/specs/018-branding-pass/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [quickstart.md](quickstart.md)

**Tests**: Required by Constitution Principle II. Write the failing widget test(s)
first, confirm they fail, then implement the branding elements in
`lib/screens/game_screen.dart` to make them pass.

## Phase 1: Setup

- [X] T001 Verify `flutter pub get`/`flutter analyze` are clean on the working tree, and
      confirm [assets/kristle_header.png](../../assets/kristle_header.png) is declared
      under `pubspec.yaml`'s `flutter.assets`.

## Phase 2: User Story 1 - The app displays branded header art (P2) 🎯 MVP

### Tests ⚠️

- [X] T002 [US1] In `test/widget_test.dart`, add/confirm a test that the app bar shows
      the header image (`find.byKey(const Key('header-image'))`) rather than a plain
      text title (FR-001, SC-001, acceptance scenario 1).
- [X] T003 [US1] Run `flutter test test/widget_test.dart` and confirm T002 fails for the
      expected reason before implementing.

### Implementation

- [X] T004 [US1] Implement the header-image app bar title in
      [lib/screens/game_screen.dart](../../lib/screens/game_screen.dart) (FR-001). Run
      `flutter test test/widget_test.dart` and confirm T002 now passes.

## Phase 3: User Story 2 - A placeholder ad slot is reserved at the bottom (P3)

### Tests ⚠️

- [X] T005 [US2] In `test/widget_test.dart`, add a test that a placeholder bar is
      present at the bottom of the screen and has no tappable ancestor
      (`GestureDetector`/`InkWell`) (FR-002, FR-003, SC-002, acceptance scenario 1).
- [X] T006 [US2] Run `flutter test test/widget_test.dart` and confirm T005 fails for the
      expected reason before implementing.

### Implementation

- [X] T007 [US2] Implement the inert bottom placeholder `Container` in
      [lib/screens/game_screen.dart](../../lib/screens/game_screen.dart) (FR-002,
      FR-003). Run `flutter test test/widget_test.dart` and confirm T005 now passes.

## Phase 4: Polish

- [X] T008 Run `flutter analyze` and the full `flutter test` suite and confirm both are
      clean/passing.

## Notes

- No `lib/` changes are expected beyond what T004/T007 verify against;
  `test/widget_test.dart` stays untracked per ROADMAP.md's Implementation rules.
