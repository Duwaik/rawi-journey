import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../services/prefs_service.dart';
import 'tutorial_keys.dart';

/// R27 S3-INFO1: tent-side info tab redesigned.
/// - Collapsed: only the 42 px (ⓘ) circle. No chevron ornament.
///   Tapping the panel (ⓘ) expands.
/// - Expanded: full panel + a `<` close chevron on the right edge.
///   Tapping the chevron — or outside the panel — collapses.
/// - Sizes: circle 52 → 42 (–20 %), glyph 32 → 26 (proportional).
///   Supersedes the S1.5 baseline.
/// - Vertical position: panel top aligns the 42 px circle's vertical
///   center with the bottom-most right-side nav icon (Collections) on
///   the tent, so the expanded panel no longer overlaps Rawi's figure.
/// - Outside-tap dismiss + pan swallow (R26 S1v3-EE8.2) preserved.
///
/// Shell-only widget. The EXPANDED content is supplied by the caller
/// via [expandedContent] (tent passes a StatRowGroup with Light / XP /
/// Dhikr rows).
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

  // R27 S3-INFO1: collapsed width shrunk from 90 to 50 — just enough
  // to hold the 42 px info circle with a 4 px side pad. The S1.5
  // always-visible chevron ornament is gone, so the wider panel it
  // required goes with it. Expanded width unchanged.
  static const double _collapsedWidth = 50;
  static const double _expandedWidth = 180;

  // R27 S3-INFO1: info circle 52 → 42 (–20 %). Glyph 32 → 26
  // (proportional, keeps the visual weight). The expanded-state close
  // chevron reuses the same circle + glyph size for visual parity.
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
    // Must be wrapped in `Positioned.fill` by the tent so the scrim
    // we paint when expanded covers the full scene (mirrors the fix
    // from R26 S1v3-EE8.2 on the event scene tab).
    final screenH = MediaQuery.of(context).size.height;

    // R27 S3-INFO1: vertically center the 42 px circle on the tent's
    // bottom-most right-side icon (Collections). Right-side nav stack
    // starts at 0.28 × H with five 44 px icons and four 8 px gaps, so
    // the bottom icon's vertical center is (0.28 × H) + 4 × (44 + 8) + 22
    // = (0.28 × H) + 230. Inside the collapsed panel the circle sits
    // with 4 px top pad and is 42 px tall, so its center is
    // (panelTop) + 4 + 21 = (panelTop) + 25. Solve for panelTop:
    //   panelTop = (0.28 × H + 230) - 25 = (0.28 × H) + 205.
    // Formula — not a fixed fraction — so it stays correct at every
    // screen height. Clamped to at least 0.45 × H (the S1.5 position)
    // so on unusually tall screens the tab never climbs ABOVE the
    // historical position.
    final alignedTop = screenH * 0.28 + 205;
    final topY = alignedTop < screenH * 0.45 ? screenH * 0.45 : alignedTop;

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
        Positioned(
          top: topY,
          left: 0,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) => Stack(
              clipBehavior: Clip.none,
              children: [
                _buildTab(),
                // R27 S3-INFO1: close chevron is expanded-only. Hidden
                // at rest (collapsed → only the ⓘ is visible). Rendered
                // straight after the tab starts opening so it tracks
                // the panel's right border as it widens.
                if (_ctrl.value > 0.02)
                  Positioned(
                    // Matches S1.5 chevron offset: the 88 px hit
                    // container's center sits on the panel's right
                    // border so the 42 px visual circle straddles
                    // 21 in / 21 out.
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

  Widget _buildTab() {
    final isCollapsed = _ctrl.value < 0.02;
    final bgAlpha = isCollapsed ? 184 : 224; // 0.72 vs 0.88
    final borderAlpha = isCollapsed ? 56 : 71; // 0.22 vs 0.28
    return GestureDetector(
      // Collapsed: the whole panel is the tap target to expand. Once
      // expanded, the outside-scrim handles dismiss and the close
      // chevron handles explicit collapse — so no tap handler here.
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
      // R28 HF3-TUT1: GlobalKey for the tent's first-launch tutorial
      // step that points at the info-tab circle. Tutorial uses live
      // RenderBox + localToGlobal; the key sits on the 42 px circle
      // directly so the spotlight lands centered on the (i) glyph.
      key: TutorialKeys.tentInfoTab,
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

  Widget _buildExpandedContent() {
    return Directionality(
      textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Padding(
        // Inner right pad so the content never slides under the close
        // chevron that straddles the right border.
        padding: const EdgeInsets.only(right: 14),
        child: widget.expandedContent,
      ),
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
            // `>` in AR. Glyph is chosen explicitly rather than relying
            // on ambient Directionality auto-mirror (which isn't
            // consistent across Material icon variants). `textDirection:
            // ltr` forces the picked glyph to render as-is regardless
            // of the RTL wrapper around the app root.
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
}
