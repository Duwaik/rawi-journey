import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../services/prefs_service.dart';

/// R27 S1-TENT1: first-visit tent tutorial cinematic.
///
/// Reuses the Witness Moment visual style — gold italic serif on
/// black with sparse gold-dust particles — but advances on tap
/// instead of auto-timer, because 5 screens on auto-timer would
/// exceed the attention budget for a first-time tutorial.
///
/// Gated by [PrefsService.isTentTutorialShown]; [RawiTentScreen]
/// pushes this in `initState` only when the flag is false, then
/// calls [PrefsService.setTentTutorialShown] before popping back.
class TentTutorialScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const TentTutorialScreen({super.key, required this.onComplete});

  @override
  State<TentTutorialScreen> createState() => _TentTutorialScreenState();
}

class _TentTutorialScreenState extends State<TentTutorialScreen> {
  int _currentScreen = 0;
  double _opacity = 0.0;
  bool _disposed = false;
  bool _advancing = false;

  bool get _isAr => PrefsService.isAr;

  List<String> get _linesEn => const [
        'Welcome to your tent, Rawi.',
        'This is your home between journeys.',
        "Here you'll find your Light, your progress, "
            'your dhikr, and the paths ahead.',
        'When an event ends, your tent will welcome you back.',
        'Ready when you are.',
      ];

  List<String> get _linesAr => const [
        'أهلاً بك في خيمتك، أيها الراوي.',
        'هذا بيتك بين الرحلات.',
        'هنا تجد نورك، ورحلتك، وذكرك، والطرق أمامك.',
        'عندما ينتهي حدث، ستستقبلك خيمتك من جديد.',
        'متى ما كنت مستعداً.',
      ];

  @override
  void initState() {
    super.initState();
    _fadeIn();
  }

  Future<void> _fadeIn() async {
    await _animateOpacity(1.0, 500);
  }

  Future<void> _advance() async {
    if (_advancing || _disposed) return;
    _advancing = true;
    await _animateOpacity(0.0, 300);
    if (_disposed) return;
    final lines = _isAr ? _linesAr : _linesEn;
    if (_currentScreen + 1 >= lines.length) {
      // Final screen done — flip the pref, pop back to tent.
      await PrefsService.setTentTutorialShown();
      if (_disposed) return;
      widget.onComplete();
      return;
    }
    setState(() => _currentScreen++);
    await _animateOpacity(1.0, 500);
    _advancing = false;
  }

  Future<void> _animateOpacity(double target, int ms) async {
    final steps = (ms / 16).round();
    final start = _opacity;
    final delta = target - start;
    for (int s = 1; s <= steps; s++) {
      if (_disposed) return;
      await Future.delayed(const Duration(milliseconds: 16));
      if (_disposed) return;
      setState(() => _opacity = start + delta * (s / steps));
    }
    if (!_disposed) setState(() => _opacity = target);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lines = _isAr ? _linesAr : _linesEn;
    final text = lines[_currentScreen];
    final linesTotal = lines.length;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _advance,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _TentTutorialParticlePainter()),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Opacity(
                  opacity: _opacity,
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    textDirection:
                        _isAr ? TextDirection.rtl : TextDirection.ltr,
                    style: GoogleFonts.lora(
                      fontSize: 22,
                      fontStyle:
                          _isAr ? FontStyle.normal : FontStyle.italic,
                      color: AppColors.gold,
                      height: 1.8,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  _isAr ? 'خيمتك' : 'Your Tent',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: AppColors.gold.withAlpha(80),
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            // Tap-to-advance hint (dim, fades when user has tapped at
            // least once so it doesn't linger).
            if (_currentScreen == 0)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 28,
                left: 0,
                right: 0,
                child: Center(
                  child: Opacity(
                    opacity: _opacity * 0.7,
                    child: Text(
                      _isAr ? 'اضغط للمتابعة' : 'Tap to continue',
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        color: AppColors.gold.withAlpha(100),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            // Progress dots at the bottom so the user knows how far
            // through the sequence they are.
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 12,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(linesTotal, (i) {
                    final active = i == _currentScreen;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        width: active ? 8 : 6,
                        height: active ? 8 : 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active
                              ? AppColors.gold
                              : AppColors.gold.withAlpha(60),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Matches the Witness Moment particle layout so the tutorial feels
/// like the same visual family.
class _TentTutorialParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.gold.withAlpha(25);
    final positions = [
      Offset(size.width * 0.15, size.height * 0.20),
      Offset(size.width * 0.82, size.height * 0.15),
      Offset(size.width * 0.30, size.height * 0.75),
      Offset(size.width * 0.70, size.height * 0.80),
      Offset(size.width * 0.50, size.height * 0.10),
      Offset(size.width * 0.90, size.height * 0.50),
      Offset(size.width * 0.10, size.height * 0.55),
      Offset(size.width * 0.60, size.height * 0.30),
      Offset(size.width * 0.40, size.height * 0.90),
      Offset(size.width * 0.75, size.height * 0.65),
    ];
    for (final p in positions) {
      canvas.drawCircle(p, 1.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
