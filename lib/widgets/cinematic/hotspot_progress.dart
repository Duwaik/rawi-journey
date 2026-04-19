import 'package:flutter/material.dart';
import '../../app_colors.dart';

/// Scene dots: dots-only indicator of hotspot discovery within an event.
///
/// R25-S3-1: the "Explore the scene · x/y" text label was dropped per
/// spec Q3.2 — the dots alone communicate progress, and Event 1's
/// first-time tutorial (S3-7) introduces them. Widget still takes an
/// [isAr] param for API stability but no longer renders any text.
class HotspotProgress extends StatelessWidget {
  final int total;
  final int discovered;
  final bool isAr;

  const HotspotProgress({
    super.key,
    required this.total,
    required this.discovered,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final allDone = discovered >= total;

    return AnimatedOpacity(
      opacity: allDone ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(140),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(total, (i) {
            final done = i < discovered;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: done ? 8 : 6,
                height: done ? 8 : 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? AppColors.gold
                      : AppColors.textMuted.withAlpha(80),
                  boxShadow: done
                      ? [BoxShadow(
                          color: AppColors.gold.withAlpha(80),
                          blurRadius: 4,
                        )]
                      : null,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
