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

/// Event list screen — the "map" / hub showing all events with progress.
/// Replaces the old parallax hub. Shows event cards with hotspot progress,
/// highlights the next unlocked event, and locks future events.
class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  late List<JourneyEvent> _events;
  late int _currentOrder;

  @override
  void initState() {
    super.initState();
    _events = List.of(m1Events)
      ..sort((a, b) => a.globalOrder.compareTo(b.globalOrder));
    _currentOrder = PrefsService.currentOrder;

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
      // Force full rebuild — picks up language, gender, and completion changes
    });
  }

  bool _isAr() => PrefsService.isAr;

  int _completedCount() =>
      _events.where((e) => PrefsService.isEventCompleted(e.globalOrder)).length;

  Color _eraColor(JourneyEra era) {
    switch (era) {
      case JourneyEra.jahiliyyah: return AppColors.eraJahiliyyah;
      case JourneyEra.earlyLife:  return AppColors.eraEarlyLife;
      case JourneyEra.mecca:      return AppColors.eraMecca;
      case JourneyEra.medina:     return AppColors.eraMediana;
      case JourneyEra.rashidun:   return AppColors.eraRashidun;
      case JourneyEra.umayyad:    return AppColors.eraUmayyad;
      case JourneyEra.abbasid:    return AppColors.eraAbbasid;
      case JourneyEra.ottoman:    return AppColors.eraOttoman;
    }
  }

  Future<void> _openEvent(JourneyEvent event) async {
    await AudioService.fadeOut(duration: const Duration(milliseconds: 400));
    if (!mounted) return;

    final config = sceneConfigs[event.id];
    final hasScene = config != null && config.groundLayers.isNotEmpty;

    if (hasScene) {
      // Immersive events: cinematic transition → immersive screen
      await Navigator.push(
        context,
        PageRouteBuilder(
          opaque: false,
          transitionDuration: Duration.zero,
          pageBuilder: (context, animation, secondaryAnimation) =>
              CinematicTransitionScreen(
            event: event,
            onComplete: () {
              Navigator.pushReplacement(
                context,
                flyDownRoute(ImmersiveEventScreen(event: event)),
              );
            },
          ),
        ),
      );
    } else {
      // Flat events: direct fade transition (no cinematic)
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

  @override
  Widget build(BuildContext context) {
    final isAr = _isAr();
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final done = _completedCount();
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
          // ── Header ──────────────────────────────────────────────────
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
                      isAr ? 'السيرة النبوية' : 'The Seerah',
                      style: GoogleFonts.lora(
                        color: AppColors.textBody, fontSize: 11,
                        fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
                const Spacer(),
                // Progress badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withAlpha(18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.gold.withAlpha(60)),
                  ),
                  child: Text(
                    '$done/$total',
                    style: GoogleFonts.nunito(
                      color: AppColors.gold, fontSize: 12,
                      fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                // XP badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withAlpha(18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.gold.withAlpha(60)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 13, color: AppColors.gold),
                      const SizedBox(width: 4),
                      Text('${PrefsService.xp}',
                          style: GoogleFonts.nunito(
                            color: AppColors.gold, fontSize: 12,
                            fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Settings gear
                GestureDetector(
                  onTap: () async {
                    await AudioService.fadeOut(
                        duration: const Duration(milliseconds: 300));
                    if (!mounted) return;
                    await Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 350),
                        reverseTransitionDuration: const Duration(milliseconds: 250),
                        pageBuilder: (c, a, s) => const SettingsScreen(),
                        transitionsBuilder: (c, a, s, child) =>
                            FadeTransition(
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
                      border: Border.all(color: AppColors.textMuted.withAlpha(40)),
                    ),
                    child: const Icon(Icons.settings_rounded,
                        size: 16, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),

          // ── Event list ──────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPad + 16),
              itemCount: _events.length,
              itemBuilder: (context, i) {
                final event = _events[i];
                final completed = PrefsService.isEventCompleted(event.globalOrder);
                final isNext = event.globalOrder == _currentOrder;
                final locked = event.globalOrder > _currentOrder;
                final eraCol = _eraColor(event.era);
                final hasScene = sceneConfigs.containsKey(event.id);
                final hotspotCount = sceneConfigs[event.id]?.hotspots.length ?? 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: locked ? null : () => _openEvent(event),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isNext
                            ? eraCol.withAlpha(15)
                            : locked
                                ? AppColors.card.withAlpha(80)
                                : AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isNext
                              ? eraCol.withAlpha(100)
                              : locked
                                  ? AppColors.textMuted.withAlpha(15)
                                  : AppColors.textMuted.withAlpha(25),
                          width: isNext ? 1.5 : 0.8,
                        ),
                        boxShadow: isNext
                            ? [BoxShadow(
                                color: eraCol.withAlpha(20),
                                blurRadius: 12, spreadRadius: 1)]
                            : null,
                      ),
                      child: Opacity(
                        opacity: locked ? 0.4 : 1.0,
                        child: Row(
                          children: [
                            // Event number circle
                            Container(
                              width: 38, height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: completed
                                    ? AppColors.green.withAlpha(25)
                                    : isNext
                                        ? eraCol.withAlpha(30)
                                        : AppColors.textMuted.withAlpha(12),
                                border: Border.all(
                                  color: completed
                                      ? AppColors.green.withAlpha(100)
                                      : isNext
                                          ? eraCol.withAlpha(80)
                                          : AppColors.textMuted.withAlpha(30)),
                              ),
                              child: Center(
                                child: completed
                                    ? const Icon(Icons.check_rounded,
                                        color: AppColors.green, size: 18)
                                    : Text(
                                        '${event.globalOrder}',
                                        style: GoogleFonts.nunito(
                                          color: isNext ? eraCol : AppColors.textMuted,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Title + location
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAr ? event.titleAr : event.title,
                                    textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                                    style: GoogleFonts.nunito(
                                      color: isNext
                                          ? AppColors.textPrimary
                                          : completed
                                              ? AppColors.textBody
                                              : AppColors.textMuted,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${isAr ? event.locationAr : event.location}  ·  ${event.year} CE',
                                    textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                                    style: GoogleFonts.nunito(
                                      color: AppColors.textMuted.withAlpha(140),
                                      fontSize: 10),
                                  ),
                                  // Hotspot counter for events with scenes
                                  if (hasScene && !locked) ...[
                                    const SizedBox(height: 2),
                                    () {
                                      final savedProgress = PrefsService.loadHotspotProgress(event.id);
                                      final discoveredCount = completed ? hotspotCount : savedProgress.length;
                                      return Text(
                                        '◆ $discoveredCount/$hotspotCount',
                                        style: GoogleFonts.nunito(
                                          color: completed
                                              ? AppColors.green
                                              : discoveredCount > 0
                                                  ? AppColors.gold
                                                  : AppColors.textMuted.withAlpha(100),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700),
                                      );
                                    }(),
                                  ],
                                ],
                              ),
                            ),

                            // Status badge
                            if (completed && hasScene)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.green.withAlpha(18),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.check_circle_rounded,
                                    color: AppColors.green, size: 20),
                              )
                            else if (completed)
                              const Icon(Icons.check_circle_rounded,
                                  color: AppColors.green, size: 18)
                            else if (isNext)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.gold,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.gold.withAlpha(50),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  isAr ? 'ابدأ' : 'Play',
                                  style: GoogleFonts.nunito(
                                    color: AppColors.bg, fontSize: 11,
                                    fontWeight: FontWeight.w800),
                                ),
                              )
                            else if (locked)
                              Icon(Icons.lock_rounded,
                                  size: 16, color: AppColors.textMuted.withAlpha(60)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
    );
  }
}
