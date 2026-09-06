# Phase 0 Research: Letter Tile Flip-Reveal Animation

## Decision: Initial controller value skips animation for pre-scored tiles

- **Decision**: `_revealController`'s initial `value` is `0` if the tile starts `empty`,
  else `1`.
- **Rationale**: Satisfies FR-004/SC-003 directly — a tile constructed already scored
  (e.g. restoring a saved game's completed rows) has no "before" state to animate from,
  so it should just render its final face immediately.
- **Alternatives considered**: Always starting at `0` and immediately jumping to `1` in
  `initState` — rejected as equivalent but more roundabout than setting the correct
  initial value directly.

## Decision: Delay via `Timer`, then `forward(from: 0)`

- **Decision**: A status change to a scored value in `didUpdateWidget` starts a `Timer`
  for `revealDelay` before calling `_revealController.forward(from: 0)`; a change to
  `empty` cancels any pending timer and sets the controller's value to `0` directly (no
  animation).
- **Rationale**: Satisfies FR-001/FR-002/FR-005 — the delay is what staggers tiles across
  a row (each with a different `revealDelay`), and `forward(from: 0)` guarantees a clean
  restart if a status changes again mid-flip (FR-006, edge case).
- **Alternatives considered**: A single `AnimationController` shared across delay and
  flip (e.g. mapping `[0, revealDelayFraction]` to "waiting" and the rest to the flip) —
  rejected as more complex than a plain `Timer` for the fixed pre-flip wait.

## Decision: Rotation and face-crossover via progress

- **Decision**: The build method reads `_revealController.value` as `progress`; the
  displayed face is the unscored face while `progress < 0.5` and the scored face once
  `progress >= 0.5`, with the `Transform`'s rotation angle computed so the tile appears
  to rotate a full half-turn and settle flat by `progress == 1`.
- **Rationale**: Satisfies FR-002 — crossing the face at the visual midpoint of the
  rotation (when the tile is edge-on and a face-swap is imperceptible) is the standard
  flip-card technique, avoiding any visible "pop" between faces.
- **Alternatives considered**: Cross-fading between faces instead of rotating — rejected
  as it doesn't match the "flip on its horizontal axis" behavior the spec calls for.

## Decision: Stagger via `columnIndex * 110ms` in `WordGrid`

- **Decision**: `WordGrid` computes `revealDelay` per cell as
  `Duration(milliseconds: columnIndex * 110)` for rows that are already submitted, and
  `Duration.zero` otherwise.
- **Rationale**: Satisfies FR-003/SC-001 — a fixed per-column increment guarantees
  strictly increasing start times left to right, without `WordGrid` needing any new
  state; it only needs to know a row is a "submitted" row, which it already knows from
  the play loop's `guesses` list.
- **Alternatives considered**: Passing a stagger config into `WordGrid` — rejected as
  unnecessary configurability for a fixed, already-decided visual interval.

## Decision: Testing approach

- **Decision**: `flutter_test` widget tests constructing `LetterTile` directly,
  transitioning its `status` via `tester.pumpWidget` with a new key-stable widget
  instance, and using `tester.pump(Duration(...))` to advance partway through the delay
  and animation, reading which face (`Text`/`DecoratedBox` color) is currently shown and
  the `Transform`'s rotation.
- **Rationale**: Exercises the actual `AnimationController`/`Timer` lifecycle
  (`didUpdateWidget`) the same way `WordGrid` triggers it in production, rather than
  reaching into private state.
- **Alternatives considered**: Testing only via the full `GameScreen` flow — rejected as
  slower and less precise for asserting exact timing/ordering than driving `LetterTile`
  directly (matches this project's established per-widget testing pattern from item 4).
