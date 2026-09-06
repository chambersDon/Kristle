# Feature Specification: Answer-Reveal Easter Egg

**Feature Branch**: `017-answer-reveal-easter-egg`

**Created**: 2026-09-06

**Status**: Draft

**Input**: User description: "Answer-reveal easter egg: a compile-time-toggleable debug helper: tapping the header 5 times reveals the current answer in place of the header image; tapping the revealed answer 5 times hides it again; it's force-hidden whenever a new game starts; the whole feature can be compiled out via a build-time flag."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Tapping the header reveals the answer (Priority: P1)

When the helper is enabled, tapping the header image five times replaces it with the
current round's answer displayed as text, giving a quick way to check the answer during
development or testing.

**Why this priority**: This is the entire value of the feature for its intended use
(development/testing convenience); there's no smaller useful slice.

**Independent Test**: Can be fully tested by tapping the header five times and
confirming the answer text appears in place of the header image.

**Acceptance Scenarios**:

1. **Given** the helper is enabled and the header image is showing, **When** the header
   is tapped fewer than five times, **Then** the header image remains showing.
2. **Given** the helper is enabled, **When** the header is tapped a fifth time, **Then**
   the header image is replaced by the current round's answer as text.

---

### User Story 2 - Tapping the revealed answer hides it again (Priority: P2)

Once the answer is revealed, tapping it five times restores the header image in its
place.

**Why this priority**: This completes the toggle so the helper doesn't permanently
replace the header; it depends on the reveal (P1) already working.

**Independent Test**: Can be fully tested by revealing the answer, tapping it five
times, and confirming the header image returns.

**Acceptance Scenarios**:

1. **Given** the answer is revealed, **When** the revealed answer is tapped fewer than
   five times, **Then** it remains revealed.
2. **Given** the answer is revealed, **When** it is tapped a fifth time, **Then** the
   header image is shown again in its place.

---

### User Story 3 - The reveal is force-hidden on a new game (Priority: P2)

Starting a new game always hides the revealed answer and resets both tap counters, even
if the answer was revealed when "New Game" was tapped.

**Why this priority**: Prevents a revealed answer from lingering into a new round with a
different answer; depends on the reveal/hide mechanics (P1/P2) already existing.

**Independent Test**: Can be fully tested by revealing the answer, starting a new game,
and confirming the header image shows again with tap progress reset (five taps are
needed again to re-reveal).

**Acceptance Scenarios**:

1. **Given** the answer is revealed, **When** a new game starts, **Then** the header
   image is shown again, not the answer.
2. **Given** a new game has just started, **When** the header is tapped, **Then** the
   full five taps are required again to reveal the new answer (no leftover tap
   progress).

---

### User Story 4 - The helper can be fully disabled at build time (Priority: P3)

When the helper is disabled via a compile-time flag, tapping the header never reveals
anything, regardless of how many times it's tapped.

**Why this priority**: This lets a release build ship with the helper fully compiled
out; it's a build-configuration concern layered on top of the interactive behavior
above.

**Independent Test**: Can be fully tested by disabling the helper and confirming five
header taps produce no reveal.

**Acceptance Scenarios**:

1. **Given** the helper is disabled, **When** the header is tapped five or more times,
   **Then** the header image remains showing and the answer is never revealed.

### Edge Cases

- What happens if the header is tapped more than five times without the answer ever
  hiding? Extra taps beyond the fifth MUST NOT cause any additional effect while already
  revealed (the hide-counter only starts once tapping the *revealed answer*, not the
  header).
- What happens to hide-tap progress if fewer than five hide-taps occur and then a new
  game starts? It MUST be reset along with everything else (per User Story 3).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: When enabled, tapping the header MUST count toward a reveal threshold of
  five taps; reaching the threshold MUST replace the header image with the current
  answer as text.
- **FR-002**: When enabled and the answer is revealed, tapping the revealed answer MUST
  count toward a hide threshold of five taps; reaching the threshold MUST restore the
  header image in place of the answer text.
- **FR-003**: Starting a new game MUST hide the revealed answer (if showing) and reset
  both the reveal and hide tap counters to zero.
- **FR-004**: A single compile-time flag MUST control whether this entire feature is
  active; when disabled, no number of header taps MUST ever reveal the answer.
- **FR-005**: The compile-time flag MUST default to enabled unless explicitly overridden
  at build time.

### Key Entities

*(none — this feature adds transient UI counters, not persisted data)*

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of five-tap sequences on the header (when enabled) reveal the answer;
  0% of shorter sequences do.
- **SC-002**: 100% of five-tap sequences on the revealed answer hide it again.
- **SC-003**: 100% of new-game transitions leave the header showing its image, not the
  answer, with tap progress reset.
- **SC-004**: 0% of header taps reveal anything when the feature is disabled at build
  time.

## Assumptions

- This is a development/testing convenience, not a player-facing feature; it is
  expected to be enabled in development builds and may be disabled for release builds
  via the compile-time flag.
- This feature depends on the core play loop (item 7) for the current answer and on the
  "New Game" flow (item 13) for the reset trigger; it adds only the tap-counting and
  reveal/hide display logic.
