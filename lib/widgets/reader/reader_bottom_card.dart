import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/scene_config.dart';
import 'manuscript_writing_text.dart';

/// R28 S3-P1-02 + P1-04 + P1-05 · Reader-mode bottom card.
///
/// Occupies 35 % of screen height at the bottom of the scene. Top 65 %
/// stays as scene BG (BG frozen rule preserved). Carries page text via
/// [ManuscriptWritingText] inside a [PageView] — N hotspots = N pages,
/// strict 1:1.
///
/// Page advance: horizontal swipe in the locale's "forward" direction
/// (LTR EN: swipe left, RTL AR: swipe right). PageView's `reverse`
/// flag flips with `isAr`. Chevron at the card bottom mirrors the
/// forward direction (chevron_right for LTR forward, chevron_left for
/// RTL forward) and pulses softly (scale 1.0 → 1.05, opacity 0.7 → 1.0)
/// every 2 seconds. Tap = `pageController.nextPage(...)`. Hidden on
/// the last page (no forward target).
///
/// Phase 1 leaves the last-page-forward gesture as a no-op; Phase 2
/// wires the end-of-event flow onto this same surface.
class ReaderBottomCard extends StatefulWidget {
  final List<SceneHotspot> hotspots;
  final bool isAr;

  const ReaderBottomCard({
    super.key,
    required this.hotspots,
    required this.isAr,
  });

  static const Color parchment = Color(0xFFF5E6C8);
  static const Color ink       = Color(0xFF3D2A10);
  static const Color inkMuted  = Color(0xFF6B4A1E);

  @override
  State<ReaderBottomCard> createState() => _ReaderBottomCardState();
}

class _ReaderBottomCardState extends State<ReaderBottomCard>
    with SingleTickerProviderStateMixin {
  late final PageController _pageCtrl;
  late final AnimationController _pulseCtrl;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    // 2-second pulse loop for the chevron arrow.
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pageCtrl.addListener(() {
      final p = _pageCtrl.page;
      if (p == null) return;
      final rounded = p.round();
      if (rounded != _currentPage) {
        setState(() => _currentPage = rounded);
      }
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _advance() {
    if (_currentPage >= widget.hotspots.length - 1) return;
    _pageCtrl.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final cardH = screenH * 0.35;
    final isLast = _currentPage >= widget.hotspots.length - 1;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: cardH,
        width: double.infinity,
        decoration: BoxDecoration(
          color: ReaderBottomCard.parchment,
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
        child: Stack(
          children: [
            // ── Page content ───────────────────────────────────────
            Positioned.fill(
              child: PageView.builder(
                controller: _pageCtrl,
                // RTL (AR) reverses page-flow so swipe-right = forward.
                reverse: widget.isAr,
                itemCount: widget.hotspots.length,
                itemBuilder: (context, index) {
                  return _PageContent(
                    hotspot: widget.hotspots[index],
                    isAr: widget.isAr,
                    bottomReserve: bottomPad + 44,
                  );
                },
              ),
            ),
            // ── Bottom chevron (P1-05) — hidden on last page ──────
            if (!isLast)
              Positioned(
                left: 0,
                right: 0,
                bottom: bottomPad + 12,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (context, _) {
                      final t = _pulseCtrl.value; // 0..1..0 reversed
                      final scale = 1.0 + 0.05 * t;
                      final opacity = 0.7 + 0.3 * t;
                      return Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: opacity,
                          child: GestureDetector(
                            onTap: _advance,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                widget.isAr
                                    ? Icons.chevron_left_rounded
                                    : Icons.chevron_right_rounded,
                                size: 28,
                                color: ReaderBottomCard.inkMuted,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Single page — wraps [ManuscriptWritingText] with the card's padding.
class _PageContent extends StatelessWidget {
  final SceneHotspot hotspot;
  final bool isAr;
  final double bottomReserve;

  const _PageContent({
    required this.hotspot,
    required this.isAr,
    required this.bottomReserve,
  });

  @override
  Widget build(BuildContext context) {
    final text = isAr ? hotspot.fragmentAr : hotspot.fragment;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 18, 20, bottomReserve),
      child: ManuscriptWritingText(
        // Key on the hotspot id so PageView keeps each page's reveal
        // state independent — switching to a new page doesn't restart
        // the previous page's animation.
        key: ValueKey('reader-page-${hotspot.id}'),
        text: text,
        isAr: isAr,
        textAlign: TextAlign.start,
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        textStyle: isAr
            ? GoogleFonts.arefRuqaa(
                color: ReaderBottomCard.ink,
                fontSize: 16,
                height: 1.85,
                fontWeight: FontWeight.w400,
              )
            : GoogleFonts.cormorantGaramond(
                color: ReaderBottomCard.ink,
                fontSize: 16,
                height: 1.55,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
      ),
    );
  }
}
