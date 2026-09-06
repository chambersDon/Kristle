import 'package:flutter_test/flutter_test.dart';
import 'package:my_wordle/models/game_state.dart';
import 'package:my_wordle/models/saved_game.dart';

void main() {
  test('round-trips a well-formed game exactly through toJson/fromJson', () {
    const game = SavedGame(
      gameNumber: 2,
      answer: 'KRIST',
      guesses: ['ABCDE', 'FGHIJ'],
      currentGuess: 'KR',
      status: GameStatus.playing,
    );

    final restored = SavedGame.fromJson(game.toJson());

    expect(restored.gameNumber, game.gameNumber);
    expect(restored.answer, game.answer);
    expect(restored.guesses, game.guesses);
    expect(restored.currentGuess, game.currentGuess);
    expect(restored.status, game.status);
  });

  test('falls back to safe defaults for missing fields', () {
    final restored = SavedGame.fromJson({});

    expect(restored.gameNumber, 0);
    expect(restored.answer, '');
    expect(restored.guesses, isEmpty);
    expect(restored.currentGuess, '');
    expect(restored.status, GameStatus.playing);
  });

  test('falls back to safe defaults for wrong-typed fields without throwing', () {
    final restored = SavedGame.fromJson({
      'gameNumber': 'two',
      'answer': 12345,
      'guesses': 'not a list',
      'currentGuess': null,
      'status': 42,
    });

    expect(restored.gameNumber, 0);
    expect(restored.answer, '');
    expect(restored.guesses, isEmpty);
    expect(restored.currentGuess, '');
    expect(restored.status, GameStatus.playing);
  });

  test('falls back to playing for an unrecognized status value', () {
    final restored = SavedGame.fromJson({
      'gameNumber': 1,
      'answer': 'KRIST',
      'guesses': <String>[],
      'currentGuess': '',
      'status': 'nonexistent-status',
    });

    expect(restored.status, GameStatus.playing);
  });

  test('uppercases restored guesses and current guess', () {
    final restored = SavedGame.fromJson({
      'gameNumber': 0,
      'answer': 'krist',
      'guesses': ['abcde'],
      'currentGuess': 'kr',
      'status': 'playing',
    });

    expect(restored.guesses, ['ABCDE']);
    expect(restored.currentGuess, 'KR');
  });

  test('ignores non-string entries in a malformed guesses list', () {
    final restored = SavedGame.fromJson({
      'guesses': ['abcde', 42, null, 'fghij'],
    });

    expect(restored.guesses, ['ABCDE', 'FGHIJ']);
  });
}
