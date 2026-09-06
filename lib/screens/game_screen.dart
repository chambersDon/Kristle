import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/game_state.dart';
import '../models/game_stats.dart';
import '../models/saved_game.dart';
import '../services/game_engine.dart';
import '../services/game_storage.dart';
import '../services/word_list.dart';
import '../theme/game_colors.dart';
import '../widgets/game_keyboard.dart';
import '../widgets/word_grid.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.wordList,
    required this.enableAnswerReveal,
    this.storage = const GameStorage(),
  });

  final WordList wordList;
  final bool enableAnswerReveal;
  final GameStorage storage;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  static const _gameEngine = GameEngine();

  final FocusNode _keyboardFocusNode = FocusNode();
  final List<String> _guesses = [];
  final Random _random = Random();
  late final AnimationController _shakeController;
  Timer? _winImageShowTimer;
  Timer? _winImageHideTimer;
  int _gameNumber = 0;
  late String _answer;
  String _currentGuess = '';
  String _message = '';
  GameStatus _status = GameStatus.playing;
  GameStats _stats = const GameStats();
  int _headerTapCount = 0;
  int _answerTapCount = 0;
  bool _isAnswerRevealed = false;
  bool _showWinImage = false;

  @override
  void initState() {
    super.initState();
    _answer = widget.wordList.pickRandomAnswer(random: _random);
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    unawaited(_loadSavedData());
  }

  @override
  void dispose() {
    _winImageShowTimer?.cancel();
    _winImageHideTimer?.cancel();
    _shakeController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _addLetter(String letter) {
    if (_status != GameStatus.playing) {
      return;
    }

    if (_currentGuess.length == WordGrid.columnCount) {
      return;
    }

    setState(() {
      _currentGuess += letter;
      _message = '';
    });
    _saveCurrentGame();
  }

  void _removeLetter() {
    if (_status != GameStatus.playing) {
      return;
    }

    if (_currentGuess.isEmpty) {
      return;
    }

    setState(() {
      _currentGuess = _currentGuess.substring(0, _currentGuess.length - 1);
      _message = '';
    });
    _saveCurrentGame();
  }

  void _submitGuess() {
    if (_status != GameStatus.playing) {
      return;
    }

    if (_currentGuess.length != WordGrid.columnCount) {
      _shakeGrid();
      setState(() {
        _message = 'Enter a 5-letter word';
      });
      return;
    }

    if (_guesses.length == WordGrid.rowCount) {
      return;
    }

    if (!widget.wordList.isAllowedGuess(_currentGuess)) {
      _shakeGrid();
      setState(() {
        _message = 'That word is not in the word list';
      });
      return;
    }

    setState(() {
      final submittedGuess = _currentGuess;
      final isWin = submittedGuess == _answer;

      _guesses.add(submittedGuess);
      _currentGuess = '';
      _message = '';

      if (isWin) {
        _status = GameStatus.won;
        _stats = _stats.recordWin(_guesses.length);
        _showWinImage = false;
        _scheduleWinImage();
      } else if (_guesses.length == WordGrid.rowCount) {
        _status = GameStatus.lost;
        _stats = _stats.recordLoss();
      }
    });
    _saveCurrentGame();
    unawaited(widget.storage.saveStats(_stats));
  }

  void _startNewGame() {
    _cancelWinImageTimers();
    setState(() {
      _gameNumber++;
      _answer = widget.wordList.pickRandomAnswer(random: _random);
      _guesses.clear();
      _currentGuess = '';
      _message = '';
      _status = GameStatus.playing;
      _headerTapCount = 0;
      _answerTapCount = 0;
      _isAnswerRevealed = false;
      _showWinImage = false;
    });
    _saveCurrentGame();
  }

  void _shakeGrid() {
    _shakeController.forward(from: 0);
  }

  void _handleHeaderTap() {
    if (!widget.enableAnswerReveal) {
      return;
    }

    setState(() {
      if (_isAnswerRevealed) {
        _answerTapCount++;
        if (_answerTapCount >= 5) {
          _isAnswerRevealed = false;
          _headerTapCount = 0;
          _answerTapCount = 0;
        }
        return;
      }

      _headerTapCount++;
      if (_headerTapCount >= 5) {
        _isAnswerRevealed = true;
        _answerTapCount = 0;
      }
    });
  }

  void _scheduleWinImage() {
    _cancelWinImageTimers();
    _winImageShowTimer = Timer(const Duration(milliseconds: 1000), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _showWinImage = true;
      });

      _winImageHideTimer = Timer(const Duration(seconds: 2), () {
        if (!mounted) {
          return;
        }

        setState(() {
          _showWinImage = false;
        });
      });
    });
  }

  void _cancelWinImageTimers() {
    _winImageShowTimer?.cancel();
    _winImageHideTimer?.cancel();
  }

  Future<void> _loadSavedData() async {
    final loadedStats = await widget.storage.loadStats();
    final loadedGame = await widget.storage.loadGame();

    if (!mounted) {
      return;
    }

    setState(() {
      _stats = loadedStats;

      if (loadedGame != null && _isValidSavedGame(loadedGame)) {
        _gameNumber = loadedGame.gameNumber;
        _answer = loadedGame.answer;
        _guesses
          ..clear()
          ..addAll(loadedGame.guesses);
        _currentGuess = loadedGame.currentGuess;
        _status = loadedGame.status;
      }
    });
  }

  bool _isValidSavedGame(SavedGame game) {
    return game.answer.length == WordGrid.columnCount &&
        game.guesses.length <= WordGrid.rowCount &&
        game.currentGuess.length <= WordGrid.columnCount;
  }

  void _saveCurrentGame() {
    unawaited(
      widget.storage.saveGame(
        SavedGame(
          gameNumber: _gameNumber,
          answer: _answer,
          guesses: List<String>.of(_guesses),
          currentGuess: _currentGuess,
          status: _status,
        ),
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return;
    }

    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      _removeLetter();
      return;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      _submitGuess();
      return;
    }

    final label = event.logicalKey.keyLabel.toUpperCase();
    if (label.length == 1 && RegExp('[A-Z]').hasMatch(label)) {
      _addLetter(label);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        title: GestureDetector(
          onTap: _handleHeaderTap,
          child: _isAnswerRevealed
              ? Text(
                  _answer,
                  key: const Key('revealed-answer'),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                )
              : Image.asset(
                  'assets/kristle_header.png',
                  key: const Key('header-image'),
                  fit: BoxFit.contain,
                  height: 80,
                ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          KeyboardListener(
            focusNode: _keyboardFocusNode,
            autofocus: true,
            onKeyEvent: _handleKeyEvent,
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: ShakeTransition(
                              animation: _shakeController,
                              child: WordGrid(
                                answer: _answer,
                                guesses: _guesses,
                                currentGuess: _currentGuess,
                              ),
                            ),
                          ),
                        ),
                        if (_showWinImage)
                          Positioned.fill(
                            child: ColoredBox(
                              color: Colors.black38,
                              child: Center(
                                child: Image.asset(
                                  'assets/you_won.png',
                                  width: 340,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 320,
                                      height: 220,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: GameColors.correct,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Text(
                                        'You Won!',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 38,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: Center(
                      child: _status == GameStatus.playing
                          ? Text(
                              _message.isEmpty ? _statsSummary : _message,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_status == GameStatus.lost)
                                  Text(
                                    _statusMessage,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                if (_status == GameStatus.lost)
                                  const SizedBox(width: 12),
                                FilledButton(
                                  onPressed: _startNewGame,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: GameColors.keyboardDefault,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('New Game'),
                                ),
                              ],
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: GameKeyboard(
                      onLetterTap: _addLetter,
                      onBackspaceTap: _removeLetter,
                      onEnterTap: _submitGuess,
                      canSubmit: _canSubmit,
                      keyStatuses: _keyStatuses,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 48,
                    margin: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Might Be An Ad One day',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _statusMessage {
    return switch (_status) {
      GameStatus.playing => '',
      GameStatus.won => '',
      GameStatus.lost => 'The answer was $_answer',
    };
  }

  String get _statsSummary {
    return 'Played ${_stats.played} | Wins ${_stats.wins} | Streak ${_stats.currentStreak}';
  }

  bool get _canSubmit =>
      _status == GameStatus.playing &&
      _currentGuess.length == WordGrid.columnCount;

  Map<String, LetterStatus> get _keyStatuses {
    final statuses = <String, LetterStatus>{};

    for (final guess in _guesses) {
      final scoredGuess = _gameEngine.scoreGuess(guess: guess, answer: _answer);

      for (var i = 0; i < guess.length; i++) {
        final letter = guess[i];
        final status = scoredGuess[i];
        final existingStatus = statuses[letter];

        if (existingStatus == null ||
            _statusRank(status) > _statusRank(existingStatus)) {
          statuses[letter] = status;
        }
      }
    }

    return statuses;
  }

  int _statusRank(LetterStatus status) {
    return switch (status) {
      LetterStatus.empty => 0,
      LetterStatus.absent => 1,
      LetterStatus.present => 2,
      LetterStatus.correct => 3,
    };
  }
}

class ShakeTransition extends StatelessWidget {
  const ShakeTransition({
    super.key,
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final progress = animation.value;
        final direction = switch (progress) {
          < 0.17 => -1,
          < 0.34 => 1,
          < 0.50 => -1,
          < 0.67 => 1,
          < 0.84 => -1,
          _ => 0,
        };
        final offset = (1 - progress) * 10 * direction;

        return Transform.translate(
          offset: Offset(offset.toDouble(), 0),
          child: child,
        );
      },
    );
  }
}
