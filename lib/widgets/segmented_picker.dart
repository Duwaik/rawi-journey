import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';

/// Reusable N-segment bar picker.
///
/// Shows all options at once so the user can see what's next and tap any
/// segment directly (replaces cycle-tap patterns). Active segment fills
/// gold; inactive segments stay muted. Haptic light-impact on tap.
///
/// Designed to extend to more segments when languages, difficulty levels,
/// or similar choices grow beyond two options (R20-A2).
class SegmentedPicker<T> extends StatelessWidget {
  final List<T> values;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onChanged;
  final double height;

  /// R28 S1-FEAT1: fixed per-segment width. Default 38 matches the
  /// existing S/M/L + joystick-side usage in Settings. Pass `null` to
  /// flex each segment (Expanded) — needed for long labels like
  /// "LIST" / "CONSTELLATION" in the Events List toggle where the
  /// parent controls overall width.
  final double? segmentWidth;

  const SegmentedPicker({
    super.key,
    required this.values,
    required this.labels,
    required this.selected,
    required this.onChanged,
    this.height = 32,
    this.segmentWidth = 38,
  }) : assert(values.length == labels.length);

  @override
  Widget build(BuildContext context) {
    final isFlex = segmentWidth == null;
    final segments = [
      for (int i = 0; i < values.length; i++)
        _segment(
          label: labels[i],
          active: values[i] == selected,
          onTap: () {
            if (values[i] == selected) return;
            HapticFeedback.lightImpact();
            onChanged(values[i]);
          },
        ),
    ];
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.gold.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: isFlex ? MainAxisSize.max : MainAxisSize.min,
        children: [
          for (int i = 0; i < segments.length; i++)
            isFlex ? Expanded(child: segments[i]) : segments[i],
        ],
      ),
    );
  }

  Widget _segment({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: segmentWidth,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: active ? AppColors.bg : AppColors.gold.withAlpha(180),
          ),
        ),
      ),
    );
  }
}
