import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../services/prefs_service.dart';

/// Semi-transparent tutorial overlay shown on first immersive event.
/// Two sequential steps, tap anywhere to advance:
///   Step 1: "Use the joystick to move" — arrow pointing to bottom-left
///   Step 2: "Approach the glowing diamond to discover" — arrow pointing up
/// After both steps, marks tutorial as seen and calls [onComplete].
class TutorialOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const TutorialOverlay({super.key, required this.onComplete});

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  late final AnimationController _fadeCtrl;

  static const _steps = [
    _TutorialStep(
      titleEn: 'Use the joystick to move',
      titleAr: 'استخدم عصا التحكم للتحرك',
      subtitleEn: 'Drag the joystick to guide your companion',
      subtitleAr: 'اسحب عصا التحكم لتوجيه رفيقك',
      icon: Icons.gamepad_rounded,
      arrowDirection: _ArrowDir.bottomLeft,
    ),
    _TutorialStep(
      titleEn: 'Discover the glowing diamonds',
      titleAr: 'اكتشف الماسات المتوهجة',
      subtitleEn: 'Approach hotspots to uncover the story',
      subtitleAr: 'اقترب من النقاط لكشف القصة',
      icon: Icons.diamond_rounded,
      arrowDirection: _ArrowDir.up,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _advance() {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      PrefsService.setTutorialSeen();
      _fadeCtrl.reverse().then((_) {
        if (mounted) widget.onComplete();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = PrefsService.isAr;
    final step = _steps[_step];
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return FadeTransition(
      opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
      child: GestureDetector(
        onTap: _advance,
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.black.withAlpha(180),
          child: Stack(
            children: [
              // ── Center content ──────────────────────────────────────
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.gold.withAlpha(25),
                          border: Border.all(
                              color: AppColors.gold.withAlpha(80), width: 2),
                        ),
                        child: Icon(step.icon,
                            size: 28, color: AppColors.gold),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        isAr ? step.titleAr : step.titleEn,
                        textAlign: TextAlign.center,
                        textDirection:
                            isAr ? TextDirection.rtl : TextDirection.ltr,
                        style: GoogleFonts.cinzelDecorative(
                          fontSize: 18,
                          color: AppColors.gold,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        isAr ? step.subtitleAr : step.subtitleEn,
                        textAlign: TextAlign.center,
                        textDirection:
                            isAr ? TextDirection.rtl : TextDirection.ltr,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: AppColors.textBody,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Arrow indicator ─────────────────────────────────────
              if (step.arrowDirection == _ArrowDir.bottomLeft)
                Positioned(
                  bottom: bottomPad + 90,
                  left: 60,
                  child: _buildArrow(isDown: true),
                ),
              if (step.arrowDirection == _ArrowDir.up)
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.3,
                  left: 0,
                  right: 0,
                  child: Center(child: _buildArrow(isDown: false)),
                ),

              // ── Tap to continue ─────────────────────────────────────
              Positioned(
                bottom: bottomPad + 30,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    isAr ? 'انقر للمتابعة' : 'Tap to continue',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: AppColors.textMuted.withAlpha(140),
                    ),
                  ),
                ),
              ),

              // ── Step dots ───────────────────────────────────────────
              Positioned(
                bottom: bottomPad + 55,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_steps.length, (i) {
                    final active = i == _step;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: active
                            ? AppColors.gold
                            : AppColors.textMuted.withAlpha(60),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArrow({required bool isDown}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isDown)
          Icon(Icons.keyboard_arrow_up_rounded,
              size: 32, color: AppColors.gold.withAlpha(160)),
        Container(
          width: 2,
          height: 30,
          color: AppColors.gold.withAlpha(100),
        ),
        if (isDown)
          Icon(Icons.keyboard_arrow_down_rounded,
              size: 32, color: AppColors.gold.withAlpha(160)),
      ],
    );
  }
}

enum _ArrowDir { bottomLeft, up }

class _TutorialStep {
  final String titleEn;
  final String titleAr;
  final String subtitleEn;
  final String subtitleAr;
  final IconData icon;
  final _ArrowDir arrowDirection;

  const _TutorialStep({
    required this.titleEn,
    required this.titleAr,
    required this.subtitleEn,
    required this.subtitleAr,
    required this.icon,
    required this.arrowDirection,
  });
}
