import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../character_art.dart';
import '../data/scene_configs.dart';
import '../models/journey_event.dart';
import '../models/scene_config.dart';
import '../services/audio_service.dart';
import '../services/prefs_service.dart';
import '../data/rawi_dialogue.dart';
import '../models/branch_point.dart';
import '../widgets/cinematic/crossroads_card.dart';
import '../widgets/cinematic/rawi_figure.dart';
import '../models/badge_definition.dart';
import '../widgets/cinematic/badge_overlay.dart';
import '../widgets/cinematic/go_deeper_section.dart';
import '../widgets/scroll_hint_wrapper.dart';
import '../widgets/cinematic/xp_reward_animation.dart';
import '../widgets/cinematic/rawi_speech_bubble.dart';
import '../widgets/cinematic/crescent_moon.dart';
import '../widgets/cinematic/hotspot_card.dart';
import '../widgets/cinematic/hotspot_progress.dart';
import '../widgets/cinematic/grain_overlay.dart';
import '../widgets/cinematic/parallax_scene.dart';
import '../widgets/cinematic/particle_painter.dart';
import '../widgets/cinematic/reader_hotspot_card.dart';
import '../widgets/cinematic/scene_hotspot_marker.dart';
import '../widgets/cinematic/birds_overlay.dart';
import '../widgets/cinematic/starfield_layer.dart';
import '../widgets/cinematic/virtual_joystick.dart';
import '../widgets/cinematic/fog_overlay.dart';
import '../widgets/settings_overlay.dart';
import '../widgets/tutorial_overlay.dart';
import 'event_list_screen.dart';
import 'unified_completion_screen.dart';

enum _Phase { explore, verdict, complete }

class ImmersiveEventScreen extends StatefulWidget {
  final JourneyEvent event;
  const ImmersiveEventScreen({super.key, required this.event});

  @override
  State<ImmersiveEventScreen> createState() => _ImmersiveEventScreenState();
}

