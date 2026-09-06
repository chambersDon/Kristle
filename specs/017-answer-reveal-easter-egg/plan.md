# Implementation Plan: Answer-Reveal Easter Egg

**Branch**: `017-answer-reveal-easter-egg` | **Date**: 2026-09-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/017-answer-reveal-easter-egg/spec.md`

## Summary

Add `AppConfig.enableAnswerReveal` (`bool.fromEnvironment`, default `true`) and, in
`GameScreen`, `_handleHeaderTap()`: a no-op if `widget.enableAnswerReveal` is false;
otherwise increments `_headerTapCount` (revealing at 5, resetting `_answerTapCount`) or,
if already revealed, increments `_answerTapCount` (hiding and resetting both counters at
5). `_startNewGame()` resets `_headerTapCount`/`_answerTapCount`/`_isAnswerRevealed` to
their initial values. The app bar's title `GestureDetector` swaps between the header
`Image.asset` and the answer `Text` based on `_isAnswerRevealed`. This plan implements
[lib/config/app_config.dart](../../lib/config/app_config.dart) and the
`_handleHeaderTap`/reveal-state slice of
[lib/screens/game_screen.dart](../../lib/screens/game_screen.dart) per ROADMAP.md item
17.

## Technical Context

**Language/Version**: Dart, SDK `^3.11.5`

**Primary Dependencies**: `bool.fromEnvironment` (Dart compile-time constant)

**Testing**: `flutter_test` widget tests tapping the header/revealed-answer text and
pumping `KristleApp` with `enableAnswerReveal: false`

**Target Platform**: All six configured Flutter targets (Constitution Principle IV)

**Constraints**: Must be fully compiled out (no runtime cost) when disabled, per
Constitution's Technology Stack section on `bool.fromEnvironment` toggles

**Scale/Scope**: One config constant and the tap-counting/reveal-state slice of
`GameScreen`

## Constitution Check

- **I. Layered Architecture** — PASS. `AppConfig` is a plain constant holder in
  `lib/config/`; `GameScreen` reads it and its own `widget.enableAnswerReveal` parameter.
- **II. Test-First Development** — PASS. Failing widget tests for reveal, hide, disabled,
  and new-game-reset behavior are written before implementation.
- **III. Immutable State** — N/A.
- **IV. Single Codebase, All Platforms** — PASS. Uses `bool.fromEnvironment`, not
  per-platform branching, per Constitution's explicit guidance for this toggle.
- **V/VI** — PASS.

No violations.

## Project Structure

```text
lib/config/app_config.dart     # enableAnswerReveal
lib/screens/game_screen.dart   # _handleHeaderTap / reveal state / _startNewGame reset
test/widget_test.dart          # widget tests for the reveal/hide/disable/reset behavior
```

**Structure Decision**: No new files.

## Complexity Tracking

*No violations — table not applicable.*
