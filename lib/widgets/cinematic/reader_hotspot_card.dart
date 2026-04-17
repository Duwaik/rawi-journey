import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app_colors.dart';

/// R20 Part C v3 — Reader Mode quadrant hotspot card.
///
/// Replaces the small marker used in Explorer Mode with a full-bleed
/// quadrant card: icon + label + state badge, with an asymmetric
/// border radius that visually "points" inward toward the centered
/// Rawi figure. State drives color, opacity, and an optional pulse.
enum ReaderCardState { locked, active, branchChoice, done }

enum ReaderCardQuadrant { tl, tr, bl, br }

class ReaderHotspotCard extends StatefulWidget {
  final String icon;
  final String label;
  final int index;
  final ReaderCardState state;
  final ReaderCardQuadrant quadrant;
  final bool isAr;
  final VoidCallback onTap;
  final double width;
  final double height;

  const ReaderHotspotCard({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
    required this.state,
    required this.quadrant,
    required this.isAr,
    required this.onTap,
    this.width = 140,
    this.height = 130,
  });

  @override
  State<ReaderHotspotCard> createState() => _ReaderHotspotCardState();
}

class _ReaderHotspotCardState extends State<ReaderHotspotCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant ReaderHotspotCard old) {
    super.didUpdateWidget(old);
    final isBranch = widget.state == ReaderCardState.branchChoice;
    final wantedMs = isBranch ? 1500 : 2500;
    if (_pulseCtrl.duration?.inMilliseconds != wantedMs) {
      _pulseCtrl.duration = Duration(milliseconds: wantedMs);
      _pulseCtrl
        ..reset()
        ..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  BorderRadius _radiusForQuadrant() {
    const big = Radius.circular(16);
    const small = Radius.circular(4);
    switch (widget.quadrant) {
      case ReaderCardQuadrant.tl:
        return const BorderRadius.only(
            topLeft: big, topRight: big, bottomLeft: big, bottomRight: small);
      case ReaderCardQuadrant.tr:
        return const BorderRadius.only(
            topLeft: big, topRight: big, bottomLeft: small, bottomRight: big);
      case ReaderCardQuadrant.bl:
        return const BorderRadius.only(
            topLeft: big, topRight: small, bottomLeft: big, bottomRight: big);
      case ReaderCardQuadrant.br:
        return const BorderRadius.only(
            topLeft: small, topRight: big, bottomLeft: big, bottomRight: big);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isDone = state == ReaderCardState.done;
    final isActive = state == ReaderCardState.active;
    final isBranch = state == ReaderCardState.branchChoice;
    final isLocked = state == ReaderCardState.locked;
    final interactive = isActive || isBranch || isDone;

    final Color borderColor = isDone
        ? AppColors.gold.withAlpha(140)
        : (isActive || isBranch)
            ? AppColors.gold
            : Colors.white.withAlpha(30);

    // R21A-04: Cards use a near-opaque dark base so labels stay
    // readable over bright scenes (E2 desert, E3 night). The scene
    // shows through the thin gap between cards and behind the Rawi
    // circle; the cards themselves are ~92% opaque.
    final Color bgColor = isDone
        ? const Color(0xEE0E1A28)
        : isActive
            ? const Color(0xEE14223A)
            : isBranch
                ? const Color(0xEE14223A)
                : const Color(0xCC060910);

    final radius = _radiusForQuadrant();

    final badgeOnLeft = widget.quadrant == ReaderCardQuadrant.tl ||
        widget.quadrant == ReaderCardQuadrant.bl;

    // R24 D-01: Material wrapper for ripple feedback on tap.
    // The GestureDetector was correct but users couldn't tell the
    // card registered their tap. The ripple gives instant visual
    // confirmation.
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: interactive ? widget.onTap : null,
        borderRadius: radius,
        splashColor: AppColors.gold.withAlpha(30),
        highlightColor: AppColors.gold.withAlpha(15),
        child: AnimatedOpacity(
        opacity: isLocked ? 0.2 : 1,
        duration: const Duration(milliseconds: 350),
        child: AnimatedScale(
          scale: (isActive || isBranch) ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: Stack(
              children: [
                // ── Card body ──────────────────────────────────────────
                Container(
                  width: widget.width,
                  height: widget.height,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: radius,
                    border: Border.all(color: borderColor, width: 1.5),
                    boxShadow: (isActive || isBranch)
                        ? [
                            BoxShadow(
                                color: AppColors.gold.withAlpha(30),
                                blurRadius: 20)
                          ]
                        : isDone
                            ? [
                                BoxShadow(
                                    color: AppColors.gold.withAlpha(13),
                                    blurRadius: 8)
                              ]
                            : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.icon,
                        style: TextStyle(
                          fontSize: 32,
                          color: isLocked
                              ? Colors.white.withAlpha(60)
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        textDirection: widget.isAr
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: isDone
                              ? AppColors.gold
                              : (isActive || isBranch)
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted.withAlpha(180),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Pulse ring ─────────────────────────────────────────
                if (isActive || isBranch)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (_, _) {
                          final t = _pulseCtrl.value;
                          final alpha =
                              (isBranch ? 90 : 65) * (0.4 + 0.6 * t);
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: radius,
                              border: Border.all(
                                color: AppColors.gold.withAlpha(alpha.round()),
                                width: 1,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // ── State badge (top corner near outer edge) ──────────
                Positioned(
                  top: 8,
                  left: badgeOnLeft ? 10 : null,
                  right: badgeOnLeft ? null : 10,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone
                          ? AppColors.gold
                          : (isActive || isBranch)
                              ? AppColors.gold.withAlpha(50)
                              : const Color(0xFF151C28),
                      border: Border.all(
                        color: (isDone || isActive || isBranch)
                            ? AppColors.gold
                            : const Color(0xFF2A3040),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isDone
                          ? '✓'
                          : isBranch
                              ? '?'
                              : '${widget.index + 1}',
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isDone
                            ? AppColors.bg
                            : (isActive || isBranch)
                                ? AppColors.gold
                                : AppColors.textMuted.withAlpha(120),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
