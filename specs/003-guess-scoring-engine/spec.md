# Feature Specification: Guess Scoring Engine

**Feature Branch**: `003-guess-scoring-engine`

**Created**: 2026-09-06

**Status**: Draft

**Input**: User description: "Guess scoring engine: a pure function that scores a 5-letter guess against an answer into per-letter statuses (correct / present / absent), correctly handling duplicate letters (correct-match pass before present-match pass, with a remaining-letter-count map)."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A guess is scored letter-by-letter (Priority: P1)

After a player submits a guess, each letter of that guess is classified against the
round's answer: exactly right position ("correct"), present elsewhere in the answer
("present"), or not in the answer at all ("absent"), so the board can show the player
what they got right.

**Why this priority**: This is the fundamental value of the whole game — without correct
per-letter scoring there is no Wordle-style feedback loop, and nothing built on top of it
(the board, the keyboard coloring) can be trusted.

**Independent Test**: Can be fully tested by calling the scoring function directly with a
guess and an answer and checking the returned per-letter statuses — no UI needed.

**Acceptance Scenarios**:

1. **Given** a guess identical to the answer, **When** it is scored, **Then** every
   letter is classified as correct.
2. **Given** a guess sharing no letters with the answer, **When** it is scored, **Then**
   every letter is classified as absent.
3. **Given** a guess with a letter in the wrong position that also appears elsewhere in
   the answer, **When** it is scored, **Then** that letter is classified as present.

---

### User Story 2 - Duplicate letters are scored fairly (Priority: P1)

When a guess contains a letter more times than the answer does, only as many of those
occurrences as the answer actually contains are marked present/correct — the rest are
marked absent, so players are never given misleading credit for a letter count the
answer doesn't have.

**Why this priority**: Getting duplicate-letter handling wrong is one of the most common
and player-visible correctness bugs in a Wordle-style game; it directly affects the
trustworthiness of every scored guess, so it ranks alongside basic scoring itself.

**Independent Test**: Can be fully tested by scoring guesses with repeated letters
against answers containing 0, 1, or 2 of that letter, and checking that at most that many
occurrences in the guess are marked correct/present — no UI needed.

**Acceptance Scenarios**:

1. **Given** a guess with a letter repeated twice and an answer containing that letter
   only once (in a different position), **When** the guess is scored, **Then** exactly
   one occurrence of that letter is marked present and the other is marked absent.
2. **Given** a guess with a letter repeated twice where one occurrence is in the correct
   position and the answer contains that letter only once, **When** the guess is scored,
   **Then** the correctly-placed occurrence is marked correct and the other occurrence is
   marked absent (not present).
3. **Given** a guess with a letter repeated twice and an answer containing that same
   letter twice, **When** the guess is scored, **Then** both occurrences are marked
   correct and/or present as appropriate, with neither incorrectly marked absent.

---

### User Story 3 - Malformed scoring requests are rejected (Priority: P3)

If something asks the scoring engine to compare two words of different lengths, it
refuses rather than returning a misleading or partial result.

**Why this priority**: This is a defensive guard against a programming error elsewhere in
the app (e.g. an answer/guess length mismatch slipping through earlier validation); it
protects correctness but isn't part of the everyday scoring path.

**Independent Test**: Can be fully tested by calling the scoring function with a guess
and answer of different lengths and confirming it raises an error rather than returning a
result.

**Acceptance Scenarios**:

1. **Given** a guess and an answer of different lengths, **When** scoring is attempted,
   **Then** the system rejects the request with a clear error instead of returning
   per-letter statuses.

### Edge Cases

- What happens when the guess and answer are scored in mixed letter case (e.g. a
  lowercase guess against an uppercase answer)? Scoring MUST be case-insensitive and
  produce the same result regardless of case.
- What happens when a letter appears three or more times in the guess but only once in
  the answer? Only one occurrence MUST be marked correct/present; the remaining
  occurrences MUST be marked absent, prioritizing correct-position matches over
  present-elsewhere matches when awarding the limited count.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST classify every letter of a guess, compared against an
  answer of the same length, into exactly one of three statuses: correct (right letter,
  right position), present (right letter, wrong position), or absent (letter not present
  in the remaining unmatched positions of the answer).
- **FR-002**: The system MUST evaluate correct-position matches for the entire guess
  before evaluating present-elsewhere matches, so that correct matches are never
  "stolen" by an earlier present-elsewhere check.
- **FR-003**: When a letter appears more times in the guess than in the answer, the
  system MUST cap the number of present/correct classifications for that letter at the
  number of times it remains available in the answer after correct matches are removed,
  marking any excess occurrences absent.
- **FR-004**: The system MUST treat letter matching as case-insensitive.
- **FR-005**: The system MUST reject a scoring request where the guess and answer are not
  the same length, raising a clear error rather than returning a result.
- **FR-006**: The system MUST NOT mutate or depend on any state outside the guess and
  answer passed to it — scoring the same guess/answer pair MUST always produce the same
  result.

### Key Entities

- **Letter status**: One of three classifications (correct, present, absent) assigned to
  a single letter position in a scored guess.
- **Scored guess**: The ordered list of letter statuses produced by scoring one guess
  against one answer, one status per letter position.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of guesses containing no duplicate letters are scored with the
  correct status for every position, verified against known guess/answer pairs.
- **SC-002**: 100% of guesses containing duplicate letters never report more
  correct/present occurrences of a letter than the answer actually contains.
- **SC-003**: Scoring the same guess/answer pair repeatedly always returns an identical
  result.
- **SC-004**: 100% of mismatched-length scoring requests are rejected before any partial
  result is produced.

## Assumptions

- The guess and answer are both restricted to alphabetic letters of a fixed word length
  (5 letters, matching the rest of the game); this feature does not need to validate that
  restriction itself — malformed word content is handled by the word-list feature.
- Scoring is a pure, synchronous computation with no persistence, network access, or
  randomness involved.
- This feature covers only the scoring algorithm itself; deciding when a guess is
  submitted, how scored results are displayed, and keyboard-letter coloring are handled
  by later roadmap features.
