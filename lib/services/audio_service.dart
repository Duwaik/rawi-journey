import 'dart:async';

import 'package:just_audio/just_audio.dart';

import 'debug_log_service.dart';
import 'prefs_service.dart';

/// Manages ambient background audio and one-shot SFX for cinematic scenes.
/// Respects user preferences: musicEnabled, sfxEnabled, voEnabled.
class AudioService {
  static AudioPlayer? _ambient;
  static AudioPlayer? _sfx;
  static AudioPlayer? _vo;
  static StreamSubscription? _voSub;
  /// Asset path of the currently playing ambient (for continuous-ambient logic).
  static String? _currentAmbientPath;

  /// R25-S1 followup: asset paths that have already failed to load once.
  /// Subsequent calls for the same path return silently without re-logging.
  /// Cleared only on full app restart — that's fine: pending-content assets
  /// stay missing for a whole session, and flipping real failures back to
  /// success requires a rebuild anyway.
  static final Set<String> _knownMissing = <String>{};

  static bool _isKnownMissing(String assetPath) =>
      _knownMissing.contains(assetPath);

  static void _markMissing(String assetPath, String category, Object err) {
    // Log exactly once per asset path.
    if (_knownMissing.add(assetPath)) {
      DebugLogService.log(category,
          'asset missing/unloadable $assetPath — $err (further attempts silenced)');
    }
  }

  /// Start playing an ambient audio asset at the given volume.
  /// Used for: onboarding music (looping) and hotspot atmospheric beds.
  ///
  /// If another ambient is already playing AND [assetPath] is the same,
  /// this returns early — the ambient continues uninterrupted. This is
  /// what enables the continuous "home" ambient pattern (Sprint 49 R7-01).
  /// If a different ambient is playing, it fades out briefly before
  /// the new one starts (LOCKED RULE: no hard cuts).
  static Future<bool> playAmbient(String assetPath, {
    double volume = 0.3,
    bool loop = true,
    Duration fadeInDuration = Duration.zero,
  }) async {
    if (!PrefsService.musicEnabled) return false;
    // R25-S1 followup: skip silently if this path already failed once.
    // Caller (e.g. tent fire ambient) treats false as "try fallback".
    if (_isKnownMissing(assetPath)) return false;
    // R27 S1.5-AUDIO1: if the same ambient is already playing, don't
    // restart it — but DO ramp its volume back to target. Tent's
    // `didPushNext` now fades the ambient down before leaving, so a
    // quick return (tent → events list → back within the fade window)
    // finds the tent fire at volume < target and needs a ramp-up.
    if (_ambient != null && _currentAmbientPath == assetPath) {
      if (fadeInDuration > Duration.zero) {
        await fadeAmbientTo(volume, duration: fadeInDuration);
      } else {
        await _ambient!.setVolume(volume);
      }
      return true;
    }
    // LOCKED RULE: fade previous ambient briefly before new one starts
    await fadeOut(duration: const Duration(milliseconds: 200));
    _currentAmbientPath = assetPath;
    _ambient = AudioPlayer();
    try {
      await _ambient!.setAsset(assetPath);
      await _ambient!.setLoopMode(loop ? LoopMode.one : LoopMode.off);
      // R27 S1.5-AUDIO1: when fadeInDuration > 0, start at volume 0
      // and ramp to target via fadeAmbientTo. Otherwise set volume
      // directly (matches pre-S1.5 behaviour for all existing callers
      // that pass the default Duration.zero).
      if (fadeInDuration > Duration.zero) {
        await _ambient!.setVolume(0.0);
        _ambient!.play();
        DebugLogService.log('audio',
            'ambient play $assetPath vol=0→$volume fade=${fadeInDuration.inMilliseconds}ms');
        await fadeAmbientTo(volume, duration: fadeInDuration);
      } else {
        await _ambient!.setVolume(volume);
        _ambient!.play();
        DebugLogService.log('audio', 'ambient play $assetPath vol=$volume');
      }
      return true;
    } catch (e) {
      _markMissing(assetPath, 'audio', e);
      _ambient?.dispose();
      _ambient = null;
      _currentAmbientPath = null;
      return false;
    }
  }

  /// Smoothly fade ambient volume to [targetVol] over [duration].
  static Future<void> fadeAmbientTo(double targetVol, {
    Duration duration = const Duration(milliseconds: 1500),
  }) async {
    final player = _ambient;
    if (player == null) return;
    final startVol = player.volume;
    const steps = 15;
    final stepDuration = duration ~/ steps;
    for (int i = 1; i <= steps; i++) {
      if (_ambient != player) return;
      final vol = startVol + (targetVol - startVol) * (i / steps);
      await player.setVolume(vol.clamp(0.0, 1.0));
      await Future.delayed(stepDuration);
    }
  }

