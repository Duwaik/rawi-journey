import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_colors.dart';

/// Collapsible "Go Deeper" section for scholarly content.
/// Shows below hotspot fragments and question explanations.
/// Collapsed by default — tap to expand.
class GoDeeperSection extends StatefulWidget {
  final String content;
  final bool isAr;

  const GoDeeperSection({
    super.key,
    required this.content,
    required this.isAr,
  });

  @override
  State<GoDeeperSection> createState() => _GoDeeperSectionState();
}

class _GoDeeperSectionState extends State<GoDeeperSection>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _toggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.gold.withAlpha(10),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.gold.withAlpha(40)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('📖',
                    style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Text(
                  widget.isAr ? 'تعمّق أكثر' : 'Go Deeper',
                  style: GoogleFonts.nunito(
                    color: AppColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.gold.withAlpha(160),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _expandAnim,
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card.withAlpha(180),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gold.withAlpha(25)),
              ),
              child: Text(
                widget.content,
                textDirection:
                    widget.isAr ? TextDirection.rtl : TextDirection.ltr,
                style: GoogleFonts.nunito(
                  color: AppColors.textBody,
                  fontSize: 12,
                  height: 1.7,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
