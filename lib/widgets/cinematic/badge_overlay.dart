import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_colors.dart';
import '../../models/badge_definition.dart';
import '../../services/prefs_service.dart';

/// Full-screen badge unlock overlay — cinematic gold card.
/// Returns a Future that completes when user taps to dismiss.
class BadgeOverlay extends StatefulWidget {
  final BadgeDefinition badge;

  const BadgeOverlay({super.key, required this.badge});

  @override
  State<BadgeOverlay> createState() => _BadgeOverlayState();
}

class _BadgeOverlayState extends State<BadgeOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _cardScale;
  late final Animation<double> _cardFade;
  late final Animation<double> _iconPop;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _cardScale = Tween(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _cardFade = CurvedAnimation(
      parent: _ctrl, curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _iconPop = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.3), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
    ));

    _ctrl.forward();
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

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: Colors.black.withAlpha(180),
            child: Center(
              child: FadeTransition(
                opacity: _cardFade,
                child: Transform.scale(
                  scale: _cardScale.value,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0E14).withAlpha(250),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.gold.withAlpha(100), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withAlpha(30),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Badge icon — pop animation
                        Transform.scale(
                          scale: _iconPop.value,
                          child: Text(badge.icon,
                              style: const TextStyle(fontSize: 48)),
                        ),
                        const SizedBox(height: 16),

                        // "Badge Unlocked"
                        Text(
                          isAr ? 'وسام جديد' : 'BADGE UNLOCKED',
                          style: GoogleFonts.nunito(
                            color: AppColors.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Badge name
                        Text(
                          isAr ? badge.nameAr : badge.name,
                          textAlign: TextAlign.center,
                          textDirection:
                              isAr ? TextDirection.rtl : TextDirection.ltr,
                          style: GoogleFonts.cinzelDecorative(
                            color: AppColors.gold,
                            fontSize: 20,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Badge description
                        Text(
                          isAr ? badge.descriptionAr : badge.description,
                          textAlign: TextAlign.center,
                          textDirection:
                              isAr ? TextDirection.rtl : TextDirection.ltr,
                          style: GoogleFonts.nunito(
                            color: AppColors.textBody,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Tap to continue
                        Text(
                          isAr ? 'انقر للمتابعة' : 'Tap to continue',
                          style: GoogleFonts.nunito(
                            color: AppColors.textMuted.withAlpha(140),
                            fontSize: 12,
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
