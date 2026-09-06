# Feature Specification: Game Statistics Model

**Feature Branch**: `014-game-statistics-model`

**Created**: 2026-09-06

**Status**: Draft

**Input**: User description: "Game statistics model: an immutable stats model (played, wins, current streak, max streak, guess-count distribution, win %) with recordWin/recordLoss/copyWith and JSON (de)serialization that tolerates missing/malformed input."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A completed round updates lifetime statistics (Priority: P1)

Whenever a round ends, the player's lifetime statistics update: games played always
increases by one, and either a win is recorded (increasing wins, extending the current
win streak, and noting how many guesses it took) or a loss is recorded (resetting the
current streak to zero).

**Why this priority**: This is the core value of the whole feature — without correct
win/loss recording, every other statistic derived from it (win percentage, streaks,
distribution) is meaningless.

**Independent Test**: Can be fully tested by recording a sequence of wins and losses
against a stats value and checking the resulting counts are correct at each step — no UI
needed.

**Acceptance Scenarios**:

1. **Given** a stats value, **When** a win is recorded, **Then** played and wins both
   increase by one, and the current streak increases by one.
2. **Given** a stats value, **When** a loss is recorded, **Then** played increases by
   one, wins is unchanged, and the current streak resets to zero.
3. **Given** a stats value, **When** a win is recorded that took N guesses, **Then** the
   guess-count distribution's entry for N increases by one.
4. **Given** a current streak that would become the longest ever, **When** a win is
   recorded, **Then** the max streak updates to match the new current streak.
5. **Given** a max streak already longer than the current streak, **When** a win extends
   the current streak without surpassing the max, **Then** the max streak is unchanged.

---

### User Story 2 - Win percentage is always derivable from the stats (Priority: P2)

At any point, the fraction of played games that were won can be read directly from the
stats value, without the caller needing to compute it themselves.

**Why this priority**: This is a convenience derived from data already tracked by User
Story 1; it adds no new tracking of its own.

**Independent Test**: Can be fully tested by checking the win percentage for a few
known played/wins combinations, including zero games played.

**Acceptance Scenarios**:

1. **Given** zero games have been played, **When** the win percentage is read, **Then**
   it is zero (not an error or undefined value).
2. **Given** some games have been played with a known number of wins, **When** the win
   percentage is read, **Then** it equals wins divided by played, expressed as a
   percentage.

---

### User Story 3 - Statistics survive being saved and loaded as data (Priority: P1)

The stats value can be converted to and from a plain data representation suitable for
storage, and reconstructing it from a previously-saved but now incomplete or corrupted
representation never crashes — it falls back to safe defaults for whatever is missing or
malformed.

**Why this priority**: This is what makes stats persistable at all (a later roadmap
feature builds on it) and, per the project's defensive-parsing rule, is a correctness and
stability requirement in its own right — a corrupted save must never crash the app at
startup.

**Independent Test**: Can be fully tested by converting a stats value to its data
representation and back, and separately by reconstructing from various deliberately
missing/malformed representations and confirming a safe, default-filled result rather
than a crash.

**Acceptance Scenarios**:

1. **Given** a fully-populated stats value, **When** it is converted to its data
   representation and back, **Then** the reconstructed value equals the original.
2. **Given** a data representation missing one or more fields, **When** the stats value
   is reconstructed from it, **Then** each missing field falls back to its safe default
   rather than causing an error.
3. **Given** a data representation with a field of the wrong type (e.g. a number where a
   list is expected, or text where a number is expected), **When** the stats value is
   reconstructed from it, **Then** that field falls back to its safe default rather than
   causing an error.
4. **Given** a guess-count distribution representation with the wrong number of entries
   or non-numeric entries, **When** the stats value is reconstructed from it, **Then**
   the result is always a well-formed distribution of the expected length with numeric
   entries.

### Edge Cases

- What happens when a win is recorded with a guess count outside the valid range (e.g.
  zero or more than the maximum allowed guesses)? The distribution MUST NOT be updated
  for an out-of-range count, while played/wins/streak fields still update normally.
- What happens when reconstructing from a completely empty data representation? The
  result MUST be identical to a brand-new, never-played stats value.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The stats model MUST track: games played, games won, current win streak,
  longest-ever win streak, and a distribution of how many guesses each win took.
- **FR-002**: Recording a win MUST increase played and wins by one, increase the current
  streak by one, update the guess-count distribution for the winning guess count (if
  within the valid range), and update the max streak if the new current streak exceeds
  it.
- **FR-003**: Recording a loss MUST increase played by one and reset the current streak
  to zero, leaving wins and the max streak unchanged.
- **FR-004**: The stats model MUST be immutable — every update produces a new value
  rather than modifying an existing one in place.
- **FR-005**: The stats model MUST expose a win percentage derived from wins and played,
  defined as zero when no games have been played.
- **FR-006**: The stats model MUST convert to and from a plain data representation
  suitable for storage.
- **FR-007**: Reconstructing a stats model from a data representation MUST NOT throw an
  error for missing, wrong-typed, or malformed fields — each such field MUST fall back to
  a safe default instead.
- **FR-008**: Reconstructing the guess-count distribution MUST always produce a
  well-formed, fixed-length list of numeric entries, regardless of what shape the source
  data was in.

### Key Entities

- **Stats**: Lifetime statistics for one player/device — played count, win count,
  current streak, max streak, and a fixed-length distribution of guess counts across
  wins.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of recorded wins/losses update played, wins, streak, max streak, and
  distribution correctly, verified across a representative sequence of outcomes.
- **SC-002**: Win percentage is correct for 100% of tested played/wins combinations,
  including zero games played.
- **SC-003**: 100% of round-trip conversions (to data and back) reproduce the original
  values exactly.
- **SC-004**: 100% of malformed or incomplete data representations reconstruct without
  error, always producing a well-formed stats value.

## Assumptions

- The maximum number of guesses per round (and therefore the distribution's fixed
  length) is 6, matching the board size defined by the word grid (item 5).
- This feature defines the stats model and its update/serialization logic only;
  persisting it to disk and triggering updates from actual completed rounds are handled
  by a later roadmap feature (stats persistence & summary display).
