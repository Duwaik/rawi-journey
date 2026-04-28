import 'package:flutter/widgets.dart';

/// R28 HF3 · Shared GlobalKey registry for tutorial-target widgets.
///
/// Tutorial overlays (`Event1TutorialOverlay`, `TentIconTutorialOverlay`)
/// pull each spotlight / arrow target's live screen position via the
/// matching key's RenderObject + `localToGlobal`, replacing the
/// hardcoded screen-fraction math that drifted whenever a target widget
/// moved or resized (see HF3-INFO1 + HF3-TUT1 commit messages).
///
/// One key per target. Keys are static so any widget tree can attach
/// to the same target without prop-drilling.
class TutorialKeys {
  TutorialKeys._();

  // ── Event-scene targets ───────────────────────────────────────────

  /// The left-edge (LTR) / right-edge (RTL) info-tab circle in an
  /// event scene. Target of `Event1TutorialOverlay`'s `leftMid`
  /// pointer (HF3-INFO1).
  static final GlobalKey eventInfoTab =
      GlobalKey(debugLabel: 'tutorial.eventInfoTab');

  // ── Tent right-side nav targets (5 active + 1 settings) ──────────
  // HF3-TUT1 attaches each. The placeholder Living Map slot still
  // gets a key — the tutorial highlights it so the user knows the
  // slot exists, even though it's a "coming soon" non-target.

  static final GlobalKey tentEvents =
      GlobalKey(debugLabel: 'tutorial.tentEvents');
  static final GlobalKey tentScroll =
      GlobalKey(debugLabel: 'tutorial.tentScroll');
  static final GlobalKey tentCollections =
      GlobalKey(debugLabel: 'tutorial.tentCollections');
  static final GlobalKey tentDhikr =
      GlobalKey(debugLabel: 'tutorial.tentDhikr');
  static final GlobalKey tentLivingMap =
      GlobalKey(debugLabel: 'tutorial.tentLivingMap');
  static final GlobalKey tentSettings =
      GlobalKey(debugLabel: 'tutorial.tentSettings');

  /// Tent's collapsed info-tab variant (mirrors event-scene's, but
  /// at the tent's lowered position). HF3-TUT1 step pointing at
  /// "Tap for help / Light status" uses this.
  static final GlobalKey tentInfoTab =
      GlobalKey(debugLabel: 'tutorial.tentInfoTab');
}
