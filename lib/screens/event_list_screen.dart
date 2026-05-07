import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../data/m1_data.dart';
import '../data/scene_configs.dart';
import '../data/threshold_challenges.dart';
import '../models/journey_event.dart';
import '../services/audio_service.dart';
import '../services/prefs_service.dart';
import '../services/route_observer.dart';
import '../widgets/constellation_view.dart';
import '../widgets/segmented_picker.dart';
import 'event_launcher.dart';
import 'legacy_event_screen.dart';
import 'threshold_screen.dart';

// ── Chapter metadata ────────────────────────────────────────────────────────

const _chapters = <JourneyEra, _Chapter>{
  JourneyEra.jahiliyyah: _Chapter('JAHILIYYAH', 'الجاهلية', 'Pre-Islamic Arabia', 'الجزيرة قبل الإسلام'),
  JourneyEra.earlyLife:  _Chapter('EARLY LIFE', 'النشأة', '570 – 610 CE', '570 – 610 م'),
  JourneyEra.mecca:      _Chapter('MECCA', 'مكة المكرمة', '610 – 622 CE', '610 – 622 م'),
  JourneyEra.medina:     _Chapter('MEDINA', 'المدينة المنورة', '622 – 632 CE', '622 – 632 م'),
};

// Module subtitle (reads from data, not hardcoded — future-proof for M2+)
const _moduleSubtitle = 'The Seerah';
const _moduleSubtitleAr = 'السيرة النبوية';

class _Chapter {
  final String name, nameAr, subtitle, subtitleAr;
  const _Chapter(this.name, this.nameAr, this.subtitle, this.subtitleAr);
}

// ── Screen ──────────────────────────────────────────────────────────────────

class EventListScreen extends StatefulWidget {
  // R25-S1-1: autoOpenEventOrder removed — the Tent Start button now
  // launches events/thresholds directly via event_launcher. Events-list
  // is only reached by explicit user action from the side nav.
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

/// R28 S1-FEAT1: which view mode the Events List is showing. Initial
/// value on open comes from `PrefsService.journeyViewDefault`
/// (configurable in Settings → Preferences → Journey view default via
/// FEAT4). Within a session the user's toggle tap is ephemeral — the
/// Settings value is the persistent default.
enum _JourneyViewMode { list, constellation }

class _EventListScreenState extends State<EventListScreen>
    with RouteAware {
  late List<JourneyEvent> _events;
  late int _currentOrder;
  final Set<JourneyEra> _expandedEras = {};
  final Set<JourneyEra> _showAllCompletedInEra = {};
  late _JourneyViewMode _viewMode;

  JourneyEra? _activeEra() {
    final activeEvent = _events.firstWhere(
      (e) => e.globalOrder == _currentOrder,
      orElse: () => _events.first,
    );
    return activeEvent.era;
  }

  @override
  void initState() {
    super.initState();
    _events = List.of(m1Events)
      ..sort((a, b) => a.globalOrder.compareTo(b.globalOrder));
    _currentOrder = PrefsService.currentOrder;
    // Expand active era by default
    final active = _activeEra();
    if (active != null) _expandedEras.add(active);

    // R28 S1-FEAT1: initial view mode from Settings preference.
    // Ephemeral within the session — user tapping the toggle doesn't
    // write back; the Settings screen is the persistent source.
    _viewMode = PrefsService.isJourneyViewConstellation
        ? _JourneyViewMode.constellation
        : _JourneyViewMode.list;

    // R27 S3-AUDIO1: events list is now part of the tent cluster —
    // the tent fire ambient carries over uninterrupted on entry. No
    // separate ambient started here (was `ambient_intro.mp3` at 0.22).
    // App-lifecycle resume is handled globally in `_RawiAppState`
    // (R27 S3-AUDIO2), so no per-screen `WidgetsBindingObserver`
    // either.
  }

  /// R27 S3-AUDIO1: subscribe to route lifecycle so we can re-ensure
  /// tent ambient when returning from an event. The event's `_exitScene`
  /// fully disposes the ambient player (`fadeOut` clears
  /// `_currentAmbientPath`), so the cluster needs someone to bring it
  /// back. Tent handles this via its own `didPopNext`; events list is
  /// the only OTHER tent-adjacent screen that can launch an event, so
  /// it mirrors the same hook.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    if (!mounted) return;
    AudioService.playAmbient(
      'assets/audio/ambient/ambient_tent_fire.mp3',
      volume: 0.14,
      fadeInDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    // R7-01: do NOT stop ambient on dispose — it carries into transition
    super.dispose();
  }

  Future<void> _refresh() async {
    // Force SharedPreferences to re-read from disk (ensures back-press saves are visible)
    await PrefsService.reload();
    if (!mounted) return;
    setState(() {
      _currentOrder = PrefsService.currentOrder;
      _showAllCompletedInEra.clear();
      // Auto-collapse all, then expand only the active era
      _expandedEras.clear();
      final active = _activeEra();
      if (active != null) _expandedEras.add(active);
    });
  }

  bool get _isAr => PrefsService.isAr;

  Future<void> _openEvent(JourneyEvent event) async {
    // R25-S1-2: tapping Start when a Threshold is pending launches the
    // threshold DIRECTLY (old code blocked with a snackbar, which left
    // the user stuck). Same shared launcher the tent uses.
    final threshold = getThresholdBefore(event.globalOrder);
    if (threshold != null &&
        !PrefsService.isThresholdCompleted(event.globalOrder)) {
      await launchThreshold(
        context,
        ThresholdItem(challenge: threshold, gatedEvent: event),
      );
      if (!mounted) return;
      _refresh();
      return;
    }

    final config = sceneConfigs[event.id];
    final hasScene = config != null;

    if (hasScene) {
      // R25-S1-1: delegate to the shared launcher so tent + list share the
      // exact same flow (video intro, noor depletion, witness moment, etc.).
      await launchEvent(context, event);
    } else {
      await Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (c, a1, a2) => LegacyEventScreen(event: event),
          transitionsBuilder: (c, a, a2, child) {
            final curved =
                CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
            return FadeTransition(opacity: curved, child: child);
          },
        ),
      );
    }