  /// Play a one-shot sound effect (layered on top of ambient).
  /// Skips playback if SFX is disabled in preferences.
  static Future<void> playSfx(String assetPath, {double volume = 0.5}) async {
    if (!PrefsService.sfxEnabled) return;
    // R25-S1 followup: skip silently for known-missing assets. Previously
    // repeated attempts (e.g. every footstep) spammed the debug log with
    // the same failure. Also avoids nuking the current _sfx player on
    // each call for a missing path.
    if (_isKnownMissing(assetPath)) return;
    await _sfx?.stop();
    await _sfx?.dispose();
    _sfx = AudioPlayer();
    try {
      await _sfx!.setAsset(assetPath);
      await _sfx!.setLoopMode(LoopMode.off);
      await _sfx!.setVolume(volume);
      _sfx!.play();
    } catch (e) {
      _markMissing(assetPath, 'audio', e);
      _sfx?.dispose();
      _sfx = null;
    }
  }

  /// Play a voiceover narration (Layer 2).
  /// Ducks ambient volume while playing, restores when done.
  /// Skips playback if VO is disabled in preferences.
  static Future<void> playVoiceover(String assetPath, {double volume = 0.7}) async {
    // R19-07: VO globally disabled until batch regeneration. Lift this
    // early return when new VO files ship.
    return;
    // ignore: dead_code
    if (!PrefsService.voEnabled) return;
    // AR VO disabled until batch regeneration with Jordanian accent
    // ignore: dead_code
    if (PrefsService.isAr) return;
    // LOCKED RULE: always fade previous VO before starting new (no hard cuts)
    await fadeOutVoiceover(duration: const Duration(milliseconds: 150));
    _vo = AudioPlayer();
    try {
      // Duck ambient
      _ambient?.setVolume(0.06);
      await _vo!.setAsset(assetPath);
      await _vo!.setLoopMode(LoopMode.off);
      await _vo!.setVolume(volume);
      _vo!.play();
      // Store subscription — cancelled in stopVoiceover()
      _voSub = _vo!.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _ambient?.setVolume(0.18);
          _vo?.dispose();
          _vo = null;
          _voSub = null;
        }
      });
    } catch (_) {
      _ambient?.setVolume(0.18);
      _vo?.dispose();
      _vo = null;
    }
  }

  /// Fade out voiceover over [duration] then dispose.
  /// LOCKED RULE: VO never hard-cuts. Always fade.
  /// Default 200ms is fast enough for rapid VO swaps (dismiss → next hotspot)
  /// but smooth enough to feel cinematic.
  static Future<void> fadeOutVoiceover({
    Duration duration = const Duration(milliseconds: 200),
  }) async {
    final player = _vo;
    if (player == null) return;
    final startVol = player.volume;
    const steps = 8;
    final stepDuration = duration ~/ steps;
    for (int i = steps; i >= 0; i--) {
      if (_vo != player) return;
      await player.setVolume(startVol * (i / steps));
      await Future.delayed(stepDuration);
    }
    await _voSub?.cancel();
    _voSub = null;
    await player.stop();
    await player.dispose();
    _vo = null;
    _ambient?.setVolume(0.18);
  }

  /// Stop voiceover immediately (emergency only — dispose, app backgrounded).
  /// For all user-visible transitions, use [fadeOutVoiceover] instead.
  /// LOCKED RULE: prefer fadeOutVoiceover everywhere except lifecycle emergencies.
  static Future<void> stopVoiceover() async {
    await _voSub?.cancel();
    _voSub = null;
    await _vo?.stop();
    await _vo?.dispose();
    _vo = null;
    _ambient?.setVolume(0.18);
  }

  /// Smoothly fade out ambient over [duration] then stop and dispose.
  /// LOCKED RULE: ambient never hard-cuts. Always fade.
  /// Default 400ms feels cinematic without being sluggish.
  static Future<void> fadeOut({
    Duration duration = const Duration(milliseconds: 400),
  }) async {
    final player = _ambient;
    if (player == null) return;
    final path = _currentAmbientPath;

    final startVol = player.volume;
    const steps = 15;
    final stepDuration = duration ~/ steps;

    for (int i = steps; i >= 0; i--) {
      if (_ambient != player) return;
      await player.setVolume(startVol * (i / steps));
      await Future.delayed(stepDuration);
    }
    await player.stop();
    await player.dispose();
    _ambient = null;
    _currentAmbientPath = null;
    DebugLogService.log('audio', 'ambient faded out $path');
  }

  /// Immediately stop ambient audio (emergency only — use fadeOut for UI).
  static Future<void> stopAmbient() async {
    final path = _currentAmbientPath;
    await _ambient?.stop();
    await _ambient?.dispose();
    _ambient = null;
    _currentAmbientPath = null;
    if (path != null) {
      DebugLogService.log('audio', 'ambient STOP $path');
    }
  }

  /// Stop SFX.
  static Future<void> stopSfx() async {
    await _sfx?.stop();
    await _sfx?.dispose();
    _sfx = null;
  }

  /// R25-S1-4: Stop everything — ambient, SFX, VO — awaiting disposal.
  /// Called by any screen that must own the audio channel before starting
  /// its own player (e.g. VideoIntroScreen on event launch). Use this
  /// instead of individual stop* calls so future audio layers are covered
  /// by one call site.
  static Future<void> stopAll() async {
    DebugLogService.log('audio',
        'stopAll requested (ambient=${_currentAmbientPath ?? "—"})');
    // Await each disposal so the caller can rely on a silent channel.
    await stopVoiceover();
    await stopAmbient();
    await stopSfx();
  }
}
