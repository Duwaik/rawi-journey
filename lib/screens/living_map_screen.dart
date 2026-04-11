import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../data/m1_data.dart';
import '../data/map_locations.dart';
import '../models/journey_event.dart';
import '../models/map_location.dart';
import '../services/prefs_service.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

const _inkBrown = Color(0xFF4A3520);
const _inkBrownFaded = Color(0x554A3520);
const _inkBrownGhost = Color(0x224A3520);
const _gold = AppColors.gold;
const _virtualMapWidth = 800.0;
const _virtualMapHeight = 1100.0;

// ─── Location state ──────────────────────────────────────────────────────────

enum _LocState {
  /// All events at this location are completed.
  completed,

  /// At least one event is the user's current event (or partial progress).
  current,

  /// Revealed but the user hasn't reached its events yet.
  revealed,

  /// One of the next 3 locations about to appear; rendered as faint "?".
  upcoming,

  /// Not yet on the map.
  hidden,
}

// ─── Wobble path generator ──────────────────────────────────────────────────

/// Build a slightly imperfect Path between two points by deflecting the
/// midpoint along the perpendicular. Deterministic on (idA, idB) so the
/// same edge always wobbles the same way.
Path _wobblePath(Offset a, Offset b, String idA, String idB) {
  final path = Path()..moveTo(a.dx, a.dy);
  final dx = b.dx - a.dx;
  final dy = b.dy - a.dy;
  final dist = math.sqrt(dx * dx + dy * dy);
  if (dist < 1) {
    path.lineTo(b.dx, b.dy);
    return path;
  }
  // Perpendicular unit vector
  final pxN = -dy / dist;
  final pyN = dx / dist;
  // Deterministic wobble seed from the two ids
  final seed = (idA.codeUnits.fold<int>(0, (s, c) => s + c) * 31 +
          idB.codeUnits.fold<int>(0, (s, c) => s + c)) %
      1000;
  final amp = (3.0 + (seed % 5)) * (dist / 200.0).clamp(0.5, 2.5);
  // Two control points along the line, both deflected
  final c1x = a.dx + dx * 0.33 + pxN * amp;
  final c1y = a.dy + dy * 0.33 + pyN * amp;
  final c2x = a.dx + dx * 0.66 - pxN * amp * 0.8;
  final c2y = a.dy + dy * 0.66 - pyN * amp * 0.8;
  path.cubicTo(c1x, c1y, c2x, c2y, b.dx, b.dy);
  return path;
}

// ─── Path painter ────────────────────────────────────────────────────────────

class _ParchmentPathPainter extends CustomPainter {
  final List<MapLocation> visible;
  final Set<String> completedIds;
  final Set<String> currentIds;
  final List<MapLocation> upcoming;

  _ParchmentPathPainter({
    required this.visible,
    required this.completedIds,
    required this.currentIds,
    required this.upcoming,
  });

  Offset _pos(MapLocation loc, Size size) =>
      Offset(loc.mapX * size.width, loc.mapY * size.height);

  bool _isLocOpen(MapLocation loc) =>
      completedIds.contains(loc.id) || currentIds.contains(loc.id);

