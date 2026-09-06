# Implementation Plan: Invalid-Guess Shake Feedback

**Branch**: `010-invalid-guess-shake` | **Date**: 2026-09-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/010-invalid-guess-shake/spec.md`

## Summary

Add a `ShakeTransition` widget wrapping the `WordGrid`, driven by an
`AnimationController` (`_shakeController`) that `_shakeGrid()` restarts via
`forward(from: 0)` whenever `_submitGuess` rejects a guess (length or allowed-guess
failure). `ShakeTransition` translates its child horizontally by an oscillating,
decaying offset derived from the animation's progress, settling back to zero
translation when the animation completes. This plan implements
`ShakeTransition`/`_shakeController`/`_shakeGrid` in
[lib/screens/game_screen.dart](../../lib/screens/game_screen.dart) per ROADMAP.md item
10, triggered from the rejection branches the core play loop (item 7) already contains.

## Technical Context

**Language/Version**: Dart, SDK `^3.11.5`

**Primary Dependencies**: Flutter SDK (`AnimationController`, `AnimatedBuilder`,
`Transform.translate`, `TickerProviderStateMixin`)

**Testing**: `flutter_test` widget tests pumping partial animation frames
(`tester.pump(Duration(...))`) and reading the rendered `Transform`'s translation

**Target Platform**: All six configured Flutter targets (Constitution Principle IV)

**Constraints**: Must not change what counts as a valid/invalid guess — purely a visual
response to a rejection decision the play loop already makes

**Scale/Scope**: One animation controller and one small transition widget in
`GameScreen`

## Constitution Check

- **I. Layered Architecture** — PASS. `ShakeTransition` is presentation-only; it reads
  an `Animation<double>` and translates its child, with no game-rule logic.
- **II. Test-First Development** — PASS. Failing widget tests are written for
  shake-on-reject and no-shake-on-success before implementation.
- **III. Immutable State** — N/A.
- **IV/V/VI** — PASS.

No violations.

## Project Structure

```text
lib/screens/game_screen.dart   # ShakeTransition / _shakeController / _shakeGrid
test/widget_test.dart          # widget tests for shake-on-reject behavior
```

**Structure Decision**: No new files.

## Complexity Tracking

*No violations — table not applicable.*
