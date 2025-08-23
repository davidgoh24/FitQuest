import 'package:flutter/material.dart';
import 'dart:math';

class ExerciseGauge extends StatelessWidget {
  final double progress; // From 0.0 to 1.0
  final Color? backgroundColor;
  final Color? progressColor;
  final VoidCallback? onTap; // Add this for navigation

  const ExerciseGauge({
    super.key,
    required this.progress,
    this.backgroundColor,
    this.progressColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = backgroundColor ?? Theme.of(context).colorScheme.surfaceVariant;
    final Color prColor = progressColor ?? Theme.of(context).colorScheme.primary;

    Widget customPaint = CustomPaint(
      painter: _SemiCirclePainter(
        progress: progress.clamp(0.0, 1.0),
        backgroundColor: bgColor,
        progressColor: prColor,
      ),
      size: const Size(200, 100),
    );

    // Only make it tappable if onTap is provided
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: customPaint,
      );
    } else {
      return customPaint;
    }
  }

}

class _SemiCirclePainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  _SemiCirclePainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 41
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      backgroundPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}