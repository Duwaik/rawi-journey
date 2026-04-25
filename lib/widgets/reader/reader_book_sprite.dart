import 'package:flutter/material.dart';

/// R28 S3-P1-09 · Reader-mode book sprite.
///
/// Pure CustomPaint — no asset file. Two trapezoids meeting at a center
/// vertical spine, forming an open-book V. Parchment fill, thin ink-line
/// border. Static (no animation).
///
/// Sized externally by the caller via the [size] parameter on
/// [SizedBox]/[CustomPaint]. Default visual: ~12 % of the scaled
/// figure's height, anchored at the figure's hand area (~55 % down).
class ReaderBookSprite extends StatelessWidget {
  final Size size;

  const ReaderBookSprite({super.key, this.size = const Size(13, 10)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: const _ReaderBookSpritePainter(),
    );
  }
}

class _ReaderBookSpritePainter extends CustomPainter {
  static const _parchment = Color(0xFFE8DCC4);
  static const _ink       = Color(0xFF6B4A1E);

  const _ReaderBookSpritePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    final fill = Paint()
      ..color = _parchment
      ..style = PaintingStyle.fill;

    final stroke = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = (h * 0.06).clamp(0.5, 1.4);

    // Left page — trapezoid: spine at top + bottom, outer edge slants.
    final left = Path()
      ..moveTo(cx, 0)
      ..lineTo(w * 0.05, h * 0.18)
      ..lineTo(0, h)
      ..lineTo(cx, h)
      ..close();
    canvas.drawPath(left, fill);
    canvas.drawPath(left, stroke);

    // Right page — mirror.
    final right = Path()
      ..moveTo(cx, 0)
      ..lineTo(w * 0.95, h * 0.18)
      ..lineTo(w, h)
      ..lineTo(cx, h)
      ..close();
    canvas.drawPath(right, fill);
    canvas.drawPath(right, stroke);

    // Spine — slightly darker hairline.
    final spine = Paint()
      ..color = _ink.withAlpha(180)
      ..strokeWidth = (h * 0.05).clamp(0.4, 1.0);
    canvas.drawLine(Offset(cx, 0), Offset(cx, h), spine);
  }

  @override
  bool shouldRepaint(covariant _ReaderBookSpritePainter old) => false;
}
