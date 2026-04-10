import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Fog of War overlay that progressively reveals the scene.
///
/// Draws a semi-transparent dark fill with soft circular cutouts at
/// the Rawi character position and each discovered hotspot.
class FogOverlay extends StatelessWidget {
  /// Rawi's current normalized position (0–1).
  final double rawiX;
  final double rawiY;

  /// Positions of discovered hotspots (normalized 0–1).
  final List<Offset> discoveredPositions;

  /// Total hotspot count in the scene.
  final int totalHotspots;

  /// How many hotspots have been discovered so far.
  final int discoveredCount;

  /// True when all hotspots discovered — triggers fade-out.
  final bool sceneRevealed;

  /// Parallax offset in logical pixels applied to the scene.
  final double sceneOffset;

  const FogOverlay({
    super.key,
    required this.rawiX,
    required this.rawiY,
    required this.discoveredPositions,
    required this.totalHotspots,
    required this.discoveredCount,
    required this.sceneRevealed,
    this.sceneOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedOpacity(
        opacity: sceneRevealed ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        child: CustomPaint(
          size: Size.infinite,
          painter: _FogPainter(
            rawiX: rawiX,
            rawiY: rawiY,
            discoveredPositions: discoveredPositions,
            totalHotspots: totalHotspots,
            discoveredCount: discoveredCount,
            sceneOffset: sceneOffset,
          ),
        ),
      ),
    );
  }
}

class _FogPainter extends CustomPainter {
  final double rawiX;
  final double rawiY;
  final List<Offset> discoveredPositions;
  final int totalHotspots;
  final int discoveredCount;
  final double sceneOffset;

  _FogPainter({
    required this.rawiX,
    required this.rawiY,
    required this.discoveredPositions,
    required this.totalHotspots,
    required this.discoveredCount,
    required this.sceneOffset,
  });

  /// Fog opacity decreases as more hotspots are discovered.
  double get _fogOpacity {
    if (totalHotspots <= 0) return 0.0;
    final ratio = discoveredCount / totalHotspots;
    if (ratio <= 0) return 0.85;
    if (ratio <= 0.25) return 0.75;
    if (ratio <= 0.5) return 0.65;
    if (ratio <= 0.75) return 0.50;
    return 0.0; // 4/4 — handled by AnimatedOpacity wrapper
  }

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = _fogOpacity;
    if (opacity <= 0) return;

    final fogColor = Colors.black.withValues(alpha: opacity);

    // Save a compositing layer so BlendMode.dstOut can punch holes
    canvas.saveLayer(Offset.zero & size, Paint());

    // 1. Fill the entire screen with the fog color
    canvas.drawRect(Offset.zero & size, Paint()..color = fogColor);

    // 2. Punch soft-edge holes using dstOut
    final holePaint = Paint()..blendMode = ui.BlendMode.dstOut;

    // Rawi character cutout (larger radius)
    _punchHole(
      canvas,
      holePaint,
      Offset(rawiX * size.width + sceneOffset, rawiY * size.height),
      100.0,
      size,
    );

    // Discovered hotspot cutouts (slightly smaller)
    for (final pos in discoveredPositions) {
      _punchHole(
        canvas,
        holePaint,
        Offset(pos.dx * size.width + sceneOffset, pos.dy * size.height),
        70.0,
        size,
      );
    }

    canvas.restore();
  }

  /// Paints a radial gradient circle that, combined with [BlendMode.dstOut],
  /// punches a soft-edged transparent hole in the fog layer.
  void _punchHole(
    Canvas canvas,
    Paint basePaint,
    Offset center,
    double radius,
    Size size,
  ) {
    final gradient = ui.Gradient.radial(
      center,
      radius,
      [
        Colors.white, // fully erase center
        Colors.white,
        Colors.white.withValues(alpha: 0.0), // fade to nothing at edge
      ],
      [0.0, 0.55, 1.0], // 55 % hard clear, then soft falloff
    );

    canvas.drawCircle(
      center,
      radius,
      basePaint..shader = gradient,
    );
  }

  @override
  bool shouldRepaint(covariant _FogPainter oldDelegate) {
    return rawiX != oldDelegate.rawiX ||
        rawiY != oldDelegate.rawiY ||
        discoveredCount != oldDelegate.discoveredCount ||
        sceneOffset != oldDelegate.sceneOffset ||
        discoveredPositions.length != oldDelegate.discoveredPositions.length;
  }
}
