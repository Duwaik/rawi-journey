import 'package:flutter/material.dart';

/// Fly-down transition: zooms in + fades (aerial → ground).
/// Reverse: zooms out + fades (ground → aerial).
Route<T> flyDownRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 800),
    reverseTransitionDuration: const Duration(milliseconds: 600),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      // Scale: 0.3 → 1.0 (fly down = zoom in)
      final scale = Tween<double>(begin: 0.3, end: 1.0).animate(curved);
      // Fade: 0.0 → 1.0
      final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
        ),
      );

      return FadeTransition(
        opacity: opacity,
        child: ScaleTransition(
          scale: scale,
          child: child,
        ),
      );
    },
  );
}
