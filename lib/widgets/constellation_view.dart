import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../models/journey_event.dart';
import '../services/prefs_service.dart';

/// R28 S1-FEAT2 / CODE1: standalone constellation view, extracted from
/// the legacy `SeerahSkyScreen` so it can live inside Events List as
/// the CONSTELLATION tab. The host (Events List) owns the screen
/// chrome — back arrow, title, segmented toggle, bottom CTA. This
/// widget renders ONLY the scrollable sky body + its internal locked
/// info card.
///
/// **Tap behaviour (R28 S1-FEAT2):**
/// - Completed star → `onLaunch(event)` (host launches in replay mode,
///   which is detected inside the event screen via
///   `PrefsService.isEventCompleted` — no explicit param needed).
/// - Current star → `onLaunch(event)` (plays normally).
/// - Locked star → shows an internal info card with **title + era +
///   locked badge only**. No content leak (no description, no BG, no
///   branching hint).
class ConstellationView extends StatefulWidget {
  final List<JourneyEvent> events;
  final int completedCount;

  /// Called when the user taps a completed or current star. The host
  /// launches the event via its existing `_openEvent` flow. The
  /// Navigation Contract (R28 S1-BUG1) ensures exit returns to tent.
  final void Function(JourneyEvent event) onLaunch;

  const ConstellationView({
    super.key,
    required this.events,
    required this.completedCount,
    required this.onLaunch,
  });

  @override
  State<ConstellationView> createState() => _ConstellationViewState();
}

