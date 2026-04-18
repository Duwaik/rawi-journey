import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../data/scroll_arcs.dart';
import '../data/scroll_entries.dart';
import '../models/scroll_entry.dart';
import '../services/prefs_service.dart';

// ── Shared palette (top-level so sub-widgets in this file can reuse) ───────
const Color _kCardBg = Color(0xFF0E1A28);
const Color _kTextWarm = Color(0xFFE8D8B8);

/// Full-screen viewer of the Rawi's Scroll.
///
/// B9: Entries are grouped into 20 story-arc scrolls (see [scrollArcs]).
/// - Sealed (0 completed events): rolled, locked visual.
/// - Partial (1..n-1 completed): unrolled, shows completed notes + remaining
///   placeholders, a small progress label (e.g. "3/5 notes").
/// - Complete: fully unrolled with all notes.
/// Within each unrolled arc, tapping a line pops the globalOrder (same
/// behaviour as the old flat viewer so callers continue to work).
class ScrollViewerScreen extends StatefulWidget {
  const ScrollViewerScreen({super.key});

  @override
  State<ScrollViewerScreen> createState() => _ScrollViewerScreenState();
}

class _ScrollViewerScreenState extends State<ScrollViewerScreen> {
  static const _bg = Color(0xFF04060D);
  static const _textMuted = Color(0xFFA89878);

  // Which partially-completed arcs are expanded. Complete arcs default
  // expanded; sealed arcs cannot expand.
  final Set<int> _expanded = {};

  bool get _isAr => PrefsService.isAr;

  @override
  Widget build(BuildContext context) {
    final isAr = _isAr;
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    // Group entries by arc index.
    final entriesByArc = <int, List<ScrollEntry>>{};
    for (final e in scrollEntries.values) {
      final arc = arcForEvent(e.globalOrder);
      if (arc == null) continue;
      entriesByArc.putIfAbsent(arc.index, () => []).add(e);
    }
    for (final list in entriesByArc.values) {
      list.sort((a, b) => a.globalOrder.compareTo(b.globalOrder));
    }

    int totalCompleted = 0;
    for (final e in scrollEntries.values) {
      if (PrefsService.isEventCompleted(e.globalOrder)) totalCompleted++;
    }

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
            // ── Header ──────────────────────────────────────────────
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
                      isAr ? 'سِجِلّ الراوي' : 'The Rawi\u2019s Scroll',
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

            // ── Grouped scrolls ─────────────────────────────────────
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  for (int m = 1; m <= 4; m++) ..._buildModuleSection(
                    module: m,
                    entriesByArc: entriesByArc,
                    isAr: isAr,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      isAr
                          ? '$totalCompleted من ١٥٥ سطراً كُتب'
                          : '$totalCompleted of 155 lines written',
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

  List<Widget> _buildModuleSection({
    required int module,
    required Map<int, List<ScrollEntry>> entriesByArc,
    required bool isAr,
  }) {
    final title = moduleTitles[module]!;
    final arcs = scrollArcs.where((a) => a.module == module).toList();
    return [
      Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 10),
        child: Text(
          isAr ? title.ar : title.en,
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          textAlign: isAr ? TextAlign.right : TextAlign.left,
          style: GoogleFonts.cinzelDecorative(
            color: AppColors.gold.withAlpha(180),
            fontSize: 13,
            letterSpacing: 2,
          ),
        ),
      ),
      for (final arc in arcs)
        _ArcScroll(
          arc: arc,
          entries: entriesByArc[arc.index] ?? const [],
          isAr: isAr,
          expanded: _expanded.contains(arc.index),
          onToggle: () {
            setState(() {
              if (_expanded.contains(arc.index)) {
                _expanded.remove(arc.index);
              } else {
                _expanded.add(arc.index);
              }
            });
          },
        ),
      const SizedBox(height: 14),
    ];
  }
}

class _ArcScroll extends StatelessWidget {
  final ScrollArc arc;
  final List<ScrollEntry> entries;
  final bool isAr;
  final bool expanded;
  final VoidCallback onToggle;

