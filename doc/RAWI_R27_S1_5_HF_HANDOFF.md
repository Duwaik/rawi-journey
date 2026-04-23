# RAWI R27-S1.5 HF Handoff

**Bundle:** R27 S1.5 HF — Polish round: registration + tent first-experience
**Round:** R27 — Apr 23 follow-up to S1.4 device verify
**Spec:** `RAWI_R27_S1_5_HF_SPEC.md`
**Parent build:** R27-S1.4 HF handoff `c7a1f7d`
**Agent:** Claude Code (Claude Opus 4.7, 1M context)
**Date:** Apr 23 2026

---

## Commits

| ID    | Hash       | Description |
|-------|------------|-------------|
| REG1  | `4b1ecc9`  | age picker — fix two-digit number soft-wrap (itemExtent 44 → 64) |
| AUDIO1| `72f29d8`  | tent ambient fade-in / fade-out envelopes (no more hard cuts) |
| INFO1 | `e530800`  | info icon enlarged past chevron (no overlap) |
| TUT1  | `7c9c0bd`  | tutorial "Tap to continue" — legibility bump |
| TUT2  | `775af4c`  | coach-mark highlight — placement + shape |
| PROG1 | `674dd3b`  | Start/Continue button + #/155 pill — height parity |

## APK

- Path: `build/app/outputs/flutter-apk/app-release.apk`
- Size: 97,274,653 bytes (92.77 MB / 97.27 MB)
- **APK SHA256:** `ee933496d0061437f2e7b7e3328e92affd13ec0f55bc0af54b8376736e42ab0c`
- **libapp.so arm64 (stripped) SHA256:** `ea91e18ea30706bbc60ab532b7b55aa6addcc9d4ce15ef56d7df591ef6575b4f`

`libapp.so` hash moved from S1.4's `90511a2e10161a1ee6ec5e4d517875036499610ae220e93eee53fced582dc365`
→ S1.5's `ea91e18ea30706bbc60ab532b7b55aa6addcc9d4ce15ef56d7df591ef6575b4f` ✓

Build: `flutter clean` → `flutter pub get` → `gradlew.bat assembleRelease`.
`BUILD SUCCESSFUL in 19m 9s`.

## flutter analyze

**0 new warnings.** 1 pre-existing (`pubspec.yaml:37 assets/audio/vo/`).

## Per-item summary

### REG1 — age picker two-digit wrap fix · `4b1ecc9`

S1.4 `RotatedBox(quarterTurns: 3)` rotation turned `itemExtent`
(originally vertical per-item height) into the horizontal per-slot
width after rotation. At 44 px, two-digit numbers at the selected
font size (34 px Cinzel w700) soft-wrapped to two lines — "20"
rendered "2" stacked on "0".

- `itemExtent` 44 → 64
- `maxLines: 1` + `softWrap: false` added to each item's Text as
  a belt-and-suspenders guard against future regressions or
  accessibility text-scale drift.

Everything else from S1.4-REG1 preserved.

### AUDIO1 — ambient fade envelopes · `72f29d8`

S1.4 resumed the tent ambient on return but hard-cut both the
start and stop. Now enveloped on both edges.

`AudioService.playAmbient` extended:
- New optional `fadeInDuration` param (defaults `Duration.zero`
  so existing callers are unaffected).
- Same-path short-circuit: if `fadeInDuration > 0`, ramps current
  player's volume via `fadeAmbientTo`. Handles rapid return
  (tent → nav → back) cleanly — the player was faded down by
  the tent's `didPushNext` and now ramps back to target.
- Fresh start: starts at volume 0, calls `play()`, then
  `fadeAmbientTo(volume, duration)`.

Tent screen changes:
- `_startTentAmbient` now passes `fadeInDuration: 300ms` for both
  the fire path and the fallback intro.
- New `didPushNext` override fires when user navigates AWAY from
  tent. Calls `fadeAmbientTo(0.0, 300ms)` — player stays alive at
  volume 0, next `didPopNext` ramps it back up.
- `didPopNext` unchanged — still calls `_startTentAmbient()`,
  which now internally fades.

Overlap protection: `fadeAmbientTo`'s existing `_ambient != player`
check (line 85) aborts any fade if the player was swapped mid-fade.
For rapid tent↔nav bouncing with the same player, parallel fades
on the same target converge safely.

Audio files + preload logic untouched.

