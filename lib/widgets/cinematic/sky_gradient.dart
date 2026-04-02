import 'package:flutter/material.dart';
import '../../models/scene_config.dart';

/// Full-screen vertical gradient sky background.
class SkyGradient extends StatelessWidget {
  final SceneConfig config;
  const SkyGradient({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: config.skyGradient,
            stops: config.skyStops,
          ),
        ),
      ),
    );
  }
}
