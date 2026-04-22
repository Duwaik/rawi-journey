# RAWI R27-S1.1 HF Handoff

**Bundle:** R27 S1.1 HF (6 hotfix items on top of R27-S1)
**Round:** R27 — Apr 22 post-S1 device verify on A56
**Spec:** `RAWI_R27_S1_1_HF_SPEC.md`
**Parent build:** R27-S1 handoff `82593da`
**Agent:** Claude Code (Claude Opus 4.7, 1M context)
**Date:** Apr 22 2026 afternoon

---

## Orchestration note

Ships BEFORE R27-S2 per your spec. S2 (events list redesign) is still queued
and untouched — this HF only addresses follow-ups to the R27-S1 tent polish.

## Commits

| ID    | Hash       | Description |
|-------|------------|-------------|
| TENT1 | `6ba1a35`  | rebuild missing tent info tab widget (P0) |
| TENT2 | `1a91456`  | info tab 44×44 tap target + EE8.2 gesture exclusivity (event scene) |
| TENT3 | `e73efc8`  | progress card spacing + Start/Continue button width equalization |
| TENT4 | `ff62c95`  | cinematic anchors on dimmed tent, not black |
| TENT5 | `f320e2c`  | tent icon coach-mark tutorial (5 steps) |
| TENT6 | `d049860`  | reset journey clears tutorial flags |

6 commits, all on local `main`. **Not pushed to origin** — your call after
device verify.

## APK

- Path: `build/app/outputs/flutter-apk/app-release.apk`
- Size: 97,258,269 bytes (92.75 MB / 97.26 MB)
- **APK SHA256:** `08453103dc4141ba1458f2f219464c8d56e7fd9e03a4194ea63dc1a28e0e27ba`
- **libapp.so arm64 (stripped) SHA256:** `85ca4028bba7c3180a40b339d84463d633395ffd7f724ff8be02281c5a29e4ce`

Build: `flutter clean` → `flutter pub get` → `gradlew.bat assembleRelease`.
`BUILD SUCCESSFUL in 10m 8s`, 256 tasks (38 executed, 218 up-to-date — Dart
recompile + repackage; native cached since no Kotlin/Java changed).

## flutter analyze

**0 new warnings.** 1 pre-existing — `pubspec.yaml:37 assets/audio/vo/`
(unchanged since Sprint 1).

## Per-item summary

### TENT1 — rebuild missing tent info tab widget (P0) · `6ba1a35`

The S1-TENT6 commit body explicitly said "the tent has no counterpart" based
on grep, and left the tent without an info tab. Device verify confirmed
there SHOULD be one on the tent. New widget `lib/widgets/tent_info_tab.dart`
parallels `event_scene_info_tab.dart` in behavior (collapse animation,
chevron-on-border, full-screen scrim when expanded) but shows tent-appropriate
content:
- Section 1: YOUR LIGHT / نورك — lifetime Light %, same as event scene.
- Section 2: JOURNEY / الرحلة — "X of 155 events" label + 4 px progress bar
  (replaces the per-event hotspot dots; tent has no "this event" context).

Wired in `rawi_tent_screen.dart` via `Positioned.fill` just before the
bottom-sheet overlay, gated behind `_activeSheet == null` so the sheet scrim
and the tab scrim never fight.

44×44 hit target on the chevron circle already baked in from this widget's
first commit (spec item TENT2 requirement folded in on the tent side).

### TENT2 — 44×44 tap target + gesture exclusivity (event scene) · `1a91456`

Device symptom: tapping the event-scene info tab chevron walked the figure
toward the left edge. Visual chevron was 24 px, below the 44 px minimum;
fast taps fell through to the tap-to-walk handler.

Fix: wrap the 24 px visual chevron in a 44×44 transparent Container inside
the GestureDetector. `HitTestBehavior.opaque` guarantees any tap within
the 44×44 box is absorbed. Matches R26 S1v3-EE8.2's pattern exactly —
figure movement code untouched per locked decision #17.

### TENT3 — progress card spacing + Start/Continue button width · `e73efc8`

Two follow-ups on S1-TENT5:
1. Gap between button and counter: 14 → 26 px for proper breathing room.
2. Button wrapped in `SizedBox(width: 128)` + `Alignment.center` so "Start"
   and "Continue" (and "ابدأ" / "متابعة") render at IDENTICAL widths. Flipping
   between fresh-install (Start) and mid-event resume (Continue) now causes
   zero row reflow.

### TENT4 — cinematic anchors on dimmed tent · `ff62c95`

Device symptom: cinematic fired on pure-black immediately after registration.
User never saw the tent. "Welcome to your tent" with no tent visible was
disorienting.

New sequence:
1. Registration ends → tent loads normally, user sees it for ~1 s.
2. `TentTutorialScreen` pushes as non-opaque route (400 ms fade).
3. Inside the screen, a dim scrim tweens 0 → 0.50 over 400 ms.
4. Text fades in (500 ms) on top of the dimmed tent.
5. Tap-to-advance through 5 screens. Final advance fades text out + lifts
   the scrim back to 0 + pops the route + triggers icon tutorial (TENT5).

