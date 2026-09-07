import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Custom painter for dotted/dashed circular outline and fill for predictions.
class DottedCirclePainter extends CustomPainter {
  const DottedCirclePainter({
    required this.color,
    required this.fillColor,
    this.isToday = false,
    this.todayBorderColor,
  });

  final Color color;
  final Color fillColor;
  final bool isToday;
  final Color? todayBorderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 2;

    // Draw background fill
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, fillPaint);

    // Draw dotted border
    final dashPaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const totalDashes = 12;
    const dashSweep = (2 * math.pi) / totalDashes;
    const dashLength = dashSweep * 0.55;

    for (var i = 0; i < totalDashes; i++) {
      final startAngle = i * dashSweep;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashLength,
        false,
        dashPaint,
      );
    }

    if (isToday && todayBorderColor != null) {
      final todayPaint = Paint()
        ..color = todayBorderColor!
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(center, radius + 1, todayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant DottedCirclePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.isToday != isToday;
  }
}
