import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

class ExerciseTimer {
  static void showRestTimer(BuildContext context, CountDownController timerController) {
    int duration = 60;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: colorScheme.surface,
              title: Text(
                "Rest Timer",
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularCountDownTimer(
                    duration: duration,
                    initialDuration: 0,
                    controller: timerController,
                    width: 120,
                    height: 120,
                    ringColor: colorScheme.outline.withOpacity(0.3),
                    fillColor: colorScheme.primary,
                    backgroundColor: colorScheme.surface,
                    strokeWidth: 10.0,
                    strokeCap: StrokeCap.round,
                    isTimerTextShown: true,
                    isReverse: true,
                    textStyle: textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface, // visible!
                    ),
                    onComplete: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                        onPressed: () {
                          duration += 10;
                          timerController.restart(duration: duration);
                          setState(() {});
                        },
                        child: Text("+10s", style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onPrimary,
                        )),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.secondary,
                          foregroundColor: colorScheme.onSecondary,
                        ),
                        onPressed: () {
                          if (duration > 10) {
                            duration -= 10;
                            timerController.restart(duration: duration);
                            setState(() {});
                          }
                        },
                        child: Text("-10s", style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSecondary,
                        )),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => timerController.pause(),
                  child: Text(
                    "Pause",
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,  // <--- final fix
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => timerController.resume(),
                  child: Text(
                    "Resume",
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,  // <--- final fix
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Close",
                    style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.error
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}