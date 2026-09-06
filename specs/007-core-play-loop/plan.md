# Implementation Plan: Core Play Loop

**Branch**: `007-core-play-loop` | **Date**: 2026-09-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/007-core-play-loop/spec.md`

## Summary

Wire `WordList`, `GameEngine`, `WordGrid`, and `GameKeyboard` together in `GameScreen`:
on start, pick a random answer via `wordList.pickRandomAnswer`; `_addLetter`/
`_removeLetter` build the current guess (capped at 5 letters, no-op when empty on
backspace); `_submitGuess` rejects an incomplete guess or one not in
`wordList.isAllowedGuess` with an inline message, otherwise appends it to `_guesses`,
clears the current guess and message, and checks for a win (`guess == answer`) or a loss
(6 guesses reached), updating `_status`; once `_status != GameStatus.playing`, all three
entry actions become no-ops. This plan implements the relevant slice of
[lib/screens/game_screen.dart](../../lib/screens/game_screen.dart) per ROADMAP.md item 7,
building on the word list (item 2), scoring engine (item 3), word grid (item 5), and
on-screen keyboard (item 6); stats, persistence, animations, physical-keyboard input, the
answer-reveal helper, and the win-celebration overlay are out of scope (later roadmap
items already present elsewhere in the same file).

## Technical Context

**Language/Version**: Dart, SDK `^3.11.5` (per [pubspec.yaml](../../pubspec.yaml))

**Primary Dependencies**: Flutter SDK (`StatefulWidget`, `setState`); this project's own
`WordList`, `GameEngine`, `WordGrid`, `GameKeyboard`

**Storage**: N/A for this feature's scope — persisting round state/stats is a later
roadmap feature; this feature only manages in-memory round state for the lifetime of the
screen

**Testing**: `flutter_test` widget tests (`testWidgets`) pumping `GameScreen`/`KristleApp`
with a small test `WordList` and driving input via the on-screen keyboard

**Target Platform**: All six configured Flutter targets — Android, iOS, web, Windows,
macOS, Linux (single codebase, per Constitution Principle IV)

**Project Type**: Mobile/desktop/web app (single Flutter package)

**Performance Goals**: Standard Flutter interaction responsiveness; no feature-specific
performance target beyond immediate visual feedback on tap

**Constraints**: Must not introduce stats tracking, save/restore persistence, the
reveal/shake animations, physical-keyboard handling, the answer-reveal helper, or the
win-celebration overlay — this feature is strictly guess entry, submission validation,
and win/loss detection with post-round input lockout

**Scale/Scope**: The guess-entry/submission/win-loss slice of one screen
(`GameScreen`); no new widgets or services are introduced

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **I. Layered Architecture** — PASS. `GameScreen` (in `lib/screens/`) calls into
  `WordList`/`GameEngine` (services) and composes `WordGrid`/`GameKeyboard` (widgets); it
  performs no scoring or word-validation logic inline — both are delegated to the
  existing services.
- **II. Test-First Development (NON-NEGOTIABLE)** — PASS. This feature requires writing
  failing widget tests for guess entry, submission validation, and win/loss detection
  before implementing the corresponding `GameScreen` methods, then writing the minimum
  code to make them pass.
- **III. Immutable State & Defensive Serialization** — N/A for this feature's scope. No
  persisted model is read or written here; `_guesses`/`_currentGuess`/`_status` are
  transient `State` fields for the lifetime of the screen.
- **IV. Single Codebase, All Platforms** — PASS. No `Platform.isX` branching; identical
  behavior on every target.
- **V. Local-First, No Backend** — PASS. No network calls; the word list and scoring run
  entirely on-device.
- **VI. Lint-Clean, Analyzer-Enforced Style** — PASS. No new lint suppressions required.

No violations. Complexity Tracking is not needed.

## Project Structure

### Documentation (this feature)

```text
specs/007-core-play-loop/
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
├── screens/
│   └── game_screen.dart      # GameScreen — the guess-entry/submit/win-loss slice
├── services/
│   ├── word_list.dart        # WordList.pickRandomAnswer / isAllowedGuess
│   └── game_engine.dart      # GameEngine.scoreGuess (used by WordGrid)
└── widgets/
    ├── word_grid.dart        # WordGrid — renders live guesses/currentGuess
    └── game_keyboard.dart    # GameKeyboard — reports letter/backspace/submit taps

test/
└── widget_test.dart          # widget tests covering GameScreen's play loop
```

**Structure Decision**: Single Flutter package at the repository root (`lib/`, `test/`),
per Constitution Principle IV and the "Naming" section (this project's `lib/` *is* its
`src/`). No new directories are needed for this feature; the play loop lives in the
existing `GameScreen`, alongside (but independent of) the later features' code already
present in the same file.

## Complexity Tracking

*No Constitution Check violations — table not applicable.*
