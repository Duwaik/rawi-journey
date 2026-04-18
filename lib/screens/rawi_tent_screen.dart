import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../character_art.dart';
import '../data/dhikr_data.dart';
import '../data/m1_data.dart';
import '../models/rawi_stage.dart';
import '../services/audio_service.dart';
import '../services/prefs_service.dart';
import 'collection_gallery_screen.dart';
import 'event_list_screen.dart';
import 'scroll_viewer_screen.dart';
import 'seerah_sky_screen.dart';
import 'settings_screen.dart';

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

  // R24 A-05: greeting on one line, name on next, no "Peace be upon you"
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return _isAr ? 'صباح الخير' : 'Good morning';
    if (hour >= 12 && hour < 17) return _isAr ? 'مرحباً' : 'Good afternoon';
    return _isAr ? 'مساء الخير' : 'Good evening';
  }

  String get _userName =>
      PrefsService.userName.isNotEmpty
          ? PrefsService.userName
          : (_isAr ? 'رحّال' : 'Traveler');

  int get _completedCount {
    int c = 0;
    // B-01 pattern: count ALL completions (no sequential break).
    for (final e in m1Events) {
      if (PrefsService.isEventCompleted(e.globalOrder)) c++;
    }
    return c;
  }

  @override
  void initState() {
    super.initState();
    AudioService.playAmbient(
      'assets/audio/ambient/ambient_intro.mp3',
      volume: 0.12,
    );
  }

  void _openSheet(String name) {
    HapticFeedback.lightImpact();
    setState(() => _activeSheet = _activeSheet == name ? null : name);
  }

  void _closeSheet() => setState(() => _activeSheet = null);

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    final completed = _completedCount;
    final currentStage = RawiStage.getStage(completed);
    final percent = (completed / m1Events.length * 100).toStringAsFixed(1);
    // C-01: Tent state flags
    final isStart = completed == 0;
    final isComplete = completed >= m1Events.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        SystemNavigator.pop();
      },
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

            // ── Rawi character (beside fire, MVP: walking pose) ──────
            Positioned(
              bottom: screenH * 0.30,
              left: screenW * 0.18,
              child: Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.gold.withAlpha(100), width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.orange.withAlpha(20), blurRadius: 20),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    CharacterArt.portrait(),
                    width: 56, height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // ── Greeting (top center) ────────────────────────────────
            Positioned(
              top: topPad + 40,
              left: 0, right: 0,
              child: Column(
                children: [
                  Text(
                    _greeting,
                    style: GoogleFonts.nunito(
                      color: AppColors.textPrimary.withAlpha(130),
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _userName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    RawiStage.stageName(currentStage, isAr: _isAr),
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

            // ── Noor + XP (top left, below greeting) ─────────────────
            // B7: larger + labeled so users recognize them as progression
            // indicators, not decorative chips.
            Positioned(
              top: topPad + 110,
              left: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _statPill(
                    emoji: '✦',
                    value: '${PrefsService.noorLevel}%',
                    label: _isAr ? 'نورك' : 'Your Light',
                  ),
                  const SizedBox(height: 8),
                  _statPill(
                    emoji: '★',
                    value: '${PrefsService.xp}',
                    label: _isAr ? 'خبرتك' : 'Experience',
                  ),
                ],
              ),
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
                      _openSheet('dhikr');
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

            // ── Continue Journey CTA (center, above fire) ────────────
            // B3: tapping launches the next event DIRECTLY via EventList's
            // autoOpenEventOrder — preserves threshold + video-intro flow.
            if (_activeSheet == null)
              Positioned(
                bottom: screenH * 0.18,
                left: 0, right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (isComplete) {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const EventListScreen()));
                        return;
                      }
                      final targetOrder = completed + 1;
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => EventListScreen(
                              autoOpenEventOrder: targetOrder)));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(170),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.gold.withAlpha(65), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.gold.withAlpha(15),
                              blurRadius: 20),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        textDirection:
                            _isAr ? TextDirection.rtl : TextDirection.ltr,
                        children: [
                          // B6: icon is on the TRAILING side of the text.
                          // In a Row with LTR: text first, icon after.
                          // In RTL: Flutter mirrors the order so icon still
                          // sits on the trailing (visual left) side.
                          Text(
                            isStart
                                ? (_isAr ? 'ابدأ الرحلة' : 'Begin Journey')
                                : isComplete
                                    ? (_isAr ? 'أعد زيارة الرحلة' : 'Revisit the Journey')
                                    : (_isAr ? 'تابع الرحلة' : 'Continue Journey'),
                            style: GoogleFonts.nunito(
                              color: AppColors.gold,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            textDirection:
                                _isAr ? TextDirection.rtl : TextDirection.ltr,
                          ),
                          const SizedBox(width: 8),
                          const Text('🚶', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // ── Progress bar (bottom) ────────────────────────────────
            if (_activeSheet == null)
              Positioned(
                bottom: bottomPad + 16,
                left: 16, right: 16,
                // B8: prominent progress card — big numbers, bigger bar,
                // label line above. Feels like a proud achievement display.
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(185),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.gold.withAlpha(70), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.gold.withAlpha(15),
                          blurRadius: 14),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _isAr ? 'رحلتك' : 'Your Journey',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          color: AppColors.gold.withAlpha(160),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isStart)
                        Text(
                          _isAr ? 'رحلتك تنتظر' : 'Your journey awaits',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lora(
                            color: AppColors.gold,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      else if (isComplete)
                        Text(
                          _isAr ? 'اكتملت الرحلة ✦' : 'Journey complete ✦',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cinzelDecorative(
                            color: AppColors.gold,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(
                                  color: AppColors.gold.withAlpha(120),
                                  blurRadius: 12),
                            ],
                          ),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$completed',
                              style: GoogleFonts.cinzelDecorative(
                                color: AppColors.gold,
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              ' / ${m1Events.length}',
                              style: GoogleFonts.nunito(
                                color: AppColors.gold.withAlpha(140),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '·  $percent%',
                              style: GoogleFonts.nunito(
                                color: AppColors.gold.withAlpha(180),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      if (!isStart) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (completed / m1Events.length)
                                .clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: AppColors.gold.withAlpha(25),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.gold),
                          ),
                        ),
                      ],
                    ],
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
    );
  }

  // ── Navigation icon ──────────────────────────────────────────────────

  Widget _navIcon(String icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(180),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withAlpha(40)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: AppColors.gold.withAlpha(130),
                fontSize: 7,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// B7: bigger, labeled stat pill. Emoji + large value + muted label line.
  Widget _statPill({
    required String emoji,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(170),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withAlpha(60), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: TextStyle(
              fontSize: 18,
              color: AppColors.gold,
              shadows: [
                Shadow(color: AppColors.gold.withAlpha(90), blurRadius: 8),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: GoogleFonts.nunito(
                  color: AppColors.gold,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.nunito(
                  color: AppColors.gold.withAlpha(130),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
                textDirection:
                    _isAr ? TextDirection.rtl : TextDirection.ltr,
              ),
            ],
          ),
        ],
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
