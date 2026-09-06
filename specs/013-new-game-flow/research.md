# Phase 0 Research: New Game Flow

## Decision: Visibility keyed on `_status`

- **Decision**: The "New Game" control renders only in the branch of the message row
  that's shown when `_status != playing`.
- **Rationale**: Satisfies FR-001 directly — reusing the same status check the play loop
  (item 7) already uses to gate input means the control's visibility can never drift out
  of sync with whether the round has actually ended.
- **Alternatives considered**: A separate `_roundEnded` boolean field — rejected as
  redundant with `_status`, which already fully encodes this.

## Decision: Reset relies on existing derived state

- **Decision**: `_startNewGame` only resets the primitive fields it owns
  (`_answer`, `_guesses`, `_currentGuess`, `_message`, `_status`,
  `_headerTapCount`/`_answerTapCount`/`_isAnswerRevealed`) plus canceling win-image
  timers; it does not separately touch keyboard colors.
- **Rationale**: Satisfies FR-005 "for free" — item 8's `_keyStatuses` getter recomputes
  from `_guesses` on every build, so clearing `_guesses` already resets every key to its
  default color with no additional code path to maintain or get out of sync.
- **Alternatives considered**: An explicit `_keyStatuses = {}` reset — not applicable;
  `_keyStatuses` is a getter, not a field, so there is nothing to reset independently.

## Decision: Testing approach

- **Decision**: `flutter_test` widget tests that end a round (win or loss), assert the
  "New Game" control is present, tap it, and then assert: guesses/current guess are
  empty, all keyboard keys are back to default color, any message is cleared, and reveal
  state is reset; a separate test asserts the control is absent while a round is in
  progress.
- **Rationale**: Exercises the full reset through the real UI path, the same way a
  player triggers it.
- **Alternatives considered**: Asserting on private `GameScreen` state directly — not
  possible; the rendered widget tree is the externally-observable equivalent.
