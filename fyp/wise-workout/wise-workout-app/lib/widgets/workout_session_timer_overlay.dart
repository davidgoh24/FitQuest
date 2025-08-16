// lib/widgets/workout_session_timer_overlay.dart
import 'package:flutter/material.dart';

class WorkoutSessionTimerOverlay extends StatefulWidget {
  final DateTime startTime;
  final Function(Duration duration) onEndSession;
  const WorkoutSessionTimerOverlay({
    super.key,
    required this.startTime,
    required this.onEndSession,
  });

  @override
  State<WorkoutSessionTimerOverlay> createState() => _WorkoutSessionTimerOverlayState();
}

class _WorkoutSessionTimerOverlayState extends State<WorkoutSessionTimerOverlay> {
  late final Stopwatch _stopwatch;
  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _ticker = Ticker((_) {
      setState(() {
        _elapsed = _stopwatch.elapsed;
      });
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    return '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  void _endSession() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Workout?'),
        content: const Text('Are you sure you want to end the session?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("No")),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Yes")),
        ],
      ),
    );

    if (confirm == true) {
      final duration = _stopwatch.elapsed;
      widget.onEndSession(duration);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 80,
      right: 20,
      child: GestureDetector(
        onTap: _endSession,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(30),
          color: Colors.orange,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.timer, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(_elapsed),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.stop_circle_outlined, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Ticker {
  final void Function(Duration) onTick;
  bool _active = false;

  Ticker(this.onTick);

  void start() {
    _active = true;
    _tick();
  }

  void _tick() async {
    while (_active) {
      await Future.delayed(const Duration(seconds: 1));
      onTick(Duration(seconds: 1));
    }
  }

  void dispose() {
    _active = false;
  }
}
