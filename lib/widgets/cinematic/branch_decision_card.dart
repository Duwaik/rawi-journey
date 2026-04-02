import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app_colors.dart';
import '../../models/branch_point.dart';

/// The Crossroads — gold-bordered card overlay after The Gate.
/// Two tappable options — each leads to a different Path visit order.
/// Styled like a discovery panel but with animated gold border to signal "choice."
class BranchDecisionCard extends StatefulWidget {
  final BranchPoint branchPoint;
  final bool isAr;
  final void Function(BranchOption selected) onOptionSelected;

  const BranchDecisionCard({
    super.key,
    required this.branchPoint,
    required this.isAr,
    required this.onOptionSelected,
  });

  @override
  State<BranchDecisionCard> createState() => _BranchDecisionCardState();
}

class _BranchDecisionCardState extends State<BranchDecisionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
    _slideAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: const Interval(0.0, 0.3, curve: Curves.easeOut)),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bp = widget.branchPoint;
    final isAr = widget.isAr;
    final prompt = isAr ? bp.promptAr : bp.prompt;

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        final glowAlpha = (40 + _pulseAnim.value * 40).round();
        return Center(
          child: Transform.translate(
            offset: Offset(0, _slideAnim.value * 50),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              decoration: BoxDecoration(
                color: AppColors.bg.withAlpha(240),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withAlpha(120 + glowAlpha),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withAlpha(glowAlpha),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Prompt text ──────────────────────────────────
                    Text(
                      prompt,
                      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                      style: GoogleFonts.lora(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Option A ─────────────────────────────────────
                    _OptionButton(
                      label: isAr ? bp.optionA.labelAr : bp.optionA.label,
                      isAr: isAr,
                      onTap: () => widget.onOptionSelected(bp.optionA),
                    ),
                    const SizedBox(height: 12),

                    // ── Option B ─────────────────────────────────────
                    _OptionButton(
                      label: isAr ? bp.optionB.labelAr : bp.optionB.label,
                      isAr: isAr,
                      onTap: () => widget.onOptionSelected(bp.optionB),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String label;
  final bool isAr;
  final VoidCallback onTap;

  const _OptionButton({
    required this.label,
    required this.isAr,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.gold.withAlpha(12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withAlpha(60)),
        ),
        child: Text(
          label,
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          style: GoogleFonts.nunito(
            color: AppColors.gold,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
