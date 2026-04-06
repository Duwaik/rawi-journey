import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../app_colors.dart';

/// Full-screen cinematic video intro for special events.
/// Plays once, then calls onComplete to transition to the game.
/// Tap to skip after 3 seconds.
class VideoIntroScreen extends StatefulWidget {
  final String videoPath;
  final VoidCallback onComplete;

  const VideoIntroScreen({
    super.key,
    required this.videoPath,
    required this.onComplete,
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

  void _onTap() {
    if (_controller.value.position.inSeconds >= 3) {
      _onVideoEnd();
    }
  }

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _onTap,
        behavior: HitTestBehavior.opaque,
        child: _controller.value.isInitialized
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
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
