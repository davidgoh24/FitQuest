import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/workout_session_service.dart';

class WorkoutTimerOverlay extends StatefulWidget {
  const WorkoutTimerOverlay({Key? key}) : super(key: key);

  @override
  _WorkoutTimerOverlayState createState() => _WorkoutTimerOverlayState();
}

class _WorkoutTimerOverlayState extends State<WorkoutTimerOverlay> {
  late final StreamSubscription<Duration> _subscription;
  String _formattedTime = "00:00:00";

  @override
  void initState() {
    super.initState();
    _subscription = WorkoutSessionService().elapsedStream.listen((elapsed) {
      setState(() {
        _formattedTime = _formatDuration(elapsed);
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes % 60)}:${twoDigits(d.inSeconds % 60)}";
  }

  @override
  Widget build(BuildContext context) {
    final session = WorkoutSessionService();
    if (!session.isActive) return const SizedBox.shrink();

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      right: 16,
      child: FloatingActionButton.extended(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("End Workout"),
              content: const Text("Are you sure you want to end this workout session?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("End"),
                ),
              ],
            ),
          );

          if (confirm == true) {
            final duration = session.elapsed;
            session.clearSession();
            setState(() {
              _formattedTime = "00:00:00";
            });

            await Navigator.pushNamed(
              context,
              '/workout-analysis',
              arguments: {
                'duration': duration,
                'calories': 6.5 * duration.inMinutes,
                'workoutName': session.workoutName ?? '',
              },
            );
          }
        },
        icon: const Icon(Icons.stop),
        label: Text(_formattedTime),
        backgroundColor: Colors.red,
      ),
    );
  }
}