import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../services/prefs_service.dart';
import 'registration_screen.dart';

/// First-launch cinematic intro — sets the tone before registration.
/// Sequential text fades over the welcome scene image.
/// Skip button top-right. "Begin" CTA at end → RegistrationScreen.
class IntroCinematicScreen extends StatefulWidget {
  const IntroCinematicScreen({super.key});

  @override
  State<IntroCinematicScreen> createState() => _IntroCinematicScreenState();
}

class _IntroCinematicScreenState extends State<IntroCinematicScreen>
    with SingleTickerProviderStateMixin {
  static const _lines = <_IntroLine>[
    _IntroLine('570 CE', 'الميلاد ٥٧٠'),
    _IntroLine('The Arabian Peninsula...', 'الجزيرة العربية...'),
    _IntroLine(
      'A world waiting for a message.',
      'عالم ينتظر رسالة.',
    ),
    _IntroLine(
      'You are the Rawi — the narrator.',
      'أنت الراوي.',
    ),
    _IntroLine(
      'Witness history. Carry the story.',
      'كن شاهداً. احمل الرواية.',
    ),
  ];

  late final AnimationController _ctrl;

  /// Each line gets: 600ms fade-in, 1800ms hold, 400ms fade-out = 2800ms.
  /// Total: 5 lines x 2800ms = 14000ms + 600ms buffer for CTA.
  static const _lineDuration = 2800;
  static const _fadeIn = 600;
  static const _hold = 1800;
  // fade-out occupies the remainder (_lineDuration - _fadeIn - _hold = 400ms)

  int _currentLine = 0;
  double _lineOpacity = 0.0;
  bool _showCta = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this);
    _runSequence();
  }

  Future<void> _runSequence() async {
    for (int i = 0; i < _lines.length; i++) {
      if (_disposed) return;
      setState(() {
        _currentLine = i;
        _lineOpacity = 0.0;
      });

      // Fade in
      await _animateOpacity(1.0, _fadeIn);
      if (_disposed) return;

      // Hold
      await Future.delayed(const Duration(milliseconds: _hold));
      if (_disposed) return;

      // Fade out
      await _animateOpacity(0.0, _lineDuration - _fadeIn - _hold);
      if (_disposed) return;
    }

    // Show CTA
    if (!_disposed) setState(() => _showCta = true);
  }

  Future<void> _animateOpacity(double target, int ms) async {
    if (_disposed) return;
    final steps = (ms / 16).round(); // ~60fps
    final start = _lineOpacity;
    final delta = target - start;
    for (int s = 1; s <= steps; s++) {
      if (_disposed) return;
      await Future.delayed(const Duration(milliseconds: 16));
      if (_disposed) return;
      setState(() => _lineOpacity = start + delta * (s / steps));
    }
    if (!_disposed) setState(() => _lineOpacity = target);
  }

  void _proceed() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RegistrationScreen(),
        transitionsBuilder: (context, anim, secondaryAnimation, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use device locale since user hasn't selected language yet
    final deviceLocale = View.of(context).platformDispatcher.locale.languageCode;
    final isAr = PrefsService.language != 'en' ? PrefsService.isAr : deviceLocale == 'ar';
    final line = _lines[_currentLine];
    final text = isAr ? line.ar : line.en;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image ──────────────────────────────────────
          Image.asset(
            'assets/scenes/scene_welcome.jpg',
            fit: BoxFit.cover,
          ),

          // ── Dark gradient overlay ─────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(120),
                  Colors.black.withAlpha(80),
                  Colors.black.withAlpha(180),
                  Colors.black.withAlpha(240),
                ],
                stops: const [0.0, 0.3, 0.6, 1.0],
              ),
            ),
          ),

          // ── Centered text line ────────────────────────────────────
          if (!_showCta)
            IgnorePointer(
            child: Center(
              child: Opacity(
                opacity: _lineOpacity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                    style: GoogleFonts.cinzelDecorative(
                      fontSize: _currentLine == 0 ? 36 : 22,
                      fontWeight: _currentLine == 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: AppColors.gold,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ),
            ),

          // ── CTA — "Begin" ─────────────────────────────────────────
          if (_showCta)
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                builder: (_, v, child) => Opacity(opacity: v, child: child),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isAr ? 'كن شاهداً. احمل الرواية.' : 'Witness history. Carry the story.',
                      textAlign: TextAlign.center,
                      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                      style: GoogleFonts.lora(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: AppColors.gold.withAlpha(200),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 200,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _proceed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.bg,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          isAr ? 'ابدأ' : 'Begin',
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Skip button ───────────────────────────────────────────
          if (!_showCta)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 16,
              child: GestureDetector(
                onTap: _proceed,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    isAr ? 'تخطي' : 'Skip',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: AppColors.textMuted.withAlpha(180),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _IntroLine {
  final String en;
  final String ar;
  const _IntroLine(this.en, this.ar);
}
