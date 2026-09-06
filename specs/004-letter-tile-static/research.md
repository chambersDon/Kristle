# Phase 0 Research: Letter Tile (Static)

No `NEEDS CLARIFICATION` markers remain in the Technical Context — the decisions below
resolve every open design question for the static `LetterTile` appearance before
implementation begins.

## Decision: Square sizing

- **Decision**: Wrap the tile's content in an `AspectRatio(aspectRatio: 1)`.
- **Rationale**: Guarantees FR-001/SC-004 (always a perfect square) regardless of the
  size constraint the parent (eventually the word grid) gives it, without the tile
  needing to know its own pixel size.
- **Alternatives considered**: A fixed-size `SizedBox` — rejected because tile size must
  be responsive to the grid's available space (a later feature's concern), and a fixed
  size would fight that.

## Decision: Status-to-color mapping

- **Decision**: A direct `switch` from `LetterStatus` to one of four colors: white/none
  for `empty`, and the three fixed status colors (correct/present/absent) for scored
  statuses, all defined as shared constants.
- **Rationale**: Satisfies FR-003/SC-001 with one obvious, exhaustive mapping; centralizing
  the colors as constants keeps the tile and later features (e.g. keyboard key coloring)
  visually consistent.
- **Alternatives considered**: Inline color literals per call site — rejected as it would
  risk the tile and keyboard drifting to slightly different shades for the same status.

## Decision: Border style for unscored vs. scored tiles

- **Decision**: A scored tile's border matches its fill color (effectively invisible);
  an unscored tile shows an outlined box with no fill — a subtle border when empty, and a
  more prominent border once a letter is typed into it.
- **Rationale**: Satisfies FR-005/FR-006/SC-002 — gives players a clear "nothing scored
  yet" read, with a secondary visual cue (border weight) distinguishing "empty" from
  "typing in progress" within the unscored state.
- **Alternatives considered**: A single unscored border style regardless of whether a
  letter is typed — rejected because it loses the "still typing" signal the spec calls
  out (edge case: an in-progress tile vs. a genuinely empty one).

## Decision: Letter text contrast

- **Decision**: White text on any scored (colored) background; a theme-derived on-surface
  color for unscored tiles.
- **Rationale**: Satisfies FR-004/SC-003 — white reads clearly against all three status
  colors (which are each mid-to-dark toned), and using the ambient theme's on-surface
  color for the unscored case keeps light/dark-mode legibility correct without hardcoding
  a second color.
- **Alternatives considered**: A single hardcoded dark text color for all states —
  rejected because it would be illegible against the darker scored backgrounds.

## Decision: Testing approach

- **Decision**: `flutter_test` widget tests constructing `LetterTile` directly (each
  test wraps it in a minimal `MaterialApp`/`Scaffold`), one status/letter combination per
  test, asserting rendered background color, border presence, and letter text.
- **Rationale**: `LetterTile` needs a `Directionality`/`MediaQuery` ancestor to lay out
  (standard for any Flutter widget test) but nothing else — no board, engine, or word
  list required, keeping tests isolated to this feature's scope (Constitution
  Principle I).
- **Alternatives considered**: Testing tile appearance only indirectly through the full
  word grid/screen — rejected because it would entangle this feature's tests with later
  features' widgets, making failures harder to attribute and violating the "independently
  testable" goal from the spec's User Story sections.
