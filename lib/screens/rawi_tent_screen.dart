import 'dart:ui' show ImageFilter;

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
import 'collection_gallery_screen.dart';
import 'dhikr_collection_screen.dart';
import 'event_launcher.dart';
import 'event_list_screen.dart';
import 'scroll_viewer_screen.dart';
import 'seerah_sky_screen.dart';
import 'settings_screen.dart';
import '../widgets/stat_row_group.dart';

/// R22 Part 3 / R24 A-01 — Rawi's Tent V2 (cinematic campfire home).
///
/// Full-screen campfire scene with time-of-day backgrounds, right-side
/// navigation icons, center "Continue Journey" CTA, and bottom sheets
/// for Next Event / Daily Dhikr / Quick Settings.
class RawiTentScreen extends StatefulWidget {
  const RawiTentScreen({super.key});

  @override
  State<RawiTentScreen> createState() => _RawiTentScreenState();
}

class _RawiTentScreenState extends State<RawiTentScreen> {
  bool get _isAr => PrefsService.isAr;
  String? _activeSheet;

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
    _startTentAmbient();
  }

  /// B13: Campfire ambient on the tent, looping. Fades in via playAmbient's
  /// built-in cross-fade. Falls back to ambient_intro.mp3 until Khaled
  /// provides the fire track (asset may be missing — try/catch handles it).
  Future<void> _startTentAmbient() async {
    final ok = await AudioService.playAmbient(
      'assets/audio/ambient/ambient_tent_fire.mp3',
      volume: 0.14,
    );
    if (!ok) {
      await AudioService.playAmbient(
        'assets/audio/ambient/ambient_intro.mp3',
        volume: 0.12,
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
        SystemNavigator.pop();
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

            // B5: Rawi figure circle removed — character is already in the
            // tent visual, a separate avatar circle is redundant.

            // ── Greeting (top center) ────────────────────────────────
            // R25-S2-6: single-line inline greeting "Assalamu Alaykom,
            // {name}" / "السلام عليكم، {name}". Rank subtitle unchanged.
            Positioned(
              top: topPad + 40,
              left: 16, right: 16,
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

            // ── R25-S2-1/S2-2: Stat pills container (left side) ──────
            // Three rows: Light, XP, Dhikr. Labels are constant across
            // modes (S3-5 / S3-HF-7 consolidation — Light is always
            // "Your Light" / "نورك", never "Knowledge"). Reader mode
            // still swaps XP value → events-completed count (B11).
            // Single container with faint gold dividers and backdrop blur.
            //
            // Device-test fix (Apr 19): original spec top: 0.44 landed on
            // the hooded figure's body in tent_day.jpg — the 0.55-alpha
            // pill had zero contrast against the dark robes and appeared
            // invisible. Moved to top: 0.22 so it sits in the sunrise sky
            // just below the greeting, above the figure.
            Positioned(
              top: screenH * 0.22,
              left: 10,
              child: _buildStatPillsContainer(completed),
            ),

            // ── Right-side navigation (5 square icons) ───────────────
            // B5: nav stack = 5 icons (Events, Stars, Scroll, Dhikr,
            // Collections). Settings moved OUT of nav stack to its own
            // gear in the top-right corner (consistent with event screens).
            if (_activeSheet == null)
              Positioned(
                top: screenH * 0.28,
                right: 10,
                child: Column(
                  children: [
                    _navIcon('📋', _isAr ? 'الأحداث' : 'Events', () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const EventListScreen()));
                    }),
                    const SizedBox(height: 8),
                    _navIcon('✦', _isAr ? 'النجوم' : 'Stars', () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const SeerahSkyScreen()));
                    }),
                    const SizedBox(height: 8),
                    _navIcon('📜', _isAr ? 'السجلّ' : 'Scroll', () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const ScrollViewerScreen()));
                    }),
                    const SizedBox(height: 8),
                    _navIcon('🤲', _isAr ? 'الذكر' : 'Dhikr', () {
                      // B10: full dhikr collection screen (Dhikr of the Day
                      // + all unlocked + locked silhouettes).
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const DhikrCollectionScreen()));
                    }),
                    const SizedBox(height: 8),
                    _navIcon('🏛️', _isAr ? 'المجموعات' : 'Collections', () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const CollectionGalleryScreen()));
                    }),
                  ],
                ),
              ),

            // ── Settings gear (top-right corner, 30x30, glass) ──────
            if (_activeSheet == null)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 12,
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

            // B8/B19/B20: standalone Continue Journey CTA removed.
            // R25-S2-3: "Your Journey" / "رحلتك" label removed — the
            // progress card's event title is already the hero.

            // ── Progress card (bottom, integrated CTA) ───────────────
            if (_activeSheet == null)
              Positioned(
                bottom: bottomPad + 16,
                left: 16, right: 16,
                // B8: progress card is the single tappable action zone.
                // Row: current/next event name + Start/Continue label.
                // Progress count uses matched sizes (no big/small split).
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
                        // R25-S2-4: button + count on same line
                        if (!isComplete)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              textDirection: _isAr
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              children: [
                                _buildStartContinueButton(isContinue),
                                const SizedBox(width: 14),
                                Padding(
                                  padding: EdgeInsetsDirectional.only(
                                      end: _isAr ? 0 : 4,
                                      start: _isAr ? 4 : 0),
                                  child: Text(
                                    '$completed / ${m1Events.length}',
                                    style: GoogleFonts.nunito(
                                      color: AppColors.gold.withAlpha(191),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // R25-S2-4: thin 2px progress bar
                        const SizedBox(height: 11),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(1),
                          child: LinearProgressIndicator(
                            value: (completed / m1Events.length)
                                .clamp(0.0, 1.0),
                            minHeight: 2,
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

            // ── Bottom sheets (R24 A-03: full dismiss) ───────────────
            if (_activeSheet != null)
              _buildSheetOverlay(
                child: _activeSheet == 'next'
                    ? _nextEventContent(completed)
                    : _activeSheet == 'dhikr'
                        ? _dhikrContent(completed)
                        : const SizedBox.shrink(),
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

  /// R25-S3-8: tent's 3-pill stat container now consumes the shared
  /// StatRowGroup widget. Same widget + data flow as the event-scene
  /// info tab (S3-6) — fixes the S2-1 / S2-2 invisibility bug by
  /// retiring the bespoke inline row rendering that was being drawn
  /// but not visually registering against certain scene-art backgrounds.
  ///
  /// Reader mode still swaps the XP value→events-completed count (B11).
  /// Labels stay constant across modes (S3-5 consolidation).
  Widget _buildStatPillsContainer(int completed) {
    final explorer = PrefsService.isExplorerMode;
    final statRows = <StatRow>[
      StatRow(
        icon: Icons.auto_awesome_rounded,
        label: 'Your Light',
        labelAr: 'نورك',
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
    // R25-S3-HF-1: explicit width = 155. StatRowGroup rows contain a
    // Spacer() between label and value; inside a Positioned with no
    // right bound, the row had zero bounded width, the Spacer couldn't
    // flex, and the whole container collapsed to 0 width — invisible
    // on device despite the widget being mounted. The info tab renders
    // fine because its parent supplies an explicit width animation.
    // Container chrome kept from the S2-1 device-test fix: bg 0.72,
    // gold 0.32 border, blur 8. Renders legibly against any time-of-
    // day scene variant.
    return SizedBox(
      width: 155,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 9),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(10, 14, 24, 0.72),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.gold.withAlpha(82),
                width: 0.8,
              ),
            ),
            child: StatRowGroup(rows: statRows, showDividers: true),
          ),
        ),
      ),
    );
  }

  /// R25-S2-4: Start / Continue button. Same generous padding in both
  /// states so the card doesn't shift when the label swaps. Label only,
  /// no icon, no number badge.
  Widget _buildStartContinueButton(bool isContinue) {
    // Start:    bg 0.15 gold, border 0.4, text #d4a843
    // Continue: bg 0.18 gold, border 0.5, text #e8c04d (slightly warmer)
    final bgAlpha = isContinue ? 46 : 38; // 0.18 vs 0.15
    final borderAlpha = isContinue ? 128 : 102; // 0.5 vs 0.4
    final textColor =
        isContinue ? const Color(0xFFE8C04D) : AppColors.gold;
    final label = isContinue
        ? (_isAr ? 'متابعة' : 'Continue')
        : (_isAr ? 'ابدأ' : 'Start');
    return Container(
      padding:
          const EdgeInsets.symmetric(vertical: 9, horizontal: 32),
      decoration: BoxDecoration(
        color: AppColors.gold.withAlpha(bgAlpha),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.gold.withAlpha(borderAlpha), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
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
