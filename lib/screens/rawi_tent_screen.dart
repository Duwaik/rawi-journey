import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../data/dhikr_data.dart';
import '../data/m1_data.dart';
import '../models/journey_event.dart';
import '../models/rawi_stage.dart';
import '../services/audio_service.dart';
import '../services/prefs_service.dart';
import '../services/route_observer.dart';
import 'collection_gallery_screen.dart';
import 'dhikr_collection_screen.dart';
import 'event_launcher.dart';
import 'event_list_screen.dart';
import 'scroll_viewer_screen.dart';
import 'settings_screen.dart';
import 'tent_tutorial_screen.dart';
import '../widgets/rawi_dialog.dart';
import '../widgets/stat_row_group.dart';
import '../widgets/tent_icon_tutorial_overlay.dart';
import '../widgets/tent_info_tab.dart';

/// R22 Part 3 / R24 A-01 — Rawi's Tent V2 (cinematic campfire home).
///
/// Full-screen campfire scene with time-of-day backgrounds, right-side
/// navigation icons, center "Continue Journey" CTA, and bottom sheets
/// for Next Event / Daily Dhikr / Quick Settings.
class RawiTentScreen extends StatefulWidget {
  /// R28 S1-BUG1 / Navigation Contract: every push of the tent MUST be
  /// tagged with `RouteSettings(name: routeName)` so that
  /// `Navigator.popUntil(ModalRoute.withName(RawiTentScreen.routeName))`
  /// from inside any event reliably lands on the tent, regardless of
  /// which screen launched the event. Call sites in splash, unified
  /// completion, rawi call, scroll writing all use this constant.
  static const String routeName = '/tent';

  const RawiTentScreen({super.key});

  @override
  State<RawiTentScreen> createState() => _RawiTentScreenState();
}

