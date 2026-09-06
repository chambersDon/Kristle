# Phase 0 Research: Game Statistics Model

## Decision: `copyWith` as the sole mutation mechanism

- **Decision**: `recordWin`/`recordLoss` compute new field values and delegate to
  `copyWith` to construct the result, rather than building a new `GameStats(...)`
  directly.
- **Rationale**: Satisfies FR-004/Constitution Principle III with one clear update
  pattern; `copyWith` also gives every future caller a general-purpose immutable update
  path beyond just win/loss recording.
- **Alternatives considered**: Constructing a new `GameStats(...)` inline in each method
  — rejected as it would require repeating every field's "keep or change" logic instead
  of reusing `copyWith`'s defaults.

## Decision: Guess-count distribution indexing and bounds

- **Decision**: `recordWin(guessCount)` increments `guessDistribution[guessCount - 1]`
  only when `guessCount` is between 1 and the distribution's length (6) inclusive;
  outside that range, the distribution is left unchanged while played/wins/streak still
  update.
- **Rationale**: Satisfies FR-002/the edge case for an out-of-range guess count —
  defends the distribution against an invalid index without silently corrupting or
  crashing on a caller bug, while still recording the win itself.
- **Alternatives considered**: Throwing on an out-of-range guess count — rejected as
  overly strict for a stats-recording call; the rest of the update is still meaningful
  even if the distribution entry can't be attributed.

## Decision: Defensive `fromJson` via small typed readers

- **Decision**: `fromJson` reads each scalar field through a `_readInt` helper
  (`value is int ? value : 0`) and the distribution through a `_readDistribution` helper
  that returns the 6-entry default unless given a `List`, then maps each entry through
  `entry is int ? entry : 0`, takes the first 6, and pads with zeros if short.
- **Rationale**: Satisfies FR-007/FR-008/SC-004 with small, focused, reusable checks
  rather than one large try/catch — each field's fallback is explicit and impossible to
  accidentally skip.
- **Alternatives considered**: Wrapping the whole `fromJson` body in a single
  `try { ... } catch { return const GameStats(); }` — rejected because a single
  malformed field would then discard every *other* valid field too, instead of only
  falling back on the field that's actually wrong (a stronger, more precise guarantee).

## Decision: Testing approach

- **Decision**: `flutter_test` unit tests constructing `GameStats` directly (no widget
  pump needed) and exercising `recordWin`/`recordLoss`/`winPercent`/`toJson`/`fromJson`
  with both well-formed and deliberately malformed maps.
- **Rationale**: `GameStats` is a pure Dart value with no Flutter dependency, matching
  Constitution Principle I's testability goal.
- **Alternatives considered**: Testing only through `GameStorage`'s round-trip (already
  covered by `game_storage_test.dart`) — rejected as insufficient; that only exercises
  well-formed data, not the defensive-parsing guarantees this feature is specifically
  about.
