# Phase 0 Research: Stats Persistence & Summary Display

## Decision: Default to `const GameStats()` when nothing is saved or saved data is bad

- **Decision**: `loadStats()` returns `const GameStats()` if no value is stored under
  its key, or if the stored value fails to decode as a `Map`.
- **Rationale**: Satisfies FR-001/SC-001 and the edge case for corrupted data — combined
  with `GameStats.fromJson`'s own defensive parsing (item 14), this guarantees `loadStats`
  never throws regardless of what's actually stored.
- **Alternatives considered**: Propagating a decode error to the caller — rejected;
  Constitution Principle III requires persisted-model loading to never crash app
  startup.

## Decision: Save on every completion, not on a timer or app-close hook

- **Decision**: `saveStats(_stats)` is called synchronously (fire-and-forget via
  `unawaited`) right after `_stats` is updated in both the win and loss branches of
  `_submitGuess`.
- **Rationale**: Satisfies FR-002/SC-002 with the simplest correct trigger — a completed
  round is the only event that changes lifetime stats, so saving exactly there guarantees
  the persisted value is never stale for longer than necessary.
- **Alternatives considered**: Saving periodically or only on app lifecycle pause —
  rejected as it risks losing an update if the app is killed before the next save point.

## Decision: Summary only replaces the "nothing to say" slot

- **Decision**: The message row shows `_message.isEmpty ? _statsSummary : _message`
  while `_status == playing`, and a different (New Game) row entirely once the round has
  ended.
- **Rationale**: Satisfies FR-003/FR-004 — the summary is exactly the fallback content
  for that one display slot, so it can never simultaneously show alongside or instead of
  a rejection message or the end-of-round control.
- **Alternatives considered**: Showing the summary in a separate, always-visible row —
  rejected as an unrequested layout change; the spec calls for a single-line summary "in
  progress," using the same slot rejection messages already occupy.

## Decision: Testing approach

- **Decision**: `flutter_test` unit tests for `GameStorage.loadStats`/`saveStats`
  (mirroring the existing `game_storage_test.dart` pattern) covering the
  nothing-saved-yet default and the save-then-load round trip; widget tests pumping
  `GameScreen` with pre-saved stats and asserting the summary text while playing, and its
  absence once a message or the end-of-round control is showing.
- **Rationale**: Matches this project's established persistence and widget test
  patterns.
- **Alternatives considered**: None — this is a straightforward extension of existing,
  already-proven test patterns for this service and screen.
