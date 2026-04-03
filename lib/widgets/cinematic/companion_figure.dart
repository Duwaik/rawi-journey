import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_colors.dart';
import '../../services/prefs_service.dart';

/// The Rawi (راوي) / Rawiah (راوية) — the narrator character.
/// Image-based avatar in a gold-bordered circle.
/// Supports pose parameter for context-specific images (when art is ready).
/// Retains walking bob, breathing, and golden aura animations.
class CompanionFigure extends StatefulWidget {
  final bool isWalking;
  final double facingDirection;
  final bool isAr;
  /// Pose: 'walking', 'witnessing', 'reflecting', 'carrying'
  /// Currently all map to the same in-scene image until pose art is generated.
  final String pose;

  const CompanionFigure({
    super.key,
    this.isWalking = false,
    this.facingDirection = 0.0,
    this.isAr = false,
    this.pose = 'walking',
  });

  @override
  State<CompanionFigure> createState() => _CompanionFigureState();
}

class _CompanionFigureState extends State<CompanionFigure>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMale = PrefsService.userGender == 'male';
    final imagePath = isMale
        ? 'assets/figures/male_companion_inscene.jpg'
        : 'assets/figures/female_companion_inscene.jpg';

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) {
        final breathe = widget.isWalking ? 0.0 : sin(_anim.value * pi) * 0.8;
        final walkBob = widget.isWalking ? sin(_anim.value * pi * 2) * 1.2 : 0.0;
        final walkLean =
            widget.isWalking ? widget.facingDirection.clamp(-1, 1) * 1.5 : 0.0;

        final glowAlpha = (40 + _anim.value * 35).round();

        return Transform.translate(
          offset: Offset(walkLean, walkBob - breathe),
          child: SizedBox(
            width: 68,
            height: 86,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Circular avatar with glow ──────────────────────
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.gold,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withAlpha(glowAlpha + 20),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                      BoxShadow(
                        color: AppColors.gold.withAlpha((glowAlpha * 0.6).round()),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      imagePath,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 2),

                // ── Label ──────────────────────────────────────────
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withAlpha(40),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.gold.withAlpha(80),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    widget.isAr
                        ? (PrefsService.userGender == 'female' ? 'راوية' : 'راوي')
                        : (PrefsService.userGender == 'female' ? 'Rawiah' : 'Rawi'),
                    textDirection: widget.isAr ? TextDirection.rtl : TextDirection.ltr,
                    style: GoogleFonts.nunito(
                      color: AppColors.gold,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