    _refresh();
  }

  // ── Build list items (events + chapter headers) ─────────────────────────

  List<Widget> _buildListItems() {
    final isAr = _isAr;
    final items = <Widget>[];
    JourneyEra? lastEra;

    // Group events by era for smart collapse
    final Map<JourneyEra, List<int>> eraEventIndices = {};
    for (int i = 0; i < _events.length; i++) {
      eraEventIndices.putIfAbsent(_events[i].era, () => []).add(i);
    }

    for (int i = 0; i < _events.length; i++) {
      final event = _events[i];
      final isLast = i == _events.length - 1;

      // Insert chapter header when era changes
      if (event.era != lastEra) {
        final chapter = _chapters[event.era];
        if (chapter != null) {
          items.add(_buildChapterHeader(chapter, event.era, isAr));
        }
        lastEra = event.era;
      }

      // Only show events if era is expanded
      if (_expandedEras.contains(event.era)) {
        final completed = PrefsService.isEventCompleted(event.globalOrder);
        final eraIndices = eraEventIndices[event.era]!;
        final completedInEra = eraIndices
            .where((idx) => PrefsService.isEventCompleted(_events[idx].globalOrder))
            .toList();
        final showAll = _showAllCompletedInEra.contains(event.era);
        final hiddenCount = completedInEra.length > 3
            ? completedInEra.length - 2
            : 0;

        // Smart collapse: hide old completed events (keep last 2 completed)
        if (!showAll && hiddenCount > 0 && completed) {
          final posInCompleted = completedInEra.indexOf(i);
          if (posInCompleted >= 0 && posInCompleted < hiddenCount) {
            // Show collapse indicator at the first hidden event
            if (posInCompleted == 0) {
              items.add(_buildCollapsedIndicator(event.era, hiddenCount, isAr));
            }
            continue; // Skip this event (collapsed)
          }
        }

        // Insert threshold marker before events that have one
        final threshold = getThresholdBefore(event.globalOrder);
        if (threshold != null) {
          items.add(_buildThresholdMarker(event.globalOrder, isAr));
        }
        items.add(_buildEventRow(event, isLast, isAr));
      }
    }

    // Bottom motivational text (R19-12: dynamic count reflecting 155 events)
    final completedCount = _events
        .where((e) => PrefsService.isEventCompleted(e.globalOrder))
        .length;
    final remaining = _events.length - completedCount;
    if (remaining > 0) {
      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text(
              isAr ? '$remaining حدثاً بانتظارك' : '$remaining events await',
              style: GoogleFonts.lora(
                color: AppColors.gold.withAlpha(60),
                fontSize: 13,
                fontStyle: isAr ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }

    return items;
  }

  // Era teasers for collapsed headers
  static const _eraTeasers = <JourneyEra, List<String>>{
    JourneyEra.jahiliyyah: ['The world before the message', 'العالم قبل الرسالة'],
    JourneyEra.earlyLife: ['Birth, guardianship, and the first signs', 'الميلاد والرعاية وأولى العلامات'],
    JourneyEra.mecca: ['The call, persecution, and perseverance', 'الدعوة والاضطهاد والصبر'],
    JourneyEra.medina: ['Migration, brotherhood, and victory', 'الهجرة والأخوّة والنصر'],
  };

  Widget _buildChapterHeader(_Chapter chapter, JourneyEra era, bool isAr) {
    final name = isAr ? chapter.nameAr : chapter.name;
    final sub = isAr ? chapter.subtitleAr : chapter.subtitle;
    final expanded = _expandedEras.contains(era);
    final eventCount = _events.where((e) => e.era == era).length;
    final teaserPair = _eraTeasers[era];
    final teaser = teaserPair != null
        ? (isAr ? teaserPair[1] : teaserPair[0])
        : null;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (expanded) {
            _expandedEras.remove(era);
          } else {
            _expandedEras.add(era);
          }
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(top: 12, bottom: 8, start: 4, end: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 24, height: 1, color: AppColors.gold.withAlpha(120)),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: GoogleFonts.nunito(
                    color: AppColors.gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  sub,
                  style: GoogleFonts.nunito(
                    color: AppColors.textMuted.withAlpha(120),
                    fontSize: 10,
                  ),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.gold.withAlpha(expanded ? 180 : 80),
                  ),
                ),
              ],
            ),
            // Preview teaser when collapsed
            if (!expanded && teaser != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 32),
                child: Text(
                  '$eventCount events · $teaser',
                  textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                  style: GoogleFonts.nunito(
                    color: AppColors.textMuted.withAlpha(80),
                    fontSize: 10,
                    fontStyle: isAr ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEventRow(JourneyEvent event, bool isLast, bool isAr) {
    final completed = PrefsService.isEventCompleted(event.globalOrder);
    // R19-09b: an event sitting just past an incomplete threshold appears
    // locked, so the user can't tap "Start" and must use the threshold card.
    final threshold = getThresholdBefore(event.globalOrder);
    final blockedByThreshold = threshold != null &&
        !PrefsService.isThresholdCompleted(event.globalOrder);
    final isNext = event.globalOrder == _currentOrder && !blockedByThreshold;
    final locked = event.globalOrder > _currentOrder || blockedByThreshold;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Timeline column (32px) ────────────────────────────────
          SizedBox(
            width: 32,
            child: Column(
              children: [
                const SizedBox(height: 14),
                // Node dot
                Container(
                  width: completed ? 12 : isNext ? 14 : 10,
                  height: completed ? 12 : isNext ? 14 : 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: completed
                        ? AppColors.gold
                        : isNext
                            ? AppColors.bg
                            : const Color(0xFF1E3040),
                    border: Border.all(
                      color: completed || isNext
                          ? AppColors.gold
                          : const Color(0xFF2A4050),
                      width: completed ? 2 : isNext ? 2 : 1.5,
                    ),
                    boxShadow: isNext
                        ? [BoxShadow(
                            color: AppColors.gold.withAlpha(40),
                            blurRadius: 8, spreadRadius: 1)]
                        : null,
                  ),
                ),
                // Vertical line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: (completed || isNext)
                          ? AppColors.gold.withAlpha(120)
                          : const Color(0xFF1E3040),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ── Event card ────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: locked ? null : () => _openEvent(event),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: completed
                        ? const Color(0xFF141E14).withAlpha(60)
                        : isNext
                            ? AppColors.gold.withAlpha(8)
                            : AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: completed
                          ? AppColors.gold.withAlpha(64)
                          : isNext
                              ? AppColors.gold.withAlpha(100)
                              : const Color(0xFF1E3040),
                      width: isNext ? 1 : 0.5,
                    ),
                    boxShadow: isNext
                        ? [
                            BoxShadow(
                              color: AppColors.gold.withAlpha(40),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Opacity(
                    opacity: locked ? 0.5 : 1.0,
                    child: Row(
                      // R27 S2-EL1: RTL mirror so the number always sits
                      // on the leading side and the status icon on the
                      // trailing side, regardless of locale.
                      textDirection:
                          isAr ? TextDirection.rtl : TextDirection.ltr,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // R27 S2-EL1: event number ALWAYS shown (was: left
                        // circle had either a tick on completed OR a
                        // number otherwise, which hid the number on
                        // completed events AND duplicated the right-side
                        // tick). Number badge is the stable identifier
                        // across all three card states; the right-side
                        // slot handles status (tick / Start / lock).
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: completed
                                ? AppColors.gold.withAlpha(20)
                                : const Color(0xFF1A2030),
                            border: Border.all(
                              color: completed
                                  ? AppColors.gold.withAlpha(64)
                                  : isNext
                                      ? AppColors.gold.withAlpha(100)
                                      : const Color(0xFF2A4050),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${event.globalOrder}',
                              style: GoogleFonts.nunito(
                                color: completed
                                    ? AppColors.gold.withAlpha(200)
                                    : isNext
                                        ? AppColors.gold
                                        : const Color(0xFF5A7A7A),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Title + subtitle + progress dots
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAr ? event.titleAr : event.title,
                                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                                style: GoogleFonts.nunito(
                                  color: locked
                                      ? const Color(0xFF5A7A7A)
                                      : const Color(0xFFE8D8B8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${isAr ? event.locationAr : event.location}  ·  ${event.year} CE',
                                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                                style: GoogleFonts.nunito(
                                  color: locked
                                      ? const Color(0xFF3A5A5A)
                                      : const Color(0xFF6A8A7A),
                                  fontSize: 11,
                                ),
                              ),
                              // R25-S2-8: per-event hotspot dots removed.
                              // The Start / Continue button label already
                              // communicates "this event has progress".
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Right side: status
                        if (completed)
                          Icon(Icons.check_rounded,
                              size: 16, color: AppColors.gold.withAlpha(140))
                        else if (isNext)
                          Builder(builder: (_) {
                            final savedProgress = PrefsService.loadHotspotProgress(event.id);
                            final hasProgress = savedProgress.isNotEmpty;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.gold,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                hasProgress
                                    ? (isAr ? 'أكمل' : 'Continue')
                                    : (isAr ? 'ابدأ' : 'Start'),
                                style: GoogleFonts.nunito(
                                  color: AppColors.bg,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          })
                        else if (locked)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock_rounded,
                                  size: 16, color: const Color(0xFF3A5A5A)),
                              const SizedBox(height: 2),
                              Text(
                                isAr ? 'أكمل السابق' : 'Complete\nprevious',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunito(
                                  color: AppColors.textMuted.withAlpha(80),
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedIndicator(JourneyEra era, int hiddenCount, bool isAr) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: GestureDetector(
        onTap: () => setState(() => _showAllCompletedInEra.add(era)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.card.withAlpha(80),
            border: Border.all(color: AppColors.divider.withAlpha(40)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.expand_more_rounded,
                  size: 16, color: AppColors.textMuted.withAlpha(140)),
              const SizedBox(width: 8),
              Text(
                isAr
                    ? '$hiddenCount أحداث مكتملة'
                    : '$hiddenCount completed events',
                style: GoogleFonts.nunito(
                  color: AppColors.textMuted.withAlpha(160),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThresholdMarker(int beforeOrder, bool isAr) {
    return _ThresholdMarker(
      beforeOrder: beforeOrder,
      isAr: isAr,
      onTap: () => _openThreshold(beforeOrder),
    );
  }

  Future<void> _openThreshold(int beforeOrder) async {
    final challenge = getThresholdBefore(beforeOrder);
    if (challenge == null) return;
    await Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (ctx, a, s) => FadeTransition(
          opacity: a,
          child: ThresholdScreen(
            challenge: challenge,
            onUnlocked: () {
              PrefsService.setThresholdCompleted(beforeOrder);
              Navigator.pop(ctx);
            },
          ),
        ),
      ),
    );
    if (!mounted) return;
    _refresh();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isAr = _isAr;
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    // B22: Events list is a secondary screen — back should pop to tent,
    // no "Exit Game" dialog. Exit confirm only applies mid-event.
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // R7-02: Cinematic desert background (matches intro/registration)
            Image.asset(
              'assets/scenes/scene_welcome.jpg',
              fit: BoxFit.cover,
            ),
            // Heavy dark overlay (~92% opacity) — readable text, subtle warmth
            Container(
              color: AppColors.bg.withAlpha(235),
            ),
            // Existing UI
            Column(
          children: [
            // ── Header ────────────────────────────────────────────────
            Container(
              padding: EdgeInsetsDirectional.fromSTEB(20, topPad + 12, 16, 16),
              decoration: BoxDecoration(
                color: AppColors.bg,
                border: Border(
                  bottom: BorderSide(color: AppColors.textMuted.withAlpha(20)),
                ),
              ),
              // B4: Events List is now a secondary screen (Tent is home).
              // Header = back-to-Tent + title. Gamification (XP/dhikr)
              // and navigation to Scroll/Map moved to the Tent.
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(8),
                        border: Border.all(
                            color: AppColors.textMuted.withAlpha(40)),
                      ),
                      // R27 S3-EVENTS-LIST1: AR must render a
                      // right-pointing arrow (RTL back semantics).
                      // Before: `isAr ? arrow_forward_ios_rounded :
                      // arrow_back_ios_new_rounded` — on device BOTH
                      // rendered as left-pointing, because the ambient
                      // `Directionality.rtl` wrapper at the app root
                      // auto-mirrors the `*_ios*` arrow glyphs (they
                      // carry `matchTextDirection: true` in the Material
                      // IconData table). The conditional picked a
                      // forward-glyph that then got flipped right back
                      // to left.
                      //
                      // Fix: use ONE fixed icon and flip it manually.
                      // `textDirection: ltr` on the Icon defeats the
                      // auto-mirror, then `Transform.scale(scaleX: -1)`
                      // in AR produces the right-pointing mirror.
                      child: Transform.scale(
                        scaleX: isAr ? -1.0 : 1.0,
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 14,
                          color: AppColors.textMuted,
                          textDirection: TextDirection.ltr,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'الأحداث' : 'Events',
                          style: GoogleFonts.cinzelDecorative(
                            color: AppColors.gold,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          isAr ? _moduleSubtitleAr : _moduleSubtitle,
                          style: GoogleFonts.lora(
                            color: AppColors.textBody,
                            fontSize: 11,
                            fontStyle: isAr
                                ? FontStyle.normal
                                : FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── R28 S1-FEAT1: LIST | CONSTELLATION segmented toggle ──
            // Sits between header and body. Centered, ~60 % screen
            // width per spec. Matches the existing SegmentedPicker
            // design language (gold border, amber-fill active).
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 14, 0, 10),
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.6,
                  child: SegmentedPicker<_JourneyViewMode>(
                    values: const [
                      _JourneyViewMode.list,
                      _JourneyViewMode.constellation,
                    ],
                    // R28 HF4-02: EN display "CONSTELLATION" (13 chars,
                    // visually unbalanced vs "LIST") → "STARS" (5 chars,
                    // matches AR "نجوم" semantics). Internal enum value
                    // stays `_JourneyViewMode.constellation` per spec —
                    // string-only rename, no routing / behaviour change.
                    labels: [
                      isAr ? 'قائمة' : 'LIST',
                      isAr ? 'نجوم' : 'STARS',
                    ],
                    selected: _viewMode,
                    onChanged: (v) => setState(() => _viewMode = v),
                    // Null = flex each segment to fill the available width.
                    segmentWidth: null,
                  ),
                ),
              ),
            ),

            // ── Body — list OR constellation based on _viewMode ─────
            Expanded(
              child: _viewMode == _JourneyViewMode.list
                  ? RefreshIndicator(
                      onRefresh: _refresh,
                      color: AppColors.gold,
                      backgroundColor: AppColors.bg,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsetsDirectional.fromSTEB(
                            12, 4, 16, bottomPad + 16),
                        children: _buildListItems(),
                      ),
                    )
                  // R28 S1-FEAT2: constellation host. Re-uses
                  // `_openEvent` so the Navigation Contract (BUG1)
                  // applies uniformly — event exit returns to tent
                  // regardless of which view launched it.
                  : ConstellationView(
                      events: _events,
                      completedCount: _events
                          .where((e) =>
                              PrefsService.isEventCompleted(e.globalOrder))
                          .length,
                      onLaunch: (event) => _openEvent(event),
                    ),
            ),
          ],
        ),
          ],
        ),
    );
  }
}

// ── Threshold marker (interactive mini-card) ────────────────────────────────

class _ThresholdMarker extends StatefulWidget {
  final int beforeOrder;
  final bool isAr;
  final VoidCallback onTap;

  const _ThresholdMarker({
    required this.beforeOrder,
    required this.isAr,
    required this.onTap,
  });

  @override
  State<_ThresholdMarker> createState() => _ThresholdMarkerState();
}

class _ThresholdMarkerState extends State<_ThresholdMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isAr;
    final currentOrder = PrefsService.currentOrder;
    final isCompleted = PrefsService.isThresholdCompleted(widget.beforeOrder);
    final isLocked = currentOrder < widget.beforeOrder;
    final isAvailable = !isLocked && !isCompleted;

    final IconData iconData = isLocked
        ? Icons.lock_rounded
        : isCompleted
            ? Icons.check_circle_rounded
            : Icons.vpn_key_rounded;

    final String title = isAr
        ? 'العَتَبة · THE THRESHOLD'
        : 'THE THRESHOLD · العَتَبة';

    final String? subtitle = isLocked
        ? null
        : isCompleted
            ? (isAr ? 'مكتمل' : 'Completed')
            : (isAr ? 'أجب لتفتح الطريق' : 'Answer to unlock the path');

    // R21-05: Use the same row layout as event rows — 32px timeline
    // column with node + line, plus full-width card. So the threshold
    // reads as a gate ON the event timeline, sized like an event card.
    Widget card = AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        final borderOpacity = isAvailable ? _pulseAnim.value : 0.6;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCompleted
                ? const Color(0xFF141E14).withAlpha(60)
                : isAvailable
                    ? AppColors.gold.withAlpha(20)
                    : AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isLocked
                  ? const Color(0xFF1E3040)
                  : isCompleted
                      ? AppColors.gold.withAlpha(64)
                      : AppColors.gold.withAlpha((255 * borderOpacity).round()),
              width: isAvailable ? 1.5 : 0.5,
            ),
            boxShadow: isAvailable
                ? [
                    BoxShadow(
                      color: AppColors.gold.withAlpha(40),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.lora(
                  color: isLocked
                      ? AppColors.textMuted.withAlpha(140)
                      : AppColors.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    color: AppColors.gold.withAlpha(140),
                    fontSize: 11,
                  ),
                  textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                ),
              ],
              if (isAvailable) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isAr ? 'ابدأ' : 'Begin',
                      style: GoogleFonts.nunito(
                        color: const Color(0xFF04060D),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );

    if (!isLocked) {
      card = GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Timeline column (32px) — matches event rows ──────────
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  const SizedBox(height: 14),
                  // Gate node — same dot vocabulary as event nodes,
                  // with the gate/key/lock icon centered inside.
                  Container(
                    width: isAvailable ? 22 : 18,
                    height: isAvailable ? 22 : 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppColors.gold
                          : isAvailable
                              ? AppColors.bg
                              : const Color(0xFF1E3040),
                      border: Border.all(
                        color: isLocked
                            ? const Color(0xFF2A4050)
                            : AppColors.gold,
                        width: isAvailable ? 2 : 1.5,
                      ),
                      boxShadow: isAvailable
                          ? [
                              BoxShadow(
                                  color: AppColors.gold.withAlpha(60),
                                  blurRadius: 8,
                                  spreadRadius: 1)
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      iconData,
                      size: isAvailable ? 12 : 10,
                      color: isCompleted
                          ? AppColors.bg
                          : isLocked
                              ? AppColors.textMuted
                              : AppColors.gold,
                    ),
                  ),
                  // Vertical line continuing the timeline.
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: isLocked
                          ? const Color(0xFF1E3040)
                          : AppColors.gold.withAlpha(120),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child:
                  isLocked ? Opacity(opacity: 0.5, child: card) : card,
            ),
          ],
        ),
      ),
    );
  }
}
