import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../data/m1_data.dart';
import '../data/map_locations.dart';
import '../models/map_location.dart';
import '../models/journey_event.dart';
import '../services/prefs_service.dart';

// ── Coastline painter (Arabian Peninsula outline) ───────────────────────────

class _CoastlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold.withAlpha(45)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    Offset p(double x, double y) => Offset(x * w, y * h);

    // ── Arabian Peninsula ─────────────────────────────────────────────────
    final peninsula = Path();

    // Start at northwest — top of the Red Sea / Sinai area
    peninsula.moveTo(p(0.40, 0.18).dx, p(0.40, 0.18).dy);

    // Red Sea (west coast) — curve down along the peninsula's western side
    peninsula.quadraticBezierTo(
      p(0.36, 0.28).dx, p(0.36, 0.28).dy,
      p(0.40, 0.36).dx, p(0.40, 0.36).dy,
    );
    peninsula.quadraticBezierTo(
      p(0.38, 0.44).dx, p(0.38, 0.44).dy,
      p(0.42, 0.52).dx, p(0.42, 0.52).dy,
    );
    peninsula.quadraticBezierTo(
      p(0.43, 0.62).dx, p(0.43, 0.62).dy,
      p(0.46, 0.72).dx, p(0.46, 0.72).dy,
    );
    peninsula.quadraticBezierTo(
      p(0.48, 0.80).dx, p(0.48, 0.80).dy,
      p(0.50, 0.86).dx, p(0.50, 0.86).dy,
    );

    // Gulf of Aden / south coast — curve east along the southern edge
    peninsula.quadraticBezierTo(
      p(0.56, 0.90).dx, p(0.56, 0.90).dy,
      p(0.62, 0.87).dx, p(0.62, 0.87).dy,
    );
    peninsula.quadraticBezierTo(
      p(0.68, 0.84).dx, p(0.68, 0.84).dy,
      p(0.72, 0.78).dx, p(0.72, 0.78).dy,
    );

    // Oman / UAE — up around the eastern tip
    peninsula.quadraticBezierTo(
      p(0.74, 0.72).dx, p(0.74, 0.72).dy,
      p(0.70, 0.66).dx, p(0.70, 0.66).dy,
    );

    // Persian Gulf (east coast) — up along the eastern side
    peninsula.quadraticBezierTo(
      p(0.64, 0.62).dx, p(0.64, 0.62).dy,
      p(0.62, 0.55).dx, p(0.62, 0.55).dy,
    );
    peninsula.quadraticBezierTo(
      p(0.63, 0.48).dx, p(0.63, 0.48).dy,
      p(0.65, 0.42).dx, p(0.65, 0.42).dy,
    );
    peninsula.quadraticBezierTo(
      p(0.62, 0.34).dx, p(0.62, 0.34).dy,
      p(0.58, 0.28).dx, p(0.58, 0.28).dy,
    );

    // Close back northward toward Sinai
    peninsula.quadraticBezierTo(
      p(0.52, 0.22).dx, p(0.52, 0.22).dy,
      p(0.46, 0.18).dx, p(0.46, 0.18).dy,
    );
    peninsula.quadraticBezierTo(
      p(0.43, 0.17).dx, p(0.43, 0.17).dy,
      p(0.40, 0.18).dx, p(0.40, 0.18).dy,
    );

    canvas.drawPath(peninsula, paint);

    // ── Africa / Abyssinia (separate small landmass, west side) ───────────
    final africa = Path();
    africa.moveTo(p(0.14, 0.66).dx, p(0.14, 0.66).dy);
    africa.quadraticBezierTo(
      p(0.12, 0.74).dx, p(0.12, 0.74).dy,
      p(0.16, 0.82).dx, p(0.16, 0.82).dy,
    );
    africa.quadraticBezierTo(
      p(0.20, 0.88).dx, p(0.20, 0.88).dy,
      p(0.24, 0.86).dx, p(0.24, 0.86).dy,
    );
    africa.quadraticBezierTo(
      p(0.26, 0.78).dx, p(0.26, 0.78).dy,
      p(0.23, 0.70).dx, p(0.23, 0.70).dy,
    );
    africa.quadraticBezierTo(
      p(0.19, 0.65).dx, p(0.19, 0.65).dy,
      p(0.14, 0.66).dx, p(0.14, 0.66).dy,
    );

    canvas.drawPath(africa, paint);
  }

  @override
  bool shouldRepaint(covariant _CoastlinePainter oldDelegate) => false;
}

// ── Route painter ────────────────────────────────────────────────────────────

