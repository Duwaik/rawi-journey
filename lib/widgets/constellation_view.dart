import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../models/journey_event.dart';
import '../services/prefs_service.dart';

/// R28 S1-FEAT2 / CODE1: standalone constellation view. Lives inside
/// Events List as the CONSTELLATION tab (alternative to the LIST
/// tab). Replaces the retired `SeerahSkyScreen` that used to be
/// reachable from the tent's Stars nav icon (also removed — see
/// NAV1). The host (Events List) owns the screen chrome: back arrow,
/// title, segmented toggle, bottom CTA. This widget renders ONLY the
/// scrollable sky body + its internal locked info card.
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

  /// Per-event anchor position. For singleton-year events the anchor
  /// IS the visual position (star + label). For same-year clusters
  /// (2+ events at the same `event.year`), all events in the cluster
  /// share the SAME anchor — the cluster's center point on the
  /// timeline. The painter then renders a tight dot-stack at that
  /// anchor, dashed leader lines fanning out to a labels column,
  /// and a year label centered vertically against the dot stack
  /// (R28 HF4-01 Mockup B).
  ///
  /// This replaces the R28-S1-FEAT3 + R28-HF3-CONST1 vertical-stagger
  /// approach. Stagger pushed adjacent-year rows apart on every
  /// cluster — with 155 events and multiple dense-year clusters
  /// (570 CE, Badr week, late Mecca) the timeline kept stretching.
  /// Mockup B is geometrically stable: N events in one year doesn't
  /// move surrounding years.
  List<Offset> _generatePositions(double screenW, double bottomPad) {
    final positions = List<Offset>.filled(widget.events.length, Offset.zero);
    final centerX = screenW / 2;
    final amplitude = screenW * 0.28;
    final bottomAllowance = 140.0 + bottomPad;

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
        // R28 HF4-01: shared anchor for the whole cluster. The
        // painter stacks dots tightly around this point and fans
        // labels out to one side.
        final anchor = Offset(baseX, y);
        for (int k = 0; k < clusterSize; k++) {
          positions[i + k] = anchor;
        }
      }
      row++;
      i = j;
    }
    return positions;
  }

  // ── R28 HF4-01 cluster geometry ────────────────────────────────────
  // Constants used by both the painter and the tap-target builder so
  // hit regions sit exactly where the labels render.
  static const double _clusterDotGapY = 7.0;     // vertical gap between dots in stack
  static const double _clusterLabelGapY = 24.0;  // vertical gap between labels (readable)
  static const double _clusterLabelOffsetX = 90.0; // distance from anchor to labels column
  static const double _clusterYearOffsetX = 50.0;  // distance from anchor to year label

  /// Per-event LABEL position. For singletons this equals the dot
  /// position (positions[i]); the painter's existing label logic
  /// lays the text adjacent. For cluster events the label sits in
  /// the labels column to the right (LTR) / left (RTL) of the
  /// anchor, vertically spread by [_clusterLabelGapY].
  ///
  /// Used by the tap-target builder so a tap on the LABEL (not just
  /// the small dot) activates the event — labels are larger touch
  /// targets and where the user's eye actually goes.
  List<Offset> _computeLabelPositions(List<Offset> dotPositions) {
    final labels = List<Offset>.filled(dotPositions.length, Offset.zero);
    int i = 0;
    while (i < widget.events.length) {
      int j = i;
      while (j < widget.events.length &&
          widget.events[j].year == widget.events[i].year) {
        j++;
      }
      final clusterSize = j - i;
      if (clusterSize == 1) {
        labels[i] = dotPositions[i];
      } else {
        final anchor = dotPositions[i];
        for (int k = 0; k < clusterSize; k++) {
          final dy = (k - (clusterSize - 1) / 2.0) * _clusterLabelGapY;
          final dx = _isAr
              ? -_clusterLabelOffsetX
              : _clusterLabelOffsetX;
          labels[i + k] = Offset(anchor.dx + dx, anchor.dy + dy);
        }
      }
      i = j;
    }
    return labels;
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

                  // Constellation lines + stars + cluster geometry
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, _) => CustomPaint(
                      size: Size(screenW, _totalHeight),
                      painter: _SkyPainter(
                        events: widget.events,
                        positions: _positions,
                        labelPositions:
                            _computeLabelPositions(_positions),
                        completedCount: widget.completedCount,
                        majorEvents: _majorEvents,
                        pulseValue: _pulseCtrl.value,
                        isAr: _isAr,
                        clusterDotGapY: _clusterDotGapY,
                        clusterYearOffsetX: _clusterYearOffsetX,
                      ),
                    ),
                  ),

                  // Tap targets — dispatch to _handleStarTap.
                  // R28 HF4-01: for cluster events, tap region sits at
                  // the LABEL (where the user's eye reads + finger
                  // lands), not at the tightly-stacked tiny dot. Label
                  // position widened to accommodate the title text.
                  for (int i = 0; i < widget.events.length; i++) ...(() {
                    final labels = _computeLabelPositions(_positions);
                    final isCluster = labels[i] != _positions[i];
                    if (isCluster) {
                      return [
                        Positioned(
                          left: labels[i].dx - 60,
                          top: labels[i].dy - 12,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _handleStarTap(i),
                            child: const SizedBox(width: 130, height: 26),
                          ),
                        ),
                      ];
                    }
                    return [
                      Positioned(
                        left: _positions[i].dx - 22,
                        top: _positions[i].dy - 22,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _handleStarTap(i),
                          child: const SizedBox(width: 44, height: 44),
                        ),
                      ),
                    ];
                  }()),
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
  /// Per-event anchor position. For singletons this is also the
  /// star + label position. For same-year clusters all events in
  /// the cluster share one anchor (the cluster's center point).
  final List<Offset> positions;
  /// Per-event label position. For singletons equals [positions];
  /// for cluster events points into the offset labels column.
  final List<Offset> labelPositions;
  final int completedCount;
  final Set<int> majorEvents;
  final double pulseValue;
  final bool isAr;
  // R28 HF4-01 cluster geometry (from the parent state).
  final double clusterDotGapY;
  final double clusterYearOffsetX;

  _SkyPainter({
    required this.events,
    required this.positions,
    required this.labelPositions,
    required this.completedCount,
    required this.majorEvents,
    required this.pulseValue,
    required this.isAr,
    required this.clusterDotGapY,
    required this.clusterYearOffsetX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = events.length;

    // ── Constellation lines (R28 HF4-01) ────────────────────────────
    // Skip lines BETWEEN events in the same cluster (they share a
    // single anchor point — drawing line(p, p) is degenerate). Lines
    // ENTERING a cluster connect prev event → cluster anchor, and
    // EXITING connect cluster anchor → next event.
    for (int i = 1; i < total; i++) {
      if (events[i - 1].year == events[i].year) {
        continue; // intra-cluster, skip
      }
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

    // ── Stars / cluster dots + labels ───────────────────────────────
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    int i = 0;
    while (i < total) {
      // Find the cluster bounds for the current year.
      int j = i;
      while (j < total && events[j].year == events[i].year) {
        j++;
      }
      final clusterSize = j - i;
      if (clusterSize == 1) {
        _paintSingleStar(canvas, textPainter, i);
      } else {
        _paintCluster(canvas, textPainter, i, j);
      }
      i = j;
    }
  }

  // ── Singleton star + adjacent label (legacy rendering) ─────────────
  void _paintSingleStar(Canvas canvas, TextPainter textPainter, int i) {
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

  // ── Cluster of N≥2 events at the same year (R28 HF4-01 Mockup B) ──
  // Renders:
  //   • Tight vertical dot stack at the cluster anchor (one dot
  //     per event, stacked clusterDotGapY apart).
  //   • Dashed leader lines from each dot horizontally to its
  //     label in the offset labels column.
  //   • Event title + "year CE" lines at each label position.
  //   • Single year label centered vertically against the dot
  //     stack's middle, on the OPPOSITE side from the labels column.
  void _paintCluster(
      Canvas canvas, TextPainter textPainter, int start, int end) {
    final n = end - start;
    final anchor = positions[start];
    // Vertical centerline of the dot stack = anchor.dy. Stack spans
    // (n - 1) * dotGapY total; first dot at anchor.dy - half the span.
    final dotsHalfSpan = (n - 1) / 2.0 * clusterDotGapY;

    // Leader-line color (matches existing constellation line low-alpha
    // gold). Dashed via short segments.
    final leaderPaint = Paint()
      ..color = const Color(0xFFD4A843).withAlpha(80)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (int k = 0; k < n; k++) {
      final i = start + k;
      final dotY = anchor.dy + (k * clusterDotGapY) - dotsHalfSpan;
      final dotPos = Offset(anchor.dx, dotY);
      final labelPos = labelPositions[i];

      final isDone = i < completedCount;
      final isCurrent = i == completedCount;
      final isMajor = majorEvents.contains(i + 1);

      // Leader line (dashed). Horizontal between dot and label X.
      // In AR the labels column sits to the LEFT of the anchor —
      // line direction flips automatically because labelPos.dx is
      // less than anchor.dx in that case.
      _drawDashedLine(canvas, dotPos, Offset(labelPos.dx, dotY), leaderPaint);

      // Dot (smaller than singleton stars — these are dots, not stars).
      double radius;
      Color color;
      if (isDone) {
        radius = isMajor ? 4 : 3;
        color = const Color(0xFFD4A843);
      } else if (isCurrent) {
        radius = isMajor ? 5 : 4;
        color = const Color(0xFFE8C854);
      } else {
        radius = 2;
        color = const Color(0xFFD4A843).withAlpha(50);
      }
      canvas.drawCircle(dotPos, radius, Paint()..color = color);
      if (isDone) {
        canvas.drawCircle(
          dotPos,
          radius,
          Paint()
            ..color = const Color(0xFFD4A843).withAlpha(150)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.5,
        );
      }
      if (isCurrent) {
        final pulseRadius = 8.0 + pulseValue * 4;
        canvas.drawCircle(
          dotPos,
          pulseRadius,
          Paint()
            ..color = const Color(0xFFD4A843)
                .withAlpha((90 * (1 - pulseValue)).round())
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
      }

      // Event title + year CE label. Visible for done / current /
      // locked alike — the cluster stacks need to label every dot
      // so users can identify which event is which (the sequential-
      // reveal logic from singletons doesn't fit a same-year cluster).
      final event = events[i];
      final title = isAr ? event.titleAr : event.title;
      final color2 = isDone || isCurrent
          ? Color(isCurrent ? 0xFFE8D8B8 : 0xCCE8D8B8)
          : const Color(0x66E8D8B8);

      // RTL: labels column is on the LEFT of anchor. Title text aligns
      // to the RIGHT edge of the column (against the leader line).
      // LTR: labels column is on the RIGHT. Title aligns LEFT (against
      // the leader line).
      textPainter
        ..text = TextSpan(
          text: title,
          style: TextStyle(
            color: color2,
            fontSize: isCurrent ? 9.5 : 9,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
            fontFamily: 'Georgia',
          ),
        )
        ..textDirection = isAr ? TextDirection.rtl : TextDirection.ltr
        ..layout(maxWidth: 130);
      final titleX = isAr
          ? labelPos.dx - textPainter.width
          : labelPos.dx;
      textPainter.paint(
        canvas,
        Offset(titleX, labelPos.dy - textPainter.height / 2 - 4),
      );

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
      final dateX = isAr
          ? labelPos.dx - textPainter.width
          : labelPos.dx;
      textPainter.paint(
        canvas,
        Offset(dateX, labelPos.dy + 4),
      );
    }

    // Year label, centered vertically against the dot stack's middle
    // (anchor.dy regardless of N). Sits on the OPPOSITE side of the
    // labels column — LTR labels are right of anchor → year is left;
    // AR labels are left of anchor → year is right.
    final yearText = '${events[start].year} CE';
    textPainter
      ..text = TextSpan(
        text: yearText,
        style: TextStyle(
          color: const Color(0xFFD4A843).withAlpha(170),
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          fontFamily: 'Georgia',
          letterSpacing: 0.4,
        ),
      )
      ..textDirection = TextDirection.ltr
      ..layout(maxWidth: 80);
    final yearX = isAr
        ? anchor.dx + clusterYearOffsetX
        : anchor.dx - clusterYearOffsetX - textPainter.width;
    textPainter.paint(
      canvas,
      Offset(yearX, anchor.dy - textPainter.height / 2),
    );
  }

  // Simple dashed-line painter for leader lines.
  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 3.0;
    const gapWidth = 2.5;
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final totalLen = sqrt(dx * dx + dy * dy);
    if (totalLen < 1) return;
    final stepLen = dashWidth + gapWidth;
    final ux = dx / totalLen;
    final uy = dy / totalLen;
    double walked = 0;
    while (walked < totalLen) {
      final segEnd = walked + dashWidth;
      final clamped = segEnd > totalLen ? totalLen : segEnd;
      canvas.drawLine(
        Offset(start.dx + ux * walked, start.dy + uy * walked),
        Offset(start.dx + ux * clamped, start.dy + uy * clamped),
        paint,
      );
      walked += stepLen;
    }
  }

  @override
  bool shouldRepaint(covariant _SkyPainter old) =>
      old.completedCount != completedCount ||
      old.pulseValue != pulseValue ||
      old.isAr != isAr ||
      old.events.length != events.length ||
      old.clusterDotGapY != clusterDotGapY ||
      old.clusterYearOffsetX != clusterYearOffsetX;

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