### INFO1 — info icon past chevron · `e530800`

Device verify on S1.4: info icon circle (44 px) and chevron circle
(42 px at panel right border) visually overlapped in [41, 53] on
an x-axis — 12 px of collision, info "partially hidden."

Geometry rework:
- `_collapsedWidth` 62 → 90 (both widgets).
- Info circle 44 → 52 px (10 px larger than chevron per spec's
  "at least 4-6 px larger" rule).
- Info glyph 28 → 32 px (scales proportionally).
- `Align(Alignment.centerLeft)` wraps the info Container so it
  hugs the panel's leading edge, leaving the chevron space clear
  on the right.

New layout:
- Info: center x=35, spans [9, 61]
- Chevron visual: center at panel right border (x=90), spans [69, 111]
- Gap 8 px, no overlap, info dominates.

Chevron (S1.3-TENT1, 42 px, `right: -44`) untouched per owner
decision ("enlarge info, don't shrink chevron").

### TUT1 — "Tap to continue" legibility · `7c9c0bd`

Hint was rendering at effective α ≈ 0.28 on the warm tent BG —
present but unreadable.

- Outer Opacity: `_opacity * 0.7` → `_opacity` (dropped the 70 %
  damper while keeping the screen fade-in envelope).
- Color alpha: 100 → 230 on the gold text.

Effective α at full fade now ≈ 0.90 — legible without being loud.
Font size unchanged per spec ("legibility is the goal, not prominence").

### TUT2 — coach-mark placement + shape · `775af4c`

Two bugs.

**Placement (info tab step):** pre-S1.5 the highlight centered on
`screenH * 0.45` with size 42 — matching the CHEVRON geometry,
not the info icon. The info icon is actually inside the panel
at `panel_top + 9 px padding`, so the spotlight sat ~31 px above
the real icon AND on the chevron's position.

Fix: compute from the actual info-icon geometry.
- `top = screenH * 0.45 + 9`
- `left = 9` (panel padding, info hugs left)
- size = 52 (matches S1.5-INFO1)

Constants renamed for semantic clarity: `_infoTabSize`,
`_infoTabPanelTopFraction`, `_infoTabPanelPadding`, `_infoTabLeftInset`.

**Shape:** pre-S1.5 used `shortestSide / 2` uniformly — circle for
all targets. Correct for the 52 × 52 info and the 34 × 34 gear,
but the right-side nav icons are 44 × 44 CONTAINERS with
BorderRadius 12 (rounded-rect, not circle).

Fix: per-target radius. `navIcon → 12 + extra`, `infoTab` and
`settingsGear → shortestSide/2 + extra`.

### PROG1 — height parity · `674dd3b`

Button ≈ 34 px (padding 9 + text 13 w800), pill ≈ 29 px (padding 6
+ text 14 w700). ~5 px baseline offset.

Both Containers now:
- Fixed `height: 40`
- `alignment: Alignment.center`
- Vertical padding dropped (redundant with fixed height); only
  horizontal padding retained on the pill for chrome breathing room.

Button width 128 px (S1.1-TENT3) unchanged.

## Architectural decisions

- **REG1 — itemExtent 64.** Measured against "99" at the 34 px
  selected font + 8-12 px padding. Left headroom for potential AR
  numeral variants; current render uses Latin digits regardless
  of locale.

- **AUDIO1 — backward-compatible API extension.** Added optional
  parameter rather than a new `playAmbientWithFadeIn` method so
  the existing 10+ callers (event scene, dhikr, etc.) keep their
  current behaviour without any edit.

- **INFO1 — widen panel, not shrink chevron.** Spec owner decision
  locked this direction — info is primary, chevron is secondary.
  Widening the panel keeps the chevron at its current 42 px /
  border-straddling position.

- **TUT2 — computed math, not RenderBox lookup.** Spec suggested
  `GlobalKey + findRenderObject + localToGlobal` for per-target
  run-time geometry. I kept computed-math because (a) the tent
  layout constants haven't changed in several sprints, (b) plumbing
  GlobalKeys from the tent screen through to the overlay widget
  is a significant refactor. If the tutorial drifts from reality
  a second time, escalate to render-box mode per spec's two-strike
  rule.

- **PROG1 — height 40 fixed, not driven by intrinsic content.**
  Intrinsic-heights are what caused the baseline drift. Fixed 40
  locks the layout; may clip at extreme accessibility scales
  (flagged below). If that bites, the two-strike move is
  `maxLines: 1 + overflow: ellipsis` on both texts before
  revisiting the height constant.

