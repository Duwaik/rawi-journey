import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../services/prefs_service.dart';
import 'tutorial_keys.dart';

/// Sequential coach-mark tutorial over the tent.
///
/// R28 HF3-TUT1 (27 Apr): step list updated to match the current
/// 5-active + 1-reserved nav (R28-S1-NAV1 retired Stars; the slot is
/// now Living Map placeholder). Six spotlights total:
///
///   1. Events           (right-side nav)
///   2. Rawi's Scroll    (right-side nav)
///   3. Collections      (right-side nav)
///   4. Living Map       (right-side nav, "coming soon" placeholder
///                        — still highlighted so the user knows the
///                        slot exists)
///   5. Info tab         (left-edge enlarged ⓘ circle)
///   6. Settings gear    (top-right corner)
///
/// Stars step removed (Stars screen retired in R28-S1-CODE1). Dhikr
/// step also removed — Dhikr has its own one-shot tutorial flag fired
/// by the Dhikr screen on first open, doesn't need a tent mention.
///
/// Spotlight positions come from each target's live RenderBox via
/// `localToGlobal`, not static screen-fraction math (the S1.5-TUT2
/// pattern). Targets are addressed by `GlobalKey` from
/// [TutorialKeys] — the actual widgets attach the same key when
/// they build, so position math survives any future layout move
/// without a second edit.
///
/// Per-target shape:
///   • nav icons    → rounded-rect, radius 12 (matches `_navIcon`'s
///                    Container BorderRadius)
///   • info tab     → circle (42 px tent info circle)
///   • settings gear → circle (34 px BoxShape.circle container)
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

  bool get _isAr => PrefsService.isAr;

  @override
  void initState() {
    super.initState();
    _ringPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    // R28 HF3-TUT1: trigger one rebuild after first frame so the
    // RenderBox lookups in `_resolveTarget` see laid-out targets.
    // First frame may otherwise paint at the static fallback rect.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
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
      ? [
          _CoachStep(
            'الأحداث',
            'كل لحظة من السيرة، بالترتيب. اختر من أين تبدأ.',
            TutorialKeys.tentEvents,
            _Shape.roundedRect,
          ),
          _CoachStep(
            'مخطوطة الراوي',
            'القصة المكتوبة حتى الآن. رحلتك تصبح مخطوطة تقرأها.',
            TutorialKeys.tentScroll,
            _Shape.roundedRect,
          ),
          _CoachStep(
            'المجموعات',
            'مخطوطاتك ومقتنياتك وشاراتك. كل ما جمعته، في مكان واحد.',
            TutorialKeys.tentCollections,
            _Shape.roundedRect,
          ),
          _CoachStep(
            'الخريطة الحيّة',
            'قريباً ستظهر خريطة لرحلتك عبر الجزيرة العربية. سنفتحها لاحقاً.',
            TutorialKeys.tentLivingMap,
            _Shape.roundedRect,
          ),
          _CoachStep(
            'تقدمك',
            'اضغط في أي وقت لرؤية نورك وما تبقى من هذه الرحلة.',
            TutorialKeys.tentInfoTab,
            _Shape.circle,
          ),
          _CoachStep(
            'الإعدادات',
            'غيّر اللغة وحجم النص، أو ابدأ رحلتك من جديد.',
            TutorialKeys.tentSettings,
            _Shape.circle,
          ),
        ]
      : [
          _CoachStep(
            'Events',
            'Every moment of the Seerah, in order. Pick where to begin.',
            TutorialKeys.tentEvents,
            _Shape.roundedRect,
          ),
          _CoachStep(
            "Rawi's Scroll",
            'The story written so far. Your journey becomes a '
                'scroll you can read back.',
            TutorialKeys.tentScroll,
            _Shape.roundedRect,
          ),
          _CoachStep(
            'Collections',
            'Your gathered manuscripts, scrolls, and badges. '
                "Everything you've earned, in one place.",
            TutorialKeys.tentCollections,
            _Shape.roundedRect,
          ),
          _CoachStep(
            'Living Map',
            'Coming soon — a map of your journey across Arabia. '
                "We'll open this slot in a future release.",
            TutorialKeys.tentLivingMap,
            _Shape.roundedRect,
          ),
          _CoachStep(
            'Your progress',
            'Tap any time to see your Light and what\'s left in this journey.',
            TutorialKeys.tentInfoTab,
            _Shape.circle,
          ),
          _CoachStep(
            'Settings',
            'Change language, text size, or start your journey over.',
            TutorialKeys.tentSettings,
            _Shape.circle,
          ),
        ];

  /// Resolve the on-screen rect for a step's target via live RenderBox.
  /// Returns a fallback rect on the right edge of the screen if the
  /// target hasn't laid out yet (covers the first paint before the
  /// post-frame setState fires).
  Rect _resolveTargetRect(_CoachStep step, Size screen) {
    final ctx = step.targetKey.currentContext;
    final ro = ctx?.findRenderObject();
    if (ro is RenderBox && ro.hasSize) {
      final pos = ro.localToGlobal(Offset.zero);
      return Rect.fromLTWH(pos.dx, pos.dy, ro.size.width, ro.size.height);
    }
    // Fallback — small placeholder rect off-screen-ish so the spotlight
    // doesn't slam into the middle of the tent on the first frame.
    return Rect.fromLTWH(screen.width - 60, screen.height * 0.5, 44, 44);
  }

  /// Choose tooltip anchor side based on the target's screen position.
  /// Right-side nav → tooltip on the LEFT (free space). Left-edge info
  /// tab → tooltip on the RIGHT. Top-bar gear → tooltip BELOW. Mirrors
  /// for AR locale because the tent's nav stays on the right edge in
  /// both LTR and RTL (it's locale-agnostic per design).
  _Anchor _resolveAnchor(_CoachStep step, Rect rect, Size screen) {
    final centerY = rect.center.dy;
    final centerX = rect.center.dx;
    final topThird = screen.height * 0.20;
    if (centerY < topThird) {
      // Top-bar element (e.g. settings gear).
      return _Anchor.belowTarget;
    }
    if (centerX > screen.width / 2) {
      // Right side of screen — tooltip on the left.
      return _Anchor.leftOfTarget;
    }
    return _Anchor.rightOfTarget;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final step = _steps[_step];
    final targetRect = _resolveTargetRect(step, size);
    final anchor = _resolveAnchor(step, targetRect, size);

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
              final double highlightRadius = step.shape == _Shape.roundedRect
                  ? 12.0 + extra
                  : (targetRect.shortestSide / 2) + extra;
              return Positioned(
                top: targetRect.top - extra,
                left: targetRect.left - extra,
                width: targetRect.width + extra * 2,
                height: targetRect.height + extra * 2,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(highlightRadius),
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
          // Tooltip card — positioned per resolved anchor.
          _buildTooltipPositioned(
              step, targetRect, anchor, size, bottomPad),
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
    const gap = 16.0;
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

enum _Shape { roundedRect, circle }

enum _Anchor { leftOfTarget, rightOfTarget, belowTarget }

class _CoachStep {
  final String title;
  final String body;
  final GlobalKey targetKey;
  final _Shape shape;
  const _CoachStep(this.title, this.body, this.targetKey, this.shape);
}
