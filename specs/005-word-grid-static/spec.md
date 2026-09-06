# Feature Specification: Word Grid (Static)

**Feature Branch**: `005-word-grid-static`

**Created**: 2026-09-06

**Status**: Draft

**Input**: User description: "Word grid (static): a 6-row x 5-column grid of letter tiles that renders submitted guesses (scored via the engine), the in-progress current guess (unscored), and empty remaining rows — responsive tile sizing that fits available width/height."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - The board shows every guess row in its correct state (Priority: P1)

The game board always shows exactly six rows of five tiles: rows for guesses already
submitted show each letter scored against the answer, the next row (if the game isn't
over) shows the letters typed so far with no scoring yet, and any rows beyond that are
completely empty.

**Why this priority**: This is the single visual source of truth for how a round is
going — every other feature that depends on "the board" (the play loop, animations, win
detection) needs this rendering to be correct first.

**Independent Test**: Can be fully tested by rendering the grid with a mix of submitted
guesses, an in-progress current guess, and remaining empty rows, and confirming each
row's tiles show the right letters and statuses — no full screen or gameplay needed.

**Acceptance Scenarios**:

1. **Given** one or more previously submitted guesses, **When** the grid is rendered,
   **Then** each submitted guess's row shows every letter scored against the answer
   (correct/present/absent, per the scoring engine).
2. **Given** a partially-typed current guess and no completed round, **When** the grid is
   rendered, **Then** the row immediately after the last submitted guess shows those
   typed letters with no scored status.
3. **Given** fewer than six guesses have been submitted or typed, **When** the grid is
   rendered, **Then** every remaining row below the current guess shows five empty,
   unscored tiles.
4. **Given** exactly six rows are always shown, **When** the grid is rendered with zero,
   some, or six submitted guesses, **Then** the total tile count is always 30 (6 rows ×
   5 columns).

---

### User Story 2 - The board fits the space it's given (Priority: P2)

The board resizes its tiles so the whole 6×5 grid fits within whatever width and height
it's given, without ever growing so large that it overflows the screen or so small that
tiles become illegibly tiny beyond a sensible cap.

**Why this priority**: Getting layout right matters for usability across device sizes,
but the grid's *content* correctness (P1) is more fundamental — a correctly-sized grid
showing the wrong letters is still broken.

**Independent Test**: Can be fully tested by rendering the grid inside containers of
several different sizes and confirming the resulting tile size adapts to fit, without
exceeding a fixed maximum tile size.

**Acceptance Scenarios**:

1. **Given** a wide available width, **When** the grid is rendered, **Then** tile size
   does not grow past a fixed maximum, keeping the board a reasonable size on large
   screens.
2. **Given** a narrow available width, **When** the grid is rendered, **Then** tile size
   shrinks so all 5 columns fit within that width.
3. **Given** limited available height, **When** the grid is rendered, **Then** tile size
   shrinks so all 6 rows fit within that height, even if width would otherwise allow
   larger tiles.

### Edge Cases

- What happens when a submitted guess is shorter than 5 letters somehow reaches the
  grid? Positions beyond that guess's length in its row MUST render as empty rather than
  erroring.
- What happens when there are exactly six submitted guesses (the round-ending case)?
  There MUST be no "current guess" row shown as in-progress — all six rows are
  submitted/scored rows, with no seventh row rendered.
- What happens when both the available width and height are extremely constrained? Tile
  size MUST shrink to fit both dimensions rather than overflowing either one.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The grid MUST always render exactly 6 rows of 5 tiles each (30 tiles
  total), regardless of how many guesses have been submitted.
- **FR-002**: Each row corresponding to an already-submitted guess MUST show that
  guess's letters scored against the round's answer.
- **FR-003**: If fewer than 6 guesses have been submitted, the row immediately following
  the last submitted guess MUST show the current in-progress guess's letters with no
  scored status.
- **FR-004**: Every row beyond the current in-progress row (or beyond the last submitted
  guess, if there are already 6) MUST render five empty, unscored tiles.
- **FR-005**: Tile size MUST scale down as needed so all 5 columns fit within the
  available width and all 6 rows fit within the available height, whichever is more
  restrictive.
- **FR-006**: Tile size MUST NOT exceed a fixed maximum, even when ample width and
  height are available.

### Key Entities

- **Grid**: A fixed 6×5 arrangement of tiles representing one round's guesses; rows are
  either submitted (scored), current (unscored, in-progress), or empty.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The grid always renders exactly 30 tiles, verified with 0, 1, 3, and 6
  submitted guesses.
- **SC-002**: 100% of submitted-guess rows show statuses matching the scoring engine's
  output for that guess/answer pair.
- **SC-003**: The current-guess row never shows a scored color for any of its letters.
- **SC-004**: Tile size stays within its fixed maximum on wide containers and shrinks to
  fit on narrow or short containers, verified across at least three container sizes.

## Assumptions

- The board is always exactly 6 rows by 5 columns; a different board size is not an
  option this feature needs to support.
- Determining *which* guesses have been submitted, what the current in-progress guess
  is, and when a round ends is handled by a later roadmap feature (the core play loop);
  this feature only renders whatever guesses/current-guess data it is given.
- The flip/reveal animation that transitions a row's tiles from unscored to scored, and
  the shake feedback for invalid submissions, are handled by later roadmap features; this
  feature renders each tile's final static state only.
