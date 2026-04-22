# RAWI R27-S1.2 HF Handoff

**Bundle:** R27 S1.2 HF — Info Tab Consolidation + Cinematic Visibility
**Round:** R27 — Apr 22 evening post-S1.1 device verify on A56
**Spec:** `RAWI_R27_S1_2_HF_SPEC.md`
**Parent build:** R27-S1.1 HF handoff `b992849`
**Agent:** Claude Code (Claude Opus 4.7, 1M context)
**Date:** Apr 22 2026 evening

---

## Orchestration note

Ships BEFORE the 7-step coach-mark extension per your spec. R27-S2 (events
list + tent counter label) remains parked.

## Commits

| ID    | Hash       | Description |
|-------|------------|-------------|
| TENT1 | `419e01d`  | consolidate tent info tab — stat pills live inside, delete old standalone block |
| TENT2 | n/a        | confirmed event scene info tab content still distinct (no code change) |
| TENT3 | `d33558f`  | info tab tap target 2× on tent + event scene, gesture exclusivity preserved |
| TENT4 | `43585e1`  | cinematic — actually dim tent BG + fade progress card + hint visibility |
| TENT5 | `2f79095`  | remove stray "Your Tent" title above greeting |
| TENT6 | `2067076`  | progress card half-and-half centered layout |

5 code commits (TENT2 was no-op per spec). All on local `main`. **Not
pushed to origin** — your call after device verify.

## APK

- Path: `build/app/outputs/flutter-apk/app-release.apk`
- Size: 97,258,269 bytes (92.75 MB / 97.26 MB)
- **APK SHA256:** `c72b8a02b052b8f2ce13825078308ecb0e761d5323745fdc86d7632dab9c5104`
- **libapp.so arm64 (stripped) SHA256:** `3f255395d7540f2591863423f3534183ad78fea50c2b25ccbd648973b24ba68a`

Build: `flutter clean` → `flutter pub get` → `gradlew.bat assembleRelease`.
`BUILD SUCCESSFUL in 13m 18s`.

## flutter analyze

**0 new warnings.** 1 pre-existing — `pubspec.yaml:37 assets/audio/vo/`
(unchanged since Sprint 1).

## Per-item summary

### TENT1 — consolidate tent info tab · `419e01d`

Tent used to render TWO stats widgets: the always-visible top-left Light/XP/
Dhikr pills block AND the expandable info tab with YOUR LIGHT + JOURNEY.
Merged to one widget.

- Deleted the standalone pills `Positioned(top: 0.22, left: 10)` + replaced
  with a comment noting the consolidation.
- Renamed `_buildStatPillsContainer` → `_buildInfoTabStatRows`. Stripped
  SizedBox(155)/ClipRRect/BackdropFilter/Container chrome — the info tab's
  panel already provides blur + gold border + dark fill.
- Refactored `TentInfoTab` to be shell-only. Takes a `Widget expandedContent`
  parameter. Caller passes a `StatRowGroup` with Light/XP/Dhikr rows. The
  old YOUR LIGHT + JOURNEY content + `_toArabicNumeral` helper + google_fonts
  import inside the widget are all gone.
- Call site: `TentInfoTab(expandedContent: _buildInfoTabStatRows(completed))`
  — builds live values each build (noorLevel, xp, dhikrCompletedCount).

Event scene info tab (`event_scene_info_tab.dart`) unchanged by this commit;
its content stays YOUR LIGHT + THIS EVENT hotspot dots.

Cleanup: removed now-unused `dart:ui` import from `rawi_tent_screen.dart`.

### TENT2 — event scene info tab content distinct · no code change

Grep-verified `event_scene_info_tab.dart` still renders:
- Section 1: `Your Light` / `نورك` — `across all events` subtitle
- Section 2: `This Event` / `هذا الحدث` — hotspot dots

No code change needed. Flagging here so the commit ledger matches the spec's
item list.

### TENT3 — info tab tap target 2× · `d33558f`

Device verify on S1.1 showed the figure still occasionally moves on an info
tab tap — 44 × 44 hit target wasn't quite generous enough.

Doubled both widgets' invisible hit target from 44 × 44 → 88 × 88. Visual
chevron stays 24 px centered inside via `Alignment.center`. `HitTestBehavior.
opaque` unchanged — any tap within the 88 × 88 box is absorbed before
reaching the figure walk handler.

