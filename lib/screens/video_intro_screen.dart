import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../app_colors.dart';
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
  late VideoPlayerController _controller;
  bool _disposed = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        if (_disposed) return;
        setState(() {});
        _controller.play();
      });

    _controller.addListener(_checkEnd);
  }

  void _checkEnd() {
    if (_disposed || _completed) return;
    final pos = _controller.value.position;
    final dur = _controller.value.duration;
    if (dur > Duration.zero && pos >= dur - const Duration(milliseconds: 200)) {
      _onVideoEnd();
    }
  }

  void _onVideoEnd() {
    if (_completed || _disposed) return;
    _completed = true;
    _controller.removeListener(_checkEnd);
    widget.onComplete();
  }

  // Tap-to-skip removed — cinematic videos play to completion

  @override
  void dispose() {
    _disposed = true;
    _controller.removeListener(_checkEnd);
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _controller.value.isInitialized
            ? Stack(
                fit: StackFit.expand,
                children: [
                  // Layer 1: Blurred scaled-up video fills entire screen
                  Transform.scale(
                    scale: 3.0,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: VideoPlayer(_controller),
                    ),
                  ),
                  // Layer 2: Dark overlay to tone down the blur
                  Container(
                    color: Colors.black.withAlpha(100),
                  ),
                  // Layer 3: Actual video centered (contain fit)
                  Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
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
                child: CircularProgressIndicator(
                  color: AppColors.gold,
                ),
              ),
      ),
    );
  }
}
