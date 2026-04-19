import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../services/prefs_service.dart';

/// R25-S3-7: One-time tutorial shown after Event 1's intro video.
///
/// Replaces the deleted "Explore the scene" copy. Single full-screen
/// overlay with three labelled callouts pointing at:
///   1. Scene dots (bottom)
///   2. Info tab (left edge, ~40% height)
///   3. Hotspot markers (mid-scene)
///
/// Tap "Got it" / "فهمت" to dismiss. Flips [PrefsService.setEvent1TutorialShown]
/// so it never re-appears. The callouts are simple positioned labels with
/// short arrow indicators — no sequential tooltips, one screen, one dismiss.
///
/// Full copy: roadmap §9.4 (LOCKED).
class Event1TutorialOverlay extends StatelessWidget {
  /// Called after the user taps "Got it" and the pref has been written.
  final VoidCallback onDismiss;

  const Event1TutorialOverlay({super.key, required this.onDismiss});

  Future<void> _dismiss() async {
    await PrefsService.setEvent1TutorialShown();
    onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = PrefsService.isAr;
    final screenH = MediaQuery.of(context).size.height;
    return Positioned.fill(
      child: Material(
        color: Colors.black.withAlpha(140), // 0.55
        child: Stack(
          children: [
            // ── Callout: Info tab (left edge, ~40%) ──────────────────
            Positioned(
              top: screenH * 0.40 - 10,
              left: 48,
              right: 24,
              child: _Callout(
                pointsLeft: true,
                text: isAr
                    ? 'اضغط هنا في أي وقت لرؤية نورك وتقدمك في هذا الحدث.'
                    : 'Tap here anytime to see your light and this event\'s progress.',
                isAr: isAr,
              ),
            ),
            // ── Callout: Scene dots (bottom) ─────────────────────────
            Positioned(
              bottom: 170,
              left: 32,
              right: 32,
              child: _Callout(
                pointsDown: true,
                text: isAr
                    ? 'هذه النقاط تُظهر تقدمك في لحظات هذا الحدث.'
                    : 'These dots show your progress through this event\'s moments.',
                isAr: isAr,
              ),
            ),
            // ── Callout: Hotspot markers (mid-scene) ─────────────────
            Positioned(
              top: screenH * 0.55,
              left: 32,
              right: 32,
              child: _Callout(
                pointsDown: true,
                text: isAr
                    ? 'اقترب من نقطة متوهجة لتشهد قصتها.'
                    : 'Move closer to a glowing spot to witness its story.',
                isAr: isAr,
              ),
            ),
            // ── Dismiss button (bottom-center) ───────────────────────
            Positioned(
              bottom: 48,
              left: 0, right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _dismiss,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(140),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.gold, width: 1.2),
                    ),
                    child: Text(
                      isAr ? 'فهمت' : 'Got it',
                      textDirection:
                          isAr ? TextDirection.rtl : TextDirection.ltr,
                      style: GoogleFonts.nunito(
                        color: AppColors.gold,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Callout extends StatelessWidget {
  final String text;
  final bool isAr;
  final bool pointsLeft;
  final bool pointsDown;

  const _Callout({
    required this.text,
    required this.isAr,
    this.pointsLeft = false,
    this.pointsDown = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (pointsLeft)
          Row(
            children: [
              Icon(Icons.arrow_left_rounded,
                  color: AppColors.gold, size: 20),
              const SizedBox(width: 4),
              Expanded(child: _text()),
            ],
          )
        else
          _text(),
        if (pointsDown)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(Icons.arrow_drop_down_rounded,
                color: AppColors.gold, size: 28),
          ),
      ],
    );
  }

  Widget _text() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(10, 14, 24, 0.88),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: AppColors.gold.withAlpha(128), width: 0.8),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          style: GoogleFonts.nunito(
            color: const Color(0xFFE8D8B8),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      );
}
