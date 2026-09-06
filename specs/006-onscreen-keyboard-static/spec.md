# Feature Specification: On-Screen Keyboard (Static)

**Feature Branch**: `006-onscreen-keyboard-static`

**Created**: 2026-09-06

**Status**: Draft

**Input**: User description: "On-screen keyboard (static): a QWERTY on-screen keyboard with letter keys, a backspace key, and a submit button that's disabled until 5 letters are entered. No per-key coloring yet (all keys one default color)."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A player types letters using the on-screen keyboard (Priority: P1)

A player taps letter keys arranged in a standard QWERTY layout to enter a guess, and a
backspace key to remove the last letter typed.

**Why this priority**: Letter entry is the core interaction of the whole game — without
it, a player has no way to build a guess at all. Nothing else about the keyboard matters
until this works.

**Independent Test**: Can be fully tested by rendering the keyboard alone, tapping
letter keys and the backspace key, and confirming each tap reports the expected action —
no game screen or state needed.

**Acceptance Scenarios**:

1. **Given** the on-screen keyboard is displayed, **When** a player looks at it, **Then**
   every letter A–Z is present, arranged in the standard three-row QWERTY layout.
2. **Given** the keyboard is displayed, **When** a player taps a letter key, **Then** the
   keyboard reports that letter was chosen.
3. **Given** the keyboard is displayed, **When** a player taps the backspace key, **Then**
   the keyboard reports a backspace action (distinct from any letter).

---

### User Story 2 - Submitting is only possible with a complete guess (Priority: P2)

A submit control lets a player commit their typed guess, but only once exactly 5 letters
have been entered — before that, the control is visibly and functionally disabled.

**Why this priority**: This prevents a player from submitting an incomplete guess, but it
depends on letter entry (P1) already existing and only matters once there's something to
submit.

**Independent Test**: Can be fully tested by rendering the keyboard with the "can
submit" condition toggled on and off and confirming the submit control is disabled/
enabled accordingly, and that tapping it while enabled reports a submit action.

**Acceptance Scenarios**:

1. **Given** fewer than 5 letters have been entered, **When** the keyboard is displayed,
   **Then** the submit control is disabled and does not respond to taps.
2. **Given** exactly 5 letters have been entered, **When** the keyboard is displayed,
   **Then** the submit control is enabled.
3. **Given** the submit control is enabled, **When** a player taps it, **Then** the
   keyboard reports a submit action.

### Edge Cases

- What happens when the keyboard is given very little available width? All keys and the
  submit control MUST still render and remain tappable, adapting their size to fit
  rather than overflowing.
- What happens to key coloring in this feature? Every letter key MUST use one single,
  consistent default appearance — no per-key color variation is part of this feature.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The keyboard MUST display every letter A–Z exactly once, arranged in the
  standard three-row QWERTY layout.
- **FR-002**: The keyboard MUST display a distinct backspace control, separate from any
  letter key.
- **FR-003**: Tapping a letter key MUST report that specific letter as chosen.
- **FR-004**: Tapping the backspace control MUST report a backspace action, distinguishable
  from any letter-chosen report.
- **FR-005**: The keyboard MUST display a submit control, separate from the letter keys
  and backspace control.
- **FR-006**: The submit control MUST be disabled (non-interactive) whenever fewer than 5
  letters have been entered, and enabled once exactly 5 have been entered.
- **FR-007**: Tapping the submit control while enabled MUST report a submit action.
- **FR-008**: Every letter key MUST use the same single default appearance — this
  feature introduces no per-key color variation based on prior guesses.
- **FR-009**: The keyboard's keys and submit control MUST resize to fit the available
  width without overflowing.

### Key Entities

- **Key**: A single tappable letter, or the backspace control, on the on-screen
  keyboard.
- **Submit control**: A single tappable control, separate from the keys, whose enabled
  state depends on whether a complete guess has been entered.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All 26 letters are present and reachable by a tap, verified across the
  full alphabet.
- **SC-002**: 100% of letter-key taps report the correct, distinct letter.
- **SC-003**: The submit control's enabled state matches the "5 letters entered" condition
  in 100% of tested cases (0, 1, 4, 5 letters entered).
- **SC-004**: The keyboard renders without overflowing at three different available
  widths, from narrow to wide.

## Assumptions

- "Reports" an action (letter chosen, backspace, submit) means the keyboard invokes a
  caller-supplied callback with the relevant information; deciding what to *do* with that
  report (updating a guess in progress, checking it against a word list, etc.) is handled
  by a later roadmap feature (the core play loop).
- Per-key coloring based on prior guess results (marking letters correct/present/absent)
  is deliberately out of scope for this feature and is handled by a later roadmap
  feature.
- The keyboard does not itself track how many letters have been entered; it is told
  whether submission is currently allowed via an input it's given.
