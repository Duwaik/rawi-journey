import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../services/prefs_service.dart';
import 'tutorial_keys.dart';

/// R25-S3-HF-8: Sequential 3-step tutorial shown after Event 1's intro.
///
/// Inherits the visual language of the legacy [TutorialOverlay] (full
/// dark scrim, centered icon-in-circle, title + subtitle, step dots,
/// "Tap to continue" hint) so it matches the rest of the app instead
/// of introducing a separate callout style.
///
/// Each step points at a different element of the new event-scene UI:
///   1. Settings gear   → mode toggle explanation
///   2. Info tab        → lifetime Light + event progress
///   3. Demo hotspot    → what a glowing moment looks like
///
/// Each step has its own "Got it" / "فهمت" dismiss. Tapping the dismiss
/// advances to the next step. After step 3, the Event 1 tutorial pref
/// flips — this overlay never shows again for any subsequent event.
///
/// Copy locked per roadmap §9.4 + hotfix §H8.
class Event1TutorialOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const Event1TutorialOverlay({super.key, required this.onDismiss});

  @override
  State<Event1TutorialOverlay> createState() =>
      _Event1TutorialOverlayState();
}

class _Event1TutorialOverlayState extends State<Event1TutorialOverlay>
    with TickerProviderStateMixin {
  int _step = 0;
  late final AnimationController _fadeCtrl;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    // R28 HF3-INFO1: trigger one rebuild after first frame so the
    // leftMid pointer's RenderBox lookup (TutorialKeys.eventInfoTab)
    // sees a laid-out target. First frame may paint with the static
    // fallback if the info tab hasn't yet completed layout.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _advance() async {
    // R26 S1v2-TU1: tutorial is now 3 steps (0..2). Mode-toggle step
    // removed — mode toggle lives in tent settings only per Sprint 4
    // lock; pointing users to the event-scene gear was incorrect.
    //   Step 0 — Info tab        (was step 1)
    //   Step 1 — Scene hotspot   (was step 2)
    //   Step 2 — Figure movement (was step 3)
    if (_step < 2) {
      setState(() => _step++);
      return;
    }
    await PrefsService.setEvent1TutorialShown();
    await _fadeCtrl.reverse();
    if (mounted) widget.onDismiss();
  }

  bool get _isAr => PrefsService.isAr;

  _StepSpec get _spec {
    final isAr = _isAr;
    // R26 S1v2-TU1: 3 steps (0..2). Mode-toggle step removed per spec —
    // mode toggle is tent-settings only.
    switch (_step) {
      case 0:
        return _StepSpec(
          icon: Icons.info_outline_rounded,
          title: isAr ? 'نورك والتقدّم' : 'Your Light & Progress',
          subtitle: isAr
              ? 'اضغط هنا لرؤية نورك وتقدمك في هذا الحدث.'
              : "Tap here to see your light and this event's progress.",
          pointer: _PointerTarget.leftMid,
        );
      case 1:
        return _StepSpec(
          icon: Icons.auto_awesome_rounded,
          title: isAr ? 'اللحظات المتوهّجة' : 'Glowing Moments',
          subtitle: isAr
              ? 'اقترب من نقطة متوهجة كهذه لتشهد لحظة.'
              : 'Move toward a glowing spot like this to witness a moment.',
          pointer: _PointerTarget.demoHotspot,
        );
      default:
        // R26 S1-TU3: figure-movement explainer. Placed last so users
        // already know WHY they're moving (to reach the glowing spot
        // from the previous step) before learning HOW.
        return _StepSpec(
          icon: Icons.gamepad_rounded,
          title: isAr ? 'كيفية التحرك' : 'How to move',
          subtitle: isAr
              ? 'اسحب راوي مباشرة بإصبعك، أو استخدم عصا التحكم في الأسفل.'
              : 'Drag Rawi directly with your finger, or use the joystick at the bottom.',
          pointer: _PointerTarget.bottomJoystick,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final spec = _spec;
    final isAr = _isAr;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final topPad = MediaQuery.of(context).padding.top;
    final size = MediaQuery.of(context).size;

    // R26 S1-TU1: explicit Directionality wrapper ensures Arabic text +
    // RTL semantics render correctly even if the ambient Directionality
    // doesn't propagate cleanly through the Positioned / FadeTransition /
    // Stack chain the overlay sits inside. Individual Text widgets also
    // pass textDirection explicitly; this is belt-and-suspenders.
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: FadeTransition(
      opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
      child: Container(
        color: Colors.black.withAlpha(210),
        child: Stack(
          children: [
            // ── Pointer / demo element keyed to step ────────────────
            _buildPointer(spec.pointer, topPad, size),

            // ── Center content: icon + title + subtitle ────────────
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold.withAlpha(30),
                        border: Border.all(
                            color: AppColors.gold.withAlpha(120), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withAlpha(60),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(spec.icon, size: 32, color: AppColors.gold),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      spec.title,
                      textAlign: TextAlign.center,
                      textDirection: isAr
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 18,
                        color: AppColors.gold,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      spec.subtitle,
                      textAlign: TextAlign.center,
                      textDirection: isAr
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: AppColors.textBody,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── "Got it" dismiss pill ───────────────────────────────
            Positioned(
              bottom: bottomPad + 80,
              left: 0, right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _advance,
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

            // ── Step dots (three) ───────────────────────────────────
            Positioned(
              bottom: bottomPad + 50,
              left: 0, right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final active = i == _step;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: active
                          ? AppColors.gold
                          : AppColors.textMuted.withAlpha(60),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  /// Step-specific pointer / demo element. Lightweight: no cross-
  /// widget coordination needed — the overlay renders its own demo
  /// glyph next to the real element it's pointing at.
  Widget _buildPointer(_PointerTarget target, double topPad, Size size) {
    // R26 S1v2-TU1: the `topRight` pointer (settings-gear arrow for the
    // old mode-toggle step) is gone along with its step. Enum entry
    // removed to keep the switch exhaustive-by-default.
    switch (target) {
      case _PointerTarget.leftMid:
        // R28 HF3-INFO1: arrow now points at the *current* info-tab
        // circle position via TutorialKeys.eventInfoTab + localToGlobal.
        // Pre-HF3 this used `size.height * 0.40 + 4` which was the
        // pre-R27-S1.4 layout — info tab is now at 0.45 * H with a
        // 42 px circle (was 52). Fallback to corrected static math
        // covers first-frame race before the info tab lays out.
        final rb = TutorialKeys.eventInfoTab.currentContext
            ?.findRenderObject() as RenderBox?;
        const arrowApprox = 32.0; // _buildArrow padded glyph footprint
        double arrowTop = size.height * 0.45 + 18;
        double arrowLeft = 60;
        IconData arrowIcon = Icons.arrow_back_rounded;
        if (rb != null && rb.hasSize) {
          final tabPos = rb.localToGlobal(Offset.zero);
          final tabSize = rb.size;
          arrowTop = tabPos.dy + tabSize.height / 2 - arrowApprox / 2;
          // Place the arrow on the screen-side AWAY from the tab's
          // edge so it visibly points INTO the circle. AR locale may
          // mount the tab on the right edge — check by midpoint.
          final tabIsLeftSide =
              tabPos.dx + tabSize.width / 2 < size.width / 2;
          if (tabIsLeftSide) {
            arrowLeft = tabPos.dx + tabSize.width + 8;
            arrowIcon = Icons.arrow_back_rounded;
          } else {
            arrowLeft = tabPos.dx - arrowApprox - 8;
            arrowIcon = Icons.arrow_forward_rounded;
          }
        }
        return Positioned(
          top: arrowTop,
          left: arrowLeft,
          child: _buildArrow(arrowIcon),
        );
      case _PointerTarget.demoHotspot:
        // Pulsing demo spot, center-left where hotspots typically sit.
        return Positioned(
          top: size.height * 0.55,
          left: size.width * 0.22,
          child: AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (ctx, _) {
              final pulse = _pulseCtrl.value;
              final radius = 12 + pulse * 6;
              return SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: Container(
                    width: radius * 2,
                    height: radius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold.withAlpha(
                          (60 + (1 - pulse) * 80).toInt()),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withAlpha(
                              (90 * (1 - pulse)).toInt()),
                          blurRadius: 18 + pulse * 12,
                          spreadRadius: 2 + pulse * 4,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      case _PointerTarget.bottomJoystick:
        // R26 S1-TU3: figure-movement explainer. Renders TWO arrows —
        // one up the middle of the scene (hint: drag figure with
        // finger) and one pointing down toward the joystick area
        // (hint: or use the joystick). Avoids cross-widget
        // coordination by drawing its own demo glyphs rather than
        // pulsing the live joystick.
        return Stack(
          children: [
            // Finger-drag hint — arrow above the figure area
            Positioned(
              top: size.height * 0.48,
              left: 0, right: 0,
              child: Center(
                child: _buildArrow(Icons.touch_app_rounded),
              ),
            ),
            // Joystick hint — arrow near bottom where the virtual
            // joystick renders (left in EN, right in AR — but the
            // joystick itself is positioned by user preference, so
            // a centered hint is language-safe).
            Positioned(
              bottom: size.height * 0.16,
              left: 0, right: 0,
              child: Center(
                child: _buildArrow(Icons.arrow_downward_rounded),
              ),
            ),
          ],
        );
    }
  }

  Widget _buildArrow(IconData icon) {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (ctx, _) {
        final t = sin(_pulseCtrl.value * pi);
        return Transform.translate(
          offset: Offset(0, -t * 4),
          child: Icon(icon,
              size: 28, color: AppColors.gold.withAlpha(200)),
        );
      },
    );
  }
}

enum _PointerTarget { leftMid, demoHotspot, bottomJoystick }

class _StepSpec {
  final IconData icon;
  final String title;
  final String subtitle;
  final _PointerTarget pointer;

  const _StepSpec({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.pointer,
  });
}
