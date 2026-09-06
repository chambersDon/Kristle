# Implementation Plan: Branding Pass

**Branch**: `018-branding-pass` | **Date**: 2026-09-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/018-branding-pass/spec.md`

## Summary

Render `Image.asset('assets/kristle_header.png', ...)` as the app bar's title (in place
of a plain text title) and add an inert bottom `Container` styled as a placeholder bar
("Might Be An Ad One day") with no `onTap`/gesture handling. This plan implements the
header-image title and bottom placeholder bar in
[lib/screens/game_screen.dart](../../lib/screens/game_screen.dart) and declares
[assets/kristle_header.png](../../assets/kristle_header.png) under `pubspec.yaml`'s
`flutter.assets`, per ROADMAP.md item 18.

## Technical Context

**Language/Version**: Dart, SDK `^3.11.5`

**Primary Dependencies**: Flutter SDK (`Image.asset`, `Container`)

**Testing**: `flutter_test` widget tests asserting the header image widget and the
placeholder bar's presence/inertness

**Target Platform**: All six configured Flutter targets (Constitution Principle IV)

**Constraints**: Purely additive presentation — no gameplay behavior changes

**Scale/Scope**: The app bar title and one bottom `Container` in `GameScreen`; one
`pubspec.yaml` asset declaration

## Constitution Check

- **I. Layered Architecture** — PASS. Purely presentational; no game-rule logic.
- **II. Test-First Development** — PASS. Failing widget tests for the header image and
  the inert placeholder bar are written before implementation.
- **III. Immutable State** — N/A.
- **IV/V/VI** — PASS.

No violations.

## Project Structure

```text
lib/screens/game_screen.dart       # header image title / placeholder bar
assets/kristle_header.png          # header art asset
pubspec.yaml                       # asset declaration
test/widget_test.dart              # widget tests for branding presence
```

**Structure Decision**: No new files beyond the already-referenced asset.

## Complexity Tracking

*No violations — table not applicable.*
