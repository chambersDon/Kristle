# Phase 0 Research: Save & Restore In-Progress Game

## Decision: Save after every state-changing action, not on a timer

- **Decision**: `_saveCurrentGame()` is called at the end of `_addLetter`,
  `_removeLetter`, `_submitGuess`, and `_startNewGame` — every method that changes
  round state.
- **Rationale**: Satisfies FR-001/SC-001 — saving exactly when state changes guarantees
  the persisted snapshot is never more than one action stale, without needing a debounce
  or periodic save mechanism.
- **Alternatives considered**: Saving only on app pause/lifecycle events — rejected as it
  risks losing the most recent actions if the app is killed abruptly rather than paused
  normally.

## Decision: Structural validation gates restoration, separate from defensive parsing

- **Decision**: `SavedGame.fromJson` only guarantees a well-formed *shape* (right types,
  never throws); a separate `_isValidSavedGame` check in `GameScreen` decides whether
  that well-formed data is *safe to restore* (right word length, guess counts in range).
- **Rationale**: Satisfies FR-003/FR-005 as two distinct guarantees — `fromJson` protects
  against crashing on malformed JSON (a data-shape concern), while
  `_isValidSavedGame` protects against restoring a structurally well-typed but
  game-rule-invalid state (e.g. a 4-letter answer from an older app version with a
  different word length), which is a game-logic concern belonging to the screen, not the
  model.
- **Alternatives considered**: Folding the length/count checks into `fromJson` itself —
  rejected because `fromJson`'s job (per Constitution Principle III) is defensive
  *parsing*, not game-rule validation; keeping them separate lets `fromJson` stay a
  simple, reusable, rule-agnostic parser.

## Decision: Uppercase-normalize restored guesses

- **Decision**: `fromJson` uppercases `currentGuess` and every entry in `guesses` while
  reading them.
- **Rationale**: Keeps restored data consistent with the case convention the rest of the
  app (word list, engine) already uses, regardless of what case a previous app version
  might have saved.
- **Alternatives considered**: Leaving case as-saved and normalizing at every later use
  site — rejected as more scattered than normalizing once at the boundary where the data
  enters the app.

## Decision: Testing approach

- **Decision**: Unit tests for `SavedGame.fromJson`'s defensive defaults (missing/
  wrong-typed fields) directly on the model; `GameStorage.loadGame`/`saveGame` round-trip
  tests (extending the existing `game_storage_test.dart` pattern); widget tests pumping
  `GameScreen` with a pre-saved valid game (confirming restoration) and pre-saved
  structurally invalid games (confirming a fresh round starts instead).
- **Rationale**: Separates the model's parsing guarantee from the screen's
  validation-and-restore behavior, testing each at the layer it belongs to.
- **Alternatives considered**: Testing restoration only at the widget level — rejected as
  it wouldn't isolate `fromJson`'s own defensive-parsing guarantee from
  `_isValidSavedGame`'s game-rule guarantee.
