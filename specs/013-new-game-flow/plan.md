# Implementation Plan: New Game Flow

**Branch**: `013-new-game-flow` | **Date**: 2026-09-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/013-new-game-flow/spec.md`

## Summary

Show a "New Game" `FilledButton` in the message row whenever `_status != playing`, wired
to `_startNewGame()`, which resets `_answer` (via `wordList.pickRandomAnswer`), clears
`_guesses`/`_currentGuess`/`_message`, sets `_status = playing`, resets
`_headerTapCount`/`_answerTapCount`/`_isAnswerRevealed`, and cancels any pending win-image
timers. Since the on-screen keyboard's key colors (item 8) are derived entirely from
`_guesses`, clearing `_guesses` resets them automatically with no separate logic needed.
This plan implements `_startNewGame` and its message-row trigger in
[lib/screens/game_screen.dart](../../lib/screens/game_screen.dart) per ROADMAP.md item
13.

## Technical Context

**Language/Version**: Dart, SDK `^3.11.5`

**Primary Dependencies**: This project's own `WordList.pickRandomAnswer`

**Testing**: `flutter_test` widget tests ending a round, tapping "New Game," and
asserting every piece of state is reset

**Target Platform**: All six configured Flutter targets (Constitution Principle IV)

**Constraints**: Must not introduce persistence of the new round (later roadmap
feature) — purely an in-memory state reset

**Scale/Scope**: One method (`_startNewGame`) and its conditional trigger button in
`GameScreen`

## Constitution Check

- **I. Layered Architecture** — PASS. `_startNewGame` calls `WordList.pickRandomAnswer`
  (a service) and resets plain `State` fields; no scoring/persistence logic inline.
- **II. Test-First Development** — PASS. Failing widget tests for the control's
  visibility and each reset aspect are written before implementation.
- **III. Immutable State** — N/A.
- **IV/V/VI** — PASS.

No violations.

## Project Structure

```text
lib/screens/game_screen.dart   # _startNewGame / "New Game" control
test/widget_test.dart          # widget tests for the new-game reset
```

**Structure Decision**: No new files.

## Complexity Tracking

*No violations — table not applicable.*