class _RawiTentScreenState extends State<RawiTentScreen>
    with RouteAware, SingleTickerProviderStateMixin {
  bool get _isAr => PrefsService.isAr;
  String? _activeSheet;

  /// R27 S1.1-TENT5: true while the icon coach-mark overlay is
  /// rendering. Drives the conditional render at the end of the
  /// tent Stack. Flipped true by [_maybeShowIconTutorial] and
  /// false by the overlay's `onFinished` callback.
  bool _iconTutorialActive = false;

  /// R27 S1.2-TENT4: true while the tent tutorial cinematic is on
  /// top of the tent route. Drives AnimatedOpacity wrappers on the
  /// progress card + nav + info tab so the tent chrome fades to 0
  /// during the cinematic and back to 1 when it ends. The cinematic
  /// itself paints a dim scrim over the tent BG, so this flag
  /// handles the chrome layers the scrim doesn't reach (they'd
  /// otherwise block the "Tap to continue" hint at the bottom).
  bool _cinematicActive = false;

  /// R27 S1-TENT2 + S1.4-ANIM1: warm-light flicker over the campfire
  /// area of the tent BG. S1-TENT2 shipped this at 1200 ms period
  /// with base alphas 70 / 30 + opacity 0.82-1.0 + scale 0.95-1.06,
  /// which was imperceptible on device (Khaled reported "no animation,
  /// none" during S1.3 verify). Amplified to 900 ms period + base
  /// alphas 120 / 60 + opacity 0.70-1.0 + scale 0.92-1.12 — still
  /// subtle enough to read as breathing, not a strobe.
  late final AnimationController _firelightCtrl;

  String _tentScenePath() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 7) return 'assets/scenes/tent_dawn.jpg';
    if (hour >= 7 && hour < 17) return 'assets/scenes/tent_day.jpg';
    if (hour >= 17 && hour < 20) return 'assets/scenes/tent_dusk.jpg';
    return 'assets/scenes/tent_night.jpg';
  }

  /// R25-S2-6: Static salaam greeting with the user's name inline.
  /// No time-of-day variants. Empty-name falls back to bare salaam
  /// (no trailing comma) per spec §7 deferred handling.
  ///
  /// R25-S3-HF-5: safety-net capitalize the first letter at render
  /// time so users who registered before the setter-side fix landed
  /// still see "Khaled" instead of "khaled". Future registrations are
  /// already cased in PrefsService.setUserName.
  String get _greeting {
    final raw = PrefsService.userName.trim();
    final name = raw.isEmpty
        ? raw
        : raw[0].toUpperCase() + raw.substring(1);
    if (_isAr) {
      return name.isEmpty
          ? 'السلام عليكم'
          : 'السلام عليكم، $name';
    }
    return name.isEmpty
        ? 'Assalamu Alaykom'
        : 'Assalamu Alaykom, $name';
  }

  int get _completedCount {
    int c = 0;
    // B-01 pattern: count ALL completions (no sequential break).
    for (final e in m1Events) {
      if (PrefsService.isEventCompleted(e.globalOrder)) c++;
    }
    return c;
  }

  /// R26 S1-T2: true when the last-launched event is flagged in-progress
  /// in PrefsService. Drives the tent's primary button label
  /// (Start → Continue) and the direct-resume routing below. This
  /// replaces the older heuristic that peeked at hotspot progress of
  /// the "next uncompleted" item — which mis-fired for users who
  /// backed out of an event before discovering any hotspot.
  bool _hasInProgressNextItem() {
    if (!PrefsService.isEventInProgress) return false;
    final id = PrefsService.lastEventId;
    if (id == null || id.isEmpty) return false;
    // Safety: if the stored ID no longer exists in m1 (spec drift,
    // dev resets), ignore and fall back to Start.
    return m1Events.any((e) => e.id == id);
  }

  /// R26 S1-T2: the JourneyEvent the Continue button should route to,
  /// or null if no in-progress event is recorded.
  JourneyEvent? _inProgressEvent() {
    final id = PrefsService.lastEventId;
    if (id == null || id.isEmpty) return null;
    for (final e in m1Events) {
      if (e.id == id) return e;
    }
    return null;
  }

  /// R25-S1-2: title of the current progression item — event OR threshold.
  /// When a threshold is pending before the next event, the progress card
  /// shows the threshold so the user knows what Start will actually launch.
  ///
  /// R26 S1-T2: when an in-progress event is flagged, the title reflects
  /// THAT event (not the next uncompleted), so the Continue button's
  /// label + title + route all point at the same thing.
  String _nextItemTitle(bool isComplete) {
    if (isComplete) {
      return _isAr ? 'اكتملت الرحلة' : 'Journey complete';
    }
    if (PrefsService.isEventInProgress) {
      final ev = _inProgressEvent();
      if (ev != null) return _isAr ? ev.titleAr : ev.title;
    }
    final item = currentProgressionItem();
    if (item is ThresholdItem) {
      return _isAr ? 'العتبة' : 'The Threshold';
    }
    if (item is EventItem) {
      return _isAr ? item.event.titleAr : item.event.title;
    }
    return _isAr ? 'اكتملت الرحلة' : 'Journey complete';
  }

  @override
  void initState() {
    super.initState();
    _firelightCtrl = AnimationController(
      vsync: this,
      // R27 S1.4-ANIM1: 1200 → 900 ms. Shorter period reads as
      // breathing rather than static at the new amplitude.
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _startTentAmbient();
    // R27 S1-TENT1 + S1.1-TENT4: first-visit tent tutorial cinematic.
    //
    // v1 fired the cinematic immediately on a black backdrop — user
    // saw gold text saying "Welcome to your tent" without ever seeing
    // the tent first. New sequence:
    //   1. User arrives at tent, sees it for 1s (anchor beat — fire
    //      ambient plays, flame flickers).
    //   2. TentTutorialScreen pushes as non-opaque route. It paints
    //      its own 0 → 0.50 dim scrim over the (still-visible) tent,
    //      then fades text in and accepts tap-to-advance.
    //   3. On final-screen advance, dim lifts, route pops.
    //   4. If the icon coach-mark tutorial hasn't been seen either,
    //      it fires immediately (see [_maybeShowIconTutorial]).
    //
    // Gated by BOTH pref flags: either tutorial still pending means
    // we still do the settle-beat work. Cinematic writes its flag on
    // FIRST tap (not final-screen) so a force-quit doesn't replay it.
    if (!PrefsService.isTentTutorialShown ||
        !PrefsService.isTentIconTutorialShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          if (!PrefsService.isTentTutorialShown) {
            // R27 S1.2-TENT4: flip the flag BEFORE pushing so the
            // tent chrome's AnimatedOpacity starts fading out while
            // the route transition + cinematic dim are landing —
            // chrome, dim, and text all coming into place together.
            setState(() => _cinematicActive = true);
            Navigator.of(context).push(
              PageRouteBuilder(
                opaque: false,
                transitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (ctx, anim, sec) => FadeTransition(
                  opacity: anim,
                  child: TentTutorialScreen(
                    onComplete: () {
                      if (!mounted) return;
                      Navigator.of(context).pop();
                      // Chrome fades BACK in now that the cinematic
                      // is done. Then the icon coach-mark takes over
                      // and paints its own dim + highlights.
                      setState(() => _cinematicActive = false);
                      _maybeShowIconTutorial();
                    },
                  ),
                ),
              ),
            );
          } else {
            // Cinematic already seen on a prior launch — go straight
            // to the icon tutorial if it hasn't been seen yet.
            _maybeShowIconTutorial();
          }
        });
      });
    }
  }

  /// R27 S1.1-TENT5: fires the sequential icon coach-mark tutorial
  /// over the tent's right-side nav. Called from the cinematic's
  /// onComplete callback (fresh install) or directly from initState
  /// when the cinematic flag is already set but this one isn't.
  void _maybeShowIconTutorial() {
    if (PrefsService.isTentIconTutorialShown) return;
    if (!mounted) return;
    // Brief breath so the cinematic's dim has fully lifted before
    // the coach-mark's own scrim lands.
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      if (PrefsService.isTentIconTutorialShown) return;
      setState(() => _iconTutorialActive = true);
    });
  }

  /// R26 S1v2-T2: subscribe to route lifecycle so the tent re-reads
  /// progress prefs the moment it becomes active again (e.g., user
  /// backs out of the event scene). Without this the Continue button
  /// label stays stale until the app is cold-restarted.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _firelightCtrl.dispose();
    super.dispose();
  }

  /// Fires when the tent becomes the top route again after a pop
  /// (event scene → back → tent). Pull the prefs and rebuild so the
  /// Start/Continue button + next-item title reflect the latest state.
  ///
  /// R27 S1.4-AUDIO1 + S1.5-AUDIO1: also fade the tent fire ambient
  /// back in (300 ms ramp 0 → 0.14). Previously the ambient hard-cut
  /// back to target volume on return; now it envelopes gracefully.
  /// `playAmbient` with `fadeInDuration` handles both cases — if tent
  /// fire is still current (fast bounce), it ramps volume back up; if
  /// another screen took over, it fades out previous + starts at 0
  /// and ramps to target.
  @override
  void didPopNext() {
    if (!mounted) return;
    setState(() {});
    _startTentAmbient();
  }

  /// R27 S3-AUDIO1: tent fire is now the ambient of the whole tent
  /// CLUSTER (tent + Events List + Scroll + Dhikr + Collections + Stars
  /// + Settings), not just this screen. So `didPushNext` no longer
  /// touches the ambient — the fire keeps crackling uninterrupted when
  /// the user crosses over to a sibling screen.
  ///
  /// Who fades the ambient when it SHOULD go quiet?
  ///   - Event entry: `event_intro_screen.dart` already calls
  ///     `AudioService.fadeOut(duration: 800ms)` in its initState. Tent
  ///     ambient fades out there, on the way INTO an event — not here.
  ///   - Event exit: `_exitScene()` in `immersive_event_screen.dart`
  ///     calls `fadeOut(250ms)`. Tent's `didPopNext` then ramps the
  ///     fire back in via `_startTentAmbient()`.
  ///
  /// The S1.5 behaviour (fade to 0 on any push, keep player alive for
  /// fast bounce-back) is superseded — `playAmbient` is idempotent on
  /// the same path, so bouncing tent → events list → tent costs nothing.
  @override
  void didPushNext() {
    // Intentionally empty. See doc comment above.
  }

  /// B13 + R27 S1.5-AUDIO1: Campfire ambient on the tent, looping.
  /// 300 ms fade-in envelope (0 → 0.14) smooths the landing — avoids
  /// the hard audible cut that S1.4 shipped. Falls back to
  /// ambient_intro.mp3 if the fire track is missing.
  Future<void> _startTentAmbient() async {
    const fade = Duration(milliseconds: 300);
    final ok = await AudioService.playAmbient(
      'assets/audio/ambient/ambient_tent_fire.mp3',
      volume: 0.14,
      fadeInDuration: fade,
    );
    if (!ok) {
      await AudioService.playAmbient(
        'assets/audio/ambient/ambient_intro.mp3',
        volume: 0.12,
        fadeInDuration: fade,
      );
    }
  }

  void _closeSheet() => setState(() => _activeSheet = null);

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final screenH = MediaQuery.of(context).size.height;
    final completed = _completedCount;
    final isComplete = completed >= m1Events.length;
    // R25-S2-4: Continue vs Start — true when the next event has any
    // recorded hotspot progress (saved mid-event). Threshold items are
    // always Start (no in-progress concept).
    final isContinue = _hasInProgressNextItem();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        // R27 S3-TENT1: Android back on the tent no longer slams the
        // app shut — gate on a confirmation dialog first. Cancel keeps
        // the user on the tent; Exit closes cleanly via SystemNavigator.
        // Sub-screens (Scroll, Events List, Dhikr, etc.) don't trigger
        // this — PopScope is scoped to the tent route, so their back
        // presses pop to tent via normal navigation.
        // R28 HF3-DIALOG1: dropped the parenthetical "(your progress
        // is saved)" body line. Dialog now renders just title +
        // Cancel/Exit. Save-on-back behaviour is unchanged — the line
        // was reassurance, not the actual save mechanism.
        final confirmed = await showRawiDialog(
          context: context,
          title: _isAr ? 'هل تريد الخروج من التطبيق؟' : 'Exit app?',
          cancelLabel: _isAr ? 'إلغاء' : 'Cancel',
          confirmLabel: _isAr ? 'خروج' : 'Exit',
          isAr: _isAr,
        );
        if (confirmed == true) {
          SystemNavigator.pop();
        }
      },
      // R25-S2-7: clamp system text scaler to [1.0, 1.3] at the tent
      // root. Android accessibility can push scaling to 2.0× which
      // breaks the layout; the design tolerates up to 1.3×.
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: MediaQuery.textScalerOf(context).clamp(
            minScaleFactor: 1.0,
            maxScaleFactor: 1.3,
          ),
        ),
        child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── Scene background (time-of-day) ───────────────────────
            Image.asset(
              _tentScenePath(),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF05080F), Color(0xFF1A1510)],
                  ),
                ),
              ),
            ),

            // ── R27 S1-TENT2: firelight flicker overlay ──────────────
            // Warm amber radial glow centered on the campfire region of
            // the tent BG. Opacity + scale breathe on a 1200 ms sine
            // loop driven by _firelightCtrl. Non-destructive — the BG
            // JPG is unchanged, this is an overlay layer.
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _firelightCtrl,
                  builder: (context, _) {
                    // R27 S1.4-ANIM1: amplitudes widened.
                    // opacity: 0.82-1.0 → 0.70-1.0  (range 18% → 30%)
                    // scale:   0.95-1.06 → 0.92-1.12 (range 11% → 20%)
                    // base alphas in gradient: 70/30 → 120/60 so the
                    // glow itself is visible enough for the pulse to
                    // register on bright tent_day.jpg.
                    final v = _firelightCtrl.value;
                    final opacity = 0.70 + v * 0.30;
                    final scale = 0.92 + v * 0.20;
                    return Align(
                      alignment: const Alignment(0.0, 0.55),
                      child: Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: opacity,
                          child: Container(
                            width: 260,
                            height: 260,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFFFFA040).withAlpha(120),
                                  const Color(0xFFFF7020).withAlpha(60),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.45, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // B5: Rawi figure circle removed — character is already in the
            // tent visual, a separate avatar circle is redundant.

            // ── Greeting (top center) ────────────────────────────────
            // R25-S2-6: single-line inline greeting "Assalamu Alaykom,
            // {name}" / "السلام عليكم، {name}". Rank subtitle unchanged.
            // R27 S1.2-TENT4: wrapped in AnimatedOpacity keyed on
            // `_cinematicActive` so the greeting fades out during the
            // tent tutorial cinematic (otherwise it sits on top of the
            // dim scrim and steals focus).
            Positioned(
              top: topPad + 40,
              left: 16, right: 16,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: _cinematicActive ? 0.0 : 1.0,
                child: Column(
                children: [
                  Text(
                    _greeting,
                    textAlign: TextAlign.center,
                    textDirection:
                        _isAr ? TextDirection.rtl : TextDirection.ltr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      color: const Color(0xFFE8D8B8),
                      fontSize: _isAr ? 16 : 15,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 2),
                          blurRadius: 8,
                          color: Colors.black.withAlpha(153),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    // B21: age + gender based rank title
                    RawiStage.ageGenderTitle(
                      age: PrefsService.userAge,
                      gender: PrefsService.userGender,
                      isAr: _isAr,
                    ),
                    style: GoogleFonts.lora(
                      color: AppColors.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ],
                ),
              ),
            ),

            // R27 S1.2-TENT1: the standalone top-left stat pills block
            // (shipped in R25-S2-1/S2-2, Positioned at top: 0.22, left: 10
            // with _buildStatPillsContainer) is DELETED. Those pills
            // now live inside the tent info tab's expanded state —
            // one tappable widget replaces two always-visible blocks,
            // letting the Rawi figure + fire be the hero.

            // ── Right-side navigation (5 slots) ──────────────────────
            // R28 S1-NAV1: Stars icon removed (absorbed by the Events
            // List → CONSTELLATION view in FEAT1/2). Collections moved
            // up (was position 5). Living Map placeholder takes the
            // freed slot 5 as a reserved "coming soon" — dimmed, no
            // screen wired yet, tap shows a snackbar.
            //
            // New order (top → bottom):
            //   1. Events List
            //   2. Rawi's Scroll
            //   3. Collections
            //   4. Dhikr (stays — Collections 3-tab not ready yet;
            //      removing Dhikr now would strand the collection.
            //      Per locked rule from the R28-S1 spec.)
            //   5. Living Map placeholder ("coming soon")
            //
            // Settings gear stays in the top-right corner (unchanged).
            // R27 S1.2-TENT4: nav column fades during cinematic so
            // the right edge of the screen is dim + empty while the
            // tutorial plays; no icon taps can land mid-tutorial
            // even if the user tries.
            if (_activeSheet == null)
              Positioned(
                top: screenH * 0.28,
                right: 10,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: _cinematicActive ? 0.0 : 1.0,
                  child: Column(
                  children: [
                    // 1. Events List
                    // R27 S1-TENT3: Material icon instead of 📋 emoji.
                    _navIconMaterial(
                        Icons.view_list_rounded,
                        _isAr ? 'الأحداث' : 'Events', () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const EventListScreen()));
                    }),
                    const SizedBox(height: 8),
                    // 2. Rawi's Scroll
                    _navIcon('📜', _isAr ? 'السجلّ' : 'Scroll', () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const ScrollViewerScreen()));
                    }),
                    const SizedBox(height: 8),
                    // 3. Collections
                    _navIcon('🏛️', _isAr ? 'المجموعات' : 'Collections', () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const CollectionGalleryScreen()));
                    }),
                    const SizedBox(height: 8),
                    // 4. Dhikr
                    _navIcon('🤲', _isAr ? 'الذكر' : 'Dhikr', () {
                      // B10: full dhikr collection screen (Dhikr of the Day
                      // + all unlocked + locked silhouettes).
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const DhikrCollectionScreen()));
                    }),
                    const SizedBox(height: 8),
                    // 5. Living Map placeholder (R28 S1-NAV1 — coming soon)
                    _navIconPlaceholder(
                      Icons.explore_outlined,
                      _isAr ? 'قريباً' : 'Coming soon',
                      _isAr
                          ? 'الخريطة الحيّة قريباً'
                          : 'Living Map is coming soon',
                    ),
                  ],
                  ),
                ),
              ),

            // ── Settings gear (top-right corner, 30x30, glass) ──────
            // R27 S1.2-TENT4: fades during cinematic.
            if (_activeSheet == null)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 12,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: _cinematicActive ? 0.0 : 1.0,
                  child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const SettingsScreen())),
                  child: Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withAlpha(90),
                      border: Border.all(
                          color: AppColors.gold.withAlpha(70)),
                    ),
                    child: const Icon(Icons.settings_rounded,
                        size: 16, color: AppColors.gold),
                  ),
                  ),
                ),
              ),

            // B8/B19/B20: standalone Continue Journey CTA removed.
            // R25-S2-3: "Your Journey" / "رحلتك" label removed — the
            // progress card's event title is already the hero.

            // ── Progress card (bottom, integrated CTA) ───────────────
            // R27 S1.2-TENT4: wrapped in AnimatedOpacity so the card
            // (and the "Tap to continue" cinematic hint that sits at
            // the same vertical position) don't compete during the
            // tutorial. Spec option B — hide chrome during cinematic,
            // restore after. Fade synced with the tent dim + route
            // transition via the shared `_cinematicActive` flag.
            if (_activeSheet == null)
              Positioned(
                bottom: bottomPad + 16,
                left: 16, right: 16,
                // B8: progress card is the single tappable action zone.
                // Row: current/next event name + Start/Continue label.
                // Progress count uses matched sizes (no big/small split).
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: _cinematicActive ? 0.0 : 1.0,
                  child: GestureDetector(
                  // R25-S1-1 / S1-2: launch the current progression item
                  // directly — threshold → ThresholdScreen, event →
                  // VideoIntroScreen / EventIntroScreen / ImmersiveEventScreen.
                  // No events-list interstitial, no flash, no audio bleed.
                  //
                  // R26 S1-T2: when an in-progress event is flagged,
                  // Continue routes directly to THAT event (not the
                  // next uncompleted in sequence). The event scene's
                  // own state rehydrates from loadHotspotProgress so
                  // the user lands at the saved HS position.
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    if (isComplete) {
                      await Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const EventListScreen()));
                      return;
                    }
                    if (isContinue) {
                      final resumeEvent = _inProgressEvent();
                      if (resumeEvent != null) {
                        await launchEvent(context, resumeEvent);
                        if (!mounted) return;
                        setState(() {});
                        return;
                      }
                    }
                    await launchCurrentItem(context);
                    if (!mounted) return;
                    // Refresh so the progress card reflects the new state
                    // after threshold / event completion.
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(185),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.gold.withAlpha(90), width: 1.4),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.gold.withAlpha(20),
                            blurRadius: 18),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // R25-S2-5: title centered above button row
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            isComplete
                                ? (_isAr
                                    ? 'اكتملت الرحلة ✦'
                                    : 'Journey complete ✦')
                                : _nextItemTitle(isComplete),
                            textAlign: TextAlign.center,
                            textDirection: _isAr
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            style: GoogleFonts.nunito(
                              color: const Color(0xFFE8D8B8),
                              fontSize: _isAr ? 14 : 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // R27 S1-TENT5: button + counter centered as a
                        // unit (was spaceBetween, which spread them to
                        // the card's outer edges). Same 14 px gap
                        // between them as before — the container is
                        // just no longer stretched. Counter is bold
                        // now so it reads as a primary metric.
                        // R27 S1.2-TENT6: half-and-half centered layout.
                        // Each element sits at the visual center of its
                        // 50% slice — button in the left half, counter
                        // in the right half. Replaces S1.1-TENT3's
                        // "move both inward + fixed gap" approach with a
                        // clean geometric split. `Expanded` gives each
                        // child a matching flex of 1; the `Center`
                        // inside each Expanded horizontally centers the
                        // element in its slice. AR RTL swaps the
                        // children order via the Row's textDirection —
                        // counter on left, button on right in Arabic
                        // locale (still centered in their own halves).
                        if (!isComplete)
                          Row(
                            textDirection: _isAr
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            children: [
                              Expanded(
                                child: Center(
                                  child: _buildStartContinueButton(
                                      isContinue),
                                ),
                              ),
                              // R27 S1.4-PROG1: gold-outlined pill
                              // around the number (matches Start/Continue
                              // button's border vocabulary).
                              // R27 S1.5-PROG1: explicit `height: 40`
                              // locked to match the button's height —
                              // no more baseline drift between the two
                              // halves of the card. Padding only
                              // horizontal now that height is forced;
                              // text centers via Alignment.center.
                              Expanded(
                                child: Center(
                                  child: Container(
                                    height: 40,
                                    padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 14),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.gold.withAlpha(20),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                      border: Border.all(
                                          color: AppColors.gold,
                                          width: 1.5),
                                    ),
                                    child: Text(
                                      '$completed / ${m1Events.length}',
                                      style: GoogleFonts.nunito(
                                        color: const Color(0xFFF0D070),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        // R27 S1-TENT5: progress bar 2 → 8 px, radius
                        // bumped to circular(4) so it stays a clean
                        // pill at the taller height. Colors unchanged.
                        const SizedBox(height: 11),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (completed / m1Events.length)
                                .clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: AppColors.gold.withAlpha(26),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.gold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ),
                ),
              ),

            // ── R27 S1.1-TENT1 + S1.2-TENT1: tent info tab ───────────
            // Single consolidated widget. Expanded content = the
            // three stat pills (Light / XP / Dhikr) that used to
            // live in the now-deleted top-left standalone block.
            // Positioned.fill so the internal scrim covers the full
            // tent when expanded (R26 S1v3-EE8.2 gesture pattern).
            // Hidden while a bottom sheet is open so the two scrims
            // don't fight, AND while the cinematic is on top — the
            // cinematic paints its own dim and we don't want the
            // info-tab gesture layer swallowing the tutorial tap.
            if (_activeSheet == null && !_cinematicActive)
              Positioned.fill(
                child: TentInfoTab(
                  expandedContent: _buildInfoTabStatRows(completed),
                ),
              ),

            // ── Bottom sheets (R24 A-03: full dismiss) ───────────────
            if (_activeSheet != null)
              _buildSheetOverlay(
                child: _activeSheet == 'next'
                    ? _nextEventContent(completed)
                    : _activeSheet == 'dhikr'
                        ? _dhikrContent(completed)
                        : const SizedBox.shrink(),
              ),

            // ── R27 S1.1-TENT5: icon coach-mark overlay ─────────────
            // Rendered last so it sits above everything else in the
            // tent (nav icons, info tab, progress card). The overlay
            // absorbs every tap itself, so nothing underneath fires
            // while it's visible.
            if (_iconTutorialActive)
              TentIconTutorialOverlay(
                onFinished: () {
                  if (mounted) {
                    setState(() => _iconTutorialActive = false);
                  }
                },
              ),
          ],
        ),
      ),
      ),
    );
  }

  // ── Navigation icon ──────────────────────────────────────────────────
  //
  // R25-S3-HF-4: Icon-only. Labels removed per device feedback — the
  // 7px labels were getting truncated ("Collectio") at larger font
  // scales and the label parameter is kept for API stability /
  // tooltips only. Button shrank 52→44 to match 44dp tap-target min.

  Widget _navIcon(String icon, String label, VoidCallback onTap) {
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44, height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(180),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gold.withAlpha(40)),
          ),
          child: Text(icon, style: const TextStyle(fontSize: 22)),
        ),
      ),
    );
  }

  /// R27 S1-TENT3: same frame as [_navIcon], but renders a Material
  /// IconData instead of an emoji string. Introduced so the Events
  /// List slot can use `Icons.view_list_rounded` — the old 📋 emoji
  /// didn't read as "list" and clustered visually with 📜 / 🏛️.
  Widget _navIconMaterial(
      IconData icon, String label, VoidCallback onTap) {
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44, height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(180),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gold.withAlpha(40)),
          ),
          child: Icon(icon, size: 22, color: AppColors.gold),
        ),
      ),
    );
  }

  /// R28 S1-NAV1 / R28 HF3-LMAP1: "coming soon" placeholder slot.
  ///
  /// Frame shape matches [_navIconMaterial] (44 px, 12 px radius) but
  /// the fill + border + icon read as **outlined / muted** instead of
  /// active. R28-S1's first pass used `Colors.black.withAlpha(120)` +
  /// faint gold border (alpha 20) which on the A56's dark scene BG
  /// rendered as a "black bar" — the dark fill blended into the
  /// background and the icon (alpha 115) was too dim to anchor the
  /// shape as a recognisable slot.
  ///
  /// HF3-LMAP1 swaps the fill from translucent-black to a barely-there
  /// gold wash (alpha 10), bumps the border to a clearly-visible gold
  /// outline (alpha 70, 1.2 px), and brightens the icon to alpha 150 —
  /// readable but still subordinate to the active nav icons (alpha 255
  /// on the gold). Net result: outlined ghost-button silhouette, dim
  /// compass icon visible, clearly placeholder-not-active.
  ///
  /// Tap shows a short snackbar explaining the slot — doesn't navigate,
  /// doesn't crash. Used for the Living Map slot which is reserved for
  /// a future sprint but has no screen wired yet.
  Widget _navIconPlaceholder(
      IconData icon, String tooltipLabel, String snackbarMessage) {
    return Tooltip(
      message: tooltipLabel,
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                duration: const Duration(seconds: 2),
                backgroundColor: const Color(0xF00E1624),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.gold.withAlpha(60)),
                ),
                content: Text(
                  snackbarMessage,
                  textAlign: TextAlign.center,
                  textDirection:
                      _isAr ? TextDirection.rtl : TextDirection.ltr,
                  style: GoogleFonts.nunito(
                    color: AppColors.gold.withAlpha(220),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
        },
        child: Container(
          width: 44, height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.gold.withAlpha(10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.gold.withAlpha(70),
              width: 1.2,
            ),
          ),
          child: Icon(icon, size: 22, color: AppColors.gold.withAlpha(150)),
        ),
      ),
    );
  }

  /// R25-S3-8: tent's 3-pill stat container now consumes the shared
  /// StatRowGroup widget. Same widget + data flow as the event-scene
  /// info tab (S3-6) — fixes the S2-1 / S2-2 invisibility bug by
  /// retiring the bespoke inline row rendering that was being drawn
  /// but not visually registering against certain scene-art backgrounds.
  ///
  /// Reader mode still swaps the XP value→events-completed count (B11).
  /// Labels stay constant across modes (S3-5 consolidation).
  /// R27 S1.2-TENT1: builds the three Light / XP / Dhikr rows that
  /// render inside the tent info tab's expanded panel. Replaces the
  /// old `_buildStatPillsContainer` whose chrome (SizedBox width 155,
  /// ClipRRect, BackdropFilter, Container decoration) is redundant
  /// now that the info tab's panel already provides blur + gold
  /// border + dark fill. Returning just the StatRowGroup keeps the
  /// expanded-panel content clean and lets TentInfoTab own the frame.
  Widget _buildInfoTabStatRows(int completed) {
    final explorer = PrefsService.isExplorerMode;
    final statRows = <StatRow>[
      StatRow(
        icon: Icons.auto_awesome_rounded,
        label: 'Light',
        labelAr: 'النور',
        value: '${PrefsService.noorLevel}%',
      ),
      StatRow(
        icon: Icons.bolt_rounded,
        label: explorer ? 'XP' : 'Events',
        labelAr: explorer ? 'الخبرة' : 'الأحداث',
        value: explorer ? '${PrefsService.xp}' : '$completed',
      ),
      StatRow(
        icon: Icons.pan_tool_alt_rounded,
        label: 'Dhikr',
        labelAr: 'الذكر',
        value: '${PrefsService.dhikrCompletedCount}',
      ),
    ];
    return StatRowGroup(rows: statRows, showDividers: true);
  }

  /// R25-S2-4: Start / Continue button. Same generous padding in both
  /// states so the card doesn't shift when the label swaps. Label only,
  /// no icon, no number badge.
  Widget _buildStartContinueButton(bool isContinue) {
    // R27 S1-TENT5: gold-filled primary CTA (was outlined translucent).
    //
    // R27 S1.1-TENT3: fixed width so "Start"/"ابدأ" (short) and
    // "Continue"/"متابعة" (longer) render at IDENTICAL widths. Flipping
    // between states causes zero row reflow now — previously the row
    // jittered when a fresh install (Start) turned into a mid-event
    // resume (Continue) with its longer label. The width is sized to
    // fit "Continue" at 13 px w800 + 32 px horizontal padding on each
    // side ≈ 128 px. AR "متابعة" lands comfortably inside the same box.
    final label = isContinue
        ? (_isAr ? 'متابعة' : 'Continue')
        : (_isAr ? 'ابدأ' : 'Start');
    // R27 S1.5-PROG1: explicit `height: 40` so the button and the
    // #/155 outlined pill (same height below) render at identical
    // heights regardless of label length or text-scale setting.
    return SizedBox(
      width: 128,
      height: 40,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isContinue
              ? [
                  BoxShadow(
                      color: AppColors.gold.withAlpha(60),
                      blurRadius: 12,
                      spreadRadius: 1),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            color: const Color(0xFF0B1E2D),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
          textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
        ),
      ),
    );
  }

  // ── Sheet overlay (R24 A-03: tap outside + swipe to dismiss) ─────────

  Widget _buildSheetOverlay({required Widget child}) {
    return GestureDetector(
      onTap: _closeSheet,
      child: Container(
        color: Colors.black.withAlpha(80),
        child: Column(
          children: [
            // Tappable dim area above sheet
            const Expanded(child: SizedBox()),
            // Sheet (absorb taps + swipe to dismiss)
            GestureDetector(
              onTap: () {}, // absorb taps on sheet
              onVerticalDragEnd: (d) {
                if (d.primaryVelocity != null && d.primaryVelocity! > 300) {
                  _closeSheet();
                }
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xF80A101C), Color(0xFE080C16)],
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border(
                    top: BorderSide(color: AppColors.gold.withAlpha(50)),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                    20, 12, 20, MediaQuery.of(context).padding.bottom + 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _closeSheet,
                      child: Container(
                        width: 36, height: 4,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withAlpha(60),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    child,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sheet contents ───────────────────────────────────────────────────

  Widget _nextEventContent(int completed) {
    if (completed >= m1Events.length) {
      return Text(
        _isAr ? 'اكتملت الرحلة' : 'Journey complete',
        style: GoogleFonts.lora(
            color: AppColors.gold, fontSize: 16, fontWeight: FontWeight.w600),
      );
    }
    final event = m1Events[completed];
    return Column(
      children: [
        Text(
          _isAr ? 'الحدث التالي' : 'NEXT EVENT',
          style: GoogleFonts.nunito(
            color: AppColors.gold.withAlpha(130),
            fontSize: 9, letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isAr ? event.titleAr : event.title,
          textAlign: TextAlign.center,
          textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
          style: GoogleFonts.nunito(
            color: AppColors.textPrimary,
            fontSize: 16, fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_isAr ? event.locationAr : event.location} · ${event.year} CE',
          style: GoogleFonts.nunito(
            color: AppColors.textMuted, fontSize: 11,
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const EventListScreen()));
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.gold.withAlpha(30),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gold.withAlpha(90)),
            ),
            child: Text(
              _isAr ? 'ابدأ' : 'Start',
              style: GoogleFonts.nunito(
                color: AppColors.gold,
                fontSize: 12, fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dhikrContent(int completed) {
    final card =
        completed > 0 ? dhikrCards[m1Events[completed - 1].id] : null;
    return Column(
      children: [
        Text(
          _isAr ? 'ذكر اليوم' : "TODAY'S DHIKR",
          style: GoogleFonts.nunito(
            color: AppColors.gold.withAlpha(130),
            fontSize: 9, letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          card != null ? card.arabicText : 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.amiri(
            color: AppColors.gold,
            fontSize: 20, height: 1.8,
          ),
        ),
        if (card != null) ...[
          const SizedBox(height: 6),
          Text(
            card.transliteration,
            style: GoogleFonts.nunito(
              color: AppColors.textMuted, fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isAr ? 'أمسك واقرأ' : 'Hold and recite',
            style: GoogleFonts.nunito(
              color: AppColors.gold.withAlpha(130), fontSize: 9,
            ),
          ),
        ],
      ],
    );
  }
}
