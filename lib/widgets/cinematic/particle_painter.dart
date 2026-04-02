import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/scene_config.dart';

/// Floating particles: incense smoke, dust motes, etc.
/// Uses a single CustomPainter for performance.
class ParticleField extends StatefulWidget {
  final ParticleType type;
  final int count;
  final Color color;

  const ParticleField({
    super.key,
    required this.type,
    required this.count,
    required this.color,
  });

  @override
  State<ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<ParticleField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _particles;
  final Random _rng = Random(9999);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    _particles = List.generate(widget.count, (_) => _spawnParticle(initial: true));
  }

  _Particle _spawnParticle({bool initial = false}) {
    final isSmoke = widget.type == ParticleType.incenseSmoke;
    return _Particle(
      x: _rng.nextDouble(),
      y: initial ? _rng.nextDouble() : 1.0 + _rng.nextDouble() * 0.1,
      vx: (_rng.nextDouble() - 0.5) * (isSmoke ? 0.015 : 0.03),
      vy: -(0.02 + _rng.nextDouble() * (isSmoke ? 0.03 : 0.05)),
      size: isSmoke ? (2.0 + _rng.nextDouble() * 4.0) : (1.0 + _rng.nextDouble() * 2.5),
      life: _rng.nextDouble(),
      maxLife: 0.6 + _rng.nextDouble() * 0.4,
      wobblePhase: _rng.nextDouble() * 2 * pi,
      wobbleSpeed: 0.5 + _rng.nextDouble() * 1.5,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              _tick();
              return CustomPaint(
                painter: _ParticlePainter(
                  particles: _particles,
                  baseColor: widget.color,
                  isSmoke: widget.type == ParticleType.incenseSmoke,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _tick() {
    final dt = 0.016; // ~60fps but visually fine at any rate
    for (int i = 0; i < _particles.length; i++) {
      final p = _particles[i];
      final wobble = sin(p.wobblePhase + _ctrl.value * p.wobbleSpeed * 2 * pi * 4) * 0.003;
      final newX = p.x + (p.vx + wobble) * dt * 2;
      final newY = p.y + p.vy * dt * 2;
      final newLife = p.life + dt * 0.08 / p.maxLife;

      if (newLife > 1.0 || newY < -0.05) {
        _particles[i] = _spawnParticle();
      } else {
        _particles[i] = p.copyWith(x: newX, y: newY, life: newLife);
      }
    }
  }
}

class _Particle {
  final double x, y, vx, vy, size, life, maxLife, wobblePhase, wobbleSpeed;

  const _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.life,
    required this.maxLife,
    required this.wobblePhase,
    required this.wobbleSpeed,
  });

  _Particle copyWith({double? x, double? y, double? life}) => _Particle(
    x: x ?? this.x,
    y: y ?? this.y,
    vx: vx,
    vy: vy,
    size: size,
    life: life ?? this.life,
    maxLife: maxLife,
    wobblePhase: wobblePhase,
    wobbleSpeed: wobbleSpeed,
  );
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color baseColor;
  final bool isSmoke;

  _ParticlePainter({
    required this.particles,
    required this.baseColor,
    required this.isSmoke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      // Fade in then out over lifecycle
      final fadeIn = (p.life * 4).clamp(0.0, 1.0);
      final fadeOut = ((1.0 - p.life) * 3).clamp(0.0, 1.0);
      final alpha = fadeIn * fadeOut;
      if (alpha <= 0) continue;

      final paint = Paint()
        ..color = baseColor.withAlpha((alpha * (baseColor.a * 255.0)).round().clamp(0, 255));

      if (isSmoke) {
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 1.5);
      }

      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size * (isSmoke ? (1.0 + p.life * 0.8) : 1.0), // smoke grows
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true; // always repainting
}
