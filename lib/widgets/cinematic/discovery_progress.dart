import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_colors.dart';

/// Bottom progress indicator showing discovery state: "Explore · 2/4"
class DiscoveryProgress extends StatelessWidget {
  final int total;
  final int discovered;
  final bool isAr;

  const DiscoveryProgress({
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(140),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dots
            ...List.generate(total, (i) {
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

            const SizedBox(width: 10),

            // Text
            Text(
              isAr
                  ? 'استكشف المشهد · $discovered/$total'
                  : 'Explore the scene · $discovered/$total',
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              style: GoogleFonts.nunito(
                color: AppColors.gold,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
