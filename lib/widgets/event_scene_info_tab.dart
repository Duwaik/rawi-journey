import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../services/prefs_service.dart';

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

  /// R25-S3-HF-2: vertical-stack redesign per hotfix spec.
  /// Section 1: "Your Light" title + "across all events" subtitle + 18px value.
  /// Section 2: "This Event" title + "X of 4 moments" subtitle + 4 dots.
  /// No more uppercase section headers, no duplicated "Your Light" label.
  /// Collapse chevron sits on the right border at mid-height (Stack).
  Widget _buildExpandedContent() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Content column
        Padding(
          padding: const EdgeInsets.only(right: 14), // clear the chevron
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
        // Collapse chevron on the right border at mid-height
        Positioned(
          right: -4,
          top: 0,
          bottom: 0,
          child: Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggle,
              child: Icon(Icons.chevron_left_rounded,
                  size: 20, color: AppColors.gold.withAlpha(200)),
            ),
          ),
        ),
      ],
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
