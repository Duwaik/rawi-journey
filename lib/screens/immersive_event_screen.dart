import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../data/scene_configs.dart';
import '../models/journey_event.dart';
import '../models/scene_config.dart';
import '../services/audio_service.dart';
import '../services/prefs_service.dart';
import '../data/companion_dialogue.dart';
import '../models/branch_point.dart';
import '../widgets/cinematic/branch_decision_card.dart';
import '../widgets/cinematic/companion_figure.dart';
import '../models/badge_definition.dart';
import '../widgets/cinematic/badge_overlay.dart';
import '../widgets/cinematic/go_deeper_section.dart';
import '../widgets/scroll_hint_wrapper.dart';
import '../widgets/cinematic/xp_reward_animation.dart';
import '../widgets/cinematic/companion_speech_bubble.dart';
import '../widgets/cinematic/crescent_moon.dart';
import '../widgets/cinematic/discovery_panel.dart';
import '../widgets/cinematic/discovery_progress.dart';
import '../widgets/cinematic/grain_overlay.dart';
import '../widgets/cinematic/parallax_scene.dart';
import '../widgets/cinematic/particle_painter.dart';
import '../widgets/cinematic/scene_hotspot_marker.dart';
import '../widgets/cinematic/birds_overlay.dart';
import '../widgets/cinematic/path_route_painter.dart';
import '../widgets/cinematic/starfield_layer.dart';
import '../widgets/cinematic/virtual_joystick.dart';
import '../widgets/settings_overlay.dart';
import '../widgets/tutorial_overlay.dart';

