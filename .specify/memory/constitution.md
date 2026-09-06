<!--
Sync Impact Report
- Version change: 1.1.1 → 1.2.0
- Principles defined:
  1. Layered Architecture (models / services / widgets / screens)
  2. Test-First Development (NON-NEGOTIABLE) — renamed from "Test-First Coverage for Game
     Logic"; now mandates strict TDD ordering (failing test written and confirmed to fail
     before any implementation code), not just eventual coverage
  3. Immutable State & Defensive Serialization
  4. Single Codebase, All Platforms
  5. Local-First, No Backend
  6. Lint-Clean, Analyzer-Enforced Style
- Added sections: none this revision
- Removed sections: none
- Templates requiring updates: .specify/templates/plan-template.md (⚠ verify Constitution
  Check gate references these principle names on next /speckit-plan run),
  .specify/templates/spec-template.md (✅ no changes needed),
  .specify/templates/tasks-template.md (✅ no changes needed)
- Follow-up TODOs: none
-->

# Kristle Constitution

## Core Principles

### I. Layered Architecture
The codebase MUST keep domain logic separate from presentation: `lib/models/` holds plain
data types (e.g. `GameState`, `GameStats`, `SavedGame`) with no Flutter widget dependencies;
`lib/services/` holds behavior (`GameEngine`, `WordList`, `GameStorage`) that widgets call
into but never the reverse; `lib/widgets/` and `lib/screens/` hold presentation only and MUST
NOT contain guess-scoring, persistence, or word-list logic inline. A service class MAY depend
on a narrow platform surface (e.g. `WordList` on `AssetBundle`, `GameStorage` on
`SharedPreferences`) but MUST expose a plain constructor/`const` API so it can be instantiated
directly in tests without a widget tree.
Rationale: this separation is what lets `game_engine_test.dart` and `word_list_test.dart` test
scoring and parsing without pumping a widget, and lets `widget_test.dart` test UI behavior
against fakes/in-memory word lists.

### II. Test-First Development (NON-NEGOTIABLE)
Test-Driven Development is mandatory for every change. For any change to guess scoring,
word-list parsing/validation, save/restore, stats calculation, or user-visible interaction
(keyboard input, physical keyboard shortcuts, win/loss messaging, answer reveal): write the
failing test(s) first — unit tests in `test/` for logic, `flutter_test` widget tests for
interaction — confirm they fail for the expected reason, then write the minimum
implementation to make them pass, then refactor. Implementation code MUST NOT be written
before its corresponding test exists. Tests MUST cover edge cases (duplicate letters,
malformed persisted JSON, empty/short guesses). `flutter test` MUST pass before a change is
considered complete.
Rationale: the existing suite (`game_engine_test.dart`, `game_storage_test.dart`,
`word_list_test.dart`, `widget_test.dart`) is the executable spec for the scoring algorithm
(correct-before-present, duplicate-letter counting) and persistence fallback behavior; losing
that coverage silently reintroduces bugs those tests were written to catch.

### III. Immutable State & Defensive Serialization
Model classes (`GameState` enums, `GameStats`, `SavedGame`) MUST be immutable: fields `final`,
updates via `copyWith`, no in-place mutation. Every persisted model MUST implement `toJson`
and a `fromJson` factory that never throws on missing, wrong-typed, or malformed data —
unknown/invalid fields fall back to a safe default (as `GameStats.fromJson` and
`SavedGame.fromJson` already do) rather than crashing app startup.
Rationale: `GameStorage` reads whatever was last written to `shared_preferences`, including
data from a previous app version; defensive parsing keeps a corrupted or outdated save from
bricking the app on launch.

### IV. Single Codebase, All Platforms
All gameplay and UI logic lives once under `lib/` and MUST run unmodified on every configured
target platform (Android, iOS, web, Windows, macOS, Linux). Platform-specific code is
confined to the generated platform runner directories (`android/`, `ios/`, `web/`, `windows/`,
`macos/`, `linux/`); `lib/` MUST NOT contain `Platform.isX` branches to change gameplay
behavior. Compile-time feature toggles (e.g. the answer-reveal easter egg) go through
`lib/config/app_config.dart` using `bool.fromEnvironment`, not per-platform branching.
Rationale: the project ships build targets for six platforms from one Flutter tree; a
platform-conditional gameplay path would silently diverge behavior no test suite runs against.

