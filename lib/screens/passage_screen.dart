import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../models/passage_moment.dart';
import '../services/audio_service.dart';
import '../services/prefs_service.dart';

/// R20 Part E — "The Passage / المعبر".
///
/// Full-screen cinematic era transition. Plays once after pivotal events
/// (E14 / E42 / E47 / E82 / E120). No gate, no quiz — a breath between
/// eras. The user reads the title + a single Qur'anic verse, then taps
/// "Continue the Journey" to proceed.
///
/// Sequence (~10s total):
///   0.0s → black
///   0.5s → gradient + particles fade in
///   1.5s → EN title fade in
///   2.3s → AR title fade in
///   3.5s → quote fade in
///   4.8s → Continue button fade in
class PassageScreen extends StatefulWidget {
  final PassageMoment passage;
  final VoidCallback onComplete;

  const PassageScreen({
    super.key,
    required this.passage,
    required this.onComplete,
  });

  @override
  State<PassageScreen> createState() => _PassageScreenState();
}

class _PassageScreenState extends State<PassageScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgFade;
  late final AnimationController _titleEnFade;
  late final AnimationController _titleArFade;
  late final AnimationController _quoteFade;
  late final AnimationController _continueFade;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _bgFade = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _titleEnFade = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _titleArFade = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _quoteFade = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _continueFade = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    // LOCKED RULE: all audio transitions are fades, not cuts.
    AudioService.fadeOut(duration: const Duration(milliseconds: 400));

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _bgFade.forward();

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    _titleEnFade.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    _titleArFade.forward();

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    _quoteFade.forward();

    await Future.delayed(const Duration(milliseconds: 1300));
    if (!mounted) return;
    _continueFade.forward();
  }

  @override
  void dispose() {
    _bgFade.dispose();
    _titleEnFade.dispose();
    _titleArFade.dispose();
    _quoteFade.dispose();
    _continueFade.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onContinue() {
    HapticFeedback.lightImpact();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = PrefsService.isAr;
    final p = widget.passage;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── Layer 1: atmospheric gradient (fade-in) ───────────────────
            FadeTransition(
              opacity: _bgFade,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.3),
                    radius: 1.4,
                    colors: [
                      AppColors.gold.withAlpha(40),
                      const Color(0xFF1A1208).withAlpha(180),
                      Colors.black,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // ── Layer 2: letterbox bars (top/bottom) ──────────────────────
            FadeTransition(
              opacity: _bgFade,
              child: Column(
                children: [
                  Container(
                    height: 48,
                    color: Colors.black,
                  ),
                  const Spacer(),
                  Container(
                    height: 48,
                    color: Colors.black,
                  ),
                ],
              ),
            ),

            // ── Layer 3: content ──────────────────────────────────────────
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),

                    // ── Titles (EN + AR stacked) ──────────────────────────
                    FadeTransition(
                      opacity: _titleEnFade,
                      child: Text(
                        isAr ? p.titleAr : p.titleEn,
                        textAlign: TextAlign.center,
                        textDirection:
                            isAr ? TextDirection.rtl : TextDirection.ltr,
                        style: GoogleFonts.cinzelDecorative(
                          fontSize: 24,
                          color: AppColors.gold,
                          letterSpacing: isAr ? 0 : 2,
                          height: 1.35,
                          shadows: [
                            Shadow(
                              color: AppColors.gold.withAlpha(80),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FadeTransition(
                      opacity: _titleArFade,
                      child: Text(
                        isAr ? p.titleEn : p.titleAr,
                        textAlign: TextAlign.center,
                        textDirection:
                            isAr ? TextDirection.ltr : TextDirection.rtl,
                        style: GoogleFonts.lora(
                          fontSize: 18,
                          color: AppColors.gold.withAlpha(180),
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── Gold divider ──────────────────────────────────────
                    FadeTransition(
                      opacity: _titleArFade,
                      child: Container(
                        width: 60,
                        height: 1,
                        color: AppColors.gold.withAlpha(100),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── Quote (bilingual) ─────────────────────────────────
                    FadeTransition(
                      opacity: _quoteFade,
                      child: Column(
                        children: [
                          Text(
                            '﴿ ${p.quoteAr} ﴾',
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: GoogleFonts.amiri(
                              fontSize: 22,
                              color: AppColors.textPrimary,
                              height: 1.8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            '"${p.quoteEn}"',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lora(
                              fontSize: 14,
                              color: AppColors.textBody.withAlpha(200),
                              fontStyle: FontStyle.italic,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '(${p.quoteSource})',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              color: AppColors.gold.withAlpha(140),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 4),

                    // ── Continue button (fades in last) ───────────────────
                    FadeTransition(
                      opacity: _continueFade,
                      child: GestureDetector(
                        onTap: _onContinue,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withAlpha(18),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.gold.withAlpha(140),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            isAr ? 'تابع الرحلة' : 'Continue the Journey',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: AppColors.gold,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                            ),
                            textDirection:
                                isAr ? TextDirection.rtl : TextDirection.ltr,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
