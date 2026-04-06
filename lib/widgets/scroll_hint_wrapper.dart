import 'package:flutter/material.dart';
import '../app_colors.dart';

/// Wraps a scrollable child and shows a gold bouncing "▼" arrow at the bottom
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

class _ScrollHintWrapperState extends State<ScrollHintWrapper>
    with SingleTickerProviderStateMixin {
  bool _showHint = false;
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );
    widget.controller.addListener(_onScroll);
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
    setState(() => _showHint = max > 10);
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
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showHint)
          Positioned(
            bottom: 6,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                final viewport = widget.controller.position.viewportDimension;
                final target = widget.controller.offset + (viewport * 0.8);
                widget.controller.animateTo(
                  target.clamp(0, widget.controller.position.maxScrollExtent),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                );
              },
              child: Center(
                child: AnimatedBuilder(
                  animation: _bounceAnim,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(0, _bounceAnim.value),
                    child: child,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.bg.withAlpha(230),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.gold.withAlpha(120),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withAlpha(60),
                          blurRadius: 14,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.keyboard_double_arrow_down_rounded,
                      size: 36,
                      color: AppColors.gold,
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
