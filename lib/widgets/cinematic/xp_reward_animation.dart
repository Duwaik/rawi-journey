import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_colors.dart';

/// Animated XP reveal: star pop → count-up → particle burst → total line.
/// Calls [onComplete] when animation finishes (for Continue button fade-in).
class XpRewardAnimation extends StatefulWidget {
  final int xpEarned;
  final int previousTotal;
  final VoidCallback? onComplete;

  const XpRewardAnimation({
    super.key,
    required this.xpEarned,
    required this.previousTotal,
    this.onComplete,
  });

  @override
  State<XpRewardAnimation> createState() => _XpRewardAnimationState();
}

class _XpRewardAnimationState extends State<XpRewardAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _starScale;
  late final Animation<int> _countUp;
  late final Animation<double> _totalFade;
  late final Animation<double> _burstFade;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Star pop: 0-30% (0.3 → 1.3 → 1.0)
    _starScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.3), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 45),
    ]).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    // Count-up: 15-70%
    _countUp = IntTween(begin: 0, end: widget.xpEarned).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.15, 0.70, curve: Curves.easeOut),
      ),
    );

    // Particle burst: 10-55%
    _burstFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.1, 0.55, curve: Curves.easeOut),
      ),
    );

    // Total XP line: 70-100%
    _totalFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.70, 1.0, curve: Curves.easeOut),
    );

    _ctrl.forward();
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newTotal = widget.previousTotal + widget.xpEarned;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Star + count-up + particle burst
            SizedBox(
              height: 120,
              width: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Gold particle burst (12 dots expanding outward)
                  if (_burstFade.value > 0)
                    ...List.generate(12, (i) {
                      final angle = i * (pi / 6);
                      final radius = (1.0 - _burstFade.value) * 70;
                      return Positioned(
                        left: 140 + cos(angle) * radius - 4,
                        top: 60 + sin(angle) * radius - 4,
                        child: Opacity(
                          opacity: _burstFade.value * 0.8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.gold,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.gold.withAlpha(100),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                  // Star + XP number
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.scale(
                        scale: _starScale.value,
                        child: const Icon(Icons.star_rounded,
                            color: AppColors.gold, size: 64),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '+${_countUp.value} XP',
                        style: GoogleFonts.cinzelDecorative(
                          color: AppColors.gold,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Total XP line
            Opacity(
              opacity: _totalFade.value,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  '★ ${widget.previousTotal} → $newTotal',
                  style: GoogleFonts.nunito(
                    color: AppColors.gold.withAlpha(180),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
