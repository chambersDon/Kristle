# Phase 1 Data Model: Letter Tile (Static)

## LetterTile (widget)

A stateless-in-appearance (for this feature's scope) square cell.

| Property | Type | Description |
|---|---|---|
| `letter` | `String` | The single letter to display; empty string shows no letter. |
| `status` | `LetterStatus` | `empty` (unscored) or one of `correct`/`present`/`absent` (scored). |

**Rendering rules** (per Phase 0 research):

- Always laid out as a 1:1 square regardless of the space given (FR-001).
- `status == empty`: outlined box, no fill; border is subtle when `letter` is also
  empty, more prominent once a `letter` is present (FR-005, FR-006).
- `status` scored: solid fill in the status's color (`correct` → green, `present` →
  yellow, `absent` → gray), border matching the fill, white letter text (FR-003, FR-004).
- `letter` text uses a theme-derived on-surface color when unscored, white when scored
  (FR-004).

**State transitions**: None in this feature's scope — a tile simply renders whatever
`letter`/`status` it is given. Transitioning a tile's *displayed* face from unscored to
scored over time (the flip/reveal animation) is a later roadmap feature; this feature
only defines what each static state looks like.

**Relationships**: Consumed by the word grid (later roadmap feature), which arranges a
6×5 grid of tiles and feeds each one a `letter` and a `LetterStatus` derived from
`GameEngine.scoreGuess`. `LetterTile` itself has no dependency on the grid, engine, or
screen.
