---

description: "Task list template for feature implementation"
---

# Tasks: App Icons & Platform Metadata

**Input**: Design documents from `/specs/019-app-icons-platform-metadata/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [quickstart.md](quickstart.md)

**Tests**: N/A for this feature (platform build configuration and static assets, not
application logic — see [research.md](research.md)). Tasks below are verification
tasks against the built platform targets, per Constitution's Development Workflow.

## Phase 1: Setup

- [X] T001 Verify `flutter pub get` succeeds and `flutter_launcher_icons` is present as
      a dev dependency in `pubspec.yaml`.

## Phase 2: User Story 1 - The app shows its own icon and name on every platform (P2) 🎯 MVP

### Verification

- [X] T002 [P] [US1] Confirm `pubspec.yaml`'s `flutter_launcher_icons` config points at
      [assets/icon/kristle_icon.png](../../assets/icon/kristle_icon.png) for both
      `image_path` and `adaptive_icon_foreground`, with `adaptive_icon_background` set
      (FR-001, FR-003).
- [X] T003 [P] [US1] Build/inspect the Android target and confirm its launcher icon and
      display name are Kristle's (FR-001, FR-002, acceptance scenario 1).
- [X] T004 [P] [US1] Build/inspect the iOS target and confirm its home-screen icon and
      display name are Kristle's (FR-001, FR-002, acceptance scenario 2).
- [X] T005 [P] [US1] Build/inspect the web target and confirm its tab icon/title reflect
      Kristle's branding (FR-001, FR-002, acceptance scenario 3).
- [X] T006 [P] [US1] Build/inspect the Windows, macOS, and Linux targets and confirm
      their window/taskbar/dock icon and title reflect Kristle's branding (FR-001,
      FR-002, acceptance scenario 4).

## Phase 3: Polish

- [X] T007 Run `flutter analyze` and the full `flutter test` suite and confirm both
      remain clean/passing (this feature makes no Dart source changes, so no
      regressions are expected).

## Notes

- This feature's "implementation" is platform build configuration and generated
  binary/image assets, which this task list does not modify (per ROADMAP.md's
  Implementation rules, no source/config changes are made here beyond what T001–T006
  verify against). If verification reveals a mismatch, that is a signal to correct the
  spec/plan, not to hand-edit generated platform files outside the established
  `flutter_launcher_icons` workflow.
