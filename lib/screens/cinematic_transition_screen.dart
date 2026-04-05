import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../data/scene_configs.dart';
import '../models/journey_event.dart';
import '../services/audio_service.dart';
import '../services/prefs_service.dart';

/// Cinematic fade-to-black transition with title card between events.
/// Flow: fade to black (400ms) → title card (year + location + title, hold 2s)
/// → fade out (600ms) → callback to push destination.
class CinematicTransitionScreen extends StatefulWidget {
  final JourneyEvent event;
  final VoidCallback onComplete;

  const CinematicTransitionScreen({
    super.key,
    required this.event,
    required this.onComplete,
  });

  @override
  State<CinematicTransitionScreen> createState() =>
      _CinematicTransitionScreenState();
}

class _CinematicTransitionScreenState extends State<CinematicTransitionScreen>
    with SingleTickerProviderStateMixin {
  double _blackOpacity = 0.0;
  double _cardOpacity = 0.0;
  bool _disposed = false;
  late final AnimationController _particleCtrl;

  @override
  void initState() {
    super.initState();
    // Continuous animation for particle drift
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    // Start transition ambient (fade in)
    if (PrefsService.musicEnabled) {
      AudioService.playAmbient(
        'assets/audio/ambient/ambient_transition.mp3',
        volume: 0.0,
      );
      AudioService.fadeAmbientTo(0.20,
          duration: const Duration(milliseconds: 600));
    }
    _runSequence();
  }

  Future<void> _runSequence() async {
    // Phase 1: Fade to black (400ms)
    await _animateTo(() => _blackOpacity, (v) => _blackOpacity = v, 1.0, 400);
    if (_disposed) return;

    // Phase 2: Title card fades in (400ms)
    await _animateTo(() => _cardOpacity, (v) => _cardOpacity = v, 1.0, 400);
    if (_disposed) return;

    // Phase 3: Hold title card (3000ms)
    await Future.delayed(const Duration(milliseconds: 3000));
    if (_disposed) return;

    // Phase 4: Title card fades out (400ms)
    await _animateTo(() => _cardOpacity, (v) => _cardOpacity = v, 0.0, 400);
    if (_disposed) return;

    // Phase 5: Brief pause then callback
    await Future.delayed(const Duration(milliseconds: 200));
    if (_disposed) return;

    widget.onComplete();
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
    // Fade out transition ambient as scene takes over
    AudioService.fadeOut(duration: const Duration(milliseconds: 500));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = PrefsService.isAr;
    final event = widget.event;
    final title = isAr ? event.titleAr : event.title;
    final location = isAr ? event.locationAr : event.location;

    // Get sky gradient from scene config if available
    final config = sceneConfigs[event.id];
    final skyColors = config?.skyGradient ?? [const Color(0xFF04060D), const Color(0xFF0B1E2D)];

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

                    // Year
                    Text(
                      '${event.year} CE',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Location
                    Text(
                      location,
                      textDirection:
                          isAr ? TextDirection.rtl : TextDirection.ltr,
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

                    // Event title
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      textDirection:
                          isAr ? TextDirection.rtl : TextDirection.ltr,
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
