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
import 'event_list_screen.dart';
import 'settings_screen.dart';

/// R22 Part 3 — Rawi's Tent (cinematic campfire home screen).
///
/// A full-screen painted scene: the Rawi sitting by a campfire in the
/// desert. The scene changes based on the user's local time. Interactive
/// hotspot pills float over the scene; tapping opens bottom sheets for
/// "Continue Journey", "Daily Dhikr", and "Your Journey" stats.
class RawiTentScreen extends StatefulWidget {
  const RawiTentScreen({super.key});

  @override
  State<RawiTentScreen> createState() => _RawiTentScreenState();
}

class _RawiTentScreenState extends State<RawiTentScreen> {
  bool get _isAr => PrefsService.isAr;

  String? _activeSheet; // 'next', 'dhikr', 'journey', or null

  // ── Time-of-day scene ─────────────────────────────────────────────
  String _tentScenePath() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 7) return 'assets/scenes/tent_dawn.jpg';
    if (hour >= 7 && hour < 17) return 'assets/scenes/tent_day.jpg';
    if (hour >= 17 && hour < 20) return 'assets/scenes/tent_dusk.jpg';
    return 'assets/scenes/tent_night.jpg';
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    final name = PrefsService.userName.isNotEmpty
        ? PrefsService.userName
        : (_isAr ? 'رحّال' : 'Traveler');
    if (hour >= 5 && hour < 12) {
      return _isAr ? 'صباح النور، $name' : 'Good morning, $name';
    } else if (hour >= 12 && hour < 17) {
      return _isAr ? 'السلام عليكم، $name' : 'Peace be upon you, $name';
    } else {
      return _isAr ? 'مساء الخير، $name' : 'Good evening, $name';
    }
  }

  int get _completedCount {
    int c = 0;
    for (final e in m1Events) {
      if (PrefsService.isEventCompleted(e.globalOrder)) {
        c++;
      } else {
        break;
      }
    }
    return c;
  }

  @override
  void initState() {
    super.initState();
    AudioService.playAmbient(
      'assets/audio/ambient/ambient_intro.mp3',
      volume: 0.15,
    );
  }

  void _openSheet(String name) {
    HapticFeedback.lightImpact();
    setState(() => _activeSheet = _activeSheet == name ? null : name);
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final completed = _completedCount;
    final currentStage = RawiStage.getStage(completed);

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
            // ── Scene background image (time-of-day) ─────────────────
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

            // ── Rawi character (left of center) ──────────────────────
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.30,
              left: MediaQuery.of(context).size.width * 0.20,
              child: Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold.withAlpha(150), width: 2.5),
                  boxShadow: [
                    BoxShadow(color: AppColors.gold.withAlpha(30), blurRadius: 20),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    CharacterArt.portrait(),
                    width: 65, height: 65,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // ── Greeting + stage (top center) ────────────────────────
            Positioned(
              top: topPad + 50,
              left: 0, right: 0,
              child: Column(
                children: [
                  Text(
                    _greeting(),
                    textAlign: TextAlign.center,
                    textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
                    style: GoogleFonts.nunito(
                      color: AppColors.textPrimary.withAlpha(220),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
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

            // ── Settings gear (top right) ────────────────────────────
            Positioned(
              top: topPad + 46,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen())),
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withAlpha(80),
                    border: Border.all(color: AppColors.gold.withAlpha(40)),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.settings_rounded,
                      size: 16, color: AppColors.gold.withAlpha(130)),
                ),
              ),
            ),

            // ── Noor + XP (top left) ─────────────────────────────────
            Positioned(
              top: topPad + 48,
              left: 16,
              child: Row(
                children: [
                  _statPill('☀️', '${PrefsService.noorLevel}%'),
                  const SizedBox(width: 6),
                  _statPill('⭐', '${PrefsService.xp}'),
                ],
              ),
            ),

            // ── Interactive hotspots ─────────────────────────────────
            // Continue Journey (above fire area, center)
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.42,
              left: 0, right: 0,
              child: Center(
                child: _scenePill(
                  icon: '🚶',
                  label: _isAr ? 'تابع الرحلة' : 'Continue Journey',
                  active: _activeSheet == 'next',
                  onTap: () => _openSheet('next'),
                ),
              ),
            ),

            // Daily Dhikr (near fire, left-center)
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.20,
              left: MediaQuery.of(context).size.width * 0.25,
              child: _scenePill(
                icon: '🤲',
                label: _isAr ? 'ذكر اليوم' : 'Daily Dhikr',
                active: _activeSheet == 'dhikr',
                onTap: () => _openSheet('dhikr'),
              ),
            ),

            // Your Journey (near scrolls, right)
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.18,
              right: MediaQuery.of(context).size.width * 0.08,
              child: _scenePill(
                icon: '📊',
                label: _isAr ? 'رحلتك' : 'Your Journey',
                active: _activeSheet == 'journey',
                onTap: () => _openSheet('journey'),
              ),
            ),

            // ── All Events button (bottom center) ────────────────────
            Positioned(
              bottom: bottomPad + 16,
              left: 0, right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const EventListScreen())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(100),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.gold.withAlpha(50)),
                    ),
                    child: Text(
                      _isAr ? 'جميع الأحداث' : 'All Events',
                      style: GoogleFonts.nunito(
                        color: AppColors.gold.withAlpha(150),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom sheets ────────────────────────────────────────
            if (_activeSheet == 'next')
              _buildBottomSheet(
                child: _nextEventContent(completed),
              ),
            if (_activeSheet == 'dhikr')
              _buildBottomSheet(
                child: _dhikrContent(completed),
              ),
            if (_activeSheet == 'journey')
              _buildBottomSheet(
                child: _journeyContent(completed),
              ),
          ],
        ),
      ),
    );
  }

  // ── Reusable scene pill ──────────────────────────────────────────────

  Widget _scenePill({
    required String icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(90),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.gold.withAlpha(active ? 130 : 50),
          ),
          boxShadow: active
              ? [BoxShadow(color: AppColors.gold.withAlpha(40), blurRadius: 16)]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: AppColors.gold,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statPill(String emoji, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(80),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 3),
          Text(
            value,
            style: GoogleFonts.nunito(
              color: AppColors.gold,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom sheet wrapper ─────────────────────────────────────────────

  Widget _buildBottomSheet({required Widget child}) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: GestureDetector(
        onTap: () {}, // block through-taps
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xF00A101C), Color(0xFE080C16)],
            ),
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20)),
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
                onTap: () => setState(() => _activeSheet = null),
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
    );
  }

  // ── Bottom sheet contents ────────────────────────────────────────────

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
            fontSize: 9,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isAr ? event.titleAr : event.title,
          textAlign: TextAlign.center,
          textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
          style: GoogleFonts.nunito(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_isAr ? event.locationAr : event.location} · ${event.year} CE',
          style: GoogleFonts.nunito(
            color: AppColors.textMuted,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const EventListScreen()));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.gold.withAlpha(30),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gold.withAlpha(90)),
            ),
            child: Text(
              _isAr ? 'ابدأ' : 'Start',
              style: GoogleFonts.nunito(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dhikrContent(int completed) {
    final card = completed > 0 ? dhikrCards[m1Events[completed - 1].id] : null;
    return Column(
      children: [
        Text(
          _isAr ? 'ذكر اليوم' : "TODAY'S DHIKR",
          style: GoogleFonts.nunito(
            color: AppColors.gold.withAlpha(130),
            fontSize: 9,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          card != null ? card.arabicText : 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.amiri(
            color: AppColors.gold,
            fontSize: 20,
            height: 1.8,
          ),
        ),
        if (card != null) ...[
          const SizedBox(height: 6),
          Text(
            card.transliteration,
            style: GoogleFonts.nunito(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }

  Widget _journeyContent(int completed) {
    final percent = (completed / m1Events.length * 100).round();
    return Column(
      children: [
        Text(
          _isAr ? 'رحلتك' : 'YOUR JOURNEY',
          style: GoogleFonts.nunito(
            color: AppColors.gold.withAlpha(130),
            fontSize: 9,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$completed',
              style: GoogleFonts.nunito(
                color: AppColors.gold,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                ' / ${m1Events.length}',
                style: GoogleFonts.nunito(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Progress bar
        Container(
          height: 5,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.gold.withAlpha(25),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: (percent / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4A843), Color(0xFFE8C854)],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _journeyStat('📜', '$completed', _isAr ? 'سجلّات' : 'Scrolls'),
            const SizedBox(width: 24),
            _journeyStat('✨', '${PrefsService.dhikrCompletedCount}',
                _isAr ? 'ذكر' : 'Dhikr'),
            const SizedBox(width: 24),
            _journeyStat('🏅', '${PrefsService.earnedBadges.length}',
                _isAr ? 'وسام' : 'Badges'),
          ],
        ),
      ],
    );
  }

  Widget _journeyStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        Text(value,
            style: GoogleFonts.nunito(
                color: AppColors.gold,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        Text(label,
            style: GoogleFonts.nunito(
                color: AppColors.textMuted, fontSize: 8)),
      ],
    );
  }
}
