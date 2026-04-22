import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../services/prefs_service.dart';

/// R27 S1-TENT1 + S1.1-TENT4: first-visit tent tutorial cinematic.
///
/// Plays on top of the tent (not a black background) so the user
/// sees where they are while the cinematic text walks them through
/// what's around them. The caller pushes this via
/// `PageRouteBuilder(opaque: false)` so the tent underneath remains
/// visible; this screen paints a dim scrim (0 → 0.50 over 400 ms)
/// between the tent and the text so the gold stays readable.
///
/// Visual language still reuses Witness Moment — gold italic Lora
/// serif + sparse gold-dust particles — but advances on tap.
///
/// Flag persistence: [PrefsService.setTentTutorialShown] fires on
/// the FIRST tap (not on final-screen completion), so a force-quit
/// mid-sequence doesn't cause the cinematic to replay on next launch
/// — user has seen enough by screen 2 to know what it is.
class TentTutorialScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const TentTutorialScreen({super.key, required this.onComplete});

  @override
  State<TentTutorialScreen> createState() => _TentTutorialScreenState();
}

class _TentTutorialScreenState extends State<TentTutorialScreen>
    with SingleTickerProviderStateMixin {
  int _currentScreen = 0;
  double _opacity = 0.0;
  double _dimOpacity = 0.0;
  bool _disposed = false;
  bool _advancing = false;
  bool _flagSaved = false;

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
    _runInitialSequence();
  }

  /// Dim tween first (400 ms) → text fade-in (500 ms). User sees
  /// the tent behind the dim as the darkness lands.
  /// R27 S1.2-TENT4: target bumped 0.50 → 0.55 for clearer contrast
  /// against bright tent variants (tent_dawn.jpg in particular).
  Future<void> _runInitialSequence() async {
    await _animateDim(0.55, 400);
    if (_disposed) return;
    await _animateOpacity(1.0, 500);
  }

  Future<void> _advance() async {
    if (_advancing || _disposed) return;
    _advancing = true;

    // R27 S1.1-TENT4: save flag on FIRST tap so a force-quit
    // mid-cinematic doesn't replay on next launch.
    if (!_flagSaved) {
      _flagSaved = true;
      await PrefsService.setTentTutorialShown();
      if (_disposed) return;
    }

    await _animateOpacity(0.0, 300);
    if (_disposed) return;
    final lines = _isAr ? _linesAr : _linesEn;
    if (_currentScreen + 1 >= lines.length) {
      // Final screen done — lift the dim scrim, then invoke the
      // caller-supplied completion (which typically pops back to
      // tent and triggers the icon coach-mark tutorial).
      await _animateDim(0.0, 400);
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

  Future<void> _animateDim(double target, int ms) async {
    final steps = (ms / 16).round();
    final start = _dimOpacity;
    final delta = target - start;
    for (int s = 1; s <= steps; s++) {
      if (_disposed) return;
      await Future.delayed(const Duration(milliseconds: 16));
      if (_disposed) return;
      setState(() => _dimOpacity = start + delta * (s / steps));
    }
    if (!_disposed) setState(() => _dimOpacity = target);
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
      // R27 S1.1-TENT4: transparent so the tent BG behind the route
      // is visible. The dim scrim painted below handles contrast.
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _advance,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // R27 S1.2-TENT4: dim scrim over the tent.
            // S1.1 used `Colors.black.withValues(alpha: _dimOpacity)` —
            // device verify showed it never landed (tent stayed fully
            // bright). Replaced with the explicit `Color.fromARGB` form
            // which is less sensitive to Flutter's float-alpha precision
            // drift, and using a `ColoredBox` so Flutter short-circuits
            // the paint when alpha is 0.
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color: Color.fromARGB(
                      (255 * _dimOpacity).round(), 0, 0, 0),
                ),
              ),
            ),
            // Particles (same positions as Witness Moment).
            CustomPaint(painter: _TentTutorialParticlePainter()),
            // Centered line.
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
                child: Opacity(
                  opacity: _dimOpacity * 2, // fades in with the scrim
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
            ),
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
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 12,
              left: 0,
              right: 0,
              child: Center(
                child: Opacity(
                  opacity: _dimOpacity * 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(linesTotal, (i) {
                      final active = i == _currentScreen;
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 3),
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
            ),
          ],
        ),
      ),
    );
  }
}

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