class _RouteLinePainter extends CustomPainter {
  final List<MapLocation> locations;
  final Size mapSize;
  final int currentOrder;

  _RouteLinePainter({
    required this.locations,
    required this.mapSize,
    required this.currentOrder,
  });

  Offset _pos(MapLocation loc) =>
      Offset(loc.mapX * mapSize.width, loc.mapY * mapSize.height);

  bool _isLocationCompleted(MapLocation loc) {
    if (loc.eventIds.isEmpty) return false;
    for (final eid in loc.eventIds) {
      final ev = m1Events.cast<JourneyEvent?>().firstWhere(
            (e) => e?.id == eid,
            orElse: () => null,
          );
      if (ev != null && !PrefsService.isEventCompleted(ev.globalOrder)) {
        return false;
      }
    }
    return true;
  }

  bool _hasAnyCompleted(MapLocation loc) {
    for (final eid in loc.eventIds) {
      final ev = m1Events.cast<JourneyEvent?>().firstWhere(
            (e) => e?.id == eid,
            orElse: () => null,
          );
      if (ev != null && PrefsService.isEventCompleted(ev.globalOrder)) {
        return true;
      }
    }
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Build ordered location list from locationRouteOrder
    final ordered = <MapLocation>[];
    for (final id in locationRouteOrder) {
      final loc = locations.cast<MapLocation?>().firstWhere(
            (l) => l?.id == id,
            orElse: () => null,
          );
      if (loc != null) ordered.add(loc);
    }

    for (int i = 0; i < ordered.length - 1; i++) {
      final from = ordered[i];
      final to = ordered[i + 1];
      final a = _pos(from);
      final b = _pos(to);

      final fromDone = _isLocationCompleted(from) || _hasAnyCompleted(from);
      final toDone = _isLocationCompleted(to) || _hasAnyCompleted(to);
      final segmentCompleted = fromDone && toDone;

      if (segmentCompleted) {
        // Solid gold line
        final paint = Paint()
          ..color = AppColors.gold.withAlpha(102)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;
        canvas.drawLine(a, b, paint);
      } else {
        // Dotted line
        _drawDottedLine(canvas, a, b, AppColors.gold.withAlpha(51));
      }
    }
  }

