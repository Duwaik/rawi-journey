import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/journey_event.dart';

/// Progression state of a node, derived from the host's
/// `completedCount` convention (the codebase's single source of
/// progression truth):
///   • chronoIndex  <  completedCount → [completed]
///   • chronoIndex  == completedCount → [active] (the current event)
///   • chronoIndex  >  completedCount → [locked]
///
/// NOTE on the spec's 4-row state table (Locked / Available /
/// Completed / Active): HF6's model has no "available-but-not-current"
/// state — the current event *is* the available one (HF6
/// `_handleStarTap` only ever distinguished completed / current /
/// locked). So the spec's "Available" and "Active" rows collapse onto
/// [active] here. This is a faithful spec→model reconciliation, not a
/// behaviour change; flagged in the R28-S4-SPINE-P1 handoff.
enum EventNodeState { completed, active, locked }

/// R28-S4-SPINE-P1 — S4S-03. One event on the Stars spine: a dot ON
/// the central spine, a short branch L/R, and the title label at the
/// branch end. Alternation is keyed off the **chronological** index
/// (position in the globalOrder-ascending list), NOT the reversed
/// column position — so a given event keeps a fixed side regardless
/// of the bottom-to-top layout flip (spec S4S-03).
///
/// Host contract: rendered inside the host's `SizedBox(height:
/// _eventSpacing)` row, full width. The dot is kept on the exact
/// horizontal centre (= the spine X) by a symmetric
/// `Expanded | fixed-dot | Expanded` row, so it never drifts off the
/// spine no matter how long the label is.
///
/// [onTap] is supplied by the host in S4S-06 (HF6 routing lift):
/// non-null → opens the event; `null` → locked / no navigation. The
/// GestureDetector + ≥44px hit area is established here in S4S-03; the
/// callback itself is wired in S4S-06.
class EventNode extends StatelessWidget {
  final JourneyEvent event;
  final int chronoIndex;
  final EventNodeState state;
  final bool isAr;
  final VoidCallback? onTap;

  const EventNode({
    super.key,
    required this.event,
    required this.chronoIndex,
    required this.state,
    required this.isAr,
    this.onTap,
  });

  // ── Palette (spec S4S-03 / Design Reference) ────────────────────
  /// Spine gold-amber — same hue as [SpinePainter] so the dot reads
  /// as sitting ON the spine.
  static const Color _gold = Color(0xFFD4A017);

  /// Brighter gold for the current event — preserves HF6's
  /// "current star is brighter" visual language (#E8C854).
  static const Color _goldBright = Color(0xFFE8C854);

  /// Label cream.
  static const Color _cream = Color(0xFFF4E9D5);

  static const double _branchLen = 18.0; // spec: ~15–20px
  static const double _branchThickness = 1.3;
  static const int _branchAlpha = 140; // ~0.55 opacity
  static const double _labelGap = 6.0;
  static const double _labelFontSize = 12.5;

  /// Fixed centre slot. Wider than the largest dot (active = 12px) so
  /// the visible circle is `Center`-ed inside and its centre lands
  /// exactly on the spine X regardless of state.
  static const double _centerSlot = 16.0;

  bool get _right => chronoIndex % 2 == 0;

  double get _dotDiameter =>
      state == EventNodeState.active ? 12.0 : 10.0; // r=6 vs r=5

  Color get _dotColor {
    switch (state) {
      case EventNodeState.completed:
        return _gold;
      case EventNodeState.active:
        return _goldBright;
      case EventNodeState.locked:
        return _gold.withAlpha(102); // ~0.4 opacity
    }
  }

  TextStyle get _labelStyle {
    switch (state) {
      case EventNodeState.completed:
        return GoogleFonts.nunito(
          color: _cream.withAlpha(235),
          fontSize: _labelFontSize,
        );
      case EventNodeState.active:
        return GoogleFonts.nunito(
          color: Colors.white, // brighter / full white (spec)
          fontSize: _labelFontSize,
          fontWeight: FontWeight.w600,
        );
      case EventNodeState.locked:
        return GoogleFonts.nunito(
          color: _cream.withAlpha(128), // ~0.5 opacity
          fontSize: _labelFontSize,
        );
    }
  }

  Widget _buildDot() {
    return SizedBox(
      width: _centerSlot,
      height: _centerSlot,
      child: Center(
        child: Container(
          width: _dotDiameter,
          height: _dotDiameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _dotColor,
            // Completed keeps the HF6 ring accent (subtle, same hue).
            border: state == EventNodeState.completed
                ? Border.all(color: _gold.withAlpha(150), width: 0.5)
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildBranch() => Container(
        width: _branchLen,
        height: _branchThickness,
        color: _gold.withAlpha(_branchAlpha),
      );

  Widget _buildLabel() => Flexible(
        child: Text(
          isAr ? event.titleAr : event.title,
          // P1 keeps LTR geometry; AR RTL mirroring is S4S-07 (P2).
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          textAlign: _right ? TextAlign.left : TextAlign.right,
          style: _labelStyle,
        ),
      );

  @override
  Widget build(BuildContext context) {
    // Branch + label for the active side, packed tight against the
    // centre slot so the branch visually emanates from the dot.
    final List<Widget> sideChildren = _right
        ? [
            _buildBranch(),
            const SizedBox(width: _labelGap),
            _buildLabel(),
          ]
        : [
            _buildLabel(),
            const SizedBox(width: _labelGap),
            _buildBranch(),
          ];

    final sideContent = Align(
      alignment: _right ? Alignment.centerLeft : Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: sideChildren,
      ),
    );

    return GestureDetector(
      // Opaque so the whole 70px row (host SizedBox) is the hit area —
      // far exceeds the spec's ≥44px square minimum. Locked nodes pass
      // onTap == null (S4S-06) → tap is a true no-op.
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        // LTR geometry is intentional in P1 (see _buildLabel).
        textDirection: TextDirection.ltr,
        children: [
          Expanded(child: _right ? const SizedBox() : sideContent),
          _buildDot(),
          Expanded(child: _right ? sideContent : const SizedBox()),
        ],
      ),
    );
  }
}
