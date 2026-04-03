import 'package:flutter/material.dart';
import '../app_colors.dart';

/// Wraps a scrollable child and shows a gold "▼" arrow at the bottom
/// when content overflows. Arrow fades out when user scrolls to the end.
class ScrollHintWrapper extends StatefulWidget {
  final Widget child;
  final ScrollController controller;

  const ScrollHintWrapper({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  State<ScrollHintWrapper> createState() => _ScrollHintWrapperState();
}

class _ScrollHintWrapperState extends State<ScrollHintWrapper> {
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
    // Check after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkOverflow());
  }

  @override
  void didUpdateWidget(ScrollHintWrapper old) {
    super.didUpdateWidget(old);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkOverflow());
  }

  void _checkOverflow() {
    if (!mounted || !widget.controller.hasClients) return;
    final max = widget.controller.position.maxScrollExtent;
    setState(() => _showHint = max > 10); // has scrollable content
  }

  void _onScroll() {
    if (!mounted || !widget.controller.hasClients) return;
    final pos = widget.controller.position;
    final atEnd = pos.pixels >= pos.maxScrollExtent - 20;
    if (_showHint && atEnd) {
      setState(() => _showHint = false);
    } else if (!_showHint && pos.pixels < pos.maxScrollExtent - 40) {
      setState(() => _showHint = true);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Gold scroll-down arrow
        if (_showHint)
          Positioned(
            bottom: 4,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: AnimatedOpacity(
                  opacity: _showHint ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.bg.withAlpha(200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: AppColors.gold.withAlpha(180),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
