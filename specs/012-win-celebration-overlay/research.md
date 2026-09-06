# Phase 0 Research: Win Celebration Overlay

## Decision: Two chained `Timer`s

- **Decision**: `_scheduleWinImage()` starts a show-delay `Timer`; its callback sets
  `_showWinImage = true` and starts a second hide-delay `Timer` whose callback sets it
  back to `false`.
- **Rationale**: Satisfies FR-001/FR-003 with the simplest possible mechanism — two
  plain timers directly express "wait, then show, then wait, then hide," with no
  animation curve or extra state needed.
- **Alternatives considered**: A single `AnimationController` with a custom timeline —
  rejected as unnecessary complexity for a simple show/hide toggle with no visual
  transition of its own (the image just appears/disappears).

## Decision: `errorBuilder` for the fallback

- **Decision**: `Image.asset(..., errorBuilder: (context, error, stackTrace) => ...)`
  renders a "You Won!" `Text` styled box in place of the image on load failure.
- **Rationale**: `errorBuilder` is Flutter's standard mechanism for image-load fallback,
  satisfying FR-005 without needing to pre-check asset availability manually.
- **Alternatives considered**: Pre-checking the asset's existence before deciding what to
  render — rejected as more complex and still subject to the same runtime failure modes
  `errorBuilder` already handles.

## Decision: Cancel timers on new game and re-win

- **Decision**: `_cancelWinImageTimers()` (canceling both timers) is called from
  `_startNewGame()` and at the start of `_scheduleWinImage()` itself.
- **Rationale**: Satisfies FR-006/edge case — starting a new game while a celebration is
  pending or showing must not let a stale timer fire later during the new round; calling
  it again at the start of `_scheduleWinImage()` guards against any theoretical
  re-entrant scheduling.
- **Alternatives considered**: Guarding with an `if (mounted)` check alone — insufficient,
  since the widget stays mounted across a new game; the timers themselves must be
  explicitly canceled.

## Decision: Testing approach

- **Decision**: `flutter_test` widget tests winning a round, then using
  `tester.pump(Duration(...))` at each key point (immediately, after the show delay,
  after the hide duration) to assert overlay presence/absence via a
  `find.byWidgetPredicate` matching the `you_won.png` `AssetImage`; a separate test wins
  via a loss path and confirms the overlay predicate never matches.
- **Rationale**: Matches this project's existing win-image test pattern
  (`findWinImage()` in `test/widget_test.dart`) and directly observes the
  externally-visible timing behavior.
- **Alternatives considered**: Asserting on `_showWinImage` directly — not possible
  (private state); the rendered widget tree is the externally-observable equivalent.
