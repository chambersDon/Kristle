# Feature Specification: Invalid-Guess Shake Feedback

**Feature Branch**: `010-invalid-guess-shake`

**Created**: 2026-09-06

**Status**: Draft

**Input**: User description: "Invalid-guess shake feedback: shake the grid horizontally when a submit is rejected (wrong length or not in the word list)."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - The board shakes to signal a rejected guess (Priority: P1)

When a player's submission is rejected — whether it's too short or not a recognized word
— the board briefly shakes side to side, giving an immediate physical-feeling cue that
something went wrong, in addition to the inline text message.

**Why this priority**: This is the entire value of the feature — a shake with no
rejection to react to, or a rejection with no shake, would both be wrong; the two must
occur together.

**Independent Test**: Can be fully tested by attempting a submission that should be
rejected and confirming the board's horizontal position animates away from and back to
its resting position.

**Acceptance Scenarios**:

1. **Given** a current guess with fewer than 5 letters, **When** the player attempts to
   submit, **Then** the board shakes horizontally.
2. **Given** a complete 5-letter guess that is not in the allowed-guess list, **When**
   the player attempts to submit, **Then** the board shakes horizontally.
3. **Given** a complete, valid guess, **When** the player submits, **Then** the board
   does not shake.
4. **Given** the board has finished shaking, **When** no further rejected submissions
   occur, **Then** the board returns to and remains at its resting horizontal position.

### Edge Cases

- What happens if the player triggers another rejected submission while the board is
  still shaking from a previous one? The shake MUST restart cleanly from the beginning
  rather than combining with or being interrupted mid-way in a visually broken state.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: A rejected submission (too short, or not in the allowed-guess list) MUST
  trigger a horizontal shake animation on the board.
- **FR-002**: A successful submission MUST NOT trigger the shake animation.
- **FR-003**: The shake MUST be transient — the board returns to its normal resting
  position after the animation completes.
- **FR-004**: Triggering a new shake while one is already in progress MUST restart the
  animation cleanly, without a broken or discontinuous visual result.

### Key Entities

*(none — this feature introduces no new data entities)*

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of rejected submissions (both rejection reasons) trigger a visible
  shake.
- **SC-002**: 0% of successful submissions trigger a shake.
- **SC-003**: 100% of shakes return the board to its resting position afterward.

## Assumptions

- The exact shake motion (distance, duration, easing) is a fixed product/feel decision,
  not an open design choice for this feature.
- This feature only adds a visual animation triggered by an already-existing rejection
  decision (the core play loop, item 7, already decides when a submission is rejected);
  it does not change what counts as a valid or invalid guess.
