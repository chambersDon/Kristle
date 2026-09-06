# Phase 0 Research: Word Grid (Static)

No `NEEDS CLARIFICATION` markers remain in the Technical Context — the decisions below
resolve every open design question for the static `WordGrid` layout before
implementation begins.

## Decision: Per-row content selection

- **Decision**: For row index `r`: if `r < guesses.length`, use `guesses[r]` scored via
  `GameEngine.scoreGuess`; if `r == guesses.length`, use `currentGuess` unscored; otherwise
  render an empty row.
- **Rationale**: A single index comparison per row directly encodes the three row kinds
  the spec requires (submitted/current/empty) without needing separate widgets or state
  for "which kind of row is this."
- **Alternatives considered**: Pre-computing three separate lists (submitted rows,
  current row, empty rows) and concatenating them — rejected as more bookkeeping for the
  same result; the index-based approach reads directly from `List.generate`.

## Decision: Tile sizing strategy

- **Decision**: Use a `LayoutBuilder` to read available width/height, compute a
  width-based tile size (available width minus inter-tile gaps, divided by 5, capped at a
  maximum) and a height-based tile size (available height minus inter-row gaps, divided
  by 6, capped at the same maximum), then take the smaller of the two.
- **Rationale**: Satisfies FR-005/FR-006/SC-004 — the grid must never overflow either
  dimension, so the more restrictive of width- or height-derived sizing wins, and the cap
  keeps tiles from growing absurdly large on big screens.
- **Alternatives considered**: Sizing tiles purely from width (ignoring height) — rejected
  because a short/landscape container would then let the grid overflow vertically, which
  the spec's height edge case explicitly rules out.

## Decision: Composing `LetterTile`

- **Decision**: `WordGrid` builds `List.generate(6, ...)` rows, each a `Row` of
  `List.generate(5, ...)` `LetterTile`s, each in a `SizedBox.square(dimension: tileSize)`.
- **Rationale**: Reuses `LetterTile`'s own static rendering (letter/status → appearance)
  entirely as-is — `WordGrid`'s only job is deciding *which* letter and status each tile
  gets and *how big* it is, keeping a clean layering between the two widgets.
- **Alternatives considered**: Inlining tile-rendering logic directly into `WordGrid`
  instead of reusing `LetterTile` — rejected as it would duplicate the tile-appearance
  rules this feature depends on `LetterTile` (item 4) to already provide.

## Decision: Testing approach

- **Decision**: `flutter_test` widget tests constructing `WordGrid` directly (wrapped in
  a minimal `MaterialApp`/`Scaffold`), covering: total tile count, per-row content for
  submitted/current/empty rows, and tile-size behavior across a few different container
  constraints (via `SizedBox`/`ConstrainedBox` ancestors).
- **Rationale**: `WordGrid` only needs a `GameEngine` (its default `const GameEngine()`)
  and an `answer` string to exercise scoring — no word list, storage, or full screen
  required, keeping tests isolated to this feature's scope (Constitution Principle I).
- **Alternatives considered**: Testing the grid only indirectly through the full game
  screen — rejected because it would entangle this feature's tests with the play loop's
  (a later feature), making failures harder to attribute.
