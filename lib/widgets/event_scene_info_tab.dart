import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../services/prefs_service.dart';

/// R25-S3-6: Expandable info tab on the left edge of the event scene.
///
/// R27 S3-INFO1 redesign:
/// - Collapsed: only the 42 px (ⓘ) circle. No chevron ornament.
///   Tapping the panel (ⓘ) expands.
/// - Expanded: full panel + a `<` close chevron on the right edge.
///   Tapping the chevron — or outside the panel — collapses.
/// - Sizes: circle 52 → 42 (–20 %), glyph 32 → 26 (proportional).
/// - Vertical position: unchanged (0.45 × H) — the scene doesn't have
///   a strict alignment target; the lowered position on tent is a
///   tent-only move driven by its 5-icon right-side stack.
/// - Outside-tap dismiss + pan swallow (R26 S1v3-EE8.2) preserved.
///
/// Section 1 — YOUR LIGHT (lifetime, same source as tent)
/// Section 2 — THIS EVENT (4-dot hotspot-completion progress)
///
/// Full spec: RAWI_R25_SPRINT_ROADMAP §9.3.
class EventSceneInfoTab extends StatefulWidget {
  /// Number of hotspots in this event (for Section 2 dots).
  final int totalHotspots;

  /// Number of hotspots the user has completed in this event.
  final int discoveredHotspots;

  const EventSceneInfoTab({
    super.key,
    required this.totalHotspots,
    required this.discoveredHotspots,
  });

  @override
  State<EventSceneInfoTab> createState() => _EventSceneInfoTabState();
}

