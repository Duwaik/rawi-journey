import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/scroll_entries.dart';
import '../models/scroll_entry.dart';
import '../services/prefs_service.dart';

/// Full-screen viewer of the Rawi's Scroll — all completed lines in order.
class ScrollViewerScreen extends StatelessWidget {
  const ScrollViewerScreen({super.key});

  static const _parchment = Color(0xFFF5E6C8);
  static const _inkDark = Color(0xFF402010);
  static const _inkFaded = Color(0x66402010);
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

    // Total future slots = totalLines minus entries we have data for
    // Show dotted lines for remaining entries we have data for but aren't completed,
    // plus conceptual future slots
    final uncompletedDataEntries = allEntries
        .where((e) => !PrefsService.isEventCompleted(e.globalOrder))
        .toList();

    return Scaffold(
      backgroundColor: _parchment,
      body: Container(
        decoration: const BoxDecoration(
          color: _parchment,
          image: DecorationImage(
            image: AssetImage('assets/textures/parchment_light.jpg'),
            fit: BoxFit.cover,
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
                      color: _inkDark.withAlpha(15),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: 18,
                      color: _inkDark,
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
                      color: _inkDark,
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
              padding: EdgeInsets.fromLTRB(28, 0, 28, bottomPad + 24),
              physics: const BouncingScrollPhysics(),
              children: [
                // Completed lines — newest first (reversed order)
                for (final entry in completedEntries.reversed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
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
                      color: _inkFaded,
                      fontSize: 13,
                      fontStyle: isAr ? FontStyle.normal : FontStyle.italic,
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
}

class _CompletedLine extends StatelessWidget {
  final ScrollEntry entry;
  final bool isAr;

  const _CompletedLine({required this.entry, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Visual feedback only for now
        HapticFeedback.selectionClick();
      },
      child: Text(
        isAr ? entry.lineAr : entry.lineEn,
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        style: isAr
            ? GoogleFonts.amiri(
                color: ScrollViewerScreen._inkDark,
                fontSize: 16,
                height: 2.0,
              )
            : GoogleFonts.lora(
                color: ScrollViewerScreen._inkDark,
                fontSize: 16,
                height: 2.0,
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
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0x33402010),
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
