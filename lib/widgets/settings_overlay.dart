import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../services/prefs_service.dart';

/// Semi-transparent in-game settings overlay.
/// Pauses gameplay. Contains audio toggles, language switch, save & exit.
/// Redesigned to match RawiDialog gold/navy design system.
class SettingsOverlay extends StatefulWidget {
  final VoidCallback onResume;
  final VoidCallback onSaveAndExit;

  const SettingsOverlay({
    super.key,
    required this.onResume,
    required this.onSaveAndExit,
  });

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  bool _music = PrefsService.musicEnabled;
  bool _vo = PrefsService.voEnabled;
  bool _sfx = PrefsService.sfxEnabled;
  String _lang = PrefsService.language;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _animCtrl.reverse();
    widget.onResume();
  }

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

  @override
  Widget build(BuildContext context) {
    final isAr = _lang == 'ar';

    return FadeTransition(
      opacity: _fadeAnim,
      child: Material(
        color: Colors.black.withAlpha(210),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold.withAlpha(80), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withAlpha(20),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header ──────────────────────────────────────────
                Text(
                  isAr ? 'إيقاف مؤقت' : 'Paused',
                  textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                  style: GoogleFonts.cinzelDecorative(
                    fontSize: 20,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 40,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withAlpha(80),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Audio toggles ────────────────────────────────────
                _buildToggle(
                  icon: Icons.music_note_rounded,
                  label: isAr ? 'الموسيقى' : 'Music',
                  value: _music,
                  onChanged: _toggleMusic,
                  isAr: isAr,
                ),
                const SizedBox(height: 10),
                _buildToggle(
                  icon: Icons.mic_rounded,
                  label: isAr ? 'الراوي' : 'Voice Over',
                  value: _vo,
                  onChanged: _toggleVo,
                  isAr: isAr,
                ),
                const SizedBox(height: 10),
                _buildToggle(
                  icon: Icons.volume_up_rounded,
                  label: isAr ? 'المؤثرات' : 'Sound Effects',
                  value: _sfx,
                  onChanged: _toggleSfx,
                  isAr: isAr,
                ),
                const SizedBox(height: 10),

                // ── Language row ─────────────────────────────────────
                GestureDetector(
                  onTap: _cycleLang,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gold.withAlpha(30)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.language_rounded,
                            size: 18, color: AppColors.gold.withAlpha(180)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isAr ? 'اللغة' : 'Language',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.gold.withAlpha(60)),
                          ),
                          child: Text(
                            _lang == 'en' ? 'English' : 'العربية',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: AppColors.gold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Resume button (primary — gold filled) ────────────
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _close,
                    icon: const Icon(Icons.play_arrow_rounded, size: 20),
                    label: Text(
                      isAr ? 'استمرار' : 'Resume',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.bg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ── Save & Exit (secondary — outlined) ───────────────
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: widget.onSaveAndExit,
                    icon: const Icon(Icons.save_rounded, size: 16),
                    label: Text(
                      isAr ? 'حفظ والخروج' : 'Save & Exit',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                      side: BorderSide(color: AppColors.textMuted.withAlpha(60)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggle({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isAr,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: value ? AppColors.gold : AppColors.textMuted.withAlpha(120)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.gold,
            activeTrackColor: AppColors.gold.withAlpha(60),
            inactiveThumbColor: AppColors.textMuted.withAlpha(120),
            inactiveTrackColor: AppColors.textMuted.withAlpha(40),
          ),
        ],
      ),
    );
  }
}
