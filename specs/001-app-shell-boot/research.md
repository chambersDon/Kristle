# Phase 0 Research: App Shell Boot

No `NEEDS CLARIFICATION` markers remain in the Technical Context — this feature reproduces
an existing, already-decided implementation, so research consists of confirming the current
code rather than evaluating alternatives.

## Decision: Where `KristleApp` lives

- **Decision**: Treat [lib/main.dart](../../lib/main.dart) as the sole source of the app
  shell (`KristleApp` widget + `main()` entry point).
- **Rationale**: [lib/app.dart](../../lib/app.dart) is present in the working tree but empty
  (0 bytes of content). `KristleApp` — the `MaterialApp` with `title: 'Kristle'`,
  `ColorScheme.fromSeed(seedColor: Colors.green)`, and `useMaterial3: true` — is fully defined
  in `main.dart` today.
- **Alternatives considered**: Splitting `KristleApp` out into `lib/app.dart` (matching the
  roadmap's original file pointer) was considered, but the roadmap's own rules state specs
  "MUST be written to reproduce the *exact* existing implementation" and that
  `/speckit-implement` "writes no application code" for features targeting existing code —
  moving code between files is a refactor, not this feature's scope. Rejected for this
  feature; may be revisited separately if the empty `lib/app.dart` file is intentional
  groundwork for a future split.

## Decision: Theme approach

- **Decision**: Material 3 (`useMaterial3: true`) with a single seed color
  (`Colors.green`) via `ColorScheme.fromSeed`.
- **Rationale**: Already implemented; matches Constitution's Technology Stack (Flutter/Dart)
  and gives a cohesive, low-maintenance theme (one seed color drives the whole palette)
  appropriate for a small, local-first game.
- **Alternatives considered**: Custom/manual `ColorScheme` construction — rejected as
  unnecessary complexity versus the existing single-seed approach, and it's not what the
  shipped code does.

## Decision: Testing approach

- **Decision**: `flutter_test` widget test that pumps `KristleApp` and asserts on
  `MaterialApp.title` and the resolved `ThemeData`/`ColorScheme` seed, independent of
  `GameScreen` internals.
- **Rationale**: Matches Constitution Principle I (testable without a full widget tree of
  gameplay features) and Principle II (TDD) using the project's sole test framework.
- **Alternatives considered**: Golden-image tests — rejected as overkill for verifying a
  title string and theme configuration; existing project has no golden test precedent.
