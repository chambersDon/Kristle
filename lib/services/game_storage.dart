import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_stats.dart';
import '../models/saved_game.dart';

class GameStorage {
  const GameStorage();

  static const _savedGameKey = 'kristle.savedGame.v1';
  static const _statsKey = 'kristle.stats.v1';

  Future<SavedGame?> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedGame = prefs.getString(_savedGameKey);
    if (encodedGame == null) {
      return null;
    }

    final decodedGame = jsonDecode(encodedGame);
    if (decodedGame is! Map<String, Object?>) {
      return null;
    }

    return SavedGame.fromJson(decodedGame);
  }

  Future<void> saveGame(SavedGame game) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_savedGameKey, jsonEncode(game.toJson()));
  }

  Future<GameStats> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedStats = prefs.getString(_statsKey);
    if (encodedStats == null) {
      return const GameStats();
    }

    final decodedStats = jsonDecode(encodedStats);
    if (decodedStats is! Map<String, Object?>) {
      return const GameStats();
    }

    return GameStats.fromJson(decodedStats);
  }

  Future<void> saveStats(GameStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, jsonEncode(stats.toJson()));
  }
}
