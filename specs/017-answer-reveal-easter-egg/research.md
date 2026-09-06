# Phase 0 Research: Answer-Reveal Easter Egg

## Decision: Two independent counters

- **Decision**: `_headerTapCount` counts taps on the header image; `_answerTapCount`
  counts taps on the revealed answer text — separate fields, only one of which is ever
  actively incrementing depending on `_isAnswerRevealed`.
- **Rationale**: Satisfies FR-001/FR-002/the edge case cleanly — since only one of the
  two surfaces is visible/tappable at a time, there is no ambiguity about which counter a
  tap should affect, and keeping them separate avoids needing to distinguish "reveal
  taps" from "hide taps" within one shared counter.
- **Alternatives considered**: A single counter with a sign or direction flag — rejected
  as more complex than two plain counters for the same result.

## Decision: `bool.fromEnvironment` for the compile-time flag

- **Decision**: `AppConfig.enableAnswerReveal = bool.fromEnvironment('KRISTLE_ENABLE_ANSWER_REVEAL',
  defaultValue: true)`.
- **Rationale**: Satisfies FR-004/FR-005 — `bool.fromEnvironment` is resolved at compile
  time, so a release build passing `--dart-define=KRISTLE_ENABLE_ANSWER_REVEAL=false`
  fully compiles out the `true` branch's dead code paths, matching Constitution's
  Technology Stack guidance for compile-time toggles.
- **Alternatives considered**: A runtime settings flag (e.g. read from
  `SharedPreferences`) — rejected; the spec explicitly calls for a compile-time flag, not
  a user-facing or runtime-configurable setting.

## Decision: Reset via `_startNewGame`, not a separate hook

- **Decision**: `_startNewGame()` directly resets `_headerTapCount`, `_answerTapCount`,
  and `_isAnswerRevealed` alongside its other round-state resets.
- **Rationale**: Satisfies FR-003/User Story 3 — reusing the single existing "start a new
  round" entry point (item 13) guarantees the reveal state can never be left stale after
  a new game, without needing a second reset path to keep in sync.
- **Alternatives considered**: Listening for answer changes and resetting reactively —
  rejected as more indirect than resetting directly in the one method that already
  changes the answer.

## Decision: Testing approach

- **Decision**: `flutter_test` widget tests tapping `find.byKey(const Key('header-image'))`
  and `find.byKey(const Key('revealed-answer'))` five times each to cross the
  reveal/hide thresholds, plus a test pumping `KristleApp(enableAnswerReveal: false)` and
  confirming five taps produce no reveal, and a test confirming "New Game" resets
  mid-progress taps.
- **Rationale**: Exercises the feature through the real UI the same way a developer
  would trigger it; these tests already exist in this project's `test/widget_test.dart`
  and are being confirmed/extended, not introduced from scratch.
- **Alternatives considered**: None — this matches the project's existing, proven test
  pattern for this exact feature.