  const _ArcScroll({
    required this.arc,
    required this.entries,
    required this.isAr,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    int completedCount = 0;
    for (final e in entries) {
      if (PrefsService.isEventCompleted(e.globalOrder)) completedCount++;
    }
    final total = arc.eventCount;
    final isSealed = completedCount == 0;
    final isComplete = completedCount >= total;
    // Complete arcs auto-expand; partial obey toggle; sealed never expand.
    final shouldExpand = isSealed ? false : (isComplete ? true : expanded);

    final borderColor = isSealed
        ? AppColors.textMuted.withAlpha(40)
        : isComplete
            ? AppColors.gold.withAlpha(140)
            : AppColors.gold.withAlpha(80);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: isComplete
              ? [
                  BoxShadow(
                    color: AppColors.gold.withAlpha(25),
                    blurRadius: 16,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header row — tappable for partial arcs.
            GestureDetector(
              onTap: isSealed ? null : onToggle,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  textDirection:
                      isAr ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    Icon(
                      isSealed
                          ? Icons.lock_rounded
                          : isComplete
                              ? Icons.auto_stories_rounded
                              : Icons.menu_book_rounded,
                      color: isSealed
                          ? AppColors.textMuted.withAlpha(120)
                          : AppColors.gold,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? arc.titleAr : arc.titleEn,
                            textDirection: isAr
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            style: GoogleFonts.cinzelDecorative(
                              color: isSealed
                                  ? AppColors.textMuted.withAlpha(160)
                                  : AppColors.gold,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            isAr
                                ? 'الأحداث ${arc.firstEvent}–${arc.lastEvent} · $completedCount/$total'
                                : 'Events ${arc.firstEvent}–${arc.lastEvent} · $completedCount/$total notes',
                            textDirection: isAr
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            style: GoogleFonts.nunito(
                              color: AppColors.textMuted.withAlpha(180),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isSealed && !isComplete)
                      Icon(
                        expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.gold.withAlpha(160),
                        size: 20,
                      ),
                    if (isComplete)
                      Icon(Icons.check_circle_rounded,
                          color: AppColors.gold, size: 18),
                  ],
                ),
              ),
            ),
            // Body — notes list
            if (shouldExpand)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Column(
                  children: [
                    Container(
                      height: 1,
                      color: AppColors.gold.withAlpha(40),
                    ),
                    const SizedBox(height: 12),
                    for (int order = arc.firstEvent;
                        order <= arc.lastEvent;
                        order++) ...[
                      _buildNoteRow(context, order),
                      if (order < arc.lastEvent) const SizedBox(height: 6),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteRow(BuildContext context, int order) {
    final entry = entries.firstWhere(
      (e) => e.globalOrder == order,
      orElse: () => ScrollEntry(
        eventId: '',
        lineEn: '',
        lineAr: '',
        globalOrder: order,
      ),
    );
    final isData = entry.eventId.isNotEmpty;
    final isDone = PrefsService.isEventCompleted(order);

    if (!isData) {
      // Future / out-of-data event — dotted placeholder
      return _DottedPlaceholder();
    }
    if (!isDone) {
      // Known line but not yet completed
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: AppColors.textMuted.withAlpha(30),
              style: BorderStyle.solid,
              width: 1),
        ),
        child: Row(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Icon(Icons.lock_outline_rounded,
                size: 13, color: AppColors.textMuted.withAlpha(100)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isAr
                    ? 'الحدث ${_toArabicNumeral(order)} — لم يُكتب بعد'
                    : 'Event $order — not written yet',
                style: GoogleFonts.nunito(
                  color: AppColors.textMuted.withAlpha(140),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Completed note
    final body = isAr ? entry.lineAr : entry.lineEn;
    final prefix = isAr
        ? '${_toArabicNumeral(entry.globalOrder)} :الحدث'
        : 'E${entry.globalOrder}:';
    final displayText = '$prefix $body';

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).pop(entry.globalOrder);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gold.withAlpha(50)),
        ),
        child: Text(
          displayText,
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          textAlign: isAr ? TextAlign.right : TextAlign.left,
          style: isAr
              ? GoogleFonts.amiri(
                  color: _kTextWarm,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.85,
                )
              : GoogleFonts.lora(
                  color: _kTextWarm,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.85,
                ),
        ),
      ),
    );
  }

  static String _toArabicNumeral(int n) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((d) => arabicDigits[int.parse(d)]).join();
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
