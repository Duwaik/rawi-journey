import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../services/prefs_service.dart';

/// R27 S1.1-TENT5 + S1.3-TENT3: sequential coach-mark tutorial over
/// the tent. Walks the user through all 7 interactive elements in a
/// fixed order:
///
///   1. Events        (right-side nav, top)
///   2. Stars          (right-side nav)
///   3. Rawi's Scroll  (right-side nav)
///   4. Dhikr          (right-side nav)
///   5. Collections    (right-side nav, bottom)
///   6. Info tab       (left edge, S1.3-TENT1's enlarged chevron)
///   7. Settings gear  (top-right corner)
///
/// Icon positions are computed from the same math the tent build
/// method uses — one move of the layout means two edits, but keeps
/// runtime simple (no RenderBox probing). Tooltip card position is
/// per-step: nav icons anchor tooltip to the LEFT (free-space side),
/// info tab to the RIGHT, settings gear BELOW with horizontal clamp.
class TentIconTutorialOverlay extends StatefulWidget {
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

  // Mirrors rawi_tent_screen.dart right-side nav Column
  //   Positioned(top: screenH * 0.28, right: 10), _navIcon 44 × 44,
  //   SizedBox(height: 8) between icons.
  static const double _navIconSize = 44;
  static const double _navIconGap = 8;
  static const double _navRightInset = 10;
  static const double _navTopFraction = 0.28;

  // R27 S1.3-TENT1: info tab chevron is 42 px visual circle,
  // straddling the left edge at `screenH * 0.45`, centered on the
  // border via `right: -44` on an 88 px hit container.
  static const double _infoTabSize = 42;
  static const double _infoTabVerticalFraction = 0.45;