### TENT4 — cinematic dim + chrome fade · `43585e1`

Two device-verified issues from S1.1-TENT4.

**A. Dim didn't land.** S1.1 used
`Colors.black.withValues(alpha: _dimOpacity)` inside a `Container` — on
device the tent stayed fully bright. Fix: explicit
`Color.fromARGB((255 * _dimOpacity).round(), 0, 0, 0)` form + `ColoredBox`
(short-circuits paint when alpha is 0). Target bumped 0.50 → 0.55 for clearer
contrast against bright tent variants.

**B. "Tap to continue" hint hidden behind progress card.** Card + hint both
sit near the bottom; scrim dims the BG but can't hide widgets from higher
layers. Fix: new `_cinematicActive` state flag. Flipped true BEFORE
pushing `TentTutorialScreen`; flipped false in the onComplete callback.
Tent chrome wrapped in `AnimatedOpacity(_cinematicActive ? 0.0 : 1.0, 400 ms)`:
- Greeting (top center)
- Right-side nav column (5 icons)
- Settings gear (top-right corner)
- Progress card (bottom)

Info tab gated off the tree entirely during cinematic (`!_cinematicActive`
condition on the Positioned.fill) so its 88 × 88 chevron hit target can't
swallow a tutorial tap.

Kept visible during cinematic: tent BG image + fire flicker overlay.

### TENT5 — remove "Your Tent" title · `2f79095`

Deleted the `Positioned` top-label block in `tent_tutorial_screen.dart`
that rendered `Your Tent` / `خيمتك`. Device-verify showed it reading as a
stray title above the greeting — root cause was partly the S1.1 dim not
landing (making the greeting visible through the transparent dim alongside
the cinematic top label). With S1.2-TENT4's chrome fade now hiding the
greeting during cinematic, there's nothing for this label to sit against,
and it's redundant to the main cinematic text.

### TENT6 — progress card half-and-half layout · `2067076`

Replaced S1.1-TENT3's "inward + 26 px fixed gap" approach with
`Row(children: [Expanded(child: Center(button)), Expanded(child: Center(counter))])`.
Each element sits at the visual center of its 50% slice — geometric and
predictable regardless of button label width or counter digits.

Preserved from S1.1: button width equalization (SizedBox(128)), gold fill,
counter bold/size, 8 px progress bar. AR RTL handled by `Row.textDirection` —
Expanded order flips, counter on left + button on right, each still centered
in its own half.

## Architectural decisions

- **TENT1 — shell-only widget.** Made TentInfoTab content-agnostic via a
  `Widget expandedContent` param rather than hardcoding pills. Future
  rounds can drop in different content (status dashboard, daily streak,
  achievements preview) without widget-boundary plumbing.

- **TENT4 dim: `ColoredBox` + explicit ARGB.** The S1.1
  `Colors.black.withValues(alpha: _dimOpacity)` inside a `Container` might
  have been a Flutter 3.x float-alpha precision edge case. The more explicit
  form removes the guesswork and ColoredBox short-circuits paint when
  alpha == 0, which is the common case at animation start.

- **TENT4 chrome-fade scope.** Spec said "progress card" specifically; I
  also wrapped greeting + nav + settings + gated info tab. Reasoning: any
  widget in the tent tree that's not the BG or fire flicker is chrome that
  competes with tutorial focus. If you want any of these visible during
  cinematic, one-line removal of the AnimatedOpacity wrapper.

- **TENT6 — Expanded+Center, not weighted columns.** `Expanded(flex: 1)`
  is equivalent to no explicit flex and simpler to read. AR RTL "just works"
  via Row's `textDirection` — no manual `isAr ?` swap.

## Self-verification notes

1. **TENT1** — tree verified: standalone `Positioned(top: 0.22)` block
   gone; `TentInfoTab` takes new `expandedContent` param; call site builds
   live StatRowGroup each build.
