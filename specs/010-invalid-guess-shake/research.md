# Phase 0 Research: Invalid-Guess Shake Feedback

## Decision: Restart via `forward(from: 0)`

- **Decision**: `_shakeGrid()` calls `_shakeController.forward(from: 0)` on every
  rejection, rather than only starting the controller if it's idle.
- **Rationale**: Satisfies FR-004 — restarting from 0 every time guarantees a clean,
  consistent shake even if the previous one hasn't finished, with no need to track
  whether an animation is already running.
- **Alternatives considered**: Ignoring a new trigger while one is in progress —
  rejected because a rapid second rejection (edge case) would then show no feedback at
  all for that attempt.

## Decision: Oscillating, decaying translation

- **Decision**: `ShakeTransition` maps animation progress to a direction that flips sign
  across several segments, scaled by `(1 - progress)` so the amplitude decays to zero by
  the end.
- **Rationale**: Produces a shake that clearly moves side-to-side and settles back to
  center on its own (FR-003), without needing a separate "return to zero" step.
- **Alternatives considered**: A single left-then-right motion — rejected as a less
  convincing "shake" feel than several decaying oscillations.

## Decision: Testing approach

- **Decision**: `flutter_test` widget tests that trigger a rejection, advance the clock
  partway through the shake duration (`tester.pump(Duration(milliseconds: ...))`), and
  read the `Transform` ancestor of `WordGrid` to assert a non-zero horizontal
  translation; a separate test asserts no such non-zero translation after a successful
  submission.
- **Rationale**: Directly observes the visual effect the spec describes, at the same
  level this project's other animation-adjacent tests already operate.
- **Alternatives considered**: Asserting on `_shakeController.status`/`value` directly —
  not possible from outside the widget (private state); reading the rendered transform is
  the externally-observable equivalent.
