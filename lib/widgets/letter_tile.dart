import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/game_state.dart';
import '../theme/game_colors.dart';

class LetterTile extends StatefulWidget {
  const LetterTile({
    super.key,
    this.letter = '',
    this.status = LetterStatus.empty,
    this.revealDelay = Duration.zero,
  });

  final String letter;
  final LetterStatus status;
  final Duration revealDelay;

  @override
  State<LetterTile> createState() => _LetterTileState();
}

class _LetterTileState extends State<LetterTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _revealController;
  Timer? _revealTimer;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      value: widget.status == LetterStatus.empty ? 0 : 1,
    );
  }

  @override
  void didUpdateWidget(LetterTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.status == widget.status) {
      return;
    }

    _revealTimer?.cancel();

    if (widget.status == LetterStatus.empty) {
      _revealController.value = 0;
      return;
    }

    _revealTimer = Timer(widget.revealDelay, () {
      if (!mounted || widget.status == LetterStatus.empty) {
        return;
      }

      _revealController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.status == LetterStatus.empty) {
      return _TileFace(letter: widget.letter, status: widget.status);
    }

    return AnimatedBuilder(
      animation: _revealController,
      builder: (context, child) {
        final progress = _revealController.value;
        final showingRevealedFace = progress >= 0.5;
        final status = showingRevealedFace ? widget.status : LetterStatus.empty;
        final angle = showingRevealedFace
            ? math.pi * (1 - progress)
            : math.pi * progress;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(angle),
          child: _TileFace(letter: widget.letter, status: status),
        );
      },
    );
  }
}

class _TileFace extends StatelessWidget {
  const _TileFace({required this.letter, required this.status});

  final String letter;
  final LetterStatus status;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _backgroundColor();
    final foregroundColor = status == LetterStatus.empty
        ? Theme.of(context).colorScheme.onSurface
        : Colors.white;

    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: _borderColor(context, backgroundColor),
            width: _borderWidth,
          ),
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              color: foregroundColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Color _backgroundColor() {
    return switch (status) {
      LetterStatus.empty => GameColors.tileEmpty,
      LetterStatus.correct => GameColors.correct,
      LetterStatus.present => GameColors.present,
      LetterStatus.absent => GameColors.absent,
    };
  }

  Color _borderColor(BuildContext context, Color backgroundColor) {
    if (status != LetterStatus.empty) {
      return backgroundColor;
    }

    if (letter.isNotEmpty) {
      return Theme.of(context).colorScheme.outline;
    }

    return Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.55);
  }

  double get _borderWidth {
    return status == LetterStatus.empty && letter.isEmpty ? 1 : 2;
  }
}
