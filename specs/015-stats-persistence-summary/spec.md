# Feature Specification: Stats Persistence & Summary Display

**Feature Branch**: `015-stats-persistence-summary`

**Created**: 2026-09-06

**Status**: Draft

**Input**: User description: "Stats persistence & summary display: persist GameStats locally (load on launch, save after every completed game) and show a one-line summary (played / wins / streak) under the board while a game is in progress."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Lifetime stats persist across app launches (Priority: P1)

A player's lifetime statistics survive closing and reopening the app: whatever was true
the last time they played is still true when they come back, and every completed round
updates what's saved.

**Why this priority**: Without persistence, statistics reset every launch and are
meaningless as a "lifetime" record — this is the entire point of the feature.

**Independent Test**: Can be fully tested by saving a stats value, simulating a fresh
app launch, and confirming the loaded value matches what was saved; and separately by
completing a round and confirming the newly updated stats are saved afterward.

**Acceptance Scenarios**:

1. **Given** no stats have ever been saved, **When** the app launches, **Then** it
   starts with brand-new (all-zero) stats rather than an error.
2. **Given** stats were saved during a previous session, **When** the app launches,
   **Then** those saved stats are loaded and used.
3. **Given** a round completes (win or loss), **When** the outcome is recorded, **Then**
   the updated stats are saved for the next launch.

---

### User Story 2 - A quick stats summary is visible while playing (Priority: P2)

While a round is in progress, a single line under the board shows the player's games
played, games won, and current streak, so they can see their standing without leaving
the screen.

**Why this priority**: This is a display convenience built on top of the persisted data
(P1); it has no value without stats already being tracked.

**Independent Test**: Can be fully tested by loading a known stats value and confirming
the summary line shows the matching played/wins/streak numbers while a round is in
progress.

**Acceptance Scenarios**:

1. **Given** loaded stats with known played/wins/streak values, **When** a round is in
   progress, **Then** a one-line summary shows all three numbers.
2. **Given** the round has ended (win or loss) or shows a rejection message, **When** the
   screen is displayed, **Then** the summary is not shown in place of that message.

### Edge Cases

- What happens if the previously-saved stats data is corrupted or in an unexpected
  shape? Loading MUST fall back to safe, all-zero stats rather than crashing the app at
  startup (per the stats model's own defensive-parsing guarantee).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST load previously saved stats when the app starts, or
  brand-new (all-zero) stats if none have been saved yet.
- **FR-002**: The system MUST save the updated stats every time a round completes (win
  or loss).
- **FR-003**: While a round is in progress and no rejection/end-of-round message is
  showing, the system MUST display a one-line summary of games played, games won, and
  current streak.
- **FR-004**: The summary MUST NOT be shown in place of a rejection message or an
  end-of-round message/control — those take priority in the same display area.

### Key Entities

*(none — this feature persists and displays the existing stats model from item 14)*

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of app launches load either the previously saved stats or safe
  all-zero defaults, with 0% of launches crashing due to stats loading.
- **SC-002**: 100% of completed rounds result in updated stats being saved.
- **SC-003**: The summary line always reflects the currently loaded stats' exact
  played/wins/streak values while a round is in progress and no message is showing.

## Assumptions

- Stats are stored locally only (per Constitution Principle V); no account or network
  sync is in scope.
- This feature depends on the stats model (item 14) for the data shape and defensive
  parsing, and on the core play loop (item 7) for detecting when a round completes; it
  adds only the load-on-launch/save-on-completion wiring and the summary line.
