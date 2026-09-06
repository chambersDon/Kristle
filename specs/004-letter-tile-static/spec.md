# Feature Specification: Letter Tile (Static)

**Feature Branch**: `004-letter-tile-static`

**Created**: 2026-09-06

**Status**: Draft

**Input**: User description: "Letter tile (static): a single square tile widget that renders one letter with a background color driven by letter status, with an empty/typing border style vs. a scored/filled style."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A tile shows its letter and scored color (Priority: P1)

A single square tile displays one letter of a guess, and once that letter has been
scored, the tile's background color communicates the result at a glance: green for
correct, yellow for present, gray for absent.

**Why this priority**: This is the smallest visible unit of feedback in the whole game —
every row of the board is built from these tiles, and no larger board or keyboard
feature can be meaningfully tested or built without a correctly colored tile first.

**Independent Test**: Can be fully tested by rendering a single tile with a letter and
each possible scored status and confirming the correct background color and letter are
shown — no board or full screen needed.

**Acceptance Scenarios**:

1. **Given** a tile showing a letter with a "correct" status, **When** it is rendered,
   **Then** its background is the correct-status color and it displays that letter.
2. **Given** a tile showing a letter with a "present" status, **When** it is rendered,
   **Then** its background is the present-status color.
3. **Given** a tile showing a letter with an "absent" status, **When** it is rendered,
   **Then** its background is the absent-status color.
4. **Given** a scored tile (correct, present, or absent), **When** its letter text is
   rendered, **Then** the letter is legible against its colored background.

---

### User Story 2 - An unscored tile looks distinct from a scored one (Priority: P2)

Before a guess is scored, a tile in the current or an empty row looks visually distinct
from a scored tile — a plain bordered box rather than a solid colored fill — so players
can tell at a glance which rows are still awaiting a result.

**Why this priority**: This distinction is what lets a player read the board correctly
(which rows are done vs. in progress vs. untouched), but it only matters once basic
scored-color rendering (P1) already works.

**Independent Test**: Can be fully tested by rendering a tile with no scored status (with
and without a letter typed into it) and confirming it uses the unscored border style
rather than any scored fill color.

**Acceptance Scenarios**:

1. **Given** a tile with no letter and no scored status, **When** it is rendered,
   **Then** it shows an empty bordered box with no fill color and no letter.
2. **Given** a tile with a letter typed but not yet scored (e.g. mid-entry in the current
   guess), **When** it is rendered, **Then** it shows that letter with the unscored
   border style, not a scored fill color.
3. **Given** an unscored tile with a letter versus one with no letter, **When** both are
   rendered, **Then** they are visually distinguishable from each other (e.g. a more
   prominent border once a letter is present) while both remaining visually distinct
   from any scored tile.

### Edge Cases

- What happens if the letter string passed to a tile is empty? The tile MUST render as
  an unscored, empty box with no visible letter.
- What happens if a tile is rendered at different sizes (e.g. varying screen widths)?
  The tile MUST remain a square (equal width and height) regardless of the size it's
  given.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: A tile MUST render as a square (1:1 aspect ratio) regardless of the space
  it is given.
- **FR-002**: A tile MUST display the single letter it is given, or nothing if given an
  empty letter.
- **FR-003**: A tile MUST render one of three distinct background fill colors when given
  a scored status (correct, present, absent), each color visually distinct from the
  other two and from the unscored style.
- **FR-004**: A tile MUST render its letter text in a color that remains legible against
  whichever background (scored fill color or unscored background) it is currently
  showing.
- **FR-005**: A tile with no scored status (an empty or in-progress/unscored tile) MUST
  render as an outlined box with no fill color, rather than any scored background color.
- **FR-006**: An unscored tile with a letter typed into it MUST be visually distinguishable
  from an unscored tile with no letter (e.g. a more prominent border once typing begins).

### Key Entities

- **Tile**: A single square cell representing one letter position in one guess row; has
  a letter (possibly empty) and a status (unscored/empty, correct, present, or absent).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of tiles with a scored status show one of exactly three distinct,
  consistent colors that map 1:1 to correct/present/absent.
- **SC-002**: 100% of unscored tiles (empty or mid-typing) show no scored fill color.
- **SC-003**: Tile letter text remains legible (sufficient contrast against its
  background) in 100% of status/background combinations.
- **SC-004**: A tile renders as a perfect square at any size it is given, verified across
  at least three different size constraints.

## Assumptions

- The specific colors used for each status (e.g. exact shade of green/yellow/gray) are a
  fixed product/branding decision, not an open design choice for this feature.
- This feature covers only a single, static tile's appearance — the flip/reveal
  animation that transitions a tile from unscored to scored, and the staggered timing
  across a row, are handled by a later roadmap feature.
- Arranging multiple tiles into rows and a full board is handled by a later roadmap
  feature (word grid); this feature only concerns one tile in isolation.
