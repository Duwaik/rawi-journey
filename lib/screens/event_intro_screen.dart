import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../models/journey_event.dart';
import '../services/audio_service.dart';
import '../services/prefs_service.dart';

/// Cinematic fade-to-black transition with title card between events.
/// Flow: fade to black (400ms) → title card (year + location + title, hold 2s)
/// → fade out (600ms) → callback to push destination.
class EventIntroScreen extends StatefulWidget {
  final JourneyEvent event;
  final VoidCallback onComplete;

  const EventIntroScreen({
    super.key,
    required this.event,
    required this.onComplete,
  });

  @override
  State<EventIntroScreen> createState() =>
      _EventIntroScreenState();
}

class _EventIntroScreenState extends State<EventIntroScreen>
    with TickerProviderStateMixin {
  double _blackOpacity = 0.0;
  double _cardOpacity = 0.0;
  bool _disposed = false;
  late final AnimationController _particleCtrl;
  late final AnimationController _cursorCtrl;

  // Typewriter state: which line is currently typing (0=date, 1=location,
  // 2=title, 3=done) and how many characters of each line are visible.
  int _currentLine = -1;
  int _dateChars = 0;
  int _locationChars = 0;
  int _titleChars = 0;

  static const int _charIntervalMs = 40;
  static const int _linePauseMs = 200;
  static const int _finalPauseMs = 800;

  @override
  void initState() {
    super.initState();
    // Continuous animation for particle drift
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    // Blinking cursor (500ms interval)
    _cursorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    // R7-01: Home ambient (ambient_intro.mp3) is already playing from
    // events list. Fade it out smoothly as the title card appears —
    // no separate transition ambient, just continuity into silence
    // before the immersive event's hotspot ambients take over.
    AudioService.fadeOut(duration: const Duration(milliseconds: 800));
    _runSequence();
  }

  Future<void> _runSequence() async {
    // Phase 1: Fade to black (400ms)
    await _animateTo(() => _blackOpacity, (v) => _blackOpacity = v, 1.0, 400);
    if (_disposed) return;

    // Phase 2: Title card container fades in (400ms)
    await _animateTo(() => _cardOpacity, (v) => _cardOpacity = v, 1.0, 400);
    if (_disposed) return;

    // Phase 3: Typewriter reveal of the three lines
    final isAr = PrefsService.isAr;
    final event = widget.event;
    final dateText = '${event.year} CE';
    final locationText = isAr ? event.locationAr : event.location;
    final titleText = isAr ? event.titleAr : event.title;

    // Line 1: date
    await _typeLine(0, dateText.length, (n) => _dateChars = n);
    if (_disposed) return;
    await Future.delayed(const Duration(milliseconds: _linePauseMs));
    if (_disposed) return;

    // Line 2: location
    await _typeLine(1, locationText.characters.length,
        (n) => _locationChars = n);
    if (_disposed) return;
    await Future.delayed(const Duration(milliseconds: _linePauseMs));
    if (_disposed) return;

    // Line 3: title
    await _typeLine(2, titleText.characters.length, (n) => _titleChars = n);
    if (_disposed) return;

    // Cursor disappears after all lines complete
    if (!_disposed) setState(() => _currentLine = 3);

    // Phase 4: Final pause (800ms) then auto-transition
    await Future.delayed(const Duration(milliseconds: _finalPauseMs));
    if (_disposed) return;

    widget.onComplete();
  }

  Future<void> _typeLine(
    int lineIndex,
    int totalChars,
    void Function(int) setter,
  ) async {
    if (_disposed) return;
    setState(() {
      _currentLine = lineIndex;
      setter(0);
    });
    for (int i = 1; i <= totalChars; i++) {
      await Future.delayed(const Duration(milliseconds: _charIntervalMs));
      if (_disposed) return;
      setState(() => setter(i));
    }
  }

  Future<void> _animateTo(
    double Function() getter,
    void Function(double) setter,
    double target,
    int ms,
  ) async {
    final steps = (ms / 16).round();
    final start = getter();
    final delta = target - start;
    for (int s = 1; s <= steps; s++) {
      if (_disposed) return;
      await Future.delayed(const Duration(milliseconds: 16));
      if (_disposed) return;
      setState(() => setter(start + delta * (s / steps)));
    }
    if (!_disposed) setState(() => setter(target));
  }

  @override
  void dispose() {
    _disposed = true;
    _particleCtrl.dispose();
    _cursorCtrl.dispose();
    // Home ambient already faded during initState (800ms fade).
    // Immersive event's hotspot ambients will take over cleanly.
    super.dispose();
  }

  /// Blinking vertical gold cursor, sized to match the text line height.
  Widget _buildCursor(double fontSize) {
    return AnimatedBuilder(
      animation: _cursorCtrl,
      builder: (_, _) => Opacity(
        opacity: _cursorCtrl.value,
        child: Container(
          width: 2,
          height: fontSize,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          color: AppColors.gold,
        ),
      ),
    );
  }

  /// A single typewriter line: shows substring(0, charCount) of [fullText]
  /// and, if this is the active line, a blinking cursor on the leading edge.
  /// For LTR the cursor sits to the right of the text; for RTL (Arabic) the
  /// cursor sits to the left — matching the direction of character reveal.
  Widget _buildTypewriterLine({
    required String fullText,
    required int charCount,
    required bool isActive,
    required bool isAr,
    required TextStyle style,
    TextAlign textAlign = TextAlign.center,
  }) {
    final chars = fullText.characters;
    final shown = charCount >= chars.length
        ? fullText
        : chars.take(charCount).toString();
    final fontSize = style.fontSize ?? 14;
    final cursor = isActive ? _buildCursor(fontSize) : const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Flexible(
          child: Text(
            shown,
            textAlign: textAlign,
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            style: style,
          ),
        ),
        cursor,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = PrefsService.isAr;
    final event = widget.event;
    final title = isAr ? event.titleAr : event.title;
    final location = isAr ? event.locationAr : event.location;

    // Always use cinematic navy gradient for transition screen
    final skyColors = [const Color(0xFF04060D), const Color(0xFF0B1E2D)];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient background from event's sky palette
          Opacity(
            opacity: _blackOpacity,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: skyColors.length >= 2
                      ? [skyColors.first, skyColors.last]
                      : [skyColors.first, skyColors.first],
                ),
              ),
            ),
          ),

          // Floating gold dust particles (visible the entire screen lifetime)
          if (_blackOpacity > 0)
            Opacity(
              opacity: _blackOpacity * 0.6,
              child: AnimatedBuilder(
                animation: _particleCtrl,
                builder: (_, _) => CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: _TransitionParticlePainter(
                    seed: event.globalOrder,
                    progress: _particleCtrl.value,
                  ),
                ),
              ),
            ),

          // Title card
          Center(
            child: Opacity(
              opacity: _cardOpacity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Chapter / era label
                    Text(
                      event.era.label(isAr ? 'ar' : 'en'),
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        color: AppColors.textMuted.withAlpha(120),
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Year (typewriter line 1)
                    _buildTypewriterLine(
                      fullText: '${event.year} CE',
                      charCount: _dateChars,
                      isActive: _currentLine == 0,
                      isAr: false,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Location (typewriter line 2)
                    _buildTypewriterLine(
                      fullText: location,
                      charCount: _locationChars,
                      isActive: _currentLine == 1,
                      isAr: isAr,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: AppColors.gold.withAlpha(160),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Decorative line
                    Container(
                      width: 40,
                      height: 1,
                      color: AppColors.gold.withAlpha(80),
                    ),
                    const SizedBox(height: 16),

                    // Event title (typewriter line 3)
                    _buildTypewriterLine(
                      fullText: title,
                      charCount: _titleChars,
                      isActive: _currentLine == 2,
                      isAr: isAr,
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 22,
                        color: AppColors.gold,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple floating gold dust particles for the transition screen.
class _TransitionParticlePainter extends CustomPainter {
  final int seed;
  final double progress;

  _TransitionParticlePainter({required this.seed, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(seed * 7);
    final count = 30;
    final paint = Paint();

    for (int i = 0; i < count; i++) {
      final x = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      // Slow upward drift based on progress
      final y = baseY - (progress * 20 * (1 + rng.nextDouble()));
      final radius = 0.8 + rng.nextDouble() * 1.5;
      final alpha = (0.15 + rng.nextDouble() * 0.35) * progress;

      paint.color = AppColors.gold.withAlpha((alpha * 255).round().clamp(0, 255));
      if (rng.nextBool()) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      } else {
        paint.maskFilter = null;
      }

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_TransitionParticlePainter old) =>
      old.progress != progress;
}
