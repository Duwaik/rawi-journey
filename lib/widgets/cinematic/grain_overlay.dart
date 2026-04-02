import 'dart:math';
import 'package:flutter/material.dart';

/// Very subtle film-grain noise overlay for cinematic texture.
class GrainOverlay extends StatelessWidget {
  final double opacity;
  const GrainOverlay({super.key, this.opacity = 0.035});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: const RepaintBoundary(
            child: CustomPaint(painter: _GrainPainter()),
          ),
        ),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42); // seeded = deterministic pattern
    final paint = Paint();
    const step = 4.0; // dot spacing (4px grid)

    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        if (rng.nextDouble() > 0.35) continue; // sparse
        final brightness = rng.nextInt(200);
        paint.color = Color.fromARGB(rng.nextInt(80) + 20, brightness, brightness, brightness);
        canvas.drawRect(Rect.fromLTWH(x, y, 1.5, 1.5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_GrainPainter old) => false; // static pattern
}
