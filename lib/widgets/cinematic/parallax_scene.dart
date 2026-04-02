import 'package:flutter/material.dart';

/// A single layer in a parallax scene.
class ParallaxLayer {
  /// Asset path for this layer's image.
  final String assetPath;

  /// Parallax speed multiplier (0.0 = static, 1.0 = full speed).
  final double speed;

  /// Vertical position: 0.0 = top of scene, 1.0 = bottom.
  final double verticalPosition;

  /// Height as fraction of scene height.
  final double heightFraction;

  /// Fade the top edge of this layer (0.0 = no fade, 0.3 = 30% of layer height).
  final double fadeTop;

  /// Fade the bottom edge of this layer.
  final double fadeBottom;

  const ParallaxLayer({
    required this.assetPath,
    this.speed = 0.5,
    this.verticalPosition = 0.0,
    this.heightFraction = 1.0,
    this.fadeTop = 0.0,
    this.fadeBottom = 0.0,
  });
}

/// Parallax scene viewer with layered images.
/// When [externalOffset] is provided, the scene is driven by companion position
/// and manual drag is disabled.
class ParallaxScene extends StatefulWidget {
  final List<ParallaxLayer> layers;
  final double height;
  final Widget? child;

  /// External offset driven by companion position.
  /// When non-null, disables manual drag and auto-pan.
  final double? externalOffset;

  const ParallaxScene({
    super.key,
    required this.layers,
    this.height = 400,
    this.child,
    this.externalOffset,
  });

  @override
  State<ParallaxScene> createState() => _ParallaxSceneState();
}

class _ParallaxSceneState extends State<ParallaxScene>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;
  late final AnimationController _autoPan;

  bool get _externallyDriven => widget.externalOffset != null;

  @override
  void initState() {
    super.initState();
    _autoPan = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
    _autoPan.addListener(() {
      if (mounted && !_externallyDriven) setState(() {});
    });
  }

  @override
  void dispose() {
    _autoPan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return SizedBox(
      height: widget.height,
      child: GestureDetector(
        // Only allow manual drag when not externally driven
        onHorizontalDragUpdate: _externallyDriven
            ? null
            : (d) {
                setState(() {
                  _dragOffset += d.delta.dx;
                  _dragOffset =
                      _dragOffset.clamp(-screenW * 0.6, screenW * 0.6);
                });
              },
        onHorizontalDragEnd: _externallyDriven ? null : (_) => _springBack(),
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ...widget.layers.map((layer) {
                final double baseOffset;
                if (_externallyDriven) {
                  baseOffset = widget.externalOffset! * layer.speed;
                } else {
                  final autoPanOffset =
                      ((_autoPan.value * 2 - 1).abs() * 2 - 1) * 15;
                  baseOffset = (_dragOffset + autoPanOffset) * layer.speed;
                }

                final layerH = widget.height * layer.heightFraction;
                final layerTop = widget.height * layer.verticalPosition;

                Widget image = Transform.translate(
                  offset: Offset(baseOffset, 0),
                  child: Image.asset(
                    layer.assetPath,
                    fit: BoxFit.cover,
                    width: screenW * 1.5,
                    height: layerH,
                    alignment: Alignment.center,
                  ),
                );

                // Apply gradient fade mask if needed
                if (layer.fadeTop > 0 || layer.fadeBottom > 0) {
                  image = ShaderMask(
                    shaderCallback: (bounds) {
                      final stops = <double>[];
                      final colors = <Color>[];

                      if (layer.fadeTop > 0) {
                        stops.add(0.0);
                        colors.add(Colors.transparent);
                        stops.add(layer.fadeTop);
                        colors.add(Colors.white);
                      } else {
                        stops.add(0.0);
                        colors.add(Colors.white);
                      }

                      if (layer.fadeBottom > 0) {
                        stops.add(1.0 - layer.fadeBottom);
                        colors.add(Colors.white);
                        stops.add(1.0);
                        colors.add(Colors.transparent);
                      } else {
                        stops.add(1.0);
                        colors.add(Colors.white);
                      }

                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: colors,
                        stops: stops,
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: image,
                  );
                }

                return Positioned(
                  top: layerTop,
                  left: -(screenW * 0.25),
                  right: -40,
                  height: layerH,
                  child: image,
                );
              }),

              if (widget.child != null) widget.child!,
            ],
          ),
        ),
      ),
    );
  }

  void _springBack() {
    final start = _dragOffset;
    final ticker = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    ticker.addListener(() {
      if (mounted) {
        setState(() {
          _dragOffset =
              start * (1 - Curves.easeOutCubic.transform(ticker.value));
        });
      }
    });
    ticker.addStatusListener((s) {
      if (s == AnimationStatus.completed) ticker.dispose();
    });
    ticker.forward();
  }
}
