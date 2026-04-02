import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_colors.dart';

/// Diamond-shaped (rotated square) hotspot marker in the parallax scene.
/// Four visual states:
///   - active: pulsing diamond + glow (next hotspot to discover)
///   - discovered: dimmed diamond + green tick badge (re-tappable)
///   - locked: visible but dimmed, no pulse, not tappable (future hotspot)
///   - pending: same as discovered but no tick yet (panel open)
class SceneHotspotMarker extends StatefulWidget {
  final String icon;
  final String label;
  final bool discovered;
  final bool active;
  final bool locked;
  final VoidCallback? onTap;

  const SceneHotspotMarker({
    super.key,
    required this.icon,
    required this.label,
    this.discovered = false,
    this.active = false,
    this.locked = false,
    this.onTap,
  });

  @override
  State<SceneHotspotMarker> createState() => _SceneHotspotMarkerState();
}

class _SceneHotspotMarkerState extends State<SceneHotspotMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.active && !widget.discovered) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(SceneHotspotMarker old) {
    super.didUpdateWidget(old);
    if (widget.active && !widget.discovered && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if ((widget.discovered || widget.locked) && _pulse.isAnimating) {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final discovered = widget.discovered;
    final locked = widget.locked;
    final isActive = widget.active && !discovered && !locked;

    return GestureDetector(
      onTap: locked ? null : widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: locked ? 0.6 : 1.0,
        child: SizedBox(
          width: 90,
          height: 90,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Diamond core + pulse ring + badge
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulse ring (diamond, only when active)
                    if (isActive)
                      AnimatedBuilder(
                        animation: _pulse,
                        builder: (_, child) {
                          final v = _pulse.value;
                          final size = 40.0 + v * 20;
                          return Transform.rotate(
                            angle: 0.7854,
                            child: Container(
                              width: size,
                              height: size,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: AppColors.gold
                                      .withAlpha((220 * (1 - v * 0.5)).round()),
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.gold
                                        .withAlpha((80 * (1 - v * 0.3)).round()),
                                    blurRadius: 12 + v * 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                    // Dark backing circle for locked hotspots (contrast)
                    if (locked)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withAlpha(100),
                        ),
                      ),

                    // Core diamond — rotated square with icon
                    Transform.rotate(
                      angle: 0.7854,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: locked
                              ? AppColors.textMuted.withAlpha(30)
                              : discovered
                                  ? AppColors.gold.withAlpha(25)
                                  : AppColors.gold.withAlpha(70),
                          border: Border.all(
                            color: locked
                                ? AppColors.textMuted.withAlpha(80)
                                : discovered
                                    ? AppColors.gold.withAlpha(80)
                                    : AppColors.gold,
                            width: locked ? 1.5 : 2.0,
                          ),
                          boxShadow: locked
                              ? [
                                  BoxShadow(
                                    color: AppColors.textMuted.withAlpha(30),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : discovered
                              ? null
                              : [
                                  BoxShadow(
                                    color: AppColors.gold.withAlpha(100),
                                    blurRadius: 16,
                                    spreadRadius: 4,
                                  ),
                                ],
                        ),
                      ),
                    ),

                    // Icon (not rotated — stays upright inside diamond)
                    Text(widget.icon,
                        style: TextStyle(
                          fontSize: locked ? 14 : 16,
                          color: locked
                              ? Colors.white54
                              : discovered
                                  ? Colors.white70
                                  : Colors.white,
                        )),

                    // Green check badge (top-right, only discovered)
                    if (discovered)
                      Positioned(
                        top: 4,
                        right: 8,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.green,
                            border:
                                Border.all(color: Colors.black54, width: 1.5),
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 11),
                        ),
                      ),

                    // Lock icon (top-right, only locked)
                    if (locked)
                      Positioned(
                        top: 6,
                        right: 10,
                        child: Icon(
                          Icons.lock_rounded,
                          size: 12,
                          color: AppColors.textMuted.withAlpha(100),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 3),

              // Label pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(locked ? 60 : discovered ? 80 : 160),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.label,
                  style: GoogleFonts.nunito(
                    color: locked
                        ? AppColors.textMuted.withAlpha(80)
                        : discovered
                            ? AppColors.textMuted.withAlpha(140)
                            : AppColors.gold,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
