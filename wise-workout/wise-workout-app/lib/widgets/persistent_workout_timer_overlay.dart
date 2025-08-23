// lib/widgets/persistent_workout_timer_overlay.dart
import 'dart:async';
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';

import '../services/workout_session_service.dart';
import '../main.dart' show rootNavigatorKey;

class PersistentWorkoutTimerOverlay extends StatefulWidget {
  const PersistentWorkoutTimerOverlay({super.key});

  @override
  State<PersistentWorkoutTimerOverlay> createState() =>
      _PersistentWorkoutTimerOverlayState();
}

class _PersistentWorkoutTimerOverlayState extends State<PersistentWorkoutTimerOverlay> {
  final _service = WorkoutSessionService();
  StreamSubscription<Duration>? _sub;
  Duration _elapsed = Duration.zero;
  bool _sheetOpen = false;
  Future<void>? _sheetFuture;
  Offset _offset = const Offset(16, 0);
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _elapsed = _service.elapsed;
    _sub = _service.elapsedStream.listen((d) {
      if (!mounted) return;
      setState(() => _elapsed = d);

      // Auto-close sheet if session ended
      if (!_service.isActive && _sheetOpen) {
        _closeSheet();
      }
    });
  }
  void _closeSheet() {
    if (_sheetOpen) {
      final ctx = rootNavigatorKey.currentContext;
      if (ctx != null) {
        Navigator.of(ctx, rootNavigator: true).pop();
      }
      _sheetOpen = false;
    }
  }


  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void _openWorkout() {
    _closeSheet(); // ensure sheet is gone
    final nav = rootNavigatorKey.currentState;
    if (nav == null) return;
    final route = _service.startRouteName;
    final args = _service.startRouteArgs;
    if (route != null) {
      nav.pushNamed(route, arguments: args);
    }
  }

  Future<void> _showPanel() async {
    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null) return;

    _sheetOpen = true;
    _sheetFuture = showModalBottomSheet(
      context: ctx,
      useSafeArea: true,
      isScrollControlled: false,
      showDragHandle: true,
      useRootNavigator: true, // important so it’s tied to the root navigator
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer_outlined),
                  const SizedBox(width: 8),
                  Text(
                    _fmt(_elapsed),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _openWorkout,
                  icon: const Icon(Icons.fitness_center),
                  label: const Text('Open Workout'),
                ),
              ),
            ],
          ),
        );
      },
    );

    await _sheetFuture;
    _sheetOpen = false;
  }

  Offset _clampToScreen(Offset raw, Size screen, double size, EdgeInsets pad) {
    final left = pad.left;
    final top = pad.top;
    final right = screen.width - size - pad.right;
    final bottom = screen.height - size - pad.bottom;
    return Offset(
      raw.dx.clamp(left, right),
      raw.dy.clamp(top, bottom),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_service.isActive) return const SizedBox.shrink();

    final mq = MediaQuery.of(context);
    final screenSize = mq.size;
    const bubbleSize = 56.0;

    if (!_initialized) {
      _initialized = true;
      _offset = Offset(
        screenSize.width - bubbleSize - 16,
        screenSize.height - bubbleSize - (mq.padding.bottom + 100),
      );
    }

    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        onPanUpdate: (d) {
          final next = _offset + d.delta;
          setState(() {
            _offset = _clampToScreen(
              next,
              screenSize,
              bubbleSize,
              EdgeInsets.only(
                left: 8,
                right: 8,
                top: mq.padding.top + 8,
                bottom: mq.padding.bottom + 8,
              ),
            );
          });
        },
        onTap: _showPanel, // tap bubble -> bottom sheet with ONLY "Open Workout"
        child: Material(
          elevation: 10,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          color: Colors.black.withOpacity(0.80),
          child: Container(
            width: bubbleSize,
            height: bubbleSize,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _fmt(_elapsed),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
