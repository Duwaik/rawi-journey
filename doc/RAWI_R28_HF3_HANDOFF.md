# RAWI R28-HF3 Handoff — 7-item polish batch

**Bundle:** R28-HF3 (7 items, all MINOR per Apr 19 build-cycle rule — cosmetic / copy / off-position / wrong-number-displayed / lifecycle polish, none break flow). Single combined build at the end.
**Spec:** `RAWI_R28_HF3_SPEC-27Apr2026-1730.md` (Downloads)
**Source:** A56 device verify on 27 Apr (R28-S1 + S2 + S3 P1 + HF1 + HF2 verify export `27Apr2026-1144` + HF1 verify pass)
**Parent build:** R28-HF2 handoff `a3fc70e`
**Agent:** Claude Code (Claude Opus 4.7, 1M context)
**Date:** Apr 27 2026 ~17:30 Amman

---

## Branch state at this HF

HF1 device-verified Apr 27 (Intro Cinematic + Registration ✅; Settings node functionally verified, mark left at user discretion).
HF2 device-verified clean Apr 27.
HF3 lands as 7 commits on top of that stack. Push gate stays held until HF3 verifies clean — then full bundle pushes in one shot.

---

## Commits

| ID                | Hash       | Description |
|-------------------|------------|-------------|
| HF3-DIALOG1       | `682582a`  | drop "(your progress is saved)" line from tent exit dialog |
| HF3-LMAP1         | `2dbc32f`  | Living Map placeholder reads as outline, not black bar |
| HF3-INFO1         | `9b21fd1`  | info-tab tutorial arrow uses live RenderBox |
| HF3-TUT1          | `fc295fc`  | tent tutorial step list reflects current nav |
| HF3-CONST1        | `cc0d2fb`  | bump same-year cluster stagger 22 → 32 px |
| HF3-PROG1         | `2392702`  | progress card shows current event index, not completed count |
| HF3-HOT1          | `9e40856`  | prime hotspot proximity on first paint, kill the dead zone |

7 items, 7 commits. `flutter analyze` clean between every commit (1 pre-existing baseline `audio/vo/` directory warning, unchanged from HF2). `flutter test` 29/29 pass.

---

## APK

- Path: `build/app/outputs/flutter-apk/app-release.apk`
- Size: 97,782,557 bytes (93.25 MB / 97.78 MB) — +81,920 bytes over R28-HF2 (new `tutorial_keys.dart` + rewritten `tent_icon_tutorial_overlay.dart` + comment additions)
- **APK SHA256:** `930d19b73fa41e7b777323279c06fcf8c67998d9141db1515781e55ffbd811a0`
- **libapp.so arm64 (stripped) SHA256:** `d7b3fd5eadb3e2dfad5c9e2494972b3662dbdcba1c11fe862635dbdc7e8f153c`

`libapp.so` hash moved from R28-HF2's `0d04c03991805606759ac6f61f099d815462591d2f049ef3aa74263919b46010`
→ R28-HF3's `d7b3fd5eadb3e2dfad5c9e2494972b3662dbdcba1c11fe862635dbdc7e8f153c` ✓

APK hash moved from R28-HF2's `2a14aa03eee8efed32dd085c845409f496cbf326f451142ebfb14aea5c525fd2`
→ R28-HF3's `930d19b73fa41e7b777323279c06fcf8c67998d9141db1515781e55ffbd811a0` ✓

Build: `flutter clean` → `flutter pub get` → `cd android && gradlew.bat assembleRelease`. Single APK for the whole 7-item batch per the Apr 19 locked build-cycle rule.
`BUILD SUCCESSFUL in 15m 7s`.

---

## Per-item summary + diagnostic findings

### HF3-DIALOG1 · drop "(your progress is saved)" line · `682582a`

Owner copy decision (Apr 27). The parenthetical reassurance line under "Exit app?" is gone. Dialog now renders title + Cancel/Exit only.

