import 'package:just_audio/just_audio.dart';

import 'prefs_service.dart';

/// Manages ambient background audio and one-shot SFX for cinematic scenes.
/// Respects user preferences: musicEnabled, sfxEnabled, voEnabled.
class AudioService {
  static AudioPlayer? _ambient;
  static AudioPlayer? _sfx;
  static AudioPlayer? _vo;

  /// Start playing an ambient audio asset at the given volume.
  /// Used for: onboarding music (looping) and hotspot atmospheric beds.
  static Future<void> playAmbient(String assetPath, {
    double volume = 0.3,
    bool loop = true,
  }) async {
    if (!PrefsService.musicEnabled) return;
    await stopAmbient();
    _ambient = AudioPlayer();
    try {
      await _ambient!.setAsset(assetPath);
      await _ambient!.setLoopMode(loop ? LoopMode.one : LoopMode.off);
      await _ambient!.setVolume(volume);
      _ambient!.play();
    } catch (_) {
      _ambient?.dispose();
      _ambient = null;
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
    await _sfx?.stop();
    await _sfx?.dispose();
    _sfx = AudioPlayer();
    try {
      await _sfx!.setAsset(assetPath);
      await _sfx!.setLoopMode(LoopMode.off);
      await _sfx!.setVolume(volume);
      _sfx!.play();
    } catch (_) {
      _sfx?.dispose();
      _sfx = null;
    }
  }

  /// Play a voiceover narration (Layer 2).
  /// Ducks ambient volume while playing, restores when done.
  /// Skips playback if VO is disabled in preferences.
  static Future<void> playVoiceover(String assetPath, {double volume = 0.7}) async {
    if (!PrefsService.voEnabled) return;
    await stopVoiceover();
    _vo = AudioPlayer();
    try {
      // Duck ambient
      _ambient?.setVolume(0.06);
      await _vo!.setAsset(assetPath);
      await _vo!.setLoopMode(LoopMode.off);
      await _vo!.setVolume(volume);
      _vo!.play();
      // Restore ambient when VO finishes
      _vo!.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _ambient?.setVolume(0.18);
          _vo?.dispose();
          _vo = null;
        }
      });
    } catch (_) {
      _ambient?.setVolume(0.18);
      _vo?.dispose();
      _vo = null;
    }
  }

  /// Fade out voiceover over 500ms.
  static Future<void> fadeOutVoiceover() async {
    final player = _vo;
    if (player == null) return;
    final startVol = player.volume;
    const steps = 10;
    for (int i = steps; i >= 0; i--) {
      if (_vo != player) return;
      await player.setVolume(startVol * (i / steps));
      await Future.delayed(const Duration(milliseconds: 50));
    }
    await player.stop();
    await player.dispose();
    _vo = null;
    _ambient?.setVolume(0.18);
  }

  /// Stop voiceover immediately.
  static Future<void> stopVoiceover() async {
    await _vo?.stop();
    await _vo?.dispose();
    _vo = null;
    _ambient?.setVolume(0.18);
  }

  /// Smoothly fade out ambient over [duration] then stop.
  static Future<void> fadeOut({
    Duration duration = const Duration(milliseconds: 1500),
  }) async {
    final player = _ambient;
    if (player == null) return;

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
  }

  /// Immediately stop ambient audio.
  static Future<void> stopAmbient() async {
    await _ambient?.stop();
    await _ambient?.dispose();
    _ambient = null;
  }

  /// Stop SFX.
  static Future<void> stopSfx() async {
    await _sfx?.stop();
    await _sfx?.dispose();
    _sfx = null;
  }
}
