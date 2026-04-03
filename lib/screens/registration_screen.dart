import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../services/prefs_service.dart';
import 'event_list_screen.dart';

/// 4-step registration flow shown on first launch after intro cinematic.
/// Steps: Name → Gender → Language → Milestone Preview.
/// Horizontal PageView with dot indicators.
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _pageCtrl = PageController();
  final _nameCtrl = TextEditingController();
  int _currentPage = 0;
  String _selectedGender = 'male';
  String _selectedLang = 'en';

  static const _totalPages = 4;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (_currentPage < _totalPages - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
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
        // Back goes to previous page, or shows exit dialog on first page
        if (_currentPage > 0) {
          _prevPage();
        } else {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(isAr ? 'مغادرة؟' : 'Exit?',
                  style: GoogleFonts.nunito(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              content: Text(isAr ? 'هل تريد الخروج؟' : 'Are you sure you want to exit?',
                  style: GoogleFonts.nunito(color: AppColors.textBody)),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false),
                    child: Text(isAr ? 'البقاء' : 'Stay', style: GoogleFonts.nunito(color: AppColors.gold))),
                TextButton(onPressed: () => Navigator.pop(ctx, true),
                    child: Text(isAr ? 'خروج' : 'Exit', style: GoogleFonts.nunito(color: Colors.redAccent, fontWeight: FontWeight.bold))),
              ],
            ),
          );
          if (confirmed == true && context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar: back arrow + dots ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  // Back arrow (hidden on first page)
                  if (_currentPage > 0)
                    IconButton(
                      onPressed: _prevPage,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20, color: AppColors.textMuted),
                    )
                  else
                    const SizedBox(width: 48),

                  const Spacer(),

                  // Page dots
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

            // ── Pages ──────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildNamePage(isAr),
                  _buildGenderPage(isAr),
                  _buildLanguagePage(),
                  _buildMilestonePage(isAr),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  // ── Page 1: Name ────────────────────────────────────────────────────────

  Widget _buildNamePage(bool isAr) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 3),
          Text(
            isAr ? 'ما اسمك يا مسافر؟' : 'What shall we call you,\ntraveler?',
            textAlign: TextAlign.center,
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            style: GoogleFonts.cinzelDecorative(
              fontSize: 22,
              color: AppColors.gold,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _nameCtrl,
            textAlign: TextAlign.center,
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
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: AppColors.gold.withAlpha(80), width: 1.5),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.gold, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 48),
          _ContinueButton(
            label: isAr ? 'التالي' : 'Continue',
            onPressed: _nextPage,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _nextPage,
            child: Text(
              isAr ? 'تخطي' : 'Skip',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: AppColors.textMuted.withAlpha(150),
              ),
            ),
          ),
          const Spacer(flex: 4),
        ],
      ),
    );
  }

  // ── Page 2: Gender ──────────────────────────────────────────────────────

  Widget _buildGenderPage(bool isAr) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 3),
          Text(
            isAr ? 'اختر رفيقك' : 'Choose your companion',
            textAlign: TextAlign.center,
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            style: GoogleFonts.cinzelDecorative(
              fontSize: 22,
              color: AppColors.gold,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _GenderCard(
                imagePath: 'assets/figures/companion_male.jpg',
                label: isAr ? 'ذكر' : 'Male',
                selected: _selectedGender == 'male',
                onTap: () => setState(() => _selectedGender = 'male'),
              ),
              const SizedBox(width: 24),
              _GenderCard(
                imagePath: 'assets/figures/companion_female.jpg',
                label: isAr ? 'أنثى' : 'Female',
                selected: _selectedGender == 'female',
                onTap: () => setState(() => _selectedGender = 'female'),
              ),
            ],
          ),
          const SizedBox(height: 48),
          _ContinueButton(
            label: isAr ? 'التالي' : 'Continue',
            onPressed: _nextPage,
          ),
          const Spacer(flex: 4),
        ],
      ),
    );
  }

  // ── Page 3: Language ────────────────────────────────────────────────────

  Widget _buildLanguagePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 3),
          // Show both languages since user hasn't picked yet
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
              fontStyle: FontStyle.italic,
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
          _ContinueButton(
            label: _selectedLang == 'ar' ? 'التالي' : 'Continue',
            onPressed: _nextPage,
          ),
          const Spacer(flex: 4),
        ],
      ),
    );
  }

  // ── Page 4: Milestone Preview ───────────────────────────────────────────

  // Chapter data for cinematic preview
  static const _chapterData = <_ChapterInfo>[
    _ChapterInfo('JAHILIYYAH', 'الجاهلية', 'Pre-Islamic Arabia', 'الجزيرة قبل الإسلام', 2, true),
    _ChapterInfo('EARLY LIFE', 'النشأة', 'The Prophetic Childhood', 'الطفولة النبوية', 9, false),
    _ChapterInfo('MECCA', 'مكة المكرمة', 'The Call and the Struggle', 'الدعوة والابتلاء', 11, false),
    _ChapterInfo('MEDINA', 'المدينة المنورة', 'The Community and the Victory', 'المجتمع والنصر', 14, false),
  ];

  Widget _buildMilestonePage(bool isAr) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          const Spacer(flex: 2),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              isAr
                  ? 'رحلتك عبر أربعة فصول'
                  : 'Your journey spans four chapters',
              textAlign: TextAlign.center,
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              style: GoogleFonts.cinzelDecorative(
                fontSize: 20,
                color: AppColors.gold,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isAr ? '36 حدثاً عبر السيرة النبوية' : '36 events across the Prophetic era',
            style: GoogleFonts.nunito(
              color: AppColors.textMuted.withAlpha(120),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 28),

          // Chapters — cinematic text blocks
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                for (final ch in _chapterData) ...[
                  // Gold separator
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: AppColors.gold.withAlpha(ch.active ? 80 : 30),
                  ),
                  const SizedBox(height: 14),
                  // Chapter block
                  Opacity(
                    opacity: ch.active ? 1.0 : 0.45,
                    child: Column(
                      children: [
                        Text(
                          isAr ? ch.nameAr : ch.name,
                          style: GoogleFonts.nunito(
                            color: AppColors.gold,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isAr ? ch.subtitleAr : ch.subtitle,
                          style: GoogleFonts.lora(
                            color: const Color(0xFFD6CCBE),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isAr ? '${ch.eventCount} أحداث' : '${ch.eventCount} events',
                          style: GoogleFonts.nunito(
                            color: AppColors.textMuted.withAlpha(100),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                // Final separator
                Container(
                  width: double.infinity,
                  height: 1,
                  color: AppColors.gold.withAlpha(30),
                ),
              ],
            ),
          ),

          const Spacer(flex: 1),

          // CTA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SizedBox(
              width: double.infinity,
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
                  isAr ? 'ابدأ الرحلة  ←' : 'Start the Journey  →',
                  style: GoogleFonts.nunito(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

// ── Reusable Widgets ──────────────────────────────────────────────────────

class _ContinueButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ContinueButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.bg,
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
          // Circular image with gold border
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
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Label below circle
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 15,
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
              : AppColors.card,
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

class _ChapterInfo {
  final String name, nameAr, subtitle, subtitleAr;
  final int eventCount;
  final bool active;
  const _ChapterInfo(this.name, this.nameAr, this.subtitle, this.subtitleAr, this.eventCount, this.active);
}
