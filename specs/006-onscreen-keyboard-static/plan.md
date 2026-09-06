# Implementation Plan: On-Screen Keyboard (Static)

**Branch**: `006-onscreen-keyboard-static` | **Date**: 2026-09-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/006-onscreen-keyboard-static/spec.md`

## Summary

Implement a `GameKeyboard` widget rendering the standard three-row QWERTY layout (26
letter keys plus a backspace key) and a submit control below it, sized to fit the
available width. Tapping a letter invokes an `onLetterTap(String)` callback; tapping
backspace invokes `onBackspaceTap()`; the submit control is enabled only when a
caller-supplied `canSubmit` flag is true, and tapping it while enabled invokes
`onEnterTap()`. Every letter key uses one single default color — no per-key status
coloring. This plan implements
[lib/widgets/game_keyboard.dart](../../lib/widgets/game_keyboard.dart) per ROADMAP.md
item 6; per-key status coloring is out of scope (later roadmap item).

## Technical Context

**Language/Version**: Dart, SDK `^3.11.5` (per [pubspec.yaml](../../pubspec.yaml))

**Primary Dependencies**: Flutter SDK (`material.dart`, `LayoutBuilder`, `FilledButton`)
only — no third-party packages

**Storage**: N/A — stateless presentation, no persistence

**Testing**: `flutter_test` widget tests (`testWidgets`) constructing `GameKeyboard`
directly with fake callbacks and varying `canSubmit`/container-width values

**Target Platform**: All six configured Flutter targets — Android, iOS, web, Windows,
macOS, Linux (single codebase, per Constitution Principle IV)

**Project Type**: Mobile/desktop/web app (single Flutter package)

**Performance Goals**: Standard Flutter layout/build performance for a ~30-key
keyboard; no feature-specific performance target

**Constraints**: Must not introduce per-key status coloring (later roadmap item) — every
letter key uses the same single default color in this feature

**Scale/Scope**: One widget (`GameKeyboard`); no screen, engine, or persistence logic in
scope

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **I. Layered Architecture** — PASS. `GameKeyboard` lives in `lib/widgets/` and is
  purely presentational — it reports taps via callbacks and holds no game state or
  scoring logic itself.
- **II. Test-First Development (NON-NEGOTIABLE)** — PASS. This feature requires writing
  failing widget tests for the QWERTY layout, letter/backspace/submit callbacks, and the
  submit control's enabled state before implementing `GameKeyboard`, then writing the
  minimum code to make them pass.
- **III. Immutable State & Defensive Serialization** — N/A. `GameKeyboard` holds no
  persisted state; its constructor parameters (callbacks, `canSubmit`) are plain
  immutable values passed in by its caller.
- **IV. Single Codebase, All Platforms** — PASS. Pure widget composition using
  `LayoutBuilder`, no `Platform.isX` branching.
- **V. Local-First, No Backend** — PASS. No network calls; purely local rendering and
  callback reporting.
- **VI. Lint-Clean, Analyzer-Enforced Style** — PASS. No new lint suppressions required.

No violations. Complexity Tracking is not needed.

## Project Structure

### Documentation (this feature)

```text
specs/006-onscreen-keyboard-static/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command) — N/A, no external interface
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
lib/
├── widgets/
│   └── game_keyboard.dart    # GameKeyboard widget — this feature's subject
└── theme/
    └── game_colors.dart      # default key color constant

test/
└── game_keyboard_test.dart   # widget tests for GameKeyboard's static layout/behavior
```

**Structure Decision**: Single Flutter package at the repository root (`lib/`, `test/`),
per Constitution Principle IV and the "Naming" section (this project's `lib/` *is* its
`src/`). No new directories are needed for this feature; `GameKeyboard` lives in
`lib/widgets/`, alongside the project's other presentation widgets.

## Complexity Tracking

*No Constitution Check violations — table not applicable.*
