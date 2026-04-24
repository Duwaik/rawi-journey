import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../data/arc_registry.dart';
import '../data/scroll_entries.dart';
import '../models/scroll_entry.dart';
import '../services/prefs_service.dart';

/// R28-S2-UI1+UI2 · Wrapped-scroll card grid + tap-to-unroll preview panel.
///
/// Each module section renders 5 arc cards in a 2-column row layout. Locked
/// arcs render as a gray wax-sealed scroll (no tap response). Unlocked arcs
/// render as an amber parchment scroll with a coral cord — tap unrolls in
/// place: card height grows, cord fades out, preview rows fade in row-by-row
/// inside the parchment area. Tap outside (or tap-the-same-card) re-rolls.
///
/// Only one card may be unrolled at a time. Tapping a different unlocked
/// card while one is open closes the current card before opening the new
/// one (sequential, to avoid layout jank).
///
/// Unlock rule: `PrefsService.currentOrder >= arc.firstEvent`. (Equivalent
/// to "any event in the arc range is current or completed", since
/// currentOrder is the next-to-play event.)
class ScrollViewerScreen extends StatefulWidget {
  const ScrollViewerScreen({super.key});

  @override
  State<ScrollViewerScreen> createState() => _ScrollViewerScreenState();
}

class _ScrollViewerScreenState extends State<ScrollViewerScreen>
    with TickerProviderStateMixin {
  static const _bg = Color(0xFF04060D);

  // ── Unroll state + animation ──
  int? _expandedArcId;
  late final AnimationController _ctrl;
  late final Animation<double> _progress;
  bool _switching = false; // guards against concurrent tap handlers

  // ── R28-S2-FX1 · Seal-break animations (per-arc, parallel) ──
  // One controller per arc currently animating. Map entry is added when
  // the animation starts and removed (controller disposed) when it ends.
  final Map<int, AnimationController> _sealCtrls = {};

  // ── globalOrder → ScrollEntry lookup (built once) ──
  late final Map<int, ScrollEntry> _entriesByOrder = {
    for (final e in scrollEntries.values) e.globalOrder: e,
  };

  bool get _isAr => PrefsService.isAr;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _progress = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);

    // Schedule seal-break work after first frame so we have a Scaffold
    // to mount into before any setStates fire.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runSealBreakLifecycle();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    for (final c in _sealCtrls.values) {
      c.dispose();
    }
    _sealCtrls.clear();
    super.dispose();
  }

  /// One-shot post-frame routine:
  ///   • First time on this build: silently mark every currently-unlocked
  ///     arc as "seal broken" — no animation cascade for users coming
  ///     from a prior build with arcs already unlocked.
  ///   • Subsequent opens: any arc that is unlocked but not yet flagged
  ///     gets its seal-break animation queued. Multiple animations fire
  ///     sequentially top-to-bottom with 200 ms stagger between starts
  ///     (so they overlap visually).
  Future<void> _runSealBreakLifecycle() async {
    if (!mounted) return;
    final currentOrder = PrefsService.currentOrder;

    if (!PrefsService.scrollSealBackfillDone) {
      for (final a in arcRegistry) {
        if (currentOrder >= a.firstEvent &&
            !PrefsService.isArcSealBroken(a.arcId)) {
          await PrefsService.setArcSealBroken(a.arcId);
        }
      }
      await PrefsService.setScrollSealBackfillDone();
      return; // backfill is silent — no animation queueing
    }

    final pending = <int>[
      for (final a in arcRegistry)
        if (currentOrder >= a.firstEvent &&
            !PrefsService.isArcSealBroken(a.arcId))
          a.arcId,
    ]..sort();

    for (int i = 0; i < pending.length; i++) {
      if (!mounted) return;
      if (i > 0) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
      if (!mounted) return;
      _startSealBreak(pending[i]);
    }
  }

  void _startSealBreak(int arcId) {
    if (_sealCtrls.containsKey(arcId)) return;
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _sealCtrls[arcId] = ctrl;
    setState(() {});
    ctrl.forward().whenComplete(() async {
      await PrefsService.setArcSealBroken(arcId);
      if (!mounted) {
        ctrl.dispose();
        return;
      }
      ctrl.dispose();
      setState(() {
        _sealCtrls.remove(arcId);
      });
    });
  }

  Future<void> _onCardTap(int arcId) async {
    if (_switching) return;
    // Per spec: re-roll happens via outside-tap, not via tap on the same
    // expanded card. Tapping the same expanded card is a no-op.
    if (_expandedArcId == arcId) return;
    _switching = true;
    try {
      if (_expandedArcId == null) {
        setState(() => _expandedArcId = arcId);
        await _ctrl.forward(from: 0);
      } else {
        // Sequential switch: close current, then open the new one.
        await _ctrl.reverse();
        if (!mounted) return;
        setState(() => _expandedArcId = arcId);
        await _ctrl.forward(from: 0);
      }
    } finally {
      _switching = false;
    }
  }

  Future<void> _closeIfExpanded() async {
    if (_expandedArcId == null || _switching) return;
    _switching = true;
    try {
      await _ctrl.reverse();
      if (mounted) setState(() => _expandedArcId = null);
    } finally {
      _switching = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = _isAr;
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final currentOrder = PrefsService.currentOrder;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _bg,
        body: GestureDetector(
          // Outside-tap closes the unrolled card. Card InkWells consume the
          // tap before this fires, so a tap on a card never reaches here.
          behavior: HitTestBehavior.translucent,
          onTap: _closeIfExpanded,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_bg, Color(0xFF0B1E2D), _bg],
              ),
            ),
            child: Column(
              children: [
                _AppBar(isAr: isAr, topPad: topPad),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 24),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      for (final m in moduleRegistry)
                        _ModuleSection(
                          module: m,
                          isAr: isAr,
                          currentOrder: currentOrder,
                          expandedArcId: _expandedArcId,
                          progress: _progress,
                          entriesByOrder: _entriesByOrder,
                          onCardTap: _onCardTap,
                          sealCtrls: _sealCtrls,
                        ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── AppBar ──────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final bool isAr;
  final double topPad;
  const _AppBar({required this.isAr, required this.topPad});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                border: Border.all(color: AppColors.gold.withAlpha(60)),
              ),
              child: Icon(
                isAr
                    ? Icons.arrow_forward_rounded
                    : Icons.arrow_back_rounded,
                size: 18,
                color: AppColors.gold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isAr ? 'سِجِلّ الراوي' : 'The Rawi’s Scroll',
              style: GoogleFonts.cinzelDecorative(
                fontSize: 20,
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Module section ──────────────────────────────────────────────────────────

class _ModuleSection extends StatelessWidget {
  final ModuleDefinition module;
  final bool isAr;
  final int currentOrder;
  final int? expandedArcId;
  final Animation<double> progress;
  final Map<int, ScrollEntry> entriesByOrder;
  final Future<void> Function(int) onCardTap;
  final Map<int, AnimationController> sealCtrls;

  const _ModuleSection({
    required this.module,
    required this.isAr,
    required this.currentOrder,
    required this.expandedArcId,
    required this.progress,
    required this.entriesByOrder,
    required this.onCardTap,
    required this.sealCtrls,
  });

  @override
  Widget build(BuildContext context) {
    final arcs = arcsInModule(module.moduleId);
    // 5 arcs → 3 rows: [0,1] [2,3] [4]
    final rows = <List<ArcDefinition>>[
      [arcs[0], arcs[1]],
      [arcs[2], arcs[3]],
      [arcs[4]],
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const gutter = 12.0;
        final cellW = (constraints.maxWidth - gutter) / 2;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            _ModuleHeader(module: module, isAr: isAr),
            const SizedBox(height: 12),
            for (int r = 0; r < rows.length; r++) ...[
              _CardRow(
                arcs: rows[r],
                cellW: cellW,
                gutter: gutter,
                isAr: isAr,
                currentOrder: currentOrder,
                expandedArcId: expandedArcId,
                progress: progress,
                entriesByOrder: entriesByOrder,
                onCardTap: onCardTap,
                sealCtrls: sealCtrls,
              ),
              if (r < rows.length - 1) const SizedBox(height: 16),
            ],
          ],
        );
      },
    );
  }
}

