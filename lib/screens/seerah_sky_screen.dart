import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../data/m1_data.dart';
import '../services/prefs_service.dart';

/// R22 Part 2 — Stars of the Seerah (نجوم السيرة).
///
/// A scrollable night sky where each of the 155 events is a star along a
/// winding constellation path. Completed stars glow gold; the current star
/// pulses; future stars are barely visible specks. Replaces LivingMapScreen.
class SeerahSkyScreen extends StatefulWidget {
  const SeerahSkyScreen({super.key});

  @override
  State<SeerahSkyScreen> createState() => _SeerahSkyScreenState();
}

class _SeerahSkyScreenState extends State<SeerahSkyScreen>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollCtrl;
  late final AnimationController _pulseCtrl;

  bool get _isAr => PrefsService.isAr;

  // ── Major events (larger stars + cross sparkle) ─────────────────────
  static const _majorEvents = {3, 11, 14, 17, 24, 31, 47, 67, 86, 101, 152, 155};

  // ── Era regions ─────────────────────────────────────────────────────
  static const _eras = [
    (range: 47, en: 'The Prophetic Dawn', ar: 'الفجر النبوي'),
    (range: 82, en: 'The Community Rises', ar: 'نهوض الأمّة'),
    (range: 120, en: 'The Turning Tide', ar: 'تحوّل المدّ'),
    (range: 155, en: 'The Final Chapter', ar: 'الفصل الأخير'),
  ];

  static const double _starSpacing = 65.0;
  late final double _totalHeight;
  late final List<Offset> _positions;
  late int _completedCount;
  int? _selectedIdx;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    // B-01: Count ALL completions, not sequential (break was wrong).
    _completedCount = m1Events
        .where((e) => PrefsService.isEventCompleted(e.globalOrder))
        .length;

    _totalHeight = m1Events.length * _starSpacing + 340;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentStar();
    });
  }

  List<Offset> _generatePositions(double screenW, double bottomPad) {
    final positions = <Offset>[];
    final centerX = screenW / 2;
    final amplitude = screenW * 0.28;
    // B-02: 140px bottom allowance so Event 1 clears the bottom bar.
    final bottomAllowance = 140.0 + bottomPad;
    for (int i = 0; i < m1Events.length; i++) {
      final y = _totalHeight - (bottomAllowance + i * _starSpacing);
      final wave = sin(i * 0.6 + 0.3) * amplitude;
      final jitter = sin(i * 2.1) * 15;
      positions.add(Offset(centerX + wave + jitter, y));
    }
    return positions;
  }

  void _scrollToCurrentStar() {
    if (!_scrollCtrl.hasClients) return;
    if (_completedCount >= m1Events.length) return;
    final targetY = _positions[_completedCount].dy;
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

  int _eraIndex(int globalOrder) {
    for (int i = 0; i < _eras.length; i++) {
      if (globalOrder <= _eras[i].range) return i;
    }
    return _eras.length - 1;
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    _positions = _generatePositions(screenW, bottomPad);
    final currentOrder = _completedCount + 1;

    return Scaffold(
      backgroundColor: const Color(0xFF060810),
      body: Stack(
        children: [
          // ── Scrollable sky ─────────────────────────────────────────
          SingleChildScrollView(
            controller: _scrollCtrl,
            child: SizedBox(
              width: screenW,
              height: _totalHeight,
              child: Stack(
                children: [
                  // Deep sky bg
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
                      top: ((i * 23 + i * i * 7) % (_totalHeight - 20).toInt())
                          .toDouble(),
                      child: Container(
                        width: i % 5 == 0 ? 1.5 : 1,
                        height: i % 5 == 0 ? 1.5 : 1,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white
                              .withAlpha((20 + (i % 7) * 8).clamp(0, 255)),
                        ),
                      ),
                    ),

                  // Constellation lines + stars via CustomPaint
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, _) => CustomPaint(
                      size: Size(screenW, _totalHeight),
                      painter: _SkyPainter(
                        events: m1Events,
                        positions: _positions,
                        completedCount: _completedCount,
                        majorEvents: _majorEvents,
                        pulseValue: _pulseCtrl.value,
                        isAr: _isAr,
                      ),
                    ),
                  ),

                  // Tap targets on stars (direct index mapping)
                  for (int i = 0; i < m1Events.length; i++)
                    Positioned(
                      left: _positions[i].dx - 22,
                      top: _positions[i].dy - 22,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (i < _completedCount) {
                            setState(() => _selectedIdx = i);
                          }
                        },
                        child: const SizedBox(width: 44, height: 44),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Fixed header ───────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xF0060810), Color(0xCC060810), Colors.transparent],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha(13),
                            border: Border.all(
                                color: AppColors.gold.withAlpha(40)),
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.arrow_back_ios_rounded,
                              size: 14,
                              color: AppColors.gold.withAlpha(130)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _isAr ? 'نجوم السيرة' : 'STARS OF THE SEERAH',
                        style: GoogleFonts.lora(
                          color: AppColors.gold,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withAlpha(15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.gold.withAlpha(40)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('✦ ',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.gold.withAlpha(160))),
                            Text(
                              '$_completedCount / ${m1Events.length}',
                              style: GoogleFonts.nunito(
                                color: AppColors.gold,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Era bar
                  Row(
                    children: [
                      for (int i = 0; i < _eras.length; i++)
                        Expanded(
                          child: Container(
                            height: 2,
                            margin: EdgeInsets.only(
                                right: i < _eras.length - 1 ? 4 : 0),
                            decoration: BoxDecoration(
                              color: i <= _eraIndex(currentOrder)
                                  ? AppColors.gold.withAlpha(100)
                                  : AppColors.gold.withAlpha(20),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _eraForEvent(currentOrder),
                    style: GoogleFonts.nunito(
                      color: AppColors.gold.withAlpha(90),
                      fontSize: 9,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Fixed bottom bar (next event CTA) ──────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xF0060810), Colors.transparent],
                ),
              ),
              padding: EdgeInsets.fromLTRB(16, 24, 16, bottomPad + 12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xEE0E1624),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppColors.gold.withAlpha(50)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold.withAlpha(25),
                        border: Border.all(
                            color: AppColors.gold.withAlpha(80), width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _completedCount < m1Events.length
                            ? '${_completedCount + 1}'
                            : '✦',
                        style: GoogleFonts.nunito(
                          color: AppColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _completedCount < m1Events.length
                                ? (_isAr
                                    ? m1Events[_completedCount].titleAr
                                    : m1Events[_completedCount].title)
                                : (_isAr
                                    ? 'اكتملت الرحلة'
                                    : 'Journey complete'),
                            style: GoogleFonts.nunito(
                              color: AppColors.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            textDirection:
                                _isAr ? TextDirection.rtl : TextDirection.ltr,
                          ),
                          Text(
                            _completedCount < m1Events.length
                                ? '${m1Events[_completedCount].year} CE'
                                : '${m1Events.length} / ${m1Events.length}',
                            style: GoogleFonts.nunito(
                              color: AppColors.gold.withAlpha(100),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.gold.withAlpha(80)),
                        ),
                        child: Text(
                          _completedCount < m1Events.length
                              ? (_isAr ? 'ابدأ' : 'Start')
                              : (_isAr ? 'اكتمل' : 'Done'),
                          style: GoogleFonts.nunito(
                            color: AppColors.gold,
                            fontSize: 10,
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

          // ── Detail bottom sheet ────────────────────────────────────
          if (_selectedIdx != null)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _buildDetailSheet(_selectedIdx!),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailSheet(int eventIdx) {
    final event = m1Events[eventIdx];
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xF80A1028), Color(0xFE080C18)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: AppColors.gold.withAlpha(50)),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: AppColors.gold.withAlpha(60),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withAlpha(20),
                  border: Border.all(
                      color: AppColors.gold.withAlpha(80), width: 1.5),
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold,
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.gold.withAlpha(100), blurRadius: 8)
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isAr ? event.titleAr : event.title,
                      style: GoogleFonts.nunito(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textDirection:
                          _isAr ? TextDirection.rtl : TextDirection.ltr,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${event.year} CE  ·  ${_isAr ? 'الحدث' : 'Event'} ${event.globalOrder}',
                      style: GoogleFonts.nunito(
                        color: AppColors.gold.withAlpha(130),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedIdx = null);
                    Navigator.pop(context);
                    // Return to event list — the event will be opened
                    // from there via the normal flow.
                  },
                  child: Container(
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.gold.withAlpha(50)),
                    ),
                    child: Text(
                      _isAr ? 'أعد القراءة' : 'Re-read',
                      style: GoogleFonts.nunito(
                        color: AppColors.gold,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _selectedIdx = null),
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(8),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.white.withAlpha(15)),
                  ),
                  child: Text(
                    _isAr ? 'إغلاق' : 'Close',
                    style: GoogleFonts.nunito(
                      color: Colors.white.withAlpha(100),
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Custom painter for stars + constellation lines ──────────────────────────

class _SkyPainter extends CustomPainter {
  final List events;
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

      // Glow halo for done/current
      if (isDone || isCurrent) {
        final glowPaint = Paint()
          ..color = const Color(0xFFD4A843)
              .withAlpha(isCurrent ? 15 : 8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
        canvas.drawCircle(pos, isMajor ? 20 : 14, glowPaint);
      }

      // Pulse ring for current
      if (isCurrent) {
        final pulseRadius = (isMajor ? 16.0 : 12.0) +
            pulseValue * 6;
        final pulsePaint = Paint()
          ..color = const Color(0xFFD4A843)
              .withAlpha((100 * (1 - pulseValue)).round())
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        canvas.drawCircle(pos, pulseRadius, pulsePaint);
      }

      // Star core
      canvas.drawCircle(pos, radius, Paint()..color = color);

      // Border on done stars
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

      // Cross sparkle on major done stars
      if (isMajor && isDone) {
        final sparkle = Paint()
          ..color = const Color(0xFFD4A843).withAlpha(80)
          ..strokeWidth = 0.5;
        canvas.drawLine(
            Offset(pos.dx, pos.dy - 12), Offset(pos.dx, pos.dy + 12), sparkle);
        canvas.drawLine(
            Offset(pos.dx - 12, pos.dy), Offset(pos.dx + 12, pos.dy), sparkle);
      }

      // R24 B-03: Event labels on completed/current stars
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

        // Date below label
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
      old.isAr != isAr;
}
