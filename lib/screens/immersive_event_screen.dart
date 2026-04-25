import 'dart:async';
import 'dart:math';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../character_art.dart';
import '../data/scene_configs.dart';
import '../models/journey_event.dart';
import '../models/scene_config.dart';
import '../feature_flags.dart';
import '../services/audio_service.dart';
import '../services/debug_log_service.dart';
import '../services/prefs_service.dart';
import '../data/rawi_dialogue.dart';
import '../models/branch_point.dart';
import '../widgets/cinematic/crossroads_card.dart';
import '../widgets/cinematic/rawi_figure.dart';
import '../widgets/reader/reader_book_sprite.dart';
import '../models/badge_definition.dart';
import '../widgets/cinematic/badge_overlay.dart';
import '../widgets/cinematic/go_deeper_section.dart';
import '../widgets/event_1_tutorial_overlay.dart';
import '../widgets/event_scene_info_tab.dart';
import '../widgets/rawi_dialog.dart';
import '../widgets/scroll_hint_wrapper.dart';
import '../widgets/top_bar_icon_button.dart';
import '../widgets/cinematic/xp_reward_animation.dart';
import '../widgets/cinematic/rawi_speech_bubble.dart';
import '../widgets/cinematic/crescent_moon.dart';
import '../widgets/cinematic/hotspot_card.dart';
import '../widgets/cinematic/hotspot_progress.dart';
import '../widgets/cinematic/grain_overlay.dart';
import '../widgets/cinematic/particle_painter.dart';
import '../widgets/cinematic/scene_hotspot_marker.dart';
import '../widgets/cinematic/birds_overlay.dart';
import '../widgets/cinematic/starfield_layer.dart';
import '../widgets/cinematic/virtual_joystick.dart';
import '../widgets/cinematic/fog_overlay.dart';
import '../widgets/settings_overlay.dart';
// R25-S3-HF-8: legacy TutorialOverlay retired — Event1TutorialOverlay
// is the sole tutorial on Event 1 now.
import 'rawi_tent_screen.dart';
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
  // R25-S3-HF-8: retained as `final false` so the two remaining guard
  // reads (idle timer, _onIdle) resolve without breaking. Legacy
  // TutorialOverlay will never set this true again.
  final bool _showTutorial = false;
  // R25-S3-7: Event 1 one-time tutorial overlay (post-intro).
  bool _showEvent1Tutorial = false;
  // _showChoiceTutorial removed — Crossroads is self-explanatory
  bool _isCompleting = false;
  bool _showContinueButton = false;

  /// R26 S1v4-EE6.2: true during the 3s fog-held + 1s quiet beat AFTER
  /// the user answers the verdict. Hides the verdict card and the dim
  /// overlay so only the revealed scene + figure remain on screen
  /// during this cinematic moment, then auto-flows into the
  /// UnifiedCompletionScreen (no "Continue" tap required).
  bool _cinematicRevealActive = false;
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

  /// R26 S1-EE2: true from the moment a proximity trigger fires
  /// (_activateHotspot entry) until the hotspot card is dismissed.
  /// Blocks BOTH joystick ticks and finger-drag updates from moving
  /// the figure while the snap-to-card handoff is in flight.
  bool _hsTriggerLocked = false;

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

  /// R26 S1v3-EE9: tap-to-trigger distance window.
  /// Walk-proximity auto-triggers when dist < 40px (`_hotspotRadius` at
  /// a typical 400-420px phone width). Inside this [40, 100] px band
  /// the user can tap the marker to finish the approach. Beyond 100px
  /// taps are still ignored — otherwise the user could bypass the
  /// walk-and-find beat entirely from anywhere on screen.
  static const double _hsTapMinPx = 40.0;
  static const double _hsTapMaxPx = 100.0;

  /// R26 S1v4-EE6.1: scene-illumination halo base unit (px). Multiplier
  /// from `noorLevel` is `(noorLevel / 25).clamp(0.5, 4.0)`, so at 60 px:
  ///   100% → 240 px, 75% → 180, 50% → 120, 25% → 60, 10% → 30 (floor).
  /// Tune on device if the 100% radius feels too big/small on the A56.
  static const double _haloBaseUnit = 60.0;

  // Speech bubble state
  String _bubbleText = '';
  bool _bubbleVisible = false;

  // Branching state (only used when _isBranching == true)
  bool _showBranchCard = false;
  BranchOption? _branchChoice;
  List<String> _branchUnlockOrder = []; // hotspot IDs in visit order
  Timer? _idleTimer;
  Timer? _hotspotHealthTimer;
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

  // R26 S1v2-EE2: 120ms ease-out snap controller. Tweens _companionX/Y
  // from the current position to the hotspot center when proximity
  // triggers. _hsTriggerLocked is already true for the duration so no
  // other input can compete with this animation.
  late final AnimationController _snapCtrl;
  double _snapStartX = 0;
  double _snapStartY = 0;
  double _snapTargetX = 0;
  double _snapTargetY = 0;

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

    // R25-S3-7: show the one-time Event 1 tutorial overlay on first
    // launch of the first event, after the intro video has completed
    // (this scene mounts AFTER VideoIntroScreen pops, so by here the
    // video is done). Never shown on events 2-155; never shown twice.
    //
    // R26 S1-TU1: trigger is deliberately locale-agnostic. No
    // `languageCode == 'en'` or similar gate — grep-verified across
    // lib/. AR + EN copy is inside Event1TutorialOverlay._spec.
    // Emitting a debug trace so future AR repro attempts produce
    // evidence of whether the overlay actually fires.
    if (widget.event.globalOrder == 1 &&
        !PrefsService.isEvent1TutorialShown) {
      _showEvent1Tutorial = true;
      DebugLogService.log('tutorial',
          'Event1 overlay armed (isAr=${PrefsService.isAr})');
    }

    // R26 S1v2-T2: write the in-progress flag at scene ENTRY (not
    // deferred to first HS discovery). Covers the "back out before
    // any HS" scenario which v1 missed — tent will read this flag
    // on didPopNext and render Continue instead of Start.
    //
    // Skipped for replays (event already completed) so revisiting a
    // completed event doesn't re-flag it as in-progress.
    if (!_alreadyCompleted) {
      PrefsService.setInProgressEvent(widget.event.id);
    }

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

    // R26 S1v2-EE2: snap animation. Duration 120ms per spec, ease-out
    // curve. Listener interpolates _companionX/Y between start and
    // target each tick; parallax recomputed on the fly.
    _snapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    )..addListener(() {
      final t = Curves.easeOut.transform(_snapCtrl.value);
      setState(() {
        _companionX = _snapStartX + (_snapTargetX - _snapStartX) * t;
        _companionY = _snapStartY + (_snapTargetY - _snapStartY) * t;
        _parallaxOffset = -(_companionX - 0.5) * 0.8;
      });
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
      // B1 root cause fix + R26 S1v3-T2.2:
      // On resume of a branching event with anchor already discovered,
      // first try to restore the user's previous choice from
      // PrefsService.getBranchChoice. If a choice is persisted, skip
      // the Crossroads and rebuild _branchUnlockOrder directly — the
      // figure can advance to whichever branch HS is next per the
      // existing discovered set. Only fall back to re-showing the
      // Crossroads if truly no prior choice is known.
      if (_isBranching &&
          widget.event.anchorHotspotId != null &&
          _discovered.contains(widget.event.anchorHotspotId) &&
          _branchChoice == null &&
          _branchUnlockOrder.isEmpty) {
        final savedTargetId =
            PrefsService.getBranchChoice(widget.event.id);
        final bp = widget.event.branchPoint;
        if (savedTargetId != null && bp != null) {
          // Re-hydrate branch state from the saved choice. The two
          // options each carry a targetHotspotId; match by that.
          final isA = savedTargetId == bp.optionA.targetHotspotId;
          final chosen = isA ? bp.optionA : bp.optionB;
          final otherHotspotId = isA
              ? bp.optionB.targetHotspotId
              : bp.optionA.targetHotspotId;
          _branchChoice = chosen;
          _branchUnlockOrder = [
            widget.event.anchorHotspotId!,
            chosen.targetHotspotId,
            otherHotspotId,
            widget.event.convergenceHotspotId!,
          ];
          if (!isA && _scene.pathWaypointsAlt != null) {
            _swapToAltPath();
          }
          debugPrint('[R26 S1v3-T2.2] Restored branch choice from prefs: '
              'eventId=${widget.event.id} chose=$savedTargetId');
        } else {
          // No prior choice persisted → legacy B1 behaviour: re-show
          // the Crossroads so the user can still make a choice.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              debugPrint('[B1] Restored Crossroads card on resume '
                  '(anchor discovered, no branch choice persisted)');
              setState(() => _showBranchCard = true);
            }
          });
        }
      }
      // R25-S3-HF-8: legacy TutorialOverlay retired. Event 1 tutorial
      // is now the sequential 3-step Event1TutorialOverlay (see
      // _showEvent1Tutorial flag, set in initState when this is event
      // 1 and the pref is unseen). Flipping the old seen flag here so
      // any reappearance of this trigger in a future branch no-ops.
      if (widget.event.globalOrder == 1 && !PrefsService.isTutorialSeen) {
        PrefsService.setTutorialSeen();
      }
      {
        _resetIdleTimer();
      }
    }
    // B1 safety net: periodic health check every 12s.
    _startHotspotHealthCheck();
  }

  /// B1 safety net: periodic silent health check that heals stuck
  /// hotspot states. Runs every 12 seconds while the event screen is
  /// alive. Detects and self-heals known stuck states:
  ///
  ///   1. `_pendingDiscovery` has entries but no active panel / branch
  ///      card — the dismiss flow didn't complete. Clear stale entries
  ///      and move them to `_discovered` so the game continues.
  ///   2. Branching event: anchor discovered, no branch choice made,
  ///      `_branchUnlockOrder` empty, and Crossroads card not showing.
  ///      Re-show the Crossroads card.
  ///   3. Linear event: `_nextHotspotId` is null but not all hotspots
  ///      are discovered — log (shouldn't happen, indicates a bug).
  ///
  /// All fixes are silent — no flicker, no reload. Logs via debugPrint
  /// so we can track if it ever fires in release builds.
  void _startHotspotHealthCheck() {
    _hotspotHealthTimer?.cancel();
    _hotspotHealthTimer = Timer.periodic(
      const Duration(seconds: 12),
      (_) => _runHotspotHealthCheck(),
    );
  }

  void _runHotspotHealthCheck() {
    if (!mounted) return;
    if (_alreadyCompleted) return;
    if (_phase != _Phase.explore) return;
    if (_activeHotspot != null) return; // user is reading a card, not stuck
    if (_showBranchCard) return; // Crossroads is up, not stuck
    if (_showSettings || _showTutorial) return;

    // Heal 1: stale _pendingDiscovery entries.
    // A hotspot in _pendingDiscovery but no active panel means the
    // dismiss flow didn't complete. Move them to _discovered.
    if (_pendingDiscovery.isNotEmpty) {
      final stale = _pendingDiscovery.toList();
      debugPrint('[B1 safety net] Healing stale pending discoveries: $stale');
      DebugLogService.log('hotspot',
          'healed stale pending discoveries: $stale (event ${widget.event.id})');
      setState(() {
        _discovered.addAll(stale);
        _pendingDiscovery.clear();
      });
      _saveProgressNow();
    }

    // Heal 2: branching event, anchor done, no choice, no crossroads.
    if (_isBranching &&
        widget.event.anchorHotspotId != null &&
        _discovered.contains(widget.event.anchorHotspotId) &&
        _branchChoice == null &&
        _branchUnlockOrder.isEmpty &&
        !_showBranchCard) {
      debugPrint('[B1 safety net] Restoring missing Crossroads card');
      DebugLogService.log('hotspot',
          'restored missing Crossroads card (event ${widget.event.id})');
      setState(() => _showBranchCard = true);
      return;
    }

    // Heal 3: linear event with null next and not all discovered.
    if (!_isBranching &&
        _nextHotspotId == null &&
        _discovered.length < _scene.hotspots.length) {
      debugPrint(
          '[B1 safety net] Linear event has null _nextHotspotId with '
          '${_discovered.length}/${_scene.hotspots.length} discovered');
      DebugLogService.log('hotspot',
          'null next id, ${_discovered.length}/${_scene.hotspots.length} discovered (event ${widget.event.id})');
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
    _hotspotHealthTimer?.cancel();
    _autoWalking = false;
    _verdictScrollCtrl.dispose();
    // _reflectionScrollCtrl removed
    WidgetsBinding.instance.removeObserver(this);
    _gameLoop.removeListener(_onFrame);
    _gameLoop.dispose();
    _figureBounceCtrl.dispose();
    _snapCtrl.dispose();
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
    // R27 S3-AUDIO2: audio (ambient, SFX, VO) is now paused + resumed
    // globally by `_RawiAppState` via `captureResumeKey` + `fadeOut` +
    // `resumeLastAmbient`. This handler only owns the scene's GAME
    // STATE — walk, joystick, idle, frame loop — which is specific to
    // the immersive screen and not something the app-root can manage.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
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
    // Absolute freeze during ANY overlay — no movement whatsoever.
    // R26 S1-EE2: _hsTriggerLocked is a sub-state of "about to show a
    // hotspot card" where _activeHotspot isn't set yet but input must
    // already be blocked so the snap holds.
    if (_activeHotspot != null || _showBranchCard || _showSettings ||
        _showBadgeOverlay || _showChapterComplete || _showXpAnimation ||
        _showTutorial ||
        _hsTriggerLocked ||
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
      final speed = _moveSpeed * joyMag * dt; // R24 #23: restored full speed

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
    // R25-S1-5: Rawi figure VO gated behind kRawiFigureVoEnabled.
    // Bubble text still shows; only the voice clip is suppressed.
    if (voPath != null && kRawiFigureVoEnabled) {
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

    // R26 S1v3-T2.2: persist the choice so resuming via tent Continue
    // doesn't re-show the Crossroads card. Cleared on event completion.
    PrefsService.setBranchChoice(event.id, selected.targetHotspotId);

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

  /// R25-S3-HF-3: Title pill in the top-bar center. Event name is the
  /// hero (14px w600 #E8D8B8); chapter/era name is the subtitle (10px
  /// gold 0.65, letter-spacing 0.5). Same scroll-like BG as the old
  /// chapter pill (rgba(10,14,24,0.55) + blur + 0.18 border) and still
  /// a plain Container — no button, no ripple.
  ///
  /// Replaces the bottom-of-scene title hero from S3-1. That position
  /// collided with scene dots, joystick, Android nav bar, and speech
  /// bubbles during device testing — doesn't hold up in practice.
  Widget _buildTitlePill() {
    // R26 S1v2-EE1: border alpha bumped 0.18 → 0.35 and width 0.5 → 0.8
    // so the pill reads as a distinct signboard against any scene art,
    // not floating text. Padding widened to 20h/10v per reference
    // screenshot. Backdrop blur kept at 6 sigma (enough to register
    // without over-softening the scene behind).
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(10, 14, 24, 0.55),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.gold.withAlpha(89), // 0.35 * 255
              width: 0.8,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _isAr ? widget.event.titleAr : widget.event.title,
                textAlign: TextAlign.center,
                textDirection:
                    _isAr ? TextDirection.rtl : TextDirection.ltr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                // R26 S1v2-EE1: title 14 → 15 per spec reference.
                style: GoogleFonts.nunito(
                  color: const Color(0xFFE8D8B8),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.event.era.label(PrefsService.language),
                textAlign: TextAlign.center,
                textDirection:
                    _isAr ? TextDirection.rtl : TextDirection.ltr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                // R26 S1-EE1: chapter subtitle now 11px italic (was 10px
                // upright). No separate "Explore the scene · N/4" pill
                // below the title — progress lives in the info-tab
                // expansion (Section 2 "THIS EVENT").
                style: GoogleFonts.nunito(
                  color: AppColors.gold.withAlpha(166), // 0.65
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
  ///
  /// R26 S1-T2: also flips the "event in progress" flag + stamps the last
  /// event ID so the tent's primary button can become Continue and route
  /// directly back to this scene.
  void _saveProgressNow() {
    if (_alreadyCompleted || _isCompleting) return;
    final allFound = _discovered.union(_pendingDiscovery);
    if (allFound.isEmpty) return;
    PrefsService.saveHotspotProgress(widget.event.id, allFound);
    PrefsService.setInProgressEvent(widget.event.id);
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
      // R26 S1-T2: stamp in-progress on every mid-event exit even if
      // no new hotspots were discovered this session (e.g., user
      // re-opened an in-progress event and backed straight out).
      await PrefsService.setInProgressEvent(widget.event.id);
    }
    AudioService.stopSfx();
    AudioService.fadeOutVoiceover(duration: const Duration(milliseconds: 200));
    AudioService.fadeOut(duration: const Duration(milliseconds: 250));
    // R28 S1-BUG1 / Navigation Contract: event exit ALWAYS returns to
    // tent, regardless of which screen launched the event (tent
    // Continue, Events List, Constellation view, future Living Map,
    // etc.). Previously a single `pop()` returned the user to the
    // caller — landing on Events List when launched from there.
    // `popUntil(withName('/tent'))` unwinds the whole stack back to the
    // tagged tent route so the user always ends up home.
    if (mounted) {
      Navigator.of(context)
          .popUntil(ModalRoute.withName(RawiTentScreen.routeName));
    }
  }

  Future<void> _saveAndExit() async {
    // Save hotspot progress before leaving (await to ensure persistence)
    if (!_alreadyCompleted && !_isCompleting) {
      final allFound = _discovered.union(_pendingDiscovery);
      if (allFound.isNotEmpty) {
        await PrefsService.saveHotspotProgress(widget.event.id, allFound);
      }
      // R26 S1-T2: same stamp as _exitScene for the settings→Save-and-exit
      // path. Tent will show Continue on next load.
      await PrefsService.setInProgressEvent(widget.event.id);
    }
    // Fade everything for smooth exit
    AudioService.stopSfx();
    AudioService.fadeOutVoiceover(duration: const Duration(milliseconds: 200));
    AudioService.fadeOut(duration: const Duration(milliseconds: 250));
    setState(() => _showSettings = false);
    // R28 S1-BUG1 / Navigation Contract: settings "Save and exit" also
    // lands on tent, same as the back-button _exitScene path.
    if (mounted) {
      Navigator.of(context)
          .popUntil(ModalRoute.withName(RawiTentScreen.routeName));
    }
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
    // R26 S1-EE2: lock input BEFORE the snap + content-reveal handoff
    // so a fast finger-drag can't continue moving the figure past the
    // hotspot marker during the 400ms window before _activeHotspot
    // gets set. Reset in _dismissPanel.
    _hsTriggerLocked = true;
    // Zero joystick + stop game loop to prevent stale movement after dismiss
    _joyDx = 0;
    _joyDy = 0;
    _gameLoop.stop();
    _gameLoop.reset();
    // R26 S1v2-EE2: 120ms ease-out tween to the hotspot center (was
    // an instant snap in v1). _hsTriggerLocked already blocks game-
    // loop + touch input for the duration so nothing competes with
    // the tween. Content card still appears 400ms after trigger,
    // giving the tween (~120ms) room to finish + ~280ms polish beat.
    final snapPos = _posFor(hotspot);
    _snapStartX = _companionX;
    _snapStartY = _companionY;
    _snapTargetX = snapPos.dx;
    _snapTargetY = snapPos.dy;
    _snapCtrl
      ..reset()
      ..forward();
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
      // R26 S1v3-EE9: tap-to-trigger when the figure is already close
      // enough to credibly "reach" the marker. The walk-proximity check
      // in _checkHotspotProximity handles dist < _hotspotRadius (~40px
      // at typical widths). Between 40–100px the user can tap the
      // marker instead of dragging the last few pixels. Beyond 100px
      // taps are ignored so the walk-and-find beat is preserved.
      final size = MediaQuery.of(context).size;
      final pos = _posFor(hotspot);
      final dxPx = (_companionX - pos.dx) * size.width;
      final dyPx = (_companionY - pos.dy) * size.height;
      final distPx = sqrt(dxPx * dxPx + dyPx * dyPx);
      if (distPx >= _hsTapMinPx && distPx <= _hsTapMaxPx) {
        _activateHotspot(hotspot);
        return;
      }
      // Still too far — return silently. User needs to walk closer.
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
    // R26 S1-EE2: release the input lock set by _activateHotspot so
    // the next movement gesture actually moves the figure again.
    _hsTriggerLocked = false;
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
        // Write immediately — crash-safe. Badge+XP shown inside Unified.
        await PrefsService.completeEvent(widget.event.globalOrder, widget.event.xpReward);
        await PrefsService.clearHotspotProgress(widget.event.id);
        // R26 S1v3-T2.2: clear branching choice so next fresh start
        // of this event (e.g., replay) shows the Crossroads card again.
        await PrefsService.clearBranchChoice(widget.event.id);
        // R26 S1-T2: event is now finalized — tent's primary button
        // returns to "Start" for the next unplayed event.
        await PrefsService.clearInProgressEvent();
        final badges = await PrefsService.checkAndAwardBadges();
        if (mounted && badges.isNotEmpty) {
          _newBadges = badges;
        }

        // R26 S1v4-EE6.2: cinematic reveal + auto-flow to Unified.
        // Replaces the old `_showContinueButton = true` tap gate — the
        // user no longer taps a Continue button to leave the scene.
        //
        // Timing (4 s total):
        //   500 ms — let the verdict card finish its dismissal animation
        //             (so the revealed scene isn't stabbed into view).
        //   3000 ms — scene held with fog fully cleared (the spec's
        //             "fog dissolves from current state to fully clear"
        //             — fog is typically already 0 from _triggerFogReveal
        //             pre-verdict, so this is a quiet 3 s scene-hold).
        //   1000 ms — final held beat, no UI overlays, just figure + BG.
        // Then `_completeAndPop()` pushes the UnifiedCompletionScreen.
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        setState(() => _cinematicRevealActive = true);
        await Future.delayed(const Duration(milliseconds: 3000));
        if (!mounted) return;
        await Future.delayed(const Duration(milliseconds: 1000));
        if (!mounted) return;
        await _completeAndPop();
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

    // R26 S1v4-EE6.3: push as a non-opaque route so this event scene
    // stays mounted behind the UnifiedCompletionScreen. The scrim +
    // cards on that screen sit over the revealed scene — spec calls
    // for the BG of the completion flow to be the same scene the user
    // just finished, not a fresh dark gradient. Unified clears both
    // routes via `pushAndRemoveUntil(tent, (r) => false)` when done,
    // so this screen is never reachable by back-nav.
    //
    // Note: `push` (not `pushReplacement`) to keep this scene alive
    // while Unified is visible. PopScope inside Unified already
    // blocks Android back until its own exit path is ready.
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (ctx, anim, sec) => FadeTransition(
          opacity: anim,
          child: UnifiedCompletionScreen(
            event: widget.event,
            xpEarned: xpEarned,
            previousXp: previousXp,
            newBadges: newBadges,
            isChapterEnd: isChapterEnd,
            alreadyCompleted: _alreadyCompleted,
          ),
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
      MaterialPageRoute(
        // R28 S1-BUG1: tag for popUntil target.
        settings: const RouteSettings(name: RawiTentScreen.routeName),
        builder: (_) => const RawiTentScreen(),
      ),
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
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // R27 S3-EVENT1: confirm before exit. Dialog gate runs BEFORE
        // `_exitScene()` so the save-and-pop path is only taken on
        // confirm — Cancel keeps all in-memory scene state
        // (hotspots visited, branching, XP, phase) untouched. Verdict
        // card + end-of-event flow have their own navigation and do
        // NOT route through this handler.
        final confirmed = await showRawiDialog(
          context: context,
          title: _isAr
              ? 'الخروج من هذا الحدث؟ تم حفظ التقدم.'
              : 'Exit event? Progress saved.',
          body: _isAr
              ? 'ستعود إلى خيمتك.'
              : 'You\'ll return to your tent.',
          cancelLabel: _isAr ? 'إلغاء' : 'Cancel',
          confirmLabel: _isAr ? 'خروج' : 'Exit',
          isAr: _isAr,
        );
        if (confirmed == true) {
          _exitScene();
        }
      },
      // R25-S3-1: clamp system text scaler to [1.0, 1.3] on the event
      // scene root (same cap as the tent in S2-7). Large accessibility
      // scaling was breaking the scene header and title overlay on the A56.
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: MediaQuery.textScalerOf(context).clamp(
            minScaleFactor: 1.0,
            maxScaleFactor: 1.3,
          ),
        ),
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
        children: [
          // R19-01b: Reader Mode background gradient (only visible where
          // ground layers don't cover; harmless when they do).
          if (!_explorerMode)
            const Positioned.fill(
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

          // ── Scene background image ────────────────────────────────────
          // Explicit width/height from screen size — Image.asset without
          // explicit dimensions was failing to render on Samsung A56
          // despite Positioned.fill / non-positioned Stack child patterns.
          // Rawi figure works because it has width: 60, height: 60 explicit.
          if (_scene.groundLayers.isNotEmpty)
            Positioned(
              left: 0,
              top: 0,
              child: Image.asset(
                _scene.groundLayers.first.assetPath,
                width: screenW,
                height: screenH,
                fit: BoxFit.cover,
              ),
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

          // ── Atmospheric overlays ───────────────────────────────────
          // THE FIX: these widgets have IgnorePointer INSIDE their own
          // build methods wrapping Positioned.fill. R22 Part 1 added a
          // redundant outer IgnorePointer which broke the inner
          // Positioned.fill (Positioned only works as a direct Stack
          // child). Removing the outer wrappers restores 333567b pattern.
          if (_scene.showStars) const StarfieldLayer(),
          if (_scene.showMoon) CrescentMoon(position: _scene.moonPosition),
          if (_scene.particleType != ParticleType.none)
            ParticleField(
                type: _scene.particleType,
                count: (_scene.particleCount *
                        (1.0 + _discoveredProgress * 0.5))
                    .round(),
                color: _scene.particleColor),
          if (_scene.showGrain) const GrainOverlay(),
          if (_scene.showBirds) BirdsOverlay(count: _scene.birdCount),

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
          // R26 S1v4-EE6.1: halo radius math — scene illumination around
          // Rawi scales as multiplier × base unit, where
          //   multiplier = (noorLevel / 25).clamp(0.5, 4.0)
          // 100% → 4x, 75% → 3x, 50% → 2x, 25% → 1x, 10% → 0.5x (floor).
          // Base unit `_haloBaseUnit` is the device-tuning knob (60 px
          // starting value per spec). HS hotspot halos are unchanged —
          // they still render at 70 px in FogOverlay itself.
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
                rawiLightRadius: _haloBaseUnit *
                    (PrefsService.noorLevel / 25.0).clamp(0.5, 4.0),
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
          if (_explorerMode && _phase == _Phase.explore)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (details) {
                  // R26 S1-EE2: the _hsTriggerLocked gate covers the
                  // snap → card-reveal window so a fast finger-drag
                  // can't push the figure past the hotspot marker
                  // while the content is about to appear.
                  if (_activeHotspot != null ||
                      _showBranchCard ||
                      _hsTriggerLocked) {
                    return;
                  }
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

          // ── Hotspot markers (Explorer only — Reader uses the bottom
          //    card, no on-scene hotspot markers). R28 S3-P1-01.
          if ((_phase == _Phase.explore || _phase == _Phase.verdict) &&
              _explorerMode)
            ..._scene.hotspots.map((h) {
              final nextHotspotId = _nextHotspotId;
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

              // R26 S1v3-EE9: tap-ready flag for the pulse hint.
              // True only when this is the next HS AND the figure
              // is inside the tap band [40, 100] px.
              bool tapReady = false;
              if (isNext) {
                final dxPx = (_companionX - hPos.dx) * screenW;
                final dyPx = (_companionY - hPos.dy) * screenH;
                final dPx = sqrt(dxPx * dxPx + dyPx * dyPx);
                tapReady = dPx >= _hsTapMinPx && dPx <= _hsTapMaxPx;
              }

              final marker = SceneHotspotMarker(
                icon: h.icon,
                label: _isAr ? h.labelAr : h.label,
                discovered: isDiscovered,
                active: isNext,
                tapReady: tapReady,
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
            }),

          // ── Rawi figure + speech bubble ─────────────────────────────
          if (_phase == _Phase.explore)
            // Reader (R28 S3-P1-09): figure scene-center horizontal, ~45 %
            // from top, scaled 0.55× with a CustomPaint book overlay at the
            // hand area. Stationary — no walk, no idle bounce. The bounce
            // controller (_figureScale) is intentionally bypassed for
            // Reader so the figure feels like a quiet reader, not a
            // hotspot-celebrating Explorer.
            // Explorer: interactive walking figure at companion position
            // with speech bubble above.
            if (!_explorerMode)
              Positioned(
                left: screenW / 2 - 34, // figure box is 68 wide
                top: screenH * 0.45 - 43, // figure box is 86 tall, 45 % from top
                child: IgnorePointer(
                  child: Transform.scale(
                    scale: 0.55,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 68,
                      height: 86,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          RawiFigure(
                            isWalking: false,
                            facingDirection: 0.0,
                            isAr: _isAr,
                          ),
                          // Book sprite at hand area (~55 % down from
                          // figure top, centered on figure midline).
                          // Size ~12 % of scaled figure height (86 * 0.12
                          // ≈ 10 px in the unscaled box → ~5.6 px visually
                          // after the 0.55× outer scale).
                          Positioned(
                            left: 68 / 2 - 13 / 2,
                            top: 86 * 0.55 - 10 / 2,
                            child: const ReaderBookSprite(
                              size: Size(13, 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            // ── Explorer: figure at companion position ──────────────
            if (_explorerMode)
              Positioned(
                left: _companionX * screenW + sceneOffset - 32,
                top: _companionY * screenH - 41,
                child: Transform.scale(
                  scale: _figureScale,
                  child: RawiFigure(
                    isWalking: _isWalking,
                    facingDirection: _facingDir,
                    isAr: _isAr,
                  ),
                ),
              ),
            // ── Explorer: speech bubble above figure ────────────────
            if (_explorerMode)
              Positioned(
                left: _companionX * screenW + sceneOffset - 60,
                top: _companionY * screenH - 100,
                child: RawiSpeechBubble(
                  text: _bubbleText,
                  visible: _bubbleVisible,
                  isAr: _isAr,
                ),
              ),

          // ── Dim overlay (non-interactive) ──────────────────────────
          // R26 S1v4-EE6.2: during the cinematic reveal beat the dim
          // overlay fades out too, so the revealed scene reads cleanly
          // for the held 4 s before the Unified screen pushes.
          if (_phase == _Phase.verdict || _phase == _Phase.complete)
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: _cinematicRevealActive
                    ? 0.0
                    : (_phase != _Phase.explore ? 0.35 : 0.0),
                duration: const Duration(milliseconds: 500),
                child: Container(color: Colors.black),
              ),
            ),

          // ── Minimal 3-element top bar ─────────────────────────────
          // [back]  [title pill, static]  [⚙ settings]
          // Back + settings use shared TopBarIconButton (36×36 pill).
          // Title pill is a plain Container — no ripple, no tap target.
          //
          // R26 S1v3-EE1: fixed-height container REMOVED. Previous
          // `height: 48 + topPad` clipped the 2-line title pill (needs
          // ~58px for 15px title + 2px gap + 11px italic chapter +
          // 20px padding). On device only the top of the pill painted,
          // which looked like "title only, no chapter, no BG pill"
          // even though the widget tree contained all three. Container
          // now sizes to its tallest child so the full pill renders.
          // Bottom padding bumped 4 → 10 for breathing room.
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(12, topPad + 6, 12, 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(128), // 0.50 alpha
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TopBarIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: _exitScene,
                  ),
                  Expanded(child: Center(child: _buildTitlePill())),
                  TopBarIconButton(
                    icon: Icons.settings_rounded,
                    onTap: _openSettings,
                  ),
                ],
              ),
            ),
          ),

          // R25-S3-1: old top-anchored title banner removed. Title now
          // renders at the bottom of the scene as a hero element
          // (see block near bottomPad).
          // R25-S3-1: old top-left _NoorHud removed. Replaced by the
          // expandable info tab widget on the left edge (S3-6).

          // ── R25-S3-6: Event-scene info tab (left edge, mid-height)
          // Collapsed = neutral info glyph; expanded = YOUR LIGHT
          // lifetime row + THIS EVENT 4-dot progress.
          //
          // R26 S1v3-EE8.2: wrap in Positioned.fill (was top: 40%, left: 0).
          // The tab widget needs full-screen bounds so the scrim it
          // paints when expanded actually covers the full scene and
          // intercepts outside taps + pans before they reach the
          // movement layer below. The tab itself still renders at 40%
          // vertical / left edge — it positions itself internally.
          if (_phase == _Phase.explore && _activeHotspot == null)
            Positioned.fill(
              child: EventSceneInfoTab(
                totalHotspots: _scene.hotspots.length,
                discoveredHotspots:
                    _discovered.length + _pendingDiscovery.length,
              ),
            ),

          // R25-S3-HF-3: scene dots at bottom — title moved to top bar
          // so dots no longer need to clear a title block above them.
          if (_phase == _Phase.explore && _activeHotspot == null)
            Positioned(
              bottom: bottomPad + 30, left: 0, right: 0,
              child: Center(
                child: HotspotProgress(
                  total: _scene.hotspots.length,
                  discovered: _discovered.length + _pendingDiscovery.length, isAr: _isAr),
              ),
            ),

          // R25-S3-HF-3: bottom-of-scene title hero removed. Event title
          // now lives in the top-bar pill next to the chapter subtitle.
          // Bottom was too crowded (dots + joystick + speech bubbles +
          // Android nav).

          // ── Virtual joystick ───────────────────────────────────────
          // B14: hide on revisit to avoid collision with replay buttons.
          // R27 S1.3-SET2: added `hidden` option — when the user picks
          // "Hide" in Settings, don't render the joystick at all. Touch-
          // to-move on the scene BG (see the Positioned.fill gesture
          // layer around line 2060) still works — this only affects the
          // joystick visual.
          if (_explorerMode && _phase == _Phase.explore
              && _activeHotspot == null && !_alreadyCompleted
              && PrefsService.joystickPosition != 'hidden')
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
                          _isAr ? 'سؤال الحدث' : 'Event Question',
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
          // B24: Event Question tooltip moved to DhikrScreen (was here
          // before; it obscured the question content).
          // R26 S1v4-EE6.2: hide the verdict card during the cinematic
          // reveal beat so only the revealed scene + figure are on
          // screen during the 4 s held moment.
          if ((_phase == _Phase.verdict || _phase == _Phase.complete)
              && !_showChapterComplete && !_showXpAnimation && !_showBadgeOverlay
              && !_cinematicRevealActive)
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

          // R25-S3-HF-8: legacy TutorialOverlay render retired. The
          // Event1TutorialOverlay below is the sole tutorial surface
          // on Event 1 now — sequential 3 steps, elegant centered
          // styling that matches the old overlay's look.

          // ── R25-S3-7: Event 1 one-time tutorial overlay ──────────
          // Shown only on the first launch of event #1, after the
          // intro video. Tap "Got it" to dismiss; flipped in prefs.
          if (_showEvent1Tutorial)
            Event1TutorialOverlay(
              onDismiss: () {
                setState(() => _showEvent1Tutorial = false);
              },
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
// R25-S3-1: _NoorHud removed. Lifetime light is now surfaced by the
// EventSceneInfoTab widget on the left edge of the scene (S3-6).

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
