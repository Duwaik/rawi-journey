import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../app_colors.dart';
import '../services/audio_service.dart';
import '../services/debug_log_service.dart';
import '../services/prefs_service.dart';

/// Full-screen cinematic video intro for special events.
/// Plays once, then calls onComplete to transition to the game.
///
/// R19-14: On a replay (2nd+ entry), a "Skip >" button appears in the
/// top-right after 1s so the user can skip straight to the scene.
class VideoIntroScreen extends StatefulWidget {
  final String videoPath;
  final VoidCallback onComplete;
  final bool canSkip;

  const VideoIntroScreen({
    super.key,
    required this.videoPath,
    required this.onComplete,
    this.canSkip = false,
  });

  @override
  State<VideoIntroScreen> createState() => _VideoIntroScreenState();
}

class _VideoIntroScreenState extends State<VideoIntroScreen> {
  // Nullable because controller is created inside the async _bootController
  // after AudioService.stopAll() completes — dispose may fire before that.
  VideoPlayerController? _controller;
  bool _disposed = false;
  bool _completed = false;
  // B26: timeout fallback — video must not freeze the journey.
  Timer? _initTimeout;
  Timer? _stallWatchdog;
  Duration _lastPos = Duration.zero;
  DateTime _lastPosTime = DateTime.now();
  // R25-S1-7: fallback UI shown when init/stall watchdog fires. User
  // picks Replay (re-init from scratch) or Skip (treat as completed).
  bool _showFallback = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _bootController();
  }

  /// R25-S1-4: AudioService.stopAll() first so the video owns the audio
  /// channel before VideoPlayerController.initialize() contends for it.
  /// Previously the ambient from the previous screen could still be alive
  /// when init started, which left Event 2 stuck on the first scene.
  Future<void> _bootController() async {
    await AudioService.stopAll();
    if (_disposed) return;

    DebugLogService.log('video', 'init start ${widget.videoPath}');
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        if (_disposed) return;
        _initTimeout?.cancel();
        DebugLogService.log('video',
            'isInitialized=true  dur=${_controller!.value.duration} ${widget.videoPath}');
        setState(() {});
        _controller!.play();
        _startStallWatchdog();
      }).catchError((e, st) {
        developer.log('video init failed', error: e, stackTrace: st);
        DebugLogService.log(
            'video', 'init failed for ${widget.videoPath}: $e');
        _failGracefully(reason: 'init_error');
      });

    _controller!.addListener(_checkEnd);

    // B26: if init doesn't complete in 10s, skip gracefully.
    // R25-S1-7: 8-second init cap (replaces B26's 10s). On timeout, show
    // the Replay/Skip fallback instead of the old "Video unavailable"
    // dead-end message — users need an actionable choice, not a notice.
    _initTimeout = Timer(const Duration(seconds: 8), () {
      if (_disposed || _completed) return;
      if (_controller?.value.isInitialized != true) {
        DebugLogService.log('video',
            'init timeout (8s) for ${widget.videoPath} — showing fallback');
        _failGracefully(reason: 'init_timeout');
      }
    });
  }

  void _startStallWatchdog() {
    // B26: if position doesn't advance for 6s while playing, treat as stall.
    _stallWatchdog?.cancel();
    _stallWatchdog = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_disposed || _completed) return;
      final ctrl = _controller;
      if (ctrl == null) return;
      final pos = ctrl.value.position;
      if (pos == _lastPos && ctrl.value.isPlaying) {
        final stallSecs = DateTime.now().difference(_lastPosTime).inSeconds;
        if (stallSecs >= 6) {
          DebugLogService.log('video',
              'stall watchdog fired at pos=$pos (${widget.videoPath}) — skipping');
          _failGracefully(reason: 'stall');
        }
      } else {
        _lastPos = pos;
        _lastPosTime = DateTime.now();
      }
    });
  }

  /// R25-S1-7: Show Replay/Skip fallback. User chooses the outcome —
  /// the screen no longer auto-advances after 900ms.
  void _failGracefully({required String reason}) {
    if (_completed || _disposed) return;
    // Cancel any in-flight timers so they don't fire on top of the UI.
    _stallWatchdog?.cancel();
    _initTimeout?.cancel();
    setState(() => _showFallback = true);
    DebugLogService.log('video', 'fallback shown reason=$reason');
  }

  /// R25-S1-7 Replay: tear down the controller and re-boot it fresh.
  Future<void> _replay() async {
    DebugLogService.log('video',
        'user tapped Replay from fallback (${widget.videoPath})');
    final old = _controller;
    _controller = null;
    _lastPos = Duration.zero;
    _lastPosTime = DateTime.now();
    setState(() => _showFallback = false);
    await old?.dispose();
    if (_disposed) return;
    await _bootController();
  }

  /// R25-S1-7 Skip: treat as completed — scene advances without replay.
  void _skipFromFallback() {
    DebugLogService.log('video',
        'user tapped Skip from fallback (${widget.videoPath})');
    _onVideoEnd();
  }

  void _checkEnd() {
    if (_disposed || _completed) return;
    final ctrl = _controller;
    if (ctrl == null) return;
    final pos = ctrl.value.position;
    final dur = ctrl.value.duration;
    if (dur > Duration.zero && pos >= dur - const Duration(milliseconds: 200)) {
      _onVideoEnd();
    }
  }

  void _onVideoEnd() {
    if (_completed || _disposed) return;
    _completed = true;
    _initTimeout?.cancel();
    _stallWatchdog?.cancel();
    _controller?.removeListener(_checkEnd);
    widget.onComplete();
  }

  // Tap-to-skip removed — cinematic videos play to completion

  @override
  void dispose() {
    _disposed = true;
    _initTimeout?.cancel();
    _stallWatchdog?.cancel();
    _controller?.removeListener(_checkEnd);
    _controller?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _controller;
    final isReady = ctrl != null && ctrl.value.isInitialized;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _showFallback
            ? _buildFallbackUi()
            : isReady
            ? Stack(
                fit: StackFit.expand,
                children: [
                  // Layer 1: Blurred scaled-up video fills entire screen
                  Transform.scale(
                    scale: 3.0,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: VideoPlayer(ctrl),
                    ),
                  ),
                  // Layer 2: Dark overlay to tone down the blur
                  Container(
                    color: Colors.black.withAlpha(100),
                  ),
                  // Layer 3: Actual video centered (contain fit)
                  Center(
                    child: AspectRatio(
                      aspectRatio: ctrl.value.aspectRatio,
                      child: VideoPlayer(ctrl),
                    ),
                  ),
                  // R19-14: Skip button on replay (top-right, safe-area aware).
                  if (widget.canSkip)
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 12,
                      right: 16,
                      child: GestureDetector(
                        onTap: _onVideoEnd,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(140),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.gold.withAlpha(120)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                PrefsService.isAr ? 'تخطّى' : 'Skip',
                                style: GoogleFonts.nunito(
                                  color: AppColors.gold,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                ),
                                textDirection: PrefsService.isAr
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                PrefsService.isAr
                                    ? Icons.chevron_left_rounded
                                    : Icons.chevron_right_rounded,
                                size: 16,
                                color: AppColors.gold,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
      ),
    );
  }

  /// R25-S1-7: Fallback UI shown when the 8s init watchdog or 6s stall
  /// watchdog fires. Two buttons: Try Again (re-init from scratch) and
  /// Skip (proceed as if the video had completed).
  Widget _buildFallbackUi() {
    final isAr = PrefsService.isAr;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 40, color: AppColors.gold.withAlpha(180)),
            const SizedBox(height: 16),
            Text(
              isAr
                  ? 'حدث خطأ في تحميل هذا المشهد'
                  : 'Something went wrong loading this scene',
              textAlign: TextAlign.center,
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              style: GoogleFonts.nunito(
                color: AppColors.gold,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 28),
            // Try Again — primary
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _replay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: const Color(0xFF04060D),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  isAr ? 'إعادة المحاولة' : 'Try Again',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Skip — secondary
            SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: _skipFromFallback,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.gold.withAlpha(140)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isAr ? 'تخطّي' : 'Skip',
                  style: GoogleFonts.nunito(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
