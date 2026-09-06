# Phase 0 Research: Physical Keyboard Support

## Decision: Reuse existing entry methods

- **Decision**: `_handleKeyEvent` calls the same `_addLetter`/`_removeLetter`/
  `_submitGuess` methods the on-screen keyboard calls, rather than a parallel
  implementation.
- **Rationale**: Guarantees FR-002–FR-004/SC-002 (identical behavior across input
  methods) by construction — there is only one implementation of "add a letter" to
  diverge from.
- **Alternatives considered**: A separate physical-input code path — rejected as an
  obvious source of behavioral drift between input methods.

## Decision: Letter detection via `keyLabel`

- **Decision**: Treat a key as a letter if `event.logicalKey.keyLabel.toUpperCase()` is
  exactly one character matching `[A-Z]`.
- **Rationale**: `keyLabel` already reflects the pressed key's textual identity across
  platforms without needing a hand-maintained map of `LogicalKeyboardKey.keyA`..`keyZ`
  constants; the single-character + regex check naturally excludes Backspace, Enter, and
  other named keys (FR-005).
- **Alternatives considered**: An explicit switch over `LogicalKeyboardKey.keyA`
  through `keyZ` — rejected as more verbose for the same result.

## Decision: Only handle key-down events

- **Decision**: `_handleKeyEvent` returns early for any event that is not a
  `KeyDownEvent` (ignoring key-up/repeat-adjacent events at the Flutter API level).
- **Rationale**: Avoids double-handling a single logical press when the platform also
  delivers key-up events through the same listener.
- **Alternatives considered**: Handling all `KeyEvent` subtypes — rejected as it would
  risk adding a letter or backspacing twice per physical press on some platforms.

## Decision: Testing approach

- **Decision**: `flutter_test` widget tests using `tester.sendKeyEvent(LogicalKeyboardKey.x)`
  to simulate physical presses, asserting the same outcomes as the equivalent on-screen
  tap tests.
- **Rationale**: `sendKeyEvent` is Flutter's standard test API for physical key
  simulation and exercises the real `KeyboardListener` wiring, not a mocked shortcut.
- **Alternatives considered**: Calling `_handleKeyEvent` directly — not possible (it's
  private and only reachable through the widget's key-event pipeline).