`lib/widgets/rawi_dialog.dart` — `body` parameter changes from `required String` to `String?`. When null or whitespace-only, the body Text + its 14 px top spacer are skipped via a conditional spread. Other 4 callers (settings reset confirm, settings reset journey button, registration back-confirm, immersive event exit-confirm) pass a body string and are unaffected.

`lib/screens/rawi_tent_screen.dart` — exit dialog call site drops the `body:` argument.

**Diff: 22 +, 14 −. flutter analyze clean.**

### HF3-LMAP1 · Living Map placeholder reads as outline · `2dbc32f`

A56 verify: tent's 5th nav slot rendered as a "black bar." R28-S1-NAV1's first-pass styling used translucent black fill (alpha 120) + faint gold border (alpha 20) + dim icon (alpha 115). On the dark scene BG the black fill blended into the background and the icon was too dim to anchor the silhouette.

`lib/screens/rawi_tent_screen.dart` `_navIconPlaceholder` — re-balanced fill / border / icon so the slot reads as an outlined-ghost button: fill `Colors.black.alpha 120 → AppColors.gold.alpha 10`, border `gold.alpha 20 → gold.alpha 70 width 1.2`, icon `gold.alpha 115 → gold.alpha 150`. Same 44 px frame, same compass icon, same snackbar-on-tap behaviour.

**Diff: 26 +, 9 −. flutter analyze clean.**

### HF3-INFO1 · info-tab tutorial arrow uses live RenderBox · `9b21fd1`

A56 verify: `Event1TutorialOverlay`'s `leftMid` pointer hardcoded `top: size.height * 0.40 + 4, left: 44`. Pre-R27-S1.4 layout — info tab was 14 px in a smaller circle at ~0.40 × screen height. Post-S1.4 + R27-S3-INFO1 the circle is 42 px at 0.45 × screen height, so the arrow landed in empty space ~5 % too high.

**New file `lib/widgets/tutorial_keys.dart`** — shared `GlobalKey` registry for tutorial-target widgets. One key per target, all static. Seeds keys for HF3-TUT1 (tent nav slots + settings + tent info-tab) too.

`lib/widgets/event_scene_info_tab.dart` — `_buildInfoCircle()` attaches `key: TutorialKeys.eventInfoTab` to the 42 px circle Container.

`lib/widgets/event_1_tutorial_overlay.dart` — `_buildPointer` for `leftMid` replaced with RenderBox lookup + AR-aware side detection (mid-point test on screen X). Falls back to corrected static math (`size.height * 0.45 + 18, left: 60`) for the first-frame race. `addPostFrameCallback` in initState forces one rebuild after layout so the lookup sees a laid-out target.

**Diff: 95 +, 4 − (3 files). flutter analyze clean.**

### HF3-TUT1 · tent tutorial step list reflects current nav · `fc295fc`

A56 verify: tutorial drifted off targets — step 2 still pointed at "Stars" (Stars retired in R28-S1-CODE1) so steps 2-5 cascaded one slot off the actual nav.

Full step-list rewrite to S1.5-TUT2 pattern (live RenderBox + `localToGlobal` via shared `TutorialKeys`). Six spotlights total:

  1. Events           (`tentEvents`,      roundedRect)
  2. Rawi's Scroll    (`tentScroll`,      roundedRect)
  3. Collections     (`tentCollections`, roundedRect)
  4. Living Map       (`tentLivingMap`,   roundedRect)
  5. Info tab         (`tentInfoTab`,     circle)
  6. Settings         (`tentSettings`,    circle)

