import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../services/prefs_service.dart';

/// R27 S1.1-TENT1 + S1.2-TENT1: tent-side info tab. Shell-only widget
/// — collapse animation, chevron-on-border ornament, left-edge panel
/// at `screenH * 0.45`, full-screen scrim when expanded with
/// tap-to-dismiss + pan-swallow (R26 S1v3-EE8.2 pattern). The
/// EXPANDED content is supplied by the caller via [expandedContent].
///
/// S1.2 consolidation: the tent used to render a SEPARATE always-on
/// Light/XP/Dhikr stat-pills block at top-left (`_buildStatPillsContainer`).
/// That block is gone — those three pills now live INSIDE this info
/// tab's expanded content instead. One widget, one tap, one source
/// of truth for tent stats.
class TentInfoTab extends StatefulWidget {
  /// The content rendered inside the expanded panel. Caller builds a
  /// StatRowGroup (or whatever) and passes it in — no coupling to
  /// specific row shapes.
  final Widget expandedContent;

  const TentInfoTab({
    super.key,
    required this.expandedContent,
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

  // R27 S1.5-INFO1: panel widened 62 → 90 to fit the enlarged info
  // circle (52 px) AND the chevron (42 px, straddling right border)
  // without visual overlap. Info circle spans [9, 61] inside the
  // panel (9 padding + 52 diameter); chevron visual spans [69, 111]
  // centered on the 90 px border. 8 px gap between them — clear
  // breathing room, chevron clearly "secondary", info clearly
  // "primary". Expanded width unchanged.
  static const double _collapsedWidth = 90;
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
                  // R27 S1.3-TENT1: shifted -12 → -44 so the 88 px hit
                  // container's CENTER lines up with the panel's right
                  // border. The 42 px visual circle inside is then
                  // centered on the border too — 21 px inside panel,
                  // 21 px outside on scene/tent BG. S1.2 used -12
                  // which put the entire circle inside the panel and
                  // made the handle look floating, not straddling.
                  right: -44,
                  top: 0,
                  bottom: 0,
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

  /// R27 S1.5-INFO1: info circle bumped 44 → 52 (10 px larger than
  /// the 42 px chevron per spec's "info dominates" rule). Glyph
  /// scales 28 → 32 to stay proportional. Panel widened to 90 px
  /// (see `_collapsedWidth`) so the two circles sit side-by-side
  /// with an 8 px gap, no overlap. `Align(Alignment.centerLeft)` so
  /// the info circle hugs the panel's left edge rather than centering
  /// in the wider panel — keeps the chevron space clear on the right.
  Widget _buildCollapsedContent() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.gold.withAlpha(20),
          border: Border.all(
              color: AppColors.gold.withAlpha(150), width: 1.2),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.info_outline_rounded,
            size: 32, color: AppColors.gold),
      ),
    );
  }

  /// R27 S1.2-TENT1: the expanded panel now just renders whatever the
  /// caller passed in via `widget.expandedContent`. The tent supplies
  /// a StatRowGroup with Light / XP / Dhikr rows — the old YOUR LIGHT
  /// + JOURNEY content is gone, replaced by the pills that used to
  /// live in the deleted standalone top-left block.
  Widget _buildExpandedContent() {
    return Directionality(
      textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: widget.expandedContent,
      ),
    );
  }

  /// R27 S1.3-TENT1: visual chevron enlarged 24 → 42 px so the handle
  /// reads at a glance (S1.2 kept it tiny at 24). Hit target stays
  /// 88 × 88 via the transparent outer Container. Circle is positioned
  /// at `right: -12` on the panel's Stack and Positioned top:0 bottom:0
  /// with Center — at 42 px diameter it straddles the border 21 px
  /// in / 21 px out. Chevron glyph scales 16 → 26 to stay proportional.
  /// `HitTestBehavior.opaque` preserved from S1.2 (EE8.2 gesture pattern).
  Widget _buildChevronCircle() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggle,
      child: Container(
        width: 88,
        height: 88,
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Container(
          width: 42,
          height: 42,
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
            _expanded
                ? Icons.chevron_left_rounded
                : Icons.chevron_right_rounded,
            size: 26,
            color: AppColors.gold,
          ),
        ),
      ),
    );
  }

}
