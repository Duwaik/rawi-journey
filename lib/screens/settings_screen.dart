import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../character_art.dart';
import '../data/m1_data.dart';
import '../main.dart';
import '../models/rawi_stage.dart';
import '../services/prefs_service.dart';
import '../widgets/rawi_dialog.dart';
import 'event_list_screen.dart';
import 'splash_screen.dart';

/// Full-page settings accessible from the hub gear icon.
/// Cinematic card-based layout with desert BG, matching event list style.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _music = PrefsService.musicEnabled;
  bool _vo = PrefsService.voEnabled;
  bool _sfx = PrefsService.sfxEnabled;
  String _lang = PrefsService.language;
  final String _gender = PrefsService.userGender;

  bool get _isAr => _lang == 'ar';

  // ── Card styling constants ────────────────────────────────────────────────
  static final Color _cardBg = const Color(0xFF0A0E14).withAlpha(200);
  static final BorderSide _cardBorder =
      BorderSide(color: AppColors.gold.withAlpha(40));
  static final BorderRadius _cardRadius = BorderRadius.circular(16);

  BoxDecoration get _sectionDecoration => BoxDecoration(
        color: _cardBg,
        borderRadius: _cardRadius,
        border: Border.fromBorderSide(_cardBorder),
      );

  void _toggleMusic(bool v) {
    setState(() => _music = v);
    PrefsService.setMusicEnabled(v);
  }

  void _toggleVo(bool v) {
    setState(() => _vo = v);
    PrefsService.setVoEnabled(v);
  }

  void _toggleSfx(bool v) {
    setState(() => _sfx = v);
    PrefsService.setSfxEnabled(v);
  }

  void _cycleLang() {
    final next = _lang == 'en' ? 'ar' : 'en';
    setState(() => _lang = next);
    PrefsService.setLanguage(next);
    RawiApp.rebuild(context);
  }

  void _cycleTextSize() {
    final current = PrefsService.textScale;
    final next = current < 0.9
        ? 1.0
        : current > 1.1
            ? 0.85
            : 1.2;
    PrefsService.setTextScale(next);
    RawiApp.rebuild(context);
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (c, a, s) => const EventListScreen(),
        transitionsBuilder: (c, a, s, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
      (route) => false,
    );
  }

  String get _textSizeLabel {
    final s = PrefsService.textScale;
    if (s < 0.9) return _isAr ? 'ص' : 'S';
    if (s > 1.1) return _isAr ? 'ك' : 'L';
    return _isAr ? 'م' : 'M';
  }

  Future<void> _resetJourney() async {
    final confirmed = await showRawiDialog(
      context: context,
      title: _isAr ? 'إعادة الرحلة' : 'Reset Journey',
      body: _isAr
          ? 'سيتم مسح كل تقدمك. هل أنت متأكد؟'
          : 'All your progress will be erased. Are you sure?',
      cancelLabel: _isAr ? 'إلغاء' : 'Cancel',
      confirmLabel: _isAr ? 'إعادة' : 'Reset',
      isAr: _isAr,
      confirmDanger: true,
    );

    if (confirmed == true) {
      await PrefsService.resetJourney();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (c, a, s) => const SplashScreen(),
          transitionsBuilder: (c, a, s, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Cinematic desert BG (same as event list) ────────────────────
          Image.asset(
            'assets/scenes/scene_welcome.jpg',
            fit: BoxFit.cover,
          ),
          // Heavy dark overlay (~92% opacity)
          Container(color: AppColors.bg.withAlpha(235)),

          // ── Content ─────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────────────────
                Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(8, topPad > 0 ? 4 : 12, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: AppColors.textMuted),
                      ),
                      const Spacer(),
                      Text(
                        _isAr ? 'الإعدادات' : 'Settings',
                        style: GoogleFonts.cinzelDecorative(
                          fontSize: 20,
                          color: AppColors.gold,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Scrollable sections ──────────────────────────────────
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      // ── 1. Profile ─────────────────────────────────────
                      _buildSectionHeader(
                          _isAr ? 'الملف الشخصي' : 'Profile'),
                      const SizedBox(height: 8),
                      _buildProfileCard(),

                      const SizedBox(height: 16),

                      // ── 2. Journey Stats ───────────────────────────────
                      _buildSectionHeader(
                          _isAr ? 'إحصائيات الرحلة' : 'Journey Stats'),
                      const SizedBox(height: 8),
                      _buildJourneyStatsCard(),

                      const SizedBox(height: 16),

                      // ── 3. Preferences ─────────────────────────────────
                      _buildSectionHeader(
                          _isAr ? 'التفضيلات' : 'Preferences'),
                      const SizedBox(height: 8),
                      _buildPreferencesCard(),

                      const SizedBox(height: 16),

                      // ── 4. About ───────────────────────────────────────
                      _buildSectionHeader(_isAr ? 'حول' : 'About'),
                      const SizedBox(height: 8),
                      _buildAboutCard(),

                      const SizedBox(height: 16),

                      // ── 5. Reset Journey ───────────────────────────────
                      _buildSectionHeader(
                          _isAr ? 'إعادة الرحلة' : 'Reset Journey'),
                      const SizedBox(height: 8),
                      _buildResetCard(),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header ──────────────────────────────────────────────────────

  Widget _buildSectionHeader(String label) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        label,
        style: GoogleFonts.lora(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.gold,
        ),
        textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
      ),
    );
  }

  // ── 1. Profile card ─────────────────────────────────────────────────────

  Widget _buildProfileCard() {
    final name = PrefsService.userName.isNotEmpty
        ? PrefsService.userName
        : (_isAr ? 'رحّال' : 'Traveler');
    final roleLabel = _gender == 'female'
        ? (_isAr ? 'الراوية' : 'Rawiah')
        : (_isAr ? 'الراوي' : 'Rawi');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _sectionDecoration,
      child: Row(
        textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
        children: [
          // Gold-bordered portrait (carrying pose)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withAlpha(40),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                CharacterArt.carrying(),
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: _isAr
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  roleLabel,
                  style: GoogleFonts.lora(
                    fontSize: 13,
                    color: AppColors.gold.withAlpha(180),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  RawiStage.stageName(
                    RawiStage.getStage(
                      (PrefsService.currentOrder - 1).clamp(0, m1EventCount),
                    ),
                    isAr: _isAr,
                  ),
                  style: GoogleFonts.lora(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. Journey Stats card ───────────────────────────────────────────────

  Widget _buildJourneyStatsCard() {
    final completed = (PrefsService.currentOrder - 1).clamp(0, m1EventCount);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: _sectionDecoration,
      child: Column(
        children: [
          _statRow(
            Icons.auto_stories_rounded,
            _isAr ? 'الأحداث المكتملة' : 'Events completed',
            '$completed / $m1EventCount',
          ),
          Divider(color: AppColors.gold.withAlpha(20), height: 24),
          _statRow(
            Icons.star_rounded,
            _isAr ? 'النقاط' : 'XP',
            '${PrefsService.xp}',
          ),
          Divider(color: AppColors.gold.withAlpha(20), height: 24),
          _statRow(
            Icons.auto_awesome_rounded,
            _isAr ? 'جلسات الذكر' : 'Dhikr',
            '${PrefsService.dhikrCompletedCount}',
          ),
        ],
      ),
    );
  }

  Widget _statRow(IconData icon, String label, String value) {
    return Row(
      textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Icon(icon, size: 20, color: AppColors.gold.withAlpha(180)),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.nunito(
                fontSize: 15, color: AppColors.textPrimary),
            textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: AppColors.textBody,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── 3. Preferences card ─────────────────────────────────────────────────

  Widget _buildPreferencesCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: _sectionDecoration,
      child: Column(
        children: [
          // Language toggle
          _tapPrefRow(
            Icons.language_rounded,
            _isAr ? 'اللغة' : 'Language',
            _lang == 'en' ? 'EN' : 'AR',
            _cycleLang,
          ),
          Divider(color: AppColors.gold.withAlpha(20), height: 24),
          // Text size toggle
          _tapPrefRow(
            Icons.text_fields_rounded,
            _isAr ? 'حجم الخط' : 'Text Size',
            _textSizeLabel,
            _cycleTextSize,
          ),
          Divider(color: AppColors.gold.withAlpha(20), height: 24),
          // Music
          _togglePrefRow(
            Icons.music_note_rounded,
            _isAr ? 'الموسيقى' : 'Music',
            _music,
            _toggleMusic,
          ),
          Divider(color: AppColors.gold.withAlpha(20), height: 24),
          // Voice Over
          _togglePrefRow(
            Icons.mic_rounded,
            _isAr ? 'الراوي الصوتي' : 'Voice Over',
            _vo,
            _toggleVo,
          ),
          Divider(color: AppColors.gold.withAlpha(20), height: 24),
          // SFX
          _togglePrefRow(
            Icons.volume_up_rounded,
            _isAr ? 'المؤثرات' : 'Sound Effects',
            _sfx,
            _toggleSfx,
          ),
        ],
      ),
    );
  }

  Widget _tapPrefRow(
      IconData icon, String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Icon(icon, size: 20, color: AppColors.gold.withAlpha(180)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.nunito(
                  fontSize: 15, color: AppColors.textPrimary),
              textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gold.withAlpha(60)),
            ),
            child: Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: AppColors.gold,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right_rounded,
              size: 18, color: AppColors.textMuted.withAlpha(100)),
        ],
      ),
    );
  }

  Widget _togglePrefRow(
      IconData icon, String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Icon(icon, size: 20, color: AppColors.gold.withAlpha(180)),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style:
                GoogleFonts.nunito(fontSize: 15, color: AppColors.textPrimary),
            textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.gold,
          activeTrackColor: AppColors.gold.withAlpha(80),
          inactiveThumbColor: AppColors.textMuted,
          inactiveTrackColor: AppColors.textMuted.withAlpha(40),
        ),
      ],
    );
  }

  // ── 4. About card ───────────────────────────────────────────────────────

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _sectionDecoration,
      child: Column(
        children: [
          Text(
            'RAWI',
            style: GoogleFonts.cinzelDecorative(
              fontSize: 18,
              color: AppColors.gold,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'v1.0.0',
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isAr ? 'صُنع بحب في عمّان' : 'Made with love in Amman',
            style: GoogleFonts.lora(
              fontSize: 13,
              fontStyle: _isAr ? FontStyle.normal : FontStyle.italic,
              color: AppColors.gold.withAlpha(140),
            ),
            textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
          ),
          const SizedBox(height: 8),
          Text(
            _isAr
                ? 'كن شاهداً. احمل الرواية.'
                : 'Witness history. Carry the story.',
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
            textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
          ),
        ],
      ),
    );
  }

  // ── 5. Reset Journey card ───────────────────────────────────────────────

  Widget _buildResetCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(15),
        borderRadius: _cardRadius,
        border: Border.all(color: Colors.redAccent.withAlpha(50)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: _cardRadius,
        child: InkWell(
          onTap: _resetJourney,
          borderRadius: _cardRadius,
          splashColor: Colors.redAccent.withAlpha(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.restart_alt_rounded,
                    size: 20, color: Colors.redAccent),
                const SizedBox(width: 10),
                Text(
                  _isAr ? 'إعادة الرحلة من البداية' : 'Reset Journey',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
