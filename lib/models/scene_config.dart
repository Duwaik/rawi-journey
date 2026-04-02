import 'dart:ui';
import '../widgets/cinematic/parallax_scene.dart';

// ── Particle types for atmospheric effects ────────────────────────────────────
enum ParticleType { incenseSmoke, dust, sandstorm, none }

// ── Interactive hotspot within a scene ────────────────────────────────────────
class SceneHotspot {
  /// Unique identifier.
  final String id;

  /// Position as fraction of scene width/height (0.0–1.0).
  final double x;
  final double y;

  /// Display label.
  final String label;
  final String labelAr;

  /// Discovery text fragment (2-3 sentences).
  final String fragment;
  final String fragmentAr;

  /// Emoji icon for the hotspot.
  final String icon;

  /// Optional sound effect asset path (plays when hotspot is tapped).
  final String? sfxPath;

  /// Optional bubble image asset path (shown in discovery panel).
  final String? imagePath;

  /// Optional "Go Deeper" scholarly content (collapsible section).
  final String? deeperContent;
  final String? deeperContentAr;

  const SceneHotspot({
    required this.id,
    required this.x,
    required this.y,
    required this.label,
    required this.labelAr,
    required this.fragment,
    required this.fragmentAr,
    this.icon = '✦',
    this.sfxPath,
    this.imagePath,
    this.deeperContent,
    this.deeperContentAr,
  });
}

// ── Scene atmosphere configuration per event ──────────────────────────────────
class SceneConfig {
  // ── Parallax scene layers ───────────────────────────────────────────────────
  final List<ParallaxLayer> hubLayers;
  final List<ParallaxLayer> groundLayers;
  final double sceneHeightFraction;

  // ── Interactive hotspots ────────────────────────────────────────────────────
  final List<SceneHotspot> hotspots;

  // ── Walking path (fractional coordinates) ──────────────────────────────────
  /// Ordered waypoints the companion follows. Joystick moves along this route.
  /// For branching events, this is the path for Option A.
  final List<Offset> pathWaypoints;

  /// Alternate walking path used when user picks Option B at the branch point.
  /// If null, pathWaypoints is used for all flows.
  final List<Offset>? pathWaypointsAlt;

  // ── Atmospheric overlays ────────────────────────────────────────────────────
  final List<Color> skyGradient;
  final List<double>? skyStops;
  final bool showStars;
  final bool showMoon;
  final Offset moonPosition;
  final ParticleType particleType;
  final int particleCount;
  final Color particleColor;
  final String? ambientAudioPath;
  final double ambientVolume;
  final bool showGrain;
  final bool showBirds;
  final int birdCount;

  const SceneConfig({
    this.hubLayers = const [],
    this.groundLayers = const [],
    this.sceneHeightFraction = 1.0,
    this.hotspots = const [],
    this.pathWaypoints = const [],
    this.pathWaypointsAlt,
    required this.skyGradient,
    this.skyStops,
    this.showStars = false,
    this.showMoon = false,
    this.moonPosition = const Offset(0.75, 0.08),
    this.particleType = ParticleType.none,
    this.particleCount = 0,
    this.particleColor = const Color(0x33C9A84C),
    this.ambientAudioPath,
    this.ambientVolume = 0.3,
    this.showGrain = false,
    this.showBirds = false,
    this.birdCount = 40,
  });
}