class _EventSceneInfoTabState extends State<EventSceneInfoTab>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _widthAnim;
  late final Animation<double> _contentOpacity;

  // R27 S3-INFO1: collapsed width shrunk from 90 to 50 — just enough
  // to hold the 42 px info circle with a 4 px side pad. The S1.5
  // always-visible chevron ornament is gone, so the wider panel it
  // required goes with it. Expanded width unchanged.
  static const double _collapsedWidth = 50;
  static const double _expandedWidth = 180;

  // R27 S3-INFO1: info circle 52 → 42 (–20 %). Glyph 32 → 26
  // (proportional). Close chevron (expanded state) reuses these.
  static const double _circleSize = 42;
  static const double _glyphSize = 26;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _widthAnim = Tween<double>(begin: _collapsedWidth, end: _expandedWidth)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _contentOpacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  bool get _isAr => PrefsService.isAr;

  @override
  Widget build(BuildContext context) {
    // R26 S1v3-EE8.2: the widget expects to be wrapped in
    // `Positioned.fill` (see immersive_event_screen.dart call site).
    // When expanded the full-screen scrim absorbs tap + pan so the
    // movement layer never sees either. The tab itself is
    // Positioned(top: 0.45 × H, left: 0) inside the Stack.
    final screenH = MediaQuery.of(context).size.height;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (_expanded)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggle,
              // Swallow drag input so a tap-that-slightly-moves (common
              // on touchscreens) doesn't get claimed by the movement
              // GestureDetector living below this scrim in the parent
              // Stack. No-op handlers + opaque hit-testing are enough
              // to keep the gesture in the arena here.
              onPanDown: (_) {},
              onPanUpdate: (_) {},
              onPanEnd: (_) {},
              child: Container(color: Colors.black.withAlpha(77)), // 0.30
            ),
          ),
        // R27 S1-TENT6: nudged down from 0.40 → 0.45 of screen height
        // so the collapsed handle no longer overlaps Rawi's figure.
        // R27 S3-INFO1: keep at 0.45 — scene has no alignment target
        // (unlike tent, which drops further to match its 5-icon stack).
        Positioned(
          top: screenH * 0.45,
          left: 0,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) => Stack(
              clipBehavior: Clip.none,
              children: [
                _buildTab(),
                // R27 S3-INFO1: close chevron is expanded-only. No
                // chevron in the collapsed state — just the ⓘ.
                if (_ctrl.value > 0.02)
                  Positioned(
                    // Straddles the panel's right border 21 in / 21 out
                    // (88 px hit container centered at right edge, 42 px
                    // visual circle centered inside that).
                    right: -44,
                    top: 0,
                    bottom: 0,
                    child: Center(child: _buildCloseChevron()),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCloseChevron() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggle,
      child: Container(
        width: 88,
        height: 88,
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Container(
          width: _circleSize,
          height: _circleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0A0E18).withValues(alpha: 0.94),
            border: Border.all(
                color: AppColors.gold.withAlpha(170), width: 1.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(120),
                  blurRadius: 6,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Icon(
            // R27 S3-INFO1: close chevron mirrors for RTL — `<` in EN,
            // `>` in AR. Glyph chosen explicitly; `textDirection: ltr`
            // defeats any ambient auto-mirror so the picked glyph
            // renders as-is in both locales.
            _isAr
                ? Icons.chevron_right_rounded
                : Icons.chevron_left_rounded,
            size: _glyphSize,
            color: AppColors.gold,
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );
  }

  Widget _buildTab() {
    final isCollapsed = _ctrl.value < 0.02;
    final bgAlpha = isCollapsed ? 184 : 224; // 0.72 vs 0.88
    final borderAlpha = isCollapsed ? 56 : 71; // 0.22 vs 0.28
    return GestureDetector(
      // Collapsed: the whole panel is the tap target to expand. Once
      // expanded the outside-scrim + close chevron handle dismiss, so
      // no tap handler here (preserves R26 S1v3-EE8.2 exclusivity —
      // taps never reach the walk handler beneath).
      behavior: HitTestBehavior.opaque,
      onTap: isCollapsed ? _toggle : null,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: _widthAnim.value,
            padding: EdgeInsets.symmetric(
              vertical: isCollapsed ? 4 : 14,
              horizontal: isCollapsed ? 4 : 14,
            ),
            decoration: BoxDecoration(
              color: Color.fromARGB(bgAlpha, 10, 14, 24),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border(
                top: BorderSide(
                    color: AppColors.gold.withAlpha(borderAlpha), width: 0.5),
                right: BorderSide(
                    color: AppColors.gold.withAlpha(borderAlpha), width: 0.5),
                bottom: BorderSide(
                    color: AppColors.gold.withAlpha(borderAlpha), width: 0.5),
              ),
            ),
            child: isCollapsed
                ? _buildInfoCircle()
                : FadeTransition(
                    opacity: _contentOpacity,
                    child: _buildExpandedContent(),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCircle() {
    return Container(
      width: _circleSize,
      height: _circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.gold.withAlpha(20),
        border: Border.all(
            color: AppColors.gold.withAlpha(150), width: 1.2),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.info_outline_rounded,
          size: _glyphSize, color: AppColors.gold),
    );
  }

  /// R25-S3-HF-2: vertical-stack layout.
  /// Section 1: "Your Light" title + "across all events" subtitle + 18px value.
  /// Section 2: "This Event" title + "X of 4 moments" subtitle + 4 dots.
  Widget _buildExpandedContent() {
    // R25-S3-HF-9: explicit Directionality guarantees AR layout semantics
    // (CrossAxisAlignment.start = right, Row child order mirrored)
    // even if the ambient directionality doesn't propagate cleanly
    // through the Positioned/AnimatedBuilder/Stack wrapping chain.
    return Directionality(
      textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Padding(
        // Inner right pad so content never slides under the close
        // chevron straddling the right border.
        padding: const EdgeInsets.only(right: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Section 1: Your Light (lifetime) ──────────────────
            Text(
              _isAr ? 'نورك' : 'Your Light',
              textDirection:
                  _isAr ? TextDirection.rtl : TextDirection.ltr,
              style: GoogleFonts.nunito(
                color: AppColors.gold.withAlpha(217), // 0.85
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              _isAr ? 'عبر كل الأحداث' : 'across all events',
              textDirection:
                  _isAr ? TextDirection.rtl : TextDirection.ltr,
              style: GoogleFonts.nunito(
                color: AppColors.gold.withAlpha(128), // 0.50
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${PrefsService.noorLevel}%',
              style: GoogleFonts.nunito(
                color: const Color(0xFFE8D8B8),
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            // Divider
            Container(
              height: 0.5,
              color: AppColors.gold.withAlpha(46),
            ),
            const SizedBox(height: 12),
            // ── Section 2: This Event (4-dot progress) ────────────
            Text(
              _isAr ? 'هذا الحدث' : 'This Event',
              textDirection:
                  _isAr ? TextDirection.rtl : TextDirection.ltr,
              style: GoogleFonts.nunito(
                color: AppColors.gold.withAlpha(217),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              _isAr
                  ? '${_toArabicNumeral(widget.discoveredHotspots)} من '
                      '${_toArabicNumeral(widget.totalHotspots)} لحظات'
                  : '${widget.discoveredHotspots} of '
                      '${widget.totalHotspots} moments',
              textDirection:
                  _isAr ? TextDirection.rtl : TextDirection.ltr,
              style: GoogleFonts.nunito(
                color: AppColors.gold.withAlpha(128),
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              textDirection:
                  _isAr ? TextDirection.rtl : TextDirection.ltr,
              children: _buildEventDots(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEventDots() {
    return List<Widget>.generate(widget.totalHotspots, (i) {
      final filled = i < widget.discoveredHotspots;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? AppColors.gold : Colors.transparent,
            border: Border.all(
              color: filled
                  ? AppColors.gold
                  : AppColors.gold.withAlpha(102), // 0.4
              width: filled ? 0 : 0.5,
            ),
          ),
        ),
      );
    });
  }

  static String _toArabicNumeral(int n) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((d) => digits[int.parse(d)]).join();
  }
}
