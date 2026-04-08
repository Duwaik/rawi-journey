import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../models/witness_intro.dart';
import '../services/prefs_service.dart';

/// Cinematic text crawl for major events. 3-4 lines fade in sequentially,
/// gold on black, with subtle particles. ~15 seconds total. Auto-advances.
/// No interaction — pure atmosphere.
class WitnessMomentScreen extends StatefulWidget {
  final WitnessIntro intro;
  final VoidCallback onComplete;

  const WitnessMomentScreen({
    super.key,
    required this.intro,
    required this.onComplete,
  });

  @override
  State<WitnessMomentScreen> createState() => _WitnessMomentScreenState();
}

class _WitnessMomentScreenState extends State<WitnessMomentScreen> {
  int _currentLine = -1;
  double _lineOpacity = 0.0;
  bool _disposed = false;

  bool get _isAr => PrefsService.isAr;

  @override
  void initState() {
    super.initState();
    _runSequence();
  }

  Future<void> _runSequence() async {
    final lines = _isAr ? widget.intro.linesAr : widget.intro.lines;

    for (int i = 0; i < lines.length; i++) {
      if (_disposed) return;
      setState(() {
        _currentLine = i;
        _lineOpacity = 0.0;
      });

      // Fade in (500ms)
      await _animateOpacity(1.0, 500);
      if (_disposed) return;

      // Hold (2000ms)
      await Future.delayed(const Duration(milliseconds: 2000));
      if (_disposed) return;

      // Fade out (400ms) — except last line holds longer
      if (i < lines.length - 1) {
        await _animateOpacity(0.0, 400);
        if (_disposed) return;
      }
    }

    // Last line: hold 3 seconds then fade
    await Future.delayed(const Duration(milliseconds: 3000));
    if (_disposed) return;
    await _animateOpacity(0.0, 600);
    if (_disposed) return;

    widget.onComplete();
  }

  Future<void> _animateOpacity(double target, int ms) async {
    final steps = (ms / 16).round();
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

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lines = _isAr ? widget.intro.linesAr : widget.intro.lines;
    final currentText = _currentLine >= 0 && _currentLine < lines.length
        ? lines[_currentLine]
        : '';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Subtle gold dust particles
          CustomPaint(
            painter: _WitnessParticlePainter(),
          ),

          // Centered text
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Opacity(
                opacity: _lineOpacity,
                child: Text(
                  currentText,
                  textAlign: TextAlign.center,
                  textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
                  style: GoogleFonts.lora(
                    fontSize: 24,
                    fontStyle: _isAr ? FontStyle.normal : FontStyle.italic,
                    color: AppColors.gold,
                    height: 1.8,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),

          // "The Witness Moment" label at top
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                _isAr ? 'لحظة الشهادة' : 'The Witness Moment',
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  color: AppColors.gold.withAlpha(80),
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Very sparse gold dust particles — atmospheric, not distracting.
class _WitnessParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.gold.withAlpha(25);
    // 10 static dots at fixed positions (simple, no animation needed)
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
