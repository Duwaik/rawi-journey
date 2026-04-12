import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../data/dhikr_data.dart';
import '../data/scroll_entries.dart';
import '../models/badge_definition.dart';
import '../models/dhikr_card.dart';
import '../models/journey_event.dart';
import '../models/scroll_entry.dart';
import '../services/audio_service.dart';
import '../services/prefs_service.dart';
import 'event_list_screen.dart';

/// R17.2-05: Unified completion screen — replaces 5 separate post-event
/// overlays (chapter / badge / XP / dhikr / scroll writing) with one
/// scrollable cinematic screen.
///
/// Sections appear in staggered order with their own micro-animations:
///   1. Chapter complete (only if era end)
///   2. Badge earned (only if new badges)
///   3. Scroll line (always — ink writing animation)
///   4. XP count-up (always — compact line)
///   5. Dhikr card (if dhikrCards contains event.id)
///   6. Continue button (gates screen exit)
///
/// Persistence writes:
///   - XP + completeEvent + clearHotspotProgress + badges are ALREADY
///     written by immersive_event_screen._selectChoice BEFORE navigation.
///     We do not double-write them here.
///   - Dhikr prefs are written when the user taps "I've said it".
class UnifiedCompletionScreen extends StatefulWidget {
  final JourneyEvent event;
  final int xpEarned;
  final int previousXp;
  final List<BadgeDefinition> newBadges;
  final bool isChapterEnd;
  final bool alreadyCompleted;

  const UnifiedCompletionScreen({
    super.key,
    required this.event,
    required this.xpEarned,
    required this.previousXp,
    required this.newBadges,
    required this.isChapterEnd,
    required this.alreadyCompleted,
  });

  @override
  State<UnifiedCompletionScreen> createState() =>
      _UnifiedCompletionScreenState();
}

