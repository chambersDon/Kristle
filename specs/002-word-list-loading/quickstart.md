# Quickstart: Word List Loading & Validation

## Prerequisites

- Flutter SDK matching `environment.sdk: ^3.11.5` in [pubspec.yaml](../../pubspec.yaml)
- Dependencies fetched: `flutter pub get`
- Bundled assets present and declared in `pubspec.yaml`:
  [assets/words/kristle_answers.txt](../../assets/words/kristle_answers.txt),
  [assets/words/allowed_guesses.txt](../../assets/words/allowed_guesses.txt)

## Try it

```dart
final wordList = await WordList.load();
final answer = wordList.pickRandomAnswer();
print(wordList.isAllowedGuess(answer)); // true
```

Expected outcome: `WordList.load()` resolves without error, `pickRandomAnswer()` returns
a 5-letter uppercase word drawn from the bundled answer list, and that word is always
reported as an allowed guess.

## Validate with tests

```bash
flutter test test/word_list_test.dart
```

This feature's acceptance criteria (FR-001–FR-008, SC-001–SC-004) are validated by unit
tests that construct `WordList` via `WordList.fromText(...)` against small in-memory
strings and assert:

1. A well-formed answers/allowed-guesses pair loads successfully.
2. Guess checks are case-insensitive (e.g. `"krist"` and `"KRIST"` behave identically).
3. Loaded words are normalized to uppercase.
4. `pickRandomAnswer` always returns a member of `answers`.
5. Blank lines and `#`-comment lines are skipped without error.
6. A line that is not exactly 5 letters throws a `FormatException` identifying the
   offending list.
7. An answers source with no valid words (after skipping blanks/comments) throws a
   `StateError`.
8. A word present only in `answers` (not separately listed in the allowed-guesses
   source) is still reported as an allowed guess.

See [spec.md](spec.md) for the full acceptance scenarios and [data-model.md](data-model.md)
for the `WordList` shape and validation rules.
