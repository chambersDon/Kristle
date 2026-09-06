# Implementation Plan: Save & Restore In-Progress Game

**Branch**: `016-save-restore-game` | **Date**: 2026-09-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/016-save-restore-game/spec.md`

## Summary

Implement an immutable `SavedGame` model (`gameNumber`, `answer`, `guesses`,
`currentGuess`, `status`) with `toJson()`/`SavedGame.fromJson(...)` that defensively
defaults missing/wrong-typed fields (never throwing), plus
`GameStorage.loadGame()`/`saveGame(SavedGame)`. Wire `GameScreen._saveCurrentGame()` to
call `saveGame` after every `_addLetter`/`_removeLetter`/`_submitGuess`/`_startNewGame`
change, and `_loadSavedData()` to call `loadGame()` at startup, restoring the loaded
game only if `_isValidSavedGame` passes (answer length == 5, guesses.length <= 6,
currentGuess.length <= 5) — otherwise the freshly-picked answer from `initState` stands.
This plan implements
[lib/models/saved_game.dart](../../lib/models/saved_game.dart) and the save/restore
slice of [lib/services/game_storage.dart](../../lib/services/game_storage.dart) and
[lib/screens/game_screen.dart](../../lib/screens/game_screen.dart) per ROADMAP.md item
16.

## Technical Context

**Language/Version**: Dart, SDK `^3.11.5`

**Primary Dependencies**: `shared_preferences`; this project's own `GameStatus` enum

**Storage**: `SharedPreferences`, JSON-encoded, under a fixed key
(`kristle.savedGame.v1`) — local only, per Constitution Principle V

**Testing**: `flutter_test` unit tests for `SavedGame.fromJson`'s defensive parsing and
`GameStorage.loadGame`/`saveGame`; widget tests for restore-on-launch and
reject-invalid-save behavior

**Target Platform**: All six configured Flutter targets (Constitution Principle IV)

**Constraints**: Must never throw when loading saved data, regardless of its shape
(Constitution Principle III)

**Scale/Scope**: One model (`SavedGame`), two `GameStorage` methods, and the
save/restore wiring in `GameScreen`

## Constitution Check

- **I. Layered Architecture** — PASS. `SavedGame` is a plain model in `lib/models/`;
  `GameStorage` (a service) owns persistence; `GameScreen` only calls into both.
- **II. Test-First Development** — PASS. Failing tests for defensive parsing,
  save/load round-trip, valid-save restoration, and invalid-save rejection are written
  before implementation.
- **III. Immutable State & Defensive Serialization** — PASS. `SavedGame` fields are
  `final`; `fromJson` never throws on missing/wrong-typed data (this feature's core
  requirement).
- **IV/V/VI** — PASS. Local-only storage, no platform branching.

No violations.

## Project Structure

```text
lib/models/saved_game.dart       # SavedGame — this feature's subject
lib/services/game_storage.dart   # loadGame / saveGame
lib/screens/game_screen.dart     # _saveCurrentGame / _loadSavedData / _isValidSavedGame
test/game_storage_test.dart      # unit tests for loadGame/saveGame
test/widget_test.dart            # widget tests for restore-on-launch behavior
```

**Structure Decision**: No new files beyond `lib/models/saved_game.dart`, which already
exists per ROADMAP.md's pointer for this item.

## Complexity Tracking

*No violations — table not applicable.*