enum _Phase { explore, choose, convergenceQuestion, complete }

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
  final ScrollController _verdictScrollCtrl = ScrollController();
  final ScrollController _reflectionScrollCtrl = ScrollController(); // badge currently showing in overlay

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
  double _autoWalkTarget = 0.0;

  // Parallax offset
  double _parallaxOffset = 0.0;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isAr = PrefsService.language == 'ar';
    _alreadyCompleted =
        PrefsService.isEventCompleted(widget.event.globalOrder);
    _scene = sceneConfigs[widget.event.id]!;
    _answers = List.filled(widget.event.questions.length, null);

    _revealCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _revealAnim = CurvedAnimation(parent: _revealCtrl, curve: Curves.easeOut);

    _phaseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    // Precompute path segment lengths
    _precomputePath();

    // Set initial companion position at path start
    if (_activeWaypoints.isNotEmpty) {
      _companionX = _activeWaypoints.first.dx;
      _companionY = _activeWaypoints.first.dy;
    }

    // Game loop — only runs while joystick is active
    _gameLoop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100),
    );
    _gameLoop.addListener(_onFrame);

    if (_alreadyCompleted) {
      _phase = _Phase.complete;
      _discovered.addAll(_scene.hotspots.map((h) => h.id));
      _pathProgress = 1.0;
      _updateCompanionFromPath();
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
    if (_autoWalking) {
      _gameLoop.removeListener(_onAutoWalkFrame);
      _autoWalking = false;
    }
    _verdictScrollCtrl.dispose();
    _reflectionScrollCtrl.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _gameLoop.removeListener(_onFrame);
    _gameLoop.dispose();
    _revealCtrl.dispose();
    _phaseCtrl.dispose();
    // Stop SFX/VO immediately, fade ambient briefly for smooth exit
    AudioService.stopSfx();
    AudioService.stopVoiceover();
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
        _phase == _Phase.convergenceQuestion || _phase == _Phase.choose ||
        _phase == _Phase.complete) return;
    if (_phase != _Phase.explore) return;
    if (_autoWalking) return; // Don't mix manual + auto movement

    final joyMag = sqrt(_joyDx * _joyDx + _joyDy * _joyDy);
    if (joyMag < 0.15) return; // joystick at rest — no update needed

    // Fixed timestep for path movement
    const dt = 0.016; // ~60fps

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
  }

  // ── Speech bubble logic ──────────────────────────────────────────────────

  // ── VO Rules ──────────────────────────────────────────────────────────────
  // 1. STOP previous VO before starting any new VO
  // 2. Hotspot VO: starts 400ms after panel opens, stops on dismiss
  // 3. Branch card VO: starts 600ms after card shows, stops on option select
  // 4. Verdict question VO: starts 600ms after phase change
  // 5. Verdict explanation VO: starts 500ms after answer reveal animation
  // 6. Companion bubbles: use SFX layer (short clips, don't duck ambient)
  // 7. App pause/settings: stop ALL VO immediately

  void _showBubble(String text, {String? voPath}) {
    setState(() {
      _bubbleText = text;
      _bubbleVisible = true;
    });
    if (voPath != null) {
      // Companion bubbles are short — use SFX layer, don't duck ambient
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
    _idleTriggerCount++;
    final total = _discovered.length + _pendingDiscovery.length;
    final List<DialogueLine> lines;
    if (total == 0) {
      lines = CompanionDialogue.idleStart;
    } else if (_isNearUndiscoveredHotspot()) {
      lines = CompanionDialogue.idleNearHotspot;
    } else {
      lines = CompanionDialogue.idleMidJourney;
    }
    final lineId = CompanionDialogue.getId(lines, _idleTriggerCount);
    _showBubble(
      CompanionDialogue.get(lines, _idleTriggerCount, isAr: _isAr, name: PrefsService.userName),
      voPath: _companionVoPath(lineId),
    );
    _resetIdleTimer(); // restart for next idle cycle
  }

  bool _isNearUndiscoveredHotspot() {
    for (final h in _scene.hotspots) {
      if (_discovered.contains(h.id) || _pendingDiscovery.contains(h.id)) continue;
      final dx = _companionX - h.x;
      final dy = _companionY - h.y;
      if (dx * dx + dy * dy < 0.03) return true;
    }
    return false;
  }

  // ── Branch choice handler ──────────────────────────────────────────────────

  void _onBranchSelected(BranchOption selected) {
    AudioService.stopVoiceover(); // Rule 3: immediate stop on option select
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
    AudioService.stopAmbient();
    AudioService.stopSfx();
    AudioService.stopVoiceover();
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

  /// Header back button — saves progress and exits with audio cleanup.
  /// Mirrors the PopScope logic so there's only one exit path.
  void _exitScene() {
    // Block during unanswered Verdict or completion writes
    if (_phase == _Phase.convergenceQuestion && !_allAnswered) return;
    if (_phase == _Phase.choose && !_allAnswered) return;
    if (_isCompleting && !_alreadyCompleted) return;
    // Save hotspot progress before leaving
    if (!_alreadyCompleted && !_isCompleting) {
      final allFound = _discovered.union(_pendingDiscovery);
      if (allFound.isNotEmpty) {
        PrefsService.saveHotspotProgress(widget.event.id, allFound);
      }
    }
    AudioService.stopSfx();
    AudioService.stopVoiceover();
    AudioService.fadeOut(duration: const Duration(milliseconds: 250));
    Navigator.of(context).pop();
  }

  void _saveAndExit() {
    // Save hotspot progress before leaving
    if (!_alreadyCompleted && !_isCompleting) {
      final allFound = _discovered.union(_pendingDiscovery);
      if (allFound.isNotEmpty) {
        PrefsService.saveHotspotProgress(widget.event.id, allFound);
      }
    }
    // Fade ambient, stop SFX/VO immediately
    AudioService.stopSfx();
    AudioService.stopVoiceover();
    AudioService.fadeOut(duration: const Duration(milliseconds: 250));
    setState(() => _showSettings = false);
    Navigator.of(context).pop();
  }

  void _checkHotspotProximity() {
    if (_activeHotspot != null) return;
    if (_showBranchCard) return; // Don't trigger hotspots while branch card showing

    for (final h in _scene.hotspots) {
      final dx = _companionX - h.x;
      final dy = _companionY - h.y;
      final dist = sqrt(dx * dx + dy * dy);

      if (dist < _hotspotRadius && !_discovered.contains(h.id) && !_pendingDiscovery.contains(h.id)) {
        _activateHotspot(h);
        return;
      }
    }
  }

  // ── Auto-walk (tap-to-walk) ─────────────────────────────────────────────

  /// Find the path progress value closest to a hotspot position.
  double _pathProgressForHotspot(SceneHotspot hotspot) {
    final wp = _activeWaypoints;
    if (wp.length < 2) return _pathProgress;
    double bestProgress = 0.0;
    double bestDist = double.infinity;
    double accumulated = 0.0;
    for (int i = 0; i < wp.length - 1; i++) {
      // Check several points along each segment
      const samples = 10;
      for (int s = 0; s <= samples; s++) {
        final t = s / samples;
        final px = wp[i].dx + (wp[i + 1].dx - wp[i].dx) * t;
        final py = wp[i].dy + (wp[i + 1].dy - wp[i].dy) * t;
        final dx = px - hotspot.x;
        final dy = py - hotspot.y;
        final dist = dx * dx + dy * dy;
        final progress = (accumulated + _segLengths[i] * t) / _totalPathLen;
        if (dist < bestDist) {
          bestDist = dist;
          bestProgress = progress;
        }
      }
      accumulated += _segLengths[i];
    }
    return bestProgress.clamp(0.0, 1.0);
  }

  void _autoWalkTo(SceneHotspot hotspot) {
    if (_autoWalking) return;
    final targetProgress = _pathProgressForHotspot(hotspot);
    if ((targetProgress - _pathProgress).abs() < 0.01) {
      // Already at hotspot — activate directly
      _activateHotspot(hotspot);
      return;
    }
    _autoWalkTarget = targetProgress;
    _autoWalking = true;
    _joyDx = 0;
    _joyDy = 0;
    if (!_gameLoop.isAnimating) _gameLoop.repeat();
    _gameLoop.addListener(_onAutoWalkFrame);
  }

  void _onAutoWalkFrame() {
    if (!_autoWalking) return;
    // Same freeze guard as _onFrame — stop during ANY overlay
    if (_activeHotspot != null || _showBranchCard || _showSettings ||
        _showBadgeOverlay || _showChapterComplete || _showXpAnimation ||
        _showTutorial ||
        _phase == _Phase.convergenceQuestion || _phase == _Phase.choose ||
        _phase == _Phase.complete) {
      _stopAutoWalk();
      return;
    }
    const dt = 0.016;
    final dir = _autoWalkTarget > _pathProgress ? 1.0 : -1.0;
    final step = _moveSpeed * 0.7 * dt / _totalPathLen * dir;
    final newProgress = (_pathProgress + step).clamp(0.0, 1.0);

    final oldX = _companionX;
    _pathProgress = newProgress;
    _updateCompanionFromPath();

    final moveDx = _companionX - oldX;
    if (moveDx.abs() > 0.001) {
      _facingDir = moveDx > 0 ? 1.0 : -1.0;
    }

    setState(() => _isWalking = true);

    // Check if arrived
    if ((_pathProgress - _autoWalkTarget).abs() < 0.015) {
      _stopAutoWalk();
      _checkHotspotProximity();
    }
  }

  void _stopAutoWalk() {
    _autoWalking = false;
    _gameLoop.removeListener(_onAutoWalkFrame);
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
          AudioService.stopVoiceover(); // Rule 1: stop previous
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
          AudioService.stopVoiceover(); // Rule 1: stop previous
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
    setState(() {
      _pendingDiscovery.add(hotspot.id);
      _isWalking = false;
    });
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

  void _onHotspotTap(SceneHotspot hotspot) {
    if (_activeHotspot != null) return;
    if (_autoWalking) return; // Don't interrupt auto-walk

    final isNew = !_discovered.contains(hotspot.id) &&
        !_pendingDiscovery.contains(hotspot.id);

    // Revisit limiter — show bubble instead of panel on 3rd+ revisit
    if (!isNew && _discovered.contains(hotspot.id)) {
      final count = (_revisitCount[hotspot.id] ?? 0) + 1;
      _revisitCount[hotspot.id] = count;
      if (count >= 4) {
        final lid = CompanionDialogue.getId(CompanionDialogue.revisitFirm, count);
        _showBubble(CompanionDialogue.get(
            CompanionDialogue.revisitFirm, count, isAr: _isAr, name: PrefsService.userName),
            voPath: _companionVoPath(lid));
        return;
      } else if (count >= 3) {
        final lid = CompanionDialogue.getId(CompanionDialogue.revisitWarn, count);
        _showBubble(CompanionDialogue.get(
            CompanionDialogue.revisitWarn, count, isAr: _isAr, name: PrefsService.userName),
            voPath: _companionVoPath(lid));
        return;
      }
      // 1st-2nd revisit: re-open panel silently
    }

    // New hotspot: auto-walk the figure to it instead of instant discovery
    if (isNew) {
      // Check if this is the next active hotspot (same logic as rendering)
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
      if (hotspot.id == nextHotspotId) {
        _autoWalkTo(hotspot);
        return;
      }
      return; // Locked hotspot — ignore tap
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

  void _dismissPanel() {
    AudioService.stopVoiceover(); // Rule: immediate stop on panel dismiss
    // Short fade out (200ms) — smooth but fast enough for next hotspot
    AudioService.fadeOut(duration: const Duration(milliseconds: 200));
    final dismissed = _activeHotspot;
    setState(() {
      if (dismissed != null && _pendingDiscovery.contains(dismissed.id)) {
        _pendingDiscovery.remove(dismissed.id);
        _discovered.add(dismissed.id);
      }
      _activeHotspot = null;
    });

    // ── Branching: show branch card after anchor ────────────────────────
    if (_isBranching && dismissed != null &&
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
            AudioService.stopVoiceover();
            AudioService.playVoiceover(branchVoPath);
          }
        });
      }
      return;
    }

    if (_allDiscovered && _phase == _Phase.explore) {
      if (_isBranching) {
        // Branching mode: question renders in-scene after convergence
        // NO tutorial here — tutorial was shown at the branch card
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            setState(() => _phase = _Phase.convergenceQuestion);
            _phaseCtrl.forward();
            _playChoiceVo('q');
          }
        });
      } else {
        // Linear mode: full-screen choose overlay
        final adLid = CompanionDialogue.getId(CompanionDialogue.allDone, _discovered.length);
        _showBubble(CompanionDialogue.get(
            CompanionDialogue.allDone, _discovered.length, isAr: _isAr, name: PrefsService.userName),
            voPath: _companionVoPath(adLid));
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() => _phase = _Phase.choose);
            _phaseCtrl.forward();
            _playChoiceVo('q');
          }
        });
      }
    } else if (dismissed != null && _discovered.contains(dismissed.id)) {
      // Post-discovery nudge
      _postDiscoveryCount++;
      final pdLid = CompanionDialogue.getId(CompanionDialogue.postDiscovery, _postDiscoveryCount);
      _showBubble(CompanionDialogue.get(
          CompanionDialogue.postDiscovery, _postDiscoveryCount, isAr: _isAr, name: PrefsService.userName),
          voPath: _companionVoPath(pdLid));
    }
  }

  void _selectChoice(int qIdx, int choiceIdx) async {
    if (_answers[qIdx] != null) return;
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

  /// "Continue Journey" — layered reward flow then auto-pop.
  /// Sequence: chapter screen → badge → XP → navigate to event list.
  Future<void> _completeAndPop() async {
    // Kill any lingering ambient from the Verdict card before the reward flow
    AudioService.stopVoiceover();
    AudioService.fadeOut(duration: const Duration(milliseconds: 300));
    if (!mounted) return;

    // Step 1: Chapter completion (if last event in era)
    if (_isChapterEnd && !_alreadyCompleted) {
      final completer = Completer<void>();
      _chapterDismissCompleter = completer;
      setState(() => _showChapterComplete = true);
      await completer.future;
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 300));
    }

    // Step 2: Badge moment (if earned)
    if (_newBadges.isNotEmpty) {
      for (final badge in _newBadges) {
        if (!mounted) return;
        final completer = Completer<void>();
        setState(() {
          _showBadgeOverlay = true;
          _currentBadge = badge;
        });
        _badgeDismissCompleter = completer;
        await completer.future;
        if (!mounted) return;
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

    // Step 3: XP animation (every event)
    if (mounted && !_alreadyCompleted) {
      setState(() => _showXpAnimation = true);
      await Future.delayed(const Duration(milliseconds: 2500));
    }

    // Step 4: Auto-navigate to event list
    if (!mounted) return;
    AudioService.stopSfx();
    AudioService.fadeOut(duration: const Duration(milliseconds: 250));
    Navigator.pop(context, true);
  }

  /// Back to events for replays.
  void _continue() {
    AudioService.stopSfx();
    AudioService.stopVoiceover();
    AudioService.fadeOut(duration: const Duration(milliseconds: 250));
    Navigator.pop(context);
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
        // Block back during unanswered Verdict — user must answer + tap Continue
        if (_phase == _Phase.convergenceQuestion && !_allAnswered) return;
        if (_phase == _Phase.choose && !_allAnswered) return;
        // Block back during completion writes
        if (_isCompleting && !_alreadyCompleted) return;
        // Save hotspot progress before leaving
        if (!_alreadyCompleted && !_isCompleting) {
          final allFound = _discovered.union(_pendingDiscovery);
          if (allFound.isNotEmpty) {
            PrefsService.saveHotspotProgress(widget.event.id, allFound);
          }
        }
        // Fade ambient, stop SFX/VO immediately, then pop
        AudioService.stopSfx();
        AudioService.stopVoiceover();
        AudioService.fadeOut(duration: const Duration(milliseconds: 250));
        Navigator.of(context).pop();
      },
      child: Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Full-screen parallax scene ──────────────────────────────
          ParallaxScene(
            height: screenH,
            layers: _scene.groundLayers,
            externalOffset: sceneOffset,
          ),

          // ── Atmospheric overlays ───────────────────────────────────
          if (_scene.showStars) const StarfieldLayer(),
          if (_scene.showMoon) CrescentMoon(position: _scene.moonPosition),
          if (_scene.particleType != ParticleType.none)
            ParticleField(type: _scene.particleType,
                count: _scene.particleCount, color: _scene.particleColor),
          if (_scene.showGrain) const GrainOverlay(),

          // ── Birds overlay (Event 2) ────────────────────────────────
          if (_scene.showBirds) BirdsOverlay(count: _scene.birdCount),

          // ── Path route visualization ───────────────────────────────
          if (_phase == _Phase.explore && _activeWaypoints.length > 1)
            CustomPaint(
              size: Size(screenW, screenH),
              painter: PathRoutePainter(
                waypoints: _activeWaypoints,
                pathProgress: _pathProgress,
                screenW: screenW,
                screenH: screenH,
                sceneOffset: sceneOffset,
                discoveredCount: _discovered.length + _pendingDiscovery.length,
                totalHotspots: _scene.hotspots.length,
              ),
            ),

          // ── Footprint trail ────────────────────────────────────────
          if (_phase == _Phase.explore && _footprints.isNotEmpty)
            CustomPaint(
              size: Size(screenW, screenH),
              painter: _FootprintPainter(
                footprints: _footprints,
                sceneW: screenW,
                screenH: screenH,
                sceneOffset: sceneOffset,
              ),
            ),

          // ── Hotspot markers (all visible, sequential/branching unlock) ──
          if (_phase == _Phase.explore || _phase == _Phase.choose || _phase == _Phase.convergenceQuestion)
            ...(() {
              // Determine next hotspot ID to unlock
              String? nextHotspotId;
              if (_isBranching && _branchUnlockOrder.isNotEmpty) {
                // Branching: follow _branchUnlockOrder
                nextHotspotId = _branchUnlockOrder.firstWhere(
                  (id) => !_discovered.contains(id) && !_pendingDiscovery.contains(id),
                  orElse: () => '',
                );
                if (nextHotspotId.isEmpty) nextHotspotId = null;
              } else if (!_isBranching) {
                // Linear: sequential by hotspot list index
                final nextIdx = _scene.hotspots.indexWhere(
                    (h) => !_discovered.contains(h.id) && !_pendingDiscovery.contains(h.id));
                if (nextIdx >= 0) nextHotspotId = _scene.hotspots[nextIdx].id;
              } else {
                // Branching but no choice yet: only anchor is active
                nextHotspotId = widget.event.anchorHotspotId;
                if (_discovered.contains(nextHotspotId) || _pendingDiscovery.contains(nextHotspotId!)) {
                  nextHotspotId = null; // anchor done, waiting for branch card
                }
              }

              return _scene.hotspots.map((h) {
                final hScreenX = h.x * screenW + sceneOffset - 45;
                final hScreenY = h.y * screenH - 45;
                final isDiscovered = _discovered.contains(h.id);
                final isPending = _pendingDiscovery.contains(h.id);
                final isNext = h.id == nextHotspotId && !isDiscovered && !isPending;
                final isLocked = !isDiscovered && !isPending && !isNext;
                return Positioned(
                  left: hScreenX, top: hScreenY,
                  child: SceneHotspotMarker(
                    icon: h.icon,
                    label: _isAr ? h.labelAr : h.label,
                    discovered: isDiscovered,
                    active: isNext,
                    locked: isLocked,
                    onTap: () => _onHotspotTap(h),
                  ),
                );
              });
            }()),

          // ── Companion figure + speech bubble ────────────────────────
          if (_phase == _Phase.explore)
            Positioned(
              left: _companionX * screenW + sceneOffset - 32,
              top: _companionY * screenH - 41,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CompanionSpeechBubble(
                    text: _bubbleText,
                    visible: _bubbleVisible,
                    isAr: _isAr,
                  ),
                  const SizedBox(height: 4),
                  CompanionFigure(
                    isWalking: _isWalking,
                    facingDirection: _facingDir,
                    isAr: _isAr,
                  ),
                ],
              ),
            ),

          // ── Dim overlay ────────────────────────────────────────────
          if (_phase == _Phase.choose || _phase == _Phase.complete || _phase == _Phase.convergenceQuestion)
            AnimatedOpacity(
              opacity: _phase != _Phase.explore ? 0.35 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Container(color: Colors.black),
            ),

          // ── Header ─────────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(4, topPad + 4, 16, 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.black.withAlpha(180), Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: AppColors.textBody, size: 20),
                    onPressed: _exitScene,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.bg.withAlpha(200),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _eraColor.withAlpha(120)),
                    ),
                    child: Text(
                      '${widget.event.era.emoji}  ${widget.event.era.label(PrefsService.language)}',
                      style: GoogleFonts.nunito(color: _eraColor, fontSize: 11,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() => _isAr = !_isAr);
                      PrefsService.setLanguage(_isAr ? 'ar' : 'en');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.card.withAlpha(180),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Text(_isAr ? 'EN' : 'AR',
                          style: GoogleFonts.nunito(color: AppColors.gold,
                              fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 8),
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
            ),
          ),

          // ── Discovery progress (top, below era bar) ────────────────
          if (_phase == _Phase.explore && _activeHotspot == null)
            Positioned(
              top: topPad + 52, left: 0, right: 0,
              child: Center(
                child: DiscoveryProgress(
                  total: _scene.hotspots.length,
                  discovered: _discovered.length + _pendingDiscovery.length, isAr: _isAr),
              ),
            ),

          // ── Virtual joystick ───────────────────────────────────────
          if (_phase == _Phase.explore && _activeHotspot == null)
            Positioned(
              bottom: bottomPad + 16, left: 20,
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

          // ── Discovery panel ────────────────────────────────────────
          if (_activeHotspot != null)
            DiscoveryPanel(
              label: _isAr ? _activeHotspot!.labelAr : _activeHotspot!.label,
              fragment: _isAr ? _activeHotspot!.fragmentAr : _activeHotspot!.fragment,
              icon: _activeHotspot!.icon, isAr: _isAr, onDismiss: _dismissPanel,
              imagePath: _activeHotspot!.imagePath,
              deeperContent: _isAr ? _activeHotspot!.deeperContentAr : _activeHotspot!.deeperContent,
              voPath: _voPath(_activeHotspot!),
              centerMode: true),

          // ── The Reflection (linear events 4+) ─────────────────────
          if ((_phase == _Phase.choose || _phase == _Phase.complete) && !_isBranching
              && !_showChapterComplete && !_showXpAnimation && !_showBadgeOverlay)
            _buildChoiceOverlay(bottomPad),

          // ── The Verdict (branching events — at The Gathering) ─────
          if ((_phase == _Phase.convergenceQuestion || _phase == _Phase.complete) && _isBranching
              && !_showChapterComplete && !_showXpAnimation && !_showBadgeOverlay)
            _buildConvergenceQuestion(bottomPad),

          // ── The Crossroads (choice card after The Gate) ────────────
          if (_showBranchCard && widget.event.branchPoint != null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withAlpha(120),
                child: BranchDecisionCard(
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                              fontSize: 16,
                              fontStyle: _isAr ? FontStyle.normal : FontStyle.italic,
                              height: 1.7,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            _isAr ? 'انقر للمتابعة' : 'Tap to continue',
                            style: GoogleFonts.nunito(
                              color: AppColors.textMuted.withAlpha(140),
                              fontSize: 12,
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
            margin: EdgeInsets.fromLTRB(16, 60, 16, bottomPad + 16),
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
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header + VO replay
                    Row(
                    children: [
                      Expanded(
                        child: Text(
                          _isAr ? 'ماذا يحفظ التاريخ؟' : 'What does history remember?',
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
                            AudioService.stopVoiceover();
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
                            AudioService.stopVoiceover();
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
                                padding: const EdgeInsets.only(left: 8),
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
                                  _isAr ? 'يسجّل التاريخ...' : 'History records...',
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
                          child: ElevatedButton(
                            onPressed: _alreadyCompleted ? _continue : _completeAndPop,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _alreadyCompleted
                                  ? AppColors.card
                                  : AppColors.gold,
                              foregroundColor: _alreadyCompleted
                                  ? AppColors.textMuted
                                  : AppColors.bg,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: Text(
                              _alreadyCompleted
                                  ? (_isAr ? 'العودة للأحداث  ←' : 'Back to Events  →')
                                  : (_isAr ? 'أكمل الرحلة  ←' : 'Continue Journey  →'),
                              style: GoogleFonts.nunito(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
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

  // ── The Reflection (linear events — old Moment of Reflection) ───────────────

  Widget _buildChoiceOverlay(double bottomPad) {
    final event = widget.event;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      bottom: 0, left: 0, right: 0,
      top: MediaQuery.of(context).size.height * 0.2,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.black.withAlpha(0), Colors.black.withAlpha(230),
              Colors.black.withAlpha(250)],
            stops: const [0.0, 0.12, 0.3],
          ),
        ),
        child: ScrollHintWrapper(
          controller: _reflectionScrollCtrl,
          child: SingleChildScrollView(
            controller: _reflectionScrollCtrl,
            padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPad),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.menu_book_rounded, size: 12, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(child: Text(event.source,
                    style: GoogleFonts.nunito(
                        color: AppColors.textMuted.withAlpha(160),
                        fontSize: 11, height: 1.4))),
              ]),
              const SizedBox(height: 20),
              if (event.questions.isNotEmpty)
                _buildChoiceCards(),
              // Continue button — appears after answering (both first time + replay)
              if (_allAnswered) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: _alreadyCompleted ? _continue : _completeAndPop,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _alreadyCompleted ? AppColors.card : _eraColor,
                      foregroundColor: _alreadyCompleted ? AppColors.textMuted : AppColors.bg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0),
                    child: Text(
                      _alreadyCompleted
                          ? (_isAr ? 'العودة للأحداث  ←' : 'Back to Events  →')
                          : (_isAr ? 'أكمل الرحلة  ←' : 'Continue Journey  →'),
                      style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700,
                          letterSpacing: 0.5)),
                  ),
                ),
              ],
            ],
          ),
        ), // SingleChildScrollView
        ), // ScrollHintWrapper
      ),
    );
  }

  Widget _buildChoiceCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(widget.event.questions.length, (qIdx) {
        final answered = _answers[qIdx] != null;
        final prevAnswered = qIdx == 0 || _answers[qIdx - 1] != null;
        if (!prevAnswered) return const SizedBox.shrink();

        final q = widget.event.questions[qIdx];
        final question = _isAr ? q.questionAr : q.question;
        final options = _isAr ? q.optionsAr : q.options;
        final explanation = _isAr ? q.explanationAr : q.explanation;
        final isCorrect = _answers[qIdx] == q.correctIndex;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_isAr ? 'ماذا كنت ستفعل؟' : 'What would you do?',
                style: GoogleFonts.lora(color: _eraColor.withAlpha(200),
                    fontSize: 14,
                    fontStyle: _isAr ? FontStyle.normal : FontStyle.italic,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text(question,
                style: GoogleFonts.cinzelDecorative(
                    color: AppColors.textPrimary, fontSize: 16, height: 1.45),
                textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr),
            const SizedBox(height: 20),
            ...List.generate(options.length, (i) {
              final isSelected = _answers[qIdx] == i;
              final isCorrectOpt = i == q.correctIndex;
              Color borderColor, bgColor, textColor;
              if (!answered) {
                borderColor = AppColors.gold.withAlpha(50);
                bgColor = AppColors.card.withAlpha(200);
                textColor = AppColors.textPrimary;
              } else if (isCorrectOpt) {
                borderColor = _eraColor;
                bgColor = _eraColor.withAlpha(22);
                textColor = AppColors.textPrimary;
              } else if (isSelected) {
                borderColor = AppColors.divider.withAlpha(90);
                bgColor = AppColors.bg;
                textColor = AppColors.textMuted;
              } else {
                borderColor = AppColors.divider.withAlpha(60);
                bgColor = AppColors.bg;
                textColor = AppColors.textMuted.withAlpha(140);
              }
              return GestureDetector(
                onTap: () => _selectChoice(qIdx, i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: bgColor, borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor,
                        width: answered && isCorrectOpt ? 1.5 : 1.0),
                  ),
                  child: Row(children: [
                    Expanded(child: Text(options[i],
                        style: GoogleFonts.nunito(color: textColor, fontSize: 14,
                            fontWeight: FontWeight.w600, height: 1.4),
                        textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr)),
                    if (answered && isCorrectOpt)
                      Padding(padding: const EdgeInsets.only(left: 8),
                        child: Icon(Icons.check_circle_rounded,
                            color: _eraColor, size: 18)),
                  ]),
                ),
              );
            }),
            if (answered) ...[
              const SizedBox(height: 4),
              FadeTransition(opacity: _revealAnim,
                child: SlideTransition(
                  position: Tween<Offset>(
                      begin: const Offset(0, 0.06), end: Offset.zero)
                      .animate(_revealAnim),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isCorrect ? _eraColor.withAlpha(14) : AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isCorrect
                          ? _eraColor.withAlpha(80) : AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(isCorrect ? Icons.brightness_3_rounded
                              : Icons.auto_stories_rounded,
                              size: 13, color: AppColors.gold),
                          const SizedBox(width: 7),
                          Text(isCorrect
                              ? (_isAr ? 'يسجّل التاريخ...' : 'History records...')
                              : (_isAr ? 'ما يسجّله التاريخ...' : 'What history records...'),
                              style: GoogleFonts.nunito(color: AppColors.gold,
                                  fontSize: 11, fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6)),
                        ]),
                        const SizedBox(height: 10),
                        Text(explanation,
                            style: GoogleFonts.lora(color: AppColors.textBody,
                                fontSize: 13,
                                fontStyle: _isAr ? FontStyle.normal : FontStyle.italic,
                                height: 1.7),
                            textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  // _buildContinueButton removed — Continue button now inline in both Verdict and Reflection
}

// ── Footprint trail painter ──────────────────────────────────────────────────

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