class _ModuleHeader extends StatelessWidget {
  final ModuleDefinition module;
  final bool isAr;
  const _ModuleHeader({required this.module, required this.isAr});

  static const List<String> _arabicDigits = [
    '٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩',
  ];

  static String toArabicNum(int n) =>
      n.toString().split('').map((d) => _arabicDigits[int.parse(d)]).join();

  @override
  Widget build(BuildContext context) {
    final label = isAr
        ? 'الفصل ${toArabicNum(module.moduleId)}'
        : 'MODULE ${module.moduleId}';
    final count = isAr
        ? '${toArabicNum(module.eventCount)} حدثاً'
        : '${module.eventCount} events';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 0.8,
                color: AppColors.gold.withAlpha(60),
                margin: const EdgeInsets.only(right: 10),
              ),
            ),
            Text(
              label,
              style: GoogleFonts.cinzelDecorative(
                color: AppColors.gold.withAlpha(180),
                fontSize: 11,
                letterSpacing: 2.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            Expanded(
              child: Container(
                height: 0.8,
                color: AppColors.gold.withAlpha(60),
                margin: const EdgeInsets.only(left: 10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          isAr ? module.nameAr : module.nameEn,
          textAlign: TextAlign.center,
          style: GoogleFonts.cinzelDecorative(
            color: AppColors.gold,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          count,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            color: AppColors.textMuted.withAlpha(180),
            fontSize: 10.5,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

// ── Card row (1 or 2 cards, top-aligned) ───────────────────────────────────

class _CardRow extends StatelessWidget {
  final List<ArcDefinition> arcs;
  final double cellW;
  final double gutter;
  final bool isAr;
  final int currentOrder;
  final int? expandedArcId;
  final Animation<double> progress;
  final Map<int, ScrollEntry> entriesByOrder;
  final Future<void> Function(int) onCardTap;
  final Map<int, AnimationController> sealCtrls;

  const _CardRow({
    required this.arcs,
    required this.cellW,
    required this.gutter,
    required this.isAr,
    required this.currentOrder,
    required this.expandedArcId,
    required this.progress,
    required this.entriesByOrder,
    required this.onCardTap,
    required this.sealCtrls,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < arcs.length; i++) ...[
          if (i > 0) SizedBox(width: gutter),
          SizedBox(
            width: cellW,
            child: _ArcCard(
              arc: arcs[i],
              cellW: cellW,
              isAr: isAr,
              currentOrder: currentOrder,
              expandedArcId: expandedArcId,
              progress: progress,
              entriesByOrder: entriesByOrder,
              onTap: () => onCardTap(arcs[i].arcId),
              sealAnim: sealCtrls[arcs[i].arcId],
            ),
          ),
        ],
      ],
    );
  }
}

// ── Arc card ────────────────────────────────────────────────────────────────

class _ArcCard extends StatelessWidget {
  final ArcDefinition arc;
  final double cellW;
  final bool isAr;
  final int currentOrder;
  final int? expandedArcId;
  final Animation<double> progress;
  final Map<int, ScrollEntry> entriesByOrder;
  final VoidCallback onTap;
  /// Non-null while this arc is mid seal-break animation. Painter reads
  /// .value to advance the crack → fragments → particles → color-shift →
  /// cord-fade-in sequence.
  final Animation<double>? sealAnim;

  const _ArcCard({
    required this.arc,
    required this.cellW,
    required this.isAr,
    required this.currentOrder,
    required this.expandedArcId,
    required this.progress,
    required this.entriesByOrder,
    required this.onTap,
    required this.sealAnim,
  });

  bool get _isUnlocked => currentOrder >= arc.firstEvent;
  bool get _isThisExpanded => expandedArcId == arc.arcId;

  int get _completedCount {
    int c = 0;
    for (int o = arc.firstEvent; o <= arc.lastEvent; o++) {
      if (PrefsService.isEventCompleted(o)) c++;
    }
    return c;
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = _isUnlocked;
    final progressLabel = unlocked
        ? (isAr
            ? '${_ModuleHeader.toArabicNum(_completedCount)}/${_ModuleHeader.toArabicNum(arc.eventCount)}'
            : '$_completedCount/${arc.eventCount}')
        : (isAr ? 'مختوم' : 'sealed');

    final closedH = cellW * 4 / 3;
    final visibleEntryCount =
        (currentOrder - arc.firstEvent + 1).clamp(0, arc.eventCount);
    final lockedCount = arc.eventCount - visibleEntryCount;
    final hasSummary = lockedCount > 0;
    final panelExtraH = _computePanelExtraHeight(
      visibleEntryCount: visibleEntryCount,
      hasSummary: hasSummary,
    );
    final openH = closedH + panelExtraH;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: unlocked ? onTap : null,
            borderRadius: BorderRadius.circular(8),
            splashColor:
                unlocked ? AppColors.gold.withAlpha(40) : Colors.transparent,
            highlightColor: Colors.transparent,
            child: AnimatedBuilder(
              animation: sealAnim == null
                  ? progress
                  : Listenable.merge([progress, sealAnim!]),
              builder: (context, _) {
                final t = _isThisExpanded ? progress.value : 0.0;
                final h = lerpDouble(closedH, openH, t)!;
                // sealBreakProgress: 0 = pre-break (visually locked even
                // though arc is unlocked), 1 = post-break (visually
                // unlocked). null AnimationController means "no transition
                // in flight" — render fully unlocked (1.0) since we got
                // here past the unlock check.
                final sealBreakT = sealAnim?.value ?? 1.0;
                return SizedBox(
                  width: cellW,
                  height: h,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _ScrollGraphicPainter(
                            unlocked: unlocked,
                            cordOpacity: unlocked ? (1 - t) : 0,
                            sealBreakProgress: sealBreakT,
                          ),
                        ),
                      ),
                      if (unlocked && t > 0)
                        Positioned.fill(
                          // Absorb row taps so they don't bubble to the
                          // InkWell (which would no-op anyway on this same
                          // expanded card, but absorbing also kills the
                          // ripple — matches "rows are not interactive").
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {},
                            child: _PreviewPanel(
                              arc: arc,
                              isAr: isAr,
                              currentOrder: currentOrder,
                              entriesByOrder: entriesByOrder,
                              t: t,
                              visibleEntryCount: visibleEntryCount,
                              lockedCount: lockedCount,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isAr ? arc.titleAr : arc.titleEn,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: isAr
              ? GoogleFonts.amiri(
                  color: unlocked
                      ? const Color(0xFFE8D8B8)
                      : AppColors.textMuted.withAlpha(180),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                )
              : GoogleFonts.lora(
                  color: unlocked
                      ? const Color(0xFFE8D8B8)
                      : AppColors.textMuted.withAlpha(180),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                ),
        ),
        const SizedBox(height: 2),
        Text(
          progressLabel,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            color: unlocked
                ? AppColors.gold.withAlpha(180)
                : const Color(0xFF7B1F1A).withAlpha(200),
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            fontStyle: unlocked ? FontStyle.normal : FontStyle.italic,
          ),
        ),
      ],
    );
  }

  /// Extra card height needed to host the unrolled preview panel.
  double _computePanelExtraHeight({
    required int visibleEntryCount,
    required bool hasSummary,
  }) {
    const rowH = 34.0;
    const summaryH = 32.0;
    const topPad = 6.0;
    const bottomPad = 6.0;
    return topPad +
        visibleEntryCount * rowH +
        (hasSummary ? summaryH : 0.0) +
        bottomPad;
  }
}

// ── Preview panel (rendered inside the parchment when t > 0) ───────────────

class _PreviewPanel extends StatelessWidget {
  final ArcDefinition arc;
  final bool isAr;
  final int currentOrder;
  final Map<int, ScrollEntry> entriesByOrder;
  final double t; // 0..1
  final int visibleEntryCount;
  final int lockedCount;

  const _PreviewPanel({
    required this.arc,
    required this.isAr,
    required this.currentOrder,
    required this.entriesByOrder,
    required this.t,
    required this.visibleEntryCount,
    required this.lockedCount,
  });

  @override
  Widget build(BuildContext context) {
    // Top inset = original closed graphic top-cap region. Below that,
    // the unrolled parchment stretches. We render rows in the parchment
    // area only — leave room for caps top + bottom.
    return LayoutBuilder(
      builder: (context, c) {
        final h = c.maxHeight;
        final w = c.maxWidth;
        final capH = (w * 4 / 3) * 0.09; // matches painter's capH for closedH
        // Panel content lives in the body area between the (animated) caps.
        // The bottom cap sits at h - capH — that anchors visually.
        final bodyTop = capH + 8;
        final bodyBottom = h - capH - 6;
        final bodyHeight = (bodyBottom - bodyTop).clamp(0.0, double.infinity);

        // Stagger config — row N starts fading in at t = N * step.
        const step = 0.06;
        const fadeWindow = 0.18;
        const summaryStart = 0.55;
        const summaryWindow = 0.25;

        double rowOpacity(int rowIndex) {
          final start = rowIndex * step;
          final v = ((t - start) / fadeWindow).clamp(0.0, 1.0);
          return v;
        }

        double summaryOpacity() {
          final v = ((t - summaryStart) / summaryWindow).clamp(0.0, 1.0);
          return v;
        }

        return ClipRect(
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, bodyTop, 8, h - bodyBottom),
            child: SizedBox(
              height: bodyHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < visibleEntryCount; i++) ...[
                    Opacity(
                      opacity: rowOpacity(i),
                      child: _PreviewRow(
                        entryIndex: i + 1,
                        eventOrder: arc.firstEvent + i,
                        entry: entriesByOrder[arc.firstEvent + i],
                        isAr: isAr,
                      ),
                    ),
                    if (i < visibleEntryCount - 1)
                      Container(
                        height: 0.5,
                        color: const Color(0xFF6B4A1E).withAlpha(80),
                      ),
                  ],
                  if (lockedCount > 0)
                    Opacity(
                      opacity: summaryOpacity(),
                      child: _LockedSummary(
                        count: lockedCount,
                        isAr: isAr,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final int entryIndex;
  final int eventOrder;
  final ScrollEntry? entry;
  final bool isAr;

  const _PreviewRow({
    required this.entryIndex,
    required this.eventOrder,
    required this.entry,
    required this.isAr,
  });

  static String _firstSentence(String body) {
    if (body.isEmpty) return body;
    final regex = RegExp(r'[.!?؟]');
    final m = regex.firstMatch(body);
    if (m != null && m.start <= 80) {
      return body.substring(0, m.start + 1);
    }
    if (body.length > 80) {
      return '${body.substring(0, 80)}…';
    }
    return body;
  }

  @override
  Widget build(BuildContext context) {
    final hasText = entry != null && (isAr ? entry!.lineAr : entry!.lineEn).isNotEmpty;
    final preview = hasText
        ? _firstSentence(isAr ? entry!.lineAr : entry!.lineEn)
        : (isAr ? 'قيد الكتابة…' : 'Entry yet to be written…');

    final label = isAr
        ? 'مدخل ${_ModuleHeader.toArabicNum(entryIndex)} · حدث ${_ModuleHeader.toArabicNum(eventOrder)}'
        : 'ENTRY $entryIndex · EVENT $eventOrder';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: GoogleFonts.nunito(
                color: const Color(0xFF6B4A1E),
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                height: 1.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              preview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: isAr
                  ? GoogleFonts.amiri(
                      color: const Color(0xFF3D2A10),
                      fontSize: 10.5,
                      fontStyle: FontStyle.italic,
                      height: 1.3,
                    )
                  : GoogleFonts.lora(
                      color: const Color(0xFF3D2A10),
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      height: 1.3,
                    ),
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            isAr ? Icons.play_arrow_rounded : Icons.play_arrow_rounded,
            size: 14,
            color: const Color(0xFF8B6D2E).withAlpha(220),
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          ),
        ],
      ),
    );
  }
}

class _LockedSummary extends StatelessWidget {
  final int count;
  final bool isAr;
  const _LockedSummary({required this.count, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final text = isAr
        ? '${_ModuleHeader.toArabicNum(count)} قيد الكتابة…'
        : '$count entries yet to be written…';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomPaint(
            painter: _DashedRulePainter(
              color: const Color(0xFF6B4A1E).withAlpha(120),
            ),
            child: const SizedBox(height: 1),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            textAlign: TextAlign.center,
            style: isAr
                ? GoogleFonts.amiri(
                    color: const Color(0xFF6B4A1E),
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  )
                : GoogleFonts.lora(
                    color: const Color(0xFF6B4A1E),
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
          ),
        ],
      ),
    );
  }
}

class _DashedRulePainter extends CustomPainter {
  final Color color;
  _DashedRulePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.8;
    const dashW = 4.0;
    const gap = 3.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(x + dashW, size.height / 2),
        paint,
      );
      x += dashW + gap;
    }
  }

  @override
  bool shouldRepaint(_DashedRulePainter old) => old.color != color;
}

// ── Scroll graphic painter ──────────────────────────────────────────────────

class _ScrollGraphicPainter extends CustomPainter {
  /// Whether the arc is unlocked at the data layer. When false, the painter
  /// always renders the locked (wax-sealed gray) state and ignores
  /// [sealBreakProgress] / [cordOpacity].
  final bool unlocked;

  /// Cord-only fade — used by UI2's unroll (cord fades out as parchment
  /// extends). 1 = full cord, 0 = no cord. Multiplies the cord alpha that
  /// the seal-break phase produces, so the two animations compose.
  final double cordOpacity;

  /// FX1 seal-break sequence. 0 = pre-break (visually locked even though
  /// `unlocked` is true), 1 = post-break (visually unlocked). When no
  /// animation is in flight, callers pass 1.0.
  final double sealBreakProgress;

  const _ScrollGraphicPainter({
    required this.unlocked,
    required this.cordOpacity,
    required this.sealBreakProgress,
  });

  static const _parchmentUnlocked = Color(0xFFD4A95C);
  static const _capUnlocked       = Color(0xFF8B6D2E);
  static const _ruleUnlocked      = Color(0x33402A10);
  static const _cord              = Color(0xFFB03A30);
  static const _cordShadow        = Color(0xFF6D1F18);

  static const _parchmentLocked = Color(0xFF5A564E);
  static const _capLocked       = Color(0xFF3D3A35);
  static const _ruleLocked      = Color(0x228E8678);
  static const _waxSeal         = Color(0xFF7B1F1A);
  static const _waxSealHighlight = Color(0xFFA73028);
  static const _waxSealShadow   = Color(0xFF4A100C);

  // ── Phase windows (over normalized 0..1 sealBreakProgress) ──────────
  // Crack appears: 0.00–0.20
  // Fragments split + fall: 0.18–0.55
  // Particle puff:           0.18–0.40
  // Color shift gray→amber:  0.20–0.65
  // Cord fade-in:            0.60–0.85
  static double _phase(double p, double start, double end) =>
      ((p - start) / (end - start)).clamp(0.0, 1.0);

  static double _easeOut(double t) => 1 - (1 - t) * (1 - t);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Cap height is fixed to width-based ratio so caps stay visually
    // anchored at top/bottom as the card grows. Closed card height = w*4/3,
    // cap = 9 % of that = w * 0.12.
    final capH = w * 0.12;
    final bodyTop = capH;
    final bodyBottom = h - capH;
    final bodyRect = Rect.fromLTRB(0, bodyTop, w, bodyBottom);

    // ── Resolve current colors based on lock state + seal-break phase ─
    final colorT = unlocked
        ? _easeOut(_phase(sealBreakProgress, 0.20, 0.65))
        : 0.0;
    final parchment = unlocked
        ? Color.lerp(_parchmentLocked, _parchmentUnlocked, colorT)!
        : _parchmentLocked;
    final cap = unlocked
        ? Color.lerp(_capLocked, _capUnlocked, colorT)!
        : _capLocked;
    final rule = unlocked
        ? Color.lerp(_ruleLocked, _ruleUnlocked, colorT)!
        : _ruleLocked;

    // ── Body ────────────────────────────────────────────────────────
    canvas.drawRect(bodyRect, Paint()..color = parchment);

    canvas.drawRect(
      bodyRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            cap.withAlpha(40),
            Colors.transparent,
            cap.withAlpha(40),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(bodyRect),
    );

    // ── Horizontal rules ────────────────────────────────────────────
    final rulePaint = Paint()..color = rule..strokeWidth = 0.8;
    final bodyH = bodyBottom - bodyTop;
    const ruleCount = 4;
    final inset = w * 0.10;
    for (int i = 1; i <= ruleCount; i++) {
      final y = bodyTop + bodyH * i / (ruleCount + 1);
      canvas.drawLine(
        Offset(inset, y),
        Offset(w - inset, y),
        rulePaint,
      );
    }

    // ── End caps ────────────────────────────────────────────────────
    _paintCap(canvas, Rect.fromLTWH(0, 0, w, capH), cap);
    _paintCap(canvas, Rect.fromLTWH(0, h - capH, w, capH), cap);

    // ── Wax seal (locked OR mid seal-break) ─────────────────────────
    if (!unlocked) {
      _paintWaxSeal(canvas, size);
    } else if (sealBreakProgress < 0.55) {
      // Fragmenting state — fades out as fragments fall.
      final fragT = _phase(sealBreakProgress, 0.18, 0.55);
      _paintWaxSealFragmenting(canvas, size, fragT);
      // Crack line — visible 0..0.30 (fades out as fragments take over).
      final crackT = _phase(sealBreakProgress, 0.0, 0.20);
      final crackFade =
          1.0 - _phase(sealBreakProgress, 0.20, 0.30); // hold then fade
      if (crackT > 0 && crackFade > 0) {
        _paintCrack(canvas, size, crackT, crackFade);
      }
      // Particles — visible 0.18..0.40
      final partT = _phase(sealBreakProgress, 0.18, 0.40);
      if (partT > 0 && partT < 1) {
        _paintParticles(canvas, size, partT);
      }
    }

    // ── Cord ────────────────────────────────────────────────────────
    // Composes with cordOpacity (UI2 unroll fade-out).
    if (unlocked) {
      final cordPhaseAlpha = _easeOut(_phase(sealBreakProgress, 0.60, 0.85));
      final cordA = cordPhaseAlpha * cordOpacity;
      if (cordA > 0) {
        _paintCord(canvas, size, bodyTop, bodyBottom, cordA);
      }
    }
  }

  // ── Cap ──────────────────────────────────────────────────────────────

  void _paintCap(Canvas canvas, Rect rect, Color base) {
    final rrect =
        RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 2));
    canvas.drawRRect(rrect, Paint()..color = base);

    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withAlpha(70), Colors.transparent],
        ).createShader(rect),
    );

    canvas.drawLine(
      Offset(rect.left + 6, rect.center.dy),
      Offset(rect.right - 6, rect.center.dy),
      Paint()
        ..color = Colors.black.withAlpha(90)
        ..strokeWidth = 0.8,
    );
  }

  // ── Cord ─────────────────────────────────────────────────────────────

  void _paintCord(
      Canvas canvas, Size size, double bodyTop, double bodyBottom, double op) {
    final w = size.width;
    final cx = w / 2;
    final bodyCenterY = (bodyTop + bodyBottom) / 2;
    final a = (op * 255).round();

    const cordWidth = 6.0;
    final cordRect = Rect.fromLTWH(
      cx - cordWidth / 2,
      bodyTop,
      cordWidth,
      bodyBottom - bodyTop,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(cordRect, const Radius.circular(2)),
      Paint()..color = _cord.withAlpha(a),
    );

    canvas.drawRect(
      Rect.fromLTWH(cx - cordWidth / 2, bodyTop, 1.4, bodyBottom - bodyTop),
      Paint()..color = _cordShadow.withAlpha((180 * op).round()),
    );

    final knot = Paint()..color = _cord.withAlpha(a);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, bodyCenterY), width: 14, height: 8),
      knot,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx - 8, bodyCenterY - 3), width: 10, height: 6),
      knot,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx + 8, bodyCenterY - 3), width: 10, height: 6),
      knot,
    );

    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, bodyCenterY - 1), width: 6, height: 2.5),
      Paint()..color = Colors.white.withAlpha((50 * op).round()),
    );
  }

  // ── Wax seal — full + fragmenting + crack + particles ────────────────

  void _paintWaxSeal(Canvas canvas, Size size) {
    _paintWaxSealAt(canvas, size, opacity: 1, dx: 0, dy: 0, scale: 1);
  }

  void _paintWaxSealFragmenting(Canvas canvas, Size size, double fragT) {
    // 3 fragments, each translated outward + falling with gravity, fading
    // out over the phase. fragT 0..1.
    final w = size.width;
    final h = size.height;
    final r = w * 0.22;
    final center = Offset(w / 2, h / 2);
    final fall = fragT * fragT * (h * 0.18); // quadratic gravity

    final fragments = <_Fragment>[
      _Fragment(angle: -1.4, distMul: 1.6, scale: 0.55), // up-left
      _Fragment(angle:  1.7, distMul: 1.3, scale: 0.50), // down-right
      _Fragment(angle:  3.1, distMul: 1.1, scale: 0.45), // left
    ];

    final opacity = (1.0 - fragT).clamp(0.0, 1.0);

    // First, draw a faint full-seal underlay at low opacity so the seal
    // doesn't pop out — it appears to "shatter" rather than vanish.
    final underlay = (1.0 - _phase(fragT, 0.0, 0.4)).clamp(0.0, 1.0);
    if (underlay > 0) {
      _paintWaxSealAt(canvas, size,
          opacity: underlay * 0.7, dx: 0, dy: fall * 0.3, scale: 1);
    }

    for (final f in fragments) {
      final dx = math.cos(f.angle) * r * 0.4 * fragT * f.distMul;
      final dy = math.sin(f.angle) * r * 0.2 * fragT * f.distMul + fall;
      final c = center.translate(dx, dy);
      _paintFragmentBlob(canvas, c, r * f.scale, opacity);
    }
  }

  void _paintFragmentBlob(
      Canvas canvas, Offset c, double r, double opacity) {
    if (opacity <= 0) return;
    final a = (opacity * 255).round();
    canvas.drawCircle(c, r, Paint()..color = _waxSeal.withAlpha(a));
    canvas.drawCircle(
      c.translate(-r * 0.3, -r * 0.2),
      r * 0.6,
      Paint()..color = _waxSealHighlight.withAlpha((140 * opacity).round()),
    );
    canvas.drawCircle(
      c.translate(r * 0.25, r * 0.25),
      r * 0.45,
      Paint()..color = _waxSealShadow.withAlpha((170 * opacity).round()),
    );
  }

  void _paintWaxSealAt(
    Canvas canvas,
    Size size, {
    required double opacity,
    required double dx,
    required double dy,
    required double scale,
  }) {
    if (opacity <= 0) return;
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2).translate(dx, dy);
    final r = w * 0.22 * scale;
    final a = (opacity * 255).round();

    canvas.drawCircle(
      center.translate(1.5, 2.5),
      r,
      Paint()
        ..color = Colors.black.withAlpha((90 * opacity).round())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    final wax = Paint()..color = _waxSeal.withAlpha(a);
    canvas.drawCircle(center, r, wax);
    canvas.drawCircle(center.translate(-r * 0.3, -r * 0.2), r * 0.55, wax);
    canvas.drawCircle(center.translate(r * 0.35, r * 0.15), r * 0.55, wax);
    canvas.drawCircle(center.translate(r * 0.1, -r * 0.35), r * 0.5, wax);
    canvas.drawCircle(center.translate(-r * 0.2, r * 0.3), r * 0.5, wax);

    canvas.drawCircle(
      center.translate(-r * 0.25, -r * 0.25),
      r * 0.35,
      Paint()..color = _waxSealHighlight.withAlpha((140 * opacity).round()),
    );

    canvas.drawCircle(
      center.translate(r * 0.25, r * 0.25),
      r * 0.45,
      Paint()..color = _waxSealShadow.withAlpha((170 * opacity).round()),
    );

    canvas.drawCircle(
      center,
      r * 0.18,
      Paint()..color = _waxSealShadow.withAlpha(a),
    );
  }

  void _paintCrack(Canvas canvas, Size size, double extendT, double fade) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final r = w * 0.22;
    final a = (fade * 220).round();
    final paint = Paint()
      ..color = _waxSealShadow.withAlpha(a)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // Diagonal crack growing from centre outward, both directions.
    final ext = r * 0.95 * extendT;
    final dir = const Offset(0.94, -0.34); // ~20° upward-right
    canvas.drawLine(
      center - dir * ext,
      center + dir * ext,
      paint,
    );
  }

  void _paintParticles(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    const n = 10;
    final maxDist = w * 0.18;
    for (int i = 0; i < n; i++) {
      // Deterministic spread via golden-angle-ish stride.
      final angle = i * (2 * math.pi / n) + (i.isOdd ? 0.3 : -0.3);
      final speed = 0.7 + (i % 3) * 0.15;
      final dist = maxDist * t * speed;
      final dx = math.cos(angle) * dist;
      final dy = math.sin(angle) * dist + (t * t) * h * 0.04; // gravity bias
      final pos = center + Offset(dx, dy);
      // Fade in 0..0.25, hold to 0.55, fade out 0.55..1.0
      double a;
      if (t < 0.25) {
        a = t / 0.25;
      } else if (t < 0.55) {
        a = 1.0;
      } else {
        a = 1.0 - (t - 0.55) / 0.45;
      }
      a = a.clamp(0.0, 1.0);
      final radius = 1.5 + (i % 2) * 0.6;
      canvas.drawCircle(
        pos,
        radius,
        Paint()..color = _waxSeal.withAlpha((a * 230).round()),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScrollGraphicPainter old) =>
      old.unlocked != unlocked ||
      old.cordOpacity != cordOpacity ||
      old.sealBreakProgress != sealBreakProgress;
}

class _Fragment {
  final double angle;     // radians
  final double distMul;   // distance multiplier
  final double scale;     // size relative to seal radius
  const _Fragment({
    required this.angle,
    required this.distMul,
    required this.scale,
  });
}
