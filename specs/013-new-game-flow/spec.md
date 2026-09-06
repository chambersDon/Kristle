# Feature Specification: New Game Flow

**Feature Branch**: `013-new-game-flow`

**Created**: 2026-09-06

**Status**: Draft

**Input**: User description: "New Game flow: a 'New Game' control (shown once the round ends) that picks a fresh answer and resets the board, keyboard colors, message, and reveal state."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A player starts a fresh round after one ends (Priority: P1)

Once a round has ended (win or loss), a "New Game" control appears; tapping it clears
the board, picks a new answer, and returns the whole screen to a fresh, playable state —
no leftover guesses, messages, keyboard colors, or revealed-answer state from the
previous round.

**Why this priority**: Without this, a player would be stuck after every round ends,
unable to play again without restarting the app; this is the entire value of the
feature.

**Independent Test**: Can be fully tested by ending a round, tapping "New Game," and
confirming every piece of round state (board, keyboard colors, message, reveal state) is
reset to a fresh starting condition.

**Acceptance Scenarios**:

1. **Given** a round is still in progress, **When** the player looks at the screen,
   **Then** no "New Game" control is shown.
2. **Given** a round has ended (win or loss), **When** the player looks at the screen,
   **Then** a "New Game" control is shown.
3. **Given** a round has ended, **When** the player taps "New Game," **Then** the board
   is cleared of all previous guesses and the current guess, and a new answer is in
   play.
4. **Given** a round has ended with some keyboard keys colored from previous guesses,
   **When** the player taps "New Game," **Then** every key returns to its default,
   unscored color.
5. **Given** a round has ended showing a rejection or loss message, **When** the player
   taps "New Game," **Then** any leftover message is cleared.
6. **Given** the answer-reveal helper was showing the previous round's answer, **When**
   the player taps "New Game," **Then** the reveal is hidden and its tap-count progress
   is reset.

### Edge Cases

- What happens to any pending celebration overlay timers when a new game starts? They
  MUST be canceled so a stale overlay from the previous round cannot appear during the
  new one (covered jointly with item 12's own cancellation requirement).
- What happens if "New Game" is tapped more than once in a row? Each tap MUST
  independently produce a fresh, fully-reset round with no accumulated state from prior
  taps.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The "New Game" control MUST be shown only when the round has ended (win or
  loss), and MUST NOT be shown while a round is in progress.
- **FR-002**: Tapping "New Game" MUST select a new answer from the word list.
- **FR-003**: Tapping "New Game" MUST clear all previously submitted guesses and the
  current in-progress guess.
- **FR-004**: Tapping "New Game" MUST reset the round's status to in-progress.
- **FR-005**: Tapping "New Game" MUST reset every on-screen keyboard key to its default,
  unscored color.
- **FR-006**: Tapping "New Game" MUST clear any rejection or end-of-round message.
- **FR-007**: Tapping "New Game" MUST hide the answer-reveal state and reset its
  tap-count progress, if the answer-reveal helper is enabled.

### Key Entities

*(none — this feature resets existing round-state entities rather than introducing new
ones)*

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of ended rounds show the "New Game" control; 0% of in-progress rounds
  show it.
- **SC-002**: 100% of "New Game" taps produce a board with zero guesses, an empty
  current guess, and every keyboard key at its default color.
- **SC-003**: 100% of "New Game" taps clear any prior message and reset the
  answer-reveal state.

## Assumptions

- "New Game" reset is scoped to in-memory round state; persisting the new round (so it
  survives an app restart) is handled by a later roadmap feature (save & restore).
- The keyboard-coloring reset (FR-005) follows automatically from clearing all guesses
  (item 8's key-status computation derives entirely from submitted guesses), rather than
  needing separate reset logic of its own.
