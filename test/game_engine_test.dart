import 'package:flutter_test/flutter_test.dart';
import 'package:my_wordle/models/game_state.dart';
import 'package:my_wordle/services/game_engine.dart';

void main() {
  const engine = GameEngine();

  test('scores exact matches as correct', () {
    expect(engine.scoreGuess(guess: 'KRIST', answer: 'KRIST'), [
      LetterStatus.correct,
      LetterStatus.correct,
      LetterStatus.correct,
      LetterStatus.correct,
      LetterStatus.correct,
    ]);
  });

  test('does not mark more present letters than the answer contains', () {
    expect(engine.scoreGuess(guess: 'ALLEY', answer: 'PLANT'), [
      LetterStatus.present,
      LetterStatus.correct,
      LetterStatus.absent,
      LetterStatus.absent,
      LetterStatus.absent,
    ]);
  });

  test('uses correct matches before present matches for duplicate letters', () {
    expect(engine.scoreGuess(guess: 'MAMMA', answer: 'MAXIM'), [
      LetterStatus.correct,
      LetterStatus.correct,
      LetterStatus.present,
      LetterStatus.absent,
      LetterStatus.absent,
    ]);
  });

  test(
    'marks a correctly-placed duplicate correct and the other occurrence '
    'absent when the answer has only one of that letter',
    () {
      expect(engine.scoreGuess(guess: 'AAXYZ', answer: 'ABCDE'), [
        LetterStatus.correct,
        LetterStatus.absent,
        LetterStatus.absent,
        LetterStatus.absent,
        LetterStatus.absent,
      ]);
    },
  );

  test(
    'credits both occurrences of a duplicate letter when the answer also '
    'contains it twice',
    () {
      expect(engine.scoreGuess(guess: 'PUPPY', answer: 'HAPPY'), [
        LetterStatus.absent,
        LetterStatus.absent,
        LetterStatus.correct,
        LetterStatus.correct,
        LetterStatus.correct,
      ]);
    },
  );

  test('scores case-insensitively', () {
    expect(
      engine.scoreGuess(guess: 'krist', answer: 'KRIST'),
      List.filled(5, LetterStatus.correct),
    );
    expect(
      engine.scoreGuess(guess: 'ALLEY', answer: 'plant'),
      engine.scoreGuess(guess: 'alley', answer: 'PLANT'),
    );
  });

  test('throws when the guess and answer are different lengths', () {
    expect(
      () => engine.scoreGuess(guess: 'SHORT', answer: 'LONGER'),
      throwsArgumentError,
    );
  });
}
