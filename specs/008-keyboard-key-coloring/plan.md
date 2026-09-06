# Implementation Plan: Keyboard Key-Status Coloring

**Branch**: `008-keyboard-key-coloring` | **Date**: 2026-09-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/008-keyboard-key-coloring/spec.md`

## Summary

Compute a `Map<String, LetterStatus>` in `GameScreen` (`_keyStatuses`) by scoring every
submitted guess via `GameEngine.scoreGuess` and, for each letter, keeping the
highest-ranked status seen (`correct` > `present` > `absent` > unscored) via a small
`_statusRank` helper, then pass that map to `GameKeyboard`'s existing `keyStatuses`
parameter. This plan implements the `_keyStatuses`/`_statusRank` slice of
[lib/screens/game_screen.dart](../../lib/screens/game_screen.dart) per ROADMAP.md item 8,
building on the scoring engine (item 3) and on-screen keyboard (item 6), which already
renders whatever `keyStatuses` map it is given.

## Technical Context

**Language/Version**: Dart, SDK `^3.11.5`

**Primary Dependencies**: This project's own `GameEngine`, `GameKeyboard`

**Storage**: N/A

**Testing**: `flutter_test` widget tests pumping `GameScreen` and submitting guess
sequences, asserting key colors via `GameKeyboard`'s rendered `FilledButton` styles

**Target Platform**: All six configured Flutter targets (Constitution Principle IV)

**Project Type**: Mobile/desktop/web app (single Flutter package)

**Constraints**: Must not change scoring or keyboard rendering — only compute and supply
the per-letter status map

**Scale/Scope**: One computed property (`_keyStatuses`) and helper (`_statusRank`) in
`GameScreen`

## Constitution Check

- **I. Layered Architecture** — PASS. `_keyStatuses` calls `GameEngine.scoreGuess` (a
  service) rather than re-implementing scoring.
- **II. Test-First Development** — PASS. Failing widget tests are written for
  rank-preservation and never-downgrades behavior before implementation.
- **III. Immutable State** — N/A, no persisted model.
- **IV/V/VI** — PASS, no platform branching, no network calls, no lint suppressions.

No violations.

## Project Structure

```text
lib/screens/game_screen.dart   # _keyStatuses / _statusRank — this feature's subject
test/widget_test.dart          # widget tests for keyboard coloring through live play
```

**Structure Decision**: No new files; the computation lives alongside the rest of
`GameScreen`'s play-loop state.

## Complexity Tracking

*No violations — table not applicable.*
