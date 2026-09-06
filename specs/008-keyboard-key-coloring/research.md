# Phase 0 Research: Keyboard Key-Status Coloring

## Decision: Rank via an integer scale

- **Decision**: Map each `LetterStatus` to an integer (`empty`→0, `absent`→1,
  `present`→2, `correct`→3) and keep the max seen per letter.
- **Rationale**: Turns "never downgrade, correct beats present beats absent" (FR-001,
  FR-003) into a simple `if (rank(new) > rank(existing))` comparison, with no special
  casing per status pair.
- **Alternatives considered**: An explicit priority list with pairwise comparisons —
  rejected as more code for the same result.

## Decision: Recompute from scratch each render

- **Decision**: `_keyStatuses` is a getter that re-scores every guess in `_guesses` on
  each access, rather than an incrementally-updated field.
- **Rationale**: `_guesses` is small (max 6 entries), so recomputing is cheap and avoids
  a second source of truth that could drift from `_guesses`.
- **Alternatives considered**: Maintaining a running map updated only when a guess is
  submitted — rejected as an unnecessary optimization that adds a place for the map to
  get out of sync with `_guesses`.

## Decision: Testing approach

- **Decision**: Widget tests submitting a real sequence of guesses through `GameScreen`
  and reading resulting key colors via `GameKeyboard`'s rendered buttons.
- **Rationale**: Exercises the actual integration point (screen computing the map,
  keyboard rendering it), not just the keyboard's own rendering (already covered by
  item 6's tests).
- **Alternatives considered**: Unit-testing a hypothetically extracted pure function —
  rejected; `_keyStatuses` is a private getter on `GameScreen`'s state and this project's
  established pattern tests such behavior at the widget level.
