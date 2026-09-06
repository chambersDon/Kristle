import 'dart:math';

import 'package:flutter/services.dart';

class WordList {
  const WordList({required this.answers, required this.allowedGuesses});

  final List<String> answers;
  final Set<String> allowedGuesses;

  static const answersAssetPath = 'assets/words/kristle_answers.txt';
  static const allowedGuessesAssetPath = 'assets/words/allowed_guesses.txt';

  static Future<WordList> load({AssetBundle? bundle}) async {
    final assetBundle = bundle ?? rootBundle;
    final answersText = await assetBundle.loadString(answersAssetPath);
    final allowedGuessesText = await assetBundle.loadString(
      allowedGuessesAssetPath,
    );

    return WordList.fromText(
      answersText: answersText,
      allowedGuessesText: allowedGuessesText,
    );
  }

  factory WordList.fromText({
    required String answersText,
    required String allowedGuessesText,
  }) {
    final answers = _parseWords(answersText, listName: 'answers').toList();
    final allowedGuesses = _parseWords(
      allowedGuessesText,
      listName: 'allowed guesses',
    ).toSet()..addAll(answers);

    if (answers.isEmpty) {
      throw StateError('The answer word list is empty.');
    }

    return WordList(answers: answers, allowedGuesses: allowedGuesses);
  }

  String pickRandomAnswer({Random? random}) {
    final answerPicker = random ?? Random();
    return answers[answerPicker.nextInt(answers.length)];
  }

  bool isAllowedGuess(String guess) {
    return allowedGuesses.contains(guess.toUpperCase());
  }

  static Iterable<String> _parseWords(String text, {required String listName}) {
    return text
        .split('\n')
        .map((line) => line.trim().toUpperCase())
        .where((word) => word.isNotEmpty && !word.startsWith('#'))
        .map((word) {
          if (!RegExp(r'^[A-Z]{5}$').hasMatch(word)) {
            throw FormatException(
              'Invalid word in $listName list: "$word". '
              'Words must be exactly five letters.',
            );
          }

          return word;
        });
  }
}
