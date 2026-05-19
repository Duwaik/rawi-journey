import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../data/dhikr_data.dart';
import '../data/passages_data.dart';
import '../data/scroll_entries.dart';
import '../models/badge_definition.dart';
import '../models/dhikr_card.dart';
import '../models/journey_event.dart';
import '../models/scroll_entry.dart';
import '../services/audio_service.dart';
import '../services/prefs_service.dart';
import '../widgets/reader_invitation_card.dart';
import 'passage_screen.dart';
import 'rawi_tent_screen.dart';

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
  // ── Dark card palette (R19-04: parchment removed for readability) ──
  static const _cardBg = Color(0xFF0E1A28);
  static const _cardBgNested = Color(0xFF152234);
  static const _textWarm = Color(0xFFE8D8B8); // warm white body text
  static const _textMuted = Color(0xFFA89878); // muted body text
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

  // R19-08c: First-time Explorer Mode dhikr tutorial card. Shown before
  // the hold ring on Event 1 only. Auto-fades after 4s or on tap.
  bool _showDhikrTutorial = false;
  Timer? _dhikrTutorialTimer;

  // R19-08b: Reader Mode "I've said it" path — distinct from skip and
  // from hold-ring completion. Used to show the right confirmation msg.
  bool _saidItPressed = false;

  // R26 S1v2-EE6: true once the user has positively confirmed dhikr
  // (hold-ring complete OR Reader-mode "I've said it"). Flipped false
  // by skip / not-now. Drives the -25% Light penalty in _continueJourney
  // and the 25% warning popup trigger.
  bool _dhikrAcknowledged = false;

  // R26 S1v2-EE6: defensive one-shot for the 25% warning dialog so it
  // never re-fires on the same page if the user dismisses and re-skips.
  bool _lightWarningShown = false;

  // ── Gating ──────────────────────────────────────────────────────────
  bool _canExit = false;

  // R28-RFT-08 · 2-screen split. 0 = Screen A (Reflection: scroll +
  // dhikr + 25% warning), 1 = Screen B (Completion: XP + chapter +
  // badge + witnessed-caption + Reader invitation + nav). The A→B
  // transition is user-gated (CTA tap, no auto-advance). Every section
  // builder + animation controller + the dhikr / passage / badge / XP
  // subsystems are reused verbatim (frozen-systems rule) — only their
  // grouping and the orchestration between beats changed.
  int _screen = 0;
  bool _aContinueReady = false;

  // R28-RFT-09 Part B: one-time Reader invitation after Event 1. While
  // pending it gates exit (the card has two explicit buttons, no skip);
  // resolving it reveals Continue. RFT-08 relocates this into the new
  // user-gated Screen B (spec: "RFT-08 depends on RFT-09 for invitation
  // widget integration") — this is the contained interim wiring.
  bool _invitationResolved = false;
  bool get _invitationPending =>
      widget.event.globalOrder == 1 &&
      !PrefsService.readerInvitationShown &&
      !_invitationResolved;

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
          // R26 S1v4-EE6.3: after scroll shimmer, wait out the 7 s
          // auto-read timer (3 s reveal + ~0.2 s shimmer already spent,
          // so ~3.8 s remaining) before fading in the dhikr section.
          // Dhikr is the only user-gated step now; everything else
          // auto-flows. Skip the wait and go straight to XP if there
          // is no dhikr for this event.
          Future.delayed(const Duration(milliseconds: 3800), () {
            if (!mounted) return;
            if (_hasDhikr) {
              _dhikrFade.forward();
            } else {
              // R28-RFT-08: Screen A has no XP. With no dhikr the
              // reflection beat is done → reveal A's user-gated
              // Continue (XP now lives on Screen B).
              _revealAContinue();
            }
          });
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

    // R19-08c: Show first-time dhikr tutorial only when:
    //   Explorer Mode + Event 1 + has dhikr + tutorial not yet seen.
    // Auto-fades after 4s; tap dismisses immediately.
    if (_hasDhikr &&
        PrefsService.isExplorerMode &&
        widget.event.globalOrder == 1 &&
        !PrefsService.isDhikrTutorialSeen) {
      _showDhikrTutorial = true;
      PrefsService.setDhikrTutorialSeen();
      _dhikrTutorialTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _showDhikrTutorial = false);
      });
    }

    _runStaggeredIntro();
  }

  // ── Stagger orchestration ────────────────────────────────────────────
  // R28-RFT-08: Screen A intro only — screen fade + the scroll
  // reflection (3 s reveal). Chapter / badge / XP moved to Screen B's
  // intro (_runScreenBIntro), reached via the user-gated A→B Continue.
  Future<void> _runStaggeredIntro() async {
    _screenFade.forward();
    _scrollFade.forward();
    if (_entry != null) {
      _scrollRevealCtrl.forward();
    } else {
      // No scroll entry: the reflection beat is only (optional) dhikr.
      if (_hasDhikr) {
        _dhikrFade.forward();
      } else {
        _revealAContinue();
      }
    }
  }

  /// R28-RFT-08 · Screen A reflection done → reveal the user-gated
  /// Continue that advances to Screen B (NOT auto-advance).
  void _revealAContinue() {
    if (!mounted) return;
    setState(() => _aContinueReady = true);
  }

  /// R28-RFT-08 · A→B transition (user tapped Screen A's Continue).
  /// Runs Screen B's stagger: chapter → badge → XP. Nav buttons reveal
  /// after the XP count-up (_afterXp). No auto-exit — B is user-gated.
  Future<void> _goToScreenB() async {
    if (_screen == 1) return;
    setState(() => _screen = 1);
    if (_showChapter) {
      _chapterFade.forward();
      HapticFeedback.heavyImpact();
    }
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    if (_hasBadges) {
      _badgeFade.forward();
      _badgeIconCtrl.forward();
      HapticFeedback.mediumImpact();
    }
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _startXpCountUp();
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
    // R28-RFT-08: XP is Screen B's last auto beat. The 4 s auto-exit
    // is GONE — Screen B is fully user-gated (spec: "NOT auto-
    // advance"). Reveal the two nav buttons. RFT-09: if the Event-1
    // Reader invitation is still pending it renders above the nav and
    // its onResolved reveals them; otherwise reveal now.
    if (_invitationPending) return;
    setState(() => _canExit = true);
    _continueFade.forward();
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

    // R26 S1v2-EE6: event-completion dhikr no longer restores Light
    // (+50 rechargeNoor removed). New model: saying dhikr on event
    // completion = Light STAYS at whatever value it was at entry;
    // skipping = -25 penalty applied in _continueJourney. Only the
    // tent-side dhikr path (dhikr_collection_screen) regenerates.
    await PrefsService.incrementDhikrCount();
    await PrefsService.setDhikrCompleted(widget.event.id);
    await _dhikrShimmerCtrl.forward();
    if (!mounted) return;
    setState(() {
      _dhikrCelebrating = true;
      _dhikrResolved = true;
      _dhikrAcknowledged = true; // R26 S1v2-EE6
    });
    // R28-RFT-08: dhikr resolved → Screen A reflection complete.
    // Reveal the user-gated Continue (XP/badge/etc. are Screen B).
    _revealAContinue();
  }

  // ── Dhikr actions ────────────────────────────────────────────────────
  Future<void> _onSaidIt() async {
    if (_dhikrCelebrating) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _dhikrCelebrating = true;
      _saidItPressed = true; // R19-08b: mark as button-confirmed
    });
    await PrefsService.incrementDhikrCount();
    await PrefsService.setDhikrCompleted(widget.event.id);
    await _dhikrShimmerCtrl.forward();
    if (!mounted) return;
    setState(() {
      _dhikrResolved = true;
      _dhikrAcknowledged = true; // R26 S1v2-EE6
    });
    // R28-RFT-08: dhikr said → Screen A done → reveal Continue.
    _revealAContinue();
  }

  /// R26 S1v2-EE6: Skip path. If the user is at Light == 25 AND hasn't
  /// acknowledged dhikr yet, intercept with the "Your light is fading"
  /// warning dialog before committing the skip. Otherwise fall through
  /// to the normal skip behaviour. The -25 penalty itself is applied
  /// later at _continueJourney based on _dhikrAcknowledged.
  Future<void> _onNotNow() async {
    if (_dhikrResolved) return;
    if (!_lightWarningShown &&
        _hasDhikr &&
        !_dhikrAcknowledged &&
        PrefsService.noorLevel == 25) {
      _lightWarningShown = true;
      final skipAnyway = await _showLightWarningDialog();
      if (!mounted) return;
      if (skipAnyway != true) {
        // User picked "Say dhikr" — leave them on the dhikr card.
        // Dhikr state untouched; they can still tap "I've said it"
        // or complete the hold ring from here.
        return;
      }
    }
    setState(() => _dhikrResolved = true);
    // R28-RFT-08: skip still completes Screen A → reveal Continue.
    // The -25% Light penalty still lands in `_continueJourney` /
    // `_returnToTent` since `_dhikrAcknowledged` stays false.
    _revealAContinue();
  }

  /// R26 S1v2-EE6: warning popup when Light = 25 and user is skipping
  /// dhikr. Matches in-app dialog style (navy container + gold accents).
  /// Barrier dismissal disabled (EE8 rule: explicit choice only).
  Future<bool?> _showLightWarningDialog() {
    final isAr = _isAr;
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF0A0E18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.gold.withAlpha(100), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 36, color: AppColors.gold.withAlpha(200)),
              const SizedBox(height: 12),
              Text(
                isAr ? 'نورك يخفت' : 'Your light is fading',
                textAlign: TextAlign.center,
                textDirection:
                    isAr ? TextDirection.rtl : TextDirection.ltr,
                style: GoogleFonts.cinzelDecorative(
                  color: AppColors.gold,
                  fontSize: 18,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isAr
                    ? 'قل ذكرك لتحافظ على إشراق نورك. أو تخطَّ للمتابعة على أي حال.'
                    : 'Say your dhikr to keep your light shining. '
                        'Or tap skip to continue anyway.',
                textAlign: TextAlign.center,
                textDirection:
                    isAr ? TextDirection.rtl : TextDirection.ltr,
                style: GoogleFonts.nunito(
                  color: const Color(0xFFE8D8B8),
                  fontSize: 14,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 20),
              // Primary — Say dhikr (closes dialog, keeps user on page)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: const Color(0xFF0A0E18),
                    padding:
                        const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isAr ? 'قل الذكر' : 'Say dhikr',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Secondary — Skip anyway
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(
                  isAr ? 'تخطٍ' : 'Skip anyway',
                  style: GoogleFonts.nunito(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Exit ─────────────────────────────────────────────────────────────
  /// R28-RFT-08 · shared event-exit prelude. The LOCKED behaviour
  /// (-25% Light penalty for finishing without acknowledging dhikr,
  /// skipped on replays — floor 10 in PrefsService.setNoorLevel — plus
  /// the audio fades) extracted so the two Screen-B nav buttons can
  /// never diverge.
  void _exitPrelude() {
    // R26 S1v2-EE6: -25% Light for finishing without acknowledging
    // dhikr. Skipped on replays (already-completed never touch Light).
    if (!widget.alreadyCompleted && !_dhikrAcknowledged) {
      final current = PrefsService.noorLevel;
      PrefsService.setNoorLevel(current - 25);
    }
    AudioService.stopSfx();
    AudioService.fadeOut(duration: const Duration(milliseconds: 250));
    AudioService.fadeOutVoiceover(
        duration: const Duration(milliseconds: 200));
  }

  /// R28-RFT-08 · "Return to Tent" — contract-safe second nav button.
  /// Same exit prelude, straight to the tent, NO Passage cinematic;
  /// Passage-seen is left untouched so it can still play later via
  /// "Continue Journey" or a natural trigger. Honors the LOCKED
  /// Navigation Contract (event exit → tent). Khaled-chosen behaviour
  /// (S5-P1 nav-button question).
  void _returnToTent() {
    _exitPrelude();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        settings: const RouteSettings(name: RawiTentScreen.routeName),
        builder: (_) => const RawiTentScreen(),
      ),
      (route) => false,
    );
  }

  void _continueJourney() {
    _exitPrelude();

    // R20 Part E: The Passage — cinematic era transition shown once
    // after 5 pivotal events. Skipped on replays and when already seen.
    final passage = getPassageAfter(widget.event.globalOrder);
    final shouldShowPassage = passage != null &&
        !widget.alreadyCompleted &&
        !PrefsService.isPassageSeen(widget.event.globalOrder);

    if (shouldShowPassage) {
      PrefsService.setPassageSeen(widget.event.globalOrder);
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (ctx, a, s) => FadeTransition(
            opacity: a,
            child: PassageScreen(
              passage: passage,
              onComplete: () {
                Navigator.of(ctx).pushAndRemoveUntil(
                  MaterialPageRoute(
                    // R28 S1-BUG1: tag for popUntil target.
                    settings: const RouteSettings(
                        name: RawiTentScreen.routeName),
                    builder: (_) => const RawiTentScreen(),
                  ),
                  (route) => false,
                );
              },
            ),
          ),
        ),
        (route) => false,
      );
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        // R28 S1-BUG1: tag for popUntil target.
        settings: const RouteSettings(name: RawiTentScreen.routeName),
        builder: (_) => const RawiTentScreen(),
      ),
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
    _dhikrTutorialTimer?.cancel();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    // R26 S1v4-EE6.3: transparent Scaffold + a mid-strength scrim over
    // the revealed event scene (the previous route is kept mounted by
    // `PageRouteBuilder(opaque: false)` in `_completeAndPop`). The
    // scene reads behind and around the cards — scroll / dhikr / XP —
    // connecting the cinematic reveal to the closing flow.
    return PopScope(
      canPop: _canExit,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FadeTransition(
          opacity: _screenFade,
          child: Container(
            // Darkening scrim so card text stays readable on bright
            // scene BGs (and gives the usual navy look on black BGs).
            color: const Color(0xFF04060D).withValues(alpha: 0.72),
            child: SafeArea(
              // R28-RFT-08: 2-screen split. Screen A (Reflection) and
              // Screen B (Completion) are the same scrim+ListView shell
              // (no jarring route push between beats); only the child
              // list differs. AnimatedSwitcher cross-fades A→B on the
              // user-gated Continue.
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: ListView(
                  key: ValueKey<int>(_screen),
                  padding:
                      EdgeInsets.fromLTRB(24, 24, 24, bottomPad + 24),
                  children: _screen == 0
                      ? _buildScreenAChildren()
                      : _buildScreenBChildren(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── R18-01 / R28-RFT-08: Section assembly ───────────────────────────
  // Weave 24px spacers + a gold divider between consecutive blocks.
  List<Widget> _weave(List<Widget> blocks) {
    final children = <Widget>[];
    for (var i = 0; i < blocks.length; i++) {
      if (i > 0) {
        children.add(const SizedBox(height: 24));
        children.add(_sectionDivider());
        children.add(const SizedBox(height: 24));
      }
      children.add(blocks[i]);
    }
    return children;
  }

  /// R28-RFT-08 · Screen A — Reflection: the scroll line + (optional)
  /// dhikr. The 25% Light warning is part of the dhikr skip path
  /// (_onNotNow → _showLightWarningDialog), unchanged. A user-gated
  /// "Continue" appears once the reflection beat is done. NO XP /
  /// badge / chapter / nav here.
  List<Widget> _buildScreenAChildren() {
    final blocks = <Widget>[_buildScrollSection()];
    if (_hasDhikr) blocks.add(_buildDhikrSection());
    final children = _weave(blocks);
    if (_aContinueReady) {
      children.add(const SizedBox(height: 24));
      children.add(_sectionDivider());
      children.add(const SizedBox(height: 24));
      children.add(_buildAContinue());
    }
    return children;
  }

  /// R28-RFT-08 · Screen B — Completion: chapter? + badge? + XP +
  /// "Rawi has just witnessed" caption + the Event-1 Reader invitation
  /// (RFT-09, relocated here per spec — between the caption and the
  /// nav buttons) + the two nav buttons. Fully user-gated.
  List<Widget> _buildScreenBChildren() {
    final blocks = <Widget>[];
    if (_showChapter) blocks.add(_buildChapterSection());
    if (_hasBadges) blocks.add(_buildBadgeSection());
    blocks.add(_buildXpSection());
    blocks.add(_buildWitnessCaption());
    final children = _weave(blocks);
    if (_invitationPending) {
      children.add(const SizedBox(height: 24));
      children.add(_sectionDivider());
      children.add(const SizedBox(height: 24));
      children.add(ReaderInvitationCard(
        isAr: _isAr,
        onResolved: (_) {
          if (!mounted) return;
          setState(() {
            _invitationResolved = true;
            _canExit = true;
          });
          _continueFade.forward();
        },
      ));
    }
    children.add(_buildBNav());
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
                  color: _cardBg,
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
                        ? GoogleFonts.amiri(color: _textWarm, fontSize: 16)
                        : GoogleFonts.lora(color: _textWarm, fontSize: 16),
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
                          ? Color.lerp(_textWarm, _goldShimmer, shimmerV)!
                          : _textWarm;

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
                    color: _cardBg,
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
                      color: AppColors.gold,
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
                      color: _textMuted,
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
                      color: _textWarm,
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
                      color: _cardBgNested,
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
                            color: _textWarm,
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
                            color: _textMuted,
                          ),
                          textDirection: _isAr
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                        ),
                      ],
                    ),
                  ),

                  // R19-08: Mode-aware dhikr action area, all INSIDE card.
                  const SizedBox(height: 22),
                  Container(
                      height: 1,
                      color: AppColors.gold.withAlpha(40)),
                  const SizedBox(height: 22),

                  // Active (not yet resolved)
                  if (!_dhikrResolved) ...[
                    // R19-08c: First-time tutorial card (Explorer + Event 1)
                    if (_showDhikrTutorial)
                      _buildDhikrTutorialCard()
                    else if (PrefsService.isExplorerMode)
                      _buildExplorerActionArea()
                    else
                      _buildReaderActionArea(),
                  ],

                  // Resolved + hold actually completed
                  if (_dhikrResolved && _holdRingComplete) ...[
                    Icon(Icons.check_circle_rounded,
                        size: 48, color: AppColors.gold),
                    const SizedBox(height: 8),
                    Text(
                      PrefsService.isExplorerMode
                          ? (_isAr ? 'النور يتجدّد' : 'Light restored')
                          : (_isAr ? 'بارك الله فيك' : 'May Allah bless you'),
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                      textDirection:
                          _isAr ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  ],

                  // Resolved + Reader user tapped "I've said it"
                  if (_dhikrResolved && !_holdRingComplete && _saidItPressed) ...[
                    Icon(Icons.check_circle_rounded,
                        size: 40, color: AppColors.gold),
                    const SizedBox(height: 6),
                    Text(
                      _isAr ? 'بارك الله فيك' : 'May Allah bless you',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                      textDirection:
                          _isAr ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  ],

                  // Skipped: completely silent per R19-08 spec.
                  // (No "Skipped" text, no checkmark, no message — just
                  // proceed to Continue button.)
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  // R19-08c: First-time dhikr tutorial card. Replaces the action area
  // until tap or 4s timer, then dismissed.
  Widget _buildDhikrTutorialCard() {
    return GestureDetector(
      onTap: () {
        _dhikrTutorialTimer?.cancel();
        setState(() => _showDhikrTutorial = false);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.gold.withAlpha(18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withAlpha(80)),
        ),
        child: Column(
          children: [
            Icon(Icons.lightbulb_rounded,
                size: 24, color: AppColors.gold.withAlpha(200)),
            const SizedBox(height: 10),
            Text(
              _isAr
                  ? 'نورك يخفت كلما تقدّمت في الرحلة. الذكر هو ما يبقي نورك حيّاً. أمسك واقرأ: نورك يعتمد عليه.'
                  : 'Your light fades as you journey deeper. Dhikr is what keeps your نور alive. Hold and recite — your light depends on it.',
              textAlign: TextAlign.center,
              textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
              style: GoogleFonts.lora(
                fontSize: 13,
                color: _textWarm,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isAr ? 'اضغط للمتابعة' : 'Tap to continue',
              style: GoogleFonts.nunito(
                fontSize: 10,
                color: _textMuted,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // R19-08: Explorer Mode action area — hold ring is the hero (120px),
  // skip link below. No "I've said it" button (must hold).
  Widget _buildExplorerActionArea() {
    return Column(
      children: [
        Text(
          _isAr ? 'أمسك واقرأ' : 'Hold and recite',
          style: GoogleFonts.nunito(
            fontSize: 13,
            color: _textWarm,
            fontWeight: FontWeight.w600,
          ),
          textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
        ),
        const SizedBox(height: 16),
        _buildHoldRing(size: 120, ringSize: 110, strokeWidth: 6, iconSize: 48),
        // R26 S1v4-EE6.3: "Noor +50%" label removed. The old +50
        // rechargeNoor was deleted in v2-EE6; the only regen path is
        // now the tent-side dhikr at +25%. Keeping the copy here
        // misrepresents what happens — spec explicitly requires the
        // label gone.
        const SizedBox(height: 16),
        _buildSkipLink(),
      ],
    );
  }

  // R19-08b: Reader Mode action area — "I've said it" button is the hero.
  // B29: button + hold ring sized to parity with Explorer mode — dhikr is
  // equally important regardless of journey mode.
  Widget _buildReaderActionArea() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: _dhikrCelebrating ? null : _onSaidIt,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: const Color(0xFF0B1E2D),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(
              _isAr ? 'قلتها \u2713' : 'I\u2019ve said it \u2713',
              style: GoogleFonts.nunito(
                  fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          _isAr ? 'أو اقرأ معنا' : 'Or recite along',
          style: GoogleFonts.nunito(
            fontSize: 11,
            color: _textMuted,
            fontStyle: _isAr ? FontStyle.normal : FontStyle.italic,
          ),
        ),
        const SizedBox(height: 10),
        // B29: hold ring matches Explorer's 120/110/6/48 dimensions
        _buildHoldRing(size: 120, ringSize: 110, strokeWidth: 6, iconSize: 48),
        const SizedBox(height: 14),
        _buildSkipLink(),
      ],
    );
  }

  // Shared hold-ring widget — sized for either mode.
  Widget _buildHoldRing({
    required double size,
    required double ringSize,
    required double strokeWidth,
    required double iconSize,
  }) {
    return GestureDetector(
      onLongPressStart: (_) => _onHoldStart(),
      onLongPressEnd: (_) => _onHoldEnd(),
      onTapDown: (_) => _onHoldStart(),
      onTapUp: (_) => _onHoldEnd(),
      onTapCancel: () => _onHoldEnd(),
      child: AnimatedBuilder(
        animation: _holdRingCtrl,
        builder: (context, child) {
          return SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: ringSize,
                  height: ringSize,
                  child: CircularProgressIndicator(
                    value: _holdRingCtrl.value,
                    strokeWidth: strokeWidth,
                    backgroundColor: AppColors.gold.withAlpha(50),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.gold),
                  ),
                ),
                Icon(
                  _holdRingCtrl.value < 1.0
                      ? Icons.touch_app_rounded
                      : Icons.check_circle_rounded,
                  size: iconSize,
                  color: _holdRingCtrl.value < 1.0
                      ? AppColors.gold.withAlpha(200)
                      : AppColors.gold,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkipLink() {
    // R21B-07: Minimum 44px touch target so the skip link is
    // comfortable to tap on all devices.
    return GestureDetector(
      onTap: _onNotNow,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Text(
          _isAr ? 'تخطّي' : 'Skip',
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: _textMuted.withAlpha(200),
          ),
          textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
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
              color: _textWarm,
            ),
            textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
          ),
        ),
      ],
    );
  }

  // ── Section 6: Continue button ───────────────────────────────────────
  // B25: SizeTransition so the button grows from 0 height when revealed,
  // pushing content naturally — no pre-allocated blank space below dhikr.
  // R28-RFT-08 \u00B7 Screen A user-gated Continue. Spec offered "CTA or
  // swipe-up" \u2014 CTA chosen (clearer, no hidden-gesture cost). Shown
  // once the reflection beat (scroll + any dhikr) is done; advances
  // A\u2192B.
  Widget _buildAContinue() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _goToScreenB,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: const Color(0xFF0B1E2D),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: Text(
            _isAr ? '\u062A\u0627\u0628\u0639' : 'Continue',
            style: GoogleFonts.nunito(
                fontSize: 16, fontWeight: FontWeight.w800),
            textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
          ),
        ),
      ),
    );
  }

  // R28-RFT-08 \u00B7 Screen B "Rawi has just witnessed" caption \u2014 uses the
  // event's existing localized title (no new content).
  Widget _buildWitnessCaption() {
    final title = _isAr ? widget.event.titleAr : widget.event.title;
    return Column(
      children: [
        const SizedBox(height: 4),
        Text(
          _isAr
              ? '\u0631\u0623\u0649 \u0627\u0644\u0631\u0627\u0648\u064A:'
              : 'Rawi has just witnessed:',
          textAlign: TextAlign.center,
          textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
          style: GoogleFonts.nunito(
            color: AppColors.gold.withAlpha(200),
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
          style: GoogleFonts.cinzelDecorative(
            color: AppColors.gold,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  // R28-RFT-08 \u00B7 Screen B nav \u2014 two buttons, both contract-safe (exit
  // \u2192 tent; differ only in the Passage cinematic). SizeTransition +
  // FadeTransition on _continueFade so they grow in with no pre-
  // allocated blank space.
  Widget _buildBNav() {
    return SizeTransition(
      sizeFactor: _continueFade,
      axisAlignment: -1.0,
      child: FadeTransition(
        opacity: _continueFade,
        child: Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Column(
            children: [
              SizedBox(
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
                    textDirection:
                        _isAr ? TextDirection.rtl : TextDirection.ltr,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _canExit ? _returnToTent : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gold,
                    side: BorderSide(
                        color: AppColors.gold.withAlpha(120)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _isAr
                        ? '\u0627\u0644\u0639\u0648\u062F\u0629 \u0625\u0644\u0649 \u0627\u0644\u062E\u064A\u0645\u0629'
                        : 'Return to Tent',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    textDirection:
                        _isAr ? TextDirection.rtl : TextDirection.ltr,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
