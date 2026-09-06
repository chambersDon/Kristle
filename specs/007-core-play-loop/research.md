# Phase 0 Research: Core Play Loop

No `NEEDS CLARIFICATION` markers remain in the Technical Context — the decisions below
resolve every open design question for the play loop before implementation begins.

## Decision: State shape

- **Decision**: Track round state as plain `State` fields on `GameScreen`: `_answer`
  (`String`), `_guesses` (`List<String>`), `_currentGuess` (`String`), `_message`
  (`String`), `_status` (`GameStatus`).
- **Rationale**: These five values are exactly what `WordGrid`/`GameKeyboard` need to
  render and what the play loop needs to make entry/submit decisions; keeping them as
  flat fields (rather than a bundled model) matches this feature's scope, which
  explicitly excludes persistence/serialization (a later feature introduces the
  serializable `SavedGame` model).
- **Alternatives considered**: Introducing a dedicated immutable round-state class now —
  rejected as premature; Constitution Principle III's immutability requirement applies to
  *persisted* models, and this feature has no persistence in scope.

## Decision: Entry guards (`_addLetter`/`_removeLetter`)

- **Decision**: Both methods return immediately (no-op) if `_status != playing`; `_addLetter`
  also returns if `_currentGuess.length == 5`; `_removeLetter` also returns if
  `_currentGuess` is empty.
- **Rationale**: Directly satisfies FR-002/FR-003/FR-010 — a single early-return guard
  per condition is simpler and more obviously correct than clamping/truncating after the
  fact.
- **Alternatives considered**: Silently clamping the guess to 5 characters after
  concatenation — rejected as functionally equivalent but less clear about *why* nothing
  happens past 5 letters.

## Decision: Submission validation order

- **Decision**: In `_submitGuess`, check `_status == playing` first, then length `== 5`,
  then `wordList.isAllowedGuess`, in that order, showing a distinct message for the
  length failure vs. the not-allowed failure.
- **Rationale**: Satisfies FR-004/FR-005 with two distinct, player-facing messages;
  checking length before list membership avoids a wasted lookup for guesses that can't
  possibly be complete anyway.
- **Alternatives considered**: A single generic "invalid guess" message for both
  failures — rejected because the spec calls for the player to understand *why* a guess
  was rejected (too short vs. not a real word), which are different, actionable pieces of
  feedback.

## Decision: Clearing the message on edit

- **Decision**: `_addLetter` and `_removeLetter` both clear `_message` as part of their
  `setState`, independent of whether a message was showing.
- **Rationale**: Satisfies FR-007 — the simplest way to guarantee a stale rejection
  message never lingers past the player's next edit is to unconditionally clear it on
  every successful edit, rather than tracking whether a message needs clearing.
- **Alternatives considered**: Only clearing the message if one is currently set —
  rejected as an unnecessary conditional for the same end result.

## Decision: Win/loss detection

- **Decision**: After appending a submitted guess, check `submittedGuess == answer` for a
  win; else check `_guesses.length == 6` for a loss; both checks happen inside the same
  `setState` that appends the guess.
- **Rationale**: Satisfies FR-008/FR-009 — evaluating both conditions immediately after
  the guess is recorded guarantees the round ends on the exact submission that triggers
  it (SC-003), with no intermediate state where a won/lost round still reads as
  `playing`.
- **Alternatives considered**: Checking win/loss in a separate method called after
  `setState` completes — rejected as an unnecessary indirection; evaluating inline keeps
  the whole "record guess → determine outcome" step atomic within one `setState`.

## Decision: Answer selection on start

- **Decision**: `initState` calls `widget.wordList.pickRandomAnswer()` once to set the
  initial `_answer`.
- **Rationale**: Satisfies FR-001/SC-005 directly — the word list (an existing
  dependency, item 2) already owns "pick a valid random word"; the play loop simply calls
  it rather than re-implementing selection logic.
- **Alternatives considered**: Hard-coding or otherwise special-casing the first
  round's answer — rejected as it would violate FR-001/SC-005's requirement that the
  answer come from the loaded list on every round start, not just subsequent ones.

## Decision: Testing approach

- **Decision**: `flutter_test` widget tests pumping `GameScreen` (via `KristleApp`) with
  a small test `WordList` (a handful of known answers/allowed guesses), driving input by
  tapping the on-screen keyboard's letter/backspace/submit buttons, and asserting on the
  rendered board/message text.
- **Rationale**: Exercises the full wiring (word list → screen → grid/keyboard) the way a
  player actually interacts with it, while keeping the test `WordList` small and known so
  expected outcomes (win, loss, rejection messages) are easy to assert precisely.
- **Alternatives considered**: Unit-testing `GameScreen`'s private methods directly —
  not possible/idiomatic in Dart/Flutter (they're private and state-driven); widget-level
  interaction tests are this project's established pattern for screen-level behavior.
