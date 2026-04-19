import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';

/// R25-S3-3: Shared circular icon button for top-bar actions (back + gear).
///
/// 36×36 pill with backdrop-blurred navy fill, faint gold border, 18px gold
/// glyph. Fires light haptic on tap. Used by both the back button and the
/// settings gear so top-bar left/right halves match.
///
/// Ripple is constrained to the circle via `BorderRadius.circular(18)` so
/// taps feel contained rather than bleeding a full-square splash.
class TopBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const TopBarIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final child = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color.fromRGBO(10, 14, 24, 0.55),
            border: Border.all(
              color: AppColors.gold.withAlpha(46), // 0.18 * 255
              width: 0.5,
            ),
          ),
          child: Icon(icon, size: 18, color: AppColors.gold),
        ),
      ),
    );
    return tooltip == null ? child : Tooltip(message: tooltip!, child: child);
  }
}
