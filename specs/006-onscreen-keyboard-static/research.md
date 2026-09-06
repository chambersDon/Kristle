# Phase 0 Research: On-Screen Keyboard (Static)

No `NEEDS CLARIFICATION` markers remain in the Technical Context — the decisions below
resolve every open design question for the static `GameKeyboard` before implementation
begins.

## Decision: Layout data

- **Decision**: Represent the three QWERTY rows as a fixed, literal list of letter
  lists, with `'BACKSPACE'` as a sentinel entry in the last row instead of a 27th letter.
- **Rationale**: A literal, hand-written layout is simplest and matches the well-known,
  fixed QWERTY arrangement (FR-001) — no need for a generated or configurable layout.
  Using a sentinel string keeps backspace in the same row-building loop as the letters
  rather than requiring a separate widget tree branch.
- **Alternatives considered**: A separate, explicitly-typed backspace-key widget outside
  the row loop — rejected as more code for the same visual result; the sentinel approach
  still keeps backspace and letters clearly distinguishable in the tap-reporting callback
  (FR-004).

## Decision: Reporting taps via callbacks

- **Decision**: Three required callbacks — `onLetterTap(String)`, `onBackspaceTap()`,
  `onEnterTap()` — invoked directly from each key's `onPressed`.
- **Rationale**: Keeps `GameKeyboard` a pure, stateless reporter of user intent
  (Constitution Principle I) — it does not know or care what a "guess in progress" is;
  that belongs to whatever owns the callbacks (a later roadmap feature, the core play
  loop).
- **Alternatives considered**: A single `onKeyTap(String key)` callback with special
  sentinel values for backspace/enter — rejected as less type-safe and less
  self-documenting than three distinctly-named callbacks.

## Decision: Submit control enabled state

- **Decision**: A required `canSubmit` boolean controls the submit `FilledButton`'s
  `onPressed`: `canSubmit ? onEnterTap : null`.
- **Rationale**: Setting `onPressed` to `null` is Flutter's standard way to disable a
  button (it also updates the button's visual disabled state automatically), directly
  satisfying FR-006/FR-007. The keyboard itself doesn't count letters — the "5 letters
  entered" condition (FR-006) is computed by the caller and handed in as `canSubmit`,
  keeping `GameKeyboard` free of game-state knowledge.
- **Alternatives considered**: Having `GameKeyboard` accept the current guess length
  itself and compute enabled-ness internally — rejected as it would give the keyboard an
  opinion about the game's rules (e.g. "5 letters"), which belongs to the play loop, not
  the keyboard widget.

## Decision: Sizing strategy

- **Decision**: A `LayoutBuilder` computes available per-row width, distributes it across
  each row's keys (weighting the backspace key wider than a letter key), and clamps key
  height to a sensible min/max range.
- **Rationale**: Satisfies FR-009/SC-004 — keys must never overflow a narrow container,
  and must not become absurdly tall on a very wide one.
- **Alternatives considered**: Fixed-size keys — rejected because a fixed size would
  overflow on narrow screens, which the spec's edge case explicitly rules out.

## Decision: Testing approach

- **Decision**: `flutter_test` widget tests constructing `GameKeyboard` directly (wrapped
  in a minimal `MaterialApp`/`Scaffold`) with fake callbacks recording what was reported,
  covering: full alphabet presence, letter/backspace/submit tap reporting, submit
  enabled/disabled state, and layout at a few different container widths.
- **Rationale**: `GameKeyboard` needs no game state, word list, or engine to exercise —
  only its own callbacks and `canSubmit` flag — keeping tests isolated to this feature's
  scope (Constitution Principle I).
- **Alternatives considered**: Testing the keyboard only indirectly through the full game
  screen — rejected because it would entangle this feature's tests with the play loop's
  (a later feature), making failures harder to attribute.