  void _drawDottedLine(Canvas canvas, Offset a, Offset b, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    const dashLen = 4.0;
    const gapLen = 6.0;
    final steps = dist / (dashLen + gapLen);
    final ux = dx / dist;
    final uy = dy / dist;
    for (int s = 0; s < steps; s++) {
      final startD = s * (dashLen + gapLen);
      final endD = startD + dashLen;
      canvas.drawLine(
        Offset(a.dx + ux * startD, a.dy + uy * startD),
        Offset(a.dx + ux * endD, a.dy + uy * endD),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RouteLinePainter oldDelegate) => true;
}

// ── Location status enum ─────────────────────────────────────────────────────

enum _LocationStatus { completed, current, partial, locked }

// ── Main screen ──────────────────────────────────────────────────────────────

class LivingMapScreen extends StatefulWidget {
  const LivingMapScreen({super.key});

  @override
  State<LivingMapScreen> createState() => _LivingMapScreenState();
}

class _LivingMapScreenState extends State<LivingMapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  late int _currentOrder;

  // Transformation controller — used to read current zoom scale so we can
  // hide sub-location labels when zoomed out (R17-03).
  final TransformationController _transformController =
      TransformationController();
  double _currentScale = 1.0;

  // Virtual map size (the coordinate space)
  static const _mapWidth = 800.0;
  static const _mapHeight = 900.0;

  // Mecca's normalized position — used to detect sub-locations that
  // cluster around it so their labels can be hidden when zoomed out.
  static const double _meccaX = 0.42;
  static const double _meccaY = 0.62;
  static const double _subLocationRadius = 0.05;
  static const double _labelZoomThreshold = 1.5;

  @override
  void initState() {
    super.initState();
    _currentOrder = PrefsService.currentOrder;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _transformController.addListener(_onTransformChanged);
  }

  void _onTransformChanged() {
    final scale = _transformController.value.getMaxScaleOnAxis();
    if ((scale - _currentScale).abs() > 0.01) {
      setState(() => _currentScale = scale);
    }
  }

  @override
  void dispose() {
    _transformController.removeListener(_onTransformChanged);
    _transformController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// True if this location is Mecca itself.
  bool _isMecca(MapLocation loc) => loc.id == 'mecca';

  /// True if this location is a sub-location clustered near Mecca
  /// (within _subLocationRadius normalized units) — excluding Mecca itself.
  bool _isMeccaSubLocation(MapLocation loc) {
    if (_isMecca(loc)) return false;
    final dx = loc.mapX - _meccaX;
    final dy = loc.mapY - _meccaY;
    return (dx * dx + dy * dy) <= (_subLocationRadius * _subLocationRadius);
  }

  bool get _isAr => PrefsService.isAr;

  // ── Location status helpers ────────────────────────────────────────────

  _LocationStatus _status(MapLocation loc) {
    if (loc.eventIds.isEmpty) return _LocationStatus.locked;

    bool allDone = true;
    bool anyDone = false;
    bool hasCurrent = false;

    for (final eid in loc.eventIds) {
      final ev = _findEvent(eid);
      if (ev == null) continue;
      if (PrefsService.isEventCompleted(ev.globalOrder)) {
        anyDone = true;
      } else {
        allDone = false;
      }
      if (ev.globalOrder == _currentOrder) hasCurrent = true;
    }

    if (allDone && anyDone) return _LocationStatus.completed;
    if (hasCurrent) return _LocationStatus.current;
    if (anyDone) return _LocationStatus.partial;
    return _LocationStatus.locked;
  }

  JourneyEvent? _findEvent(String id) {
    return m1Events.cast<JourneyEvent?>().firstWhere(
          (e) => e?.id == id,
          orElse: () => null,
        );
  }

  // ── Tap handler — bottom sheet ─────────────────────────────────────────

  void _onLocationTap(MapLocation loc) {
    final status = _status(loc);
    final isAr = _isAr;

    if (status == _LocationStatus.locked) {
      // Show mystery toast
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr ? '؟؟؟ — اكتشف هذا الموقع لاحقاً' : '??? — Discover this location later',
            style: GoogleFonts.nunito(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1A2030),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

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
          Navigator.pop(context); // back to event list — let it handle navigation
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isAr = _isAr;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF04060D),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF04060D), // fallback
          image: DecorationImage(
            image: AssetImage('assets/textures/parchment_dark.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────
          Container(
            padding: EdgeInsetsDirectional.fromSTEB(16, topPad + 12, 16, 14),
            decoration: BoxDecoration(
              color: const Color(0xFF04060D).withAlpha(220),
              border: Border(
                bottom: BorderSide(color: AppColors.gold.withAlpha(30)),
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
                      border: Border.all(color: AppColors.gold.withAlpha(40)),
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
                          color: AppColors.gold,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        isAr ? 'الخريطة الحيّة' : 'The Living Map',
                        style: GoogleFonts.lora(
                          color: AppColors.textMuted.withAlpha(120),
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Map area ────────────────────────────────────────────────
          Expanded(
            child: InteractiveViewer(
              transformationController: _transformController,
              minScale: 1.0,
              maxScale: 3.0,
              boundaryMargin: const EdgeInsets.all(60),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Use the full available area, maintaining aspect ratio
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;
                  final scale = math.min(w / _mapWidth, h / _mapHeight);
                  final mapW = _mapWidth * scale;
                  final mapH = _mapHeight * scale;
                  final offsetX = (w - mapW) / 2;
                  final offsetY = (h - mapH) / 2;

                  return Stack(
                    children: [
                      // Subtle darkened overlay on top of the parchment
                      // texture so route lines and markers still glow.
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF04060D).withAlpha(140),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: const EdgeInsets.all(8),
                        ),
                      ),
                      // Coastline outline (behind routes and markers)
                      Positioned(
                        left: offsetX,
                        top: offsetY,
                        width: mapW,
                        height: mapH,
                        child: CustomPaint(
                          painter: _CoastlinePainter(),
                        ),
                      ),
                      // Route lines
                      Positioned(
                        left: offsetX,
                        top: offsetY,
                        width: mapW,
                        height: mapH,
                        child: CustomPaint(
                          painter: _RouteLinePainter(
                            locations: mapLocations,
                            mapSize: Size(mapW, mapH),
                            currentOrder: _currentOrder,
                          ),
                        ),
                      ),
                      // Location markers
                      ...mapLocations.map((loc) {
                        final x = offsetX + loc.mapX * mapW;
                        final y = offsetY + loc.mapY * mapH;
                        return _buildMarker(loc, x, y, isAr);
                      }),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildMarker(MapLocation loc, double x, double y, bool isAr) {
    final status = _status(loc);
    final double dotSize;
    final Color dotColor;
    bool showLabel;
    final bool showCheck;

    switch (status) {
      case _LocationStatus.completed:
        dotSize = 14;
        dotColor = AppColors.gold;
        showLabel = true;
        showCheck = true;
      case _LocationStatus.current:
        dotSize = 16;
        dotColor = AppColors.gold;
        showLabel = true;
        showCheck = false;
      case _LocationStatus.partial:
        dotSize = 12;
        dotColor = AppColors.gold.withAlpha(160);
        showLabel = true;
        showCheck = false;
      case _LocationStatus.locked:
        dotSize = 8;
        dotColor = AppColors.gold.withAlpha(77);
        showLabel = false;
        showCheck = false;
    }

    // R17-03: When zoomed out (< 1.5x), hide labels for sub-locations
    // clustered near Mecca to prevent overlap. Mecca itself always keeps
    // its label. Dots remain visible at every zoom level.
    if (showLabel &&
        _currentScale < _labelZoomThreshold &&
        _isMeccaSubLocation(loc)) {
      showLabel = false;
    }

    final label = isAr ? loc.nameAr : loc.name;

    return Positioned(
      left: x - 40,
      top: y - 40,
      width: 80,
      height: 80,
      child: GestureDetector(
        onTap: () => _onLocationTap(loc),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow for current / completed
            if (status == _LocationStatus.current)
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) => Container(
                  width: dotSize + 18,
                  height: dotSize + 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold.withAlpha(
                        (30 * _pulseAnim.value).toInt()),
                  ),
                ),
              ),
            if (status == _LocationStatus.completed)
              Container(
                width: dotSize + 10,
                height: dotSize + 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withAlpha(40),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            // The dot
            if (status == _LocationStatus.current)
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) => Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor.withAlpha(
                        (180 + 75 * _pulseAnim.value).toInt().clamp(0, 255)),
                    border: Border.all(
                        color: AppColors.gold.withAlpha(200), width: 2),
                  ),
                ),
              )
            else
              Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                  border: showCheck
                      ? Border.all(
                          color: AppColors.gold.withAlpha(180), width: 1.5)
                      : null,
                ),
                child: showCheck
                    ? const Icon(Icons.check_rounded,
                        size: 9, color: Color(0xFF04060D))
                    : null,
              ),
            // Label
            if (showLabel)
              Positioned(
                bottom: 4,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    color: status == _LocationStatus.current
                        ? AppColors.gold
                        : AppColors.gold.withAlpha(180),
                    fontSize: status == _LocationStatus.current ? 10 : 9,
                    fontWeight: status == _LocationStatus.current
                        ? FontWeight.w700
                        : FontWeight.w600,
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

// ── Location detail bottom sheet ─────────────────────────────────────────────

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
    return m1Events.cast<JourneyEvent?>().firstWhere(
          (e) => e?.id == id,
          orElse: () => null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final events = <JourneyEvent>[];
    for (final eid in location.eventIds) {
      final ev = _findEvent(eid);
      if (ev != null) events.add(ev);
    }
    events.sort((a, b) => a.globalOrder.compareTo(b.globalOrder));

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
              color: AppColors.gold.withAlpha(60),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Location name bilingual
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text(
                  isAr ? location.nameAr : location.name,
                  style: GoogleFonts.cinzelDecorative(
                    color: AppColors.gold,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isAr ? location.name : location.nameAr,
                  style: GoogleFonts.lora(
                    color: AppColors.textMuted.withAlpha(120),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.gold.withAlpha(30), height: 1),
          // Event list
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shrinkWrap: true,
              itemCount: events.length,
              itemBuilder: (_, i) {
                final ev = events[i];
                final completed =
                    PrefsService.isEventCompleted(ev.globalOrder);
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
                            ? AppColors.gold.withAlpha(12)
                            : AppColors.card.withAlpha(80),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCurrent
                              ? AppColors.gold.withAlpha(80)
                              : AppColors.divider.withAlpha(40),
                        ),
                      ),
                      child: Opacity(
                        opacity: locked ? 0.45 : 1.0,
                        child: Row(
                          children: [
                            // Status icon
                            if (completed)
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.gold.withAlpha(20),
                                ),
                                child: const Icon(Icons.check_rounded,
                                    size: 14, color: AppColors.gold),
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
                                      color: AppColors.gold.withAlpha(100)),
                                ),
                                child: Center(
                                  child: Text(
                                    '${ev.globalOrder}',
                                    style: GoogleFonts.nunito(
                                      color: AppColors.gold,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 12),
                            // Event title
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAr ? ev.titleAr : ev.title,
                                    textDirection: isAr
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
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
                            // Play button for current
                            if (isCurrent)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.gold,
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
