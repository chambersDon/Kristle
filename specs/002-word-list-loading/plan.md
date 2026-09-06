# Implementation Plan: Word List Loading & Validation

**Branch**: `002-word-list-loading` | **Date**: 2026-09-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/002-word-list-loading/spec.md`

## Summary

Load two bundled 5-letter word-list text assets (`assets/words/kristle_answers.txt`,
`assets/words/allowed_guesses.txt`) into an immutable `WordList` value (answers as a
`List<String>`, allowed guesses as a `Set<String>` that always includes every answer),
validating each non-blank/non-comment line is exactly 5 letters (throwing a
`FormatException` naming the offending list on failure, and a `StateError` if the answer
list ends up empty), normalizing everything to uppercase for case-insensitive matching,
and exposing a random-answer picker and an allowed-guess check. This plan implements the
`WordList` service in [lib/services/word_list.dart](../../lib/services/word_list.dart)
per ROADMAP.md item 2.

## Technical Context

**Language/Version**: Dart, SDK `^3.11.5` (per [pubspec.yaml](../../pubspec.yaml))

**Primary Dependencies**: Flutter SDK (`flutter/services.dart` for `AssetBundle`/
`rootBundle`); `dart:math` (`Random`) for answer selection; no third-party packages

**Storage**: N/A — read-only bundled text assets, no persistence written by this feature

**Testing**: `flutter_test` unit tests (`test/word_list_test.dart`) constructing
`WordList` via `WordList.fromText(...)` against in-memory strings, no widget pump needed

**Target Platform**: All six configured Flutter targets — Android, iOS, web, Windows,
macOS, Linux (single codebase, per Constitution Principle IV); asset bundling works
identically on all of them via `rootBundle`

**Project Type**: Mobile/desktop/web app (single Flutter package)

**Performance Goals**: Standard one-time startup asset load (~13k total lines across both
files); no feature-specific performance target beyond loading before the first frame that
needs a word

**Constraints**: Must not introduce scoring, persistence, or UI logic — this feature is
strictly loading, validating, and exposing the two word lists (`WordList.load`,
`WordList.fromText`, `pickRandomAnswer`, `isAllowedGuess`)

**Scale/Scope**: One model/service class (`WordList`), two bundled asset files; no
screens, widgets, or storage are in scope

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **I. Layered Architecture** — PASS. `WordList` lives in `lib/services/` and contains no
  widget dependencies; it depends only on the narrow `AssetBundle` platform surface
  (injectable via an optional `bundle` parameter) and exposes a plain `const` constructor
  plus a `WordList.fromText` factory, so it is directly instantiable in tests without a
  widget tree.
- **II. Test-First Development (NON-NEGOTIABLE)** — PASS. This feature requires writing
  failing unit tests (`test/word_list_test.dart`) for `WordList`'s parsing, validation,
  case-insensitivity, random-pick, and allowed-guess behavior before implementing
  `WordList` in `lib/services/word_list.dart`, then writing the minimum code to make them
  pass.
- **III. Immutable State & Defensive Serialization** — PARTIAL/N/A. `WordList` itself is
  an immutable value (`final` fields, no mutation after construction), but it is
  intentionally *not* defensively-parsed — malformed word-list entries MUST throw
  (`FormatException`/`StateError`) per FR-002/FR-005, rather than falling back to a safe
  default. This is a deliberate exception to the "never throws on malformed data" clause,
  which applies to *persisted* app state (`GameStats`/`SavedGame`, written by a possibly
  older app version), not to bundled, developer-controlled word-list assets where a
  malformed entry indicates a build-time data bug that should fail loudly. See Complexity
  Tracking.
- **IV. Single Codebase, All Platforms** — PASS. `WordList.load` uses `rootBundle`
  uniformly; no `Platform.isX` branching.
- **V. Local-First, No Backend** — PASS. Word lists are bundled assets loaded on-device;
  no network call.
- **VI. Lint-Clean, Analyzer-Enforced Style** — PASS. No new lint suppressions required.

No blocking violations. One deliberate, justified exception to Principle III is recorded
in Complexity Tracking below.

## Project Structure

### Documentation (this feature)

```text
specs/002-word-list-loading/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command) — N/A, no external interface
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
lib/
└── services/
    └── word_list.dart          # WordList model+loader — this feature's subject

assets/
└── words/
    ├── kristle_answers.txt     # bundled answer list
    └── allowed_guesses.txt     # bundled allowed-guess list

test/
└── word_list_test.dart         # unit tests for WordList
```

**Structure Decision**: Single Flutter package at the repository root (`lib/`, `test/`,
`assets/`), per Constitution Principle IV and the "Naming" section (this project's `lib/`
*is* its `src/`). No new directories are needed for this feature; `WordList` lives in
[lib/services/word_list.dart](../../lib/services/word_list.dart), alongside the project's
other services.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| `WordList` loading throws on malformed input instead of defensively falling back (Principle III's "never throws" clause) | Word-list assets are bundled at build time and controlled by the developer, not user/runtime data; a malformed entry means the shipped word data itself is broken, and silently dropping/truncating it could let an invalid word reach gameplay (e.g. a truncated answer no guess could ever match) | Defensive fallback (skip bad entries silently) was rejected because it would hide a data-authoring bug until a player encountered an unwinnable/broken round in production, with no error trail pointing at the bad asset line |
