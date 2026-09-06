# Feature Specification: Win Celebration Overlay

**Feature Branch**: `012-win-celebration-overlay`

**Created**: 2026-09-06

**Status**: Draft

**Input**: User description: "Win celebration overlay: on a win, after a short delay, show a full-width 'you won' image over the board for a couple of seconds, then auto-hide it (with a text fallback if the image asset fails to load)."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A win is celebrated with a brief overlay (Priority: P1)

After a player wins a round, a short pause lets the final scored row register visually,
then a celebratory image appears over the board for a couple of seconds before
disappearing on its own, so the player gets a satisfying, unobtrusive acknowledgment of
the win.

**Why this priority**: This is the entire value of the feature — the celebration only
matters if it appears at the right time and goes away on its own without the player
needing to dismiss it.

**Independent Test**: Can be fully tested by winning a round and confirming the overlay
is absent immediately, appears after the delay, and disappears again after its display
duration — no other feature's behavior needs to be exercised.

**Acceptance Scenarios**:

1. **Given** a player has just won, **When** no time has passed yet, **Then** the
   celebration overlay is not shown.
2. **Given** a player has won, **When** the short post-win delay has elapsed, **Then**
   the celebration overlay appears over the board.
3. **Given** the celebration overlay is showing, **When** its display duration has
   elapsed, **Then** the overlay disappears on its own, with no player action required.
4. **Given** a round ends in a loss rather than a win, **When** the round ends, **Then**
   the celebration overlay never appears.

---

### User Story 2 - The celebration still works if its image can't load (Priority: P2)

If the celebration image asset can't be loaded for any reason, a simple text message is
shown in its place instead, so a win is still acknowledged even without the graphic.

**Why this priority**: This is a robustness fallback — the primary celebration (P1)
matters more, but the game shouldn't show a broken or blank overlay if the image is
unavailable.

**Independent Test**: Can be fully tested by simulating an image load failure during the
celebration window and confirming a text fallback appears in the image's place.

**Acceptance Scenarios**:

1. **Given** the celebration overlay is due to display and its image fails to load,
   **When** the overlay appears, **Then** a text message acknowledging the win is shown
   instead of a broken or blank image.

### Edge Cases

- What happens if the player starts a new game while the celebration overlay is still
  showing or still pending? Any pending or in-progress celebration timers MUST be
  canceled so a stale overlay doesn't appear during the new round.
- What happens if the overlay is showing and the player attempts to interact with the
  board underneath it? The round has already ended at this point, so no guess input is
  possible either way (per the core play loop's post-round lockout).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: On a win, the system MUST wait a short, fixed delay before showing the
  celebration overlay.
- **FR-002**: The celebration overlay MUST be a full-width image displayed over the
  board.
- **FR-003**: The celebration overlay MUST automatically disappear after a fixed display
  duration, with no player action required.
- **FR-004**: The celebration overlay MUST NOT appear on a loss.
- **FR-005**: If the celebration image fails to load, a text fallback acknowledging the
  win MUST be shown in its place.
- **FR-006**: Starting a new game MUST cancel any pending or in-progress celebration
  timers so a stale overlay cannot appear during the new round.

### Key Entities

*(none — this feature introduces no new data entities)*

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of wins show the celebration overlay after the fixed delay, and it
  auto-hides after the fixed display duration, with no manual dismissal needed.
- **SC-002**: 0% of losses ever show the celebration overlay.
- **SC-003**: 100% of image load failures during the celebration window show the text
  fallback instead of a broken/blank image.

## Assumptions

- The exact delay and display duration are fixed product/feel decisions, not open
  design choices for this feature.
- This feature only adds the celebration overlay's timing and fallback behavior; it does
  not change win/loss detection itself (the core play loop, item 7, already decides
  that) or the "New Game" reset mechanics (item 13) beyond canceling this feature's own
  timers.
