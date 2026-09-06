class GameStats {
  const GameStats({
    this.played = 0,
    this.wins = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.guessDistribution = const [0, 0, 0, 0, 0, 0],
  });

  final int played;
  final int wins;
  final int currentStreak;
  final int maxStreak;
  final List<int> guessDistribution;

  double get winPercent {
    if (played == 0) {
      return 0;
    }

    return wins / played * 100;
  }

  GameStats recordWin(int guessCount) {
    final updatedDistribution = List<int>.of(guessDistribution);
    if (guessCount >= 1 && guessCount <= updatedDistribution.length) {
      updatedDistribution[guessCount - 1]++;
    }

    final newStreak = currentStreak + 1;
    return copyWith(
      played: played + 1,
      wins: wins + 1,
      currentStreak: newStreak,
      maxStreak: newStreak > maxStreak ? newStreak : maxStreak,
      guessDistribution: updatedDistribution,
    );
  }

  GameStats recordLoss() {
    return copyWith(played: played + 1, currentStreak: 0);
  }

  GameStats copyWith({
    int? played,
    int? wins,
    int? currentStreak,
    int? maxStreak,
    List<int>? guessDistribution,
  }) {
    return GameStats(
      played: played ?? this.played,
      wins: wins ?? this.wins,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      guessDistribution: guessDistribution ?? this.guessDistribution,
    );
  }

  Map<String, Object> toJson() {
    return {
      'played': played,
      'wins': wins,
      'currentStreak': currentStreak,
      'maxStreak': maxStreak,
      'guessDistribution': guessDistribution,
    };
  }

  factory GameStats.fromJson(Map<String, Object?> json) {
    return GameStats(
      played: _readInt(json['played']),
      wins: _readInt(json['wins']),
      currentStreak: _readInt(json['currentStreak']),
      maxStreak: _readInt(json['maxStreak']),
      guessDistribution: _readDistribution(json['guessDistribution']),
    );
  }

  static int _readInt(Object? value) {
    return value is int ? value : 0;
  }

  static List<int> _readDistribution(Object? value) {
    if (value is! List) {
      return const [0, 0, 0, 0, 0, 0];
    }

    final distribution = value
        .map((entry) => entry is int ? entry : 0)
        .take(6)
        .toList();

    while (distribution.length < 6) {
      distribution.add(0);
    }

    return distribution;
  }
}
