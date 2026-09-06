import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_wordle/services/word_list.dart';

void main() {
  final wordList = WordList.fromText(
    answersText: '''
krist
kites
''',
    allowedGuessesText: '''
abcde
kites
krabc
krist
''',
  );

  test('allows known guesses without caring about case', () {
    expect(wordList.isAllowedGuess('krist'), isTrue);
  });

  test('rejects unknown guesses', () {
    expect(wordList.isAllowedGuess('AAAAA'), isFalse);
  });

  test('normalizes loaded words to uppercase', () {
    expect(wordList.answers, ['KRIST', 'KITES']);
    expect(wordList.allowedGuesses, containsAll(['ABCDE', 'KITES', 'KRABC']));
  });

  test('picks a random answer from the answer list', () {
    final answer = wordList.pickRandomAnswer(random: Random(1));

    expect(wordList.answers, contains(answer));
  });

  test('ignores empty lines and comments', () {
    final wordList = WordList.fromText(
      answersText: '''
# Kristle words
KRIST

''',
      allowedGuessesText: '''
# guesses
ABCDE
''',
    );

    expect(wordList.pickRandomAnswer(random: Random(1)), 'KRIST');
    expect(wordList.isAllowedGuess('abcde'), isTrue);
  });

  test('ignores comment lines even when the comment text is not 5 letters', () {
    final wordList = WordList.fromText(
      answersText: '''
# not a valid word at all
KRIST
''',
      allowedGuessesText: '''
# also not a valid word
KRIST
''',
    );

    expect(wordList.answers, ['KRIST']);
  });

  test('trims surrounding whitespace around an otherwise-valid word', () {
    final wordList = WordList.fromText(
      answersText: '  KRIST  \n',
      allowedGuessesText: '  KRIST  \n',
    );

    expect(wordList.answers, ['KRIST']);
    expect(wordList.isAllowedGuess('krist'), isTrue);
  });

  test('is case-insensitive for guesses regardless of mixed casing', () {
    expect(wordList.isAllowedGuess('Krist'), isTrue);
    expect(wordList.isAllowedGuess('KRIST'), isTrue);
    expect(wordList.isAllowedGuess('kRiSt'), isTrue);
  });

  test('throws a FormatException naming the answers list for a malformed entry', () {
    expect(
      () => WordList.fromText(
        answersText: '''
krist
krisss
''',
        allowedGuessesText: 'krist',
      ),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('answers'),
        ),
      ),
    );
  });

  test(
    'throws a FormatException naming the allowed guesses list for a malformed entry',
    () {
      expect(
        () => WordList.fromText(
          answersText: 'krist',
          allowedGuessesText: '''
krist
ab
''',
        ),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('allowed guesses'),
          ),
        ),
      );
    },
  );

  test('throws a StateError when the answer list has zero valid entries', () {
    expect(
      () => WordList.fromText(
        answersText: '''
# no real words here

''',
        allowedGuessesText: 'krist',
      ),
      throwsStateError,
    );
  });

  test('does not always pick the same answer across different seeds', () {
    final multiWordList = WordList.fromText(
      answersText: '''
krist
kites
kraft
''',
      allowedGuessesText: 'krist',
    );

    final picks = List.generate(
      20,
      (i) => multiWordList.pickRandomAnswer(random: Random(i)),
    ).toSet();

    expect(picks.length, greaterThan(1));
  });

  test('reports an answer-only word as an allowed guess', () {
    final wordList = WordList.fromText(
      answersText: '''
krist
kites
''',
      allowedGuessesText: 'abcde',
    );

    expect(wordList.isAllowedGuess('kites'), isTrue);
  });
}
