import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../services/prefs_service.dart';

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
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _advance() async {
    // TODO: Sprint 4 — revisit step 1 copy if the mode toggle location
    // changes when Sprint 4 moves the toggle to tent settings only.
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
    switch (_step) {
      case 0:
        return _StepSpec(
          icon: Icons.settings_rounded,
          title: isAr ? 'وضع الاستكشاف والقراءة' : 'Explorer & Reader Modes',
          subtitle: isAr
              ? 'اضغط على الإعدادات في أي وقت للتبديل بين وضع الاستكشاف والقراءة.'
              : 'Tap settings anytime to switch between Explorer and Reader mode.',
          pointer: _PointerTarget.topRight,
        );
      case 1:
        return _StepSpec(
          icon: Icons.info_outline_rounded,
          title: isAr ? 'نورك والتقدّم' : 'Your Light & Progress',
          subtitle: isAr
              ? 'اضغط هنا لرؤية نورك وتقدمك في هذا الحدث.'
              : "Tap here to see your light and this event's progress.",
          pointer: _PointerTarget.leftMid,
        );
      default:
        return _StepSpec(
          icon: Icons.auto_awesome_rounded,
          title: isAr ? 'اللحظات المتوهّجة' : 'Glowing Moments',
          subtitle: isAr
              ? 'اقترب من نقطة متوهجة كهذه لتشهد لحظة.'
              : 'Move toward a glowing spot like this to witness a moment.',
          pointer: _PointerTarget.demoHotspot,
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

    return FadeTransition(
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
    );
  }

  /// Step-specific pointer / demo element. Lightweight: no cross-
  /// widget coordination needed — the overlay renders its own demo
  /// glyph next to the real element it's pointing at.
  Widget _buildPointer(_PointerTarget target, double topPad, Size size) {
    switch (target) {
      case _PointerTarget.topRight:
        // Arrow pointing up-right toward the settings gear.
        return Positioned(
          top: topPad + 52,
          right: 24,
          child: _buildArrow(Icons.arrow_upward_rounded),
        );
      case _PointerTarget.leftMid:
        // Arrow pointing left toward the info tab at ~40% height.
        return Positioned(
          top: size.height * 0.40 + 4,
          left: 44,
          child: _buildArrow(Icons.arrow_back_rounded),
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

enum _PointerTarget { topRight, leftMid, demoHotspot }

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
