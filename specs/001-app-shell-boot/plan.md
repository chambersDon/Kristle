# Implementation Plan: App Shell Boot

**Branch**: `001-app-shell-boot` | **Date**: 2026-09-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-app-shell-boot/spec.md`

## Summary

Launch the Flutter app directly into a single `MaterialApp` root (`KristleApp`) titled
"Kristle", themed with a Material 3 `ThemeData` built from `ColorScheme.fromSeed(seedColor:
Colors.green)`. This plan targets the exact existing implementation already present in
[lib/main.dart](../../lib/main.dart) — no new application code is introduced by this feature;
the app shell/theme is reproduced as-is per ROADMAP.md item 1.

## Technical Context

**Language/Version**: Dart, SDK `^3.11.5` (per [pubspec.yaml](../../pubspec.yaml))

**Primary Dependencies**: Flutter SDK (`material.dart`); no third-party packages required for
the shell/theme itself (`shared_preferences` and other deps exist in `pubspec.yaml` for later
features, not this one)

**Storage**: N/A — this feature has no persistence

**Testing**: `flutter_test` widget tests (`testWidgets`, `WidgetTester.pumpWidget`)

**Target Platform**: All six configured Flutter targets — Android, iOS, web, Windows, macOS,
Linux (single codebase, per Constitution Principle IV)

**Project Type**: Mobile/desktop/web app (single Flutter package)

**Performance Goals**: Standard Flutter cold-start expectations; no feature-specific
performance target beyond reaching the root screen without a visible unstyled flash

**Constraints**: Must not introduce gameplay logic, asset loading, or state management — this
feature is strictly the `MaterialApp` shell and `ThemeData` (title + `ColorScheme.fromSeed` +
`useMaterial3: true`)

**Scale/Scope**: One widget (`KristleApp`), one entry point (`main()`); no other screens,
services, or models are in scope

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **I. Layered Architecture** — PASS. `KristleApp` is presentation-only (a `StatelessWidget`
  building a `MaterialApp`); it contains no scoring, persistence, or word-list logic. It
  currently takes a `wordList` (and `enableAnswerReveal`) constructor parameter to hand to
  `GameScreen`, which belongs to later features (#2, #7, #17) — this plan does not change
  that signature, only reproduces the shell/theme portion of it.
- **II. Test-First Development (NON-NEGOTIABLE)** — PASS. This feature adds a widget test
  asserting the shell renders with the correct title and theme, written before confirming it
  passes against existing code (the code already exists; the test is written to lock in
  current behavior per the roadmap's "specs target existing code" rule).
- **III. Immutable State & Defensive Serialization** — N/A. No persisted model is introduced.
- **IV. Single Codebase, All Platforms** — PASS. `KristleApp`/`main()` contain no
  `Platform.isX` branching; identical widget tree on every target.
- **V. Local-First, No Backend** — PASS. No network calls; app boots fully offline.
- **VI. Lint-Clean, Analyzer-Enforced Style** — PASS. No new lint suppressions required.

No violations. Complexity Tracking is not needed.

## Project Structure

### Documentation (this feature)

```text
specs/001-app-shell-boot/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command) — N/A, no entities
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command) — N/A, no external interface
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
lib/
├── main.dart            # main() entry point + KristleApp (MaterialApp shell/theme) — existing
├── screens/
│   └── game_screen.dart # root `home:` widget — existing, later features (#7+) own its contents
└── config/
    └── app_config.dart  # compile-time toggles consumed by KristleApp — existing (feature #17)

test/
└── widget_test.dart     # existing integration-style widget tests (later features)
```

**Structure Decision**: Single Flutter package at the repository root (`lib/`, `test/`), per
Constitution Principle IV and the "Naming" section (this project's `lib/` *is* its `src/`).
No new directories are introduced by this feature; `KristleApp` stays defined in
[lib/main.dart](../../lib/main.dart) (the `lib/app.dart` file referenced by the roadmap's
original description is currently empty in the working tree — `main.dart` is the single
source of truth for the shell today, and this plan targets that reality).

## Complexity Tracking

*No Constitution Check violations — table not applicable.*
