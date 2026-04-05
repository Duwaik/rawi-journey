import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../services/audio_service.dart';
import '../services/prefs_service.dart';
import 'registration_screen.dart';

/// First-launch cinematic intro — sets the tone before registration.
/// Sequential text fades over the welcome scene image.
/// Shows BOTH English and Arabic simultaneously (user hasn't chosen language yet).
/// "Begin" CTA at end → RegistrationScreen.
class IntroCinematicScreen extends StatefulWidget {
  const IntroCinematicScreen({super.key});

  @override
  State<IntroCinematicScreen> createState() => _IntroCinematicScreenState();
}

class _IntroCinematicScreenState extends State<IntroCinematicScreen>
    with SingleTickerProviderStateMixin {
  // Note: "Witness history. Carry the story." intentionally NOT in this list.
  // It's shown ONLY in the CTA section below (with the Begin button) to avoid
  // showing the same text twice in a row.
  static const _lines = <_IntroLine>[
    _IntroLine('570 CE', '570 ميلادي'),
    _IntroLine('The Arabian Peninsula...', 'الجزيرة العربية...'),
    _IntroLine(
      'A world waiting for a message.',
      'العالم ينتظر رسالة.',
    ),
    _IntroLine(
      'You are the Rawi\n"The Narrator"',
      'أنت الراوي',
    ),
  ];

  late final AnimationController _ctrl;

  /// Each line gets: 600ms fade-in, 1800ms hold, 400ms fade-out = 2800ms.
  static const _lineDuration = 2800;
  static const _fadeIn = 600;
  static const _hold = 1800;

  int _currentLine = 0;
  double _lineOpacity = 0.0;
  bool _showCta = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this);
    // Start onboarding ambient (carries through intro + registration)
    _startIntroAmbient();
    _runSequence();
  }

  Future<void> _startIntroAmbient() async {
    if (!PrefsService.musicEnabled) return;
    await AudioService.playAmbient(
      'assets/audio/ambient/ambient_intro.mp3',
      volume: 0.0,
    );
    if (_disposed) return;
    await AudioService.fadeAmbientTo(0.22,
        duration: const Duration(milliseconds: 1500));
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
    // Don't stop onboarding music — it carries into registration
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
    final line = _lines[_currentLine];
    final isFirstLine = _currentLine == 0;

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

          // ── Bilingual text lines ─────────────────────────────────
          if (!_showCta)
            IgnorePointer(
              child: Center(
                child: Opacity(
                  opacity: _lineOpacity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // English (primary)
                        Text(
                          line.en,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cinzelDecorative(
                            fontSize: isFirstLine ? 36 : 22,
                            fontWeight: isFirstLine
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: AppColors.gold,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Arabic (secondary — explicit normal, never italic)
                        Text(
                          line.ar,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.lora(
                            fontSize: isFirstLine ? 28 : 18,
                            fontStyle: FontStyle.normal,
                            color: AppColors.gold.withAlpha(180),
                            height: 1.6,
                          ),
                        ),
                      ],
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
                      'Witness history. Carry the story.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 22,
                        color: AppColors.gold,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'كن شاهداً. احمل الرواية.',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.lora(
                        fontSize: 18,
                        fontStyle: FontStyle.normal,
                        color: AppColors.gold.withAlpha(180),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 48),
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
                          'Begin / ابدأ',
                          style: GoogleFonts.lora(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Skip button REMOVED — intro only shows once, mandatory
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
