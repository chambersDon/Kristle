# Phase 1 Data Model: Letter Tile Flip-Reveal Animation

## LetterTile (extended)

| Property | Type | Description |
|---|---|---|
| `letter` | `String` | Unchanged from item 4. |
| `status` | `LetterStatus` | Unchanged from item 4. |
| `revealDelay` | `Duration` | How long to wait after a scored-status transition before the flip starts (FR-001, FR-003); defaults to `Duration.zero`. |

**Animation lifecycle** (per Phase 0 research):

- Created with `status != empty`: shows scored face immediately, no animation
  (FR-004).
- Transitions `empty` → scored: waits `revealDelay`, then flips (FR-001, FR-002).
- Transitions scored → `empty`: shows unscored face immediately, no animation (FR-005).
- Any status change while a flip is in progress: restarts cleanly from the beginning for
  the new status (FR-006).

**Relationships**: `WordGrid` (item 5) computes each cell's `revealDelay`
(`columnIndex * 110ms` for submitted rows, `Duration.zero` otherwise) and passes it into
each `LetterTile` it builds (FR-003).
