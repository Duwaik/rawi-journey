# RAWI R27-S1.4 HF Handoff

**Bundle:** R27 S1.4 HF — Info Icon + Progress Card + Tent Ambient + Flame + Age Picker
**Round:** R27 — Apr 23 morning follow-up to S1.3 verify
**Spec:** `RAWI_R27_S1_4_HF_SPEC.md`
**Parent build:** R27-S1.3 HF + R27-S2 handoff `b67cb10`
**Agent:** Claude Code (Claude Opus 4.7, 1M context)
**Date:** Apr 23 2026 morning

---

## Commits

| ID     | Hash       | Description |
|--------|------------|-------------|
| INFO1  | `76fb664`  | info icon + circular border enlarged, chevron unchanged (tent + event scene) |
| PROG1  | `d4c7f9a`  | progress card number — remove "Completed" word, add gold-outlined container |
| AUDIO1 | `74c3670`  | tent ambient lifecycle — resume on return, dispose previous |
| ANIM1  | `1e36c15`  | flame animation — amplified (was rendering but imperceptible) |
| REG1   | `3514174`  | registration age picker — horizontal swipe |

All on local `main`. Pushing this bundle per your instruction ("Ship, push, done").

## APK

- Path: `build/app/outputs/flutter-apk/app-release.apk`
- Size: 97,274,653 bytes (92.77 MB / 97.27 MB)
- **APK SHA256:** `b681ca2ce32f561d999e1d50e1b967f8bcd74ea1557d6d0e3132a8fee98f4384`
- **libapp.so arm64 (stripped) SHA256:** `90511a2e10161a1ee6ec5e4d517875036499610ae220e93eee53fced582dc365`

Build: `flutter clean` → `flutter pub get` → `gradlew.bat assembleRelease`.
`BUILD SUCCESSFUL in 12m 1s`, 256 tasks (219 executed, 37 up-to-date).

## flutter analyze

**0 new warnings.** 1 pre-existing — `pubspec.yaml:37 assets/audio/vo/`
(unchanged since Sprint 1).

## Per-item summary

### INFO1 — info icon + border enlarged · `76fb664`

Third pass on info tab sizing. S1.2 fixed the tap target (44 → 88 px
invisible); S1.3 fixed chevron visual + straddle positioning. S1.3
device verify revealed the remaining asymmetry: the chevron visual
(42 px) was LARGER than the info glyph inside the panel (14 px from
S1.1). Visual hierarchy inverted.

Fix applied to both `tent_info_tab.dart` and `event_scene_info_tab.dart`:
- `_collapsedWidth` 32 → 62 (gives 44 px internal after padding).
- `_buildCollapsedContent` now returns a 44 × 44 gold-outlined circle
  with a 28 px `Icons.info_outline_rounded` centered inside.
- Chevron circle from S1.3-TENT1 (42 px, `right: -44`) untouched —
  it reads as secondary to the info icon's dominance.

### PROG1 — gold-outlined container · `d4c7f9a`

S2-EL2 added a "Completed " / "مكتمل " prefix to the tent counter to
disambiguate from the events list badge (BUG-D). Khaled's verify:
wording not wanted, wanted visual treatment.

- Removed the RichText + "Completed" prefix span.
- Wrapped the number in a `Container(…)` with:
  - 1.5 px solid gold border
  - Gold α20 fill
  - `BorderRadius.circular(10)` — matches Start/Continue button
  - 14 × 6 px padding
- Counter number retains S1.3-TENT2 styling (#F0D070 w700 14 px);
  the halo shadow was dropped now that the container provides the
  visual weight.

BUG-D disambiguation still works because R27-S2-EL1 gives every
events list card an explicit number badge — the two numbers sit in
clearly distinct visual containers.

### AUDIO1 — tent ambient lifecycle · `74c3670`

Symptom: navigate tent → Events List / Scroll / Dhikr / Collections
→ back → tent fire ambient doesn't resume. Previous screen's ambient
keeps playing.

Root cause: tent's `didPopNext` (wired to `appRouteObserver` since
R26 S1v2-T2) only called `setState(() {})` to refresh the Continue
button. Never re-triggered the ambient.

Fix: add `_startTentAmbient()` call inside `didPopNext` alongside
the existing setState. `AudioService.playAmbient`
(audio_service.dart:44) handles the cross-fade cleanly:
- Same ambient already current → early return (no-op)
- Different ambient current → fadeOut previous over 200 ms, then
  start fire ambient. LOCKED RULE (no hard cuts) preserved.

### ANIM1 — flame animation amplified · `1e36c15`

Device verify on S1.3: Khaled reported "no animation, none." Audit
of `rawi_tent_screen.dart:349-387` confirmed the animation IS
rendering — just imperceptible.

Root-cause values (S1-TENT2):
- Period 1200 ms reverse (2400 ms full cycle) — too slow to read as
  breathing
- Base alphas 70 / 30 on the radial gradient — glow itself was
  barely visible (27% / 12% opacity), so the pulse was modulating
  an almost-invisible element
- Opacity amplitude 0.82 → 1.00 (18%) — narrow
- Scale amplitude 0.95 → 1.06 (11%) — narrow

Amplified (S1.4):
- Period 1200 → 900 ms (full cycle 1800 ms)
- Base alphas 70 → 120, 30 → 60
- Opacity 0.70 → 1.00 (30%)
- Scale 0.92 → 1.12 (20%)

Still subtle — reads as breath, not a strobe. Position, radius,
gradient colors, `IgnorePointer` wrap, disposal unchanged.

### REG1 — age picker horizontal · `3514174`

Age picker on registration was a vertical `ListWheelScrollView`.
Khaled wants horizontal to match the toggle language on the same
screen.

