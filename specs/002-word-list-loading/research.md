# Phase 0 Research: Word List Loading & Validation

No `NEEDS CLARIFICATION` markers remain in the Technical Context — the decisions below
resolve every open design question for `WordList` before implementation begins.

## Decision: Validation strategy (fail-fast vs. defensive skip)

- **Decision**: Reject the whole load with a thrown error (`FormatException` for a
  malformed word, `StateError` for an empty answer list) rather than silently skipping
  bad entries.
- **Rationale**: The word lists are build-time bundled assets, not user- or
  network-supplied data. A malformed entry (wrong length, non-letter characters) is a
  data-authoring bug that should be caught immediately — ideally at test/build time —
  rather than silently degrading gameplay (e.g. a dropped answer, or a guess list that
  looks fine but is missing entries).
- **Alternatives considered**: Defensive skip-and-log (matching the "never throws" style
  used for persisted app state like `GameStats`/`SavedGame`) — rejected because that
  pattern exists specifically to tolerate data written by a *previous app version*, which
  does not apply to a word list shipped and controlled entirely within the current build.
  This distinction is recorded as a deliberate Constitution Principle III exception in
  [plan.md](plan.md)'s Complexity Tracking.

## Decision: Case handling

- **Decision**: Normalize every loaded word (and every word passed to
  `isAllowedGuess`) to uppercase before storing/comparing.
- **Rationale**: Guarantees case-insensitive behavior (FR-004) with a single
  normalization point rather than case-insensitive comparisons scattered across call
  sites.
- **Alternatives considered**: Case-insensitive `Set`/comparator (e.g. a custom
  `Equality`) — rejected as unnecessary complexity when upfront normalization is simpler
  and just as correct for this data (no need to preserve original casing anywhere).

## Decision: Guaranteeing every answer is an allowed guess

- **Decision**: After parsing both lists, union the answer list into the allowed-guesses
  `Set` (`..addAll(answers)`).
- **Rationale**: Satisfies FR-008 (every answer must be guessable) without requiring the
  allowed-guess asset file to duplicate every answer-list entry, which would be a
  maintenance burden and a source of drift between the two files.
- **Alternatives considered**: Checking membership in *either* list at guess-check time
  (`allowedGuesses.contains(x) || answers.contains(x)`) — rejected as functionally
  equivalent but slower (two lookups on every guess check) and less clear than
  pre-computing one authoritative set at load time.

## Decision: Randomization source

- **Decision**: `dart:math`'s `Random`, injectable via an optional constructor parameter
  on `pickRandomAnswer` for deterministic testing.
- **Rationale**: Sufficient per the spec's Assumptions (no cryptographic requirement);
  injectable `Random` lets tests assert "the returned word is a list member" and exercise
  specific seeds deterministically without flaking.
- **Alternatives considered**: A cryptographically secure RNG (`Random.secure()`) —
  rejected as unnecessary for picking a game's answer word, and it cannot be seeded for
  deterministic tests.

## Decision: Testing approach

- **Decision**: `flutter_test` unit tests constructing `WordList` via
  `WordList.fromText(...)` against small in-memory strings (no asset bundle needed),
  covering: known-good load, case-insensitivity, uppercase normalization, random-pick
  membership, comment/blank-line skipping, and (new) malformed-entry and empty-list
  failure cases.
- **Rationale**: Decoupling `fromText` parsing from `AssetBundle` I/O (Constitution
  Principle I) lets tests run fast and deterministically without touching real asset
  files.
- **Alternatives considered**: Loading the real bundled asset files in tests via
  `rootBundle` — rejected as slower, dependent on the Flutter test binding, and
  redundant with `fromText` tests already covering parsing logic; a full-asset smoke test
  is unnecessary for unit coverage of this feature's behavior.