  @override
  void paint(Canvas canvas, Size size) {
    final byId = {for (final l in visible) l.id: l};
    final upcomingById = {for (final l in upcoming) l.id: l};
    final drawnPairs = <String>{};

    for (final from in visible) {
      for (final toId in from.connectedTo) {
        // Avoid drawing the same edge twice
        final pair = ([from.id, toId]..sort()).join('|');
        if (drawnPairs.contains(pair)) continue;
        drawnPairs.add(pair);

        final to = byId[toId] ?? upcomingById[toId];
        if (to == null) continue;

        final a = _pos(from, size);
        final b = _pos(to, size);
        final path = _wobblePath(a, b, from.id, toId);

        final fromOpen = _isLocOpen(from);
        final toOpen = _isLocOpen(to);
        final toIsRevealed = byId.containsKey(toId);

        final Paint paint;
        if (fromOpen && toOpen) {
          // Traveled — solid ink line
          paint = Paint()
            ..color = _inkBrown
            ..strokeWidth = 1.7
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;
          canvas.drawPath(path, paint);
        } else if (fromOpen && toIsRevealed) {
          // Open path to a revealed (not yet completed) location
          paint = Paint()
            ..color = _inkBrownFaded
            ..strokeWidth = 1.4
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;
          canvas.drawPath(path, paint);
        } else if (fromOpen && upcomingById.containsKey(toId)) {
          // "Next" path to a yet-to-be-revealed upcoming location: dashed
          _drawDashedPath(canvas, path, _inkBrownGhost);
        }
        // Otherwise: invisible
      }
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final metrics = path.computeMetrics();
    const dashLen = 6.0;
    const gapLen = 5.0;
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final next = math.min(distance + dashLen, metric.length);
        final extract = metric.extractPath(distance, next);
        canvas.drawPath(extract, paint);
        distance = next + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParchmentPathPainter old) {
    return old.completedIds != completedIds ||
        old.currentIds != currentIds ||
        old.visible.length != visible.length;
  }
}

// ─── Main screen ─────────────────────────────────────────────────────────────

class LivingMapScreen extends StatefulWidget {
  const LivingMapScreen({super.key});