2. **TENT2** — grep confirmed `event_scene_info_tab.dart` lines 271 ('Your
   Light') and 309 ('This Event') still present with expected content.
3. **TENT3** — both `_buildChevronCircle` methods now use `width: 88, height: 88`
   Container wrapping the 24 px visual. HitTestBehavior.opaque retained.
4. **TENT4** — traced state flow: initState → 1000 ms → setState(_cinematicActive=true)
   → push route → route transition (300 ms) + dim tween (400 ms) + text
   tween (500 ms) run in parallel → tap-to-advance → final tap → dim tween
   back to 0 → widget.onComplete → pop → setState(_cinematicActive=false)
   → _maybeShowIconTutorial → 250 ms → icon tutorial starts.
5. **TENT5** — grep confirmed no remaining "Your Tent" / "خيمتك" top-label
   in the cinematic widget (only in-copy Arabic "خيمتك" still inside the
   5 cinematic lines, which is correct).
6. **TENT6** — `Row(children: [Expanded, Expanded])` with AR textDirection
   flips the visual order correctly.

## KNOWN UNDERBAKED

- **TENT1 / single-tap cost.** User now has to tap the info tab handle to
  see Light/XP/Dhikr at a glance — no longer visible by default. You flagged
  this as acceptable in spec, but it's a shift in default-visible state.
- **TENT3 / hit target might overlap screen edge.** `88 × 88` centered at
  the chevron's `right: -12` extends roughly 44 px past the panel border
  (half the hit target width) and 44 px inward. On A56 that's well within
  the screen. On narrower devices the inward extent might eat into scene
  real estate — flag for device verify across widths.
- **TENT4 / dim target 0.55.** If this still reads too bright on tent_dawn.jpg,
  one-line bump to 0.60-0.65 in `_runInitialSequence`. Spec range was 50-60%.
- **TENT4 / chrome-fade order** — the 400 ms fade on chrome starts BEFORE
  the 300 ms route transition completes. Fine visually but they're not
  choreographed; if the overlap feels off, chain them with an `await`
  or a post-frame callback instead of flipping the flag synchronously.
- **TENT6 / AR RTL screenshot** — I can trace the AR render on paper
  (counter-on-left, button-on-right, each centered in its half) but haven't
  screenshot-verified on device.

## Device verification checklist (A56)

**TENT1:**
- [ ] Tent loads → NO Light/XP/Dhikr pills visible at top-left
- [ ] Only the collapsed info tab handle on left edge
- [ ] Tap handle → expands showing the three pills with current values
- [ ] Tap chevron → collapses
- [ ] AR locale: labels translate (Light → النور, XP → الخبرة, Dhikr → الذكر)

**TENT2 (no code change — device check only):**
- [ ] Enter any event scene → tap info tab → expanded shows YOUR LIGHT +
      THIS EVENT sections, NOT Light/XP/Dhikr pills
- [ ] YOUR LIGHT value matches tent value
- [ ] THIS EVENT shows hotspot dots

**TENT3:**
- [ ] Event scene → fast-tap info tab chevron 10 times → figure does NOT
      move once
- [ ] Tent → fast-tap info tab chevron 10 times → tab toggles each time
- [ ] 88 × 88 hit zone reliably catches fast / imprecise taps

**TENT4:**
- [ ] Reset Journey → fresh tent load
- [ ] ~1 s later → tent BG visibly dims to ~55% darkness
- [ ] Greeting, progress card, nav, settings gear all fade to 0 during cinematic
- [ ] Cinematic text clearly legible against dimmed BG
- [ ] "Tap to continue" hint on screen 1 visible at bottom (not hidden)
- [ ] After final tap → dim lifts, chrome fades back to 1.0, icon tutorial fires

**TENT5:**
- [ ] During cinematic → NO "Your Tent" label anywhere
- [ ] Only the main gold cinematic text visible

**TENT6:**
- [ ] Start state screenshot: button centered in left half, counter centered in right half
- [ ] Continue state screenshot: identical positions — zero reflow
- [ ] AR locale: counter on left, button on right, each centered in own half
- [ ] Small / Normal / Large text scales — no overflow or wrap

## Out of scope

- 7-step coach-mark extension (R27-S1.3)
- R27-S2 events list redesign
- v4.1 spec
- Rawi's Scroll / Collections / Stars redesigns

## Next

If verification passes → proceed to the 7-step coach-mark extension per
whatever spec you drop next.

If anything fails → paste log + screenshot, do not blind-iterate.

---

_Handoff S1.2 HF — Apr 22 2026 evening._
