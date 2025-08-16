import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

class InlineExerciseTimer extends StatelessWidget {
  final int duration; // seconds
  final VoidCallback onCompleted;
  const InlineExerciseTimer({super.key, required this.duration, required this.onCompleted});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return CircularCountDownTimer(
      duration: duration,
      initialDuration: 0,
      controller: CountDownController(),
      width: 40,
      height: 40,
      ringColor: colorScheme.outline.withOpacity(0.3),
      fillColor: colorScheme.primary,
      backgroundColor: colorScheme.surface,
      strokeWidth: 5.0,
      strokeCap: StrokeCap.round,
      isTimerTextShown: true,
      isReverse: false,
      textStyle: textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
      autoStart: true,
      onComplete: onCompleted,
    );
  }
}
