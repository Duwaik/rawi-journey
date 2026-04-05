import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../services/prefs_service.dart';
import '../widgets/rawi_dialog.dart';
import 'event_list_screen.dart';
import 'splash_screen.dart';

/// Full-page settings accessible from the hub gear icon.
/// Audio toggles, language, profile editing, reset journey, about.
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
  String _gender = PrefsService.userGender;

  bool get _isAr => _lang == 'ar';

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
  }

  void _cycleGender() {
    final next = _gender == 'male' ? 'female' : 'male';
    setState(() => _gender = next);
    PrefsService.setUserGender(next);
  }

  Future<void> _resetJourney() async {
    final confirmed = await showRawiDialog(
      context: context,
      title: _isAr ? 'إعادة الرحلة' : 'Reset Journey',
      body: _isAr ? 'سيتم مسح كل تقدمك. هل أنت متأكد؟' : 'All your progress will be erased. Are you sure?',
      cancelLabel: _isAr ? 'إلغاء' : 'Cancel',
      confirmLabel: _isAr ? 'إعادة' : 'Reset',
      isAr: _isAr,
      confirmDanger: true,
    );

    if (confirmed == true) {
      await PrefsService.resetJourney();
      if (!mounted) return;
      // Restart app from splash — clear entire navigation stack
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
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(8, topPad > 0 ? 4 : 12, 16, 0),
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

            const SizedBox(height: 16),

            // ── Content ──────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // ── Profile ──────────────────────────────────────
                  _SectionHeader(
                      label: _isAr ? 'الملف الشخصي' : 'Profile', isAr: _isAr),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.person_outline_rounded,
                    label: _isAr ? 'الاسم' : 'Name',
                    value: PrefsService.userName.isNotEmpty
                        ? PrefsService.userName
                        : (_isAr ? 'رحّال' : 'Traveler'),
                  ),
                  const SizedBox(height: 8),
                  _TapRow(
                    icon: Icons.auto_stories_rounded,
                    label: _isAr ? 'الرفيق' : 'Companion',
                    value: _gender == 'male'
                        ? (_isAr ? 'راوي' : 'Rawi')
                        : (_isAr ? 'راوية' : 'Rawiah'),
                    onTap: _cycleGender,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.calendar_today_rounded,
                    label: _isAr ? 'راوي منذ' : 'Rawi since',
                    value: PrefsService.firstLaunchDate,
                  ),

                  const SizedBox(height: 28),

                  // ── Journey ──────────────────────────────────────
                  _SectionHeader(
                      label: _isAr ? 'الرحلة' : 'Journey', isAr: _isAr),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.star_rounded,
                    label: _isAr ? 'النقاط' : 'XP',
                    value: '${PrefsService.xp}',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.local_fire_department_rounded,
                    label: _isAr ? 'أيام متتالية' : 'Streak',
                    value: '${PrefsService.streak}',
                  ),

                  const SizedBox(height: 28),

                  // ── Preferences ──────────────────────────────────
                  _SectionHeader(
                      label: _isAr ? 'التفضيلات' : 'Preferences', isAr: _isAr),
                  const SizedBox(height: 8),
                  _TapRow(
                    icon: Icons.language_rounded,
                    label: _isAr ? 'اللغة' : 'Language',
                    value: _lang == 'en' ? 'English' : 'العربية',
                    onTap: _cycleLang,
                  ),
                  const SizedBox(height: 8),
                  _TapRow(
                    icon: Icons.text_fields_rounded,
                    label: _isAr ? 'حجم الخط' : 'Text Size',
                    value: PrefsService.textScale < 0.9
                        ? (_isAr ? 'صغير' : 'Small')
                        : PrefsService.textScale > 1.1
                            ? (_isAr ? 'كبير' : 'Large')
                            : (_isAr ? 'عادي' : 'Normal'),
                    onTap: () {
                      final current = PrefsService.textScale;
                      final next = current < 0.9 ? 1.0 : current > 1.1 ? 0.85 : 1.2;
                      PrefsService.setTextScale(next);
                      Navigator.of(context).pushAndRemoveUntil(
                        PageRouteBuilder(
                          pageBuilder: (c, a, s) => const EventListScreen(),
                          transitionsBuilder: (c, a, s, child) =>
                              FadeTransition(opacity: a, child: child),
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _ToggleRow(
                    icon: Icons.music_note_rounded,
                    label: _isAr ? 'الموسيقى' : 'Music',
                    value: _music,
                    onChanged: _toggleMusic,
                  ),
                  const SizedBox(height: 8),
                  _ToggleRow(
                    icon: Icons.mic_rounded,
                    label: _isAr ? 'الراوي الصوتي' : 'Voice Over',
                    value: _vo,
                    onChanged: _toggleVo,
                  ),
                  const SizedBox(height: 8),
                  _ToggleRow(
                    icon: Icons.volume_up_rounded,
                    label: _isAr ? 'المؤثرات' : 'Sound Effects',
                    value: _sfx,
                    onChanged: _toggleSfx,
                  ),

                  const SizedBox(height: 28),

                  // ── About ────────────────────────────────────────
                  _SectionHeader(
                      label: _isAr ? 'حول' : 'About', isAr: _isAr),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.textMuted.withAlpha(30)),
                    ),
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
                        const SizedBox(height: 8),
                        Text(
                          _isAr
                              ? 'صُنع بحبّ في عمّان'
                              : 'Made with ♥ in Amman',
                          style: GoogleFonts.lora(
                            fontSize: 13,
                            color: AppColors.gold.withAlpha(160),
                          ),
                          textDirection:
                              _isAr ? TextDirection.rtl : TextDirection.ltr,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Reset Journey (destructive — always last) ───
                  _buildResetButton(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        onPressed: _resetJourney,
        icon: const Icon(Icons.restart_alt_rounded,
            size: 18, color: Colors.redAccent),
        label: Text(
          _isAr ? 'إعادة الرحلة من البداية' : 'Reset Journey',
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.redAccent,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent, width: 0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// ── Reusable rows ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final bool isAr;
  const _SectionHeader({required this.label, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 1,
        ),
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textMuted.withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.gold.withAlpha(180)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: GoogleFonts.nunito(
                    fontSize: 15, color: AppColors.textPrimary)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.gold,
            inactiveTrackColor: AppColors.textMuted.withAlpha(40),
          ),
        ],
      ),
    );
  }
}

class _TapRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TapRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.textMuted.withAlpha(30)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.gold.withAlpha(180)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.nunito(
                      fontSize: 15, color: AppColors.textPrimary)),
            ),
            Text(value,
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700)),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.textMuted.withAlpha(100)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textMuted.withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.gold.withAlpha(180)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: GoogleFonts.nunito(
                    fontSize: 15, color: AppColors.textPrimary)),
          ),
          Text(value,
              style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: AppColors.textBody,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
