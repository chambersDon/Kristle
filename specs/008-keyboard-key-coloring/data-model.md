# Phase 1 Data Model: Keyboard Key-Status Coloring

## Key status map

`Map<String, LetterStatus>`, built by iterating every guess in `_guesses`, scoring each
via `GameEngine.scoreGuess(guess: guess, answer: _answer)`, and for each letter position
keeping the entry with the higher `_statusRank` than whatever is already recorded for
that letter (FR-001, FR-003). Letters never seen in any guess are simply absent from the
map (FR-004), and `GameKeyboard` already treats a missing entry as its default color.

**Relationships**: Reads `GameEngine.scoreGuess` and `_guesses`; feeds `GameKeyboard`'s
`keyStatuses` parameter. No new entities are introduced.