Stars step removed (no widget). Dhikr step removed (Dhikr screen has its own first-open tutorial flag — doesn't need a tent mention; nav slot stays in the tent UI). Living Map placeholder stays in the tutorial highlight list per spec — even though "coming soon," users should know the slot exists.

`lib/screens/rawi_tent_screen.dart` — three nav-helper signatures (`_navIcon`, `_navIconMaterial`, `_navIconPlaceholder`) gain optional `Key? key` param attaching to inner Container. 5 nav slots + Living Map placeholder + settings gear (34 px Container) all pass their `TutorialKeys.tentXxx` keys.

`lib/widgets/tent_info_tab.dart` — `_buildInfoCircle()`'s 42 px Container takes `key: TutorialKeys.tentInfoTab`. Mirror of HF3-INFO1's pattern.

`lib/widgets/tent_icon_tutorial_overlay.dart` — full rewrite. Drops the static-math constants (`_navTopFraction`, `_navIconSize`, `_infoTabSize`, `_gearTopInset`). `_resolveTargetRect` looks up `step.targetKey.currentContext?.findRenderObject()` and returns the live rect; falls back to a small off-screen-ish placeholder if the target hasn't laid out yet. `_resolveAnchor` picks tooltip side from rect midpoint vs screen midpoint — right-side nav → tooltip on left, left-edge info tab → tooltip on right, top-bar gear → tooltip below. Self-corrects in AR locale because `localToGlobal` returns actual screen coords regardless of ambient Directionality.

**Diff: 182 +, 166 − (3 files). flutter analyze clean.**

### HF3-CONST1 · bump cluster stagger 22 → 32 px · `cc0d2fb`

A56 verify: 570 CE region (Year of the Elephant + Birth + Halimah's Nursing) showed labels overlapping. R28-S1-FEAT3's stagger algorithm IS correct for 3+ events (symmetric `(k - (clusterSize-1)/2.0) * clusterStaggerY` distribution), but `clusterStaggerY = 22.0` was too tight — chosen as the minimum needed to fit a 10 px title + 7 px date stacked, with no margin for diacritics, ascenders, or text-scale inflation.

`lib/widgets/constellation_view.dart` — bump `clusterStaggerY` from 22 → 32 px. ~10 px of clear daylight between adjacent labels (was ~2-5 px). The symmetric formula stays unchanged so single-event-per-year rendering, the diagonal cluster shape, the X spread, and year-axis label alignment all carry over.

Spec §"Fix" prefers vertical stagger over horizontal jitter or on-tap clustering. 32 px clears the 570 CE case at default font scale; if Large text scale still overlaps, next escalation is X-spread reduction (visually tighter "stack") rather than horizontal jitter (the spec warns reads as "different year").

Carry-forward note added to the comment so the future port (when Stars retires entirely and Events List → CONSTELLATION becomes the only host) preserves both the formula and the constant.

**Diff: 16 +, 6 −. flutter analyze clean.**

### HF3-PROG1 · progress card shows current event index, not completed count · `2392702`

**Diagnostic finding:** the regression is NOT actually from HF1 — `git log -L 760,770:lib/screens/rawi_tent_screen.dart` shows the formula `'$completed / ${m1Events.length}'` has been in place since **R27-S1.4-PROG1** (`d4c7f9a`, "progress card number — remove 'Completed' word, add gold-outlined container"). HF1's two commits (`34e6a1b` RESET + `8c1469e` INTRO) didn't touch the tent screen at all.

What HF1 DID do was make fresh-install state newly reachable on a live device (via `prefs.clear()`), which exposed the count vs index mismatch:
- Fresh post-Reset: completedCount = 0 → "0/155" with title "Arabia Before the Light" (Event 1). User reads "I haven't started anything yet" — looks fine.
- After Event 1 done: completedCount = 1 → "1/155" with title "Year of the Elephant" (Event 2). User reads as N-1 vs the title.

Spec §Item-7 wants the pill to show the **current event INDEX** (what Start/Continue is about to launch), not the count of events the user has finished.

`lib/screens/rawi_tent_screen.dart` line 765 — formula change:
```dart
// before
'$completed / ${m1Events.length}'
// after
'${(completed + 1).clamp(1, m1Events.length)} / ${m1Events.length}'
```

The `clamp` covers the journey-fully-complete edge: when `completed == m1Events.length`, `completed + 1` would be 156, clamped to 155 so the pill stays "155/155".

Stat row at `_buildInfoTabStatRows` line 997 still renders `$completed` (count semantics — "you've completed X events", labeled "Events" / "الأحداث") unchanged.

**Diff: 22 +, 1 −. flutter analyze clean.**

### HF3-HOT1 · prime hotspot proximity on first paint · `9e40856`

**Diagnostic finding:** hypothesis C from spec §HF3-HOT1 (proximity auto-snap state not initialized → tap rejected), with one additional observation the spec didn't list — proximity OPACITY also wasn't primed, so the next-hotspot marker rendered at opacity 0 on the very first frame.

The path: tap → `SceneHotspotMarker` GestureDetector at line 2150 → `_onHotspotTap(h)` → for `isNew` hotspots in Explorer mode the distance check at lines 1407-1417 gates activation:
- `distPx < _hsTapMinPx` (40 px): silently rejected
- `distPx >= _hsTapMinPx && distPx <= _hsTapMaxPx` (40-100 px): activate
- `distPx > _hsTapMaxPx` (100 px+): silently rejected

The other proximity path (`_checkHotspotProximity` at line 1157) auto-snaps when `dist < _hotspotRadius` (0.09 of screen width = ~32 px on A56). Snap only fires if the function is CALLED.

Pre-fix, `_checkHotspotProximity` + `_updateHotspotProximity` were called only from movement handlers (game-loop tick, touch-to-move pan-update, path advance). On fresh entry the figure spawned at its initial waypoint, neither helper had been called, and:

1. The next hotspot's marker rendered with `_hotspotProximityOpacity[h.id] ?? 0.0` — invisible.
2. If the figure spawned within `_hotspotRadius` (~32 px) of a hotspot, auto-snap SHOULD have activated but didn't.
3. If the figure spawned at 32-40 px (the **dead zone** between auto-snap and tap activation), the first tap on the near-invisible marker hit the line 1412 distance gate and was rejected silently. User would tap, see nothing, drag the figure → next tap fires the proximity helper → auto-snap or marker glow → tap works. "Intermittent."

Fix: `WidgetsBinding.instance.addPostFrameCallback` in `initState` calls both proximity helpers exactly once after first paint completes. `MediaQuery` is valid by then; companion + hotspot positions are laid out. Auto-snap fires if applicable; otherwise the next marker gains its proper glow opacity.

`DebugLogService.log` line at the start of the callback emits the companion position + next hotspot id to the always-on B27 overlay. If A56 still surfaces misses, the log line gives evidence for the next iteration without needing logcat.

Per spec §HF3-HOT1: "Don't add a frame-blocking listener attach that delays first paint." `addPostFrameCallback` runs AFTER first paint — no first-paint penalty.

**Diff: 44 +, 0 −. flutter analyze clean.**

---

## Self-verify checklist (per spec §"Self-verify checklist")

- [x] All 7 items implemented in ONE combined build (APK SHA `930d19b7…`)
- [x] APK size delta vs HF2 baseline non-zero (+81,920 B)
- [x] `libapp.so` arm64 SHA256 moved from HF2's `0d04c039…` → `d7b3fd5e…`
- [x] `flutter analyze` returns 0 warnings (1 pre-existing baseline `audio/vo/` directory warning, unchanged from HF2)
- [x] No partial landings — every item has a commit + working code
- [x] No changes outside scope:
  - BG art frozen ✓
  - Figure movement frozen ✓
  - Audio service untouched (HF2's caller-stack instrumentation stays; nothing else moved) ✓
  - S1.4 verified items untouched (info tab styling, etc.) ✓
  - HF1/HF2 acceptance preserved (Reset full-wipe still runs, AR intro punctuation fix still active, ambient resume on event-completion still works) ✓
- [x] Per-item commits with `R28 HF3-<item>:` prefix
- [x] `flutter test`: 29/29 pass (17 arc_registry + 5 branching + 6 reader_phase1 + 1 smoke)
- [x] Walked all 7 acceptance lists via code inspection (per-item summaries above)
- [ ] Push to local branch only (do NOT push to origin/main — Khaled holds push gate until full bundle device-verifies clean)

---

## Two-strike candidates flagged in spec

If A56 verify finds residue on these items, the spec rules require **diagnostic instrumentation** before attempt #2 (no theoretical guesses):

1. **HF3-HOT1** — DebugLogService.log line shipped in this commit prints companion position + next hotspot id at scene mount. If misses persist, that overlay output is the next iteration's evidence.
2. **HF3-PROG1** — current single-source-of-truth (`final completed = _completedCount` at line 337) means no cross-screen state drift can split the value. If pill still shows N-1, log `_completedCount` + the formula's input + output at render time before re-coding.
3. **HF3-INFO1** + **HF3-TUT1** — RenderBox lookups have a static fallback for first-frame race. If arrows / spotlights still drift, log `currentContext`'s `findRenderObject()` result + size at the resolve site before adjusting fallback math.

---

## Branch state at handoff

After this commit, the branch is **43 commits** beyond `origin/main`:

```
[handoff]   this commit
9e40856  R28 HF3-HOT1:    prime hotspot proximity on first paint
2392702  R28 HF3-PROG1:   progress card shows current event index
cc0d2fb  R28 HF3-CONST1:  bump same-year cluster stagger 22 → 32 px
fc295fc  R28 HF3-TUT1:    tent tutorial step list reflects current nav
9b21fd1  R28 HF3-INFO1:   info-tab tutorial arrow uses live RenderBox
2dbc32f  R28 HF3-LMAP1:   Living Map placeholder reads as outline
682582a  R28 HF3-DIALOG1: drop "(your progress is saved)" line
a3fc70e  R28-HF2:         handoff doc (tent ambient resume)
…HF2 + HF1 + R28-S3 P1 + R28-S2 + R28-S1 + R27-S3 commits…
```

**Push gate stays held.** Per spec §"Self-verify checklist" last bullet: push to local branch only. Khaled walks all 7 items on A56; full bundle clears to push origin/main when verify lands clean.

---

## Self-verify (per-item code-inspection acceptance)

A56 device-walk owed by owner. Code-inspection verdict per item:

| # | Item | Code-inspection verdict |
|---|------|---|
| 1 | HF3-DIALOG1 | Body parameter optional, tent call site drops body, conditional spread skips Text + spacer when null/blank ✓ |
| 2 | HF3-LMAP1 | Three colour tokens moved (fill, border, icon); same 44 px frame + same snackbar behaviour ✓ |
| 3 | HF3-INFO1 | GlobalKey on info-tab circle; tutorial overlay's `_buildPointer` uses live RenderBox + AR-aware side detection + first-frame fallback ✓ |
| 4 | HF3-TUT1 | Six steps wired to TutorialKeys; static-math constants gone; `_resolveTargetRect` + `_resolveAnchor` use live RenderBox ✓ |
| 5 | HF3-CONST1 | `clusterStaggerY` 22 → 32 px; symmetric formula intact; carry-forward note added ✓ |
| 6 | HF3-PROG1 | Formula `(completed + 1).clamp(1, m1Events.length) / m1Events.length`; stat row count semantics preserved ✓ |
| 7 | HF3-HOT1 | postFrameCallback fires both proximity helpers; debug log line at scene mount; no first-paint blocking ✓ |

---

_Handoff written Apr 27 2026 ~17:30 Amman. R28-HF3 is the third hotfix in the R28 stack. When A56 verify lands clean across all 7 items, the full 43-commit bundle clears to push origin/main in one shot — R27-S3 + R28-S1 + R28-S2 + R28-S3 P1 + HF1 + HF2 + HF3 all in one push._
