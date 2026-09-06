# Phase 0 Research: Guess Scoring Engine

No `NEEDS CLARIFICATION` markers remain in the Technical Context — the decisions below
resolve every open design question for `GameEngine.scoreGuess` before implementation
begins.

## Decision: Two-pass scoring algorithm

- **Decision**: Score in two passes — a correct-position pass over every letter first,
  building a per-letter remaining-count map from the answer's unmatched positions, then
  a present-elsewhere pass that consumes from that map.
- **Rationale**: A single left-to-right pass would let an earlier present-elsewhere
  match "steal" credit that a later correct-position match in the same letter needed,
  producing wrong results for duplicate letters (FR-002, FR-003). Doing all correct
  matches first guarantees the remaining-count map only reflects answer positions no
  guess letter has already claimed.
- **Alternatives considered**: A single pass with lookahead/backtracking — rejected as
  more complex and harder to reason about than two straightforward linear passes for a
  fixed, small word length.

## Decision: Remaining-count map keyed by letter

- **Decision**: Use a `Map<String, int>` keyed by single-letter strings, incremented for
  each answer position not already matched correct, then decremented as present matches
  consume it.
- **Rationale**: Directly encodes "how many more times can this letter be credited,"
  which is exactly the cap FR-003 requires, and generalizes to any repeat count (2, 3+)
  without special-casing.
- **Alternatives considered**: Counting via `List<bool>` "used" flags per answer index —
  rejected as requiring an extra inner loop per guess letter to find an unused matching
  index, when a count map achieves the same result in O(1) per letter.

## Decision: Case handling

- **Decision**: Uppercase both the guess and answer before comparison.
- **Rationale**: Guarantees case-insensitive scoring (FR-004) with a single
  normalization point, consistent with the word list's own uppercase normalization.
- **Alternatives considered**: Case-insensitive character comparison at each step —
  rejected as more scattered and error-prone than normalizing once upfront.

## Decision: Length-mismatch handling

- **Decision**: Throw an `ArgumentError` immediately if `guess.length != answer.length`,
  before any scoring work begins.
- **Rationale**: Satisfies FR-005/SC-004 — a mismatched pair is a caller error (e.g. a
  bug in whatever validates guesses before scoring), and failing fast with a clear error
  is preferable to returning a misleading partial or truncated result.
- **Alternatives considered**: Silently truncating/padding to the shorter/longer length —
  rejected as it would hide a caller bug and produce a scored result that doesn't
  correspond to any real guess.

## Decision: Testing approach

- **Decision**: `flutter_test` unit tests calling `GameEngine().scoreGuess(...)` directly
  with literal guess/answer string pairs, asserting the returned `List<LetterStatus>`.
- **Rationale**: `GameEngine` is a pure, synchronous, dependency-free function — no
  widget pump or fake services are needed, matching Constitution Principle I's testability
  goal.
- **Alternatives considered**: Property-based/fuzz testing over random letter
  combinations — considered for duplicate-letter coverage, but rejected as unnecessary
  given a small, enumerable set of hand-picked duplicate-letter cases already covers the
  algorithm's branches (correct-before-present, answer-limited count, exact match,
  no match).
