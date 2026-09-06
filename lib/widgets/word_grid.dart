import 'package:flutter/material.dart';

import '../models/game_state.dart';
import '../services/game_engine.dart';
import 'letter_tile.dart';

class WordGrid extends StatelessWidget {
  const WordGrid({
    super.key,
    required this.answer,
    this.guesses = const [],
    this.currentGuess = '',
    this.gameEngine = const GameEngine(),
  });

  final String answer;
  final List<String> guesses;
  final String currentGuess;
  final GameEngine gameEngine;

  static const rowCount = 6;
  static const columnCount = 5;
  static const _tileGap = 6.0;
  static const _maxTileSize = 70.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxBoardWidth = columnCount * _maxTileSize;
        final availableWidth = constraints.maxWidth;
        final widthBasedTileSize =
            (availableWidth.clamp(0.0, maxBoardWidth) -
                (_tileGap * (columnCount - 1))) /
            columnCount;
        final heightBasedTileSize =
            (constraints.maxHeight - (_tileGap * (rowCount - 1))) / rowCount;
        final maxHeightBasedTileSize = heightBasedTileSize.clamp(
          0.0,
          _maxTileSize,
        );
        final tileSize = widthBasedTileSize.clamp(0.0, maxHeightBasedTileSize);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(rowCount, (rowIndex) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: rowIndex == rowCount - 1 ? 0 : _tileGap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(columnCount, (columnIndex) {
                  final letter = _letterAt(rowIndex, columnIndex);
                  final status = _statusAt(rowIndex, columnIndex);
                  final revealDelay = rowIndex < guesses.length
                      ? Duration(milliseconds: columnIndex * 110)
                      : Duration.zero;

                  return Padding(
                    padding: EdgeInsets.only(
                      right: columnIndex == columnCount - 1 ? 0 : _tileGap,
                    ),
                    child: SizedBox.square(
                      dimension: tileSize,
                      child: LetterTile(
                        letter: letter,
                        status: status,
                        revealDelay: revealDelay,
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        );
      },
    );
  }

  String _letterAt(int rowIndex, int columnIndex) {
    final word = _wordAt(rowIndex);
    if (columnIndex >= word.length) {
      return '';
    }

    return word[columnIndex];
  }

  LetterStatus _statusAt(int rowIndex, int columnIndex) {
    if (rowIndex >= guesses.length) {
      return LetterStatus.empty;
    }

    final guess = guesses[rowIndex];
    if (columnIndex >= guess.length) {
      return LetterStatus.empty;
    }

    return gameEngine.scoreGuess(guess: guess, answer: answer)[columnIndex];
  }

  String _wordAt(int rowIndex) {
    if (rowIndex < guesses.length) {
      return guesses[rowIndex];
    }

    if (rowIndex == guesses.length) {
      return currentGuess;
    }

    return '';
  }
}
