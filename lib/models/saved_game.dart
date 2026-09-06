import 'game_state.dart';

class SavedGame {
  const SavedGame({
    required this.gameNumber,
    required this.answer,
    required this.guesses,
    required this.currentGuess,
    required this.status,
  });

  final int gameNumber;
  final String answer;
  final List<String> guesses;
  final String currentGuess;
  final GameStatus status;

  Map<String, Object> toJson() {
    return {
      'gameNumber': gameNumber,
      'answer': answer,
      'guesses': guesses,
      'currentGuess': currentGuess,
      'status': status.name,
    };
  }

  factory SavedGame.fromJson(Map<String, Object?> json) {
    return SavedGame(
      gameNumber: json['gameNumber'] is int ? json['gameNumber']! as int : 0,
      answer: json['answer'] is String ? json['answer']! as String : '',
      guesses: json['guesses'] is List
          ? (json['guesses']! as List)
                .whereType<String>()
                .map((guess) => guess.toUpperCase())
                .toList()
          : const [],
      currentGuess: json['currentGuess'] is String
          ? (json['currentGuess']! as String).toUpperCase()
          : '',
      status: GameStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => GameStatus.playing,
      ),
    );
  }
}
