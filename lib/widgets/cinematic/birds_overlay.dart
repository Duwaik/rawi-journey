import 'dart:math';
import 'package:flutter/material.dart';

/// Animated birds swarming across the sky for Event 2 (Year of the Elephant).
/// Shows dozens of small bird silhouettes moving in waves.
class BirdsOverlay extends StatefulWidget {
  final int count;

  const BirdsOverlay({super.key, this.count = 40});

  @override
  State<BirdsOverlay> createState() => _BirdsOverlayState();
}

class _BirdsOverlayState extends State<BirdsOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final List<_Bird> _birds;

  @override
  void initState() {
    super.initState();
    final rng = Random(77);
    _birds = List.generate(widget.count, (i) => _Bird(rng));
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _BirdsPainter(
            birds: _birds,
            animValue: _anim.value,
          ),
        );
      },
    );
  }
}

class _Bird {
  final double startX; // 0–1
  final double baseY;  // 0–0.4 (upper part of sky)
  final double speed;  // movement speed multiplier
  final double wingPhase; // offset for wing flap
  final double size;

  _Bird(Random rng)
      : startX = rng.nextDouble(),
        baseY = rng.nextDouble() * 0.35 + 0.02,
        speed = 0.3 + rng.nextDouble() * 0.7,
        wingPhase = rng.nextDouble() * 2 * pi,
        size = 3.0 + rng.nextDouble() * 4.0;
}

class _BirdsPainter extends CustomPainter {
  final List<_Bird> birds;
  final double animValue;

  _BirdsPainter({required this.birds, required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    for (final bird in birds) {
      // Birds move from right to left in waves
      final t = (animValue * bird.speed + bird.startX) % 1.0;
      final x = (1.0 - t) * size.width * 1.3 - size.width * 0.15;
      final yWobble = sin(animValue * 2 * pi * 3 + bird.wingPhase) * 8;
      final y = bird.baseY * size.height + yWobble;

      // Wing flap animation
      final wingAngle = sin(animValue * 2 * pi * 6 + bird.wingPhase) * 0.4;
      final s = bird.size;

      // Draw bird as simple V shape
      final paint = Paint()
        ..color = Color.fromARGB(
          (140 + (bird.baseY * 80)).round().clamp(100, 200),
          30, 25, 20,
        )
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      // Left wing
      path.moveTo(x - s, y - s * wingAngle);
      path.quadraticBezierTo(x - s * 0.3, y - s * 0.2, x, y);
      // Right wing
      path.quadraticBezierTo(x + s * 0.3, y - s * 0.2, x + s, y - s * wingAngle);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_BirdsPainter old) => old.animValue != animValue;
}
