import 'package:flutter/material.dart';
import '../../app_colors.dart';

/// A floating virtual joystick for moving the companion figure.
/// Returns normalized direction (dx, dy) from -1.0 to 1.0.
class VirtualJoystick extends StatefulWidget {
  /// Called continuously while the joystick is dragged.
  /// [dx] and [dy] are normalized (-1.0 to 1.0).
  final void Function(double dx, double dy) onMove;

  /// Called when the user releases the joystick.
  final VoidCallback? onRelease;

  const VirtualJoystick({
    super.key,
    required this.onMove,
    this.onRelease,
  });

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  static const double _outerRadius = 56.0;
  static const double _thumbRadius = 22.0;
  static const double _maxDisplacement = 34.0; // outer - thumb

  Offset _thumbOffset = Offset.zero;
  bool _active = false;

  void _handleDrag(Offset localPosition) {
    final center = const Offset(_outerRadius, _outerRadius);
    var delta = localPosition - center;

    // Clamp to circle
    final dist = delta.distance;
    if (dist > _maxDisplacement) {
      delta = delta / dist * _maxDisplacement;
    }

    setState(() {
      _thumbOffset = delta;
      _active = true;
    });

    // Normalize to -1..1
    widget.onMove(
      delta.dx / _maxDisplacement,
      delta.dy / _maxDisplacement,
    );
  }

  void _handleRelease() {
    setState(() {
      _thumbOffset = Offset.zero;
      _active = false;
    });
    widget.onRelease?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _outerRadius * 2,
      height: _outerRadius * 2,
      child: GestureDetector(
        onPanStart: (d) => _handleDrag(d.localPosition),
        onPanUpdate: (d) => _handleDrag(d.localPosition),
        onPanEnd: (_) => _handleRelease(),
        onPanCancel: _handleRelease,
        child: CustomPaint(
          painter: _JoystickPainter(
            thumbOffset: _thumbOffset,
            active: _active,
            outerRadius: _outerRadius,
            thumbRadius: _thumbRadius,
          ),
        ),
      ),
    );
  }
}

class _JoystickPainter extends CustomPainter {
  final Offset thumbOffset;
  final bool active;
  final double outerRadius;
  final double thumbRadius;

  _JoystickPainter({
    required this.thumbOffset,
    required this.active,
    required this.outerRadius,
    required this.thumbRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Outer ring
    final outerPaint = Paint()
      ..color = AppColors.gold.withAlpha(active ? 50 : 30)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, outerRadius, outerPaint);

    final outerBorder = Paint()
      ..color = AppColors.gold.withAlpha(active ? 120 : 60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, outerRadius, outerBorder);

    // Direction indicators (subtle cross lines)
    final linePaint = Paint()
      ..color = AppColors.gold.withAlpha(25)
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(center.dx, center.dy - outerRadius + 12),
      Offset(center.dx, center.dy + outerRadius - 12),
      linePaint,
    );
    canvas.drawLine(
      Offset(center.dx - outerRadius + 12, center.dy),
      Offset(center.dx + outerRadius - 12, center.dy),
      linePaint,
    );

    // Thumb
    final thumbCenter = center + thumbOffset;
    final thumbGlow = Paint()
      ..color = AppColors.gold.withAlpha(active ? 60 : 20)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(thumbCenter, thumbRadius + 4, thumbGlow);

    final thumbFill = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.gold.withAlpha(active ? 200 : 120),
          AppColors.gold.withAlpha(active ? 140 : 60),
        ],
      ).createShader(Rect.fromCircle(center: thumbCenter, radius: thumbRadius));
    canvas.drawCircle(thumbCenter, thumbRadius, thumbFill);

    final thumbBorder = Paint()
      ..color = AppColors.gold.withAlpha(active ? 220 : 100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(thumbCenter, thumbRadius, thumbBorder);

    // Center dot on thumb
    canvas.drawCircle(
      thumbCenter,
      3,
      Paint()..color = Colors.white.withAlpha(active ? 200 : 80),
    );
  }

  @override
  bool shouldRepaint(_JoystickPainter old) =>
      old.thumbOffset != thumbOffset || old.active != active;
}
