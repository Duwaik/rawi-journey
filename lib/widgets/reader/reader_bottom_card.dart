import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/scene_config.dart';
import 'manuscript_writing_text.dart';

/// R28 S3-P1-02 · Reader-mode bottom card.
///
/// Occupies 35 % of screen height at the bottom of the scene. Top 65 %
/// stays as scene BG (unmodified — BG frozen rule). The card carries the
/// page text via [ManuscriptWritingText].
///
/// Phase 1 P1-02 ships only the scaffold + a single page (the first
/// hotspot's fragment). PageView, chevron, dots, scroll, tap-to-complete,
/// and the 1 s establishing beat land in P1-04 / P1-05 / P1-06 / P1-07 /
/// P1-08 / P1-11 commits.
class ReaderBottomCard extends StatelessWidget {
  final List<SceneHotspot> hotspots;
  final bool isAr;

  const ReaderBottomCard({
    super.key,
    required this.hotspots,
    required this.isAr,
  });

  static const Color _parchment = Color(0xFFF5E6C8);
  static const Color _ink       = Color(0xFF3D2A10);
  static const Color _inkMuted  = Color(0xFF6B4A1E);

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final cardH = screenH * 0.35;

    final firstFragment = hotspots.isEmpty
        ? ''
        : (isAr ? hotspots.first.fragmentAr : hotspots.first.fragment);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: cardH,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _parchment,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(90),
              blurRadius: 14,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(20, 18, 20, bottomPad + 16),
        child: ManuscriptWritingText(
          text: firstFragment,
          isAr: isAr,
          textAlign: TextAlign.start,
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          textStyle: isAr
              ? GoogleFonts.arefRuqaa(
                  color: _ink,
                  fontSize: 16,
                  height: 1.85,
                  fontWeight: FontWeight.w400,
                )
              : GoogleFonts.cormorantGaramond(
                  color: _ink,
                  fontSize: 16,
                  height: 1.55,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
        ),
      ),
    );
  }

  // Reserve token used by sibling Phase 1 widgets (chevron / dots) — keeps
  // a single source of truth for the Reader card's muted-ink color.
  static Color get inkMuted => _inkMuted;
}
