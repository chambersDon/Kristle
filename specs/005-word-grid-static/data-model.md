# Phase 1 Data Model: Word Grid (Static)

## WordGrid (widget)

| Property | Type | Description |
|---|---|---|
| `answer` | `String` | The round's answer, used to score submitted guesses. |
| `guesses` | `List<String>` | Guesses already submitted, in order; defaults to empty. |
| `currentGuess` | `String` | The in-progress, unscored guess; defaults to empty. |
| `gameEngine` | `GameEngine` | Scoring service; defaults to `const GameEngine()`. |

**Layout constants**: `rowCount = 6`, `columnCount = 5`, a fixed inter-tile/row gap, and
a fixed maximum tile size.

**Rendering rules** (per Phase 0 research), for row index `r` (0-based) and column index
`c`:

- `r < guesses.length`: letter is `guesses[r][c]` (or empty if `c` is beyond that guess's
  length — edge case guard), status is `GameEngine.scoreGuess(guess: guesses[r], answer:
  answer)[c]` (FR-002).
- `r == guesses.length` (and `guesses.length < rowCount`): letter is `currentGuess[c]` (or
  empty beyond its length), status is `LetterStatus.empty` (FR-003).
- Otherwise: letter is empty, status is `LetterStatus.empty` (FR-004).
- Tile size = `min(widthBasedSize, heightBasedSize)`, each clamped to the fixed maximum
  (FR-005, FR-006).

**State transitions**: None in this feature's scope — `WordGrid` is a pure function of
its constructor parameters; it holds no state of its own and re-renders fully whenever
`guesses`/`currentGuess`/`answer` change. Deciding *when* those values change (guess
entry, submission, win/loss) is a later roadmap feature.

**Relationships**: Composes `LetterTile` (one per cell) and calls `GameEngine.scoreGuess`
(one call per submitted row) to score each cell's status. Consumed by the core play loop
(later roadmap feature), which supplies the live `guesses`/`currentGuess`/`answer` values
as a round progresses.
