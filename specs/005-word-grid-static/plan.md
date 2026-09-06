# Implementation Plan: Word Grid (Static)

**Branch**: `005-word-grid-static` | **Date**: 2026-09-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/005-word-grid-static/spec.md`

## Summary

Implement a `WordGrid` widget that lays out a fixed 6×5 grid of `LetterTile`s: rows
before the current guess render each submitted guess's letters scored via
`GameEngine.scoreGuess` against the round's `answer`; the row at the current guess's
index renders its letters unscored; all remaining rows render empty tiles. Tile size is
computed from the available width and height (via `LayoutBuilder`), capped at a fixed
maximum, so the whole grid always fits its container. This plan implements
[lib/widgets/word_grid.dart](../../lib/widgets/word_grid.dart) per ROADMAP.md item 5,
building on the `LetterTile` widget (item 4) and `GameEngine` (item 3); the row-reveal
animation and shake feedback are out of scope (later roadmap items).

## Technical Context

**Language/Version**: Dart, SDK `^3.11.5` (per [pubspec.yaml](../../pubspec.yaml))

**Primary Dependencies**: Flutter SDK (`material.dart`, `LayoutBuilder`); this project's
own `GameEngine` and `LetterTile`

**Storage**: N/A — stateless presentation, no persistence

**Testing**: `flutter_test` widget tests (`testWidgets`) constructing `WordGrid` directly
with various `guesses`/`currentGuess` combinations and container sizes

**Target Platform**: All six configured Flutter targets — Android, iOS, web, Windows,
macOS, Linux (single codebase, per Constitution Principle IV)

**Project Type**: Mobile/desktop/web app (single Flutter package)

**Performance Goals**: Standard Flutter layout/build performance for a 30-tile grid; no
feature-specific performance target

**Constraints**: Must not introduce the reveal animation's staggered timing behavior or
the shake-on-invalid-submit feedback (later roadmap items) — this feature is strictly the
grid's static layout and per-row content selection

**Scale/Scope**: One widget (`WordGrid`), composed of 30 `LetterTile`s; no keyboard,
screen, or persistence logic in scope

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **I. Layered Architecture** — PASS. `WordGrid` lives in `lib/widgets/` and only
  arranges `LetterTile`s and calls `GameEngine.scoreGuess` (a service call, not inline
  scoring logic); it performs no persistence.
- **II. Test-First Development (NON-NEGOTIABLE)** — PASS. This feature requires writing
  failing widget tests for submitted/current/empty row rendering and responsive sizing
  before implementing `WordGrid`, then writing the minimum code to make them pass.
- **III. Immutable State & Defensive Serialization** — N/A. `WordGrid` holds no
  persisted state; its constructor parameters (`answer`, `guesses`, `currentGuess`) are
  plain immutable values passed in by its caller.
- **IV. Single Codebase, All Platforms** — PASS. Pure widget composition using
  `LayoutBuilder`, no `Platform.isX` branching.
- **V. Local-First, No Backend** — PASS. No network calls; purely local rendering.
- **VI. Lint-Clean, Analyzer-Enforced Style** — PASS. No new lint suppressions required.

No violations. Complexity Tracking is not needed.

## Project Structure

### Documentation (this feature)

```text
specs/005-word-grid-static/
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
│   ├── word_grid.dart        # WordGrid widget — this feature's subject
│   └── letter_tile.dart      # LetterTile — composed by WordGrid
└── services/
    └── game_engine.dart      # GameEngine.scoreGuess — used to score submitted rows

test/
└── word_grid_test.dart       # widget tests for WordGrid's static layout/content
```

**Structure Decision**: Single Flutter package at the repository root (`lib/`, `test/`),
per Constitution Principle IV and the "Naming" section (this project's `lib/` *is* its
`src/`). No new directories are needed for this feature; `WordGrid` lives in
`lib/widgets/`, alongside `LetterTile`.

## Complexity Tracking

*No Constitution Check violations — table not applicable.*
