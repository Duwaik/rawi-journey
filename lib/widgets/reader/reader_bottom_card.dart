import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app_colors.dart';
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
  // R28 S3-P1-11 · 1-second establishing beat. Page 1's content stays
  // un-mounted for the first 1000 ms after the card opens so the scene
  // can breathe before the writing animation begins.
  bool _firstPageReady = false;

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
    // P1-11 — schedule page 1 reveal after the establishing beat.
    Future<void>.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _firstPageReady = true);
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
                  // P1-11 — withhold page 1's content for 1 s after open
                  // so the scene breathes. Pages 2..4 mount whenever
                  // PageView builds them (typically on swipe-in), so
                  // they start their reveal as the user lands on them.
                  if (index == 0 && !_firstPageReady) {
                    return const _EmptyPage();
                  }
                  return _PageContent(
                    hotspot: widget.hotspots[index],
                    isAr: widget.isAr,
                    bottomReserve: bottomPad + 44,
                  );
                },
              ),
            ),
            // ── Page dots (P1-08) — always visible ────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomPad + 48, // sits just above the chevron
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(widget.hotspots.length, (i) {
                    final isCurrent = i == _currentPage;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCurrent
                              ? AppColors.gold
                              : ReaderBottomCard.inkMuted.withAlpha(80),
                        ),
                      ),
                    );
                  }),
                ),
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

/// Quiet placeholder rendered for page 1 during the P1-11 establishing
/// beat — same padding shape as a real page, no text, no controllers.
class _EmptyPage extends StatelessWidget {
  const _EmptyPage();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand();
  }
}

/// Single page — wraps [ManuscriptWritingText] with the card's padding
/// and a tap handler that invokes the per-page writing controller's
/// `completeNow()` (R28 S3-P1-06).
class _PageContent extends StatefulWidget {
  final SceneHotspot hotspot;
  final bool isAr;
  final double bottomReserve;

  const _PageContent({
    required this.hotspot,
    required this.isAr,
    required this.bottomReserve,
  });

  @override
  State<_PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<_PageContent> {
  late final ManuscriptWritingController _writingCtrl;
  late final ScrollController _scrollCtrl;

  @override
  void initState() {
    super.initState();
    _writingCtrl = ManuscriptWritingController();
    _scrollCtrl = ScrollController();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onTextTap() {
    // Post-completion tap is a no-op — controller's completeNow is
    // idempotent (early-returns when _completed). The clean
    // "swipe/chevron, not text-tap, advances the page" gesture
    // separation stays.
    _writingCtrl.completeNow();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.isAr
        ? widget.hotspot.fragmentAr
        : widget.hotspot.fragment;
    return Directionality(
      // Locale-driven directionality — Scrollbar picks up the trailing
      // edge from this (LTR → right edge, RTL → left edge), satisfying
      // the spec's "right edge (LTR) / left edge (RTL)" requirement
      // without manual positioning.
      textDirection: widget.isAr ? TextDirection.rtl : TextDirection.ltr,
      child: GestureDetector(
        onTap: _onTextTap,
        // HitTestBehavior.opaque so taps on the parchment around the text
        // also count as "tap-to-complete." Horizontal swipes still win
        // the gesture arena because TapGestureRecognizer requires no
        // movement — once a finger moves, PageView's HorizontalDrag
        // takes over. Vertical drag on overflowing content is captured
        // by SingleChildScrollView below before reaching this detector.
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 18, 20, widget.bottomReserve),
          child: Theme(
            // Local theme override — narrow parchment-ink scrollbar.
            data: Theme.of(context).copyWith(
              scrollbarTheme: ScrollbarThemeData(
                thumbColor: WidgetStateProperty.all(
                  ReaderBottomCard.inkMuted.withAlpha(150),
                ),
                thickness: WidgetStateProperty.all(2),
                radius: const Radius.circular(1),
                crossAxisMargin: 1,
                mainAxisMargin: 4,
                // null thumbVisibility = default behaviour: appears on
                // scroll, fades out shortly after — matches spec's
                // "fade-in on scroll-active" + "only visible when
                // content overflows."
              ),
            ),
            child: Scrollbar(
              controller: _scrollCtrl,
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                // ClampingScrollPhysics: no overscroll bounce on a
                // small overflowing page (BouncingScrollPhysics would
                // feel mushy at the 35 % card scale).
                physics: const ClampingScrollPhysics(),
                child: ManuscriptWritingText(
                  // Key on the hotspot id so PageView keeps each page's
                  // reveal state independent — switching to a new page
                  // doesn't restart the previous page's animation.
                  key: ValueKey('reader-page-${widget.hotspot.id}'),
                  text: text,
                  isAr: widget.isAr,
                  controller: _writingCtrl,
                  // R28-RFT-02 · scroll-follow uses THIS page's existing
                  // _scrollCtrl (the same one driving the Scrollbar +
                  // SingleChildScrollView) — no second controller.
                  followController: _scrollCtrl,
                  textAlign: TextAlign.start,
                  textDirection: widget.isAr
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  textStyle: widget.isAr
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