class _ImmersiveEventScreenState extends State<ImmersiveEventScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool _isAr = false;
  bool _alreadyCompleted = false;
  bool _showSettings = false;
  bool _showTutorial = false;
  // _showChoiceTutorial removed — Crossroads is self-explanatory
  bool _isCompleting = false;
  bool _showContinueButton = false;
  bool _showXpAnimation = false;
  bool _showBadgeOverlay = false;
  int _previousXp = 0;
  List<BadgeDefinition> _newBadges = [];
  BadgeDefinition? _currentBadge;

  /// Explorer/Reader mode flag — drives fog, movement, and hotspot visibility.
  /// Read once at init so mid-event switches don't break anything.
  /// Used by Sprint 2 (free-roam) and Sprint 3 (fog/noor). Intentionally
  /// declared ahead of those sprints so the flag is wired and testable.
  // ignore: unused_field
  late final bool _explorerMode;
  final ScrollController _verdictScrollCtrl = ScrollController();
  // _reflectionScrollCtrl removed — unified verdict uses _verdictScrollCtrl

  late final SceneConfig _scene;

  /// True if this event uses the branching system (anchor → choice → convergence).
  /// False = linear hotspot flow (Events 4+). This is the safety net.
  bool get _isBranching => widget.event.isBranching;
  late final List<int?> _answers;
  late final AnimationController _revealCtrl;
  late final Animation<double> _revealAnim;

  // Explore state
  final Set<String> _discovered = {};       // panel dismissed — green tick shown
  final Set<String> _pendingDiscovery = {}; // found but panel not dismissed yet
  SceneHotspot? _activeHotspot;
  _Phase _phase = _Phase.explore;

  // Path-following state
  double _pathProgress = 0.0; // 0.0 = start, 1.0 = end of path
  double _companionX = 0.50;
  double _companionY = 0.75;
  double _facingDir = 0.0;
  bool _isWalking = false;

  // Footprint trail
  final List<Offset> _footprints = [];
  double _footprintAccum = 0.0;

  // Joystick input
  double _joyDx = 0.0;
  double _joyDy = 0.0;

  // Auto-walk state (tap-to-walk)
  bool _autoWalking = false;

  // Parallax offset
  double _parallaxOffset = 0.0;

  // Anti-frustration timer (Explorer Mode) — time since last hotspot
  // discovery. Drives progressive hints at 60s/90s/120s.
  DateTime _lastDiscoveryTime = DateTime.now();
  int get _secondsSinceDiscovery =>
      DateTime.now().difference(_lastDiscoveryTime).inSeconds;

  // Phase transitions
  late final AnimationController _phaseCtrl;

  // Game loop
  late final AnimationController _gameLoop;

  // Path precomputed segment lengths
  late final List<double> _segLengths;
  late double _totalPathLen;

  static const double _hotspotRadius = 0.09;
  static const double _moveSpeed = 0.35;

  // Speech bubble state
  String _bubbleText = '';
  bool _bubbleVisible = false;

  // Branching state (only used when _isBranching == true)
  bool _showBranchCard = false;
  BranchOption? _branchChoice;
  List<String> _branchUnlockOrder = []; // hotspot IDs in visit order
  Timer? _idleTimer;
  int _idleTriggerCount = 0;
  int _postDiscoveryCount = 0;
  final Map<String, int> _revisitCount = {};

  // Fog of War — golden tint on full reveal
  bool _fogSceneRevealed = false;
  double _goldenTintOpacity = 0.0;

  // Hidden Scene Elements (secrets) — discovered during walking
  final Set<String> _discoveredSecrets = {};
  final Map<String, AnimationController> _secretAnims = {};

  // ── Feature: Rawi figure bounce ──────────────────────────────────────────
  late final AnimationController _figureBounceCtrl;
  double _figureScale = 1.0;
  double _figureBounceTarget = 0.05; // peak scale offset (0.05 = normal, 0.1 = celebration)

  // ── Feature: Hotspot proximity opacity ───────────────────────────────────
  final Map<String, double> _hotspotProximityOpacity = {};

  // R20 Part B + C: per-hotspot effective (x,y) overrides computed once
  // in initState based on the journey mode. Explorer Mode = seeded random
  // per event id (quadrant-spread); Reader Mode = fixed horizontal row.
  // All downstream code (proximity, fog, marker render) reads through
  // _posFor() instead of raw h.x/h.y.
  final Map<String, Offset> _effectivePositions = {};

  Offset _posFor(SceneHotspot h) =>
      _effectivePositions[h.id] ?? Offset(h.x, h.y);


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isAr = PrefsService.language == 'ar';
    _explorerMode = PrefsService.isExplorerMode;
    _alreadyCompleted =
        PrefsService.isEventCompleted(widget.event.globalOrder);
    _scene = sceneConfigs[widget.event.id]!;
    _answers = List.filled(widget.event.questions.length, null);

    // R20 Part B + C: compute effective hotspot positions once for this
    // event. Completed-event replays keep the stored scene-config positions
    // so the re-read layout is stable; live runs get the mode-specific
    // layout.
    _computeEffectivePositions();

    _revealCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _revealAnim = CurvedAnimation(parent: _revealCtrl, curve: Curves.easeOut);

    _phaseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    // Precompute path segment lengths
    _precomputePath();

    // Set initial companion position.
    // R20 Part C v3: Reader Mode keeps the Rawi stationary at scene
    // center between the four quadrant cards. Explorer Mode and legacy
    // path still spawn at path start.
    if (!_explorerMode) {
      // R21A-02: Rawi stays at exact scene center in Reader Mode.
      // These values are set ONCE and never updated — no game loop,
      // no auto-walk, no bubble-driven shifts.
      _companionX = 0.50;
      _companionY = 0.50;
    } else if (_activeWaypoints.isNotEmpty) {
      _companionX = _activeWaypoints.first.dx;
      _companionY = _activeWaypoints.first.dy;
    }

    // Game loop — only runs while joystick is active
    _gameLoop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100),
    );
    _gameLoop.addListener(_onFrame);

    // Figure bounce controller (Feature 6: Rawi Reactions)
    _figureBounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
      // Bounce curve: 1.0 → peak → 1.0
      final t = _figureBounceCtrl.value;
      final bounce = sin(t * pi); // 0→1→0 over the animation
      setState(() {
        _figureScale = 1.0 + _figureBounceTarget * bounce;
      });
    })..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _figureScale = 1.0);
        _figureBounceCtrl.reset();
      }
    });

    if (_alreadyCompleted) {
      // R20-03 (revises R19-14): replay = "read-only walkthrough", not
      // "explore again". All 4 hotspots start discovered with checkmarks;
      // the user can tap any to re-read. No fog, no sequential lock. The
      // verdict stays accessible at the end of the scene. XP/badges/noor
      // are already guarded elsewhere against re-awarding.
      _phase = _Phase.explore;
      _discovered.addAll(_scene.hotspots.map((h) => h.id));
    } else {
      // Restore any saved hotspot progress (from previous back press)
      final saved = PrefsService.loadHotspotProgress(widget.event.id);
      if (saved.isNotEmpty) {
        _discovered.addAll(saved);
        // Advance path progress to match discovered count
        _pathProgress = (_discovered.length / _scene.hotspots.length).clamp(0.0, 0.95);
        _updateCompanionFromPath();
      }
      // Show tutorial on first event if not seen
      if (!PrefsService.isTutorialSeen && widget.event.globalOrder == 1) {
        _showTutorial = true;
      } else {
        _resetIdleTimer();
      }
    }
  }

  void _precomputePath() {
    final wp = _activeWaypoints;
    _segLengths = [];
    _totalPathLen = 0;
    for (int i = 0; i < wp.length - 1; i++) {
      final dx = wp[i + 1].dx - wp[i].dx;
      final dy = wp[i + 1].dy - wp[i].dy;
      final len = sqrt(dx * dx + dy * dy);
      _segLengths.add(len);
      _totalPathLen += len;
    }
    if (_segLengths.isEmpty) {
      _segLengths.add(1.0);
      _totalPathLen = 1.0;
    }
  }

  // ── R20 Part B + C: effective hotspot positions per mode ─────────────

  /// Populate _effectivePositions based on current mode.
  ///
  /// Explorer Mode → seeded random quadrant-spread positions.
  /// Reader Mode   → fixed horizontal row (tap-to-read layout).
  /// Replay of a completed event → use the stored SceneConfig positions
  /// (so the layout the user saw when they played is still what they see
  /// on re-read).
  void _computeEffectivePositions() {
    _effectivePositions.clear();
    if (_alreadyCompleted) {
      // Replay keeps authored positions — predictable re-read layout.
      for (final h in _scene.hotspots) {
        _effectivePositions[h.id] = Offset(h.x, h.y);
      }
      return;
    }
    if (_explorerMode) {
      final positions = _generateExplorerPositions(
          widget.event.id, _scene.hotspots.length);
      for (int i = 0; i < _scene.hotspots.length; i++) {
        _effectivePositions[_scene.hotspots[i].id] =
            i < positions.length ? positions[i] : Offset(_scene.hotspots[i].x, _scene.hotspots[i].y);
      }
    } else {
      // Reader Mode v3: 2x2 quadrant grid with Rawi stationary in center.
      // Index → quadrant mapping:
      //   LTR: [0=tl, 1=tr, 2=bl, 3=br]
      //   AR : [0=tr, 1=tl, 2=br, 3=bl]   (mirrored so 1st card sits on
      //                                    the side AR readers naturally
      //                                    look first)
      // Card centers:
      //   tl/bl → x = 0.27 ; tr/br → x = 0.73
      //   tl/tr → y = 0.40 ; bl/br → y = 0.65
      const positions = {
        'tl': Offset(0.27, 0.40),
        'tr': Offset(0.73, 0.40),
        'bl': Offset(0.27, 0.65),
        'br': Offset(0.73, 0.65),
      };
      final ltrQuads = ['tl', 'tr', 'bl', 'br'];
      final arQuads = ['tr', 'tl', 'br', 'bl'];
      final quads = _isAr ? arQuads : ltrQuads;
      for (int i = 0; i < _scene.hotspots.length; i++) {
        final q = i < quads.length ? quads[i] : 'tl';
        _effectivePositions[_scene.hotspots[i].id] =
            positions[q] ?? const Offset(0.5, 0.5);
      }
    }
  }

  /// Reader Mode v3 quadrant for a given hotspot index, language-aware.
  ReaderCardQuadrant _readerQuadrant(int index) {
    const ltr = [
      ReaderCardQuadrant.tl,
      ReaderCardQuadrant.tr,
      ReaderCardQuadrant.bl,
      ReaderCardQuadrant.br,
    ];
    const ar = [
      ReaderCardQuadrant.tr,
      ReaderCardQuadrant.tl,
      ReaderCardQuadrant.br,
      ReaderCardQuadrant.bl,
    ];
    final list = _isAr ? ar : ltr;
    return index < list.length ? list[index] : ReaderCardQuadrant.tl;
  }

  /// Reader Mode v3 card state machine.
  ///
  /// Linear events: cards unlock 1 → 2 → 3 → 4. Discovered = done; the
  /// next undiscovered = active; everything after = locked.
  ///
  /// Branching events: anchor → both branch options glow as choice →
  /// pick one → other branch becomes active → convergence active →
  /// done. Direct tap on a BRANCH_CHOICE card IS the branch selection
  /// (no Crossroads overlay in Reader Mode).
  ReaderCardState _readerCardState(SceneHotspot h) {
    if (_alreadyCompleted) return ReaderCardState.done;

    // R21B-03/06: Only items in _discovered (card closed) are "done".
    // Items in _pendingDiscovery (card still open) show as "active"
    // so the NEXT card stays locked until the current card is dismissed.
    if (_discovered.contains(h.id)) return ReaderCardState.done;
    if (_pendingDiscovery.contains(h.id)) return ReaderCardState.active;

    // While any card is being read, no new card unlocks.
    if (_pendingDiscovery.isNotEmpty) return ReaderCardState.locked;

    if (!_isBranching) {
      final firstUndiscoveredIdx = _scene.hotspots.indexWhere(
        (x) => !_discovered.contains(x.id),
      );
      final myIdx = _scene.hotspots.indexOf(h);
      return myIdx == firstUndiscoveredIdx
          ? ReaderCardState.active
          : ReaderCardState.locked;
    }

    // ── Branching ────────────────────────────────────────────────────
    final ev = widget.event;
    final anchorId = ev.anchorHotspotId;
    final convergenceId = ev.convergenceHotspotId;
    final bp = ev.branchPoint;
    if (anchorId == null || convergenceId == null || bp == null) {
      return ReaderCardState.locked;
    }
    final branchIds = {bp.optionA.targetHotspotId, bp.optionB.targetHotspotId};

    if (!_discovered.contains(anchorId)) {
      return h.id == anchorId
          ? ReaderCardState.active
          : ReaderCardState.locked;
    }

    final branchesDone = branchIds.where(_discovered.contains).toSet();

    if (branchesDone.isEmpty) {
      return branchIds.contains(h.id)
          ? ReaderCardState.branchChoice
          : ReaderCardState.locked;
    }

    if (branchesDone.length == 1) {
      if (branchIds.contains(h.id) && !branchesDone.contains(h.id)) {
        return ReaderCardState.active;
      }
      return ReaderCardState.locked;
    }

    return h.id == convergenceId
        ? ReaderCardState.active
        : ReaderCardState.locked;
  }

  /// Seeded random positions for Explorer Mode. Deterministic on event
  /// id — same event always produces the same layout for the same user.
  /// Guarantees quadrant spread and min distance between hotspots.
  List<Offset> _generateExplorerPositions(String eventId, int count) {
    final rng = Random(eventId.hashCode);
    final positions = <Offset>[];

    const quadrants = [
      Rect.fromLTRB(0.10, 0.20, 0.50, 0.50), // top-left
      Rect.fromLTRB(0.50, 0.20, 0.90, 0.50), // top-right
      Rect.fromLTRB(0.10, 0.50, 0.50, 0.80), // bottom-left
      Rect.fromLTRB(0.50, 0.50, 0.90, 0.80), // bottom-right
    ];

    bool tooClose(Offset p) {
      for (final q in positions) {
        final dx = p.dx - q.dx;
        final dy = p.dy - q.dy;
        if (sqrt(dx * dx + dy * dy) < 0.20) return true;
      }
      // Also stay away from the Rawi spawn point so nothing is
      // discoverable the instant the scene loads.
      final sdx = p.dx - 0.50;
      final sdy = p.dy - 0.75;
      if (sqrt(sdx * sdx + sdy * sdy) < 0.15) return true;
      return false;
    }

    for (int i = 0; i < count; i++) {
      final q = quadrants[i % quadrants.length];
      Offset pos = Offset(q.left + q.width / 2, q.top + q.height / 2);
      for (int attempts = 0; attempts < 50; attempts++) {
        final candidate = Offset(
          q.left + rng.nextDouble() * q.width,
          q.top + rng.nextDouble() * q.height,
        );
        if (!tooClose(candidate)) {
          pos = candidate;
          break;
        }
      }
      positions.add(pos);
    }
    return positions;
  }

  /// Convert _pathProgress (0-1) to a position on the path.
  Offset _positionOnPath(double progress) {
    final wp = _activeWaypoints;
    if (wp.isEmpty) return Offset(_companionX, _companionY);
    if (wp.length == 1) return wp.first;

    final targetDist = progress.clamp(0.0, 1.0) * _totalPathLen;
    double accumulated = 0;

    for (int i = 0; i < _segLengths.length; i++) {
      if (accumulated + _segLengths[i] >= targetDist) {
        final segProgress =
            _segLengths[i] > 0 ? (targetDist - accumulated) / _segLengths[i] : 0.0;
        return Offset(
          wp[i].dx + (wp[i + 1].dx - wp[i].dx) * segProgress,
          wp[i].dy + (wp[i + 1].dy - wp[i].dy) * segProgress,
        );
      }
      accumulated += _segLengths[i];
    }
    return wp.last;
  }

  /// Get the direction vector of the current path segment.
  Offset _currentSegmentDir() {
    final wp = _activeWaypoints;
    if (wp.length < 2) return const Offset(1, 0);

    final targetDist = _pathProgress.clamp(0.0, 1.0) * _totalPathLen;
    double accumulated = 0;

    for (int i = 0; i < _segLengths.length; i++) {
      if (accumulated + _segLengths[i] >= targetDist || i == _segLengths.length - 1) {
        final dx = wp[i + 1].dx - wp[i].dx;
        final dy = wp[i + 1].dy - wp[i].dy;
        final len = sqrt(dx * dx + dy * dy);
        return len > 0 ? Offset(dx / len, dy / len) : const Offset(1, 0);
      }
      accumulated += _segLengths[i];
    }
    return const Offset(1, 0);
  }

  void _updateCompanionFromPath() {
    final pos = _positionOnPath(_pathProgress);
    _companionX = pos.dx;
    _companionY = pos.dy;
    _parallaxOffset = -(_companionX - 0.5) * 0.8;
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _autoWalking = false;
    _verdictScrollCtrl.dispose();
    // _reflectionScrollCtrl removed
    WidgetsBinding.instance.removeObserver(this);
    _gameLoop.removeListener(_onFrame);
    _gameLoop.dispose();
    _figureBounceCtrl.dispose();
    _revealCtrl.dispose();
    _phaseCtrl.dispose();
    // Fade all audio for smooth exit (LOCKED RULE: no hard cuts)
    AudioService.stopSfx();
    AudioService.fadeOutVoiceover(duration: const Duration(milliseconds: 200));
    AudioService.fadeOut(duration: const Duration(milliseconds: 250));
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Stop all audio layers
      AudioService.stopAmbient();
      AudioService.stopSfx();
      AudioService.stopVoiceover();
      // Cancel auto-walk BEFORE stopping game loop
      if (_autoWalking) _stopAutoWalk();
      // Stop game loop and joystick state
      _gameLoop.stop();
      _gameLoop.reset();
      _joyDx = 0;
      _joyDy = 0;
      _idleTimer?.cancel();
      if (mounted) setState(() => _isWalking = false);
    } else if (state == AppLifecycleState.resumed) {
      // Restart idle timer
      if (_phase == _Phase.explore) _resetIdleTimer();
    }
  }

  // ── Game loop ──────────────────────────────────────────────────────────────

  bool _footstepPlaying = false;

  void _onFrame() {
    // Absolute freeze during ANY overlay — no movement whatsoever
    if (_activeHotspot != null || _showBranchCard || _showSettings ||
        _showBadgeOverlay || _showChapterComplete || _showXpAnimation ||
        _showTutorial ||
        _phase == _Phase.verdict ||
        _phase == _Phase.complete) {
      return;
    }
    if (_phase != _Phase.explore) return;
    if (_autoWalking) return; // Don't mix manual + auto movement

    final joyMag = sqrt(_joyDx * _joyDx + _joyDy * _joyDy);
    if (joyMag < 0.15) return; // joystick at rest — no update needed

    // Fixed timestep
    const dt = 0.016; // ~60fps

    // ── FREE-ROAM branch (Explorer Mode, ALL events incl. branching) ────
    // R19-01a: Branching events also free-roam now. Branch card still
    // triggers via discovery (anchor hotspot dismissed → card shown),
    // and _branchUnlockOrder controls _nextHotspotId so the sequential
    // hotspot guard (R19-02) keeps the branch flow coherent.
    if (_explorerMode) {
      final joyNormX = _joyDx / joyMag;
      final joyNormY = _joyDy / joyMag;
      final speed = _moveSpeed * joyMag * dt * 0.6; // slightly slower than path

      final oldX = _companionX;
      _companionX = (_companionX + joyNormX * speed).clamp(0.05, 0.95);
      _companionY = (_companionY + joyNormY * speed).clamp(0.15, 0.90);
      _parallaxOffset = -(_companionX - 0.5) * 0.8;

      final moveDx = _companionX - oldX;
      if (moveDx.abs() > 0.001) {
        _facingDir = moveDx > 0 ? 1.0 : -1.0;
      }

      // Footprint trail (distance-based, same as path mode)
      final dist = sqrt(joyNormX * joyNormX + joyNormY * joyNormY) * speed;
      _footprintAccum += dist;
      if (_footprintAccum > 0.025) {
        _footprints.add(Offset(_companionX, _companionY));
        _footprintAccum = 0;
        if (_footprints.length > 80) _footprints.removeAt(0);
      }

      setState(() => _isWalking = true);
      if (!_footstepPlaying) {
        AudioService.playSfx('assets/audio/sfx_footsteps_sand.wav', volume: 0.15);
        _footstepPlaying = true;
      }

      _checkHotspotProximity();
      _updateHotspotProximity(nextHotspotId: _nextHotspotId);
      return;
    }

    // ── PATH-CONSTRAINED branch (Reader Mode + branching events) ────────
    final segDir = _currentSegmentDir();
    final joyNormX = _joyDx / joyMag;
    final joyNormY = _joyDy / joyMag;
    final dot = joyNormX * segDir.dx + joyNormY * segDir.dy;

    final pathSpeed = dot * _moveSpeed * joyMag * dt / _totalPathLen;
    final newProgress = (_pathProgress + pathSpeed).clamp(0.0, 1.0);

    if ((newProgress - _pathProgress).abs() < 0.0001) return;

    final oldX = _companionX;
    _pathProgress = newProgress;
    _updateCompanionFromPath();

    final moveDx = _companionX - oldX;
    if (moveDx.abs() > 0.001) {
      _facingDir = moveDx > 0 ? 1.0 : -1.0;
    }

    // Footprint trail
    _footprintAccum += pathSpeed.abs() * _totalPathLen;
    if (_footprintAccum > 0.025) {
      _footprints.add(Offset(_companionX, _companionY));
      _footprintAccum = 0;
      if (_footprints.length > 80) _footprints.removeAt(0);
    }

    setState(() => _isWalking = true);

    // Footstep sound
    if (!_footstepPlaying) {
      AudioService.playSfx('assets/audio/sfx_footsteps_sand.wav', volume: 0.15);
      _footstepPlaying = true;
    }

    _checkHotspotProximity();
    _updateHotspotProximity(nextHotspotId: _nextHotspotId);
  }

  // ── Speech bubble logic ──────────────────────────────────────────────────

  // ── VO Rules ──────────────────────────────────────────────────────────────
  // 1. STOP previous VO before starting any new VO
  // 2. Hotspot VO: starts 400ms after panel opens, stops on dismiss
  // 3. Branch card VO: starts 600ms after card shows, stops on option select
  // 4. Verdict question VO: starts 600ms after phase change
  // 5. Verdict explanation VO: starts 500ms after answer reveal animation
  // 6. Rawi bubbles: use SFX layer (short clips, don't duck ambient)
  // 7. App pause/settings: stop ALL VO immediately

  void _showBubble(String text, {String? voPath}) {
    // R21A-02/03: Reader Mode has no bubbles. The Rawi figure is
    // frozen at center and never speaks — all narration is in the
    // tapped card itself. Early-return so the bubble doesn't fire
    // or change state (which would shift the figure's Column layout
    // and make it appear to move).
    if (!_explorerMode) return;

    // Failsafe: zero all movement state when showing any bubble
    _joyDx = 0;
    _joyDy = 0;
    if (_gameLoop.isAnimating && !_autoWalking) {
      _gameLoop.stop();
      _gameLoop.reset();
    }
    setState(() {
      _bubbleText = text;
      _bubbleVisible = true;
      _isWalking = false;
    });
    if (voPath != null) {
      // Rawi bubbles are short — use SFX layer, don't duck ambient
      AudioService.playSfx(voPath, volume: 0.5);
    }
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _bubbleVisible = false);
    });
  }

  /// Build companion VO path from line ID.
  String _companionVoPath(String lineId) {
    final lang = _isAr ? 'ar' : 'en';
    final gender = PrefsService.userGender == 'female' ? 'f' : 'm';
    return 'assets/audio/companion/comp_${lineId}_${lang}_$gender.mp3';
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    if (_phase != _Phase.explore) return;
    _idleTimer = Timer(const Duration(seconds: 10), _onIdle);
  }

  void _onIdle() {
    if (!mounted || _phase != _Phase.explore || _activeHotspot != null || _showSettings || _showBranchCard) return;
    // Failsafe: ensure figure is frozen during idle (no stale joystick values)
    _joyDx = 0;
    _joyDy = 0;
    _gameLoop.stop();
    _gameLoop.reset();
    _isWalking = false;
    _idleTriggerCount++;
    final total = _discovered.length + _pendingDiscovery.length;
    final List<DialogueLine> lines;
    if (total == 0) {
      lines = RawiDialogue.idleStart;
    } else if (_isNearUndiscoveredHotspot()) {
      lines = RawiDialogue.idleNearHotspot;
    } else {
      lines = RawiDialogue.idleMidJourney;
    }
    final lineId = RawiDialogue.getId(lines, _idleTriggerCount);
    _showBubble(
      RawiDialogue.get(lines, _idleTriggerCount, isAr: _isAr, name: PrefsService.userName),
      voPath: _companionVoPath(lineId),
    );
    _resetIdleTimer(); // restart for next idle cycle
  }

  bool _isNearUndiscoveredHotspot() {
    for (final h in _scene.hotspots) {
      if (_discovered.contains(h.id) || _pendingDiscovery.contains(h.id)) continue;
      final pos = _posFor(h);
      final dx = _companionX - pos.dx;
      final dy = _companionY - pos.dy;
      if (dx * dx + dy * dy < 0.03) return true;
    }
    return false;
  }

  // ── Branch choice handler ──────────────────────────────────────────────────

  /// Reader Mode v3 card tap dispatcher.
  ///
  /// LOCKED → no-op. DONE / ACTIVE → open the hotspot panel like a
  /// regular tap. BRANCH_CHOICE → record the branch selection (which
  /// implicitly turns the OTHER branch into ACTIVE on the next state
  /// recomputation), then open this card.
  void _onReaderCardTap(SceneHotspot h, ReaderCardState state) {
    if (state == ReaderCardState.locked) return;
    if (state == ReaderCardState.branchChoice) {
      final bp = widget.event.branchPoint;
      if (bp != null) {
        final option = bp.optionA.targetHotspotId == h.id
            ? bp.optionA
            : bp.optionB.targetHotspotId == h.id
                ? bp.optionB
                : null;
        if (option != null) {
          _onBranchSelected(option);
        }
      }
    }
    _onHotspotTap(h);
  }

  void _onBranchSelected(BranchOption selected) {
    AudioService.fadeOutVoiceover(duration: const Duration(milliseconds: 200));
    AudioService.fadeOut(duration: const Duration(milliseconds: 300)); // Fade Crossroads
    final event = widget.event;
    final bp = event.branchPoint!;
    final isA = selected.targetHotspotId == bp.optionA.targetHotspotId;
    final otherHotspotId = isA
        ? bp.optionB.targetHotspotId
        : bp.optionA.targetHotspotId;

    // Build unlock order: anchor (done) → chosen → other → convergence
    _branchUnlockOrder = [
      event.anchorHotspotId!,      // already discovered
      selected.targetHotspotId,     // next
      otherHotspotId,               // after that
      event.convergenceHotspotId!,  // final
    ];

    // Swap path if user chose option B
    if (!isA && _scene.pathWaypointsAlt != null) {
      _swapToAltPath();
    }

    setState(() {
      _showBranchCard = false;
      _branchChoice = selected;
    });
    _resetIdleTimer();
  }

  void _swapToAltPath() {
    final altWaypoints = _scene.pathWaypointsAlt!;
    // Recompute path segments for the alt path
    _segLengths.clear();
    _totalPathLen = 0;
    for (int i = 0; i < altWaypoints.length - 1; i++) {
      final dx = altWaypoints[i + 1].dx - altWaypoints[i].dx;
      final dy = altWaypoints[i + 1].dy - altWaypoints[i].dy;
      final len = sqrt(dx * dx + dy * dy);
      _segLengths.add(len);
      _totalPathLen += len;
    }
  }

  /// Get the active waypoints (original or alt based on branch choice).
  List<Offset> get _activeWaypoints {
    if (_isBranching && _branchChoice != null) {
      final bp = widget.event.branchPoint!;
      final isA = _branchChoice!.targetHotspotId == bp.optionA.targetHotspotId;
      if (!isA && _scene.pathWaypointsAlt != null) {
        return _scene.pathWaypointsAlt!;
      }
    }
    return _scene.pathWaypoints;
  }

  void _openSettings() {
    _gameLoop.stop();
    _gameLoop.reset();
    _joyDx = 0;
    _joyDy = 0;
    _idleTimer?.cancel();
    // Fade ambient + VO when opening settings (LOCKED RULE: no cuts)
    AudioService.stopSfx();
    AudioService.fadeOutVoiceover(duration: const Duration(milliseconds: 200));
    AudioService.fadeOut(duration: const Duration(milliseconds: 250));
    setState(() {
      _showSettings = true;
      _isWalking = false;
    });
  }

  void _resumeFromSettings() {
    setState(() {
      _showSettings = false;
      _isAr = PrefsService.isAr;
    });
    // Restart the ambient that was playing when user opened settings
    if (_showBranchCard) {
      AudioService.playAmbient(
        'assets/audio/ambient/ambient_crossroads.mp3',
        volume: 0.20,
      );
    } else if (_activeHotspot?.ambientPath != null) {
      AudioService.playAmbient(
        _activeHotspot!.ambientPath!,
        volume: 0.18,
      );
    }
    _resetIdleTimer();
  }

  /// R18-06: Fire-and-forget save of current progress (union of discovered + pending).
  /// Called immediately on every discovery state change so progress persists
  /// the moment it happens, eliminating exit-time race conditions.
  void _saveProgressNow() {
    if (_alreadyCompleted || _isCompleting) return;
    final allFound = _discovered.union(_pendingDiscovery);
    if (allFound.isEmpty) return;
    PrefsService.saveHotspotProgress(widget.event.id, allFound);
  }

  /// Header back button — saves progress and exits with audio cleanup.
  /// Mirrors the PopScope logic so there's only one exit path.
  Future<void> _exitScene() async {
    // Block during unanswered Verdict or completion writes
    if (_phase == _Phase.verdict && !_allAnswered) return;
    if (_isCompleting && !_alreadyCompleted) return;
    // Save hotspot progress before leaving (await to ensure persistence)
    if (!_alreadyCompleted && !_isCompleting) {
      final allFound = _discovered.union(_pendingDiscovery);
      if (allFound.isNotEmpty) {
        await PrefsService.saveHotspotProgress(widget.event.id, allFound);
      }
    }
    AudioService.stopSfx();
    AudioService.fadeOutVoiceover(duration: const Duration(milliseconds: 200));
    AudioService.fadeOut(duration: const Duration(milliseconds: 250));
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _saveAndExit() async {
    // Save hotspot progress before leaving (await to ensure persistence)
    if (!_alreadyCompleted && !_isCompleting) {
      final allFound = _discovered.union(_pendingDiscovery);
      if (allFound.isNotEmpty) {
        await PrefsService.saveHotspotProgress(widget.event.id, allFound);
      }
    }
    // Fade everything for smooth exit
    AudioService.stopSfx();
    AudioService.fadeOutVoiceover(duration: const Duration(milliseconds: 200));
    AudioService.fadeOut(duration: const Duration(milliseconds: 250));
    setState(() => _showSettings = false);
    if (mounted) Navigator.of(context).pop();
  }

  void _checkHotspotProximity() {
    if (_activeHotspot != null) return;
    if (_showBranchCard) return; // Don't trigger hotspots while branch card showing

    // R19-02: In Explorer Mode, only the NEXT hotspot in sequence can be
    // activated. Prevents discovering HS2/HS3 out of order.
    final nextId = _explorerMode ? _nextHotspotId : null;

    for (final h in _scene.hotspots) {
      if (_explorerMode && h.id != nextId) continue;

      final pos = _posFor(h);
      final dx = _companionX - pos.dx;
      final dy = _companionY - pos.dy;
      final dist = sqrt(dx * dx + dy * dy);

      if (dist < _hotspotRadius && !_discovered.contains(h.id) && !_pendingDiscovery.contains(h.id)) {
        _activateHotspot(h);
        return;
      }
    }
  }

  // ── Auto-walk (tap-to-walk) ─────────────────────────────────────────────

  void _stopAutoWalk() {
    _autoWalking = false;
    _gameLoop.stop();
    _gameLoop.reset();
    if (mounted) setState(() => _isWalking = false);
  }

  /// Derive choice phase VO path (question or explanation).
  String? _choiceVoPath(String type) {
    final eventMap = {'j_1_1_1': 'event1', 'j_1_1_2': 'event2', 'j_1_1_3': 'event3'};
    final eventKey = eventMap[widget.event.id];
    if (eventKey == null) return null;
    final lang = _isAr ? 'ar' : 'en';
    final gender = PrefsService.userGender == 'female' ? 'f' : 'm';
    return 'assets/audio/vo/vo_${eventKey}_${type}_${lang}_$gender.mp3';
  }

  void _playChoiceVo(String type) {
    final path = _choiceVoPath(type);
    if (path != null) {
      // Rule 4/5: Question VO 600ms after phase, explanation 500ms after reveal
      final delay = type == 'exp' ? 500 : 600;
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) {
          // playVoiceover internally fades any previous VO (LOCKED RULE)
          AudioService.playVoiceover(path);
        }
      });
    }
  }

  /// Derive VO asset path from event + hotspot + language + gender.
  String? _voPath(SceneHotspot hotspot) {
    // Map event IDs to VO naming: j_1_1_1 → event1, j_1_1_2 → event2, j_1_1_3 → event3
    final eventMap = {'j_1_1_1': 'event1', 'j_1_1_2': 'event2', 'j_1_1_3': 'event3'};
    final eventKey = eventMap[widget.event.id];
    if (eventKey == null) return null;
    final lang = _isAr ? 'ar' : 'en';
    final gender = PrefsService.userGender == 'female' ? 'f' : 'm';
    return 'assets/audio/vo/vo_${eventKey}_${hotspot.id}_${lang}_$gender.mp3';
  }

  void _playVoForHotspot(SceneHotspot hotspot) {
    final path = _voPath(hotspot);
    if (path != null) {
      // Rule 2: Hotspot VO starts 400ms after panel opens
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted && _activeHotspot == hotspot) {
          // playVoiceover internally fades any previous VO (LOCKED RULE)
          AudioService.playVoiceover(path);
        }
      });
    }
  }

  void _activateHotspot(SceneHotspot hotspot) {
    if (hotspot.sfxPath != null) {
      AudioService.playSfx(hotspot.sfxPath!, volume: 0.4);
      _footstepPlaying = false;
    }
    // Zero joystick + stop game loop to prevent stale movement after dismiss
    _joyDx = 0;
    _joyDy = 0;
    _gameLoop.stop();
    _gameLoop.reset();
    setState(() {
      _pendingDiscovery.add(hotspot.id);
      _isWalking = false;
      _lastDiscoveryTime = DateTime.now(); // reset anti-frustration timer
    });
    // R18-06: Save on discovery (immediate persistence — no race conditions)
    _saveProgressNow();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _activeHotspot = hotspot);
        // Start hotspot ambient bed (if available)
        if (hotspot.ambientPath != null) {
          AudioService.playAmbient(hotspot.ambientPath!, volume: 0.18);
        }
        _playVoForHotspot(hotspot);
      }
    });
  }

  /// Check if a screen tap hits any undiscovered secret near the Rawi.
  /// Secrets are pure visual delight — no card opens, just an effect.
  void _checkSecretTap(Offset localPosition, double screenW, double screenH, double sceneOffset) {
    if (_phase != _Phase.explore) return;
    if (_scene.secrets.isEmpty) return;

    // Convert tap position to normalized coords (accounting for parallax offset)
    final tapXNorm = (localPosition.dx - sceneOffset) / screenW;
    final tapYNorm = localPosition.dy / screenH;

    for (final secret in _scene.secrets) {
      if (_discoveredSecrets.contains(secret.id)) continue;

      // Tap must be within ~40px of the secret position
      final dx = (tapXNorm - secret.x).abs();
      final dy = (tapYNorm - secret.y).abs();
      final tapRadius = 0.06; // ~40px on a 600px-wide screen
      if (dx > tapRadius || dy > tapRadius) continue;

      // Secret must be within the Rawi's lit fog radius (~0.25 normalized)
      final distFromRawi = sqrt(
        pow(_companionX - secret.x, 2) + pow(_companionY - secret.y, 2),
      );
      if (distFromRawi > 0.25) continue;

      // Secret found — trigger reaction
      _triggerSecret(secret);
      return;
    }
  }

  void _triggerSecret(SceneSecret secret) {
    HapticFeedback.selectionClick();
    PrefsService.addDiscoveredSecret(secret.id);
    setState(() {
      _discoveredSecrets.add(secret.id);
    });

    // Play SFX if defined
    if (secret.sfxPath != null) {
      AudioService.playSfx(secret.sfxPath!, volume: 0.5);
    }

    // Create a brief animation controller for the visual effect (2s)
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _secretAnims[secret.id] = ctrl;
    ctrl.forward().then((_) {
      if (mounted) {
        setState(() => _secretAnims.remove(secret.id));
      }
      ctrl.dispose();
    });
  }

  void _onHotspotTap(SceneHotspot hotspot) {
    if (_activeHotspot != null) return;

    // ── Reader Mode: direct activation, no sequential checks. ──────
    // The card state machine (_readerCardState) already gates which
    // cards are tappable. If the user could tap it, they should see
    // the content. Period. No auto-walk, no path progress, no revisit
    // limiters — those are Explorer-only mechanics.
    if (!_explorerMode) {
      _activateHotspot(hotspot);
      return;
    }

    // ── Explorer Mode below ────────────────────────────────────────
    if (_autoWalking) return;

    final isNew = !_discovered.contains(hotspot.id) &&
        !_pendingDiscovery.contains(hotspot.id);

    // Revisit limiter — show bubble instead of panel on 3rd+ revisit
    if (!isNew && _discovered.contains(hotspot.id)) {
      final count = (_revisitCount[hotspot.id] ?? 0) + 1;
      _revisitCount[hotspot.id] = count;
      if (count >= 4) {
        final lid = RawiDialogue.getId(RawiDialogue.revisitFirm, count);
        _showBubble(RawiDialogue.get(
            RawiDialogue.revisitFirm, count, isAr: _isAr, name: PrefsService.userName),
            voPath: _companionVoPath(lid));
        return;
      } else if (count >= 3) {
        final lid = RawiDialogue.getId(RawiDialogue.revisitWarn, count);
        _showBubble(RawiDialogue.get(
            RawiDialogue.revisitWarn, count, isAr: _isAr, name: PrefsService.userName),
            voPath: _companionVoPath(lid));
        return;
      }
    }

    // New hotspot: check sequential unlock + auto-walk
    if (isNew) {
      String? nextHotspotId;
      if (_isBranching && _branchUnlockOrder.isNotEmpty) {
        nextHotspotId = _branchUnlockOrder.firstWhere(
          (id) => !_discovered.contains(id) && !_pendingDiscovery.contains(id),
          orElse: () => '',
        );
        if (nextHotspotId.isEmpty) nextHotspotId = null;
      } else if (!_isBranching) {
        final nextIdx = _scene.hotspots.indexWhere(
            (h) => !_discovered.contains(h.id) && !_pendingDiscovery.contains(h.id));
        if (nextIdx >= 0) nextHotspotId = _scene.hotspots[nextIdx].id;
      } else {
        nextHotspotId = widget.event.anchorHotspotId;
        if (_discovered.contains(nextHotspotId) || _pendingDiscovery.contains(nextHotspotId!)) {
          nextHotspotId = null;
        }
      }
      if (hotspot.id != nextHotspotId) {
        return; // Locked hotspot — ignore tap
      }
      // Explorer: proximity-based activation happens in _checkHotspotProximity,
      // not here. Return silently — the user needs to walk closer.
      return;
    }

    // Revisit (1st-2nd): re-open panel from anywhere
    if (hotspot.sfxPath != null) {
      AudioService.playSfx(hotspot.sfxPath!, volume: 0.4);
      _footstepPlaying = false;
    }
    setState(() => _isWalking = false);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _activeHotspot = hotspot);
        if (hotspot.ambientPath != null) {
          AudioService.playAmbient(hotspot.ambientPath!, volume: 0.18);
        }
        _playVoForHotspot(hotspot);
      }
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Color get _eraColor {
    switch (widget.event.era) {
      case JourneyEra.jahiliyyah: return AppColors.eraJahiliyyah;
      case JourneyEra.earlyLife:  return AppColors.eraEarlyLife;
      case JourneyEra.mecca:      return AppColors.eraMecca;
      case JourneyEra.medina:     return AppColors.eraMediana;
      case JourneyEra.rashidun:   return AppColors.eraRashidun;
      case JourneyEra.umayyad:    return AppColors.eraUmayyad;
      case JourneyEra.abbasid:    return AppColors.eraAbbasid;
      case JourneyEra.ottoman:    return AppColors.eraOttoman;
    }
  }

  bool get _allDiscovered =>
      (_discovered.length + _pendingDiscovery.length) >= _scene.hotspots.length;
  bool get _allAnswered =>
      widget.event.questions.isEmpty || _answers.every((a) => a != null);

  /// Discovery progress 0.0→1.0 for scene evolution effects.
  double get _discoveredProgress =>
      _scene.hotspots.isEmpty ? 0.0 : _discovered.length / _scene.hotspots.length;

  /// Trigger a scale bounce on the Rawi figure.
  void _triggerFigureBounce({bool celebration = false}) {
    _figureBounceTarget = celebration ? 0.10 : 0.05;
    _figureBounceCtrl.duration = Duration(milliseconds: celebration ? 500 : 300);
    _figureBounceCtrl.forward(from: 0.0);
  }

  /// Determine the next hotspot ID to unlock (shared logic).
  String? get _nextHotspotId {
    if (_isBranching && _branchUnlockOrder.isNotEmpty) {
      final id = _branchUnlockOrder.firstWhere(
        (id) => !_discovered.contains(id) && !_pendingDiscovery.contains(id),
        orElse: () => '',
      );
      return id.isEmpty ? null : id;
    } else if (!_isBranching) {
      final nextIdx = _scene.hotspots.indexWhere(
          (h) => !_discovered.contains(h.id) && !_pendingDiscovery.contains(h.id));
      return nextIdx >= 0 ? _scene.hotspots[nextIdx].id : null;
    } else {
      // Branching but no choice yet: only anchor is active
      final anchorId = widget.event.anchorHotspotId;
      if (anchorId != null && !_discovered.contains(anchorId) && !_pendingDiscovery.contains(anchorId)) {
        return anchorId;
      }
      return null;
    }
  }

  /// Update proximity opacity map for undiscovered hotspots.
  void _updateHotspotProximity({required String? nextHotspotId}) {
    // R21B-06: Freeze proximity during the ENTIRE discovery window —
    // both the 400ms activation delay (_pendingDiscovery non-empty but
    // _activeHotspot still null) AND while the card is open.
    if (_activeHotspot != null || _pendingDiscovery.isNotEmpty) return;

    // R19-01c: Reader Mode shows ALL hotspots fully visible from start.
    // No proximity fade, no sequential lock — the user is reading, not
    // hunting. Clear the opacity map so build uses defaults.
    if (!_explorerMode) {
      _hotspotProximityOpacity.clear();
      return;
    }

    for (final h in _scene.hotspots) {
      if (_discovered.contains(h.id) || _pendingDiscovery.contains(h.id)) {
        // Discovered: always fully visible (handled in build)
        _hotspotProximityOpacity.remove(h.id);
        continue;
      }
      if (h.id != nextHotspotId) {
        // Locked future hotspot: invisible
        _hotspotProximityOpacity[h.id] = 0.0;
        continue;
      }
      // Next undiscovered hotspot: distance-based opacity
      // Range extended past the fog cutout (~0.25 normalized) so the marker
      // becomes visible THROUGH the fog as a hint, before entering the lit area.
      final pos = _posFor(h);
      final dx = _companionX - pos.dx;
      final dy = _companionY - pos.dy;
      final dist = sqrt(dx * dx + dy * dy);

      // Anti-frustration (Explorer Mode): progressively boost visibility
      // when the user hasn't found the next hotspot for a while.
      //   60s → double the visible range (0.32 → 0.64)
      //   90s → triple it + minimum glow
      //  120s → fully visible regardless of distance
      final secs = _explorerMode ? _secondsSinceDiscovery : 0;
      if (secs >= 120) {
        // 120s: pulse brightly — nobody stays stuck forever
        _hotspotProximityOpacity[h.id] = 0.9;
      } else {
        final rangeMultiplier = secs >= 90 ? 3.0 : (secs >= 60 ? 2.0 : 1.0);
        final minGlow = secs >= 90 ? 0.25 : 0.0;
        final maxDist = 0.32 * rangeMultiplier;
        if (dist > maxDist) {
          _hotspotProximityOpacity[h.id] = minGlow;
        } else if (dist > 0.18) {
          // Far-near zone: faint hint through fog (0.2 → 0.5)
          final t = 1.0 - (dist - 0.18) / (maxDist - 0.18).clamp(0.01, 10.0);
          _hotspotProximityOpacity[h.id] = (0.2 + t * 0.3).clamp(minGlow, 1.0);
        } else if (dist > 0.10) {
          // Near zone: noticeable (0.5 → 0.8)
          final t = 1.0 - (dist - 0.10) / (0.18 - 0.10);
          _hotspotProximityOpacity[h.id] = 0.5 + t * 0.3;
        } else {
          // Close zone: fully visible (0.8 → 1.0)
          final t = 1.0 - dist / 0.10;
          _hotspotProximityOpacity[h.id] = 0.8 + t * 0.2;
        }
      }
    }
  }

  void _dismissPanel() {
    // LOCKED RULE: fade VO and ambient, never hard cut
    AudioService.fadeOutVoiceover(duration: const Duration(milliseconds: 200));
    AudioService.fadeOut(duration: const Duration(milliseconds: 200));
    final dismissed = _activeHotspot;
    // Ensure joystick is clean — prevents stale movement after dismiss
    _joyDx = 0;
    _joyDy = 0;
    final wasNewDiscovery = dismissed != null && _pendingDiscovery.contains(dismissed.id);
    setState(() {
      if (wasNewDiscovery) {
        _pendingDiscovery.remove(dismissed.id);
        _discovered.add(dismissed.id);
        HapticFeedback.mediumImpact();
      }
      _activeHotspot = null;
    });
    // R18-06: Save on discovery (immediate persistence — no race conditions)
    if (wasNewDiscovery) _saveProgressNow();

    // ── Feature 6: Rawi bounce after discovery ──────────────────────────
    if (wasNewDiscovery) {
      _triggerFigureBounce();
    }

    // ── Feature 5: Ambient volume increase with progress ────────────────
    if (wasNewDiscovery && _discoveredProgress > 0) {
      AudioService.fadeAmbientTo(
        0.10 + _discoveredProgress * 0.10,
        duration: const Duration(milliseconds: 500),
      );
    }

    // R20 Part C: Reader Mode tap-to-advance — after dismissing a
    // hotspot, walk the Rawi to the next one. Skip for the final
    // hotspot (verdict takes over) and for branching events whose
    // R20 Part C v3: Reader Mode keeps the Rawi stationary in the
    // center of the quadrant grid — no auto-walk. The card state
    // machine takes over visually (active/branch_choice cards
    // glow). Branch choice in Reader Mode is made by tapping a
    // BRANCH_CHOICE card directly (see _onHotspotTap), so the
    // Crossroads overlay is suppressed below as well.

    // ── Branching: show Crossroads card after anchor (Explorer only) ────
    if (_explorerMode &&
        _isBranching && dismissed != null &&
        dismissed.id == widget.event.anchorHotspotId &&
        _branchChoice == null) {
      // The Gate just dismissed — show The Crossroads
      _idleTimer?.cancel(); // Stop idle VO from overlapping branch card
      // Stop ALL movement state before showing branch card
      _gameLoop.stop();
      _gameLoop.reset();
      _joyDx = 0;
      _joyDy = 0;
      _isWalking = false;
      setState(() => _showBranchCard = true);
      // Start Crossroads ambient bed
      AudioService.playAmbient(
        'assets/audio/ambient/ambient_crossroads.mp3',
        volume: 0.20,
      );
      // Rule 3: Branch card VO starts 600ms after card shows
      final branchVoPath = _choiceVoPath('branch');
      if (branchVoPath != null) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted && _showBranchCard) {
            // playVoiceover internally fades any previous VO (LOCKED RULE)
            AudioService.playVoiceover(branchVoPath);
          }
        });
      }
      return;
    }

    // R21B-04: In replay mode, don't auto-trigger verdict. The user
    // can re-read any card freely and use explicit buttons at the
    // bottom to open the verdict or return to the event list.
    if (_allDiscovered && _phase == _Phase.explore && !_alreadyCompleted) {
      // ── Feature 6: All-done celebration bounce ────────────────────
      _triggerFigureBounce(celebration: true);

      // ── Fog of War: full reveal + golden tint ─────────────────────
      _triggerFogReveal();

      if (_isBranching) {
        // Branching mode: question renders in-scene after convergence
        // NO tutorial here — tutorial was shown at the branch card
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            setState(() => _phase = _Phase.verdict);
            _phaseCtrl.forward();
            _playChoiceVo('q');
          }
        });
      } else {
        // Linear mode: verdict overlay
        final adLid = RawiDialogue.getId(RawiDialogue.allDone, _discovered.length);
        _showBubble(RawiDialogue.get(
            RawiDialogue.allDone, _discovered.length, isAr: _isAr, name: PrefsService.userName),
            voPath: _companionVoPath(adLid));
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() => _phase = _Phase.verdict);
            _phaseCtrl.forward();
            _playChoiceVo('q');
          }
        });
      }
    } else if (dismissed != null && _discovered.contains(dismissed.id)) {
      // Post-discovery nudge
      _postDiscoveryCount++;
      final pdLid = RawiDialogue.getId(RawiDialogue.postDiscovery, _postDiscoveryCount);
      _showBubble(RawiDialogue.get(
          RawiDialogue.postDiscovery, _postDiscoveryCount, isAr: _isAr, name: PrefsService.userName),
          voPath: _companionVoPath(pdLid));
    }
  }

  /// Triggers fog fade-out and golden tint sunrise effect.
  void _triggerFogReveal() {
    HapticFeedback.heavyImpact();
    setState(() => _fogSceneRevealed = true);
    // Golden tint: fade in over 400ms, hold, then fade out
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _goldenTintOpacity = 1.0);
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _goldenTintOpacity = 0.0);
    });
  }

  void _selectChoice(int qIdx, int choiceIdx) async {
    if (_answers[qIdx] != null) return;
    final isCorrect = choiceIdx == widget.event.questions[qIdx].correctIndex;
    if (isCorrect) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }
    setState(() => _answers[qIdx] = choiceIdx);
    _revealCtrl.forward();
    _playChoiceVo('exp');

    if (_allAnswered) {
      final prevXp = PrefsService.xp;
      setState(() {
        _phase = _Phase.complete;
        _isCompleting = true;
        _previousXp = prevXp;
        _showContinueButton = false;
        _showXpAnimation = false;
        _showBadgeOverlay = false;
      });

      if (!_alreadyCompleted) {
        // Write immediately — crash-safe. Badge+XP shown later on Continue tap.
        await PrefsService.completeEvent(widget.event.globalOrder, widget.event.xpReward);
        await PrefsService.clearHotspotProgress(widget.event.id);
        final badges = await PrefsService.checkAndAwardBadges();
        if (mounted && badges.isNotEmpty) {
          _newBadges = badges;
        }
        // Show Continue button after a brief delay for explanation to settle
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) setState(() => _showContinueButton = true);
      } else {
        // Replay — show Continue immediately
        setState(() => _showContinueButton = true);
      }
    }
  }

  Completer<void>? _badgeDismissCompleter;

  void _onBadgeDismissed() {
    setState(() {
      _showBadgeOverlay = false;
      _currentBadge = null;
    });
    _badgeDismissCompleter?.complete();
    _badgeDismissCompleter = null;
  }

  bool _showChapterComplete = false;
  Completer<void>? _chapterDismissCompleter;

  /// Check if this event is the last in its chapter.
  bool get _isChapterEnd =>
      widget.event.globalOrder == widget.event.era.lastEventOrder;

  /// "Continue Journey" — pushes the unified completion screen, which
  /// replaces the old 5-step overlay sequence (chapter / badge / XP /
  /// dhikr / scroll writing) with a single scrollable screen.
  ///
  /// R17.2-05: replaced by UnifiedCompletionScreen.
  /// Note: XP, badges, event completion, and hotspot clearing are ALREADY
  /// persisted by _selectChoice before this runs. The unified screen only
  /// handles dhikr prefs on user tap.
  Future<void> _completeAndPop() async {
    // LOCKED RULE: fade VO and ambient before reward flow (no cuts)
    AudioService.fadeOutVoiceover(duration: const Duration(milliseconds: 300));
    AudioService.fadeOut(duration: const Duration(milliseconds: 300));
    AudioService.stopSfx();
    if (!mounted) return;

    // Capture state for the unified screen
    final xpEarned = _alreadyCompleted ? 0 : widget.event.xpReward;
    final previousXp = _previousXp;
    final newBadges = _newBadges;
    final isChapterEnd = _isChapterEnd && !_alreadyCompleted;

    // R17.2-05: replaced by UnifiedCompletionScreen — the old sequential
    // overlay flow (chapter / badge / XP / dhikr / scroll writing) is
    // preserved in its source files but no longer triggered from here.
    //
    // Old sequence (for reference):
    //   Step 1: Chapter completion overlay (_showChapterComplete)
    //   Step 2: Badge overlay loop (_showBadgeOverlay / _currentBadge)
    //   Step 3: XP reward animation (_showXpAnimation)
    //   Step 4: DhikrScreen push → ScrollWritingScreen → EventListScreen
    //
    // All five steps now live inside UnifiedCompletionScreen as sections.

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => UnifiedCompletionScreen(
          event: widget.event,
          xpEarned: xpEarned,
          previousXp: previousXp,
          newBadges: newBadges,
          isChapterEnd: isChapterEnd,
          alreadyCompleted: _alreadyCompleted,
        ),
      ),
    );
  }

  /// Back to events for replays.
  void _continue() {
    AudioService.stopSfx();
    AudioService.fadeOutVoiceover(duration: const Duration(milliseconds: 200));
    AudioService.fadeOut(duration: const Duration(milliseconds: 250));
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const EventListScreen()),
      (route) => false,
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;

    final maxOffset = screenW * 0.3; // max parallax shift
    final sceneOffset =
        (_parallaxOffset * maxOffset).clamp(-maxOffset, maxOffset);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _exitScene();
      },
      child: Scaffold(
      // R19-01b: Reader Mode uses the same navy gradient as the cinematic
      // intro for events without rich custom art. Avoids a flat-black scene
      // that feels dim even though there's no fog.
      backgroundColor: _explorerMode ? Colors.black : const Color(0xFF04060D),
      body: Listener(
        behavior: HitTestBehavior.deferToChild,
        onPointerDown: _explorerMode
            ? (event) => _checkSecretTap(
                event.localPosition, screenW, screenH, sceneOffset)
            : null,
        // R22 Part 1: NO GestureDetector wrapping the Stack. In Reader
        // Mode this was causing tap-eating even with null callbacks —
        // a GestureDetector with HitTestBehavior.translucent still
        // registers in the gesture arena. Touch-to-move is now a
        // Positioned.fill child INSIDE the Stack, Explorer-only.
        child: Stack(
        fit: StackFit.expand,
        children: [
          // R19-01b: Reader Mode background gradient.
          if (!_explorerMode)
            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF04060D), Color(0xFF0B1E2D)],
                    ),
                  ),
                ),
              ),
            ),

          // ── Full-screen parallax scene (non-interactive) ───────────
          Positioned.fill(
            child: IgnorePointer(child: ParallaxScene(
              height: screenH,
              layers: _scene.groundLayers,
              externalOffset: sceneOffset,
            )),
          ),

          // ── Feature 5: Sky gradient shift (warm overlay with progress) ──
          if (_discoveredProgress > 0 && _phase == _Phase.explore)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _discoveredProgress * 0.12,
                  duration: const Duration(milliseconds: 600),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.lerp(Colors.transparent, const Color(0xFFFF8C00), _discoveredProgress) ?? Colors.transparent,
                          Color.lerp(Colors.transparent, const Color(0xFFFFD700), _discoveredProgress) ?? Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Hidden scene secrets (active animations) ──────────────
          ..._secretAnims.entries.map((entry) {
            final secret = _scene.secrets.firstWhere((s) => s.id == entry.key);
            return Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: entry.value,
                  builder: (context, _) {
                    final t = entry.value.value;
                    return CustomPaint(
                      painter: _SecretPainter(
                        type: secret.type,
                        x: secret.x,
                        y: secret.y,
                        progress: t,
                        sceneOffset: sceneOffset,
                      ),
                    );
                  },
                ),
              ),
            );
          }),

          // ── Atmospheric overlays (all non-interactive) ─────────────
          if (_scene.showStars) const IgnorePointer(child: StarfieldLayer()),
          if (_scene.showMoon) IgnorePointer(child: CrescentMoon(position: _scene.moonPosition)),
          if (_scene.particleType != ParticleType.none)
            IgnorePointer(child: ParticleField(type: _scene.particleType,
                count: (_scene.particleCount * (1.0 + _discoveredProgress * 0.5)).round(),
                color: _scene.particleColor)),
          if (_scene.showGrain) const IgnorePointer(child: GrainOverlay()),

          if (_scene.showBirds) IgnorePointer(child: BirdsOverlay(count: _scene.birdCount)),

          // ── Footprint trail (non-interactive) ──────────────────────
          if (_phase == _Phase.explore && _footprints.isNotEmpty)
            IgnorePointer(child: CustomPaint(
              size: Size(screenW, screenH),
              painter: _FootprintPainter(
                footprints: _footprints,
                sceneW: screenW,
                screenH: screenH,
                sceneOffset: sceneOffset,
              ),
            )),

          // ── Fog of War (Explorer only, non-interactive) ────────────
          if (_phase == _Phase.explore && !_alreadyCompleted && _explorerMode)
            Positioned.fill(
              child: IgnorePointer(child: FogOverlay(
                rawiX: _companionX,
                rawiY: _companionY,
                discoveredPositions: _scene.hotspots
                    .where((h) => _discovered.contains(h.id) || _pendingDiscovery.contains(h.id))
                    .map((h) => _posFor(h))
                    .toList(),
                totalHotspots: _scene.hotspots.length,
                discoveredCount: _discovered.length + _pendingDiscovery.length,
                sceneRevealed: _fogSceneRevealed,
                sceneOffset: sceneOffset,
                rawiLightRadius: 25.0 + (PrefsService.noorLevel / 100.0) * 95.0,
              )),
            ),

          // ── Golden tint on full reveal ────────────────────────────────
          if (_goldenTintOpacity > 0.0)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _goldenTintOpacity,
                  duration: const Duration(milliseconds: 400),
                  child: Container(color: const Color(0x15FFD700)),
                ),
              ),
            ),

          // ── Touch-to-move (Explorer only, BEHIND markers) ────────
          // R24 fix: MUST be before hotspot markers in the children
          // list so markers render on top and win hit tests. The
          // previous position (after markers) caused the Positioned.fill
          // GestureDetector to sit ABOVE cards, eating their taps.
          if (_explorerMode && _phase == _Phase.explore)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (details) {
                  if (_activeHotspot != null || _showBranchCard) return;
                  final targetX = (details.localPosition.dx / screenW)
                      .clamp(0.05, 0.95);
                  final targetY = (details.localPosition.dy / screenH)
                      .clamp(0.15, 0.90);
                  _companionX += (targetX - _companionX) * 0.15;
                  _companionY += (targetY - _companionY) * 0.15;
                  _parallaxOffset = -(_companionX - 0.5) * 0.8;
                  _facingDir = targetX >= _companionX ? 1.0 : -1.0;
                  if (_footprints.isEmpty ||
                      (_footprints.last.dx - _companionX).abs() > 0.01 ||
                      (_footprints.last.dy - _companionY).abs() > 0.01) {
                    _footprints.add(Offset(_companionX, _companionY));
                    if (_footprints.length > 80) _footprints.removeAt(0);
                  }
                  setState(() => _isWalking = true);
                  _checkHotspotProximity();
                  _updateHotspotProximity(nextHotspotId: _nextHotspotId);
                },
                onPanEnd: (_) {
                  if (mounted) setState(() => _isWalking = false);
                },
              ),
            ),

          // ── Hotspot markers (Explorer) / cards (Reader v3) ──────────
          if (_phase == _Phase.explore || _phase == _Phase.verdict)
            ...(() {
              if (_explorerMode) {
                // Explorer: small markers w/ sequential reveal + fog hint.
                final nextHotspotId = _nextHotspotId;
                return _scene.hotspots.map((h) {
                  final hPos = _posFor(h);
                  final hScreenX = hPos.dx * screenW + sceneOffset - 45;
                  final hScreenY = hPos.dy * screenH - 45;
                  final isDiscovered = _discovered.contains(h.id);
                  final isPending = _pendingDiscovery.contains(h.id);
                  final isNext =
                      h.id == nextHotspotId && !isDiscovered && !isPending;
                  final isLocked =
                      !isDiscovered && !isPending && h.id != nextHotspotId;

                  final double proximityOpacity;
                  if (isDiscovered || isPending) {
                    proximityOpacity = 1.0;
                  } else if (h.id == nextHotspotId) {
                    proximityOpacity = _hotspotProximityOpacity[h.id] ?? 0.0;
                  } else {
                    proximityOpacity = 0.0;
                  }

                  final marker = SceneHotspotMarker(
                    icon: h.icon,
                    label: _isAr ? h.labelAr : h.label,
                    discovered: isDiscovered,
                    active: isNext,
                    locked: isLocked,
                    onTap: () => _onHotspotTap(h),
                  );

                  return Positioned(
                    left: hScreenX, top: hScreenY,
                    child: (isDiscovered || isPending)
                        ? marker
                        : AnimatedOpacity(
                            opacity: proximityOpacity,
                            duration: const Duration(milliseconds: 400),
                            child: marker,
                          ),
                  );
                });
              }

              // Reader Mode v3: 4 quadrant cards with a small gap
              // (R21A-06) so the Rawi circle sits IN the intersection
              // rather than on top of perfectly-butted corners. The
              // circle's 2.5px gold border meets each card's inner
              // corner through the gap — one connected visual unit.
              const cardW = 150.0;
              const cardH = 138.0;
              const halfGap = 3.0; // 6px total gap → circle fits in it
              final centerX = screenW / 2;
              final centerY = screenH / 2;
              return _scene.hotspots.asMap().entries.map((entry) {
                final i = entry.key;
                final h = entry.value;
                final state = _readerCardState(h);
                final quadrant = _readerQuadrant(i);
                final isLeft = quadrant == ReaderCardQuadrant.tl ||
                    quadrant == ReaderCardQuadrant.bl;
                final isTop = quadrant == ReaderCardQuadrant.tl ||
                    quadrant == ReaderCardQuadrant.tr;
                final left =
                    isLeft ? centerX - cardW - halfGap : centerX + halfGap;
                final top =
                    isTop ? centerY - cardH - halfGap : centerY + halfGap;

                return Positioned(
                  left: left,
                  top: top,
                  child: ReaderHotspotCard(
                    icon: h.icon,
                    label: _isAr ? h.labelAr : h.label,
                    index: i,
                    state: state,
                    quadrant: quadrant,
                    isAr: _isAr,
                    width: cardW,
                    height: cardH,
                    onTap: () => _onReaderCardTap(h, state),
                  ),
                );
              });
            }()),

          // ── Rawi figure + speech bubble ─────────────────────────────
          if (_phase == _Phase.explore)
            // Reader: IgnorePointer (stationary, non-interactive, sits
            // in the card grid gap). Explorer: interactive column with
            // bubble above the walking figure.
            if (!_explorerMode)
              Positioned(
                left: screenW / 2 - 34,
                top: screenH / 2 - 32,
                child: IgnorePointer(
                  child: Transform.scale(
                    scale: _figureScale,
                    child: RawiFigure(
                      isWalking: false,
                      facingDirection: 0.0,
                      isAr: _isAr,
                    ),
                  ),
                ),
              )
            else
              Positioned(
                left: _companionX * screenW + sceneOffset - 32,
                top: _companionY * screenH - 41,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RawiSpeechBubble(
                      text: _bubbleText,
                      visible: _bubbleVisible,
                      isAr: _isAr,
                    ),
                    const SizedBox(height: 4),
                    Transform.scale(
                      scale: _figureScale,
                      child: RawiFigure(
                        isWalking: _isWalking,
                        facingDirection: _facingDir,
                        isAr: _isAr,
                      ),
                    ),
                  ],
                ),
            ),

          // ── Dim overlay (non-interactive) ──────────────────────────
          if (_phase == _Phase.verdict || _phase == _Phase.complete)
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: _phase != _Phase.explore ? 0.35 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Container(color: Colors.black),
              ),
            ),

          // ── Header ─────────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsetsDirectional.fromSTEB(4, topPad + 4, 16, 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.black.withAlpha(180), Colors.transparent],
                ),
              ),
              // R21B-05: Language toggle removed from scene header — language
              // changes only via Settings or Registration. The header now
              // has just the back + era chip on the left and settings on
              // the right.
              child: Row(
                    textDirection: TextDirection.ltr,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded,
                            color: AppColors.textBody, size: 20),
                        onPressed: _exitScene,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.bg.withAlpha(200),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _eraColor.withAlpha(120)),
                        ),
                        child: Text(
                          '${widget.event.era.emoji}  ${widget.event.era.label(PrefsService.language)}',
                          style: GoogleFonts.nunito(
                              color: _eraColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _openSettings,
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.card.withAlpha(180),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: const Icon(Icons.settings_rounded,
                          size: 15, color: AppColors.textMuted),
                    ),
                  ),
                    ],
                  ),
            ),         // Container (header bg)
          ),           // Positioned (header)

          // ── Noor HUD (Explorer Mode only) ────────────────────────
          if (_explorerMode && _phase == _Phase.explore && _activeHotspot == null)
            Positioned(
              top: topPad + 50, left: 14,
              child: _NoorHud(noorLevel: PrefsService.noorLevel),
            ),

          // ── Hotspot progress (top, below era bar) ─────────────────
          if (_phase == _Phase.explore && _activeHotspot == null)
            Positioned(
              top: topPad + 52, left: 0, right: 0,
              child: Center(
                child: HotspotProgress(
                  total: _scene.hotspots.length,
                  discovered: _discovered.length + _pendingDiscovery.length, isAr: _isAr),
              ),
            ),

          // ── Virtual joystick ───────────────────────────────────────
          // R20 Part C: hidden in Reader Mode — Reader uses tap-to-advance
          // instead of free movement.
          // R21-04: position is user-configurable (left / center / right).
          if (_explorerMode && _phase == _Phase.explore && _activeHotspot == null)
            Positioned(
              bottom: bottomPad + 16,
              left: PrefsService.joystickPosition == 'left'
                  ? 20
                  : PrefsService.joystickPosition == 'center'
                      ? screenW / 2 - 56
                      : null,
              right:
                  PrefsService.joystickPosition == 'right' ? 20 : null,
              child: VirtualJoystick(
                onMove: (dx, dy) {
                  _joyDx = dx;
                  _joyDy = dy;
                  _resetIdleTimer();
                  if (!_gameLoop.isAnimating) {
                    _gameLoop.repeat();
                  }
                },
                onRelease: () {
                  _joyDx = 0; _joyDy = 0;
                  _gameLoop.stop();
                  _gameLoop.reset();
                  _resetIdleTimer();
                  setState(() => _isWalking = false);
                  if (_footstepPlaying) {
                    AudioService.stopSfx();
                    _footstepPlaying = false;
                  }
                },
              ),
            ),

          // ── R21B-04: Replay mode buttons (Verdict + Back) ─────────
          if (_alreadyCompleted && _phase == _Phase.explore && _activeHotspot == null)
            Positioned(
              bottom: bottomPad + 20,
              left: 24,
              right: 24,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _continue,
                      child: Container(
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.gold.withAlpha(15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.gold.withAlpha(120)),
                        ),
                        child: Text(
                          _isAr ? 'العودة للأحداث' : 'Back to Events',
                          style: GoogleFonts.nunito(
                            color: AppColors.gold,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _phase = _Phase.verdict);
                        _phaseCtrl.forward();
                      },
                      child: Container(
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _isAr ? 'الحكم' : 'The Verdict',
                          style: GoogleFonts.nunito(
                            color: AppColors.bg,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Hotspot card ───────────────────────────────────────────
          if (_activeHotspot != null)
            HotspotCard(
              label: _isAr ? _activeHotspot!.labelAr : _activeHotspot!.label,
              fragment: _isAr ? _activeHotspot!.fragmentAr : _activeHotspot!.fragment,
              icon: _activeHotspot!.icon, isAr: _isAr, onDismiss: _dismissPanel,
              imagePath: _activeHotspot!.imagePath,
              deeperContent: _isAr ? _activeHotspot!.deeperContentAr : _activeHotspot!.deeperContent,
              voPath: _voPath(_activeHotspot!),
              didYouKnow: _activeHotspot!.didYouKnow,
              didYouKnowAr: _activeHotspot!.didYouKnowAr,
              sourceRef: _activeHotspot!.sourceRef,
              sourceRefAr: _activeHotspot!.sourceRefAr,
              centerMode: true),

          // ── The Verdict (all events — unified gold card UI) ────────
          if ((_phase == _Phase.verdict || _phase == _Phase.complete)
              && !_showChapterComplete && !_showXpAnimation && !_showBadgeOverlay)
            _buildConvergenceQuestion(bottomPad),

          // ── The Crossroads (choice card after The Gate) ────────────
          if (_showBranchCard && widget.event.branchPoint != null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withAlpha(120),
                child: CrossroadsCard(
                  branchPoint: widget.event.branchPoint!,
                  isAr: _isAr,
                  onOptionSelected: _onBranchSelected,
                ),
              ),
            ),

          // ── Settings overlay ──────────────────────────────────────
          if (_showSettings)
            Positioned.fill(
              child: SettingsOverlay(
                onResume: _resumeFromSettings,
                onSaveAndExit: _saveAndExit,
              ),
            ),

          // ── Tutorial overlay (first event only) ───────────────────
          if (_showTutorial)
            Positioned.fill(
              child: TutorialOverlay(
                onComplete: () {
                  setState(() => _showTutorial = false);
                  _resetIdleTimer();
                },
              ),
            ),

          // ── Badge overlay (full-screen, 85% dark) ──────────────────
          if (_showBadgeOverlay && _currentBadge != null)
            Positioned.fill(
              child: BadgeOverlay(
                badge: _currentBadge!,
                onDismiss: _onBadgeDismissed,
              ),
            ),

          // ── Chapter completion overlay (narrative closing) ─────────
          if (_showChapterComplete)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() => _showChapterComplete = false);
                  _chapterDismissCompleter?.complete();
                  _chapterDismissCompleter = null;
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  color: Colors.black.withAlpha(245),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(18),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.gold.withAlpha(40)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Carrying portrait with gold border
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.gold, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.gold.withAlpha(50),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                CharacterArt.carrying(),
                                width: 80, height: 80, fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            widget.event.era.emoji,
                            style: const TextStyle(fontSize: 48),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _isAr
                                ? widget.event.era.label('ar')
                                : widget.event.era.label('en'),
                            style: GoogleFonts.cinzelDecorative(
                              color: AppColors.gold,
                              fontSize: 22,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: 40, height: 1,
                            color: AppColors.gold.withAlpha(80),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.event.era.closingLine(
                                _isAr ? 'ar' : 'en'),
                            textAlign: TextAlign.center,
                            textDirection: _isAr
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            style: GoogleFonts.lora(
                              color: const Color(0xFFE8D8B8),
                              fontSize: 17,
                              fontStyle: _isAr ? FontStyle.normal : FontStyle.italic,
                              fontWeight: FontWeight.w500,
                              height: 1.7,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            _isAr ? 'اضغط للمتابعة' : 'Tap to continue',
                            style: GoogleFonts.nunito(
                              color: AppColors.textMuted.withAlpha(180),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── XP celebration overlay (full-screen, after badge) ─────
          if (_showXpAnimation)
            Positioned.fill(
              child: Container(
                color: Colors.black.withAlpha(200),
                child: Center(
                  child: XpRewardAnimation(
                    xpEarned: widget.event.xpReward,
                    previousTotal: _previousXp,
                  ),
                ),
              ),
            ),
        ],
      ),
      ),
    ),
    );
  }

  // ── The Verdict (in-scene question at The Gathering) ────────────────────────

  Widget _buildConvergenceQuestion(double bottomPad) {
    final event = widget.event;
    if (event.questions.isEmpty) return const SizedBox.shrink();

    final q = event.questions[0];
    final question = _isAr ? q.questionAr : q.question;
    final options = _isAr ? q.optionsAr : q.options;
    final explanation = _isAr ? q.explanationAr : q.explanation;
    final answered = _answers[0] != null;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withAlpha(180), // Deeper dim — scene holds its breath
        child: Center(
          child: Container(
            margin: EdgeInsetsDirectional.fromSTEB(16, 60, 16, bottomPad + 16),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0E14).withAlpha(250),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.gold.withAlpha(100), // Gold border — cinematic
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withAlpha(25),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ScrollHintWrapper(
              controller: _verdictScrollCtrl,
              child: SingleChildScrollView(
                controller: _verdictScrollCtrl,
                padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header + witnessing portrait + VO replay
                    Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          CharacterArt.witnessing(),
                          width: 40, height: 40, fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _isAr ? 'هل تذكر؟' : 'Do You Remember?',
                    style: GoogleFonts.lora(
                      color: _eraColor.withAlpha(200),
                      fontSize: 14,
                      fontStyle: _isAr ? FontStyle.normal : FontStyle.italic,
                      fontWeight: FontWeight.w600,
                    ),
                        ),
                      ),
                      // Replay VO
                      GestureDetector(
                        onTap: () {
                          final path = _choiceVoPath(answered ? 'exp' : 'q');
                          if (path != null) {
                            // playVoiceover fades previous internally (LOCKED RULE)
                            AudioService.playVoiceover(path);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.gold.withAlpha(25),
                            border: Border.all(color: AppColors.gold.withAlpha(80)),
                          ),
                          child: Icon(Icons.replay_rounded,
                              size: 14, color: AppColors.gold.withAlpha(200)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Mute/unmute VO
                      GestureDetector(
                        onTap: () {
                          if (PrefsService.voEnabled) {
                            AudioService.fadeOutVoiceover(
                                duration: const Duration(milliseconds: 200));
                            PrefsService.setVoEnabled(false);
                          } else {
                            PrefsService.setVoEnabled(true);
                          }
                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.gold.withAlpha(15),
                            border: Border.all(color: AppColors.gold.withAlpha(50)),
                          ),
                          child: Icon(
                            PrefsService.voEnabled
                                ? Icons.volume_up_rounded
                                : Icons.volume_off_rounded,
                            size: 14,
                            color: PrefsService.voEnabled
                                ? AppColors.gold.withAlpha(180)
                                : AppColors.textMuted.withAlpha(120)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Question
                  Text(
                    question,
                    textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
                    style: GoogleFonts.cinzelDecorative(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Options
                  ...List.generate(options.length, (i) {
                    final isSelected = _answers[0] == i;
                    final isCorrectOpt = i == q.correctIndex;
                    Color borderColor, bgColor, textColor;
                    if (!answered) {
                      borderColor = AppColors.gold.withAlpha(76); // Gold at 30%
                      bgColor = AppColors.gold.withAlpha(8);
                      textColor = AppColors.textPrimary;
                    } else if (isCorrectOpt) {
                      borderColor = AppColors.gold; // Full gold reveal
                      bgColor = AppColors.gold.withAlpha(25);
                      textColor = AppColors.textPrimary;
                    } else if (isSelected) {
                      borderColor = AppColors.textMuted.withAlpha(40);
                      bgColor = AppColors.bg;
                      textColor = AppColors.textMuted.withAlpha(120);
                    } else {
                      borderColor = AppColors.textMuted.withAlpha(20);
                      bgColor = AppColors.bg;
                      textColor = AppColors.textMuted.withAlpha(100);
                    }
                    return GestureDetector(
                      onTap: () => _selectChoice(0, i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: borderColor,
                            width: answered && isCorrectOpt ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                options[i],
                                textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
                                style: GoogleFonts.nunito(
                                  color: textColor, fontSize: 13,
                                  fontWeight: FontWeight.w600, height: 1.4,
                                ),
                              ),
                            ),
                            if (answered && isCorrectOpt)
                              Padding(
                                padding: const EdgeInsetsDirectional.only(start: 8),
                                child: Icon(Icons.check_circle_rounded,
                                    color: AppColors.gold, size: 18),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // Explanation (after answer)
                  if (answered) ...[
                    const SizedBox(height: 4),
                    FadeTransition(
                      opacity: _revealAnim,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withAlpha(10),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.gold.withAlpha(50),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.brightness_3_rounded,
                                    size: 13, color: AppColors.gold),
                                const SizedBox(width: 7),
                                Text(
                                  _isAr ? 'يسجّل التاريخ' : 'History Records',
                                  style: GoogleFonts.nunito(
                                    color: AppColors.gold,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              explanation,
                              textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
                              style: GoogleFonts.lora(
                                color: AppColors.textBody,
                                fontSize: 13,
                                fontStyle: _isAr ? FontStyle.normal : FontStyle.italic,
                                height: 1.7,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Source reference (below explanation)
                  if (answered && q.sourceRef != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '📖 ${_isAr ? (q.sourceRefAr ?? q.sourceRef!) : q.sourceRef!}',
                        style: GoogleFonts.nunito(
                          color: const Color(0xFF8A9BB0),
                          fontSize: 11,
                        ),
                        textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
                      ),
                    ),

                  // Go Deeper (if available)
                  if (answered && q.deeperContent != null)
                    GoDeeperSection(
                      content: _isAr ? (q.deeperContentAr ?? q.deeperContent!) : q.deeperContent!,
                      isAr: _isAr,
                    ),

                  // Continue button (after answering — badge+XP show on tap)
                  if (answered) ...[
                    const SizedBox(height: 20),

                    // Continue button — appears after explanation settles
                    if (_showContinueButton || _alreadyCompleted)
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                        builder: (context, opacity, child) =>
                            Opacity(opacity: opacity, child: child),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: GestureDetector(
                            onTap: _alreadyCompleted ? _continue : _completeAndPop,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.gold,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                _alreadyCompleted
                                    ? (_isAr ? 'العودة للأحداث' : 'Back to Events')
                                    : (_isAr ? 'أكمل الرحلة' : 'Continue Journey'),
                                style: GoogleFonts.nunito(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.bg,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ), // SingleChildScrollView
            ), // ScrollHintWrapper
          ),
        ),
      ),
    );
  }
}

// ── Footprint trail painter ──────────────────────────────────────────────────

/// Paints a brief reaction effect for a discovered scene secret.
/// Type 'bird': diagonal flying line. Type 'star': diagonal shooting trail.
// ── Noor HUD (Explorer Mode) ──────────────────────────────────────────────
/// Small sun icon + circular fill indicator showing the Rawi's current
/// light level. Positioned top-left during explore phase.
class _NoorHud extends StatelessWidget {
  final int noorLevel; // 0-100
  const _NoorHud({required this.noorLevel});

  @override
  Widget build(BuildContext context) {
    final fraction = noorLevel / 100.0;
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              value: fraction,
              strokeWidth: 3,
              backgroundColor: Colors.white.withAlpha(20),
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.gold.withAlpha((140 + fraction * 115).toInt().clamp(0, 255)),
              ),
            ),
          ),
          // Sun icon
          Icon(
            noorLevel > 50 ? Icons.wb_sunny_rounded : Icons.wb_sunny_outlined,
            size: 16,
            color: AppColors.gold.withAlpha((100 + fraction * 155).toInt().clamp(0, 255)),
          ),
        ],
      ),
    );
  }
}

class _SecretPainter extends CustomPainter {
  final String type;
  final double x;
  final double y;
  final double progress; // 0.0 → 1.0
  final double sceneOffset;

  _SecretPainter({
    required this.type,
    required this.x,
    required this.y,
    required this.progress,
    required this.sceneOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = x * size.width + sceneOffset;
    final centerY = y * size.height;

    // Fade out toward end
    final alpha = (255 * (1.0 - progress)).round().clamp(0, 255);

    if (type == 'bird') {
      // Bird flies diagonally up-right
      final flyX = centerX + progress * 80;
      final flyY = centerY - progress * 50;
      final paint = Paint()
        ..color = const Color(0xFF2A1810).withAlpha(alpha)
        ..style = PaintingStyle.fill;
      // Simple V shape (wings)
      final path = Path()
        ..moveTo(flyX - 6, flyY)
        ..lineTo(flyX, flyY - 4)
        ..lineTo(flyX + 6, flyY)
        ..lineTo(flyX, flyY - 1)
        ..close();
      canvas.drawPath(path, paint);
    } else if (type == 'star') {
      // Shooting star — diagonal line with fading trail
      final starX = centerX + progress * 100;
      final starY = centerY + progress * 60;
      final paint = Paint()
        ..color = const Color(0xFFFFD700).withAlpha(alpha)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(starX - 30, starY - 18),
        Offset(starX, starY),
        paint,
      );
      // Bright tip
      canvas.drawCircle(
        Offset(starX, starY),
        3,
        Paint()..color = const Color(0xFFFFD700).withAlpha(alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SecretPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _FootprintPainter extends CustomPainter {
  final List<Offset> footprints;
  final double sceneW;
  final double screenH;
  final double sceneOffset;

  _FootprintPainter({
    required this.footprints,
    required this.sceneW,
    required this.screenH,
    required this.sceneOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (footprints.isEmpty) return;

    final count = footprints.length;
    for (int i = 0; i < count; i++) {
      final fp = footprints[i];
      final screenX = fp.dx * sceneW + sceneOffset;
      final screenY = fp.dy * screenH;

      // Fade: older prints are dimmer
      final age = (count - i) / count;
      final alpha = (60 * (1 - age * 0.8)).round().clamp(8, 60);

      canvas.drawCircle(
        Offset(screenX, screenY),
        2.0,
        Paint()
          ..color = AppColors.gold.withAlpha(alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
    }
  }

  @override
  bool shouldRepaint(_FootprintPainter old) =>
      footprints.length != old.footprints.length ||
      sceneOffset != old.sceneOffset;
}
