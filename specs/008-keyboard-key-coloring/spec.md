# Feature Specification: Keyboard Key-Status Coloring

**Feature Branch**: `008-keyboard-key-coloring`

**Created**: 2026-09-06

**Status**: Draft

**Input**: User description: "Keyboard key-status coloring: feed the highest-ranked status (correct > present > absent > empty) per letter, across all submitted guesses, back into the on-screen keyboard so keys change color as letters are ruled in/out."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Keyboard letters reflect what's been learned so far (Priority: P1)

As guesses are submitted, each letter key on the on-screen keyboard updates to the
best-known status for that letter across every guess submitted so far, so a player can
see at a glance which letters are confirmed correct, known to be in the word, or ruled
out entirely.

**Why this priority**: This is the entire value of the feature — without it, keys never
change color and players lose a key piece of Wordle-style deduction support.

**Independent Test**: Can be fully tested by submitting a sequence of guesses and
checking that each letter's on-screen key color matches the best status that letter has
received across all guesses so far.

**Acceptance Scenarios**:

1. **Given** a submitted guess where a letter scored correct, **When** the keyboard is
   displayed, **Then** that letter's key shows the correct-status color.
2. **Given** a letter has never appeared in any submitted guess, **When** the keyboard is
   displayed, **Then** that letter's key shows the default (unscored) color.
3. **Given** a letter scored absent in one guess and present in a later guess, **When**
   the keyboard is displayed, **Then** that letter's key shows the present-status color
   (the better of the two), not absent.
4. **Given** a letter scored present in one guess and correct in a later guess, **When**
   the keyboard is displayed, **Then** that letter's key shows the correct-status color
   (the better of the two), not present.

### Edge Cases

- What happens if the same letter appears more than once in a single guess with
  different statuses (e.g. one occurrence correct, one absent, due to duplicate-letter
  scoring)? The key MUST show the better of the two statuses from that guess.
- What happens once a letter has reached the correct status? A later guess scoring that
  same letter as present or absent MUST NOT downgrade its key color.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: For every letter that has appeared in at least one submitted guess, the
  system MUST compute that letter's best-known status by ranking `correct` above
  `present`, `present` above `absent`, and `absent` above no status at all (never
  submitted).
- **FR-002**: The system MUST feed this per-letter best-known status to the on-screen
  keyboard so each key's color reflects it.
- **FR-003**: A letter's key color MUST never downgrade once a better status has been
  reached, regardless of what a later guess reports for that letter.
- **FR-004**: A letter that has never appeared in any submitted guess MUST show the
  keyboard's default (unscored) color.

### Key Entities

- **Key status map**: A mapping from letter to its best-known status, derived from every
  submitted guess scored against the answer.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of letter keys reflect the highest-ranked status that letter has
  received across all submitted guesses so far.
- **SC-002**: 0% of letter keys ever downgrade in status after reaching a better one.

## Assumptions

- Ranking order (correct > present > absent > unscored) is a fixed product decision, not
  an open design choice.
- This feature only computes and feeds the per-letter status map to the existing
  on-screen keyboard widget (which already renders per-key colors given such a map); it
  does not change how guesses are scored or how the keyboard renders a given status.
