import 'dart:math';
import 'package:flutter/material.dart';

/// Two layers of twinkling stars at different animation speeds.
class StarfieldLayer extends StatefulWidget {
  final int starCount;
  const StarfieldLayer({super.key, this.starCount = 40});

  @override
  State<StarfieldLayer> createState() => _StarfieldLayerState();
}

class _StarfieldLayerState extends State<StarfieldLayer>
    with TickerProviderStateMixin {
  late final AnimationController _twinkleA;
  late final AnimationController _twinkleB;

  // Pre-computed star data: [x%, y%, size, layerIndex]
  late final List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    _twinkleA = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat(reverse: true);

    _twinkleB = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    )..repeat(reverse: true);

    final rng = Random(1337);
    _stars = List.generate(widget.starCount, (i) {
      return _Star(
        x: rng.nextDouble(),
        y: rng.nextDouble() * 0.65, // stars only in upper 65%
        size: 1.0 + rng.nextDouble() * 1.8,
        layer: i % 2, // alternate between layer A and B
        baseAlpha: 0.4 + rng.nextDouble() * 0.55,
      );
    });
  }

  @override
  void dispose() {
    _twinkleA.dispose();
    _twinkleB.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: Listenable.merge([_twinkleA, _twinkleB]),
            builder: (context, _) {
              return CustomPaint(
                painter: _StarPainter(
                  stars: _stars,
                  twinkleA: _twinkleA.value,
                  twinkleB: _twinkleB.value,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Star {
  final double x, y, size, baseAlpha;
  final int layer;
  const _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.layer,
    required this.baseAlpha,
  });
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double twinkleA, twinkleB;

  _StarPainter({
    required this.stars,
    required this.twinkleA,
    required this.twinkleB,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final twinkle = s.layer == 0 ? twinkleA : twinkleB;
      // Oscillate alpha between baseAlpha*0.6 and baseAlpha
      final alpha = s.baseAlpha * (0.6 + 0.4 * twinkle);
      final paint = Paint()
        ..color = _starColor(s).withAlpha((alpha * 255).round())
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.size * 0.5);

      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.size,
        paint,
      );
    }
  }

  Color _starColor(_Star s) {
    // Mix of warm white and cool blue stars
    return s.layer == 0
        ? const Color(0xFFFFF8DC) // floral white
        : const Color(0xFFC8DCFF); // cool blue
  }

  @override
  bool shouldRepaint(_StarPainter old) =>
      old.twinkleA != twinkleA || old.twinkleB != twinkleB;
}
