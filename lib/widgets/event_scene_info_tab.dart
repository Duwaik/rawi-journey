import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../services/prefs_service.dart';
import 'stat_row_group.dart';

/// R25-S3-6: Expandable info tab on the left edge of the event scene.
///
/// Replaces the old _NoorHud (deleted in S3-1). Collapsed shows a neutral
/// info glyph + chevron hint. Expanded slides out to ~180px wide and
/// reveals two sections:
///   Section 1 — YOUR LIGHT (lifetime, same source as tent)
///   Section 2 — THIS EVENT (4-dot hotspot-completion progress)
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
    // When expanded we render an additional full-screen scrim that dims
    // the scene behind and absorbs taps to collapse. The tab itself is
    // always on the left edge at ~40% vertical.
    return Stack(
      children: [
        if (_expanded)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggle,
              child: Container(color: Colors.black.withAlpha(77)), // 0.30
            ),
          ),
        AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) => _buildTab(),
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

  /// Collapsed content: neutral info glyph + tiny rightward chevron.
  /// Uses a GestureDetector here instead of InkWell — the spec says no
  /// ripple on this tab; tapping reveals, chevron collapses.
  Widget _buildCollapsedContent() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggle,
      child: SizedBox(
        width: _collapsedWidth - 18, // internal area (minus padding)
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline_rounded,
                size: 14, color: AppColors.gold),
            const SizedBox(height: 2),
            Icon(Icons.chevron_right_rounded,
                size: 12, color: AppColors.gold.withAlpha(160)),
          ],
        ),
      ),
    );
  }

  /// Expanded content: YOUR LIGHT (lifetime) section + THIS EVENT
  /// (4-dot progress) section, separated by a faint divider.
  Widget _buildExpandedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header row: collapse chevron pinned to the end
        Row(
          textDirection:
              _isAr ? TextDirection.rtl : TextDirection.ltr,
          children: [
            const Spacer(),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggle,
              child: Icon(Icons.chevron_left_rounded,
                  size: 18, color: AppColors.gold.withAlpha(200)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Section 1 — YOUR LIGHT (lifetime), rendered via the shared
        // StatRowGroup so this surface and the tent use the same widget
        // (spec §S3-8 acceptance criterion).
        _sectionLabel(_isAr ? 'نورك' : 'YOUR LIGHT'),
        const SizedBox(height: 6),
        StatRowGroup(
          showDividers: false,
          rows: [
            StatRow(
              icon: Icons.auto_awesome_rounded,
              label: 'Your Light',
              labelAr: 'نورك',
              value: '${PrefsService.noorLevel}%',
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          _isAr ? 'عبر كل الأحداث' : 'across all events',
          textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
          style: GoogleFonts.nunito(
            color: AppColors.gold.withAlpha(102), // 0.40
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 12),
        // Divider
        Container(
          height: 0.5,
          color: AppColors.gold.withAlpha(46),
        ),
        const SizedBox(height: 12),
        // Section 2 — THIS EVENT (4-dot progress)
        _sectionLabel(_isAr ? 'هذا الحدث' : 'THIS EVENT'),
        const SizedBox(height: 6),
        Row(
          textDirection:
              _isAr ? TextDirection.rtl : TextDirection.ltr,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded,
                size: 14, color: AppColors.gold),
            const SizedBox(width: 6),
            ..._buildEventDots(),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _isAr
              ? '${_toArabicNumeral(widget.discoveredHotspots)} من '
                  '${_toArabicNumeral(widget.totalHotspots)} لحظات'
              : '${widget.discoveredHotspots} of '
                  '${widget.totalHotspots} moments',
          textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
          style: GoogleFonts.nunito(
            color: AppColors.gold.withAlpha(140), // 0.55
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
        style: GoogleFonts.nunito(
          color: AppColors.gold.withAlpha(191), // 0.75
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      );

  List<Widget> _buildEventDots() {
    return List<Widget>.generate(widget.totalHotspots, (i) {
      final filled = i < widget.discoveredHotspots;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? AppColors.gold : Colors.transparent,
            border: Border.all(
              color: filled
                  ? AppColors.gold
                  : AppColors.gold.withAlpha(80),
              width: 1,
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
