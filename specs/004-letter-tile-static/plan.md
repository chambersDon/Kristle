# Implementation Plan: Letter Tile (Static)

**Branch**: `004-letter-tile-static` | **Date**: 2026-09-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/004-letter-tile-static/spec.md`

## Summary

Implement a `LetterTile` widget that renders a single square cell for one letter,
showing an outlined/bordered style with no fill when its status is `empty` (unscored),
and a solid background fill color (green/yellow/gray) with white letter text when scored
`correct`/`present`/`absent`. The tile is always a perfect square (`AspectRatio(1)`), and
an unscored tile with a typed letter uses a more prominent border than a fully empty one.
This plan implements the tile's appearance in
[lib/widgets/letter_tile.dart](../../lib/widgets/letter_tile.dart) and the shared color
palette in [lib/theme/game_colors.dart](../../lib/theme/game_colors.dart) per ROADMAP.md
item 4; the reveal/flip transition between unscored and scored states is out of scope
(later roadmap item).

## Technical Context

**Language/Version**: Dart, SDK `^3.11.5` (per [pubspec.yaml](../../pubspec.yaml))

**Primary Dependencies**: Flutter SDK (`material.dart`) only — no third-party packages

**Storage**: N/A — stateless presentation, no persistence

**Testing**: `flutter_test` widget tests (`testWidgets`, `WidgetTester.pumpWidget`)
constructing `LetterTile` directly with each letter/status combination

**Target Platform**: All six configured Flutter targets — Android, iOS, web, Windows,
macOS, Linux (single codebase, per Constitution Principle IV)

**Project Type**: Mobile/desktop/web app (single Flutter package)

**Performance Goals**: Standard Flutter build/paint performance for a single small
widget; no feature-specific performance target

**Constraints**: Must not introduce the flip/reveal animation or staggered timing across
a row (later roadmap item) — this feature is strictly the tile's static appearance per
letter/status combination

**Scale/Scope**: One widget (`LetterTile`) and its color constants
(`lib/theme/game_colors.dart`); no grid, keyboard, or screen logic in scope

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **I. Layered Architecture** — PASS. `LetterTile` lives in `lib/widgets/` and contains
  only presentation logic (color/border selection based on the `LetterStatus` it is
  given); it performs no scoring or persistence itself.
- **II. Test-First Development (NON-NEGOTIABLE)** — PASS. This feature requires writing
  failing widget tests for each letter/status combination (colors, borders, letter text)
  before implementing the tile's static rendering, then writing the minimum code to make
  them pass.
- **III. Immutable State & Defensive Serialization** — N/A. `LetterTile` holds no
  persisted state; its constructor parameters (`letter`, `status`) are plain immutable
  values.
- **IV. Single Codebase, All Platforms** — PASS. Pure widget composition, no
  `Platform.isX` branching.
- **V. Local-First, No Backend** — PASS. No network calls; purely local rendering.
- **VI. Lint-Clean, Analyzer-Enforced Style** — PASS. No new lint suppressions required.

No violations. Complexity Tracking is not needed.

## Project Structure

### Documentation (this feature)

```text
specs/004-letter-tile-static/
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
│   └── letter_tile.dart      # LetterTile widget — this feature's subject
└── theme/
    └── game_colors.dart      # shared status color constants

test/
└── letter_tile_test.dart     # widget tests for LetterTile's static appearance
```

**Structure Decision**: Single Flutter package at the repository root (`lib/`, `test/`),
per Constitution Principle IV and the "Naming" section (this project's `lib/` *is* its
`src/`). No new directories are needed for this feature; `LetterTile` lives in
`lib/widgets/`, alongside the project's other presentation widgets, and reads its colors
from `lib/theme/game_colors.dart`.

## Complexity Tracking

*No Constitution Check violations — table not applicable.*
