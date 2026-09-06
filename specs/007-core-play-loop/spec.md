# Feature Specification: Core Play Loop

**Feature Branch**: `007-core-play-loop`

**Created**: 2026-09-06

**Status**: Draft

**Input**: User description: "Core play loop: guess entry, submission, win/loss. Wire word list + engine + grid + keyboard into one screen: pick a random answer on start, type/backspace letters into the current row, submit only when 5 letters are typed and the word is in the allowed-guess list (otherwise show an inline message), detect a win (guess == answer) or a loss (6 guesses used), stop accepting input once the game ends."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A player types and edits a guess (Priority: P1)

A player taps letters on the keyboard to build up their current guess, and can remove
the last letter typed with backspace, seeing the letters appear in the board's current
row as they go.

**Why this priority**: Building a guess is the most basic interaction of an actual game
round — every later interaction (submitting, winning, losing) depends on this working
first.

**Independent Test**: Can be fully tested by starting a round and typing/backspacing
letters, confirming the board's current row reflects exactly what's been typed.

**Acceptance Scenarios**:

1. **Given** a fresh round with an empty current guess, **When** the player taps letter
   keys, **Then** each tapped letter appears in order in the board's current row.
2. **Given** a current guess with at least one letter, **When** the player taps
   backspace, **Then** the last letter typed is removed from the current row.
3. **Given** a current guess already has 5 letters, **When** the player taps another
   letter key, **Then** no additional letter is added.
4. **Given** an empty current guess, **When** the player taps backspace, **Then**
   nothing happens (there is no letter to remove).

---

### User Story 2 - A guess is only accepted if it's complete and valid (Priority: P1)

When a player tries to submit their guess, it's only accepted as a real turn if it has
exactly 5 letters and is a real word from the game's word list; otherwise the player sees
a message explaining why, and the guess stays in place for them to fix.

**Why this priority**: This is the gatekeeper for every scored guess reaching the board
— without it, incomplete or nonsense guesses could corrupt the round. It depends on
guess entry (P1) already working.

**Independent Test**: Can be fully tested by attempting to submit an incomplete guess and
a complete-but-invalid guess, and confirming both are rejected with a message and neither
becomes a scored row, then submitting a valid guess and confirming it is accepted.

**Acceptance Scenarios**:

1. **Given** fewer than 5 letters have been typed, **When** the player attempts to
   submit, **Then** the guess is rejected, an inline message explains a 5-letter word is
   needed, and the current guess is left unchanged for editing.
2. **Given** exactly 5 letters have been typed but the word is not in the allowed-guess
   list, **When** the player attempts to submit, **Then** the guess is rejected, an
   inline message explains the word isn't recognized, and the current guess is left
   unchanged for editing.
3. **Given** exactly 5 letters have been typed and the word is in the allowed-guess
   list, **When** the player submits, **Then** the guess becomes a new scored row on the
   board, the current guess is cleared, and any previous rejection message is cleared.

---

### User Story 3 - The round ends on a win or a loss (Priority: P1)

The round ends the moment a submitted guess exactly matches the answer (a win), or after
six guesses have been submitted without matching (a loss); once the round has ended, no
further letters can be typed or guesses submitted until a new round starts.

**Why this priority**: This is the payoff of the entire play loop — without win/loss
detection, guesses could be submitted forever with no result. It depends on guess
submission (P1) already working.

**Independent Test**: Can be fully tested by submitting the answer as a guess (confirming
a win is detected and further input is ignored) and, separately, submitting six
non-matching guesses (confirming a loss is detected after the sixth and further input is
ignored).

**Acceptance Scenarios**:

1. **Given** a round in progress, **When** the player submits a guess that exactly
   matches the answer, **Then** the round ends in a win.
2. **Given** a round in progress with five guesses already submitted, none matching,
   **When** the player submits a sixth non-matching guess, **Then** the round ends in a
   loss.
3. **Given** the round has ended (win or loss), **When** the player attempts to type a
   letter, use backspace, or submit, **Then** none of those actions have any effect.

