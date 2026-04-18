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
  bool _showUnavailable = false;

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
    _initTimeout = Timer(const Duration(seconds: 10), () {
      if (_disposed || _completed) return;
      if (_controller?.value.isInitialized != true) {
        DebugLogService.log('video',
            'init timeout (10s) for ${widget.videoPath} — skipping');
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

  void _failGracefully({required String reason}) {
    if (_completed || _disposed) return;
    setState(() => _showUnavailable = true);
    // Brief visible notice, then proceed to the scene.
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      _onVideoEnd();
    });
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
        body: isReady
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
            : Center(
                child: _showUnavailable
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          PrefsService.isAr
                              ? 'الفيديو غير متوفّر — المتابعة إلى المشهد'
                              : 'Video unavailable — continuing to the scene',
                          textAlign: TextAlign.center,
                          textDirection: PrefsService.isAr
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          style: GoogleFonts.nunito(
                            color: AppColors.gold.withAlpha(200),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : const CircularProgressIndicator(
                        color: AppColors.gold,
                      ),
              ),
      ),
    );
  }
}
