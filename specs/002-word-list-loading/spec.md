# Feature Specification: Word List Loading & Validation

**Feature Branch**: `002-word-list-loading`

**Created**: 2026-09-06

**Status**: Draft

**Input**: User description: "Word list loading & validation: a service that loads two bundled word-list text assets (answers, allowed guesses), validates every line is exactly 5 letters (case-insensitive, `#` comments and blank lines skipped, malformed entries throw), exposes a random-answer picker and an allowed-guess check."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - App loads a validated word list on startup (Priority: P1)

Before any gameplay can start, the app loads its bundled answer list and allowed-guess
list from disk, checks that every entry is a well-formed 5-letter word, and makes the
resulting lists available to the rest of the app. If either list is malformed, the app
fails loudly and immediately rather than silently starting a game it cannot run
correctly.

**Why this priority**: Every later feature (guess scoring, the play loop, the board) is
built on top of a trustworthy word list. Without a validated word source, invalid or
malformed words could corrupt gameplay in ways that are hard to trace back to their
source.

**Independent Test**: Can be fully tested by pointing the loader at a set of in-memory
word lists (well-formed and malformed variants) and confirming it accepts the former and
rejects the latter — delivers the value of a trustworthy word source before any UI is
built on top of it.

**Acceptance Scenarios**:

1. **Given** the app's bundled answer and allowed-guess word lists, **When** the app
   loads them at startup, **Then** both lists load successfully and are available for use
   by other features.
2. **Given** a word list containing an entry that is not exactly 5 letters, **When** the
   app attempts to load it, **Then** loading fails immediately with an error, rather than
   silently dropping or truncating the bad entry.
3. **Given** a loaded word list, **When** a word is looked up in any letter case (e.g.
   "kite", "KITE", "Kite"), **Then** the lookup behaves identically regardless of case.

---

### User Story 2 - A random answer is chosen for a new game (Priority: P2)

Once the word list has loaded, the game needs a single answer word to play against for a
new round.

**Why this priority**: Picking today's/this round's answer is a prerequisite for the core
play loop (a later feature), but it only matters once loading (P1) already works.

**Independent Test**: Can be fully tested by loading a small known answer list and
confirming repeated picks always return a word that is a member of that list — delivers
the value of an always-valid starting point for a new game.

**Acceptance Scenarios**:

1. **Given** a loaded answer list, **When** a new-game answer is requested, **Then** the
   word returned is always one of the entries in the answer list.
2. **Given** a loaded answer list with more than one word, **When** many new-game answers
   are requested in sequence, **Then** the selection is not fixed to always the same word
   (i.e. selection is randomized, not hard-coded to one entry).

---

### User Story 3 - A submitted guess is checked against the allowed word list (Priority: P2)

While playing, a player's typed 5-letter guess must be checked against the allowed-guess
list before it can be scored, so that nonsense strings are rejected before they reach
scoring.

**Why this priority**: This gate is what the play-loop feature relies on to reject
invalid submissions; it must exist and behave correctly before that feature can be built,
but it is secondary to loading the list at all.

**Independent Test**: Can be fully tested by loading a small known allowed-guess list and
confirming known member words pass the check while non-member strings fail it —
delivers the value of a reliable accept/reject gate for guesses, independent of any UI.

**Acceptance Scenarios**:

1. **Given** a loaded allowed-guess list, **When** a guess matching an entry in that list
   is checked (in any letter case), **Then** the guess is reported as allowed.
2. **Given** a loaded allowed-guess list, **When** a guess not present in that list is
   checked, **Then** the guess is reported as not allowed.
3. **Given** a loaded answer list and allowed-guess list, **When** a word appears only in
   the answer list and not explicitly in the allowed-guess list, **Then** that word is
   still reported as an allowed guess (every valid answer is always guessable).

### Edge Cases

- What happens when a word-list source contains blank lines? They MUST be skipped and
  MUST NOT be treated as malformed entries.
- What happens when a word-list source contains a comment line (starting with `#`)? It
  MUST be skipped and MUST NOT be treated as malformed entry, regardless of what follows
  the `#`.
- What happens when a word-list source contains a line with leading/trailing whitespace
  around an otherwise valid 5-letter word? The whitespace MUST be ignored and the word
  MUST be treated as valid.
- What happens when the answer list is empty after skipping comments/blank lines?
  Loading MUST fail with an error, since a game cannot start without at least one
  possible answer.
- What happens when a line contains a word with the wrong number of letters, or
  non-letter characters? Loading MUST fail immediately with an error identifying the
  offending list.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST load an answer word list and an allowed-guess word list
  from the app's bundled assets.
- **FR-002**: The system MUST validate, for each non-skipped line in both lists, that the
  line contains exactly 5 letters; any line that does not MUST cause loading to fail with
  an error that identifies which list the bad entry came from.
- **FR-003**: The system MUST skip blank lines and lines starting with `#` in both lists
  without treating them as validation failures.
- **FR-004**: The system MUST treat word matching (loading, lookups, and the allowed-guess
  check) as case-insensitive.
- **FR-005**: The system MUST fail loading with an error if the answer list contains zero
  valid entries after skipping blank/comment lines.
- **FR-006**: The system MUST provide a way to pick a single random word from the loaded
  answer list, such that every call returns a member of that list and repeated calls are
  not restricted to always returning the same word when the list has more than one entry.
- **FR-007**: The system MUST provide a way to check whether an arbitrary 5-letter string
  is an allowed guess, returning a clear allowed/not-allowed result.
- **FR-008**: Every word present in the loaded answer list MUST be reported as an allowed
  guess, even if it does not separately appear in the allowed-guess list source.

### Key Entities

- **Answer list**: The set of words eligible to be chosen as a round's answer; loaded
  from a bundled source, validated on load, non-empty.
- **Allowed-guess list**: The set of words a player is permitted to submit as a guess;
  loaded from a bundled source, validated on load, always a superset of the answer list.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of well-formed bundled word-list files load successfully with zero
  manual intervention.
- **SC-002**: 100% of malformed word-list entries (wrong length, non-letter characters)
  are caught at load time, with 0% reaching gameplay unnoticed.
- **SC-003**: Every answer produced by the random-answer picker is a valid member of the
  loaded answer list, verified across repeated selections.
- **SC-004**: Guess-validity checks return the correct allowed/not-allowed result for
  100% of tested known-member and known-non-member words, regardless of letter case.

## Assumptions

- The two word lists are bundled with the app as plain-text assets, one word per line,
  and are read-only at runtime (no in-app editing of the word lists).
- "5 letters" means 5 alphabetic characters; no accented characters, hyphens, apostrophes,
  or digits are supported in either list for this feature.
- The allowed-guess list is expected to already contain the vast majority of playable
  guesses; this feature only guarantees that answer-list words are additionally usable as
  guesses even if omitted from the allowed-guess source.
- Randomization for the answer picker does not need to be cryptographically secure; it
  only needs to avoid predictable/fixed selection.
- This feature covers loading, validation, random selection, and guess-validity checking
  only; scoring a guess against an answer (letter-by-letter correctness) is out of scope
  and handled by a later roadmap feature (guess scoring engine).
