# Feature Specification: Physical Keyboard Support

**Feature Branch**: `009-physical-keyboard-support`

**Created**: 2026-09-06

**Status**: Draft

**Input**: User description: "Physical keyboard support: accept the same input (letters, backspace, enter) from a connected physical keyboard, in addition to on-screen taps."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A player uses a physical keyboard to play (Priority: P1)

A player with a connected physical keyboard types letter keys, Backspace, and Enter and
sees exactly the same effect as tapping the equivalent on-screen keyboard controls.

**Why this priority**: On desktop/web, a physical keyboard is often the primary or only
practical input method; without this, those players are stuck tapping a virtual keyboard
with a mouse.

**Independent Test**: Can be fully tested by sending physical key events and confirming
they produce the same guess-entry, backspace, and submission behavior as on-screen taps.

**Acceptance Scenarios**:

1. **Given** a round in progress, **When** the player presses a letter key on a physical
   keyboard, **Then** that letter is appended to the current guess, exactly as if the
   matching on-screen key had been tapped.
2. **Given** a current guess with at least one letter, **When** the player presses
   Backspace, **Then** the last letter is removed, exactly as if the on-screen backspace
   key had been tapped.
3. **Given** a complete, valid current guess, **When** the player presses Enter, **Then**
   the guess is submitted, exactly as if the on-screen submit control had been tapped.
4. **Given** an incomplete current guess, **When** the player presses Enter, **Then** the
   same rejection message is shown as when submission is attempted with an incomplete
   guess via any other input method.

---

### User Story 2 - Non-game keys are ignored (Priority: P2)

Pressing a key that isn't a letter, Backspace, or Enter has no effect on the game.

**Why this priority**: This prevents unrelated key presses (modifier keys, punctuation,
function keys) from corrupting the guess; it's a safety/robustness concern secondary to
basic input support (P1).

**Independent Test**: Can be fully tested by sending a variety of non-letter,
non-Backspace, non-Enter key presses and confirming none of them change the current
guess.

**Acceptance Scenarios**:

1. **Given** a round in progress, **When** the player presses a key that is not a
   letter, Backspace, or Enter, **Then** the current guess is unchanged.

### Edge Cases

- What happens if the round has already ended (win or loss)? Physical key presses MUST
  be subject to the same "no effect once ended" rule as on-screen input.
- What happens on a key-repeat (holding a key down)? Each individual key-down event MUST
  be handled the same as a single press; this feature does not need to de-duplicate or
  rate-limit repeats beyond what the platform itself delivers.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST listen for physical keyboard input while a round is
  displayed.
- **FR-002**: A physical letter-key press MUST have the same effect as tapping that
  letter on the on-screen keyboard.
- **FR-003**: A physical Backspace press MUST have the same effect as tapping the
  on-screen backspace key.
- **FR-004**: A physical Enter press MUST have the same effect as tapping the on-screen
  submit control, including showing the same rejection messages for incomplete or
  unrecognized guesses.
- **FR-005**: A physical key press that is not a letter, Backspace, or Enter MUST have no
  effect on the current guess or round state.
- **FR-006**: Physical keyboard input MUST respect the same round-ended lockout as
  on-screen input.

### Key Entities

*(none — this feature introduces no new data entities)*

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of A–Z physical key presses append the correct letter, matching
  on-screen tap behavior exactly.
- **SC-002**: 100% of physical Backspace/Enter presses match their on-screen equivalents'
  behavior exactly, including rejection messaging.
- **SC-003**: 0% of non-letter, non-Backspace, non-Enter key presses have any observable
  effect on the guess or round.

## Assumptions

- "Letter key" means any physical key whose label corresponds to a single A–Z character;
  keyboard layout/locale differences beyond standard A–Z key labels are out of scope.
- This feature adds a second input path alongside the existing on-screen keyboard (item
  6); it does not change or replace the on-screen keyboard's own behavior.
