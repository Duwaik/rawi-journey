import 'package:flutter/material.dart';

import '../data/m1_data.dart';
import '../data/scene_configs.dart';
import '../data/threshold_challenges.dart';
import '../models/journey_event.dart';
import '../models/threshold_challenge.dart';
import '../services/audio_service.dart';
import '../services/debug_log_service.dart';
import '../services/prefs_service.dart';
import '../widgets/cinematic/fly_transition.dart';
import 'event_intro_screen.dart';
import 'immersive_event_screen.dart';
import 'threshold_screen.dart';
import 'video_intro_screen.dart';
import 'witness_moment_screen.dart';

/// R25-S1-1 / S1-2: Single source of truth for "launch the next progression
/// item" used by both the Tent Start button and the Events List Start
/// buttons. Previously events-list had all the logic, tent only knew how
/// to auto-open-via-events-list (which caused a visible flash + audio bleed).
///
/// Progression items, in priority order:
///   1. ThresholdChallenge — if the next event has one pending
///   2. JourneyEvent — otherwise
///
/// Callers should use [currentProgressionItem] for the tent progress card
/// and [launchCurrentItem] for the Start button.
sealed class ProgressionItem {
  const ProgressionItem();
}

class ThresholdItem extends ProgressionItem {
  final ThresholdChallenge challenge;
  final JourneyEvent gatedEvent;
  const ThresholdItem({required this.challenge, required this.gatedEvent});
}

class EventItem extends ProgressionItem {
  final JourneyEvent event;
  const EventItem(this.event);
}

/// Returns the current progression item based on completion state.
/// Returns null only when the entire journey is complete.
ProgressionItem? currentProgressionItem() {
  int completed = 0;
  for (final e in m1Events) {
    if (PrefsService.isEventCompleted(e.globalOrder)) completed++;
  }
  if (completed >= m1Events.length) return null;
  final next = m1Events[completed];
  final threshold = getThresholdBefore(next.globalOrder);
  if (threshold != null &&
      !PrefsService.isThresholdCompleted(next.globalOrder)) {
    return ThresholdItem(challenge: threshold, gatedEvent: next);
  }
  return EventItem(next);
}

/// Launches the current progression item directly — no events-list
/// interstitial. Safe to call from the tent Start button or from an
/// events-list row Start button.
Future<void> launchCurrentItem(BuildContext context) async {
  final item = currentProgressionItem();
  if (item == null) {
    DebugLogService.log('nav', 'launchCurrentItem: journey complete, no-op');
    return;
  }
  if (item is ThresholdItem) {
    await launchThreshold(context, item);
  } else if (item is EventItem) {
    await launchEvent(context, item.event);
  }
}

/// Launches the Threshold question screen. On correct answer, marks the
/// threshold completed and pops back so the tent's progress card refreshes.
Future<void> launchThreshold(
    BuildContext context, ThresholdItem item) async {
  DebugLogService.log('nav',
      'launchThreshold before event ${item.gatedEvent.globalOrder}');
  await Navigator.push(
    context,
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, a, s) => FadeTransition(
        opacity: a,
        child: ThresholdScreen(
          challenge: item.challenge,
          onUnlocked: () {
            PrefsService.setThresholdCompleted(
                item.gatedEvent.globalOrder);
            Navigator.pop(ctx);
          },
        ),
      ),
    ),
  );
}

/// Launches an event — handles video intro, noor depletion, witness moment,
/// and the immersive scene push. Mirrors the original event_list_screen._openEvent.
Future<void> launchEvent(BuildContext context, JourneyEvent event) async {
  DebugLogService.log('nav', 'launchEvent ${event.id} (#${event.globalOrder})');

  // Explorer Mode: deplete noor on event transition (-25%).
  // Skip for completed events (replays) and Event 1 (first-time grace).
  if (PrefsService.isExplorerMode &&
      !PrefsService.isEventCompleted(event.globalOrder) &&
      event.globalOrder > 1) {
    await PrefsService.depleteNoor(25);
  }

  final config = sceneConfigs[event.id];
  final hasScene = config != null;
  if (!hasScene) {
    // No scene yet — fallback to a minimal intro so the Start button
    // doesn't silently no-op. Caller is responsible for future scene data.
    DebugLogService.log(
        'nav', 'launchEvent: no scene config for ${event.id}, skipping');
    return;
  }

  final videoPath = _getVideoIntro(event.id);
  final canSkip = _videoIsReplay(event.id, event.globalOrder);

  if (videoPath != null) {
    // AWAIT the fade so ambient is fully down before video init.
    await AudioService.fadeOut(
        duration: const Duration(milliseconds: 500));
    if (!context.mounted) return;
    await Navigator.push(
      context,
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (ctx, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: VideoIntroScreen(
            videoPath: videoPath,
            canSkip: canSkip,
            onComplete: () {
              if (!ctx.mounted) return;
              Navigator.pushReplacement(
                ctx,
                flyDownRoute(ImmersiveEventScreen(event: event)),
              );
            },
          ),
        ),
      ),
    );
    return;
  }

  // Regular cinematic transition (no video).
  await Navigator.push(
    context,
    PageRouteBuilder(
      opaque: false,
      transitionDuration: Duration.zero,
      pageBuilder: (ctx, animation, secondaryAnimation) => EventIntroScreen(
        event: event,
        onComplete: () {
          if (!ctx.mounted) return;
          if (event.witnessIntro != null) {
            Navigator.pushReplacement(
              ctx,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 500),
                pageBuilder: (ctx2, a, s) => FadeTransition(
                  opacity: a,
                  child: WitnessMomentScreen(
                    intro: event.witnessIntro!,
                    onComplete: () {
                      if (!ctx2.mounted) return;
                      Navigator.pushReplacement(
                        ctx2,
                        flyDownRoute(ImmersiveEventScreen(event: event)),
                      );
                    },
                  ),
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
              ctx,
              flyDownRoute(ImmersiveEventScreen(event: event)),
            );
          }
        },
      ),
    ),
  );
}

// ── Local helpers (mirror event_list_screen, kept private here) ────────────

String? _getVideoIntro(String eventId) {
  const videoIntros = {
    'j_1_1_2': 'assets/video/event2_intro.mp4',
    // Add more: 'j_1_1_X': 'assets/video/eventX_intro.mp4',
  };
  return videoIntros[eventId];
}

bool _videoIsReplay(String eventId, int globalOrder) {
  return PrefsService.isEventCompleted(globalOrder) ||
      PrefsService.loadHotspotProgress(eventId).isNotEmpty;
}
