# Feature Specification: Save & Restore In-Progress Game

**Feature Branch**: `016-save-restore-game`

**Created**: 2026-09-06

**Status**: Draft

**Input**: User description: "Save & restore in-progress game: persist the current game (answer, submitted guesses, current in-progress guess, status, game number) after every input change, and restore it on next launch if it's still structurally valid (right word length, guess counts in range) — otherwise start fresh."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Closing and reopening the app resumes the same round (Priority: P1)

A player mid-round can close the app and come back later to find their exact
in-progress round waiting for them — the same answer, the same submitted guesses, the
same partially-typed current guess, and the same win/loss status — rather than losing
their progress.

**Why this priority**: Losing an in-progress round on every app restart is a poor
experience for anything but a single sitting; this is the entire value of the feature.

**Independent Test**: Can be fully tested by saving a round's state, simulating a fresh
app launch, and confirming the restored round matches exactly what was saved.

**Acceptance Scenarios**:

1. **Given** a player has typed or submitted at least one letter/guess, **When** that
   change happens, **Then** the current round's full state is saved.
2. **Given** a previously saved, structurally valid round, **When** the app launches,
   **Then** that exact round (answer, guesses, current guess, status) is restored in
   place of starting a new one.
3. **Given** no round has ever been saved, **When** the app launches, **Then** a fresh
   round starts normally.

---

### User Story 2 - A corrupted or invalid save never breaks the app (Priority: P1)

If the previously saved round data is structurally invalid in any way, the app starts a
fresh round instead of restoring the broken data or crashing.

**Why this priority**: This is a correctness and stability guarantee — a bad save must
never prevent the player from playing at all, ranking it alongside restoration itself.

**Independent Test**: Can be fully tested by saving deliberately invalid round data
(wrong-length answer, too many guesses, an over-long current guess) and confirming the
app starts fresh rather than restoring it or erroring.

**Acceptance Scenarios**:

1. **Given** a saved answer that is not the expected word length, **When** the app
   launches, **Then** a fresh round starts instead of restoring the invalid save.
2. **Given** a saved guess list longer than the maximum allowed guesses, **When** the
   app launches, **Then** a fresh round starts instead of restoring the invalid save.
3. **Given** a saved current guess longer than the expected word length, **When** the
   app launches, **Then** a fresh round starts instead of restoring the invalid save.
4. **Given** saved round data that is missing fields or has wrong-typed values, **When**
   it is read back, **Then** reading it never throws an error — malformed or missing
   fields fall back to safe defaults.

### Edge Cases

- What happens if the saved data can't be decoded as valid structured data at all (e.g.
  corrupted text)? The app MUST start fresh rather than crash.
- What happens to the save after a round ends and "New Game" is used? The newly started
  round MUST be what gets saved going forward, not the just-finished one.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST save the current round's full state (answer, submitted
  guesses, current guess, status, and a game number) after every change to that state
  (typing, backspacing, submitting, or starting a new game).
- **FR-002**: On launch, the system MUST attempt to load a previously saved round.
- **FR-003**: A loaded round MUST be restored as the active round only if it is
  structurally valid: its answer is the expected word length, its guess count does not
  exceed the maximum allowed, and its current guess does not exceed the expected word
  length.
- **FR-004**: If no round was previously saved, or the saved round fails structural
  validation, the system MUST start a fresh round instead.
- **FR-005**: Reading saved round data MUST NOT throw an error for missing, wrong-typed,
  or malformed fields — each such field MUST fall back to a safe default before the
  structural validation in FR-003 is applied.

### Key Entities

- **Saved round**: A persisted snapshot of one in-progress or completed round — a game
  number, the answer, submitted guesses, the current guess, and status.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of input changes (typing, backspacing, submitting, new game) result
  in the current round being saved.
- **SC-002**: 100% of structurally valid saved rounds are restored exactly on the next
  launch.
- **SC-003**: 100% of structurally invalid or corrupted saved rounds result in a fresh
  round starting, with 0% of launches crashing because of bad saved data.

## Assumptions

- The expected word length (5) and maximum guess count (6) are fixed values matching the
  word grid (item 5).
- This feature depends on the core play loop (item 7) for the round-state fields being
  saved and on the "New Game" flow (item 13) for when a fresh round begins; it adds the
  persistence and restoration wiring around that existing state.
- Persisting lifetime statistics (item 15) is a separate concern from persisting the
  current in-progress round; this feature covers only the latter.
