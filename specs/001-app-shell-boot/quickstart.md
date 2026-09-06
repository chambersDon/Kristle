# Quickstart: App Shell Boot

## Prerequisites

- Flutter SDK matching `environment.sdk: ^3.11.5` in [pubspec.yaml](../../pubspec.yaml)
- Dependencies fetched: `flutter pub get`

## Run it

```bash
flutter run
```

Expected outcome: the app launches directly to the `GameScreen` inside a Material 3
`MaterialApp` shell — no splash/loading screen — with the window/tab title "Kristle" and a
green-seeded color theme applied consistently (app bar, buttons, etc. all derive from the
same `ColorScheme.fromSeed(seedColor: Colors.green)`).

## Validate with tests

```bash
flutter test test/app_shell_test.dart
```

This feature's acceptance criteria (FR-001–FR-005, SC-001–SC-003) are validated by a widget
test that:

1. Pumps `KristleApp` with a test `WordList`.
2. Asserts exactly one `MaterialApp` is in the tree with `title == 'Kristle'`.
3. Reads the resolved `ThemeData` and asserts `useMaterial3 == true` and that the
   `ColorScheme` was generated from a green seed (e.g. checking `colorScheme.primary`
   matches `ColorScheme.fromSeed(seedColor: Colors.green).primary`).

See [spec.md](spec.md) for the full acceptance scenarios and [plan.md](plan.md) /
[research.md](research.md) for why `main.dart` (not `app.dart`) is treated as the shell's
source of truth.
