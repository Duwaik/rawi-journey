import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../services/prefs_service.dart';

/// Semi-transparent in-game settings overlay.
/// Pauses gameplay. Contains audio toggles, language switch, save & exit.
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
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  bool _music = PrefsService.musicEnabled;
  bool _vo = PrefsService.voEnabled;
  bool _sfx = PrefsService.sfxEnabled;
  String _lang = PrefsService.language;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut);
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _slideCtrl.reverse();
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
    final topPad = MediaQuery.of(context).padding.top;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Material(
        color: Colors.black.withAlpha(200),
        child: SlideTransition(
          position: _slideAnim,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, topPad + 16, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Header ──────────────────────────────────────────
                  Text(
                    isAr ? 'الإعدادات' : 'Settings',
                    textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                    style: GoogleFonts.cinzelDecorative(
                      fontSize: 22,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Toggles ─────────────────────────────────────────
                  _ToggleRow(
                    icon: Icons.music_note_rounded,
                    label: isAr ? 'الموسيقى' : 'Music',
                    value: _music,
                    onChanged: _toggleMusic,
                  ),
                  const SizedBox(height: 12),
                  _ToggleRow(
                    icon: Icons.mic_rounded,
                    label: isAr ? 'الراوي' : 'Voice Over',
                    value: _vo,
                    onChanged: _toggleVo,
                  ),
                  const SizedBox(height: 12),
                  _ToggleRow(
                    icon: Icons.volume_up_rounded,
                    label: isAr ? 'المؤثرات' : 'Sound Effects',
                    value: _sfx,
                    onChanged: _toggleSfx,
                  ),
                  const SizedBox(height: 12),

                  // ── Language row ────────────────────────────────────
                  _buildLangRow(isAr),

                  const SizedBox(height: 32),

                  // ── Save & Exit ─────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: widget.onSaveAndExit,
                      icon: const Icon(Icons.save_rounded, size: 18),
                      label: Text(
                        isAr ? 'حفظ والخروج' : 'Save & Exit',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: BorderSide(
                            color: AppColors.textMuted.withAlpha(60)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Resume ──────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _close,
                      icon: const Icon(Icons.play_arrow_rounded, size: 22),
                      label: Text(
                        isAr ? 'استمرار' : 'Resume',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.bg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLangRow(bool isAr) {
    return GestureDetector(
      onTap: _cycleLang,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.textMuted.withAlpha(30)),
        ),
        child: Row(
          children: [
            Icon(Icons.language_rounded,
                size: 20, color: AppColors.gold.withAlpha(180)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                isAr ? 'اللغة' : 'Language',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              _lang == 'en' ? 'English' : 'العربية',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: AppColors.gold,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.textMuted.withAlpha(100)),
          ],
        ),
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
            child: Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
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
