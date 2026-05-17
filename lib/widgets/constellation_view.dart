import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/journey_event.dart';
import '../services/prefs_service.dart';
import 'spine_painter.dart';

/// R28-S4-SPINE-P1 — Stars view, alternating-spine continuous scroll.
///
/// Supersedes the HF6 InteractiveViewer + Mockup-B cluster rendering
/// (preserved in git history @ 3517fb5 and the `r28-s4-p1-archive`
/// tag) and the local-only year-paged R28-S4-P1 (hard-reset away).
/// The year-paged design failed A56 visual verify — sparse years
/// (1–3 events) left ~80% of each page empty and the mini-
/// constellation metaphor collapsed.
///
/// Spine design: ONE vertical continuous SingleChildScrollView, a
/// central gold spine line, events alternating L/R of the spine,
/// year markers ON the spine (Option 2 — interrupting the spine).
/// This kills empty-year syndrome (continuous flow, no page
/// boundaries) and density-clash (alternating L/R doubles usable
/// width for the Medina 624–632 CE block).
///
/// DIRECTION — bottom-to-top: the seerah climbs upward. Oldest
/// event (570 CE, Year of the Elephant) at the BOTTOM of the scroll
/// content; newest (632 CE) at the TOP. Implemented purely as a
/// children-order reversal in the Column — the SingleChildScrollView
/// itself is NOT `reverse: true`, so offset 0 == top of content and
/// the S4S-05 persistence math stays natural.
///
/// Class name + constructor are unchanged from HF6 so the host
/// (`event_list_screen.dart`, STARS branch) needs zero edits:
///   • [events]         — full journey list, globalOrder-ascending
///   • [completedCount] — index `completedCount` is the current /
///                        active event (HF6 "current star" convention)
///   • [onLaunch]       — host's existing `_openEvent` (Navigation
///                        Contract preserved)
///
/// Phase 1 (S4S-01..06): structure, spine, nodes, year markers,
/// scroll-to-current + persistence, tap routing. Phase 2 (S4S-07/08):
/// AR locale parity + first-entry tutorial.
class ConstellationView extends StatefulWidget {
  final List<JourneyEvent> events;
  final int completedCount;
  final void Function(JourneyEvent event) onLaunch;

  const ConstellationView({
    super.key,
    required this.events,
    required this.completedCount,
    required this.onLaunch,
  });

  @override
  State<ConstellationView> createState() => _ConstellationViewState();
}

class _ConstellationViewState extends State<ConstellationView> {
  // ── Layout constants (tunable; spec S4S-03/04) ──────────────────
  /// Vertical distance between consecutive event dots.
  static const double _eventSpacing = 70.0;

  /// Total vertical footprint of a year marker (box + small margin).
  /// This is the gap SpinePainter (S4S-02) skips.
  static const double _yearMarkerHeight = 30.0;

  /// Top + bottom breathing room on the scroll content.
  static const double _endPadding = 40.0;

  late final ScrollController _scrollCtrl;

  bool get _isAr => PrefsService.isAr;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
    // S4S-05 (scroll-to-current + persistence) wires a post-frame
    // jump here. S4S-01 just establishes the scroll architecture.
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  /// Builds the reverse-chronological child list (newest at top of
  /// the Column → oldest at the bottom) and, in lock-step, records
  /// each year marker's Y top so S4S-02's SpinePainter can gap there.
  ///
  /// Per spec S4S-04 placement rule: the year marker for year Y is
  /// inserted IMMEDIATELY AFTER (i.e. below, since the column renders
  /// top=newest) the chronologically-first event of year Y — so the
  /// marker sits at the LOWEST visual position of its year, the clean
  /// boundary between Y and the older year beneath it.
  ({List<Widget> children, List<double> gapTops, double totalHeight})
      _buildLayout() {
    final events = widget.events;
    final children = <Widget>[];
    final gapTops = <double>[];
    double y = _endPadding;

    for (int i = events.length - 1; i >= 0; i--) {
      children.add(SizedBox(
        height: _eventSpacing,
        child: _PlaceholderEventRow(
          // S4S-01 placeholder; S4S-03 swaps in the real EventNode.
          event: events[i],
          chronoIndex: i,
          isAr: _isAr,
        ),
      ));
      y += _eventSpacing;

      final isChronoFirstOfYear =
          i == 0 || events[i - 1].year != events[i].year;
      if (isChronoFirstOfYear) {
        gapTops.add(y);
        children.add(SizedBox(
          height: _yearMarkerHeight,
          child: _PlaceholderYearRow(
            // S4S-01 placeholder; S4S-04 swaps in the real YearMarker.
            year: events[i].year,
            isAr: _isAr,
          ),
        ));
        y += _yearMarkerHeight;
      }
    }

    return (
      children: children,
      gapTops: gapTops,
      totalHeight: y + _endPadding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final layout = _buildLayout();

    return ColoredBox(
      color: const Color(0xFF060810),
      // R28-HF6-02 preserved structurally: SafeArea(top:false) keeps
      // the timeline content above the Android system nav bar. The
      // Events List header + LIST/STARS toggle already own the
      // status-bar inset, so top:false avoids double-insetting.
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          controller: _scrollCtrl,
          // NOT reverse:true — bottom-to-top is the children order.
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            // Explicit height = sum of child heights + end padding,
            // so the Positioned.fill SpinePainter (S4S-02) spans the
            // exact content height.
            height: layout.totalHeight,
            child: Stack(
              children: [
                // S4S-02: spine BEHIND the events (z-order — the
                // full-opacity event dots will paint on top in S4S-03).
                // Positioned.fill takes the Stack's size, which the
                // SizedBox pins to the exact content height, so painter
                // Y == layout Y and the gapTops align 1:1 with the
                // year-marker boxes.
                Positioned.fill(
                  child: CustomPaint(
                    painter: SpinePainter(
                      gapTops: layout.gapTops,
                      gapHeight: _yearMarkerHeight,
                    ),
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: _endPadding),
                    ...layout.children,
                    const SizedBox(height: _endPadding),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// S4S-01 placeholder. Replaced by the real `EventNode` (alternating
/// L/R dot + branch + label + state visuals + tap) in S4S-03.
class _PlaceholderEventRow extends StatelessWidget {
  final JourneyEvent event;
  final int chronoIndex;
  final bool isAr;

  const _PlaceholderEventRow({
    required this.event,
    required this.chronoIndex,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final right = chronoIndex % 2 == 0;
    return Align(
      alignment: right ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          isAr ? event.titleAr : event.title,
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          style: GoogleFonts.nunito(
            color: const Color(0xFFF4E9D5).withAlpha(180),
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}

/// S4S-01 placeholder. Replaced by the real boxed `YearMarker`
/// (on-spine, Option 2) in S4S-04.
class _PlaceholderYearRow extends StatelessWidget {
  final int year;
  final bool isAr;

  const _PlaceholderYearRow({required this.year, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$year CE',
        style: GoogleFonts.nunito(
          color: const Color(0xFFD4A017),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
