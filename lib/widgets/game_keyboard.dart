import 'package:flutter/material.dart';

import '../models/game_state.dart';
import '../theme/game_colors.dart';

class GameKeyboard extends StatelessWidget {
  const GameKeyboard({
    super.key,
    required this.onLetterTap,
    required this.onBackspaceTap,
    required this.onEnterTap,
    required this.canSubmit,
    this.keyStatuses = const {},
  });

  final ValueChanged<String> onLetterTap;
  final VoidCallback onBackspaceTap;
  final VoidCallback onEnterTap;
  final bool canSubmit;
  final Map<String, LetterStatus> keyStatuses;

  static const _rows = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M', 'BACKSPACE'],
  ];
  static const _keyGap = 4.0;
  static const _maxKeyboardWidth = 520.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final keyboardWidth = constraints.maxWidth.clamp(
          0.0,
          _maxKeyboardWidth,
        );

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: _rows
              .map<Widget>((row) {
                final units = row.fold<double>(
                  0,
                  (total, key) => total + _keyUnits(key),
                );
                final availableKeyWidth =
                    (keyboardWidth - (_keyGap * (row.length - 1))).clamp(
                      0.0,
                      _maxKeyboardWidth,
                    );
                final keyUnit = availableKeyWidth / units;
                final keyHeight = keyUnit.clamp(36.0, 48.0);

                return Padding(
                  padding: EdgeInsets.only(bottom: row == _rows.last ? 0 : 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: row.map((letter) {
                      final isBackspace = letter == 'BACKSPACE';
                      final status = keyStatuses[letter] ?? LetterStatus.empty;

                      return Padding(
                        padding: EdgeInsets.only(
                          right: letter == row.last ? 0 : _keyGap,
                        ),
                        child: SizedBox(
                          width: keyUnit * _keyUnits(letter),
                          height: keyHeight,
                          child: FilledButton(
                            onPressed: switch (letter) {
                              'BACKSPACE' => onBackspaceTap,
                              _ => () => onLetterTap(letter),
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: _backgroundColor(
                                context,
                                status,
                              ),
                              foregroundColor: _foregroundColor(
                                context,
                                status,
                              ),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: isBackspace
                                ? const Icon(Icons.backspace_outlined, size: 18)
                                : FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      letter,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              })
              .followedBy([
                const SizedBox(height: 10),
                SizedBox(
                  width: keyboardWidth.clamp(0.0, 360.0),
                  height: 48,
                  child: FilledButton(
                    onPressed: canSubmit ? onEnterTap : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: GameColors.keyboardDefault,
                      disabledBackgroundColor: GameColors.absent,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: GameColors.absentKeyboardText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ])
              .toList(),
        );
      },
    );
  }

  double _keyUnits(String letter) {
    return letter == 'BACKSPACE' ? 1.65 : 1;
  }

  Color? _backgroundColor(BuildContext context, LetterStatus status) {
    return switch (status) {
      LetterStatus.empty => GameColors.keyboardDefault,
      LetterStatus.correct => GameColors.correct,
      LetterStatus.present => GameColors.present,
      LetterStatus.absent => GameColors.absent,
    };
  }

  Color? _foregroundColor(BuildContext context, LetterStatus status) {
    return switch (status) {
      LetterStatus.absent => GameColors.absentKeyboardText,
      _ => Colors.white,
    };
  }
}