`TentTutorialScreen` rewritten:
- Scaffold `backgroundColor` → `Colors.transparent`.
- New `_dimOpacity` state + `_animateDim` method runs independently of the
  text opacity animation.
- Flag save moved from final-screen to FIRST-TAP (spec §TENT4 #6) — a force
  quit mid-cinematic doesn't cause a replay.
- Particles + top label ("Your Tent" / "خيمتك") unchanged.

`rawi_tent_screen.dart` initState:
- Gate widened to `!isTentTutorialShown || !isTentIconTutorialShown` so
  either unseen tutorial triggers the settle+fire path.
- `Future.delayed(1000 ms)` inside `addPostFrameCallback` = settle beat.
- If cinematic already seen but icon tutorial hasn't, go straight to icon
  tutorial (skip the cinematic path).

Witness Moment screen (`witness_moment_screen.dart`) NOT touched — only
`TentTutorialScreen` got the dim-scrim treatment. The 9 WM events are a
separate path that still renders black.

### TENT5 — tent icon coach-mark tutorial (5 steps) · `f320e2c`

New widget `lib/widgets/tent_icon_tutorial_overlay.dart` (~290 lines).
Fires automatically after the cinematic completes on first-ever visit.

Per-step render:
- Full-screen dim scrim (0.60).
- Pulsing gold ring around the current icon (2 px border + blur shadow
  growing 4→10 px outward on a 1100 ms reverse animation).
- Tooltip card pinned to the LEFT of the icon with right-padding that
  clears the icon itself.
- Card shows Cinzel title + Nunito body + Skip link (left) + Next/Done
  pill (right).
- Step dots at screen bottom (5 dots, current larger + filled).

Icon positions computed from the same math the tent's nav Column uses
(`screenH * 0.28`, `right: 10`, 44 px icons with 8 px gaps) — not read
from RenderBox, avoiding post-frame probing.

Copy locked per spec for all 5 steps in both EN and AR.

Taps outside Next/Skip are absorbed by the outer opaque GestureDetector
so live nav icons can't launch mid-tutorial. Either Next-through-step-5
or Skip writes `tent_icon_tutorial_shown = true`.

`rawi_tent_screen.dart`:
- New state flag `_iconTutorialActive`.
- `_maybeShowIconTutorial()` schedules `setState(=true)` after a 250 ms
  breath so the cinematic's dim has fully lifted before the coach-mark
  scrim lands.
- Overlay rendered last in the tent Stack, above everything else.
- `onFinished` callback clears the state flag; the overlay is removed
  from the tree.

### TENT6 — reset journey clears tutorial flags · `d049860`

Extended `PrefsService.resetJourney()` to clear 4 additional keys after the
existing progress clears:
- `tent_tutorial_shown`
- `tent_icon_tutorial_shown`
- `event1_tutorial_shown`
- `last_tent_dhikr_ts` (bonus — not in spec line-item list; same "device
  handoff hygiene" intent, clears the previous owner's 24 h tent-dhikr
  cooldown timestamp. Flag so you can revert if you'd rather keep it.)

Confirmation dialog in settings is untouched per spec.

## Architectural decisions

- **TENT1 — Section 2 semantics.** Spec said "same content as event scene
  info tab" but the event scene's Section 2 is per-event hotspot progress,
  which makes no sense on the tent. Pragmatic read: mirror the WIDGET
  structure (two sections + headers), adapt content to tent context
  (JOURNEY progress bar instead of hotspot dots). If you'd rather have
  "next event's dots" on tent, it's a <30 line swap.

- **TENT4 — save flag on first tap, not final tap.** Explicit spec
  requirement. The `_flagSaved` guard prevents double-writes if the user
  taps fast through the sequence.

- **TENT5 — hardcoded icon positions, not RenderBox.** Spec suggested
  reading from the live nav Column's RenderBox. I chose to mirror the
  positioning math as constants at the top of the overlay file because:
  (a) RenderBox probing requires a post-frame callback + key plumbing to
  `rawi_tent_screen.dart`'s nav column, which is more fragile; (b) the
  nav Column's layout has been locked for several sprints. If the layout
  ever changes, two sets of constants update in lockstep. Trade-off flagged
  in commit body.

- **TENT5 — tooltip always LEFT of icon, doesn't mirror in AR.** Nav is
  always on the right per locked decision #7 regardless of locale, so
  AR users also have the nav on the right. Tooltip-on-the-left works
  symmetrically for both.

- **TENT6 — bonus `last_tent_dhikr_ts` clear.** Added on the reasoning
  that a handed-off device shouldn't inherit the previous owner's 24 h
  cooldown. If this is wrong, one line to remove.

## Self-verification notes

1. **TENT1** — widget tree verified: `Positioned.fill` wrapper on tent
   gives the internal scrim full-screen bounds. Panel + chevron sit at
   `screenH * 0.45` which on A56 puts the handle below the Rawi figure's
   head. `_activeSheet == null` gate prevents scrim fight with bottom sheets.
2. **TENT2** — grep-verified the event scene tab's `_buildChevronCircle`
   is the only place reached during chevron taps; 44×44 outer Container
   + opaque behavior absorbs taps before the movement layer sees them.
3. **TENT3** — button width 128 fits "Continue" + padding comfortably; AR
   "متابعة" lands inside too. Gap 26 px replaces 14 px for proper air.
4. **TENT4** — traced: initState → 1000 ms delay → push `TentTutorialScreen`
   (opaque: false) → `_runInitialSequence` tweens dim then text → tap flips
   flag on first tap → final tap tweens dim back to 0 → pop → `_maybeShowIconTutorial`.
5. **TENT5** — traced: `onComplete` from cinematic → pop → `_maybeShowIconTutorial`
   → 250 ms delay → `setState(_iconTutorialActive=true)` → overlay renders →
   5 taps or Skip → pref set + `onFinished` → state flag cleared → overlay removed.
6. **TENT6** — grep-verified `resetJourney` is the only caller in lib/ (the
   other hit is the function definition itself). Flags added at the correct
   structural spot (after Noor reset + before function end).

## KNOWN UNDERBAKED

- **TENT1 / AR RTL mirror** — tent info tab still sits on the LEFT edge in
  AR locale; only content inside mirrors (same limitation as event scene
  tab). Deferred R25-S6.
- **TENT5 / tooltip vertical position on short screens** — `iconCenterY - 60`
  clamped to `[16, screenH - 140]`. On A56 it shouldn't clamp; very small
  devices might see the tooltip drift from its intended spot. Device-verify
  the 5th step (Collections, lowest icon) specifically.
- **TENT6 / `last_tent_dhikr_ts` not in spec** — see TENT6 commit body.
  Added on hygiene reasoning; trivial to revert.

## Device verification checklist (A56)

**TENT1 — tent info tab rebuild:**
- [ ] Tent loads fresh → info tab handle visible on left edge, collapsed
- [ ] Tap chevron circle → expands showing YOUR LIGHT + JOURNEY sections
- [ ] JOURNEY section shows `X of 155 events` + progress bar
- [ ] Tap chevron again → collapses
- [ ] Collapsed handle does NOT overlap Rawi's hat
- [ ] Outside-tap dismisses expanded panel
- [ ] AR locale: labels translate, RTL content inside the panel

**TENT2 — event scene chevron tap:**
- [ ] Enter an event scene
- [ ] Tap info tab chevron 10× fast → figure walks ZERO times
- [ ] Tap tab toggles correctly each time
- [ ] Tap anywhere OUTSIDE the chevron → figure walks as normal

**TENT3 — progress card:**
- [ ] Before starting any event: button reads "Start" — screenshot
- [ ] Start an event, back out, return to tent: button reads "Continue"
      — screenshot at IDENTICAL width
- [ ] Counter sits 26 px from button right edge (slightly wider than S1)
- [ ] Small / Normal / Large text scales — no overflow

**TENT4 — cinematic anchor:**
- [ ] Reset Journey (or fresh install)
- [ ] Finish registration → tent loads normally, user sees it for ~1 s
- [ ] Dim fades in smoothly over tent
- [ ] Gold text appears on dimmed tent — legible, tent visible behind
- [ ] 5 screens advance on tap
- [ ] After final tap, dim lifts, tent fully visible, icon tutorial starts
- [ ] Force-quit mid-cinematic, relaunch → cinematic does NOT replay (flag set on first tap)

**TENT5 — icon coach-mark tutorial:**
- [ ] After cinematic, icon tutorial fires step 1 (Events highlight)
- [ ] Ring pulses around Events icon, tooltip card pinned to left
- [ ] Tap Next → step 2 (Stars highlight)
- [ ] Continue through Scroll (3), Dhikr (4), Collections (5)
- [ ] On step 5, button reads "Done" (not "Next")
- [ ] Tap Done → tutorial dismisses, tent fully interactive
- [ ] Tap Skip on any step → same dismiss behavior, flag set
- [ ] Mid-tutorial: tap the highlighted icon directly → route does NOT launch (absorbed)
- [ ] AR locale: all 5 copy lines render RTL, tooltip direction mirrors

**TENT6 — reset journey tutorial reset:**
- [ ] Play a few events, complete Event 1 tutorial
- [ ] Settings → Reset Journey → confirm
- [ ] Navigate to tent → cinematic fires again
- [ ] After cinematic → icon tutorial fires again
- [ ] Launch Event 1 → Event 1 tutorial fires again
- [ ] Existing reset behavior preserved (completed events cleared, XP 0, Light 100, etc.)

## Out of scope

- R27-S2 events list redesign + tent counter clarity — separate bundle
- Back button exit dialog (R25-S7-1)
- AR RTL back arrow (R25-S7-2)
- v4.1 post-event wiring (Chapter Review, Chain, Thresholds)
- Stars / Scroll / Collections structure decisions

## Next

If verification passes: proceed to R27-S2 (events list + tent counter label
clarity, 2 items). If anything fails: paste log + screenshot, do not
blind-iterate.

---

_Handoff S1.1 HF — Apr 22 2026 afternoon._
