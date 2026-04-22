import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../services/prefs_service.dart';

/// R27 S1.1-TENT1: tent-side info tab widget. Mirrors the event scene
/// info tab (`lib/widgets/event_scene_info_tab.dart`) in look and
/// behavior — chevron-on-border collapse toggle, left-edge panel,
/// ~40-60 px below the default anchor so it clears the Rawi figure's
/// head on the tent scene.
///
/// Differs only in content: Section 2 shows JOURNEY progress
/// (`X of 155 events completed`) instead of per-event hotspot dots,
/// because the tent is where the user lives between events and
/// there's no "this event" context until one is launched.
class TentInfoTab extends StatefulWidget {
  /// Count of events the user has completed (same source the tent's
  /// progress card already uses — `_completedCount`).
  final int completedEvents;

  /// Total events in the journey (155 at time of writing, passed in
  /// so the widget doesn't reach into m1_data directly).
  final int totalEvents;

  const TentInfoTab({
    super.key,
    required this.completedEvents,
    required this.totalEvents,
  });

  @override
  State<TentInfoTab> createState() => _TentInfoTabState();
}

class _TentInfoTabState extends State<TentInfoTab>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _widthAnim;
  late final Animation<double> _contentOpacity;

  static const double _collapsedWidth = 32;
  static const double _expandedWidth = 180;

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
    // Must be wrapped in `Positioned.fill` by the tent so the scrim
    // we paint when expanded covers the full scene (mirrors the fix
    // from R26 S1v3-EE8.2 on the event scene tab).
    final screenH = MediaQuery.of(context).size.height;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (_expanded)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggle,
              // Pan no-ops so a drag-outside doesn't leak to anything
              // behind. The tent's CTAs below will still receive taps
              // while the scrim is DOWN (not expanded).
              onPanDown: (_) {},
              onPanUpdate: (_) {},
              onPanEnd: (_) {},
              child: Container(color: Colors.black.withAlpha(77)), // 0.30
            ),
          ),
        // Tab + chevron circle. ~45% of screen height keeps the
        // collapsed handle below the Rawi figure's head.
        Positioned(
          top: screenH * 0.45,
          left: 0,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) => Stack(
              clipBehavior: Clip.none,
              children: [
                _buildTab(),
                Positioned(
                  right: -12,
                  top: 0,
                  bottom: 0,
                  // R27 S1.1-TENT2: 44×44 hit target via invisible
                  // padding in the GestureDetector — visual circle
                  // stays 24 px. `HitTestBehavior.opaque` absorbs the
                  // tap so it never bubbles to any tent CTAs beneath.
                  child: Center(child: _buildChevronCircle()),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTab() {
    final bgAlpha = _expanded ? 224 : 184; // 0.88 vs 0.72
    final borderAlpha = _expanded ? 71 : 56; // 0.28 vs 0.22
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: _widthAnim.value,
          padding: EdgeInsets.symmetric(
            vertical: _expanded ? 14 : 9,
            horizontal: _expanded ? 14 : 9,
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
          child: _ctrl.value < 0.02
              ? _buildCollapsedContent()
              : FadeTransition(
                  opacity: _contentOpacity,
                  child: _buildExpandedContent(),
                ),
        ),
      ),
    );
  }

  /// Matches event scene info tab: just the info glyph. The collapse
  /// chevron moved out to [_buildChevronCircle].
  Widget _buildCollapsedContent() {
    return SizedBox(
      width: _collapsedWidth - 18,
      child: Icon(Icons.info_outline_rounded,
          size: 14, color: AppColors.gold),
    );
  }

  Widget _buildExpandedContent() {
    return Directionality(
      textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Section 1: YOUR LIGHT (lifetime) ───────────────────
            Text(
              _isAr ? 'نورك' : 'Your Light',
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
              _isAr ? 'عبر كل الأحداث' : 'across all events',
              textDirection:
                  _isAr ? TextDirection.rtl : TextDirection.ltr,
              style: GoogleFonts.nunito(
                color: AppColors.gold.withAlpha(128),
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
            Container(height: 0.5, color: AppColors.gold.withAlpha(46)),
            const SizedBox(height: 12),
            // ── Section 2: JOURNEY (events completed / 155) ────────
            Text(
              _isAr ? 'الرحلة' : 'Journey',
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
                  ? '${_toArabicNumeral(widget.completedEvents)} من '
                      '${_toArabicNumeral(widget.totalEvents)} حدثاً'
                  : '${widget.completedEvents} of '
                      '${widget.totalEvents} events',
              textDirection:
                  _isAr ? TextDirection.rtl : TextDirection.ltr,
              style: GoogleFonts.nunito(
                color: AppColors.gold.withAlpha(128),
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 6),
            // Slim progress bar, visually balanced with the 4-dot row
            // used in the event scene tab.
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: widget.totalEvents == 0
                    ? 0.0
                    : (widget.completedEvents / widget.totalEvents)
                        .clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor: AppColors.gold.withAlpha(40),
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.gold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// R27 S1.1-TENT2: 44×44 hit target with a 24 px visual chevron
  /// circle centered inside. Invisible padding carries the taps;
  /// `HitTestBehavior.opaque` absorbs them so they never reach any
  /// tent CTA beneath this widget.
  Widget _buildChevronCircle() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggle,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0A0E18).withValues(alpha: 0.92),
            border: Border.all(
                color: AppColors.gold.withAlpha(140), width: 0.8),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(100),
                  blurRadius: 4,
                  offset: const Offset(0, 1)),
            ],
          ),
          child: Icon(
            _expanded
                ? Icons.chevron_left_rounded
                : Icons.chevron_right_rounded,
            size: 16,
            color: AppColors.gold,
          ),
        ),
      ),
    );
  }

  static String _toArabicNumeral(int n) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((d) => digits[int.parse(d)]).join();
  }
}
