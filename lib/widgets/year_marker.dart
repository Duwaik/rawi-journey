import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// R28-S4-SPINE-P1 — S4S-04. The boxed year label that sits ON the
/// central spine (Design Reference → Option 2, "interrupting the
/// spine"). Non-interactive: it's a label, not a control, so it has
/// no gesture handler — a tap on it falls through to the scroll view
/// (spec acceptance: "tapping the year box does nothing").
///
/// Host contract: rendered inside the host's
/// `SizedBox(height: _yearMarkerHeight /* 30 */)` row. The 76×22 box
/// is centred in that 30px slot (~4px breathing margin top & bottom),
/// and that exact 30px Y range is the gap `SpinePainter` (S4S-02)
/// skips — so the box cleanly breaks the spine with no peek-through
/// (the opaque background-matching fill is a belt-and-braces guard
/// against any 1px gap/box misalignment).
///
/// P1 renders the EN form `"$year CE"` only. Localised AR formatting
/// (e.g. "٥٧٠ م") is S4S-07 (P2) — deliberately no `isAr` param here
/// to keep the P1 surface minimal; P2 adds locale handling.
class YearMarker extends StatelessWidget {
  final int year;

  const YearMarker({super.key, required this.year});

  /// Gold-amber — same hue as the spine ([SpinePainter]) and event
  /// dots ([EventNode]) so the marker reads as part of the spine.
  static const Color _gold = Color(0xFFD4A017);

  /// Exact scaffold background (`ConstellationView`'s ColoredBox), so
  /// the box fill is invisible against the backdrop and only the gold
  /// border + text read.
  static const Color _bgFill = Color(0xFF060810);

  static const double _boxWidth = 76.0;
  static const double _boxHeight = 22.0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: _boxWidth,
        height: _boxHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _bgFill,
          border: Border.all(color: _gold, width: 1.2),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          '$year CE',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            color: _gold,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            // Spec: letter-spacing 0.04em. Flutter letterSpacing is in
            // logical px, so 0.04em × 12px ≈ 0.48.
            letterSpacing: 0.48,
          ),
        ),
      ),
    );
  }
}
