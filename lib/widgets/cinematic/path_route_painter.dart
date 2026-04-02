import 'package:flutter/material.dart';

/// Silver path color — contrasts gold hotspots and desert tones.
const _silver = Color(0xFFB8C4CC);

/// Paints the walking route on the scene.
/// Active segment (next hotspot) is bright silver with glow.
/// Completed segments fade to dim transparent.
/// Upcoming segments are subtle dotted lines.
class PathRoutePainter extends CustomPainter {
  final List<Offset> waypoints;
  final double pathProgress; // 0.0–1.0
  final double screenW;
  final double screenH;
  final double sceneOffset;
  final int discoveredCount; // how many hotspots completed
  final int totalHotspots;

  PathRoutePainter({
    required this.waypoints,
    required this.pathProgress,
    required this.screenW,
    required this.screenH,
    required this.sceneOffset,
    required this.discoveredCount,
    required this.totalHotspots,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waypoints.length < 2) return;

    final segCount = waypoints.length - 1;
    final completedFraction = totalHotspots > 0
        ? (discoveredCount / totalHotspots).clamp(0.0, 1.0)
        : 0.0;

    for (int i = 0; i < segCount; i++) {
      final segFraction = i / segCount;
      final nextSegFraction = (i + 1) / segCount;

      final p1 = Offset(
        waypoints[i].dx * screenW + sceneOffset,
        waypoints[i].dy * screenH,
      );
      final p2 = Offset(
        waypoints[i + 1].dx * screenW + sceneOffset,
        waypoints[i + 1].dy * screenH,
      );

      final bool isCompleted = segFraction < completedFraction;
      final bool isActive = segFraction >= completedFraction &&
          nextSegFraction <= completedFraction + (1.0 / totalHotspots) + 0.05;

      if (isCompleted) {
        _drawDottedLine(canvas, p1, p2,
            color: _silver.withAlpha(35), dotRadius: 1.5, gap: 10);
      } else if (isActive) {
        // Active: bright silver, glowing line
        final glowPaint = Paint()
          ..color = _silver.withAlpha(45)
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawLine(p1, p2, glowPaint);

        final linePaint = Paint()
          ..color = _silver.withAlpha(140)
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(p1, p2, linePaint);
      } else {
        _drawDottedLine(canvas, p1, p2,
            color: _silver.withAlpha(22), dotRadius: 1.2, gap: 12);
      }
    }
  }

  void _drawDottedLine(Canvas canvas, Offset p1, Offset p2,
      {required Color color, required double dotRadius, required double gap}) {
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final dist = (dx * dx + dy * dy);
    if (dist < 1) return;
    final sqrtLen = dist.toDouble();
    // Newton's method sqrt approximation
    double d = sqrtLen;
    for (int j = 0; j < 10; j++) {
      d = (d + sqrtLen / d) / 2;
    }
    final steps = (d / gap).round();
    if (steps <= 0) return;

    final paint = Paint()..color = color;
    for (int s = 0; s <= steps; s++) {
      final t = s / steps;
      canvas.drawCircle(
        Offset(p1.dx + dx * t, p1.dy + dy * t),
        dotRadius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(PathRoutePainter old) =>
      old.pathProgress != pathProgress ||
      old.discoveredCount != discoveredCount ||
      old.sceneOffset != sceneOffset;
}
