import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_colors.dart';

/// Gold-bordered speech pill above the companion figure.
/// Fades in (400ms) → holds → fades out (400ms).
/// Parent controls visibility via [visible] and [text].
class CompanionSpeechBubble extends StatefulWidget {
  final String text;
  final bool visible;
  final bool isAr;

  const CompanionSpeechBubble({
    super.key,
    required this.text,
    this.visible = false,
    this.isAr = false,
  });

  @override
  State<CompanionSpeechBubble> createState() => _CompanionSpeechBubbleState();
}

class _CompanionSpeechBubbleState extends State<CompanionSpeechBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    if (widget.visible) _fadeCtrl.forward();
  }

  @override
  void didUpdateWidget(CompanionSpeechBubble old) {
    super.didUpdateWidget(old);
    if (widget.visible && !old.visible) {
      _fadeCtrl.forward();
    } else if (!widget.visible && old.visible) {
      _fadeCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.bg.withAlpha(220),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.gold.withAlpha(120),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(80),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          widget.text,
          textAlign: TextAlign.center,
          textDirection: widget.isAr ? TextDirection.rtl : TextDirection.ltr,
          style: GoogleFonts.nunito(
            fontSize: 10,
            color: AppColors.gold,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}
