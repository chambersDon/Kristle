# Phase 1 Data Model: Word List Loading & Validation

## WordList

An immutable value holding the two validated word collections used by the game.

| Field | Type | Description |
|---|---|---|
| `answers` | `List<String>` | Every valid word from the answer asset, uppercase, in file order. Always non-empty (FR-005). |
| `allowedGuesses` | `Set<String>` | Every valid word from the allowed-guess asset, uppercase, plus every word in `answers` (FR-008). |

**Validation rules** (applied while parsing each source, per line):

- Skip the line if it is blank after trimming, or starts with `#` (FR-003).
- Otherwise, trim and uppercase the line, then require it to match exactly 5 alphabetic
  characters (`^[A-Z]{5}$`); a non-matching line throws a `FormatException` naming which
  list (`answers` or `allowed guesses`) it came from (FR-002).
- After parsing the answers source, if zero words resulted, throw a `StateError`
  (FR-005).

**State transitions**: None — `WordList` is a fully-formed, read-only snapshot for the
lifetime of the app process; a new instance is created by `WordList.load()`/
`WordList.fromText()`, never mutated in place (Constitution Principle III's immutability
clause; see [plan.md](plan.md) for the one deliberate exception to that principle's
"never throws" clause).

**Relationships**: Consumed by later roadmap features — the guess-scoring engine and the
core play loop read `answers` (via `pickRandomAnswer`) and `allowedGuesses` (via
`isAllowedGuess`); `WordList` itself has no dependency on those features.

## Operations

- **`WordList.load({AssetBundle? bundle})`**: Reads both bundled text assets
  (`assets/words/kristle_answers.txt`, `assets/words/allowed_guesses.txt`) via the given
  or default (`rootBundle`) asset bundle and delegates to `fromText`.
- **`WordList.fromText({required String answersText, required String allowedGuessesText})`**:
  Parses both raw strings per the validation rules above and constructs a `WordList`.
  Pure/synchronous — no I/O — making it the primary unit-test entry point.
- **`pickRandomAnswer({Random? random})`**: Returns a uniformly random element of
  `answers`, using the given or a new `Random`. Always returns a member of `answers`.
- **`isAllowedGuess(String guess)`**: Returns whether `guess.toUpperCase()` is present in
  `allowedGuesses`. Case-insensitive by construction.
