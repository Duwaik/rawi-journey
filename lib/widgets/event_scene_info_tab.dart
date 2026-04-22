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
    // R26 S1v3-EE8.2: the widget now expects to be wrapped in
    // `Positioned.fill` (see immersive_event_screen.dart call site).
    // Previously the parent passed only `top: 40%, left: 0` which gave
    // this Stack tiny intrinsic bounds, so the `Positioned.fill` scrim
    // only covered the tab's own footprint. Outside taps bled through
    // to the movement GestureDetector below and moved the figure.
    //
    // Now:
    //   - Stack fills the screen.
    //   - When expanded: a full-screen scrim absorbs tap AND pan so
    //     the movement layer never sees either. Tap collapses.
    //   - The tab itself is repositioned internally to 40% vertical
    //     on the left edge — preserving the previous visual layout.
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
        // so the collapsed handle no longer overlaps Rawi's figure
        // (the figure's head/hat sits roughly 0.40-0.45 when the user
        // first enters a scene — was clipping the chevron circle).
        //
        // Stack wraps the panel + the chevron-circle ornament. The
        // circle straddles the right border (half in, half out) via
        // Positioned(right: -12) + clipBehavior: Clip.none.
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
                  child: Center(child: _buildChevronCircle()),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// R27 S1-TENT6 / S1.1-TENT2 / S1.2-TENT3: the toggle chevron
  /// lives in a 24 px visual circle straddling the panel's right
  /// border, wrapped in an 88 × 88 invisible hit target so fast taps
  /// never fall through to the walk handler beneath. Doubled from 44
  /// in S1.1 after device verify showed the figure still sometimes
  /// moved on tab taps — more headroom is free because the hit area
  /// is invisible. `HitTestBehavior.opaque` keeps the tap in the
  /// arena here (same R26 S1v3-EE8.2 pattern).
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

  /// Collapsed content: just the neutral info glyph. The expand/collapse
  /// chevron moved out of here in R27 S1-TENT6 and now lives in a
  /// circle on the panel's right border (see [_buildChevronCircle]).
  /// The whole panel is still tappable — any tap on the collapsed
  /// handle toggles expansion via this GestureDetector.
  Widget _buildCollapsedContent() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggle,
      child: SizedBox(
        width: _collapsedWidth - 18, // internal area (minus padding)
        child: Icon(Icons.info_outline_rounded,
            size: 14, color: AppColors.gold),
      ),
    );
  }

  /// R25-S3-HF-2: vertical-stack redesign per hotfix spec.
  /// Section 1: "Your Light" title + "across all events" subtitle + 18px value.
  /// Section 2: "This Event" title + "X of 4 moments" subtitle + 4 dots.
  /// No more uppercase section headers, no duplicated "Your Light" label.
  /// Collapse chevron sits on the right border at mid-height (Stack).
  Widget _buildExpandedContent() {
    // R25-S3-HF-9: explicit Directionality guarantees AR layout semantics
    // (CrossAxisAlignment.start = right, Row child order mirrored)
    // even if the ambient directionality doesn't propagate cleanly
    // through the Positioned/AnimatedBuilder/Stack wrapping chain.
    return Directionality(
      textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Stack(
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
        // R27 S1-TENT6: the old in-body collapse chevron lived here.
        // Moved to the [_buildChevronCircle] ornament that straddles
        // the right border in both collapsed and expanded states.
      ],
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
