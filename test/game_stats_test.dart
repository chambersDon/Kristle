import 'package:flutter_test/flutter_test.dart';
import 'package:my_wordle/models/game_stats.dart';

void main() {
  group('recordWin / recordLoss', () {
    test('recordWin increments played, wins, and currentStreak', () {
      const stats = GameStats();
      final result = stats.recordWin(3);

      expect(result.played, 1);
      expect(result.wins, 1);
      expect(result.currentStreak, 1);
    });

    test('recordLoss increments played, resets streak, leaves wins alone', () {
      const stats = GameStats(played: 2, wins: 2, currentStreak: 2, maxStreak: 2);
      final result = stats.recordLoss();

      expect(result.played, 3);
      expect(result.wins, 2);
      expect(result.currentStreak, 0);
    });

    test('recordWin(n) increments guessDistribution[n - 1]', () {
      const stats = GameStats();
      final result = stats.recordWin(3);

      expect(result.guessDistribution, [0, 0, 1, 0, 0, 0]);
    });

    test('maxStreak updates when currentStreak surpasses it', () {
      const stats = GameStats(currentStreak: 2, maxStreak: 2);
      final result = stats.recordWin(1);

      expect(result.currentStreak, 3);
      expect(result.maxStreak, 3);
    });

    test('maxStreak stays put when currentStreak does not surpass it', () {
      const stats = GameStats(currentStreak: 0, maxStreak: 5);
      final result = stats.recordWin(1);

      expect(result.currentStreak, 1);
      expect(result.maxStreak, 5);
    });

    test(
      'recordWin with an out-of-range guess count leaves the distribution '
      'unchanged but still updates played/wins/streak',
      () {
        const stats = GameStats();

        final tooLow = stats.recordWin(0);
        expect(tooLow.guessDistribution, [0, 0, 0, 0, 0, 0]);
        expect(tooLow.played, 1);
        expect(tooLow.wins, 1);
        expect(tooLow.currentStreak, 1);

        final tooHigh = stats.recordWin(7);
        expect(tooHigh.guessDistribution, [0, 0, 0, 0, 0, 0]);
        expect(tooHigh.played, 1);
      },
    );
  });

  group('winPercent', () {
    test('is zero when no games have been played', () {
      const stats = GameStats();
      expect(stats.winPercent, 0);
    });

    test('equals wins / played * 100', () {
      const stats = GameStats(played: 4, wins: 3);
      expect(stats.winPercent, 75.0);
    });
  });

  group('JSON serialization', () {
    test('round-trips a fully-populated value exactly', () {
      const stats = GameStats(
        played: 10,
        wins: 7,
        currentStreak: 2,
        maxStreak: 4,
        guessDistribution: [1, 2, 1, 2, 1, 0],
      );

      final restored = GameStats.fromJson(stats.toJson());

      expect(restored.played, stats.played);
      expect(restored.wins, stats.wins);
      expect(restored.currentStreak, stats.currentStreak);
      expect(restored.maxStreak, stats.maxStreak);
      expect(restored.guessDistribution, stats.guessDistribution);
    });

    test('fromJson({}) matches a brand-new GameStats', () {
      final restored = GameStats.fromJson({});
      const fresh = GameStats();

      expect(restored.played, fresh.played);
      expect(restored.wins, fresh.wins);
      expect(restored.currentStreak, fresh.currentStreak);
      expect(restored.maxStreak, fresh.maxStreak);
      expect(restored.guessDistribution, fresh.guessDistribution);
    });

    test('falls back to defaults for missing fields', () {
      final restored = GameStats.fromJson({'played': 5});

      expect(restored.played, 5);
      expect(restored.wins, 0);
      expect(restored.currentStreak, 0);
      expect(restored.maxStreak, 0);
      expect(restored.guessDistribution, [0, 0, 0, 0, 0, 0]);
    });

    test('falls back to defaults for wrong-typed fields without throwing', () {
      final restored = GameStats.fromJson({
        'played': 'five',
        'wins': null,
        'currentStreak': 3.5,
        'maxStreak': [1, 2],
        'guessDistribution': 'not a list',
      });

      expect(restored.played, 0);
      expect(restored.wins, 0);
      expect(restored.currentStreak, 0);
      expect(restored.maxStreak, 0);
      expect(restored.guessDistribution, [0, 0, 0, 0, 0, 0]);
    });

    test('normalizes a malformed distribution to 6 numeric entries', () {
      final tooShort = GameStats.fromJson({
        'guessDistribution': [1, 2],
      });
      expect(tooShort.guessDistribution, [1, 2, 0, 0, 0, 0]);

      final tooLong = GameStats.fromJson({
        'guessDistribution': [1, 2, 3, 4, 5, 6, 7, 8],
      });
      expect(tooLong.guessDistribution, [1, 2, 3, 4, 5, 6]);

      final withNonNumeric = GameStats.fromJson({
        'guessDistribution': [1, 'two', null, 4, 5, 6],
      });
      expect(withNonNumeric.guessDistribution, [1, 0, 0, 4, 5, 6]);
    });
  });
}
