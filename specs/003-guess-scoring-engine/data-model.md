# Phase 1 Data Model: Guess Scoring Engine

## LetterStatus (enum)

The classification assigned to a single letter position in a scored guess.

| Value | Meaning |
|---|---|
| `empty` | No letter/status yet (not produced by scoring itself; used by later features for unscored tiles/keys) |
| `correct` | The letter is in the right position |
| `present` | The letter is in the answer, but in a different position |
| `absent` | The letter is not present in the answer's remaining unmatched positions |

## GameEngine

A stateless service with one operation.

### `scoreGuess({required String guess, required String answer})` → `List<LetterStatus>`

**Validation rules**:

- `guess.length` MUST equal `answer.length`; otherwise raise an `ArgumentError` before
  any scoring work (FR-005).

**Algorithm** (per Phase 0 research):

1. Uppercase both `guess` and `answer` (FR-004).
2. First pass: for each index, if the guess letter equals the answer letter, mark that
   position `correct`; otherwise increment a `remaining answer letters` count for the
   answer's letter at that index (FR-002).
3. Second pass: for each index not already `correct`, if the guess letter has a
   remaining count greater than zero, mark it `present` and decrement the count;
   otherwise mark it `absent` (FR-003).
4. Return the resulting `List<LetterStatus>`, one entry per position, in guess order.

**State transitions**: None — `GameEngine` holds no state; each call to `scoreGuess` is
independent and deterministic given the same inputs (FR-006, SC-003).

**Relationships**: Consumed by later roadmap features — the word grid renders tiles
colored by `scoreGuess`'s result, and the on-screen keyboard's key coloring derives the
highest-ranked status per letter across all submitted guesses. `GameEngine` itself has no
dependency on those features.
