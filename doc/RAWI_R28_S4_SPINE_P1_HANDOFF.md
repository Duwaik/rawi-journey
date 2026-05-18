# RAWI R28-S4-SPINE-P1 Handoff — Stars view: alternating-spine continuous scroll

**Bundle:** R28-S4-SPINE-P1 (6 items, S4S-01..06 — sequential, each its own commit)
**Spec:** `RAWI_R28_S4_SPINE_P1_SPEC-17May2026-1745.md` v2 (Downloads, 17 May)
**Base:** `origin/main @ 3517fb5` (HF6 — last pushed tip)
**Replaces:** local-only year-paged R28-S4-P1 (hard-reset away; archived tag `r28-s4-p1-archive` → `b92c27d`)
**Agent:** Claude Code (Claude Opus 4.7, 1M context)
**Date:** 18 May 2026

---

## Build verification block

```
BUILD COMPLETE - R28-S4-SPINE-P1
- flutter clean: confirmed
- APK size: 93.16 MB
- libapp.so SHA256: 2880c9b3d26354011a1e90ee142a2d68cb1c54177f5e425320bf6de030ab8681
- Changed from previous build: YES
```

`Changed: YES` — confirms all 6 SPINE-P1 items compiled into the APK. `libapp.so` moved off the HF6 baseline `aaf2327df1e81d59dbe386317a1fa7fd2c75b887b746369bc18b981906a1b5ee` → `2880c9b3d26354011a1e90ee142a2d68cb1c54177f5e425320bf6de030ab8681`. APK 93.16 MB vs HF6's 93.38 MB — ~0.22 MB **smaller** (expected: SPINE-P1 net-removed ~947 lines of HF6 InteractiveViewer/cluster-painter code and replaced it with leaner widgets; zero asset changes; well within the ±1 MB tolerance). Fresh `flutter clean` → `assembleRelease` (10m 27s) → `verify_build.py`.

- **flutter analyze:** 0 errors, 0 warnings from SPINE-P1 (clean between every commit). The single project-wide warning (`asset directory 'assets/audio/vo/' doesn't exist`, pubspec.yaml:37) is **pre-existing** — present verbatim on the HF6 baseline `3517fb5`; `pubspec.yaml` was not touched by SPINE-P1 (`git diff 3517fb5..HEAD --name-only` = 6 files, no pubspec).
- **Tests:** 29/29 passing (`flutter test`).
- **verify_build.py:** ✅

---

## Commits

| Item | Hash | Description |
|---|---|---|
| — | `ef23150` | chore: gitignore `.claude/scheduled_tasks.lock` (harness runtime artifact) |
| S4S-01 | `e8474e4` | vertical bottom-to-top spine-scroll architecture |
| S4S-02 | `a3e8948` | central gold spine line with year-marker gaps |
| S4S-03 | `3ddfc80` | EventNode — alternating L/R dot + branch + label |
| S4S-04 | `0240bb2` | YearMarker — boxed on-spine year (Option 2) |
| S4S-05 | `cd601a3` | scroll-to-current + scroll-position persistence |
| S4S-06 | `8d69a82` | event tap routing (HF6 lift; locked → no-op) |

6 SPINE items, one commit each per spec §"One change per build". Plus one unrelated hygiene chore (`ef23150`) — see deviation flag 6. `flutter analyze` clean at every commit.

---

## Pre-flight (spec P-1 / P-2) — done