class _ConstellationViewState extends State<ConstellationView>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollCtrl;
  late final AnimationController _pulseCtrl;

  bool get _isAr => PrefsService.isAr;

  // ── Major events (larger stars + cross sparkle) ─────────────────────
  static const _majorEvents = {
    3, 11, 14, 17, 24, 31, 47, 67, 86, 101, 152, 155,
  };

  // ── Era regions ─────────────────────────────────────────────────────
  static const _eras = [
    (range: 47, en: 'The Prophetic Dawn', ar: 'الفجر النبوي'),
    (range: 82, en: 'The Community Rises', ar: 'نهوض الأمّة'),
    (range: 120, en: 'The Turning Tide', ar: 'تحوّل المدّ'),
    (range: 155, en: 'The Final Chapter', ar: 'الفصل الأخير'),
  ];

  static const double _starSpacing = 65.0;
  late final double _totalHeight;
  late final int _rowCount;
  late List<Offset> _positions;
  int? _lockedInfoIdx;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _rowCount = _countYearRows();
    _totalHeight = _rowCount * _starSpacing + 340;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentStar();
    });
  }

  int _countYearRows() {
    int rows = 0;
    int i = 0;
    while (i < widget.events.length) {
      int j = i;
      while (j < widget.events.length &&
          widget.events[j].year == widget.events[i].year) {
        j++;
      }
      rows++;
      i = j;
    }
    return rows;
  }

  /// Same-year events share a Y row and spread across X symmetrically
  /// around the centerline. (R28 S1-FEAT3 will layer a vertical
  /// stagger on top — see that commit.)
  List<Offset> _generatePositions(double screenW, double bottomPad) {
    final positions = List<Offset>.filled(widget.events.length, Offset.zero);
    final centerX = screenW / 2;
    final amplitude = screenW * 0.28;
    final bottomAllowance = 140.0 + bottomPad;
    final clusterSpread = screenW * 0.18;

    int row = 0;
    int i = 0;
    while (i < widget.events.length) {
      int j = i;
      while (j < widget.events.length &&
          widget.events[j].year == widget.events[i].year) {
        j++;
      }
      final clusterSize = j - i;
      final y = _totalHeight - (bottomAllowance + row * _starSpacing);
      final wave = sin(row * 0.6 + 0.3) * amplitude;
      final baseX = centerX + wave;

      if (clusterSize == 1) {
        final jitter = sin(row * 2.1) * 15;
        positions[i] = Offset(baseX + jitter, y);
      } else {
        for (int k = 0; k < clusterSize; k++) {
          final offsetX = (k - (clusterSize - 1) / 2.0) * clusterSpread;
          positions[i + k] = Offset(centerX + offsetX, y);
        }
      }
      row++;
      i = j;
    }
    return positions;
  }

  void _scrollToCurrentStar() {
    if (!_scrollCtrl.hasClients) return;
    if (widget.completedCount >= widget.events.length) return;
    final targetY = _positions[widget.completedCount].dy;
    final viewportH = _scrollCtrl.position.viewportDimension;
    final scrollTo = (targetY - viewportH / 2).clamp(
      _scrollCtrl.position.minScrollExtent,
      _scrollCtrl.position.maxScrollExtent,
    );
    _scrollCtrl.animateTo(scrollTo,
        duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
  }

  String _eraForEvent(int globalOrder) {
    for (final era in _eras) {
      if (globalOrder <= era.range) return _isAr ? era.ar : era.en;
    }
    return _isAr ? _eras.last.ar : _eras.last.en;
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _handleStarTap(int idx) {
    final isCompleted = idx < widget.completedCount;
    final isCurrent = idx == widget.completedCount;
    if (isCompleted || isCurrent) {
      // R28 S1-FEAT2: completed → replay (event screen auto-detects
      // via `PrefsService.isEventCompleted`); current → play.
      widget.onLaunch(widget.events[idx]);
    } else {
      // Locked: show the minimal info card (title + era + badge only).
      setState(() => _lockedInfoIdx = idx);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    _positions = _generatePositions(screenW, bottomPad);

    return Container(
      color: const Color(0xFF060810),
      child: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollCtrl,
            child: SizedBox(
              width: screenW,
              height: _totalHeight,
              child: Stack(
                children: [
                  // Deep-sky gradient backdrop
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(0, -0.3),
                          radius: 1.5,
                          colors: [Color(0xFF0C1030), Color(0xFF060810)],
                        ),
                      ),
                    ),
                  ),

                  // Background dust (atmospheric, not events)
                  for (int i = 0; i < 60; i++)
                    Positioned(
                      left: (3 + (i * 17 + i * i * 3) % 94) * screenW / 100,
                      top: ((i * 23 + i * i * 7) %
                              (_totalHeight - 20).toInt())
                          .toDouble(),
                      child: Container(
                        width: i % 5 == 0 ? 1.5 : 1,
                        height: i % 5 == 0 ? 1.5 : 1,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(
                              (20 + (i % 7) * 8).clamp(0, 255)),
                        ),
                      ),
                    ),

                  // Constellation lines + stars
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, _) => CustomPaint(
                      size: Size(screenW, _totalHeight),
                      painter: _SkyPainter(
                        events: widget.events,
                        positions: _positions,
                        completedCount: widget.completedCount,
                        majorEvents: _majorEvents,
                        pulseValue: _pulseCtrl.value,
                        isAr: _isAr,
                      ),
                    ),
                  ),

                  // Tap targets — dispatch to _handleStarTap
                  for (int i = 0; i < widget.events.length; i++)
                    Positioned(
                      left: _positions[i].dx - 22,
                      top: _positions[i].dy - 22,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _handleStarTap(i),
                        child: const SizedBox(width: 44, height: 44),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Locked info card (content-leak-free, title + era + badge).
          if (_lockedInfoIdx != null)
            Positioned.fill(
              child: _LockedInfoCard(
                event: widget.events[_lockedInfoIdx!],
                eraLabel: _eraForEvent(widget.events[_lockedInfoIdx!].globalOrder),
                isAr: _isAr,
                onDismiss: () => setState(() => _lockedInfoIdx = null),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Locked info card ────────────────────────────────────────────────────────

class _LockedInfoCard extends StatelessWidget {
  final JourneyEvent event;
  final String eraLabel;
  final bool isAr;
  final VoidCallback onDismiss;

  const _LockedInfoCard({
    required this.event,
    required this.eraLabel,
    required this.isAr,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Tap-outside dismisses.
      behavior: HitTestBehavior.opaque,
      onTap: onDismiss,
      child: Container(
        color: Colors.black.withAlpha(153), // 0.60
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: GestureDetector(
          // Swallow taps on the card so they don't dismiss.
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1624),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gold.withAlpha(80)),
              boxShadow: [
                BoxShadow(
                    color: AppColors.gold.withAlpha(20),
                    blurRadius: 20,
                    spreadRadius: 2),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Locked badge (gold outline, lock glyph)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold.withAlpha(20),
                    border:
                        Border.all(color: AppColors.gold.withAlpha(100), width: 1.2),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.lock_outline_rounded,
                      size: 22, color: AppColors.gold.withAlpha(200)),
                ),
                const SizedBox(height: 14),
                // Title — event title in current locale.
                Text(
                  isAr ? event.titleAr : event.title,
                  textAlign: TextAlign.center,
                  textDirection:
                      isAr ? TextDirection.rtl : TextDirection.ltr,
                  style: GoogleFonts.cinzelDecorative(
                    color: AppColors.gold,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                // Era.
                Text(
                  eraLabel,
                  textAlign: TextAlign.center,
                  textDirection:
                      isAr ? TextDirection.rtl : TextDirection.ltr,
                  style: GoogleFonts.nunito(
                    color: AppColors.gold.withAlpha(140),
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 16),
                // Locked caption — intentionally generic. Spec: NO
                // content leak. No description, no hint at what the
                // event is about beyond title + era.
                Text(
                  isAr
                      ? 'اكتمل الأحداث السابقة لفتح هذا النجم'
                      : 'Complete earlier events to unlock',
                  textAlign: TextAlign.center,
                  textDirection:
                      isAr ? TextDirection.rtl : TextDirection.ltr,
                  style: GoogleFonts.nunito(
                    color: AppColors.textBody.withAlpha(180),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                // Close button.
                GestureDetector(
                  onTap: onDismiss,
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: AppColors.gold.withAlpha(60)),
                    ),
                    child: Text(
                      isAr ? 'إغلاق' : 'Close',
                      style: GoogleFonts.nunito(
                        color: AppColors.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Custom painter for stars + constellation lines ──────────────────────────

class _SkyPainter extends CustomPainter {
  final List<JourneyEvent> events;
  final List<Offset> positions;
  final int completedCount;
  final Set<int> majorEvents;
  final double pulseValue;
  final bool isAr;

  _SkyPainter({
    required this.events,
    required this.positions,
    required this.completedCount,
    required this.majorEvents,
    required this.pulseValue,
    required this.isAr,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = events.length;

    // ── Constellation lines ─────────────────────────────────────────
    for (int i = 1; i < total; i++) {
      final p0 = positions[i - 1];
      final p1 = positions[i];
      final done0 = (i - 1) < completedCount;
      final done1 = i < completedCount;
      final isCurrent = i == completedCount;
      final bothDone = done0 && (done1 || isCurrent);

      final paint = Paint()
        ..color = bothDone
            ? const Color(0xFFD4A843).withAlpha(130)
            : isCurrent
                ? const Color(0xFFD4A843).withAlpha(40)
                : const Color(0xFFD4A843).withAlpha(15)
        ..strokeWidth = bothDone ? 1.5 : 0.5
        ..style = PaintingStyle.stroke;

      canvas.drawLine(p0, p1, paint);
    }

    // ── Stars + labels ─────────────────────────────────────────────
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < total; i++) {
      final pos = positions[i];
      final globalOrder = i + 1;
      final isDone = i < completedCount;
      final isCurrent = i == completedCount;
      final isNext = i == completedCount + 1;
      final isMajor = majorEvents.contains(globalOrder);

      double radius;
      Color color;
      if (isDone) {
        radius = isMajor ? 7 : 4;
        color = const Color(0xFFD4A843);
      } else if (isCurrent) {
        radius = isMajor ? 8 : 5;
        color = const Color(0xFFE8C854);
      } else if (isNext) {
        radius = 3;
        color = const Color(0xFFD4A843).withAlpha(40);
      } else {
        radius = 2;
        color = const Color(0xFFD4A843).withAlpha(10);
      }

      if (isDone || isCurrent) {
        final glowPaint = Paint()
          ..color = const Color(0xFFD4A843).withAlpha(isCurrent ? 15 : 8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
        canvas.drawCircle(pos, isMajor ? 20 : 14, glowPaint);
      }

      if (isCurrent) {
        final pulseRadius = (isMajor ? 16.0 : 12.0) + pulseValue * 6;
        final pulsePaint = Paint()
          ..color = const Color(0xFFD4A843)
              .withAlpha((100 * (1 - pulseValue)).round())
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        canvas.drawCircle(pos, pulseRadius, pulsePaint);
      }

      if (isMajor) {
        _drawStar(canvas, pos, radius * 1.6, Paint()..color = color);
        if (isDone) {
          _drawStar(
            canvas,
            pos,
            radius * 1.6,
            Paint()
              ..color = const Color(0xFFD4A843).withAlpha(150)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.7,
          );
        }
      } else {
        canvas.drawCircle(pos, radius, Paint()..color = color);
        if (isDone) {
          canvas.drawCircle(
            pos,
            radius,
            Paint()
              ..color = const Color(0xFFD4A843).withAlpha(150)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.5,
          );
        }
      }

      if (isMajor && isDone) {
        final sparkle = Paint()
          ..color = const Color(0xFFD4A843).withAlpha(80)
          ..strokeWidth = 0.5;
        canvas.drawLine(
            Offset(pos.dx, pos.dy - 14), Offset(pos.dx, pos.dy + 14), sparkle);
        canvas.drawLine(
            Offset(pos.dx - 14, pos.dy), Offset(pos.dx + 14, pos.dy), sparkle);
      }

      if (isDone || isCurrent) {
        final event = events[i];
        final label = isAr ? event.titleAr : event.title;
        final isRight = pos.dx > 180;
        final labelX = isRight ? pos.dx - 16 : pos.dx + 16;

        textPainter
          ..text = TextSpan(
            text: label,
            style: TextStyle(
              color: Color(isCurrent ? 0xFFE8D8B8 : 0x73E8D8B8),
              fontSize: isCurrent ? 9 : 8,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
              fontFamily: 'Georgia',
            ),
          )
          ..textDirection = isAr ? TextDirection.rtl : TextDirection.ltr
          ..layout(maxWidth: 120);
        final textOffset = Offset(
          isRight ? labelX - textPainter.width : labelX,
          pos.dy - textPainter.height / 2 - 6,
        );
        textPainter.paint(canvas, textOffset);

        textPainter
          ..text = TextSpan(
            text: '${event.year} CE',
            style: const TextStyle(
              color: Color(0x33D4A843),
              fontSize: 7,
              fontFamily: 'sans-serif',
            ),
          )
          ..layout(maxWidth: 80);
        final dateOffset = Offset(
          isRight ? labelX - textPainter.width : labelX,
          textOffset.dy + 12,
        );
        textPainter.paint(canvas, dateOffset);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SkyPainter old) =>
      old.completedCount != completedCount ||
      old.pulseValue != pulseValue ||
      old.isAr != isAr ||
      old.events.length != events.length;

  void _drawStar(Canvas canvas, Offset c, double r, Paint paint) {
    final inner = r * 0.38;
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..lineTo(c.dx + inner, c.dy - inner)
      ..lineTo(c.dx + r, c.dy)
      ..lineTo(c.dx + inner, c.dy + inner)
      ..lineTo(c.dx, c.dy + r)
      ..lineTo(c.dx - inner, c.dy + inner)
      ..lineTo(c.dx - r, c.dy)
      ..lineTo(c.dx - inner, c.dy - inner)
      ..close();
    canvas.drawPath(path, paint);
  }
}
