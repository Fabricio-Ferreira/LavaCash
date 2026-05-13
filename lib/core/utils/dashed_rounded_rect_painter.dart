import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

/// Paints a dashed stroke along a rounded rectangle (e.g. dashed borders).
class DashedRoundedRectPainter extends CustomPainter {
  const DashedRoundedRectPainter({
    required this.color,
    required this.radius,
    this.strokeWidth = 1.6,
    this.dashLength = 6,
    this.gapLength = 4,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final Paint paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;
    _drawDashedRRect(canvas, rrect, paint);
  }

  void _drawDashedRRect(Canvas canvas, RRect rrect, Paint paint) {
    final Path path = Path()..addRRect(rrect);
    for (final PathMetric metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final double next = (dist + dashLength).clamp(0, metric.length);
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedRoundedRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength;
  }
}
