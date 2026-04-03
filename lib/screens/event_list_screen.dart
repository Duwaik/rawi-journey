import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../data/m1_data.dart';
import '../data/scene_configs.dart';
import '../models/journey_event.dart';
import '../services/audio_service.dart';
import '../services/prefs_service.dart';
import 'cinematic_transition_screen.dart';
import 'immersive_event_screen.dart';
import 'journey_event_screen.dart';
import 'settings_screen.dart';
import '../widgets/cinematic/fly_transition.dart';

// ── Chapter metadata ────────────────────────────────────────────────────────

const _chapters = <JourneyEra, _Chapter>{
  JourneyEra.jahiliyyah: _Chapter('JAHILIYYAH', 'الجاهلية', 'Pre-Islamic Arabia', 'الجزيرة قبل الإسلام'),
  JourneyEra.earlyLife:  _Chapter('EARLY LIFE', 'النشأة', '570 – 610 CE', '570 – 610 م'),
  JourneyEra.mecca:      _Chapter('MECCA', 'مكة المكرمة', '610 – 622 CE', '610 – 622 م'),
  JourneyEra.medina:     _Chapter('MEDINA', 'المدينة المنورة', '622 – 632 CE', '622 – 632 م'),
};

// Module subtitle (reads from data, not hardcoded — future-proof for M2+)
const _moduleSubtitle = 'The Seerah';
const _moduleSubtitleAr = 'السيرة النبوية';

class _Chapter {
  final String name, nameAr, subtitle, subtitleAr;
  const _Chapter(this.name, this.nameAr, this.subtitle, this.subtitleAr);
}

