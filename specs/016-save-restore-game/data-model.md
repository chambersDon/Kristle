# Phase 1 Data Model: Save & Restore In-Progress Game

## SavedGame

| Field | Type | Description |
|---|---|---|
| `gameNumber` | `int` | Increments each time a new round starts (item 13); defaults to `0`. |
| `answer` | `String` | The round's answer; defaults to `''`. |
| `guesses` | `List<String>` | Submitted guesses, uppercased; defaults to `[]`. |
| `currentGuess` | `String` | The in-progress guess, uppercased; defaults to `''`. |
| `status` | `GameStatus` | Defaults to `playing` if missing/unrecognized. |

**Defensive parsing** (`fromJson`, FR-005): each field is read only if it is present and
correctly typed; otherwise its default above is used. No combination of missing or
wrong-typed input throws.

**Structural validation** (`GameScreen._isValidSavedGame`, FR-003 — a game-rule check,
not part of `SavedGame` itself): a loaded `SavedGame` is safe to restore only if
`answer.length == 5`, `guesses.length <= 6`, and `currentGuess.length <= 5`.

**Relationships**: Written by `GameScreen._saveCurrentGame()` after every round-state
change (item 7's `_addLetter`/`_removeLetter`/`_submitGuess`, item 13's
`_startNewGame`); read by `GameScreen._loadSavedData()` at startup via
`GameStorage.loadGame()`.
