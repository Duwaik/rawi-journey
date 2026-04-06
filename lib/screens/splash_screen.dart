import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../services/prefs_service.dart';
import 'event_list_screen.dart';
import 'intro_cinematic_screen.dart';

/// Branded splash screen — first thing the player sees on every launch.
/// First launch: 2s hold → intro cinematic.
/// Returning player: 1s hold → hub.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _logoFade;
  late final Animation<double> _bismillahFade;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // Logo fades in 0–60%, bismillah fades in 40–100%
    _logoFade = CurvedAnimation(
      parent: _fadeCtrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _bismillahFade = CurvedAnimation(
      parent: _fadeCtrl,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );

    _fadeCtrl.forward();

    final holdDuration = PrefsService.isOnboardingComplete
        ? const Duration(milliseconds: 1000)
        : const Duration(milliseconds: 2000);

    Future.delayed(holdDuration, _navigate);
  }

  void _navigate() {
    if (!mounted) return;

    final destination = PrefsService.isOnboardingComplete
        ? const EventListScreen()
        : const IntroCinematicScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, anim, secondaryAnimation, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Cinematic desert background (matches intro/registration/events list)
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Image.asset(
              'assets/scenes/scene_welcome.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.black.withAlpha(180),
          ),
          Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── RAWI logo ──────────────────────────────────────────────
            FadeTransition(
              opacity: _logoFade,
              child: Text(
                'RAWI',
                style: GoogleFonts.cinzelDecorative(
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                  letterSpacing: 8,
                ),
              ),
            ),
            const SizedBox(height: 6),
            FadeTransition(
              opacity: _logoFade,
              child: Text(
                'راوي',
                style: GoogleFonts.lora(
                  fontSize: 28,
                  fontStyle: FontStyle.normal,
                  color: AppColors.gold.withAlpha(200),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Bismillah ──────────────────────────────────────────────
            FadeTransition(
              opacity: _bismillahFade,
              child: Text(
                'بسم الله الرحمن الرحيم',
                style: GoogleFonts.lora(
                  fontSize: 16,
                  fontStyle: FontStyle.normal,
                  color: AppColors.textMuted.withAlpha(160),
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ),
        ),
        ],
      ),
    );
  }
}