// ── Screen ──────────────────────────────────────────────────────────────────

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  late List<JourneyEvent> _events;
  late int _currentOrder;
  final Set<JourneyEra> _expandedEras = {};

  JourneyEra? _activeEra() {
    final activeEvent = _events.firstWhere(
      (e) => e.globalOrder == _currentOrder,
      orElse: () => _events.first,
    );
    return activeEvent.era;
  }

  @override
  void initState() {
    super.initState();
    _events = List.of(m1Events)
      ..sort((a, b) => a.globalOrder.compareTo(b.globalOrder));
    _currentOrder = PrefsService.currentOrder;
    // Expand active era by default
    final active = _activeEra();
    if (active != null) _expandedEras.add(active);

    if (PrefsService.musicEnabled) {
      AudioService.playAmbient(
        'assets/audio/ambient_desert_evening.wav',
        volume: 0.10,
      );
    }
  }

  @override
  void dispose() {
    AudioService.fadeOut();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _currentOrder = PrefsService.currentOrder;
      // Auto-collapse all, then expand only the active era
      _expandedEras.clear();
      final active = _activeEra();
      if (active != null) _expandedEras.add(active);
    });
  }

  bool get _isAr => PrefsService.isAr;

  int get _completedCount =>
      _events.where((e) => PrefsService.isEventCompleted(e.globalOrder)).length;

  Future<void> _openEvent(JourneyEvent event) async {
    await AudioService.fadeOut(duration: const Duration(milliseconds: 400));
    if (!mounted) return;

    final config = sceneConfigs[event.id];
    final hasScene = config != null && config.groundLayers.isNotEmpty;

    if (hasScene) {
      await Navigator.push(
        context,
        PageRouteBuilder(
          opaque: false,
          transitionDuration: Duration.zero,
          pageBuilder: (context, animation, secondaryAnimation) =>
              CinematicTransitionScreen(
            event: event,
            onComplete: () async {
              final result = await Navigator.push(
                context,
                flyDownRoute(ImmersiveEventScreen(event: event)),
              );
              if (context.mounted) {
                Navigator.pop(context, result);
              }
            },
          ),
        ),
      );
    } else {
      await Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (c, a1, a2) => JourneyEventScreen(event: event),
          transitionsBuilder: (c, a, a2, child) {
            final curved =
                CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
            return FadeTransition(opacity: curved, child: child);
          },
        ),
      );
    }

    _refresh();
    if (PrefsService.musicEnabled) {
      AudioService.playAmbient(
        'assets/audio/ambient_desert_evening.wav',
        volume: 0.10,
      );
    }
  }

  // ── Build list items (events + chapter headers) ─────────────────────────

  List<Widget> _buildListItems() {
    final isAr = _isAr;
    final items = <Widget>[];
    JourneyEra? lastEra;

    for (int i = 0; i < _events.length; i++) {
      final event = _events[i];
      final isLast = i == _events.length - 1;

      // Insert chapter header when era changes
      if (event.era != lastEra) {
        final chapter = _chapters[event.era];
        if (chapter != null) {
          items.add(_buildChapterHeader(chapter, event.era, isAr));
        }
        lastEra = event.era;
      }

      // Only show events if era is expanded
      if (_expandedEras.contains(event.era)) {
        items.add(_buildEventRow(event, isLast, isAr));
      }
    }

    return items;
  }

  Widget _buildChapterHeader(_Chapter chapter, JourneyEra era, bool isAr) {
    final name = isAr ? chapter.nameAr : chapter.name;
    final sub = isAr ? chapter.subtitleAr : chapter.subtitle;
    final expanded = _expandedEras.contains(era);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (expanded) {
            _expandedEras.remove(era);
          } else {
            _expandedEras.add(era);
          }
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 8, left: 4, right: 4),
        child: Row(
          children: [
            Container(width: 24, height: 1, color: AppColors.gold.withAlpha(120)),
            const SizedBox(width: 8),
            Text(
              name,
              style: GoogleFonts.nunito(
                color: AppColors.gold,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              sub,
              style: GoogleFonts.nunito(
                color: AppColors.textMuted.withAlpha(120),
                fontSize: 10,
              ),
            ),
            const Spacer(),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.gold.withAlpha(expanded ? 180 : 80),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventRow(JourneyEvent event, bool isLast, bool isAr) {
    final completed = PrefsService.isEventCompleted(event.globalOrder);
    final isNext = event.globalOrder == _currentOrder;
    final locked = event.globalOrder > _currentOrder;
    final hasScene = sceneConfigs.containsKey(event.id);
    final hotspotCount = sceneConfigs[event.id]?.hotspots.length ?? 0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Timeline column (32px) ────────────────────────────────
          SizedBox(
            width: 32,
            child: Column(
              children: [
                const SizedBox(height: 14),
                // Node dot
                Container(
                  width: completed ? 12 : isNext ? 14 : 10,
                  height: completed ? 12 : isNext ? 14 : 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: completed
                        ? AppColors.gold
                        : isNext
                            ? AppColors.bg
                            : const Color(0xFF1E3040),
                    border: Border.all(
                      color: completed || isNext
                          ? AppColors.gold
                          : const Color(0xFF2A4050),
                      width: completed ? 2 : isNext ? 2 : 1.5,
                    ),
                    boxShadow: isNext
                        ? [BoxShadow(
                            color: AppColors.gold.withAlpha(40),
                            blurRadius: 8, spreadRadius: 1)]
                        : null,
                  ),
                ),
                // Vertical line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: (completed || isNext)
                          ? AppColors.gold.withAlpha(120)
                          : const Color(0xFF1E3040),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ── Event card ────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: locked ? null : () => _openEvent(event),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: completed
                        ? const Color(0xFF141E14).withAlpha(60)
                        : isNext
                            ? AppColors.gold.withAlpha(8)
                            : AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: completed
                          ? AppColors.gold.withAlpha(64)
                          : isNext
                              ? AppColors.gold.withAlpha(100)
                              : const Color(0xFF1E3040),
                      width: isNext ? 1 : 0.5,
                    ),
                  ),
                  child: Opacity(
                    opacity: locked ? 0.5 : 1.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        // Number or check
                        if (completed)
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.gold.withAlpha(20),
                            ),
                            child: const Icon(Icons.check_rounded,
                                color: AppColors.gold, size: 16),
                          )
                        else
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF1A2030),
                              border: Border.all(
                                color: isNext
                                    ? AppColors.gold.withAlpha(100)
                                    : const Color(0xFF2A4050),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${event.globalOrder}',
                                style: GoogleFonts.nunito(
                                  color: isNext
                                      ? AppColors.gold
                                      : const Color(0xFF3A5A5A),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(width: 10),

                        // Title + subtitle + progress dots
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAr ? event.titleAr : event.title,
                                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                                style: GoogleFonts.nunito(
                                  color: locked
                                      ? const Color(0xFF5A7A7A)
                                      : const Color(0xFFE8D8B8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${isAr ? event.locationAr : event.location}  ·  ${event.year} CE',
                                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                                style: GoogleFonts.nunito(
                                  color: locked
                                      ? const Color(0xFF3A5A5A)
                                      : const Color(0xFF6A8A7A),
                                  fontSize: 11,
                                ),
                              ),
                              // Hotspot progress dots
                              if (!locked && hasScene && hotspotCount > 0) ...[
                                const SizedBox(height: 4),
                                _buildProgressDots(event, completed, hotspotCount),
                              ],
                            ],
                          ),
                        ),

                        // Right side: status
                        if (completed)
                          Text(
                            '$hotspotCount/$hotspotCount',
                            style: GoogleFonts.nunito(
                              color: AppColors.gold.withAlpha(180),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        else if (isNext)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isAr ? 'ابدأ' : 'Play',
                              style: GoogleFonts.nunito(
                                color: AppColors.bg,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else if (locked)
                          Icon(Icons.lock_rounded,
                              size: 16, color: const Color(0xFF3A5A5A)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDots(JourneyEvent event, bool completed, int count) {
    final savedProgress = PrefsService.loadHotspotProgress(event.id);
    final discoveredCount = completed ? count : savedProgress.length;

    return Row(
      children: List.generate(count, (i) {
        final filled = i < discoveredCount;
        return Container(
          margin: const EdgeInsets.only(right: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? AppColors.gold : Colors.transparent,
            border: Border.all(
              color: filled ? AppColors.gold : const Color(0xFF3A5A5A),
              width: 1,
            ),
          ),
        );
      }),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isAr = _isAr;
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final done = _completedCount;
    final total = _events.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Text(
              isAr ? 'مغادرة اللعبة؟' : 'Exit game?',
              style: GoogleFonts.nunito(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold),
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            ),
            content: Text(
              isAr
                  ? 'هل أنت متأكد أنك تريد الخروج؟'
                  : 'Are you sure you want to exit?',
              style: GoogleFonts.nunito(color: AppColors.textBody),
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  isAr ? 'البقاء' : 'Stay',
                  style: GoogleFonts.nunito(color: AppColors.gold),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  isAr ? 'خروج' : 'Exit',
                  style: GoogleFonts.nunito(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
        if (confirmed == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Column(
          children: [
            // ── Header ────────────────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(20, topPad + 12, 16, 16),
              decoration: BoxDecoration(
                color: AppColors.bg,
                border: Border(
                  bottom: BorderSide(color: AppColors.textMuted.withAlpha(20)),
                ),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RAWI',
                          style: GoogleFonts.cinzelDecorative(
                            color: AppColors.gold, fontSize: 22,
                            fontWeight: FontWeight.w700, letterSpacing: 3)),
                      Text(
                        isAr ? _moduleSubtitleAr : _moduleSubtitle,
                        style: GoogleFonts.lora(
                          color: AppColors.textBody, fontSize: 11,
                          fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _HeaderBadge(label: '$done/$total'),
                  const SizedBox(width: 8),
                  _HeaderBadge(
                    label: '${PrefsService.xp}',
                    icon: Icons.star_rounded,
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      await AudioService.fadeOut(
                          duration: const Duration(milliseconds: 300));
                      if (!mounted) return;
                      await Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 350),
                          reverseTransitionDuration:
                              const Duration(milliseconds: 250),
                          pageBuilder: (c, a, s) => const SettingsScreen(),
                          transitionsBuilder: (c, a, s, child) => FadeTransition(
                              opacity: CurvedAnimation(
                                  parent: a, curve: Curves.easeOut),
                              child: child),
                        ),
                      );
                      _refresh();
                      if (PrefsService.musicEnabled) {
                        AudioService.playAmbient(
                          'assets/audio/ambient_desert_evening.wav',
                          volume: 0.10,
                        );
                      }
                    },
                    child: Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(8),
                        border: Border.all(
                            color: AppColors.textMuted.withAlpha(40)),
                      ),
                      child: const Icon(Icons.settings_rounded,
                          size: 16, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),

            // ── Timeline list ─────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(12, 4, 16, bottomPad + 16),
                children: _buildListItems(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header badge ────────────────────────────────────────────────────────────

class _HeaderBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  const _HeaderBadge({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.gold.withAlpha(18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: AppColors.gold),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: GoogleFonts.nunito(
                color: AppColors.gold, fontSize: 12,
                fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
