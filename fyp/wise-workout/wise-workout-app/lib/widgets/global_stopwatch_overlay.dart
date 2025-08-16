import 'package:flutter/material.dart';
import '../services/workout_session_service.dart';

class GlobalStopwatchOverlay extends StatefulWidget {
  const GlobalStopwatchOverlay({super.key});

  @override
  State<GlobalStopwatchOverlay> createState() => _GlobalStopwatchOverlayState();
}

class _GlobalStopwatchOverlayState extends State<GlobalStopwatchOverlay> {
  final _sessionService = WorkoutSessionService();
  String _formattedTime = "00:00:00";

  @override
  void initState() {
    super.initState();
    if (_sessionService.isActive) {
      _formattedTime = _formatDuration(_sessionService.elapsed);
      _sessionService.start((elapsed) {
        if (mounted) {
          setState(() {
            _formattedTime = _formatDuration(elapsed);
          });
        }
      });
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes % 60)}:${twoDigits(d.inSeconds % 60)}";
  }

  @override
  Widget build(BuildContext context) {
    if (!_sessionService.isActive) return const SizedBox.shrink();

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      right: 16,
      child: FloatingActionButton.extended(
        backgroundColor: Colors.red,
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
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
            final duration = _sessionService.elapsed;
            final calories = 6.5 * duration.inMinutes;

            _sessionService.clearSession();

            if (context.mounted) {
              Navigator.pushNamed(
                context,
                '/workout-analysis',
                arguments: {
                  'duration': duration,
                  'calories': calories,
                  'workoutName': 'Workout',
                },
              );
            }
          }
        },
        icon: const Icon(Icons.stop),
        label: Text(_formattedTime),
      ),
    );
  }
}