### V. Local-First, No Backend
The game MUST be fully playable offline. Word lists ship as bundled assets
(`assets/words/kristle_answers.txt`, `assets/words/allowed_guesses.txt`), the daily/random
answer is picked on-device (`WordList.pickRandomAnswer`), and all game state and statistics
persist locally via `SharedPreferences`/`GameStorage`. No feature may require a network call,
external API, or server-side account to function.
Rationale: this keeps the app simple, private, and dependency-free, matching its current
zero-backend design.

### VI. Lint-Clean, Analyzer-Enforced Style
All Dart code MUST pass `flutter analyze` under the `flutter_lints` rule set configured in
`analysis_options.yaml` with zero warnings before a change is complete. New lint suppressions
(`// ignore:`) require a one-line justification comment and MUST NOT be used to silence
correctness-relevant lints (e.g. unused code, missing null checks).
Rationale: the project has adopted `flutter_lints` deliberately; unreviewed suppressions erode
the signal the linter is there to provide.

## Technology Stack

- Framework: Flutter, Dart SDK constrained by `environment.sdk: ^3.11.5` in `pubspec.yaml`.
- State/persistence: `shared_preferences` for all local storage; no other storage engine
  (database, file I/O, secure storage) may be introduced without a constitution amendment.
- Word data: plain newline-delimited `.txt` assets under `assets/words/`, one 5-letter
  uppercase word per line, `#`-prefixed comment lines allowed; `WordList` is the sole parser
  and validator (`^[A-Z]{5}$`) for these files.
- Testing: `flutter_test` for both pure unit tests and widget tests; no additional test
  framework is to be introduced.
- Tooling: `flutter_lints` for static analysis, `flutter_launcher_icons` for app icon
  generation. New dev dependencies MUST have a concrete, current need — no speculative
  tooling additions.

## Development Workflow

- Run `flutter analyze` and `flutter test` before treating any change as done; both MUST be
  clean/passing.
- New or changed gameplay logic (scoring, word validation, stats, persistence) requires
  accompanying tests per Principle II in the same change — not as follow-up work.
- Compile-time behavior toggles are added to `lib/config/app_config.dart` following the
  existing `bool.fromEnvironment` pattern, keeping default values safe for a normal release
  build.
- Keep `pubspec.yaml`'s `assets` list in sync with any new/renamed files under `assets/`.

## Naming

The product/app name is **Kristle**; this MUST be the only name used in this constitution,
in user-facing text, and in project documentation prose. `MyWordle` is solely the on-disk
repository/folder name (and the legacy Dart package name `my_wordle` it implies) and MUST be
used only where a literal filesystem path, package identifier, or import statement requires
it — never as the product name in prose, UI copy, or docs.

Spec Kit's generic project templates label the application source directory `src/`. This
project's source directory is `lib/`, per Dart/Flutter's package convention: `package:my_wordle/`
imports resolve directly to `lib/` and this mapping is not configurable. `lib/` (with `test/`
as its sibling) IS this project's `src/` — it MUST NOT be renamed or nested under a `src/`
folder, and any spec-kit-generated plan referring to `src/` MUST be read as `lib/` for this
project.

## Governance

This constitution supersedes ad hoc conventions for this project. Amendments are made by
editing `.specify/memory/constitution.md` directly (via `/speckit-constitution`), incrementing
the version per semantic versioning (MAJOR: principle removed/redefined incompatibly; MINOR:
principle or section added or materially expanded; PATCH: clarification/wording only), and
updating the `Last Amended` date below. Every pull request that touches `lib/`, `test/`, or
`assets/words/` MUST be checked against the Core Principles above before merge; a violation
must either be fixed or the constitution amended first — principles are not to be silently
bypassed. Runtime agent guidance for implementing features against this constitution lives in
the Spec Kit templates under `.specify/templates/`.

**Version**: 1.2.0 | **Ratified**: 2026-09-06 | **Last Amended**: 2026-09-06
