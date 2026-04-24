import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../data/arc_registry.dart';
import '../services/prefs_service.dart';

/// R28-S2-UI1 · Wrapped-scroll card grid of the 20 narrative arcs.
///
/// Replaces the prior flat/grouped feed. Four module sections, each with
/// a 2-column grid of 5 arc cards. Locked arcs render as a gray wax-sealed
/// scroll — no tap response. Unlocked arcs render as an amber parchment
/// scroll with a coral cord — tap is a no-op in UI1 (UI2 wires the unroll).
///
/// Unlock rule (per spec): an arc is unlocked iff any event in its range
/// is `current` or `completed`. Since `currentOrder` advances past every
/// completed event and equals the next-to-play event, this reduces to
/// `PrefsService.currentOrder >= arc.firstEvent`.
class ScrollViewerScreen extends StatefulWidget {
  const ScrollViewerScreen({super.key});

  @override
  State<ScrollViewerScreen> createState() => _ScrollViewerScreenState();
}

class _ScrollViewerScreenState extends State<ScrollViewerScreen> {
  static const _bg = Color(0xFF04060D);

  bool get _isAr => PrefsService.isAr;

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
                      ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
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

// ── Module section (header + 2-col grid of 5 cards) ────────────────────────

class _ModuleSection extends StatelessWidget {
  final ModuleDefinition module;
  final bool isAr;
  final int currentOrder;

  const _ModuleSection({
    required this.module,
    required this.isAr,
    required this.currentOrder,
  });

  @override
  Widget build(BuildContext context) {
    final arcs = arcsInModule(module.moduleId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        _ModuleHeader(module: module, isAr: isAr),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          childAspectRatio: 0.58, // 3:4 scroll graphic + title/progress below
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            for (final arc in arcs)
              _ArcCard(
                arc: arc,
                isAr: isAr,
                currentOrder: currentOrder,
              ),
          ],
        ),
      ],
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

  static String _toArabicNum(int n) =>
      n.toString().split('').map((d) => _arabicDigits[int.parse(d)]).join();

  @override
  Widget build(BuildContext context) {
    final label = isAr
        ? 'الفصل ${_toArabicNum(module.moduleId)}'
        : 'MODULE ${module.moduleId}';
    final count = isAr
        ? '${_toArabicNum(module.eventCount)} حدثاً'
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

// ── Arc card ────────────────────────────────────────────────────────────────

class _ArcCard extends StatelessWidget {
  final ArcDefinition arc;
  final bool isAr;
  final int currentOrder;

  const _ArcCard({
    required this.arc,
    required this.isAr,
    required this.currentOrder,
  });

  bool get _isUnlocked => currentOrder >= arc.firstEvent;

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
    final progress = unlocked
        ? (isAr
            ? '${_ModuleHeader._toArabicNum(_completedCount)}/${_ModuleHeader._toArabicNum(arc.eventCount)}'
            : '$_completedCount/${arc.eventCount}')
        : (isAr ? 'مختوم' : 'sealed');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: unlocked ? () {} : null, // UI2 replaces the body
              borderRadius: BorderRadius.circular(8),
              splashColor: unlocked
                  ? AppColors.gold.withAlpha(40)
                  : Colors.transparent,
              highlightColor: Colors.transparent,
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: CustomPaint(
                  painter: _ScrollGraphicPainter(unlocked: unlocked),
                ),
              ),
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
          progress,
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
}

// ── Scroll graphic painter ──────────────────────────────────────────────────

class _ScrollGraphicPainter extends CustomPainter {
  final bool unlocked;
  const _ScrollGraphicPainter({required this.unlocked});

  // Palette — parchment / caps / seal. Locked = desaturated variants.
  static const _parchmentUnlocked = Color(0xFFD4A95C); // warm amber
  static const _capUnlocked       = Color(0xFF8B6D2E); // darker amber
  static const _ruleUnlocked      = Color(0x33402A10); // subtle lines
  static const _cord              = Color(0xFFB03A30); // coral-red
  static const _cordShadow        = Color(0xFF6D1F18);

  static const _parchmentLocked = Color(0xFF5A564E);
  static const _capLocked       = Color(0xFF3D3A35);
  static const _ruleLocked      = Color(0x228E8678);
  static const _waxSeal         = Color(0xFF7B1F1A); // oxblood
  static const _waxSealHighlight = Color(0xFFA73028);
  static const _waxSealShadow   = Color(0xFF4A100C);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final capH = h * 0.09;
    final bodyTop = capH;
    final bodyBottom = h - capH;
    final bodyRect = Rect.fromLTRB(0, bodyTop, w, bodyBottom);

    // ── Body (parchment) ────────────────────────────────────────────
    final bodyPaint = Paint()
      ..color = unlocked ? _parchmentUnlocked : _parchmentLocked
      ..style = PaintingStyle.fill;
    canvas.drawRect(bodyRect, bodyPaint);

