# Implementation Plan: Win Celebration Overlay

**Branch**: `012-win-celebration-overlay` | **Date**: 2026-09-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/012-win-celebration-overlay/spec.md`

## Summary

On a win, `_scheduleWinImage()` starts a 1-second `Timer` (`_winImageShowTimer`) that
sets `_showWinImage = true` and starts a second 2-second `Timer`
(`_winImageHideTimer`) that sets it back to `false`. The board's `Stack` conditionally
overlays a full-width `Image.asset('assets/you_won.png', ...)` when `_showWinImage` is
true, with an `errorBuilder` rendering a "You Won!" text fallback if the asset fails to
load. `_startNewGame()` and `_submitGuess`'s win branch both call
`_cancelWinImageTimers()` first to clear any pending/in-progress timers. This plan
implements the `_scheduleWinImage`/`_showWinImage`/`_cancelWinImageTimers` slice of
[lib/screens/game_screen.dart](../../lib/screens/game_screen.dart) per ROADMAP.md item
12, triggered from the win branch the core play loop (item 7) already contains.

## Technical Context

**Language/Version**: Dart, SDK `^3.11.5`

**Primary Dependencies**: Flutter SDK (`Timer`, `Image.asset`, `errorBuilder`)

**Testing**: `flutter_test` widget tests using `tester.pump(Duration(...))` to advance
past the show/hide delays, and `AssetImage`-predicate finders for the overlay

**Target Platform**: All six configured Flutter targets (Constitution Principle IV)

**Constraints**: Must not change win/loss detection (item 7) or "New Game" reset (item
13) beyond canceling this feature's own timers

**Scale/Scope**: Two `Timer`s and a conditional overlay widget in `GameScreen`

## Constitution Check

- **I. Layered Architecture** — PASS. Purely presentational timing/overlay logic; no
  game-rule decisions.
- **II. Test-First Development** — PASS. Failing widget tests for delay, auto-hide,
  no-overlay-on-loss, and the fallback are written before implementation.
- **III. Immutable State** — N/A.
- **IV/V/VI** — PASS.

No violations.

## Project Structure

```text
lib/screens/game_screen.dart   # _scheduleWinImage / _showWinImage / timers
test/widget_test.dart          # widget tests for the celebration overlay
```

**Structure Decision**: No new files.

## Complexity Tracking

*No violations — table not applicable.*