class _UnifiedCompletionScreenState extends State<UnifiedCompletionScreen>
    with TickerProviderStateMixin {
  // ── Parchment / ink palette (matches scroll_writing_screen) ─────────
  static const _parchment = Color(0xFFF5E6C8);
  static const _parchmentNested = Color(0xFFE8D6B0);
  static const _inkDark = Color(0xFF402010);
  static const _inkMuted = Color(0xFF6B4423);
  static const _goldShimmer = Color(0xFFD4A843);

  // ── Screen-level fade-in ─────────────────────────────────────────────
  late final AnimationController _screenFade;

  // ── Per-section fade controllers (staggered) ─────────────────────────
  late final AnimationController _chapterFade;
  late final AnimationController _badgeFade;
  late final AnimationController _scrollFade;
  late final AnimationController _xpFade;
  late final AnimationController _dhikrFade;
  late final AnimationController _continueFade;

  // ── Badge icon pop ───────────────────────────────────────────────────
  late final AnimationController _badgeIconCtrl;
  late final Animation<double> _badgeIconScale;

  // ── Scroll ink reveal (3s) + shimmer ────────────────────────────────
  late final AnimationController _scrollRevealCtrl;
  late final AnimationController _scrollShimmerCtrl;
  bool _scrollShimmerDone = false;

  // ── XP count-up ─────────────────────────────────────────────────────
  late final AnimationController _xpCountCtrl;
  late final Animation<int> _xpEarnedCount;
  late final Animation<int> _xpTotalCount;

  // ── XP star bounce (R18-02) ─────────────────────────────────────────
  late final AnimationController _xpStarCtrl;
  late final Animation<double> _xpStarScale;

  // ── Dhikr celebration shimmer ────────────────────────────────────────
  late final AnimationController _dhikrShimmerCtrl;
  late final Animation<double> _dhikrShimmer;
  bool _dhikrCelebrating = false;
  bool _dhikrResolved = false;

  // ── Dhikr hold-to-complete ring (Explorer & Reader) ─────────────────
  late final AnimationController _holdRingCtrl;
  bool _holdRingComplete = false;

  // ── Gating ──────────────────────────────────────────────────────────
  bool _canExit = false;

  ScrollEntry? get _entry => scrollEntries[widget.event.id];
  DhikrCard? get _card => dhikrCards[widget.event.id];
  bool get _hasDhikr => _card != null;
  bool get _hasBadges => widget.newBadges.isNotEmpty;
  bool get _showChapter => widget.isChapterEnd;
  bool get _isAr => PrefsService.isAr;

  @override
  void initState() {
    super.initState();

    _screenFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _chapterFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _badgeFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scrollFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _xpFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _dhikrFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _continueFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _badgeIconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _badgeIconScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.1), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 40),
    ]).animate(_badgeIconCtrl);

    _scrollRevealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _scrollShimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scrollRevealCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.mediumImpact();
        _scrollShimmerCtrl.forward().then((_) {
          if (!mounted) return;
          setState(() => _scrollShimmerDone = true);
          _startXpCountUp();
        });
      }
    });

    _xpCountCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _xpEarnedCount = IntTween(begin: 0, end: widget.xpEarned).animate(
      CurvedAnimation(parent: _xpCountCtrl, curve: Curves.easeOut),
    );
    _xpTotalCount = IntTween(
      begin: widget.previousXp,
      end: widget.previousXp + widget.xpEarned,
    ).animate(CurvedAnimation(parent: _xpCountCtrl, curve: Curves.easeOut));
    _xpCountCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _afterXp();
      }
    });

    // R18-02: Star bounce — 0 → 1.3 → 1.0 over 400ms with elastic feel.
    _xpStarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _xpStarScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 40),
    ]).animate(
      CurvedAnimation(parent: _xpStarCtrl, curve: Curves.easeOut),
    );

    _dhikrShimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _dhikrShimmer =
        CurvedAnimation(parent: _dhikrShimmerCtrl, curve: Curves.easeOut);

    _holdRingCtrl = AnimationController(
      vsync: this,
      duration: _holdDurationForCard(_card),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_holdRingComplete) {
          _onHoldComplete();
        }
      });

    _runStaggeredIntro();
  }

  // ── Stagger orchestration ────────────────────────────────────────────
  Future<void> _runStaggeredIntro() async {
    _screenFade.forward();

    // Section 1: Chapter (0ms)
    if (_showChapter) {
      _chapterFade.forward();
      HapticFeedback.heavyImpact();
    }

    // Section 2: Badge (200ms)
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    if (_hasBadges) {
      _badgeFade.forward();
      _badgeIconCtrl.forward();
      HapticFeedback.mediumImpact();
    }

    // Section 3: Scroll (400ms) — 3s reveal
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _scrollFade.forward();
    if (_entry != null) {
      _scrollRevealCtrl.forward();
    } else {
      // No scroll entry — skip straight to XP
      _startXpCountUp();
    }
  }

  void _startXpCountUp() {
    if (!mounted) return;
    _xpFade.forward();
    _xpStarCtrl.forward();
    if (widget.xpEarned > 0) {
      _xpCountCtrl.forward();
    } else {
      // Nothing to count — continue straight to dhikr
      _afterXp();
    }
  }

  void _afterXp() {
    if (!mounted) return;
    if (_hasDhikr) {
      _dhikrFade.forward();
    } else {
      // No dhikr — reveal Continue immediately
      setState(() {
        _dhikrResolved = true;
        _canExit = true;
      });
      _continueFade.forward();
    }
  }

  // ── Dhikr hold helpers ───────────────────────────────────────────────

  /// Map dhikr count text to a hold duration (seconds).
  /// Calibrated so the user has time to actually say it.
  static Duration _holdDurationForCard(DhikrCard? card) {
    if (card == null) return const Duration(seconds: 8);
    final c = (card.count ?? '').toLowerCase();
    if (c.contains('100') || c.contains('hundred')) return const Duration(seconds: 60);
    if (c.contains('33'))   return const Duration(seconds: 45);
    if (c.contains('10'))   return const Duration(seconds: 30);
    // Note: 'seven' is safe but 'ten' appears in 'often' — don't add it.
    if (c.contains('7') || c.contains('seven'))  return const Duration(seconds: 20);
    if (c.contains('3') || c.contains('three'))  return const Duration(seconds: 12);
    return const Duration(seconds: 8); // single / unspecified
  }

  void _onHoldStart() {
    if (_dhikrResolved || _holdRingComplete) return;
    _holdRingCtrl.forward();
  }

  void _onHoldEnd() {
    if (_holdRingComplete) return;
    _holdRingCtrl.stop(); // pauses — does NOT reset
  }

  Future<void> _onHoldComplete() async {
    if (_holdRingComplete) return;
    _holdRingComplete = true;
    HapticFeedback.heavyImpact();

    // Noor recharge in Explorer Mode
    if (PrefsService.isExplorerMode) {
      await PrefsService.rechargeNoor(50);
    }

    await PrefsService.incrementDhikrCount();
    await PrefsService.setDhikrCompleted(widget.event.id);
    await _dhikrShimmerCtrl.forward();
    if (!mounted) return;
    setState(() {
      _dhikrCelebrating = true;
      _dhikrResolved = true;
      _canExit = true;
    });
    _continueFade.forward();
  }

  // ── Dhikr actions ────────────────────────────────────────────────────
  Future<void> _onSaidIt() async {
    if (_dhikrCelebrating) return;
    HapticFeedback.mediumImpact();
    setState(() => _dhikrCelebrating = true);
    await PrefsService.incrementDhikrCount();
    await PrefsService.setDhikrCompleted(widget.event.id);
    await _dhikrShimmerCtrl.forward();
    if (!mounted) return;
    setState(() {
      _dhikrResolved = true;
      _canExit = true;
    });
    _continueFade.forward();
  }

  void _onNotNow() {
    if (_dhikrResolved) return;
    setState(() {
      _dhikrResolved = true;
      _canExit = true;
    });
    _continueFade.forward();
  }

  // ── Exit ─────────────────────────────────────────────────────────────
  void _continueJourney() {
    AudioService.stopSfx();
    AudioService.fadeOut(duration: const Duration(milliseconds: 250));
    AudioService.fadeOutVoiceover(
        duration: const Duration(milliseconds: 200));
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const EventListScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _screenFade.dispose();
    _chapterFade.dispose();
    _badgeFade.dispose();
    _scrollFade.dispose();
    _xpFade.dispose();
    _dhikrFade.dispose();
    _continueFade.dispose();
    _badgeIconCtrl.dispose();
    _scrollRevealCtrl.dispose();
    _scrollShimmerCtrl.dispose();
    _xpCountCtrl.dispose();
    _xpStarCtrl.dispose();
    _dhikrShimmerCtrl.dispose();
    _holdRingCtrl.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return PopScope(
      canPop: _canExit,
      child: Scaffold(
        backgroundColor: const Color(0xFF04060D),
        body: FadeTransition(
          opacity: _screenFade,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF04060D),
                  Color(0xFF0B1E2D),
                  Color(0xFF04060D),
                ],
              ),
            ),
            child: SafeArea(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPad + 24),
                children: _buildSectionChildren(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── R18-01: Section assembly with dividers between blocks ───────────
  List<Widget> _buildSectionChildren() {
    final blocks = <Widget>[];
    if (_showChapter) blocks.add(_buildChapterSection());
    if (_hasBadges) blocks.add(_buildBadgeSection());
    blocks.add(_buildScrollSection());
    blocks.add(_buildXpSection());
    if (_hasDhikr) blocks.add(_buildDhikrSection());

    // Weave 24px spacers + gold divider lines between each section.
    final children = <Widget>[];
    for (var i = 0; i < blocks.length; i++) {
      if (i > 0) {
        children.add(const SizedBox(height: 24));
        children.add(_sectionDivider());
        children.add(const SizedBox(height: 24));
      }
      children.add(blocks[i]);
    }
    children.add(_buildContinueSection());
    return children;
  }

  Widget _sectionDivider() {
    return Container(
      height: 1,
      color: AppColors.gold.withAlpha(75),
    );
  }

  // ── Section 1: Chapter complete ──────────────────────────────────────
  Widget _buildChapterSection() {
    final era = widget.event.era;
    final lang = _isAr ? 'ar' : 'en';
    return FadeTransition(
      opacity: _chapterFade,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text(era.emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            era.label(lang),
            textAlign: TextAlign.center,
            textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
            style: GoogleFonts.cinzelDecorative(
              color: AppColors.gold,
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            era.closingLine(lang),
            textAlign: TextAlign.center,
            textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
            style: _isAr
                ? GoogleFonts.amiri(
                    color: const Color(0xFFE8D8B8),
                    fontSize: 16,
                    height: 1.6,
                  )
                : GoogleFonts.lora(
                    color: const Color(0xFFE8D8B8),
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                  ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ── Section 2: Badge earned ─────────────────────────────────────────
  Widget _buildBadgeSection() {
    return FadeTransition(
      opacity: _badgeFade,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            _isAr ? 'وسام جديد' : 'BADGE UNLOCKED',
            style: GoogleFonts.nunito(
              color: AppColors.gold,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 14),
          for (final badge in widget.newBadges)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _badgeIconCtrl,
                    builder: (_, _) => Transform.scale(
                      scale: _badgeIconScale.value,
                      child: Text(
                        badge.icon,
                        style: const TextStyle(fontSize: 56),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isAr ? badge.nameAr : badge.name,
                    textAlign: TextAlign.center,
                    textDirection:
                        _isAr ? TextDirection.rtl : TextDirection.ltr,
                    style: GoogleFonts.lora(
                      color: AppColors.gold,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isAr ? badge.descriptionAr : badge.description,
                    textAlign: TextAlign.center,
                    textDirection:
                        _isAr ? TextDirection.rtl : TextDirection.ltr,
                    style: GoogleFonts.nunito(
                      color: const Color(0xFFE8D8B8),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ── Section 3: Scroll line (ink writing) ─────────────────────────────
  Widget _buildScrollSection() {
    final entry = _entry;
    return FadeTransition(
      opacity: _scrollFade,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            _isAr
                ? '\u0633\u0650\u062C\u0650\u0644\u0651 \u0627\u0644\u0631\u0627\u0648\u064A'
                : 'The Rawi\u2019s Scroll',
            style: GoogleFonts.cinzelDecorative(
              color: AppColors.gold,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          AnimatedBuilder(
            animation: _scrollShimmerCtrl,
            builder: (context, child) {
              // R18-04: fade a stronger gold glow over the card during
              // the 200ms shimmer window when the line completes.
              final shimmerV = _scrollShimmerCtrl.value;
              final glowAlpha = (18 + (120 * shimmerV)).toInt().clamp(0, 255);
              final glowSpread = 2.0 * shimmerV;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: _parchment,
                  image: DecorationImage(
                    image: const AssetImage(
                        'assets/textures/parchment_light.jpg'),
                    fit: BoxFit.cover,
                    // R18-03: subtle dark overlay to improve text
                    // contrast on the crumpled parchment texture (~8%).
                    colorFilter: ColorFilter.mode(
                      Colors.black.withAlpha(20),
                      BlendMode.darken,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.gold.withAlpha(80),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withAlpha(glowAlpha),
                      blurRadius: 14 + (10 * shimmerV),
                      spreadRadius: glowSpread,
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: entry == null
                ? Text(
                    _isAr
                        ? '\u0627\u0643\u062A\u0645\u0644\u062A \u0647\u0630\u0647 \u0627\u0644\u0635\u0641\u062D\u0629.'
                        : 'This page is complete.',
                    textAlign: TextAlign.center,
                    textDirection:
                        _isAr ? TextDirection.rtl : TextDirection.ltr,
                    style: _isAr
                        ? GoogleFonts.amiri(color: _inkDark, fontSize: 16)
                        : GoogleFonts.lora(color: _inkDark, fontSize: 16),
                  )
                : AnimatedBuilder(
                    animation: Listenable.merge(
                      [_scrollRevealCtrl, _scrollShimmerCtrl],
                    ),
                    builder: (context, _) {
                      final text = _isAr ? entry.lineAr : entry.lineEn;
                      final reveal = _scrollRevealCtrl.value;
                      final charCount = (text.length * reveal).round();
                      final visibleText = text.substring(0, charCount);

                      final shimmerV = _scrollShimmerCtrl.value;
                      final inkColor = shimmerV > 0 && !_scrollShimmerDone
                          ? Color.lerp(_inkDark, _goldShimmer, shimmerV)!
                          : _inkDark;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        textDirection:
                            _isAr ? TextDirection.rtl : TextDirection.ltr,
                        children: [
                          Expanded(
                            child: Text(
                              visibleText,
                              textDirection: _isAr
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              style: _isAr
                                  ? GoogleFonts.amiri(
                                      color: inkColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      height: 1.9,
                                    )
                                  : GoogleFonts.lora(
                                      color: inkColor,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      height: 1.9,
                                    ),
                            ),
                          ),
                          // R18-04: Quill pen — small gold dot that
                          // rides the leading edge of the ink reveal,
                          // then fades out (200ms) as the shimmer plays.
                          if (reveal > 0 && !_scrollShimmerDone)
                            Opacity(
                              opacity: reveal < 1
                                  ? 1.0
                                  : (1.0 - shimmerV).clamp(0.0, 1.0),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.gold,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.gold.withAlpha(180),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ── Section 4: XP — prominent center block (R18-02) ─────────────────
  Widget _buildXpSection() {
    return FadeTransition(
      opacity: _xpFade,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Star with bounce + gold glow
            AnimatedBuilder(
              animation: _xpStarCtrl,
              builder: (_, _) {
                return Transform.scale(
                  scale: _xpStarScale.value,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withAlpha(140),
                          blurRadius: 4,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: AppColors.gold,
                      size: 28,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            // Earned XP — large count-up
            AnimatedBuilder(
              animation: _xpCountCtrl,
              builder: (_, _) {
                final earned = widget.xpEarned == 0 ? 0 : _xpEarnedCount.value;
                return Text(
                  '+$earned XP',
                  style: GoogleFonts.cinzelDecorative(
                    color: AppColors.gold,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
            const SizedBox(height: 6),
            // Total line
            AnimatedBuilder(
              animation: _xpCountCtrl,
              builder: (_, _) {
                final total = widget.xpEarned == 0
                    ? widget.previousXp
                    : _xpTotalCount.value;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isAr ? 'المجموع: ' : 'Total: ',
                      style: GoogleFonts.nunito(
                        color: AppColors.gold.withAlpha(190),
                        fontSize: 16,
                      ),
                    ),
                    const Icon(Icons.star_rounded,
                        color: AppColors.gold, size: 16),
                    const SizedBox(width: 2),
                    Text(
                      '$total',
                      style: GoogleFonts.nunito(
                        color: AppColors.gold,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Section 5: Dhikr card ────────────────────────────────────────────
  Widget _buildDhikrSection() {
    final card = _card!;
    return FadeTransition(
      opacity: _dhikrFade,
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Text(
              _isAr
                  ? '\uD83D\uDCFF \u0627\u0643\u0633\u0628 \u062D\u0633\u0646\u0627\u062A'
                  : '\uD83D\uDCFF Earn Hasanat',
              style: GoogleFonts.cinzelDecorative(
                color: AppColors.gold,
                fontSize: 18,
              ),
              textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
            ),
            const SizedBox(height: 14),
            AnimatedBuilder(
              animation: _dhikrShimmer,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: _parchment,
                    image: DecorationImage(
                      image: const AssetImage(
                          'assets/textures/parchment_light.jpg'),
                      fit: BoxFit.cover,
                      // R18-03: subtle dark overlay on parchment for
                      // better text contrast.
                      colorFilter: ColorFilter.mode(
                        Colors.black.withAlpha(20),
                        BlendMode.darken,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _dhikrCelebrating
                          ? AppColors.gold.withAlpha(
                              (80 + (175 * _dhikrShimmer.value))
                                  .toInt()
                                  .clamp(0, 255))
                          : AppColors.gold.withAlpha(80),
                      width: _dhikrCelebrating ? 2 : 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withAlpha(_dhikrCelebrating
                            ? (60 * _dhikrShimmer.value).toInt()
                            : 18),
                        blurRadius: _dhikrCelebrating ? 22 : 14,
                        spreadRadius: _dhikrCelebrating ? 2 : 0,
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: Column(
                children: [
                  Text(
                    card.arabicText,
                    style: GoogleFonts.amiri(
                      fontSize: 22,
                      color: _inkDark,
                      height: 1.8,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    card.transliteration,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: _inkMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isAr ? card.meaningAr : card.meaningEn,
                    style: GoogleFonts.lora(
                      fontSize: 13,
                      fontStyle:
                          _isAr ? FontStyle.normal : FontStyle.italic,
                      color: _inkDark,
                    ),
                    textAlign: TextAlign.center,
                    textDirection:
                        _isAr ? TextDirection.rtl : TextDirection.ltr,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: const Color(0xFF8B6F47).withAlpha(60),
                  ),
                  const SizedBox(height: 16),
                  _dhikrInfoLine(
                    '\uD83D\uDCFF',
                    card.count != null
                        ? (_isAr
                            ? '\u0642\u0644\u0647\u0627: ${card.countAr ?? card.count}'
                            : 'Say it: ${card.count}')
                        : (_isAr
                            ? '\u0642\u0644\u0647\u0627 \u0645\u0631\u0629 \u0628\u062D\u0636\u0648\u0631 \u0642\u0644\u0628'
                            : 'Say it once with presence of heart'),
                  ),
                  const SizedBox(height: 8),
                  _dhikrInfoLine(
                    '\uD83D\uDD50',
                    _isAr
                        ? '\u0645\u062A\u0649: ${card.whenToSayAr}'
                        : 'When: ${card.whenToSay}',
                  ),
                  const SizedBox(height: 18),
                  // Promise sub-card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _parchmentNested,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF8B6F47).withAlpha(60),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _isAr ? '\u2728 \u0627\u0644\u0648\u0639\u062F' : '\u2728 The Promise',
                          style: GoogleFonts.cinzelDecorative(
                            fontSize: 13,
                            color: AppColors.gold,
                          ),
                          textDirection:
                              _isAr ? TextDirection.rtl : TextDirection.ltr,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isAr ? card.promiseAr : card.promiseEn,
                          style: GoogleFonts.lora(
                            fontSize: 13,
                            color: _inkDark,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                          textDirection: _isAr
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isAr ? card.sourceRefAr : card.sourceRef,
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: _inkMuted,
                          ),
                          textDirection: _isAr
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Hold-to-complete ring ──────────────────────────────────
            if (!_dhikrResolved)
              Column(
                children: [
                  Text(
                    _isAr
                        ? 'ضع إصبعك واقرأ الذكر'
                        : 'Hold and recite the dhikr',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: _inkMuted,
                    ),
                    textDirection:
                        _isAr ? TextDirection.rtl : TextDirection.ltr,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onLongPressStart: (_) => _onHoldStart(),
                    onLongPressEnd: (_) => _onHoldEnd(),
                    // Also support simple tap-and-hold via down/up
                    onTapDown: (_) => _onHoldStart(),
                    onTapUp: (_) => _onHoldEnd(),
                    onTapCancel: () => _onHoldEnd(),
                    child: AnimatedBuilder(
                      animation: _holdRingCtrl,
                      builder: (context, child) {
                        return SizedBox(
                          width: 80,
                          height: 80,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Background ring
                              SizedBox(
                                width: 72,
                                height: 72,
                                child: CircularProgressIndicator(
                                  value: _holdRingCtrl.value,
                                  strokeWidth: 4,
                                  backgroundColor:
                                      AppColors.gold.withAlpha(40),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.gold,
                                  ),
                                ),
                              ),
                              // Center icon
                              Icon(
                                _holdRingCtrl.value < 1.0
                                    ? Icons.touch_app_rounded
                                    : Icons.check_circle_rounded,
                                size: 32,
                                color: _holdRingCtrl.value < 1.0
                                    ? AppColors.gold.withAlpha(180)
                                    : AppColors.gold,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Noor recharge hint (Explorer Mode only)
                  if (PrefsService.isExplorerMode)
                    Text(
                      _isAr ? 'نور +٥٠٪' : 'Noor +50%',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        color: AppColors.gold.withAlpha(140),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),

            // ── Resolved state: golden burst confirmation ──────────────
            if (_dhikrResolved)
              Column(
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 40, color: AppColors.gold),
                  const SizedBox(height: 6),
                  Text(
                    PrefsService.isExplorerMode
                        ? (_isAr ? 'تمّ — النور يتجدّد' : 'Done — Light restored')
                        : (_isAr ? 'بارك الله فيك' : 'May Allah bless you'),
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                    textDirection:
                        _isAr ? TextDirection.rtl : TextDirection.ltr,
                  ),
                ],
              ),

            const SizedBox(height: 12),

            // ── Quick "I've said it" button (Reader Mode) ──────────────
            if (!_dhikrResolved && !PrefsService.isExplorerMode)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _dhikrCelebrating ? null : _onSaidIt,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: const Color(0xFF0B1E2D),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text(
                      _isAr ? '\u0642\u0644\u062A\u0647\u0627 \u2713' : 'I\'ve said it \u2713',
                      style: GoogleFonts.nunito(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),

            // ── Skip link ──────────────────────────────────────────────
            if (!_dhikrResolved)
              GestureDetector(
                onTap: _onNotNow,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _isAr ? 'تخطّي' : 'Skip',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: AppColors.textMuted.withAlpha(120),
                    ),
                    textDirection:
                        _isAr ? TextDirection.rtl : TextDirection.ltr,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _dhikrInfoLine(String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: _inkDark,
            ),
            textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
          ),
        ),
      ],
    );
  }

  // ── Section 6: Continue button ───────────────────────────────────────
  Widget _buildContinueSection() {
    return FadeTransition(
      opacity: _continueFade,
      child: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _canExit ? _continueJourney : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: const Color(0xFF0B1E2D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
              _isAr
                  ? '\u0623\u0643\u0645\u0644 \u0627\u0644\u0631\u062D\u0644\u0629 \u2190'
                  : 'Continue Journey \u2192',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
              textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
            ),
          ),
        ),
      ),
    );
  }

}