    // subtle inner shading — gradient top-to-bottom for depth
    final bodyShade = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          (unlocked ? _capUnlocked : _capLocked).withAlpha(40),
          Colors.transparent,
          (unlocked ? _capUnlocked : _capLocked).withAlpha(40),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(bodyRect);
    canvas.drawRect(bodyRect, bodyShade);

    // ── Horizontal rule lines (writing guides) ──────────────────────
    final rulePaint = Paint()
      ..color = unlocked ? _ruleUnlocked : _ruleLocked
      ..strokeWidth = 0.8;
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

    // ── End caps (cylindrical bars) ─────────────────────────────────
    _paintCap(canvas, Rect.fromLTWH(0, 0, w, capH));
    _paintCap(canvas, Rect.fromLTWH(0, h - capH, w, capH));

    // ── Cord (unlocked) or Wax seal (locked) ────────────────────────
    if (unlocked) {
      _paintCord(canvas, size, bodyTop, bodyBottom);
    } else {
      _paintWaxSeal(canvas, size);
    }
  }

  void _paintCap(Canvas canvas, Rect rect) {
    final base = unlocked ? _capUnlocked : _capLocked;
    // Outer pill
    final pillPaint = Paint()..color = base;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 2));
    canvas.drawRRect(rrect, pillPaint);

    // Highlight shine along top
    final highlight = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withAlpha(70),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRRect(rrect, highlight);

    // Dark shadow line at centre for roundness
    final shadow = Paint()
      ..color = Colors.black.withAlpha(90)
      ..strokeWidth = 0.8;
    canvas.drawLine(
      Offset(rect.left + 6, rect.center.dy),
      Offset(rect.right - 6, rect.center.dy),
      shadow,
    );
  }

  void _paintCord(Canvas canvas, Size size, double bodyTop, double bodyBottom) {
    final w = size.width;
    final cx = w / 2;
    final bodyCenterY = (bodyTop + bodyBottom) / 2;

    // Vertical cord running the full body, slightly off-centre band
    const cordWidth = 6.0;
    final cordRect = Rect.fromLTWH(
      cx - cordWidth / 2,
      bodyTop,
      cordWidth,
      bodyBottom - bodyTop,
    );
    final cordPaint = Paint()..color = _cord;
    canvas.drawRRect(
      RRect.fromRectAndRadius(cordRect, const Radius.circular(2)),
      cordPaint,
    );

    // Dark shadow stripe down the cord's left edge
    final shadow = Paint()..color = _cordShadow.withAlpha(180);
    canvas.drawRect(
      Rect.fromLTWH(cx - cordWidth / 2, bodyTop, 1.4, bodyBottom - bodyTop),
      shadow,
    );

    // Knot — small oval with bow wings around the body-centre
    final knot = Paint()..color = _cord;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, bodyCenterY),
        width: 14,
        height: 8,
      ),
      knot,
    );

    // Two small bow wings either side
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 8, bodyCenterY - 3),
        width: 10,
        height: 6,
      ),
      knot,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 8, bodyCenterY - 3),
        width: 10,
        height: 6,
      ),
      knot,
    );

    // Knot highlight
    final knotShine = Paint()..color = Colors.white.withAlpha(50);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, bodyCenterY - 1),
        width: 6,
        height: 2.5,
      ),
      knotShine,
    );
  }

  void _paintWaxSeal(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final r = w * 0.22;

    // Shadow cast on parchment
    final shadow = Paint()
      ..color = Colors.black.withAlpha(90)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center.translate(1.5, 2.5), r, shadow);

    // Main wax blob — irregular edges via stacked circles
    final wax = Paint()..color = _waxSeal;
    canvas.drawCircle(center, r, wax);
    canvas.drawCircle(center.translate(-r * 0.3, -r * 0.2), r * 0.55, wax);
    canvas.drawCircle(center.translate(r * 0.35, r * 0.15), r * 0.55, wax);
    canvas.drawCircle(center.translate(r * 0.1, -r * 0.35), r * 0.5, wax);
    canvas.drawCircle(center.translate(-r * 0.2, r * 0.3), r * 0.5, wax);

    // Highlight — top-left glint
    final highlight = Paint()..color = _waxSealHighlight.withAlpha(140);
    canvas.drawCircle(
      center.translate(-r * 0.25, -r * 0.25),
      r * 0.35,
      highlight,
    );

    // Dark inner shadow — bottom-right
    final innerShadow = Paint()..color = _waxSealShadow.withAlpha(170);
    canvas.drawCircle(
      center.translate(r * 0.25, r * 0.25),
      r * 0.45,
      innerShadow,
    );

    // Embossed tiny dot at centre (signet feel)
    final dot = Paint()..color = _waxSealShadow;
    canvas.drawCircle(center, r * 0.18, dot);
  }

  @override
  bool shouldRepaint(covariant _ScrollGraphicPainter old) =>
      old.unlocked != unlocked;
}
