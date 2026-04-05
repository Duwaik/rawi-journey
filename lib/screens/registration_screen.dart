import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../services/audio_service.dart';
import '../services/prefs_service.dart';
import '../widgets/rawi_dialog.dart';
import 'event_list_screen.dart';

/// 2-step registration flow shown on first launch after intro cinematic.
/// Screen 1: Identity (name + companion)
/// Screen 2: Language
/// Background: blurred cinematic desert scene throughout.
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _pageCtrl = PageController();
  final _nameCtrl = TextEditingController();
  final _nameFocus = FocusNode();
  int _currentPage = 0;
  String _selectedGender = 'male';
  late String _selectedLang;

  static const _totalPages = 2;

  @override
  void initState() {
    super.initState();
    final deviceLang = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    _selectedLang = deviceLang == 'ar' ? 'ar' : 'en';
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _nextPage() {
    FocusScope.of(context).unfocus();
    if (_currentPage < _totalPages - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    FocusScope.of(context).unfocus();
    if (_currentPage > 0) {
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finish() async {
    final name = _nameCtrl.text.trim();
    if (name.isNotEmpty) await PrefsService.setUserName(name);
    await PrefsService.setUserGender(_selectedGender);
    await PrefsService.setLanguage(_selectedLang);
    await PrefsService.setOnboardingComplete();

    AudioService.fadeOut(duration: const Duration(milliseconds: 2500));

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const EventListScreen(),
        transitionsBuilder: (context, anim, secondaryAnimation, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = _selectedLang == 'ar';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_currentPage > 0) {
          _prevPage();
        } else {
          final confirmed = await showRawiDialog(
            context: context,
            title: isAr ? 'مغادرة؟' : 'Exit?',
            body: isAr ? 'هل تريد الخروج؟' : 'Are you sure you want to exit?',
            cancelLabel: isAr ? 'البقاء' : 'Stay',
            confirmLabel: isAr ? 'خروج' : 'Exit',
            isAr: isAr,
            confirmDanger: true,
          );
          if (confirmed == true && context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Blurred cinematic background ──────────────────────────
            Image.asset(
              'assets/scenes/scene_welcome.jpg',
              fit: BoxFit.cover,
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                color: Colors.black.withAlpha(180),
              ),
            ),

            // ── Content ───────────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  // Top bar: back arrow + dots
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Row(
                      children: [
                        if (_currentPage > 0)
                          IconButton(
                            onPressed: _prevPage,
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                size: 20, color: AppColors.textMuted),
                          )
                        else
                          const SizedBox(width: 48),
                        const Spacer(),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(_totalPages, (i) {
                            final active = i == _currentPage;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: active ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: active
                                    ? AppColors.gold
                                    : AppColors.textMuted.withAlpha(60),
                              ),
                            );
                          }),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // Pages
                  Expanded(
                    child: PageView(
                      controller: _pageCtrl,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      children: [
                        _buildIdentityPage(isAr),
                        _buildLanguagePage(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  // ── Page 1: Identity (name + companion) ───────────────────────────────────

  Widget _buildIdentityPage(bool isAr) {
    final name = _nameCtrl.text.trim();
    final valid = name.length >= 2 && name.length <= 15;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Text(
            isAr ? 'من يحمل هذه الرواية؟' : 'Who carries the story?',
            textAlign: TextAlign.center,
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            style: GoogleFonts.cinzelDecorative(
              fontSize: 20,
              color: AppColors.gold,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // Name input
          TextField(
            controller: _nameCtrl,
            focusNode: _nameFocus,
            textAlign: TextAlign.center,
            maxLength: 15,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
            style: GoogleFonts.nunito(
              fontSize: 20,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: isAr ? 'اسمك هنا' : 'Your name here',
              hintStyle: GoogleFonts.nunito(
                fontSize: 18,
                color: AppColors.textMuted.withAlpha(100),
              ),
              counterText: isAr ? '2–15 حرفاً' : '2–15 characters',
              counterStyle: GoogleFonts.nunito(
                fontSize: 11,
                color: AppColors.textMuted.withAlpha(80),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: AppColors.gold.withAlpha(80), width: 1.5),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.gold, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Companion selection
          Text(
            isAr ? 'اختر رفيقك' : 'Choose your companion',
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: AppColors.textMuted.withAlpha(160),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _GenderCard(
                imagePath: 'assets/figures/companion_male.jpg',
                label: isAr ? 'راوي' : 'Rawi',
                selected: _selectedGender == 'male',
                onTap: () {
                  FocusScope.of(context).unfocus();
                  setState(() => _selectedGender = 'male');
                },
              ),
              const SizedBox(width: 24),
              _GenderCard(
                imagePath: 'assets/figures/companion_female.jpg',
                label: isAr ? 'راوية' : 'Rawiah',
                selected: _selectedGender == 'female',
                onTap: () {
                  FocusScope.of(context).unfocus();
                  setState(() => _selectedGender = 'female');
                },
              ),
            ],
          ),
          const SizedBox(height: 32),

          _ContinueButton(
            label: isAr ? 'متابعة' : 'Continue',
            onPressed: valid ? _nextPage : null,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Page 2: Language ──────────────────────────────────────────────────────

  Widget _buildLanguagePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 3),
          Text(
            'Choose your language',
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzelDecorative(
              fontSize: 22,
              color: AppColors.gold,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'اختر لغتك',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.lora(
              fontSize: 18,
              fontStyle: FontStyle.normal,
              color: AppColors.gold.withAlpha(160),
            ),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LanguageCard(
                flag: '🇬🇧',
                label: 'English',
                selected: _selectedLang == 'en',
                onTap: () => setState(() => _selectedLang = 'en'),
              ),
              const SizedBox(width: 24),
              _LanguageCard(
                flag: '🇸🇦',
                label: 'العربية',
                selected: _selectedLang == 'ar',
                onTap: () => setState(() => _selectedLang = 'ar'),
              ),
            ],
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: 260,
            height: 54,
            child: ElevatedButton(
              onPressed: _finish,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.bg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                _selectedLang == 'ar' ? 'ابدأ الرحلة  ←' : 'Start the Journey  →',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const Spacer(flex: 4),
        ],
      ),
    );
  }
}

// ── Reusable Widgets ────────────────────────────────────────────────────────

class _ContinueButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _ContinueButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? AppColors.gold : AppColors.gold.withAlpha(60),
          foregroundColor: enabled ? AppColors.bg : AppColors.textMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String imagePath;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.imagePath,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.gold : AppColors.textMuted.withAlpha(40),
                width: selected ? 3 : 1.5,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.gold.withAlpha(40),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: AnimatedScale(
              scale: selected ? 1.05 : 0.95,
              duration: const Duration(milliseconds: 300),
              child: ClipOval(
                child: Image.asset(
                  imagePath,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? AppColors.gold : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 130,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.gold.withAlpha(18)
              : AppColors.card.withAlpha(180),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.gold
                : AppColors.textMuted.withAlpha(40),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.gold.withAlpha(30),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Text(flag, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? AppColors.gold : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
