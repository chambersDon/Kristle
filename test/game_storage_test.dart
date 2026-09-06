import 'package:flutter_test/flutter_test.dart';
import 'package:my_wordle/models/game_state.dart';
import 'package:my_wordle/models/game_stats.dart';
import 'package:my_wordle/models/saved_game.dart';
import 'package:my_wordle/services/game_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('saves and loads the current game', () async {
    const storage = GameStorage();
    const savedGame = SavedGame(
      gameNumber: 2,
      answer: 'KRIST',
      guesses: ['ABCDE'],
      currentGuess: 'KI',
      status: GameStatus.playing,
    );

    await storage.saveGame(savedGame);

    final loadedGame = await storage.loadGame();

    expect(loadedGame?.gameNumber, 2);
    expect(loadedGame?.answer, 'KRIST');
    expect(loadedGame?.guesses, ['ABCDE']);
    expect(loadedGame?.currentGuess, 'KI');
    expect(loadedGame?.status, GameStatus.playing);
  });

  test('loadGame returns null when nothing has been saved', () async {
    const storage = GameStorage();

    final loadedGame = await storage.loadGame();

    expect(loadedGame, isNull);
  });

  test('loadStats returns brand-new stats when nothing has been saved', () async {
    const storage = GameStorage();

    final loadedStats = await storage.loadStats();

    expect(loadedStats.played, 0);
    expect(loadedStats.wins, 0);
    expect(loadedStats.currentStreak, 0);
    expect(loadedStats.maxStreak, 0);
    expect(loadedStats.guessDistribution, [0, 0, 0, 0, 0, 0]);
  });

  test('saves and loads game stats', () async {
    const storage = GameStorage();
    const stats = GameStats(
      played: 3,
      wins: 2,
      currentStreak: 1,
      maxStreak: 2,
      guessDistribution: [0, 1, 0, 1, 0, 0],
    );

    await storage.saveStats(stats);

    final loadedStats = await storage.loadStats();

    expect(loadedStats.played, 3);
    expect(loadedStats.wins, 2);
    expect(loadedStats.currentStreak, 1);
    expect(loadedStats.maxStreak, 2);
    expect(loadedStats.guessDistribution, [0, 1, 0, 1, 0, 0]);
  });
}