- **P-1:** `git tag r28-s4-p1-archive` (→ `b92c27d`, the year-paged exploration), `git reset --hard origin/main` → HEAD = `3517fb5` (HF6), `flutter clean` + `pub get`.
- **P-2:** baseline HF6 `assembleRelease` + `verify_build.py --sprint "HF6-baseline-check"` → `libapp.so aaf2327d…`, `Changed: NO` (correctly interpreted: the reset reproduced HF6's libapp byte-for-byte, confirming a clean baseline before any SPINE work).

---

## Per-item summary

### S4S-01 · spine-scroll architecture · `e8474e4`
`lib/widgets/constellation_view.dart` fully rewritten (−947/+150). `ColoredBox(0xFF060810) → SafeArea(top:false) → SingleChildScrollView(controller, BouncingScrollPhysics, NOT reverse:true) → SizedBox(totalHeight) → Column([endPad, …reverse-chrono children, endPad])`. `_buildLayout()` iterates `events.length-1 → 0` (newest child first → renders top), inserts the year marker immediately **after** the chronologically-first event of each year (= the lowest visual position of that year), and returns `(children, gapTops, totalHeight)`. Constants `_eventSpacing=70`, `_yearMarkerHeight=30`, `_endPadding=40`. Class name + constructor unchanged → host `event_list_screen.dart` needs **zero edits** (verified: full-project `flutter analyze` clean, host compiles against the new widget untouched).

### S4S-02 · central spine · `a3e8948`
New `lib/widgets/spine_painter.dart`. `SpinePainter extends CustomPainter`: one 1.5px vertical stroke at `size.width/2`, gold `#D4A017` @ alpha 140 (~0.55), drawn as the **complement** of the year-marker gap ranges (sorted gapTops, cursor sweep, clamped to canvas). Coordinate contract: canvas (0,0) == content top-left, so painter-Y == layout-Y; each gap = `[gapTop, gapTop+30]`. Wired into the host via a `Stack` with the painter in a `Positioned.fill` **behind** the event Column (z-order: dots paint on top in S4S-03).

### S4S-03 · EventNode · `3ddfc80`
New `lib/widgets/event_node.dart`. Dot held exactly on the spine X by a symmetric `Expanded | fixed-16px-slot | Expanded` row (label length can never drift the dot off-spine). Branch 18px × 1.3px gold @ alpha 140. Alternation keyed off the **chronological** index (`chronoIndex % 2`) so an event keeps a fixed side across the bottom-to-top reversal. State visuals via `EventNodeState` (`_stateFor` from `completedCount`): completed = solid `#D4A017` 5px + cream label + HF6 ring accent; active = brighter `#E8C854` 6px + full-white w600 label; locked = `#D4A017` a102 (~0.4) + cream a128 (~0.5). `GestureDetector(HitTestBehavior.opaque)` over the full 70px row ⇒ hit target ≫ spec's ≥44px square.

### S4S-04 · YearMarker · `0240bb2`
New `lib/widgets/year_marker.dart`. 76×22 box centred in the 30px host slot, 1.2px gold border, `BorderRadius.circular(2)`, bold 12px gold `"$year CE"`, `letterSpacing: 0.48` (spec 0.04em × 12px). Opaque fill = exact scaffold bg `#FF060810` → clean spine break with no peek-through even on a 1px gap/box misalignment. Non-interactive by construction (no GestureDetector → tap falls through to the scroll view).

### S4S-05 · scroll-to-current + persistence · `cd601a3`
`PrefsService`: + `lastConstellationScrollOffset` (double, −1.0 sentinel) + `lastConstellationSavedAtCompletionCount` (int, −1 sentinel), existing key+getter idiom. `_buildLayout` also returns `eventCenterY {chronoIndex → content-Y}`; cached in `build()` for the post-frame entry callback. `_positionOnEntry()` (one-shot via `_didInitialScroll`): restores the saved offset iff a save exists AND `savedCount ≥ live` (no event completed since the save); else centres the current event (`centerY − viewport/2`), `jumpTo` (instant, no flicker), clamped `[0, maxScrollExtent]`. `_currentEventIndex` = `completedCount` clamped to `[0, len-1]` (folds in spec's none-started → first / all-done → last). Completion invalidation: clear-prefs on the re-centre path **and** in `didUpdateWidget` when the host pushes a new `completedCount`. Save via `NotificationListener<ScrollEndNotification>` (deviation flag 4).

### S4S-06 · tap routing · `8d69a82`
`_buildLayout`: `onTap: state == locked ? null : () => widget.onLaunch(events[i])` — lifted **verbatim** from HF6 `_handleStarTap@3517fb5` (`widget.onLaunch(widget.events[idx])` for completed||current; identical route, method, argument). Navigation Contract preserved. Locked = silent no-op (deviation flag 5).

---

## Spec-deviation flags (per spec §"Reasoned deviations welcome — flag transparently")

1. **Spec file path corrected.** Spec says `lib/screens/constellation_view.dart`; the real file at HF6 baseline is `lib/widgets/constellation_view.dart`. All work targeted the actual path. No code impact — flagged for spec accuracy.
2. **Spec's 4-row state table → codebase's 3-state model.** Spec S4S-03 lists Locked / Available / Completed / Active. HF6's progression model (the single source of truth, `completedCount`) has no "available-but-not-current" state — the current event *is* the available one; HF6 `_handleStarTap` only ever distinguished completed / current / locked. So "Available" and "Active" collapse onto `EventNodeState.active`. Documented in `event_node.dart` doc-comment + `_stateFor`. Faithful reconciliation, not a behaviour change.
3. **S4S-05 PrefsService API shape.** Implemented as an atomic `setLastConstellationScroll(offset, count)` + `clearLastConstellationScroll()` rather than two independent setters. The spec specifies the *stored data* (the two keys), not the method signatures; atomic write prevents a half-written state stranding a restore on the wrong completion count.
4. **S4S-05 save mechanism.** Spec says "debounced listener on `ScrollController.position`"; implemented as `NotificationListener<ScrollEndNotification>`. Same intent (persist the *resting* position), fires exactly once on scroll-rest, timer-free, Flutter-idiomatic. The one-shot guard flips true *after* `jumpTo` so the programmatic jump's own synchronous ScrollEndNotification is never persisted — only genuine user scrolls save.
5. **S4S-06 locked = silent no-op (spec-aligned, noted for clarity).** HF6's `_LockedInfoCard` is intentionally **dropped** for the spine design (spec S4S-06: "no-op or subtle feedback, no navigation"). Locked passes `onTap: null` → the opaque GestureDetector is a true no-op.
6. **`dart format` + the gitignore chore.** `dart format` applied to `constellation_view.dart` only (the whole file is SPINE-P1 code); **not** applied to `prefs_service.dart` (shared 652-line file — the +36 addition follows the existing idiom; blanket-formatting would bloat the diff for zero gain — same diff-pragmatism precedent as HF6-02). Separately, `.claude/scheduled_tasks.lock` (a stale harness scheduler lock, not project config) was surfacing as untracked noise → gitignored in chore commit `ef23150`. Out of the spec's item list but a clean-tree hygiene fix; flagged here per the rule.
7. **⚠️ Phase 1 UX is intentionally limited — NOT feature-complete.** Per the standing phased-handoff instruction: P1 (S4S-01..06) ships structure, spine, nodes, year markers, scroll-to-current + persistence, and tap routing **in EN only**. Deferred to **P2** (separate spec, not yet written): **S4S-07** AR locale parity (RTL label rendering, alternation visual mirror; spine/year-box stay centred — vertical direction is locale-agnostic) and **S4S-08** first-entry tutorial overlay ("Scroll up to journey through time"). EventNode/YearMarker already accept/ignore `isAr` cleanly so P2 is additive, not a rework.

---

## Regression watch (spec §"Regression watch")

- **HF6-01** (Stars pan + zoom) — **N/A by design.** No InteractiveViewer, no pinch-zoom, no horizontal pan in the spine design (the entire HF6 render surface was replaced; preserved in git @ `3517fb5` + tag `r28-s4-p1-archive`).
- **HF6-02** (SafeArea — first event behind Android nav) — **preserved.** `SafeArea(top:false)` retained around the scroll view with the same rationale (Events List header + LIST/STARS toggle already own the status-bar inset). Bottom inset still applies → 570 CE (timeline bottom) sits above the nav region. **A56 verify owed** (see below).
- **HF6-03** (Living Map compass) — N/A, different screen, untouched.
- **Living Map BL-02** (Medina cluster density) — addressed structurally by alternating L/R + continuous scroll (no page boundaries).

---

## Khaled-side verify (A56) — owed

Spine design is **visual-first**; the agent has no A56, so these need eyes on device:

1. **Direction:** scroll to the very bottom → 570 CE (Year of the Elephant) is the oldest, sitting **above** the Android nav bar (HF6-02 not regressed). Scroll to the very top → 632 CE (newest). Scrolling **up** advances forward in time.
2. **Spine:** continuous gold line down the centre, end-to-end, with a clean gap at every year box — no spine peek-through behind/through a box, no overlap.
3. **Nodes:** all 155 events render, alternating L/R, consistent side per event; labels don't collide with the spine or each other; completed / active / locked visually distinct (active brighter + larger).
4. **Year boxes:** one per year at the chronologically-first-event boundary, breaking the spine cleanly; the bottom-most marker is 570 CE.
5. **Entry centring:** new user → lands on 570 CE centred; mid-progress (e.g. event 30) → event 30 centred, older below / newer above; no entry flicker (jump before paint).
6. **Persistence:** scroll away, leave screen, return → lands at the saved position. Complete an event, return → re-centres on the new current event (saved offset cleared).
7. **Tap:** available/active/completed → opens the event via the existing route (Navigation Contract: exit → tent). Locked → nothing happens (no card, no nav). Year box → nothing.
8. **AR:** P1 is EN-only by design (deviation flag 7) — AR labels will render but **without** RTL mirroring/locale-formatted years; that is S4S-07/P2, not a bug.

---

## Branch state

7 commits ahead of `origin/main` (`3517fb5`): 6 SPINE-P1 items + 1 gitignore chore, + this handoff commit. **Push gate held by Khaled.** No agent push. After A56 verify clean, Khaled pushes `R28-S4-SPINE-P1` to `origin/main`; then the **P2 spec** (S4S-07 AR + S4S-08 tutorial) is written.

Untracked and intentionally left alone: `assets/audio/ambient/ambient_tent_fire.mp3` (not added by SPINE-P1, not in scope — flagged so it isn't mistaken for an omission).

---

_Handoff written 18 May 2026. Spec sequencing followed S4S-01→06, one commit per item, analyze-clean throughout. 7 reasoned deviations flagged above — none silent. P1 UX is deliberately partial (EN-only, no tutorial); P2 is additive._
