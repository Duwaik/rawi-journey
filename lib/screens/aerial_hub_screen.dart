import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../data/m1_data.dart';
import '../data/scene_configs.dart';
import '../models/journey_event.dart';
import '../services/audio_service.dart';
import '../services/prefs_service.dart';
import '../widgets/cinematic/crescent_moon.dart';
import '../widgets/cinematic/fly_transition.dart';
import '../widgets/cinematic/grain_overlay.dart';
import '../widgets/cinematic/parallax_scene.dart';
import '../widgets/cinematic/sky_gradient.dart';
import '../widgets/cinematic/starfield_layer.dart';
import 'cinematic_transition_screen.dart';
import 'immersive_event_screen.dart';
import 'journey_event_screen.dart';
import 'settings_screen.dart';

// ── Aerial Hub — parallax layered scene with hotspots ───────────────────────

class AerialHubScreen extends StatefulWidget {
  const AerialHubScreen({super.key});

  @override
  State<AerialHubScreen> createState() => _AerialHubScreenState();
}

class _AerialHubScreenState extends State<AerialHubScreen> {
  late List<JourneyEvent> _events;
  late int _currentOrder;

  @override
  void initState() {
    super.initState();
    _events = List.of(m1Events)
      ..sort((a, b) => a.globalOrder.compareTo(b.globalOrder));
    _currentOrder = PrefsService.currentOrder;

    AudioService.playAmbient(
      'assets/audio/ambient_desert_evening.wav',
      volume: 0.12,
    );
  }

  @override
  void dispose() {
    AudioService.fadeOut();
    super.dispose();
  }

  void _refresh() {
    setState(() => _currentOrder = PrefsService.currentOrder);
  }

  JourneyEvent get _activeEvent =>
      _events.firstWhere(
        (e) => e.globalOrder == _currentOrder,
        orElse: () => _events.last,
      );

  int get _completedCount =>
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

    // Play cinematic transition, then push event screen
    await Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        transitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) =>
            CinematicTransitionScreen(
          event: event,
          onComplete: () {
            // Replace transition with the actual event screen
            final config = sceneConfigs[event.id];
            if (config != null && config.groundLayers.isNotEmpty) {
              Navigator.pushReplacement(
                context,
                flyDownRoute(ImmersiveEventScreen(event: event)),
              );
            } else {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 400),
                  reverseTransitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (c, a1, a2) =>
                      JourneyEventScreen(event: event),
                  transitionsBuilder: (c, a, a2, child) {
                    final curved = CurvedAnimation(
                        parent: a, curve: Curves.easeOutCubic);
                    return FadeTransition(opacity: curved, child: child);
                  },
                ),
              );
            }
          },
        ),
      ),
    );

    _refresh();
    if (PrefsService.musicEnabled) {
      AudioService.playAmbient(
        'assets/audio/ambient_desert_evening.wav',
        volume: 0.12,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = _activeEvent;
    final eraCol = _eraColor(active.era);
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final screenH = MediaQuery.of(context).size.height;

    final config = sceneConfigs[active.id];
    final hubLayers = config?.hubLayers ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Sky gradient (fallback / base) ─────────────────────────
          if (config != null)
            SkyGradient(config: config),

          // ── Parallax scene ─────────────────────────────────────────
          if (hubLayers.isNotEmpty)
            ParallaxScene(
              height: screenH,
              layers: hubLayers,
            ),

          // ── Atmospheric overlays ───────────────────────────────────
          if (config?.showStars ?? false) const StarfieldLayer(),
          if (config?.showMoon ?? false)
            CrescentMoon(position: config!.moonPosition),
          if (config?.showGrain ?? false) const GrainOverlay(opacity: 0.025),

          // ── Dark vignette at bottom ────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: screenH * 0.55,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withAlpha(240),
                      Colors.black.withAlpha(180),
                      Colors.black.withAlpha(60),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.25, 0.55, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── Top bar ────────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(200),
                    Colors.black.withAlpha(100),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RAWI',
                          style: GoogleFonts.cinzelDecorative(
                            color: AppColors.gold, fontSize: 20,
                            fontWeight: FontWeight.w700, letterSpacing: 3)),
                      Text('The Seerah',
                          style: GoogleFonts.lora(
                            color: AppColors.textBody, fontSize: 11,
                            fontStyle: FontStyle.italic)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: eraCol.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: eraCol.withAlpha(80)),
                    ),
                    child: Text(
                      '${active.era.emoji}  ${active.era.label(PrefsService.language)}',
                      style: GoogleFonts.nunito(
                        color: eraCol, fontSize: 11,
                        fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                        Text('${PrefsService.xp} XP',
                            style: GoogleFonts.nunito(
                              color: AppColors.gold, fontSize: 11,
                              fontWeight: FontWeight.w700)),
                      ],
                    ),
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
                          transitionDuration:
                              const Duration(milliseconds: 350),
                          reverseTransitionDuration:
                              const Duration(milliseconds: 250),
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
                          volume: 0.12,
                        );
                      }
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(12),
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
          ),

          // ── Bottom panel ───────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad + 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Active event card
                  GestureDetector(
                    onTap: () => _openEvent(active),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.card.withAlpha(200),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: eraCol.withAlpha(50)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withAlpha(15),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: eraCol.withAlpha(25),
                              shape: BoxShape.circle,
                              border: Border.all(color: eraCol.withAlpha(60)),
                            ),
                            child: Center(
                              child: Text(active.era.emoji,
                                  style: const TextStyle(fontSize: 20)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  PrefsService.isEventCompleted(active.globalOrder)
                                      ? (PrefsService.isAr ? 'مكتمل' : 'Completed')
                                      : (PrefsService.isAr ? 'الحدث التالي' : 'Next Event'),
                                  textDirection: PrefsService.isAr ? TextDirection.rtl : TextDirection.ltr,
                                  style: GoogleFonts.nunito(
                                    color: eraCol, fontSize: 10,
                                    fontWeight: FontWeight.w700, letterSpacing: 0.8),
                                ),
                                Text(
                                  PrefsService.isAr
                                      ? active.titleAr : active.title,
                                  textDirection: PrefsService.isAr ? TextDirection.rtl : TextDirection.ltr,
                                  style: GoogleFonts.nunito(
                                    color: AppColors.textPrimary, fontSize: 14,
                                    fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  '${PrefsService.isAr ? active.locationAr : active.location}  ·  ${active.year} CE',
                                  textDirection: PrefsService.isAr ? TextDirection.rtl : TextDirection.ltr,
                                  style: GoogleFonts.nunito(
                                    color: AppColors.textMuted, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withAlpha(18),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.gold.withAlpha(50)),
                            ),
                            child: Text('+${active.xpReward} XP',
                                style: GoogleFonts.nunito(
                                  color: AppColors.gold, fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildProgressBar(eraCol),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(Color eraCol) {
    final total = _events.length;
    final done = _completedCount;
    final pct = total > 0 ? (done / total * 100).round() : 0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$done / $total events',
                style: GoogleFonts.nunito(color: AppColors.textBody, fontSize: 11)),
            Text('$pct%',
                style: GoogleFonts.nunito(
                  color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: total > 0 ? done / total : 0,
            minHeight: 5,
            backgroundColor: AppColors.divider,
            valueColor: const AlwaysStoppedAnimation(AppColors.gold),
          ),
        ),
      ],
    );
  }
}
