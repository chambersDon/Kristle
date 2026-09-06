import '../models/game_state.dart';

class GameEngine {
  const GameEngine();

  List<LetterStatus> scoreGuess({
    required String guess,
    required String answer,
  }) {
    if (guess.length != answer.length) {
      throw ArgumentError.value(
        guess,
        'guess',
        'Guess must be the same length as the answer.',
      );
    }

    final normalizedGuess = guess.toUpperCase();
    final normalizedAnswer = answer.toUpperCase();
    final statuses = List.filled(guess.length, LetterStatus.absent);
    final remainingAnswerLetters = <String, int>{};

    for (var i = 0; i < normalizedAnswer.length; i++) {
      if (normalizedGuess[i] == normalizedAnswer[i]) {
        statuses[i] = LetterStatus.correct;
      } else {
        final answerLetter = normalizedAnswer[i];
        remainingAnswerLetters[answerLetter] =
            (remainingAnswerLetters[answerLetter] ?? 0) + 1;
      }
    }

    for (var i = 0; i < normalizedGuess.length; i++) {
      if (statuses[i] == LetterStatus.correct) {
        continue;
      }

      final guessLetter = normalizedGuess[i];
      final remainingCount = remainingAnswerLetters[guessLetter] ?? 0;
      if (remainingCount > 0) {
        statuses[i] = LetterStatus.present;
        remainingAnswerLetters[guessLetter] = remainingCount - 1;
      }
    }

    return statuses;
  }
}
