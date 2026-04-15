import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../data/scroll_entries.dart';
import '../models/scroll_entry.dart';
import '../services/prefs_service.dart';

/// Full-screen viewer of the Rawi's Scroll — all completed lines in order.
///
/// R19-04: Dark theme replaces light parchment for readability.
/// R19-13: Entries are bold, tappable (returns globalOrder for navigation),
///   and properly RTL-aligned in Arabic.
class ScrollViewerScreen extends StatelessWidget {
  const ScrollViewerScreen({super.key});

  static const _bg = Color(0xFF04060D);
  static const _cardBg = Color(0xFF0E1A28);
  static const _textWarm = Color(0xFFE8D8B8);
  static const _textMuted = Color(0xFFA89878);
  static const _totalLines = 155;

  @override
  Widget build(BuildContext context) {
    final isAr = PrefsService.isAr;
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    // Sort all scroll entries by globalOrder
    final allEntries = scrollEntries.values.toList()
      ..sort((a, b) => a.globalOrder.compareTo(b.globalOrder));

    // Determine which are completed
    final completedEntries = <ScrollEntry>[];
    for (final e in allEntries) {
      if (PrefsService.isEventCompleted(e.globalOrder)) {
        completedEntries.add(e);
      }
    }
    final completedCount = completedEntries.length;

    final uncompletedDataEntries = allEntries
        .where((e) => !PrefsService.isEventCompleted(e.globalOrder))
        .toList();

    return Scaffold(
      backgroundColor: _bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bg, Color(0xFF0B1E2D), _bg],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.fromLTRB(20, topPad + 12, 12, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold.withAlpha(20),
                        border: Border.all(
                            color: AppColors.gold.withAlpha(60)),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 18,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isAr
                          ? '\u0633\u0650\u062C\u0650\u0644\u0651 \u0627\u0644\u0631\u0627\u0648\u064A'
                          : 'The Rawi\u2019s Scroll',
                      textDirection:
                          isAr ? TextDirection.rtl : TextDirection.ltr,
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 20,
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  // Completed lines — newest first (reversed order)
                  for (final entry in completedEntries.reversed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CompletedLine(entry: entry, isAr: isAr),
                    ),

                  // Uncompleted data entries (faint dotted)
                  for (int i = 0; i < uncompletedDataEntries.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _DottedPlaceholder(),
                    ),

                  // Remaining future slots beyond our data
                  for (int i = 0;
                      i < _totalLines - allEntries.length;
                      i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _DottedPlaceholder(),
                    ),

                  // Bottom counter
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      isAr
                          ? '$completedCount \u0645\u0646 \u0661\u0665\u0665 \u0633\u0637\u0631\u0627\u064B \u0643\u064F\u062A\u0628'
                          : '$completedCount of $_totalLines lines written',
                      style: GoogleFonts.lora(
                        color: _textMuted,
                        fontSize: 13,
                        fontStyle:
                            isAr ? FontStyle.normal : FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Re-export palette for inner widgets.
  static const Color cardBg = _cardBg;
  static const Color textWarm = _textWarm;
}

class _CompletedLine extends StatelessWidget {
  final ScrollEntry entry;
  final bool isAr;

  const _CompletedLine({required this.entry, required this.isAr});

  /// Convert ASCII digits to Arabic-Indic digits (٠١٢٣٤٥٦٧٨٩).
  static String _toArabicNumeral(int n) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((d) => arabicDigits[int.parse(d)]).join();
  }

  @override
  Widget build(BuildContext context) {
    // Display-only prefix: "E1:" in EN, "١ :الحدث" in AR.
    // Data in scroll_entries.dart is unchanged.
    final body = isAr ? entry.lineAr : entry.lineEn;
    final prefix = isAr
        ? '${_toArabicNumeral(entry.globalOrder)} :الحدث'
        : 'E${entry.globalOrder}:';
    final displayText = '$prefix $body';

    return GestureDetector(
      onTap: () {
        // R19-13: tap → pop with the globalOrder so the caller (event list)
        // can navigate to the event.
        HapticFeedback.selectionClick();
        Navigator.of(context).pop(entry.globalOrder);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: ScrollViewerScreen.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.gold.withAlpha(40)),
        ),
        child: Text(
          displayText,
          // R19-13: explicit RTL for Arabic + textAlign keeps long lines
          // hugging the right edge of the card.
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          textAlign: isAr ? TextAlign.right : TextAlign.left,
          style: isAr
              ? GoogleFonts.amiri(
                  color: ScrollViewerScreen.textWarm,
                  fontSize: 16,
                  fontWeight: FontWeight.w700, // R19-13: bold
                  height: 1.9,
                )
              : GoogleFonts.lora(
                  color: ScrollViewerScreen.textWarm,
                  fontSize: 15,
                  fontWeight: FontWeight.w700, // R19-13: bold
                  height: 1.9,
                ),
        ),
      ),
    );
  }
}

class _DottedPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dashWidth = 4.0;
          final dashSpace = 6.0;
          final dashCount =
              (constraints.maxWidth / (dashWidth + dashSpace)).floor();
          return Row(
            children: List.generate(dashCount, (_) {
              return Padding(
                padding: EdgeInsets.only(right: dashSpace),
                child: SizedBox(
                  width: dashWidth,
                  height: 1.5,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.gold.withAlpha(40),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
