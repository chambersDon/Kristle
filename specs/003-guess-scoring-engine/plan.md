# Implementation Plan: Guess Scoring Engine

**Branch**: `003-guess-scoring-engine` | **Date**: 2026-09-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/003-guess-scoring-engine/spec.md`

## Summary

Implement a `LetterStatus` enum (`empty`, `correct`, `present`, `absent`) and a
`GameEngine` service with a pure `scoreGuess({required guess, required answer})` method
that returns a `List<LetterStatus>`, one per letter position. Scoring runs a
correct-position pass first, tracking remaining per-letter counts from the answer's
unmatched positions in a map, then a present-elsewhere pass that only awards `present`
while a letter still has remaining count, capping duplicate-letter credit at what the
answer actually contains. Case is normalized to uppercase before comparison, and a
length mismatch between guess and answer raises an argument error immediately.

## Technical Context

**Language/Version**: Dart, SDK `^3.11.5` (per [pubspec.yaml](../../pubspec.yaml))

**Primary Dependencies**: None beyond the Dart SDK — pure computation, no Flutter/widget
dependency

**Storage**: N/A — no persistence, no external state

**Testing**: `flutter_test` unit tests (`test/game_engine_test.dart`) calling
`GameEngine().scoreGuess(...)` directly with literal guess/answer strings

**Target Platform**: All six configured Flutter targets — Android, iOS, web, Windows,
macOS, Linux (single codebase, per Constitution Principle IV); pure Dart logic runs
identically everywhere

**Project Type**: Mobile/desktop/web app (single Flutter package)

**Performance Goals**: O(word length) per scoring call; negligible for 5-letter words,
no feature-specific performance target beyond "instant" from the player's perspective

**Constraints**: Must remain a pure function with no side effects, no UI, and no
persistence — this feature is strictly the `LetterStatus` enum and `GameEngine.scoreGuess`

**Scale/Scope**: One enum (`LetterStatus`), one service class (`GameEngine`) with one
public method; no screens, widgets, or storage are in scope

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **I. Layered Architecture** — PASS. `GameEngine` lives in `lib/services/`, has a plain
  `const` constructor, and depends on nothing beyond `lib/models/game_state.dart`'s
  `LetterStatus` enum — directly instantiable in tests without a widget tree.
- **II. Test-First Development (NON-NEGOTIABLE)** — PASS. This feature requires writing
  failing unit tests in `test/game_engine_test.dart` for exact-match scoring,
  no-match scoring, present-elsewhere scoring, and duplicate-letter scoring (both
  correct-before-present and answer-limited-count cases) before implementing
  `GameEngine.scoreGuess`, then writing the minimum code to make them pass.
- **III. Immutable State & Defensive Serialization** — N/A. `GameEngine` and
  `LetterStatus` hold no persisted state; there is nothing to serialize or defend against
  malformed storage.
- **IV. Single Codebase, All Platforms** — PASS. Pure Dart computation with no
  `Platform.isX` branching.
- **V. Local-First, No Backend** — PASS. No network calls; scoring runs entirely
  on-device and synchronously.
- **VI. Lint-Clean, Analyzer-Enforced Style** — PASS. No new lint suppressions required.

No violations. Complexity Tracking is not needed.

## Project Structure

### Documentation (this feature)

```text
specs/003-guess-scoring-engine/
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
├── models/
│   └── game_state.dart       # LetterStatus (and GameStatus) enums
└── services/
    └── game_engine.dart      # GameEngine.scoreGuess

test/
└── game_engine_test.dart     # unit tests for GameEngine.scoreGuess
```

**Structure Decision**: Single Flutter package at the repository root (`lib/`, `test/`),
per Constitution Principle IV and the "Naming" section (this project's `lib/` *is* its
`src/`). No new directories are needed for this feature; `GameEngine` lives in
`lib/services/`, alongside the project's other services, and `LetterStatus` lives in
`lib/models/game_state.dart` alongside the game's other small enums.

## Complexity Tracking

*No Constitution Check violations — table not applicable.*
