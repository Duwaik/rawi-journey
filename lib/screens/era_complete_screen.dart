import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../models/journey_event.dart';
import '../services/prefs_service.dart';

class EraCompleteScreen extends StatelessWidget {
  final JourneyEra era;
  final int xpGained;

  const EraCompleteScreen({
    super.key,
    required this.era,
    required this.xpGained,
  });

  Color get _eraColor {
    switch (era) {
      case JourneyEra.jahiliyyah: return AppColors.eraJahiliyyah;
      case JourneyEra.earlyLife:  return AppColors.eraEarlyLife;
      case JourneyEra.mecca:      return AppColors.eraMecca;
      case JourneyEra.medina:     return AppColors.eraMediana;
      case JourneyEra.rashidun:   return AppColors.eraRashidun;
      case JourneyEra.umayyad:    return AppColors.eraUmayyad;
      case JourneyEra.abbasid:    return AppColors.eraAbbasid;
      case JourneyEra.ottoman:    return AppColors.eraOttoman;
    }
  }

  String _nextEraName() {
    final lang = PrefsService.language;
    final nextIndex = era.index + 1;
    if (nextIndex >= JourneyEra.values.length) {
      return lang == 'ar' ? 'المرحلة التالية' : 'Next Chapter';
    }
    return JourneyEra.values[nextIndex].label(lang);
  }

  @override
  Widget build(BuildContext context) {
    final lang = PrefsService.language;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Era emoji — large
              Text(
                era.emoji,
                style: const TextStyle(fontSize: 72),
              ),
              const SizedBox(height: 24),

              // Chapter complete label
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: _eraColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _eraColor.withAlpha(80)),
                ),
                child: Text(
                  lang == 'ar' ? 'أتممت المرحلة!' : 'Chapter Complete!',
                  textDirection: lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                  style: TextStyle(
                    color: _eraColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Era name
              Text(
                era.label(lang),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Text(
                lang == 'ar'
                    ? 'لقد استكملت رحلتك عبر هذه الحقبة التاريخية'
                    : 'You\'ve journeyed through this era of Islamic history',
                textDirection: lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                style: const TextStyle(
                  color: AppColors.textBody,
                  fontSize: 15,
                  height: 1.6,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // XP earned
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.gold.withAlpha(15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.gold.withAlpha(60)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 28, color: AppColors.gold),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '+$xpGained XP',
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          lang == 'ar'
                              ? 'مكتسبة من هذا الحدث'
                              : 'Earned from this event',
                          textDirection: lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Total XP
              Text(
                '${lang == 'ar' ? 'إجمالي XP' : 'Total XP'}: ${PrefsService.xp}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),

              const Spacer(),

              // Next chapter CTA
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context)
                      .popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _eraColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    lang == 'ar'
                        ? 'واصل إلى ${_nextEraName()} ←'
                        : 'Continue to ${_nextEraName()} →',
                    textDirection: lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Back to map
              TextButton(
                onPressed: () => Navigator.of(context)
                    .popUntil((route) => route.isFirst),
                child: Text(
                  lang == 'ar' ? 'العودة إلى الخريطة' : 'Back to Map',
                  textDirection: lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
