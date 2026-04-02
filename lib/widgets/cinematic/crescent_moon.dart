import 'package:flutter/material.dart';

/// Crescent moon with gold radial gradient and soft glow.
class CrescentMoon extends StatelessWidget {
  /// Position as fraction of screen size (0-1, 0-1).
  final Offset position;
  const CrescentMoon({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const moonSize = 42.0;
    const shadowOffset = 10.0;

    return Positioned(
      top: size.height * position.dy,
      left: size.width * position.dx,
      child: IgnorePointer(
        child: SizedBox(
          width: moonSize + 20, // extra space for glow
          height: moonSize + 20,
          child: Stack(
            children: [
              // Outer glow
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE8C870).withAlpha(50),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                      BoxShadow(
                        color: const Color(0xFFE8C870).withAlpha(20),
                        blurRadius: 80,
                        spreadRadius: 16,
                      ),
                    ],
                  ),
                ),
              ),
              // Moon body (gold circle)
              Center(
                child: Container(
                  width: moonSize,
                  height: moonSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: Alignment(-0.25, -0.25),
                      colors: [
                        Color(0xFFFDF6D0), // bright centre
                        Color(0xFFE8C870), // edge
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x59E8C864),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
              // Dark overlay to create crescent shape
              Positioned(
                top: (62 - moonSize) / 2 - shadowOffset * 0.3,
                left: (62 - moonSize) / 2 + shadowOffset,
                child: Container(
                  width: moonSize * 0.85,
                  height: moonSize * 0.85,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF080D1C), // match sky
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
