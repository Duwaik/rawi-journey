import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_colors.dart';
import '../../models/badge_definition.dart';
import '../../services/audio_service.dart';
import '../../services/prefs_service.dart';

/// Full-screen badge unlock overlay — covers everything at 85% dark.
/// Shows as an overlay widget (not a dialog) for complete screen control.
/// Returns a Future via [completer] that resolves when user taps to dismiss.
class BadgeOverlay extends StatefulWidget {
  final BadgeDefinition badge;
  final VoidCallback onDismiss;

  const BadgeOverlay({
    super.key,
    required this.badge,
    required this.onDismiss,
  });

  @override
  State<BadgeOverlay> createState() => _BadgeOverlayState();
}

class _BadgeOverlayState extends State<BadgeOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _cardScale;
  late final Animation<double> _cardFade;
  late final Animation<double> _iconPop;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _cardScale = Tween(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _cardFade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _iconPop = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.2), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.1, 0.7, curve: Curves.easeOut),
    ));

    // Play badge ceremonial sound
    AudioService.playSfx('assets/audio/ambient/sfx_badge.mp3', volume: 0.7);

    _ctrl.forward();
  }

  Future<void> _dismiss() async {
    if (_dismissing) return;
    _dismissing = true;
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = PrefsService.isAr;
    final badge = widget.badge;
    final screenW = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return GestureDetector(
          onTap: _dismiss,
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: Colors.black.withAlpha((_cardFade.value * 216).round()), // 85%
            child: Center(
              child: FadeTransition(
                opacity: _cardFade,
                child: Transform.scale(
                  scale: _cardScale.value,
                  child: Container(
                    width: screenW * 0.8,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1520),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.gold, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withAlpha(50),
                          blurRadius: 16,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Badge icon — geometric gold placeholder (painterly art coming)
                        Transform.scale(
                          scale: _iconPop.value,
                          child: _BadgePlaceholder(icon: badge.icon),
                        ),
                        const SizedBox(height: 16),

                        // "BADGE UNLOCKED"
                        Text(
                          isAr ? 'وسام جديد' : 'BADGE UNLOCKED',
                          style: GoogleFonts.nunito(
                            color: AppColors.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Badge name
                        Text(
                          isAr ? badge.nameAr : badge.name,
                          textAlign: TextAlign.center,
                          textDirection:
                              isAr ? TextDirection.rtl : TextDirection.ltr,
                          style: GoogleFonts.lora(
                            color: AppColors.gold,
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Badge description
                        Text(
                          isAr ? badge.descriptionAr : badge.description,
                          textAlign: TextAlign.center,
                          textDirection:
                              isAr ? TextDirection.rtl : TextDirection.ltr,
                          style: GoogleFonts.nunito(
                            color: const Color(0xFFE8D8B8),
                            fontSize: 14,
                            height: 1.5,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Tap to continue
                        Text(
                          isAr ? 'انقر للمتابعة' : 'Tap to continue',
                          style: GoogleFonts.nunito(
                            color: AppColors.gold.withAlpha(128),
                            fontSize: 12,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Geometric gold badge placeholder — diamond + rosette + emoji hint.
/// Temporary until painterly AI artwork is ready.
class _BadgePlaceholder extends StatelessWidget {
  final String icon;
  const _BadgePlaceholder({required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withAlpha(80),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          Transform.rotate(
            angle: 0.7854,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.gold.withAlpha(200),
                    AppColors.gold.withAlpha(120),
                  ],
                ),
                border: Border.all(color: AppColors.gold, width: 2),
              ),
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0A1520),
              border: Border.all(
                color: AppColors.gold.withAlpha(180),
                width: 1.5,
              ),
            ),
          ),
          Text(
            icon,
            style: const TextStyle(
              fontSize: 32,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