`ListWheelScrollView`'s scroll direction is fixed to vertical
internally (no `scrollDirection` param). Fix via rotation wrapper:

- Outer `RotatedBox(quarterTurns: 3)` rotates the wheel 90° CCW —
  vertical-up becomes horizontal-left. Swipe L/R changes age.
- Each child counter-rotates `quarterTurns: 1` to keep age numbers
  upright while the wheel rolls horizontally.
- `itemExtent: 44` unchanged — now describes horizontal extent.
- No controller / physics / childCount / onSelectedItemChanged
  changes. Persistence, mode pre-selection, range all unchanged.

## Architectural decisions

- **INFO1 — dedicated circular container inside the panel.** Could
  have pushed the icon onto the existing panel's own border. Chose
  a nested circle because: (a) the panel's rect is getting wider
  for the enlarged icon and a ring clarifies what's tappable vs
  what's chrome; (b) the same treatment applies cleanly to the
  event scene tab, where the panel has a different background
  (scene BG vs tent BG).

- **PROG1 — matching the button's border vocabulary, not the
  button's fill.** Gold-outlined pill over gold-filled pill keeps
  the two elements visually distinct (not two solid gold buttons)
  while sharing the same geometry.

- **AUDIO1 — single-line fix.** `playAmbient` already does the
  right thing; just needed the call in `didPopNext`. No observer
  / layer changes needed.

- **ANIM1 — amplify, don't rebuild.** Spec offered Option A
  (AnimatedOpacity overlay) and Option B (CustomPainter particles).
  The existing overlay was already Option A — the problem was
  scale, not architecture. If amplification still reads as absent
  on device, Option B stays as a fallback.

- **REG1 — RotatedBox over native rewrite.** Spec's "fastest path."
  Stable, zero controller churn, zero physics changes. If users
  report a rendering edge case (rare), native rewrite is a 1-hour
  task.

## Self-verification

1. **INFO1** — both widgets' `_buildCollapsedContent` now return
   a 44 × 44 circle with 28 px icon. `_collapsedWidth = 62` leaves
   18 px for horizontal padding on each side. Chevron position
   unchanged.
2. **PROG1** — RichText + TextSpan prefix + "Completed" string all
   removed. Single Text inside a Container with gold border. No
   remaining "Completed" / "مكتمل" reference in the progress card.
3. **AUDIO1** — `didPopNext` now calls both `setState(() {})` +
   `_startTentAmbient()`. `playAmbient`'s short-circuit at
   audio_service.dart:54 handles the "same ambient" case.
4. **ANIM1** — grep confirms `_firelightCtrl` still renders via the
   same AnimatedBuilder; values bumped. No new controllers.
5. **REG1** — RotatedBox nesting: outer 3 + inner 1. Net rotation
   for each child = 3 + 1 = 4 quarterTurns = 0 (full rotation).
   Age numbers render upright. The wheel itself is rotated 270° so
   scroll axis is horizontal.

## KNOWN UNDERBAKED

- **ANIM1** — amplified from a known-rendering baseline. If it's
  STILL invisible on device, the overlay might be clipped by some
  Stack ancestor I'm not seeing, or the cinematic dim layer is
  persisting somehow. Video capture in verify will confirm.
- **REG1 AR swipe direction** — same `quarterTurns: 3` for both
  locales. Native Android / iOS wheel pickers don't flip swipe
  direction per locale, so this matches platform convention. If AR
  users report fighting the direction, flip to `quarterTurns: 1`
  for `isAr == true`.
- **PROG1 narrow state** — the outlined pill takes its natural size
  from the number inside. "0/155" is ~5 chars; "155/155" is 7. Pill
  width varies across the user journey. Device verify at both
  extremes to confirm no layout drift.

## Device verification checklist (A56)

**INFO1:**
- [ ] Tent info tab collapsed: info icon clearly visible + larger than chevron
- [ ] Event scene info tab: same treatment
- [ ] Tap info icon → opens panel; tap chevron circle → also opens panel
- [ ] Event scene: tap icon does NOT walk the figure

**PROG1:**
- [ ] Progress card: no "Completed" word anywhere
- [ ] Number inside a gold-outlined pill
- [ ] Pill visually equal to Start/Continue button, not louder/quieter
- [ ] No overflow at Small / Large text scales

**AUDIO1:**
- [ ] Fresh launch → tent → fire ambient plays
- [ ] Tent → Events List → back → fire ambient resumes
- [ ] Tent → Scroll → back → fire ambient resumes
- [ ] Tent → Dhikr → back → fire ambient resumes
- [ ] Tent → Collections → back → fire ambient resumes
- [ ] Tent → Stars → back → fire ambient resumes
- [ ] No two ambients simultaneously at any point

**ANIM1:**
- [ ] Open tent, watch fire for 10 seconds → visible breathing glow
- [ ] Motion is natural, not strobe-y
- [ ] Tent BG image unchanged (diff vs pre-build if possible)
- [ ] No frame drops on A56

**REG1:**
- [ ] Registration second page: age picker responds to horizontal swipe
- [ ] Ages laid out horizontally, current one centered + larger
- [ ] Vertical swipe doesn't change value
- [ ] Selected age persists after Continue
- [ ] AR locale: same behavior

## Out of scope

- Rawi's Scroll wrapped-scroll visual
- Dhikr screen list → grouped redesign
- Stars screen non-event handling
- Collections structure decision
- Back button exit dialog (R25-S7-1)
- v4.1 event engine
- R27-S2 Events List verification (shipped prior bundle)

---

_Handoff S1.4 HF — Apr 23 2026 morning._
