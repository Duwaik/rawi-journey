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

    // Total duration: ~1.5s
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Star pop: 0-30% (0.5 → 1.2 → 1.0)
    _starScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.25), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    // Count-up: 15-75%
    _countUp = IntTween(begin: 0, end: widget.xpEarned).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.15, 0.75, curve: Curves.easeOut),
      ),
    );

    // Particle burst: 10-50%
    _burstFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.1, 0.5, curve: Curves.easeOut),
      ),
    );

    // Total XP line: 75-100%
    _totalFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
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
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Gold particle burst (8 dots expanding outward)
                  if (_burstFade.value > 0)
                    ...List.generate(8, (i) {
                      final angle = i * (pi / 4);
                      final radius = (1.0 - _burstFade.value) * 30;
                      return Positioned(
                        left: MediaQuery.of(context).size.width / 2 -
                            40 + cos(angle) * radius,
                        top: 25 + sin(angle) * radius,
                        child: Opacity(
                          opacity: _burstFade.value * 0.8,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                      );
                    }),

                  // Star + XP number
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.scale(
                        scale: _starScale.value,
                        child: const Icon(Icons.star_rounded,
                            color: AppColors.gold, size: 28),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+${_countUp.value} XP',
                        style: GoogleFonts.nunito(
                          color: AppColors.gold,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
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
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '★ ${widget.previousTotal} → $newTotal',
                  style: GoogleFonts.nunito(
                    color: AppColors.gold.withAlpha(140),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