## Self-verification

1. **REG1** — itemExtent 64 ≥ "99" @ 34 px + padding. `maxLines: 1`
   + `softWrap: false` prevents wrap even if extent drifts.
2. **AUDIO1** — traced all 3 paths:
   - fresh: vol 0 → `fadeAmbientTo(0.14, 300ms)`
   - same-path re-entry: `fadeAmbientTo(0.14, 300ms)` from current
     (which may be 0 after `didPushNext`)
   - different-path + fadeIn: fadeOut previous 200 ms → vol 0 →
     fadeAmbientTo target
3. **INFO1** — math: info [9, 61] vs chevron [69, 111] = 8 px gap.
   Verified mentally on paper.
4. **TUT1** — effective α went 0.28 → 0.90 at full fade (0.7 * 0.39
   → 1.0 * 0.90). Eyeball test: clearly legible on both black and
   amber mental BG samples.
5. **TUT2** — info tab highlight top was `screenH*0.45 - 21`, now
   `screenH*0.45 + 9`. Delta = 30 px down, which matches the
   observed "too high" offset.
6. **PROG1** — both Containers now `height: 40`, `alignment: center`,
   zero vertical padding competing.

## KNOWN UNDERBAKED

- **PROG1 / text scale 1.3:** accessibility scale pushes the 14 px
  pill text rendered height above 40 px. Clips. Fallback: add
  `maxLines: 1 + overflow: ellipsis` before bumping height.
- **TUT2 / GlobalKey escalation path:** if the overlay drifts again
  on the info tab or any other target, next pass should plumb
  GlobalKeys from tent to overlay per spec's two-strike rule.
- **AUDIO1 / fade overlap on rapid bounce:** two parallel
  `fadeAmbientTo` calls on the same player race. The existing
  `_ambient != player` abort covers player-swap. For same-player
  parallel fades, last-one-to-finish wins. Should be imperceptible
  at 300 ms but might produce a volume blip if user bounces
  tent↔nav within ~100 ms.

## Device verification checklist (A56)

**REG1:**
- [ ] Swipe through full age range (4 → 99)
- [ ] All values — single-digit (4-9), double-digit including 20/40/60/80/90 — render on ONE line
- [ ] Peripheral + selected positions both fit

**AUDIO1:**
- [ ] Fresh launch → tent → fire fades IN smoothly (no pop)
- [ ] Tent → Events List → ambient fades out during transition
- [ ] Back to tent → fire fades IN (no hard restart)
- [ ] Repeat for Stars, Scroll, Dhikr, Collections, Settings
- [ ] Rapid bounce (tent → events → tent within 2s): no artifacts, no stacked ambients

**INFO1:**
- [ ] Tent info tab: info icon circle LARGER than chevron, clearly dominant
- [ ] No visual overlap between info and chevron
- [ ] Event scene info tab: identical treatment
- [ ] Rawi's hat not obscured (vertical position `screenH * 0.45` unchanged)
- [ ] Both tap targets still work (info + chevron)

**TUT1:**
- [ ] Reset Journey → tent cinematic fires
- [ ] "Tap to continue" clearly legible on every cinematic step
- [ ] Doesn't draw eye away from the main title text

**TUT2:**
- [ ] Reset Journey → walk all 7 tutorial steps
- [ ] Nav icons (steps 1-5): rounded-rect spotlights matching card shape
- [ ] Info tab (step 6): CIRCLE spotlight sitting exactly on the info icon (not above, not on chevron)
- [ ] Settings gear (step 7): circle spotlight on gear icon

**PROG1:**
- [ ] Button and pill render at identical heights in Start state
- [ ] Same height in Continue state — no baseline drift when flipping
- [ ] Small / Default text scale: both fit cleanly
- [ ] Large text scale: flag any clipping per underbaked note

## Out of scope

- Rawi's Scroll wrapped-scroll visual
- Dhikr screen list → grouped redesign
- Stars screen non-event handling (R25-S6)
- Collections structure decision
- Back button exit dialog (R25-S7-1)
- v4.1 event engine
- Flame flicker animation (DROPPED BY OWNER in spec §verified+closed)

---

_Handoff S1.5 HF — Apr 23 2026. After device verify, S1 closes._
