# Phase 1 Data Model: Core Play Loop

## Round state (GameScreen fields)

| Field | Type | Description |
|---|---|---|
| `_answer` | `String` | The round's answer, chosen once at start via `wordList.pickRandomAnswer()` (FR-001). |
| `_guesses` | `List<String>` | Guesses successfully submitted so far, in order. |
| `_currentGuess` | `String` | The in-progress guess being typed, 0–5 letters. |
| `_message` | `String` | An inline rejection message, or empty when there is nothing to show. |
| `_status` | `GameStatus` | `playing`, `won`, or `lost`. |

**Transitions**:

- **Start**: `_answer` set from `wordList.pickRandomAnswer()`; `_guesses` empty,
  `_currentGuess` empty, `_message` empty, `_status = playing` (FR-001).
- **Type a letter** (`_status == playing` only): if `_currentGuess.length < 5`, append
  the letter and clear `_message`; otherwise no-op (FR-002, FR-007).
- **Backspace** (`_status == playing` only): if `_currentGuess` is non-empty, drop its
  last character and clear `_message`; otherwise no-op (FR-003, FR-007).
- **Submit** (`_status == playing` only):
  - If `_currentGuess.length != 5`: set `_message` to a length-rejection message; no
    other state changes (FR-004).
  - Else if `!wordList.isAllowedGuess(_currentGuess)`: set `_message` to a
    not-recognized-word rejection message; no other state changes (FR-005).
  - Else: append `_currentGuess` to `_guesses`, clear `_currentGuess` and `_message`;
    if the appended guess equals `_answer`, set `_status = won`; else if `_guesses.length
    == 6`, set `_status = lost` (FR-006, FR-008, FR-009).
- **Any action once `_status != playing`**: no-op (FR-010).

**Relationships**: Reads from `WordList` (`pickRandomAnswer`, `isAllowedGuess`) and
`GameEngine` indirectly via `WordGrid` (which scores each submitted guess for display).
Drives `WordGrid` (via `answer`/`guesses`/`currentGuess`) and `GameKeyboard` (via
`onLetterTap`/`onBackspaceTap`/`onEnterTap`/`canSubmit`). Does not itself persist any of
this state — that is a later roadmap feature.
