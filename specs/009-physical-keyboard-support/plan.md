# Implementation Plan: Physical Keyboard Support

**Branch**: `009-physical-keyboard-support` | **Date**: 2026-09-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/009-physical-keyboard-support/spec.md`

## Summary

Wrap the game board in a `KeyboardListener` with an autofocus `FocusNode`, handling
`KeyDownEvent`s in `_handleKeyEvent`: `LogicalKeyboardKey.backspace` calls
`_removeLetter()`, `LogicalKeyboardKey.enter` calls `_submitGuess()`, and any key whose
`keyLabel` is a single A–Z character calls `_addLetter(label)` — anything else is
ignored. This plan implements the `_handleKeyEvent`/`KeyboardListener` slice of
[lib/screens/game_screen.dart](../../lib/screens/game_screen.dart) per ROADMAP.md item 9,
reusing the same `_addLetter`/`_removeLetter`/`_submitGuess` methods the on-screen
keyboard already calls (item 7), so both input paths share identical behavior including
the round-ended lockout.

## Technical Context

**Language/Version**: Dart, SDK `^3.11.5`

**Primary Dependencies**: Flutter SDK (`KeyboardListener`, `FocusNode`,
`LogicalKeyboardKey`, `flutter/services.dart`)

**Testing**: `flutter_test` widget tests using `WidgetTester.sendKeyEvent`

**Target Platform**: All six configured Flutter targets (Constitution Principle IV) —
physical keyboard input is most relevant on desktop/web but the listener is harmless on
mobile

**Constraints**: Must reuse the existing `_addLetter`/`_removeLetter`/`_submitGuess`
methods rather than duplicating their logic for a second input path

**Scale/Scope**: One event handler (`_handleKeyEvent`) and its `KeyboardListener` wiring
in `GameScreen`

## Constitution Check

- **I. Layered Architecture** — PASS. `_handleKeyEvent` only translates key events into
  calls to `_addLetter`/`_removeLetter`/`_submitGuess`; it contains no game-rule logic of
  its own.
- **II. Test-First Development** — PASS. Failing widget tests using `sendKeyEvent` are
  written before implementation.
- **III. Immutable State** — N/A.
- **IV/V/VI** — PASS.

No violations.

## Project Structure

```text
lib/screens/game_screen.dart   # _handleKeyEvent / KeyboardListener wiring
test/widget_test.dart          # widget tests using WidgetTester.sendKeyEvent
```

**Structure Decision**: No new files.

## Complexity Tracking

*No violations — table not applicable.*
