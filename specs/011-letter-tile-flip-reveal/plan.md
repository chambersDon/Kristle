# Implementation Plan: Letter Tile Flip-Reveal Animation

**Branch**: `011-letter-tile-flip-reveal` | **Date**: 2026-09-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/011-letter-tile-flip-reveal/spec.md`

## Summary

Extend `LetterTile` to a `StatefulWidget` with a per-tile `_revealController`
(`AnimationController`, 450ms) and a `revealDelay` constructor parameter. On
construction, the controller starts at `0` if the initial status is `empty`, or `1`
(fully revealed, no animation) otherwise — satisfying "already scored on creation shows
immediately." In `didUpdateWidget`, a status change to `empty` snaps the controller to
`0` with no animation; a change to a scored status starts a `Timer` for `revealDelay`,
then calls `_revealController.forward(from: 0)`. The build method uses an
`AnimatedBuilder` to compute a rotation angle from the controller's progress (crossing
from the unscored `_TileFace` to the scored one at the halfway point) via
`Transform`/`rotateX`. `WordGrid` assigns each submitted row's tiles an increasing
`revealDelay` (`columnIndex * 110ms`) so the flip starts left-to-right. This plan
implements the animation slice of
[lib/widgets/letter_tile.dart](../../lib/widgets/letter_tile.dart) and the
`revealDelay` calculation in
[lib/widgets/word_grid.dart](../../lib/widgets/word_grid.dart) per ROADMAP.md item 11,
on top of the static tile (item 4) and grid (item 5).

## Technical Context

**Language/Version**: Dart, SDK `^3.11.5`

**Primary Dependencies**: Flutter SDK (`AnimationController`,
`SingleTickerProviderStateMixin`, `Timer`, `AnimatedBuilder`, `Transform`)

**Testing**: `flutter_test` widget tests using `tester.pump(Duration(...))` to advance
partway through the reveal delay and animation, reading the rendered face/rotation

**Target Platform**: All six configured Flutter targets (Constitution Principle IV)

**Constraints**: Must not change either static face's appearance (item 4) — only the
transition between them

**Scale/Scope**: `LetterTile`'s animation lifecycle and `WordGrid`'s per-tile delay
calculation; no new widgets

## Constitution Check

- **I. Layered Architecture** — PASS. Purely presentational; no game-rule logic.
- **II. Test-First Development** — PASS. Failing widget tests for delay-gating,
  staggered start order, and the two "no animation" cases (already-scored-on-creation,
  transition-to-empty) are written before implementation.
- **III. Immutable State** — N/A.
- **IV/V/VI** — PASS.

No violations.

## Project Structure

```text
lib/widgets/letter_tile.dart   # _revealController / didUpdateWidget / AnimatedBuilder
lib/widgets/word_grid.dart     # revealDelay calculation per submitted row
test/letter_tile_test.dart     # widget tests for the flip-reveal animation
```

**Structure Decision**: No new files; extends the existing tile/grid tests.

## Complexity Tracking

*No violations — table not applicable.*
