import 'package:flutter/material.dart';

/// R28-S4-SPINE-P1 — S4S-02. The central gold spine line that runs
/// behind the Stars timeline.
///
/// One vertical stroke down the horizontal centre of the scroll
/// content, broken by a clean gap wherever a year-marker box sits
/// (Option 2 — interrupting the spine, no overlap, no peek-through).
///
/// Coordinate contract with `ConstellationView._buildLayout()`:
///   • Canvas (0,0) == top-left of the scroll content (the SizedBox
///     that wraps the Stack), so painter-Y == layout-Y directly — no
///     transform needed.
///   • [gapTops] holds the Y of the TOP of each year-marker box, in
///     layout order (the build loop already accounts for the leading
///     end-padding).
///   • Each gap spans `[gapTop, gapTop + gapHeight]`.
///
/// Direction (bottom-to-top) is irrelevant to the painter — the spine
/// is just a vertical line with holes; the holes land wherever the
/// year markers ended up in the rendered column. z-order is handled
/// by the host placing this CustomPaint behind the event Column in a
/// Stack, so the full-opacity event dots read cleanly on top.
class SpinePainter extends CustomPainter {
  /// Y of the top edge of every year-marker gap, content-space.
  final List<double> gapTops;

  /// Height of each gap (== the year-marker vertical footprint).
  final double gapHeight;

  /// Gold-amber, app palette (#D4A017).
  static const Color _spineColor = Color(0xFFD4A017);

  /// 1.5px per spec S4S-02.
  static const double _spineWidth = 1.5;

  /// ~0.55 opacity → 0.55 * 255 ≈ 140 (codebase uses withAlpha, not
  /// the 3.27+ withValues, to stay deprecation-free and consistent).
  static const int _spineAlpha = 140;

  const SpinePainter({required this.gapTops, required this.gapHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _spineColor.withAlpha(_spineAlpha)
      ..strokeWidth = _spineWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final double centerX = size.width / 2;

    // Draw the spine as the complement of the gap ranges: sweep a
    // cursor from the top of the content down to the bottom, emitting
    // a stroke for every span between consecutive gaps. Sorting makes
    // the sweep robust regardless of the order gapTops arrived in.
    final sorted = List<double>.from(gapTops)..sort();

    double cursor = 0.0;
    for (final gapTop in sorted) {
      final double gStart = gapTop.clamp(0.0, size.height);
      final double gEnd = (gapTop + gapHeight).clamp(0.0, size.height);
      if (gStart > cursor) {
        canvas.drawLine(
          Offset(centerX, cursor),
          Offset(centerX, gStart),
          paint,
        );
      }
      if (gEnd > cursor) cursor = gEnd;
    }
    if (cursor < size.height) {
      canvas.drawLine(
        Offset(centerX, cursor),
        Offset(centerX, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SpinePainter old) =>
      old.gapHeight != gapHeight ||
      !_listEquals(old.gapTops, gapTops);

  static bool _listEquals(List<double> a, List<double> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
