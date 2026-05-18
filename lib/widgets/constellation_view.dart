import 'package:flutter/material.dart';

import '../models/journey_event.dart';
import '../services/prefs_service.dart';
import 'event_node.dart';
import 'spine_painter.dart';
import 'year_marker.dart';

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

  /// One-shot guard: the initial restore/centre jump runs exactly
  /// once per entry, on the first post-frame. It is flipped true
  /// AFTER the jump so the scroll-end save listener ignores the
  /// programmatic jump's own ScrollEndNotification (jumpTo dispatches
  /// it synchronously, before this becomes true).
  bool _didInitialScroll = false;

  /// Cached from the last build so the post-frame entry callback can
  /// read content-space event Y-centres without rebuilding the layout.
  Map<int, double> _eventCenterY = const {};
  double _totalHeight = 0;

  bool get _isAr => PrefsService.isAr;

  /// Spec S4S-05 "current event": index `completedCount` is the
  /// active event. The clamp folds in the two boundary cases — none
  /// started (→ first event, idx 0) and all completed (→ last event).
  int get _currentEventIndex => widget.events.isEmpty
      ? 0
      : widget.completedCount.clamp(0, widget.events.length - 1);

  /// Progression state from the host's `completedCount` convention
  /// (the codebase's single progression source of truth). [i] is the
  /// chronological index (position in the globalOrder-ascending list).
  EventNodeState _stateFor(int i) {
    if (i < widget.completedCount) return EventNodeState.completed;
    if (i == widget.completedCount) return EventNodeState.active;
    return EventNodeState.locked;
  }

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
  ({
    List<Widget> children,
    List<double> gapTops,
    Map<int, double> eventCenterY,
    double totalHeight,
  })
  _buildLayout() {
    final events = widget.events;
    final children = <Widget>[];
    final gapTops = <double>[];
    // chronoIndex → content-space Y of that event's dot centre, fed
    // to S4S-05's entry-centring. Direction-agnostic: the value is
    // just the row's middle; bottom-to-top only means earlier events
    // get a numerically larger Y (they're appended later, lower down).
    final eventCenterY = <int, double>{};
    double y = _endPadding;

    for (int i = events.length - 1; i >= 0; i--) {
      eventCenterY[i] = y + _eventSpacing / 2;
      final state = _stateFor(i);
      children.add(
        SizedBox(
          height: _eventSpacing,
          child: EventNode(
            event: events[i],
            chronoIndex: i,
            state: state,
            isAr: _isAr,
            // S4S-06 routing — lifted verbatim from HF6 _handleStarTap
            // (completed | current → onLaunch; locked → no-op). Locked
            // passes null so EventNode's opaque GestureDetector is a
            // true no-op (no navigation, no feedback) — matching HF6,
            // which only ever launched completed/current stars. The
            // ≥44px hit target itself was established in S4S-03.
            onTap: state == EventNodeState.locked
                ? null
                : () => widget.onLaunch(events[i]),
          ),
        ),
      );
      y += _eventSpacing;

      final isChronoFirstOfYear =
          i == 0 || events[i - 1].year != events[i].year;
      if (isChronoFirstOfYear) {
        gapTops.add(y);
        children.add(
          SizedBox(
            height: _yearMarkerHeight,
            child: YearMarker(year: events[i].year),
          ),
        );
        y += _yearMarkerHeight;
      }
    }

    return (
      children: children,
      gapTops: gapTops,
      eventCenterY: eventCenterY,
      totalHeight: y + _endPadding,
    );
  }

  /// S4S-05 entry positioning. Runs once per entry in a post-frame
  /// callback (scroll metrics are only valid after first layout).
  ///
  /// Restore vs. re-centre:
  ///   • Valid save (offset present AND no event completed since it
  ///     was saved) → jump to the saved resting offset.
  ///   • Otherwise → centre the current event in the viewport. If a
  ///     newly-completed event invalidated a prior save, drop it so a
  ///     later same-count visit can't restore a stale offset.
  ///
  /// `jumpTo` (instant, no animation) per spec — the view appears
  /// already positioned, no entry flicker. Clamped to the valid
  /// scroll range.
  void _positionOnEntry() {
    if (!_scrollCtrl.hasClients) return;
    final pos = _scrollCtrl.position;
    final double maxExtent = pos.maxScrollExtent;
    final double viewport = pos.viewportDimension;

    final int savedCount = PrefsService.lastConstellationSavedAtCompletionCount;
    final double savedOffset = PrefsService.lastConstellationScrollOffset;
    final int live = widget.completedCount;

    final bool hasValidSave =
        savedCount >= 0 && savedOffset >= 0 && savedCount >= live;

    double target;
    if (hasValidSave) {
      target = savedOffset;
    } else {
      // Bottom-to-top doesn't change the centring math — put the
      // event's content-Y at the viewport middle either way.
      final double centerY =
          _eventCenterY[_currentEventIndex] ?? (_totalHeight / 2);
      target = centerY - viewport / 2;
      if (savedCount >= 0 && live > savedCount) {
        PrefsService.clearLastConstellationScroll();
      }
    }
    _scrollCtrl.jumpTo(target.clamp(0.0, maxExtent));
  }

  @override
  void didUpdateWidget(covariant ConstellationView old) {
    super.didUpdateWidget(old);
    // Host pushed a new completedCount while we stayed mounted (e.g.
    // returned after finishing an event): the saved offset is stale —
    // drop it and re-run entry positioning on the next frame so we
    // re-centre on the new current event.
    if (old.completedCount != widget.completedCount) {
      PrefsService.clearLastConstellationScroll();
      _didInitialScroll = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final layout = _buildLayout();
    // Cache for the post-frame entry callback (avoids rebuilding the
    // layout off-frame). Geometry depends only on the events list +
    // constants, so this is stable across completedCount changes.
    _eventCenterY = layout.eventCenterY;
    _totalHeight = layout.totalHeight;

    if (!_didInitialScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _positionOnEntry();
        // AFTER the jump: jumpTo dispatches its ScrollEndNotification
        // synchronously; flipping the guard here means that one is
        // ignored by the save listener (only genuine user scrolls
        // persist).
        _didInitialScroll = true;
      });
    }

    return ColoredBox(
      color: const Color(0xFF060810),
      // R28-HF6-02 preserved structurally: SafeArea(top:false) keeps
      // the timeline content above the Android system nav bar. The
      // Events List header + LIST/STARS toggle already own the
      // status-bar inset, so top:false avoids double-insetting.
      child: SafeArea(
        top: false,
        child: NotificationListener<ScrollEndNotification>(
          // S4S-05 persistence. ScrollEndNotification fires once when
          // a scroll comes to rest — that IS "scroll-end", so it's a
          // direct, timer-free substitute for the spec's "debounced
          // listener" (same intent: persist the resting position).
          // Flagged as a reasoned deviation in the handoff.
          onNotification: (n) {
            if (_didInitialScroll && _scrollCtrl.hasClients) {
              // Fire-and-forget: resting offset + the completion count
              // it is valid against.
              PrefsService.setLastConstellationScroll(
                _scrollCtrl.offset,
                widget.completedCount,
              );
            }
            return false; // keep the notification bubbling
          },
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
      ),
    );
  }
}