  @override
  State<LivingMapScreen> createState() => _LivingMapScreenState();
}

class _LivingMapScreenState extends State<LivingMapScreen>
    with SingleTickerProviderStateMixin {
  late int _currentOrder;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  final TransformationController _viewCtrl = TransformationController();

  @override
  void initState() {
    super.initState();
    _currentOrder = PrefsService.currentOrder;
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim =
        Tween<double>(begin: 0.55, end: 1.0).animate(CurvedAnimation(
      parent: _pulseCtrl,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _viewCtrl.dispose();
    super.dispose();
  }

  bool get _isAr => PrefsService.isAr;

  // ── State helpers ────────────────────────────────────────────────────────

  JourneyEvent? _findEvent(String id) {
    for (final e in m1Events) {
      if (e.id == id) return e;
    }
    return null;
  }

  _LocState _statusFor(MapLocation loc) {
    if (_currentOrder < loc.revealsAtEvent) return _LocState.hidden;
    if (loc.eventIds.isEmpty) return _LocState.revealed;

    bool allDone = true;
    bool anyCurrent = false;
    bool anyDone = false;
    for (final eid in loc.eventIds) {
      final ev = _findEvent(eid);
      if (ev == null) continue;
      if (PrefsService.isEventCompleted(ev.globalOrder)) {
        anyDone = true;
      } else {
        allDone = false;
      }
      if (ev.globalOrder == _currentOrder) anyCurrent = true;
    }
    if (anyCurrent) return _LocState.current;
    if (allDone && anyDone) return _LocState.completed;
    return _LocState.revealed;
  }

  void _onLocationTap(MapLocation loc, _LocState state) {
    final isAr = _isAr;
    if (state == _LocState.upcoming) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr ? '... وجهة جديدة تنتظرك' : 'A new destination awaits...',
            style: GoogleFonts.lora(color: const Color(0xFFE8D8B8)),
          ),
          backgroundColor: const Color(0xFF1A1410),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    if (state == _LocState.hidden) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LocationSheet(
        location: loc,
        isAr: isAr,
        currentOrder: _currentOrder,
        onEventTap: (event) {
          Navigator.pop(context); // close sheet
          Navigator.pop(context); // back to event list
        },
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isAr = _isAr;
    final topPad = MediaQuery.of(context).padding.top;

    final visible = visibleLocations(_currentOrder);
    final upcoming = upcomingLocations(_currentOrder);
    final completedIds = <String>{};
    final currentIds = <String>{};
    for (final loc in visible) {
      final s = _statusFor(loc);
      if (s == _LocState.completed) completedIds.add(loc.id);
      if (s == _LocState.current) currentIds.add(loc.id);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE8D5A8),
      body: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────────
          Container(
            padding: EdgeInsetsDirectional.fromSTEB(16, topPad + 12, 16, 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1410).withAlpha(220),
              border: Border(
                bottom: BorderSide(color: _gold.withAlpha(50)),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(8),
                      border: Border.all(color: _gold.withAlpha(50)),
                    ),
                    child: const Icon(Icons.arrow_back_rounded,
                        size: 18, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'الخريطة الحيّة' : 'The Living Map',
                        style: GoogleFonts.cinzelDecorative(
                          color: _gold,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        isAr ? 'The Living Map' : 'الخريطة الحيّة',
                        style: GoogleFonts.lora(
                          color: AppColors.textMuted.withAlpha(120),
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${visible.length}/${mapLocations.length}',
                  style: GoogleFonts.nunito(
                    color: _gold.withAlpha(160),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),

          // ── Parchment map area ─────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/textures/parchment_light.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: InteractiveViewer(
                transformationController: _viewCtrl,
                minScale: 0.9,
                maxScale: 3.5,
                boundaryMargin: const EdgeInsets.all(80),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final h = constraints.maxHeight;
                    final scale = math.min(
                        w / _virtualMapWidth, h / _virtualMapHeight);
                    final mapW = _virtualMapWidth * scale;
                    final mapH = _virtualMapHeight * scale;
                    final offsetX = (w - mapW) / 2;
                    final offsetY = (h - mapH) / 2;

                    return RepaintBoundary(
                      child: Stack(
                        children: [
                          // Ink paths between revealed locations
                          Positioned(
                            left: offsetX,
                            top: offsetY,
                            width: mapW,
                            height: mapH,
                            child: CustomPaint(
                              painter: _ParchmentPathPainter(
                                visible: visible,
                                completedIds: completedIds,
                                currentIds: currentIds,
                                upcoming: upcoming,
                              ),
                            ),
                          ),

                          // Upcoming "?" marks (drawn under revealed markers)
                          ...upcoming.map((loc) {
                            final x = offsetX + loc.mapX * mapW;
                            final y = offsetY + loc.mapY * mapH;
                            return _buildUpcomingMark(loc, x, y);
                          }),

                          // Revealed location markers
                          ...visible.map((loc) {
                            final state = _statusFor(loc);
                            final x = offsetX + loc.mapX * mapW;
                            final y = offsetY + loc.mapY * mapH;
                            return _buildMarker(loc, state, x, y, isAr);
                          }),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingMark(MapLocation loc, double x, double y) {
    return Positioned(
      left: x - 18,
      top: y - 18,
      width: 36,
      height: 36,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onLocationTap(loc, _LocState.upcoming),
        child: Center(
          child: Text(
            '?',
            style: GoogleFonts.cinzelDecorative(
              color: _inkBrownFaded,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarker(
      MapLocation loc, _LocState state, double x, double y, bool isAr) {
    if (state == _LocState.hidden) return const SizedBox.shrink();

    final double dotSize;
    final Color dotColor;
    switch (state) {
      case _LocState.completed:
        dotSize = 12;
        dotColor = _gold;
      case _LocState.current:
        dotSize = 14;
        dotColor = _gold;
      case _LocState.revealed:
        dotSize = 10;
        dotColor = _gold.withAlpha(180);
      case _LocState.upcoming:
      case _LocState.hidden:
        dotSize = 8;
        dotColor = _inkBrownFaded;
    }

    final label = isAr ? loc.nameAr : loc.name;

    return Positioned(
      left: x - 50,
      top: y - 24,
      width: 100,
      height: 60,
      child: GestureDetector(
        onTap: () => _onLocationTap(loc, state),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Dot (with pulse for current)
            if (state == _LocState.current)
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, _) => Container(
                  width: dotSize + 14,
                  height: dotSize + 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _gold.withAlpha((40 * _pulseAnim.value).toInt()),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                  border: state == _LocState.completed
                      ? Border.all(color: _inkBrown, width: 1)
                      : null,
                ),
              ),
            ),

            // Hand-sketched ink label
            Positioned(
              top: dotSize + 12,
              child: Text(
                label,
                textAlign: TextAlign.center,
                textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                style: GoogleFonts.lora(
                  color: state == _LocState.current ? _inkBrown : _inkBrownFaded,
                  fontSize: state == _LocState.current ? 11 : 10,
                  fontWeight: state == _LocState.current
                      ? FontWeight.w700
                      : FontWeight.w600,
                  letterSpacing: 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Location detail bottom sheet (kept from previous design) ───────────────

class _LocationSheet extends StatelessWidget {
  final MapLocation location;
  final bool isAr;
  final int currentOrder;
  final void Function(JourneyEvent) onEventTap;

  const _LocationSheet({
    required this.location,
    required this.isAr,
    required this.currentOrder,
    required this.onEventTap,
  });

  JourneyEvent? _findEvent(String id) {
    for (final e in m1Events) {
      if (e.id == id) return e;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final events = <JourneyEvent>[];
    for (final eid in location.eventIds) {
      final ev = _findEvent(eid);
      if (ev != null) events.add(ev);
    }
    events.sort((a, b) => a.globalOrder.compareTo(b.globalOrder));

    final completedCount =
        events.where((e) => PrefsService.isEventCompleted(e.globalOrder)).length;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.55,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0C1420),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _gold.withAlpha(60),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text(
                  isAr ? location.nameAr : location.name,
                  style: GoogleFonts.cinzelDecorative(
                    color: _gold,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isAr ? location.name : location.nameAr,
                  textDirection:
                      isAr ? ui.TextDirection.ltr : ui.TextDirection.rtl,
                  style: GoogleFonts.lora(
                    color: AppColors.textMuted.withAlpha(120),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAr
                      ? '$completedCount من ${events.length} مكتمل'
                      : '$completedCount of ${events.length} complete',
                  style: GoogleFonts.nunito(
                    color: _gold.withAlpha(150),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: _gold.withAlpha(30), height: 1),
          // Event list
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shrinkWrap: true,
              itemCount: events.length,
              itemBuilder: (_, i) {
                final ev = events[i];
                final completed = PrefsService.isEventCompleted(ev.globalOrder);
                final isCurrent = ev.globalOrder == currentOrder;
                final locked = ev.globalOrder > currentOrder;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: GestureDetector(
                    onTap: locked ? null : () => onEventTap(ev),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? _gold.withAlpha(12)
                            : AppColors.card.withAlpha(80),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCurrent
                              ? _gold.withAlpha(80)
                              : AppColors.divider.withAlpha(40),
                        ),
                      ),
                      child: Opacity(
                        opacity: locked ? 0.45 : 1.0,
                        child: Row(
                          children: [
                            if (completed)
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _gold.withAlpha(20),
                                ),
                                child: const Icon(Icons.check_rounded,
                                    size: 14, color: _gold),
                              )
                            else if (locked)
                              const Icon(Icons.lock_rounded,
                                  size: 16, color: Color(0xFF3A5A5A))
                            else
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: _gold.withAlpha(100)),
                                ),
                                child: Center(
                                  child: Text(
                                    '${ev.globalOrder}',
                                    style: GoogleFonts.nunito(
                                      color: _gold,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAr ? ev.titleAr : ev.title,
                                    textDirection: isAr
                                        ? ui.TextDirection.rtl
                                        : ui.TextDirection.ltr,
                                    style: GoogleFonts.nunito(
                                      color: locked
                                          ? const Color(0xFF5A7A7A)
                                          : const Color(0xFFE8D8B8),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${ev.year} CE',
                                    style: GoogleFonts.nunito(
                                      color: const Color(0xFF6A8A7A),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isCurrent)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 5),
                                decoration: BoxDecoration(
                                  color: _gold,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isAr ? 'ابدأ' : 'Play',
                                  style: GoogleFonts.nunito(
                                    color: const Color(0xFF04060D),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }
}
