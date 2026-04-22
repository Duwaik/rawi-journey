import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../services/prefs_service.dart';

/// R27 S1.1-TENT5: sequential coach-mark tutorial over the tent's
/// right-side nav icons.
///
/// Fires automatically after the tent cinematic ([TentTutorialScreen])
/// completes on first-ever visit. 5 steps walking top-to-bottom:
/// Events → Stars → Scroll → Dhikr → Collections. Each step dims
/// the rest of the screen, pulses a gold ring around the highlighted
/// icon, and shows a tooltip card to the LEFT of the icon (so the
/// icon itself stays visible). Tap `Next` to advance; `Skip` dismisses
/// the whole tutorial and marks the flag complete.
///
/// Icon positions are NOT read from the live RenderBox tree — they're
/// computed from the same math the tent uses
/// (`Positioned(top: screenH * 0.28, right: 10)` + 44 px icons with
/// 8 px gap). If that math ever changes in [RawiTentScreen], update
/// the constants at the top of this file.
class TentIconTutorialOverlay extends StatefulWidget {
  /// Called when the user either completes step 5 or taps Skip.
  /// The host widget removes the overlay from the tree and sets
  /// [PrefsService.setTentIconTutorialShown].
  final VoidCallback onFinished;

  const TentIconTutorialOverlay({super.key, required this.onFinished});

  @override
  State<TentIconTutorialOverlay> createState() =>
      _TentIconTutorialOverlayState();
}

class _TentIconTutorialOverlayState extends State<TentIconTutorialOverlay>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  late final AnimationController _ringPulse;

  // Mirrors rawi_tent_screen.dart:391 (right-side nav Column):
  //   Positioned(top: screenH * 0.28, right: 10)
  //   _navIcon is 44 × 44, SizedBox(height: 8) between icons.
  static const double _iconSize = 44;
  static const double _iconGap = 8;
  static const double _navRightInset = 10;
  static const double _navTopFraction = 0.28;

  bool get _isAr => PrefsService.isAr;

  @override
  void initState() {
    super.initState();
    _ringPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ringPulse.dispose();
    super.dispose();
  }

  void _next() {
    if (_step + 1 >= _steps.length) {
      _finish();
      return;
    }
    setState(() => _step++);
  }

  Future<void> _skip() async {
    await PrefsService.setTentIconTutorialShown();
    if (!mounted) return;
    widget.onFinished();
  }

  Future<void> _finish() async {
    await PrefsService.setTentIconTutorialShown();
    if (!mounted) return;
    widget.onFinished();
  }

  List<_CoachStep> get _steps => _isAr
      ? const [
          _CoachStep('الأحداث',
              'كل لحظة من السيرة، بالترتيب. اختر من أين تبدأ.'),
          _CoachStep('النجوم',
              'أحداثك المكتملة تصبح نجوماً في السماء. كل نجمة رحلة تتذكرها.'),
          _CoachStep('مخطوطة الراوي',
              'القصة المكتوبة حتى الآن. رحلتك تصبح مخطوطة تقرأها.'),
          _CoachStep('الذِكر',
              'ذِكر يومي. قله مرة في اليوم لينير طريقك.'),
          _CoachStep('المجموعات',
              'مخطوطاتك ومقتنياتك وشاراتك. كل ما جمعته، في مكان واحد.'),
        ]
      : const [
          _CoachStep('Events',
              'Every moment of the Seerah, in order. Pick where to begin.'),
          _CoachStep('Stars',
              'Your completed events become stars in the sky. '
                  'Each one is a journey you remember.'),
          _CoachStep("Rawi's Scroll",
              'The story written so far. Your journey becomes a '
                  'scroll you can read back.'),
          _CoachStep('Dhikr',
              'A daily remembrance. Say it once per day to light your way.'),
          _CoachStep('Collections',
              'Your gathered manuscripts, scrolls, and badges. '
                  "Everything you've earned, in one place."),
        ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenW = size.width;
    final screenH = size.height;

    final iconTop = screenH * _navTopFraction +
        _step * (_iconSize + _iconGap);
    final iconRight = _navRightInset;
    final iconCenterY = iconTop + _iconSize / 2;
    final iconLeft = screenW - iconRight - _iconSize;

    final step = _steps[_step];

    // GestureDetector absorbs every tap outside the Next/Skip chips
    // so the live nav icons can't launch their routes mid-tutorial.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {}, // absorb
      child: Stack(
        children: [
          // Dim scrim over the whole tent.
          Positioned.fill(
            child: Container(color: Colors.black.withAlpha(153)), // 0.60
          ),
          // Pulsing gold ring highlight around the current icon.
          AnimatedBuilder(
            animation: _ringPulse,
            builder: (context, _) {
              final v = _ringPulse.value;
              final extra = 4 + v * 6; // ring grows 4 → 10 px outward
              return Positioned(
                top: iconTop - extra,
                left: iconLeft - extra,
                width: _iconSize + extra * 2,
                height: _iconSize + extra * 2,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16 + extra),
                      border: Border.all(
                        color: AppColors.gold
                            .withAlpha((220 * (1 - v * 0.3)).round()),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold
                              .withAlpha((90 * (1 - v * 0.3)).round()),
                          blurRadius: 14 + v * 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Tooltip card pinned to the left of the highlighted icon.
          Positioned(
            top: (iconCenterY - 60).clamp(16, screenH - 140),
            left: 16,
            right: screenW - iconLeft + 12, // clear the icon
            child: _buildTooltipCard(step),
          ),
          // Step dots (bottom, unobtrusive).
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_steps.length, (i) {
                  final active = i == _step;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Container(
                      width: active ? 8 : 6,
                      height: active ? 8 : 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active
                            ? AppColors.gold
                            : AppColors.gold.withAlpha(80),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTooltipCard(_CoachStep step) {
    return Directionality(
      textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E18).withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.gold.withAlpha(140), width: 1),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(140),
                blurRadius: 14,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              step.title,
              textDirection:
                  _isAr ? TextDirection.rtl : TextDirection.ltr,
              style: GoogleFonts.cinzelDecorative(
                color: AppColors.gold,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              step.body,
              textDirection:
                  _isAr ? TextDirection.rtl : TextDirection.ltr,
              style: GoogleFonts.nunito(
                color: const Color(0xFFE8D8B8),
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              textDirection:
                  _isAr ? TextDirection.rtl : TextDirection.ltr,
              children: [
                // Skip link
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _skip,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      _isAr ? 'تخطي' : 'Skip',
                      style: GoogleFonts.nunito(
                        color: AppColors.textMuted.withAlpha(180),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Next / Finish pill
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _next,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      _step + 1 >= _steps.length
                          ? (_isAr ? 'تم' : 'Done')
                          : (_isAr ? 'التالي' : 'Next'),
                      style: GoogleFonts.nunito(
                        color: const Color(0xFF0B1E2D),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CoachStep {
  final String title;
  final String body;
  const _CoachStep(this.title, this.body);
}
