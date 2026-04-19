import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';

/// R25-S3-8: Shared presentational widget for stacked stat rows.
///
/// Used by:
/// - Tent screen (Light + XP + Dhikr container) — 3 rows, dividers on.
/// - Event scene info tab (S3-6) — 1 row (Light only), dividers off.
///
/// This is the single source of truth for the row look. Values come from
/// the caller (pre-formatted String) so the widget stays pure.
///
/// Rendering contract per row:
///   [11×11 gold icon]  [11px #c0a878 w500 label]  [spacer]  [11px gold w700 value]
///
/// RTL mirrors via ambient [Directionality] — callers must ensure the
/// surrounding widget tree has the right [Directionality] or pass a
/// [textDirection] override. The widget itself relies on the ambient
/// direction.
class StatRowGroup extends StatelessWidget {
  final List<StatRow> rows;
  final bool showDividers;

  const StatRowGroup({
    super.key,
    required this.rows,
    this.showDividers = true,
  });

  @override
  Widget build(BuildContext context) {
    final isAr = Directionality.of(context) == TextDirection.rtl;
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      if (i > 0 && showDividers) {
        children.add(_buildDivider());
      }
      children.add(_buildRow(rows[i], isAr: isAr));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  Widget _buildRow(StatRow row, {required bool isAr}) {
    return SizedBox(
      height: 22,
      child: Row(
        children: [
          Icon(row.icon, size: 11, color: AppColors.gold),
          const SizedBox(width: 7),
          Text(
            isAr ? row.labelAr : row.label,
            style: GoogleFonts.nunito(
              color: const Color(0xFFC0A878),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            row.value,
            style: GoogleFonts.nunito(
              color: AppColors.gold,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Container(
        height: 0.5,
        margin: const EdgeInsets.symmetric(vertical: 3),
        color: AppColors.gold.withAlpha(31), // 0.12 * 255
      );
}

/// Presentational model for one stat row. Caller formats the value.
class StatRow {
  final IconData icon;
  final String label; // EN
  final String labelAr; // AR
  final String value; // pre-formatted by caller

  const StatRow({
    required this.icon,
    required this.label,
    required this.labelAr,
    required this.value,
  });
}