---

### User Story 4 - Every round starts with a freshly chosen answer (Priority: P2)

When a round begins, the answer to guess is chosen from the game's word list, not fixed
to the same word every time.

**Why this priority**: This makes the game replayable, but it's secondary to the
mechanics of playing a single round (P1) correctly.

**Independent Test**: Can be fully tested by starting a round and confirming the answer
in play is a genuine member of the loaded answer list (observable once the round ends,
e.g. via the loss message revealing the answer).

**Acceptance Scenarios**:

1. **Given** the game's word list has been loaded, **When** a round starts, **Then** the
   answer for that round is a word drawn from the loaded answer list.

### Edge Cases

- What happens if a player rapidly re-attempts submitting the same invalid guess? Each
  attempt MUST be rejected the same way, with no partial or corrupted state building up.
- What happens to a rejection message once the player starts typing again? It MUST be
  cleared as soon as the player edits the current guess (types a letter or backspaces),
  so stale messages don't linger.
- What happens once six guesses have been submitted without a win? The round MUST end in
  a loss exactly at that point — a seventh guess MUST NOT be accepted.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: At the start of a round, the system MUST select an answer from the loaded
  word list.
- **FR-002**: While a round is in progress, typing a letter MUST append it to the current
  guess, up to a maximum of 5 letters; typing beyond 5 MUST have no effect.
- **FR-003**: While a round is in progress, backspace MUST remove the last letter of the
  current guess, if any; backspacing an empty current guess MUST have no effect.
- **FR-004**: Attempting to submit a current guess with fewer than 5 letters MUST be
  rejected, leaving the current guess unchanged, and MUST show an inline message
  indicating a complete word is required.
- **FR-005**: Attempting to submit a complete (5-letter) current guess that is not in the
  allowed-guess list MUST be rejected, leaving the current guess unchanged, and MUST show
  an inline message indicating the word isn't recognized.
- **FR-006**: Submitting a complete, allowed current guess MUST add it as a new scored
  row on the board, clear the current guess, and clear any prior rejection message.
- **FR-007**: Any successful edit to the current guess (typing or backspacing) MUST clear
  a previously shown rejection message.
- **FR-008**: The round MUST end in a win the moment a submitted guess exactly matches
  the answer.
- **FR-009**: The round MUST end in a loss once six guesses have been submitted without
  any of them matching the answer.
- **FR-010**: Once a round has ended (win or loss), typing, backspacing, and submitting
  MUST all have no effect until a new round starts.

### Key Entities

- **Round**: One in-progress or completed play-through — an answer, the guesses
  submitted so far, the current in-progress guess, and whether it's still playing, won,
  or lost.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of typed letters appear in the current row in the order they were
  typed, up to exactly 5, with no more accepted beyond that.
- **SC-002**: 100% of submission attempts with fewer than 5 letters, or with an
  unrecognized 5-letter word, are rejected with an inline message and produce no new
  scored row.
- **SC-003**: 100% of submissions matching the answer end the round in a win on that
  exact submission, and 100% of the sixth non-matching submission ends the round in a
  loss.
- **SC-004**: Once a round ends, 100% of further typing/backspace/submit attempts have no
  observable effect on the board.
- **SC-005**: The answer used in a new round is always a member of the loaded answer
  list, verified across multiple round starts.

## Assumptions

- The word list (loading/validation, random selection, allowed-guess checking) and the
  scoring engine already exist as separate, reusable services this feature wires
  together rather than reimplementing.
- The word grid and on-screen keyboard already exist as separate, reusable widgets this
  feature wires together and drives with live state, rather than reimplementing their
  static rendering.
- This feature covers only the play loop's mechanics (entry, submission, win/loss,
  input-lockout after the round ends). Persisting game state and statistics across app
  restarts, the flip/reveal animation, keyboard key-status coloring, shake feedback for
  invalid guesses, physical-keyboard input, a "New Game" control, and the win-celebration
  overlay are all handled by later roadmap features and are out of scope here.