  // R27 S1-TENT (settings gear in rawi_tent_screen.dart:~498):
  //   Positioned(top: topPad + 10, right: 12), 34 × 34.
  static const double _gearSize = 34;
  static const double _gearRightInset = 12;
  static const double _gearTopInset = 10;

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
              'كل لحظة من السيرة، بالترتيب. اختر من أين تبدأ.',
              _Target.navIcon, 0),
          _CoachStep('النجوم',
              'أحداثك المكتملة تصبح نجوماً في السماء. كل نجمة رحلة تتذكرها.',
              _Target.navIcon, 1),
          _CoachStep('مخطوطة الراوي',
              'القصة المكتوبة حتى الآن. رحلتك تصبح مخطوطة تقرأها.',
              _Target.navIcon, 2),
          _CoachStep('الذِكر',
              'ذِكر يومي. قله مرة في اليوم لينير طريقك.',
              _Target.navIcon, 3),
          _CoachStep('المجموعات',
              'مخطوطاتك ومقتنياتك وشاراتك. كل ما جمعته، في مكان واحد.',
              _Target.navIcon, 4),
          _CoachStep('تقدمك',
              'اضغط في أي وقت لرؤية نورك وما تبقى من هذه الرحلة.',
              _Target.infoTab, 0),
          _CoachStep('الإعدادات',
              'غيّر اللغة وحجم النص، أو ابدأ رحلتك من جديد.',
              _Target.settingsGear, 0),
        ]
      : const [
          _CoachStep('Events',
              'Every moment of the Seerah, in order. Pick where to begin.',
              _Target.navIcon, 0),
          _CoachStep('Stars',
              'Your completed events become stars in the sky. '
                  'Each one is a journey you remember.',
              _Target.navIcon, 1),
          _CoachStep("Rawi's Scroll",
              'The story written so far. Your journey becomes a '
                  'scroll you can read back.',
              _Target.navIcon, 2),
          _CoachStep('Dhikr',
              'A daily remembrance. Say it once per day to light your way.',
              _Target.navIcon, 3),
          _CoachStep('Collections',
              'Your gathered manuscripts, scrolls, and badges. '
                  "Everything you've earned, in one place.",
              _Target.navIcon, 4),
          _CoachStep('Your progress',
              'Tap any time to see your Light and what\'s left in this journey.',
              _Target.infoTab, 0),
          _CoachStep('Settings',
              'Change language, text size, or start your journey over.',
              _Target.settingsGear, 0),
        ];

  /// Per-step target rect + tooltip anchor side. Returns the rect of
  /// the highlighted UI element in screen coordinates.
  ({Rect rect, _Anchor anchor}) _resolveTarget(
      _CoachStep step, Size screen, double topPad) {
    switch (step.target) {
      case _Target.navIcon:
        final top = screen.height * _navTopFraction +
            step.targetIndex * (_navIconSize + _navIconGap);
        final left = screen.width - _navRightInset - _navIconSize;
        return (
          rect: Rect.fromLTWH(left, top, _navIconSize, _navIconSize),
          // Nav is on the right; tooltip goes to the LEFT.
          anchor: _Anchor.leftOfTarget,
        );
      case _Target.infoTab:
        // Handle chevron center sits on the LEFT edge at ~45 % height.
        final cy = screen.height * _infoTabVerticalFraction;
        final top = cy - _infoTabSize / 2;
        // Centered on the left border — extends half out into the
        // scene, half into the panel body.
        final left = -_infoTabSize / 2;
        return (
          rect: Rect.fromLTWH(
              left, top, _infoTabSize, _infoTabSize),
          // Left edge → tooltip goes to the RIGHT.
          anchor: _Anchor.rightOfTarget,
        );
      case _Target.settingsGear:
        final top = topPad + _gearTopInset;
        final left = screen.width - _gearRightInset - _gearSize;
        return (
          rect: Rect.fromLTWH(left, top, _gearSize, _gearSize),
          // Gear sits top-right corner; tooltip goes BELOW since
          // there's no headroom above and no lateral space to the right.
          anchor: _Anchor.belowTarget,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final step = _steps[_step];
    final target = _resolveTarget(step, size, topPad);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {}, // absorb — live controls cannot fire mid-tutorial
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(color: Colors.black.withAlpha(153)), // 0.60
          ),
          // Pulsing gold ring around the resolved target rect.
          AnimatedBuilder(
            animation: _ringPulse,
            builder: (context, _) {
              final v = _ringPulse.value;
              final extra = 4 + v * 6;
              return Positioned(
                top: target.rect.top - extra,
                left: target.rect.left - extra,
                width: target.rect.width + extra * 2,
                height: target.rect.height + extra * 2,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          (target.rect.shortestSide / 2) + extra),
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
          // Tooltip card — positioned per step's anchor side.
          _buildTooltipPositioned(
              step, target.rect, target.anchor, size, bottomPad),
          // Step dots.
          Positioned(
            bottom: bottomPad + 16,
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

  Widget _buildTooltipPositioned(_CoachStep step, Rect targetRect,
      _Anchor anchor, Size screen, double bottomPad) {
    // Minimum breathing gap between tooltip and the target rect.
    const gap = 16.0;
    // Card width used to compute right/left bounds when anchoring.
    switch (anchor) {
      case _Anchor.leftOfTarget:
        return Positioned(
          top: (targetRect.center.dy - 60)
              .clamp(16, screen.height - 140)
              .toDouble(),
          left: 16,
          right: screen.width - targetRect.left + gap,
          child: _buildTooltipCard(step),
        );
      case _Anchor.rightOfTarget:
        return Positioned(
          top: (targetRect.center.dy - 60)
              .clamp(16, screen.height - 140)
              .toDouble(),
          left: targetRect.right + gap,
          right: 16,
          child: _buildTooltipCard(step),
        );
      case _Anchor.belowTarget:
        return Positioned(
          top: targetRect.bottom + gap,
          left: 16,
          right: 16,
          child: _buildTooltipCard(step),
        );
    }
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

enum _Target { navIcon, infoTab, settingsGear }

enum _Anchor { leftOfTarget, rightOfTarget, belowTarget }

class _CoachStep {
  final String title;
  final String body;
  final _Target target;
  final int targetIndex;
  const _CoachStep(this.title, this.body, this.target, this.targetIndex);
}
