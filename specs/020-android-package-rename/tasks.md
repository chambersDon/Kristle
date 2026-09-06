---

description: "Task list template for feature implementation"
---

# Tasks: Android Package Rename

**Input**: Design documents from `/specs/020-android-package-rename/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [quickstart.md](quickstart.md)

**Tests**: N/A for this feature (Android build configuration and file layout, not
application logic — see [research.md](research.md)). Tasks below are verification
tasks against the Android project, per Constitution's Development Workflow.

## Phase 1: Setup

- [X] T001 Verify the Android target still builds (`flutter build apk` or
      `flutter analyze` at minimum) on the current working tree.

## Phase 2: User Story 1 - The Android app is identified by its real package (P3) 🎯 MVP

### Verification

- [X] T002 [P] [US1] Confirm `namespace` and `applicationId` in
      [android/app/build.gradle.kts](../../android/app/build.gradle.kts) are the real
      package name, not `com.example.my_wordle` (FR-001, acceptance scenario 1).
- [X] T003 [P] [US1] Confirm `MainActivity.kt` resolves under a directory path matching
      the real package, and that the old `com/example/my_wordle/` directory no longer
      exists (FR-002, acceptance scenario 2).
- [X] T004 [US1] Grep `android/` for any remaining reference to `com.example.my_wordle`
      (manifest, Gradle files, Kotlin source) and confirm there are none (FR-003, SC-002,
      acceptance scenario 3).

## Phase 3: Polish

- [X] T005 Run `flutter analyze` and the full `flutter test` suite and confirm both
      remain clean/passing (this feature makes no Dart source changes, so no
      regressions are expected).

## Notes

- This feature's "implementation" is Android platform file layout, which this task list
  does not modify (per ROADMAP.md's Implementation rules, no changes are made here
  beyond what T001–T004 verify against). If verification reveals a mismatch, that is a
  signal to correct the spec/plan, not to hand-edit the Android project outside a
  deliberate rename.
