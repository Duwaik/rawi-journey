import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../character_art.dart';
import '../data/m1_data.dart';
import '../main.dart';
import '../models/rawi_stage.dart';
import '../services/audio_service.dart';
import '../services/prefs_service.dart';
import '../widgets/rawi_dialog.dart';
import '../widgets/segmented_picker.dart';
import 'splash_screen.dart';

/// Full-page settings accessible from the hub gear icon.
/// Cinematic card-based layout with desert BG, matching event list style.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // C-02: Collapsible sections — only Profile expanded by default.
  final Map<String, bool> _expanded = {'profile': true};

  bool _music = PrefsService.musicEnabled;
  bool _vo = PrefsService.voEnabled;
  bool _sfx = PrefsService.sfxEnabled;
  String _lang = PrefsService.language;
  String _gender = PrefsService.userGender;
  // R28 S1-FEAT4: which view mode the Events List opens in by default.
  // 'list' (factory) or 'constellation'. Written through
  // `PrefsService.setJourneyViewDefault`.
  String _journeyView = PrefsService.journeyViewDefault;

  bool get _isAr => _lang == 'ar';

  /// R27 S1.3-SET1: editable-profile state. Flipped true when the
  /// user taps Edit. Holds draft values until Save commits them or
  /// Cancel discards. `_editNameError` / `_editAgeError` are filled
  /// by validation and drive inline error rendering.
  bool _editingProfile = false;
  final TextEditingController _editNameCtrl = TextEditingController();
  final TextEditingController _editAgeCtrl = TextEditingController();
  String _editGender = 'male';
  String? _editNameError;
  String? _editAgeError;
  bool _profileSavedToast = false;

  /// R27 S1.3-SET1: same charset + blocklist as S1-REG1. Kept in sync
  /// manually; if you change one, change the other (or extract to
  /// `lib/utils/name_validator.dart` when a third caller appears).
  static final RegExp _nameAllowedChars =
      RegExp(r"^[a-zA-Z؀-ۿ \'\-]+$");
  static const Set<String> _nameBlocklist = {
    'allah', 'god', 'rabb', 'lord',
    'الله', 'اللّه', 'الرب', 'رب',
  };

  @override
  void dispose() {
    _editNameCtrl.dispose();
    _editAgeCtrl.dispose();
    super.dispose();
  }

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
    // R19-11: actually stop the ambient when muted (don't just save the pref)
    if (!v) {
      AudioService.fadeOut(duration: const Duration(milliseconds: 300));
    }
  }

  void _setJourneyView(String v) {
    setState(() => _journeyView = v);
    PrefsService.setJourneyViewDefault(v);
  }

  void _toggleVo(bool v) {
    setState(() => _vo = v);
    PrefsService.setVoEnabled(v);
    if (!v) {
      AudioService.fadeOutVoiceover(duration: const Duration(milliseconds: 200));
    }
  }

  void _toggleSfx(bool v) {
    setState(() => _sfx = v);
    PrefsService.setSfxEnabled(v);
    if (!v) AudioService.stopSfx();
  }

  void _cycleLang() {
    final next = _lang == 'en' ? 'ar' : 'en';
    setState(() => _lang = next);
    PrefsService.setLanguage(next);
    RawiApp.rebuild(context);
  }

  // R20-A1: Text size is now a segmented bar instead of cycle-tap.
  // 0.85 = Small, 1.0 = Medium, 1.2 = Large.
  static const double _textScaleSmall = 0.85;
  static const double _textScaleMedium = 1.0;
  static const double _textScaleLarge = 1.2;

  double get _textScaleKey {
    final s = PrefsService.textScale;
    if (s < 0.9) return _textScaleSmall;
    if (s > 1.1) return _textScaleLarge;
    return _textScaleMedium;
  }

  void _setTextSize(double scale) {
    PrefsService.setTextScale(scale);
    RawiApp.rebuild(context);
    setState(() {});
  }

  // R21-04: Joystick position (Explorer Mode only) — left / center / right.
  String _joystickPos = PrefsService.joystickPosition;

  void _setJoystickPos(String pos) {
    PrefsService.setJoystickPosition(pos);
    setState(() => _joystickPos = pos);
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
      // R28-HF1-RESET: with prefs.clear() the language, text scale,
      // and Reader/Explorer mode all snap back to defaults. Force the
      // MaterialApp to rebuild so its Directionality + textScaler
      // pick up the cleared values before SplashScreen mounts —
      // otherwise the splash inherits AR-RTL / Large-scale from the
      // settings screen we just popped out of for one frame.
      RawiApp.rebuild(context);
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
                // C-02: Collapsible sections, reordered by frequency.
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _collapsibleSection(
                        key: 'profile',
                        label: _isAr ? 'الملف الشخصي' : 'Profile',
                        child: _buildProfileCard(),
                      ),
                      _collapsibleSection(
                        key: 'preferences',
                        label: _isAr ? 'التفضيلات' : 'Preferences',
                        child: _buildPreferencesCard(),
                      ),
                      _collapsibleSection(
                        key: 'journey_mode',
                        label: _isAr ? 'نمط الرحلة' : 'Journey Mode',
                        child: _buildJourneyModeCard(),
                      ),
                      _collapsibleSection(
                        key: 'journey_stats',
                        label: _isAr ? 'إحصائيات الرحلة' : 'Journey Stats',
                        child: _buildJourneyStatsCard(),
                      ),
                      _collapsibleSection(
                        key: 'coming_soon',
                        label: _isAr ? 'قريباً' : 'Coming Soon',
                        child: _buildComingSoonCard(),
                      ),
                      _collapsibleSection(
                        key: 'subscription',
                        label: _isAr ? 'الاشتراك' : 'Subscription',
                        child: _buildSubscriptionCard(),
                      ),
                      _collapsibleSection(
                        key: 'about',
                        label: _isAr ? 'حول' : 'About',
                        child: _buildAboutCard(),
                      ),
                      _collapsibleSection(
                        key: 'reset',
                        label: _isAr ? 'إعادة الرحلة' : 'Reset Journey',
                        child: _buildResetCard(),
                      ),
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

  // ── Collapsible section wrapper (C-02) ──────────────────────────────────

  Widget _collapsibleSection({
    required String key,
    required String label,
    required Widget child,
  }) {
    final isExpanded = _expanded[key] ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded[key] = !isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(child: _buildSectionHeader(label)),
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.gold.withAlpha(130),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity, height: 0),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: child,
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
      ],
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
  //
  // R27 S1.3-SET1: switchable read-only / edit view. Read-only shows
  // the existing portrait + name + role + stage and adds a small
  // Edit pill. Tapping Edit swaps the card content to an edit form
  // (name input, age input, gender select, Save/Cancel row). Save
  // validates + writes to PrefsService + shows a brief toast; Cancel
  // reverts unsaved changes.

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _sectionDecoration,
      child: _editingProfile ? _buildProfileEditForm() : _buildProfileRead(),
    );
  }

  Widget _buildProfileRead() {
    final name = PrefsService.userName.isNotEmpty
        ? PrefsService.userName
        : (_isAr ? 'رحّال' : 'Traveler');
    final roleLabel = _gender == 'female'
        ? (_isAr ? 'الراوية' : 'Rawiah')
        : (_isAr ? 'الراوي' : 'Rawi');

    return Row(
      textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
      children: [
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
        // Edit pill — small, gold outline, defers to the form swap.
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _startEditProfile,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.gold.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.gold.withAlpha(160), width: 1),
            ),
            child: Text(
              _isAr ? 'تعديل' : 'Edit',
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

  void _startEditProfile() {
    setState(() {
      _editingProfile = true;
      _editNameCtrl.text = PrefsService.userName;
      _editAgeCtrl.text = PrefsService.userAge.toString();
      _editGender = _gender;
      _editNameError = null;
      _editAgeError = null;
    });
  }

  void _cancelEditProfile() {
    setState(() {
      _editingProfile = false;
      _editNameError = null;
      _editAgeError = null;
    });
  }

  String? _validateEditName(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return _isAr ? 'الاسم مطلوب.' : 'Name is required.';
    }
    if (trimmed.length < 2 || trimmed.length > 15) {
      return _isAr
          ? 'الاسم يجب أن يكون 2-15 حرفاً.'
          : 'Name must be 2-15 characters.';
    }
    if (!_nameAllowedChars.hasMatch(trimmed)) {
      return _isAr
          ? 'مسموح بالحروف والمسافات والرموز - \' فقط.'
          : "Only letters, spaces, and - ' allowed.";
    }
    if (_nameBlocklist.contains(trimmed.toLowerCase())) {
      return _isAr ? 'يرجى استخدام اسم شخصي.' : 'Please use a personal name.';
    }
    return null;
  }

  String? _validateEditAge(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return _isAr ? 'العمر مطلوب.' : 'Age is required.';
    }
    final parsed = int.tryParse(trimmed);
    if (parsed == null) {
      return _isAr ? 'أدخل رقماً صحيحاً.' : 'Enter a valid number.';
    }
    if (parsed < 4 || parsed > 120) {
      return _isAr
          ? 'العمر يجب أن يكون بين 4 و 120.'
          : 'Age must be between 4 and 120.';
    }
    return null;
  }

  Future<void> _saveEditProfile() async {
    final nameErr = _validateEditName(_editNameCtrl.text);
    final ageErr = _validateEditAge(_editAgeCtrl.text);
    if (nameErr != null || ageErr != null) {
      setState(() {
        _editNameError = nameErr;
        _editAgeError = ageErr;
      });
      return;
    }
    // Persist — setUserName capitalizes the first letter for us.
    await PrefsService.setUserName(_editNameCtrl.text);
    await PrefsService.setUserAge(int.parse(_editAgeCtrl.text));
    await PrefsService.setUserGender(_editGender);
    if (!mounted) return;
    setState(() {
      _gender = _editGender;
      _editingProfile = false;
      _editNameError = null;
      _editAgeError = null;
      _profileSavedToast = true;
    });
    // Toast auto-hides after 2 seconds.
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _profileSavedToast = false);
    });
  }

  Widget _buildProfileEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Name field
        Text(
          _isAr ? 'الاسم' : 'Name',
          textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
          style: GoogleFonts.nunito(
            fontSize: 11,
            color: AppColors.gold.withAlpha(180),
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _editNameCtrl,
          maxLength: 15,
          textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
          style: GoogleFonts.nunito(
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            isDense: true,
            counterText: '',
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: AppColors.gold.withAlpha(80), width: 1),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.gold, width: 1.5),
            ),
          ),
        ),
        if (_editNameError != null) ...[
          const SizedBox(height: 4),
          Text(
            _editNameError!,
            textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
            style: GoogleFonts.nunito(
              fontSize: 11,
              color: const Color(0xFFE27979),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 16),

        // Age field
        Text(
          _isAr ? 'العمر' : 'Age',
          textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
          style: GoogleFonts.nunito(
            fontSize: 11,
            color: AppColors.gold.withAlpha(180),
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _editAgeCtrl,
          keyboardType: TextInputType.number,
          maxLength: 3,
          textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
          style: GoogleFonts.nunito(
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            isDense: true,
            counterText: '',
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: AppColors.gold.withAlpha(80), width: 1),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.gold, width: 1.5),
            ),
          ),
        ),
        if (_editAgeError != null) ...[
          const SizedBox(height: 4),
          Text(
            _editAgeError!,
            textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
            style: GoogleFonts.nunito(
              fontSize: 11,
              color: const Color(0xFFE27979),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 16),

        // Gender toggle
        Text(
          _isAr ? 'الشخصية' : 'Companion',
          textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
          style: GoogleFonts.nunito(
            fontSize: 11,
            color: AppColors.gold.withAlpha(180),
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _editGenderChip('male',
                  label: _isAr ? 'راوي' : 'Rawi'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _editGenderChip('female',
                  label: _isAr ? 'راوية' : 'Rawiah'),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Save / Cancel row
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _cancelEditProfile,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.gold.withAlpha(120), width: 1),
                  ),
                  child: Text(
                    _isAr ? 'إلغاء' : 'Cancel',
                    style: GoogleFonts.nunito(
                      color: AppColors.gold,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _saveEditProfile,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _isAr ? 'حفظ' : 'Save',
                    style: GoogleFonts.nunito(
                      color: const Color(0xFF0B1E2D),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_profileSavedToast) ...[
          const SizedBox(height: 10),
          Text(
            _isAr ? 'تم الحفظ ✓' : 'Saved ✓',
            textAlign: TextAlign.center,
            textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }

  Widget _editGenderChip(String value, {required String label}) {
    final selected = _editGender == value;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _editGender = value),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.gold.withAlpha(60)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected
                  ? AppColors.gold
                  : AppColors.gold.withAlpha(80),
              width: selected ? 1.5 : 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            color: selected
                ? AppColors.gold
                : AppColors.textMuted,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
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

  // ── Subscription placeholder (R19-10) ──────────────────────────────────

  Widget _buildSubscriptionCard() {
    return Container(
      decoration: _sectionDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium_rounded,
                  color: AppColors.gold, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isAr
                          ? 'RawiJourney Premium — \$9.99'
                          : 'RawiJourney Premium — \$9.99',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isAr
                          ? 'افتح جميع الأحداث الـ 155'
                          : 'Unlock all 155 events',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gold.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gold.withAlpha(60)),
            ),
            child: Center(
              child: Text(
                _isAr ? 'قريباً' : 'Coming Soon',
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. Journey Mode card ────────────────────────────────────────────────

  String _mode = PrefsService.journeyMode;

  void _switchMode(String newMode) async {
    if (newMode == _mode) return;
    final confirmed = await showRawiDialog(
      context: context,
      title: _isAr ? 'تغيير النمط؟' : 'Switch mode?',
      body: _isAr
          ? 'سيُطبّق التغيير على الحدث التالي.'
          : 'This will take effect on your next event.',
      cancelLabel: _isAr ? 'إلغاء' : 'Cancel',
      confirmLabel: _isAr ? 'تأكيد' : 'Confirm',
      isAr: _isAr,
    );
    if (confirmed != true) return;
    await PrefsService.setJourneyMode(newMode);
    setState(() => _mode = newMode);
  }

  Widget _buildJourneyModeCard() {
    return Container(
      decoration: _sectionDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildModeOption(
            mode: 'explorer',
            icon: Icons.explore_rounded,
            titleEn: 'Explorer',
            titleAr: 'المستكشف',
            descEn: 'Explore scenes freely, discover hotspots in the fog, let dhikr fuel your light',
            descAr: 'استكشف المشاهد بحرية، اكتشف النقاط في الضباب، دع الذكر يغذّي نورك',
          ),
          const SizedBox(height: 10),
          _buildModeOption(
            mode: 'reader',
            icon: Icons.auto_stories_rounded,
            titleEn: 'Reader',
            titleAr: 'القارئ',
            descEn: 'Follow the guided path, all hotspots visible, focus on reading and reflection',
            descAr: 'اتّبع المسار المرسوم، جميع النقاط ظاهرة، ركّز على القراءة والتأمل',
          ),
        ],
      ),
    );
  }

  Widget _buildModeOption({
    required String mode,
    required IconData icon,
    required String titleEn,
    required String titleAr,
    required String descEn,
    required String descAr,
  }) {
    final selected = _mode == mode;
    return GestureDetector(
      onTap: () => _switchMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected ? AppColors.gold.withAlpha(15) : Colors.transparent,
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.textMuted.withAlpha(30),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 24,
                color: selected ? AppColors.gold : AppColors.textMuted),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isAr ? titleAr : titleEn,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? AppColors.gold
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isAr ? descAr : descEn,
                    textDirection:
                        _isAr ? TextDirection.rtl : TextDirection.ltr,
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: AppColors.textMuted.withAlpha(150),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 8),
                child: Icon(Icons.check_circle_rounded,
                    size: 20, color: AppColors.gold),
              ),
          ],
        ),
      ),
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
          // R20-A1: Text size as 3-segment bar (S / M / L).
          _segmentedPrefRow(
            icon: Icons.text_fields_rounded,
            label: _isAr ? 'حجم الخط' : 'Text Size',
            picker: SegmentedPicker<double>(
              values: const [
                _textScaleSmall,
                _textScaleMedium,
                _textScaleLarge,
              ],
              labels: _isAr
                  ? const ['ص', 'و', 'ك']
                  : const ['S', 'M', 'L'],
              selected: _textScaleKey,
              onChanged: _setTextSize,
            ),
          ),
          Divider(color: AppColors.gold.withAlpha(20), height: 24),
          // R21-04: Joystick position (Explorer Mode only).
          // R27 S1.3-SET2: added 4th "Hide" option for users who
          // prefer touch-to-move exclusively. When selected, the
          // joystick doesn't render on event scenes; touch-to-move
          // on the scene BG continues working as always.
          _segmentedPrefRow(
            icon: Icons.gamepad_rounded,
            label: _isAr ? 'موقع عصا التحكم' : 'Joystick Position',
            picker: SegmentedPicker<String>(
              values: const ['left', 'center', 'right', 'hidden'],
              labels: _isAr
                  ? const ['ي', 'و', 'ش', '⊘']
                  : const ['L', 'C', 'R', '⊘'],
              selected: _joystickPos,
              onChanged: _setJoystickPos,
            ),
          ),
          Divider(color: AppColors.gold.withAlpha(20), height: 24),
          // R28 S1-FEAT4: journey view default — List or Constellation.
          // Stacked layout (label row + full-width segmented below)
          // because "Journey view default" + "LIST"/"CONSTELLATION"
          // labels don't fit comfortably in the inline segmented-pref
          // row pattern used for shorter S/M/L + joystick pickers.
          _segmentedPrefRowStacked(
            icon: Icons.auto_awesome_rounded,
            label: _isAr ? 'طريقة عرض الرحلة' : 'Journey view default',
            picker: SegmentedPicker<String>(
              values: const ['list', 'constellation'],
              labels: _isAr
                  ? const ['قائمة', 'نجوم']
                  : const ['LIST', 'CONSTELLATION'],
              selected: _journeyView,
              onChanged: _setJourneyView,
              segmentWidth: null, // flex each segment to fill the row
            ),
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

  // R20-A1: Row with a trailing segmented picker instead of tappable chip.
  Widget _segmentedPrefRow({
    required IconData icon,
    required String label,
    required Widget picker,
  }) {
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
        picker,
      ],
    );
  }

  // R28 S1-FEAT4: stacked variant of [_segmentedPrefRow] — icon + label
  // on top, full-width picker below. Used when a 2-segment picker's
  // labels are too long to share a row with the setting label (e.g.
  // "Journey view default" + "LIST" / "CONSTELLATION").
  Widget _segmentedPrefRowStacked({
    required IconData icon,
    required String label,
    required Widget picker,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Icon(icon, size: 20, color: AppColors.gold.withAlpha(180)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.nunito(
                    fontSize: 15, color: AppColors.textPrimary),
                textDirection:
                    _isAr ? TextDirection.rtl : TextDirection.ltr,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        picker,
      ],
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
    // B30: SizedBox(width: infinity) so the card fills its container width
    // matching other settings section widths.
    return SizedBox(
      width: double.infinity,
      child: Container(
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
            // B27: triple-tap the version number to toggle the debug overlay.
            GestureDetector(
              onTap: _onVersionTap,
              behavior: HitTestBehavior.opaque,
              child: Text(
                'v1.0.0',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // R19-16: "Made with love in Amman" removed.
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
            // R25-S3-7: debug-only "Reset tutorials" affordance so QA can
            // re-trigger the Event 1 overlay + other first-time flows on
            // the same install. Compiled out of release builds.
            if (kDebugMode) ...[
              const SizedBox(height: 14),
              GestureDetector(
                onTap: _onResetTutorials,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.gold.withAlpha(120), width: 0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _isAr ? 'إعادة الدروس (QA)' : 'Reset tutorials (QA)',
                    textDirection:
                        _isAr ? TextDirection.rtl : TextDirection.ltr,
                    style: GoogleFonts.nunito(
                      color: AppColors.gold.withAlpha(200),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _onResetTutorials() async {
    await PrefsService.resetAllTutorials();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tutorials reset'),
        duration: Duration(milliseconds: 1000),
      ),
    );
  }

  // B27: triple-tap detection for version text → toggles debug overlay.
  int _versionTapCount = 0;
  DateTime _versionFirstTap = DateTime.fromMillisecondsSinceEpoch(0);

  void _onVersionTap() {
    final now = DateTime.now();
    if (now.difference(_versionFirstTap).inMilliseconds > 1200) {
      _versionTapCount = 1;
      _versionFirstTap = now;
      return;
    }
    _versionTapCount++;
    if (_versionTapCount >= 3) {
      _versionTapCount = 0;
      final newVal = !PrefsService.isDebugOverlayEnabled;
      PrefsService.setDebugOverlayEnabled(newVal);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newVal
              ? 'Debug overlay enabled'
              : 'Debug overlay disabled'),
          duration: const Duration(milliseconds: 1000),
        ),
      );
      setState(() {});
    }
  }

  // ── 5. Coming Soon (R23 feature flags) ───────────────────────────────

  static const _comingSoonFeatures = [
    (icon: Icons.child_care_rounded, en: 'Little Rawi Mode', ar: 'وضع الراوي الصغير', descEn: 'Simplified content for ages 4-10', descAr: 'محتوى مبسّط للأعمار ٤-١٠'),
    (icon: Icons.translate_rounded, en: 'More Languages', ar: 'لغات إضافية', descEn: 'Turkish, Urdu, Bahasa, French', descAr: 'تركي، أوردو، بهاسا، فرنسي'),
    (icon: Icons.timer_rounded, en: 'Challenge Mode', ar: 'وضع التحدّي', descEn: 'Timed quiz on mastered content', descAr: 'اختبار سريع على ما أتقنته'),
    (icon: Icons.map_rounded, en: 'Mastery Map', ar: 'خريطة الإتقان', descEn: 'Visualize your Seerah knowledge', descAr: 'تصوّر معرفتك بالسيرة'),
    (icon: Icons.auto_stories_rounded, en: 'Manuscripts', ar: 'المخطوطات', descEn: 'Collectible historical documents', descAr: 'وثائق تاريخية قابلة للجمع'),
  ];

  Widget _buildComingSoonCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: _sectionDecoration,
      child: Column(
        children: [
          for (int i = 0; i < _comingSoonFeatures.length; i++) ...[
            if (i > 0)
              Divider(color: AppColors.gold.withAlpha(20), height: 20),
            _comingSoonRow(_comingSoonFeatures[i]),
          ],
        ],
      ),
    );
  }

  Widget _comingSoonRow(
      ({IconData icon, String en, String ar, String descEn, String descAr}) f) {
    return Row(
      textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Icon(f.icon, size: 20, color: AppColors.gold.withAlpha(120)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isAr ? f.ar : f.en,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
              ),
              const SizedBox(height: 2),
              Text(
                _isAr ? f.descAr : f.descEn,
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  color: AppColors.textMuted.withAlpha(160),
                ),
                textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.gold.withAlpha(15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.gold.withAlpha(50)),
          ),
          child: Text(
            _isAr ? 'قريباً' : 'Soon',
            style: GoogleFonts.nunito(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.gold.withAlpha(180),
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }

  // ── 6. Reset Journey card ───────────────────────────────────────────────

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
