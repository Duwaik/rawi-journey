# RAWI R27-S1 Handoff (1 of 2)

**Bundle:** R27 S1 (8 polish items — registration + tent)
**Round:** R27 — Apr 22 fresh-install device testing surfaced first-30-seconds polish
**Spec:** `RAWI_R27_S1_SPEC.md`
**Parent build:** v4 handoff `35ffb5f` + doc-audit `af09abe`
**Agent:** Claude Code (Claude Opus 4.7, 1M context)
**Date:** Apr 22 2026

---

## Orchestration note

Per Khaled: **S1 first, device-verify on A56, THEN S2.** R27-S2 (events list
redesign — 2 items, data-integrity-adjacent) is queued and NOT in this bundle.
Don't combine — S2 touches BUG-D event-numbering code and we want a clean
bisectable commit if anything regresses.

## Commits

| ID    | Hash       | Description |
|-------|------------|-------------|
| REG1  | `6ccbad4`  | name validation — charset + blocklist + inline hint |
| REG2  | `1d5ea46`  | Rawi's Call final sentence font alignment |
| TENT1 | `79c842e`  | first-visit tent tutorial cinematic (5 screens EN+AR) |
| TENT2 | `c9acc7a`  | fire ambient wiring + flame flicker overlay |
| TENT3 | `5849df0`  | Events List side-nav icon swap |
| TENT4 | `09b458b`  | Light pill label — drop "Your" |
| TENT5 | `bc82072`  | progress card — gold button, centered, bold counter, 8px bar |
| TENT6 | `3f4dfbc`  | info tab chevron-on-border + nudged down from Rawi's head |

8 commits, all on local `main`. **Not pushed to origin** — your call after
device verify.

## APK

- Path: `build/app/outputs/flutter-apk/app-release.apk`
- Size: 97,159,965 bytes (92.7 MB / 97.16 MB)
- **APK SHA256:** `2bd83ff81aa3aeebb1987d864f288fa9b1add06170f93b7976495974c2308a59`
- **libapp.so arm64 (stripped) SHA256:** `6a675b7f3798519a37b614e1296f8c1373a9a2127a24dd3e77d7967a52758f9c`

Build: `flutter clean` → `flutter pub get` → `gradlew.bat assembleRelease`.
`BUILD SUCCESSFUL in 12m 16s`, 256 tasks (219 executed, 37 up-to-date —
full Dart recompile + native rebuild after `flutter clean`).

## flutter analyze

**0 new warnings.** 1 pre-existing — `pubspec.yaml:37 assets/audio/vo/`
(unchanged since Sprint 1).

## Per-item summary

### REG1 — name validation (`6ccbad4`)

Before: any non-empty 2–15 char string passed. Digits, emoji, divine names.

Now:
- Charset regex `^[a-zA-Z؀-ۿ \'\-]+$` — Latin + Arabic + space + apostrophe + hyphen.
- Blocklist lowercase set: `allah god rabb lord الله اللّه الرب رب`. Match is whole-string-equals (after trim + lowercase), so `Abdullah` / `عبدالله` / `Abd Allah` all pass.
- `_validateName(String, bool isAr)` returns null when valid, else localized error.
- Permanent inline hint below the name field (always visible). Rejection error renders below the hint in red only when input violates a rule.
- Continue button disabled when a validation error is present.

All 11 acceptance cases walked statically.

### REG2 — Rawi's Call font (`1d5ea46`)

Line 4 ("Answer well, and the chain continues.") was 15 px white fully-opaque non-italic, breaking the screen rhythm. Lines 2–3 are 14 px α200 white italic. Line 1 is 16 px gold non-italic. Line 4 now matches Line 1 exactly — the screen bookends in gold (identity opener + closing promise), white italic body between.

### TENT1 — tent tutorial cinematic (`79c842e`)

New gated one-time cinematic, 5 screens EN+AR, visual style reuses Witness Moment (gold italic Lora serif on black, sparse gold-dust particles, dim top label, progress dots at bottom).

Advancement: tap-to-advance (not auto-timer). 5 screens on auto-timer would exceed attention for a first-use tutorial.

Trigger: new `PrefsService.isTentTutorialShown` / `setTentTutorialShown` (key `tent_tutorial_shown`). `RawiTentScreen.initState` schedules a post-frame push of `TentTutorialScreen` via `PageRouteBuilder(opaque: false)` only when the flag is false; the screen flips the flag and pops back on final-screen tap.

### TENT2 — fire ambient + flame flicker (`c9acc7a`)

Ambient audio: `ambient_tent_fire.mp3` is present. Existing code at `rawi_tent_screen.dart:191` already calls `playAmbient` with a fallback guard (`bf337c2`). Guard passes → fire crackle plays. No new audio code.

Flicker: warm amber radial glow overlay, positioned at `Align(0.0, 0.55)` (lower center of screen, roughly where the campfire in the BG JPG sits). 260×260 px circle, opacity 0.82→1.00 + scale 0.95→1.06 on a 1200 ms sine loop via `SingleTickerProviderStateMixin` + `AnimationController(reverse: true)`. `IgnorePointer` so it doesn't steal CTAs. BG JPG untouched (locked rule — tent BG is frozen).

### TENT3 — Events List icon (`5849df0`)

`📋` emoji → `Icons.view_list_rounded` in gold. Reads unambiguously as a list; distinct from adjacent `📜` (Scroll) and `🏛️` (Collections) emoji. New `_navIconMaterial(IconData, String, VoidCallback)` helper mirrors the existing emoji `_navIcon` frame (44×44 + rounded + black α180 + gold α40 border). Only Events List uses it; other nav slots unchanged.

### TENT4 — Light pill label (`09b458b`)

`Your Light` / `نورك` → `Light` / `النور`. One-line change in `_buildStatPillsContainer`. Other "Your Light" / "نورك" references retained intentionally (event scene info tab, event 1 tutorial, unified completion full sentences).

### TENT5 — progress card (`bc82072`)

Four visual changes:
1. Button: outlined translucent → solid gold fill + dark navy (#0B1E2D) text + w800. Continue state keeps a faint gold glow.
2. Button + counter row: `MainAxisAlignment.spaceBetween` → `center`. Pair sits in card middle with same 14 px gap.
3. Counter: `w500` → `w700`, alpha 191 → 230, size 11 → 12. Reads as primary metric.
4. Progress bar: `minHeight 2 → 8`, `BorderRadius.circular(1) → circular(4)`.

### TENT6 — info tab chevron-on-border (`3f4dfbc`)

Spec asked to update "tent info tab" + event scene info tab. Grep confirms `EventSceneInfoTab` is the ONLY widget matching the described YOUR LIGHT + THIS EVENT pattern — the tent has no counterpart (its Light/XP/Dhikr row is the unrelated `StatRowGroup`, already polished in TENT4/TENT5). Commit covers the single matching widget.

Changes:
- Default state already collapsed (`_expanded = false` on initState). No change needed.
- New `_buildChevronCircle()` — 24 px circle, navy fill α235 + gold 0.8 border + 4 px shadow, icon `chevron_right_rounded` when collapsed and `chevron_left_rounded` when expanded. Positioned at `right: -12` inside a `Stack(clipBehavior: Clip.none)` so it straddles the panel border.
- Old in-body chevrons removed from `_buildCollapsedContent` (rightward chevron under info glyph) and `_buildExpandedContent` (the `Positioned(right: -4)` collapse chevron).
- Vertical position nudged `screenH * 0.40 → 0.45` so the collapsed handle no longer clips Rawi's hat on scene entry.

**Preserved:** R26 S1v3-EE8.2 full-screen scrim with pan swallow.

## Architectural decisions

- **REG1 — blocklist is exact-match, case-insensitive, whole-input.** `Abdullah` must pass; `Abd Allah` must pass; only the standalone divine name is blocked. `_nameBlocklist.contains(trimmed.toLowerCase())` enforces this — no substring checks, no tokenization.

- **TENT1 — tap-to-advance, not auto-timer.** Spec said "match Witness Moment behavior exactly" and "tap anywhere to advance" — WM actually uses auto-timer, so these contradict. 5 screens on auto-timer at ~3 s each is 15 s which is too long for a first-use tutorial. Tap-to-advance respects user pacing. Flagged this in the commit body.

- **TENT2 — flicker is an overlay, not a repaint.** The tent BG is a frozen JPG and the campfire is baked in. A true flame animation would require extracting the fire region or swapping to a composited scene — both too invasive for a polish bundle. Overlay approach is non-destructive and reads as firelight breath.

- **TENT3 — swapped only Events List, not all nav icons.** Spec explicitly flags the Events List confusion; other icons (Scroll / Collections / Stars / Dhikr) weren't called out. Introduced `_navIconMaterial` so Khaled can opt-in to other Material swaps later without a helper refactor.

- **TENT5 — kept the card outer padding** at `horizontal: 18, vertical: 14`. Centering the button+counter compressed the row inward, but the outer card padding stays generous so the whole progress card doesn't feel wall-to-wall.

- **TENT6 — scoped to event scene info tab only.** No tent widget matches the spec description; the tent's equivalent concerns are handled by TENT4 + TENT5. Documented the scope call in the commit body.

## Self-verification notes

Per spec §2 anti-iteration:

1. **REG1** — walked all 11 cases statically (see commit body). `Abdullah` / `عبدالله` / `Abd al-Rahman` / `Abd Allah` all pass; `Allah` / `الله` / `Khaled123` / `Khaled😀` all rejected with the correct error branch.
2. **REG2** — before/after style diffed. Line 4 now exactly matches Line 1 (16 px gold Lora h1.8 non-italic). Screen bookends in gold.
3. **TENT1** — trigger logic flow-traced: `PrefsService.isTentTutorialShown=false` + `initState.addPostFrameCallback` → push cinematic → tap through 5 screens → final tap calls `setTentTutorialShown` + `onComplete` → pop back to tent. Second launch: flag is true → initState branch skipped.
4. **TENT2** — controller lifecycle verified: `initState` creates + `repeat(reverse: true)`, `dispose` tears down. `IgnorePointer` wrap means the overlay doesn't steal CTA taps below. Guard at `_startTentAmbient` already handles missing-file fallback.
5. **TENT3** — grep-confirmed `_navIconMaterial` is only called from the Events List slot. Other slots still call `_navIcon` with emoji.
6. **TENT4** — grep-confirmed no other render path uses `_buildStatPillsContainer.label`. Other "Your Light" strings are intentional and documented in the commit body.
7. **TENT5** — walked the card structure: Row `MainAxisAlignment.center` + `SizedBox(width: 14)` preserves the pair-gap relationship from the old spaceBetween. Button `_buildStartContinueButton` now has solid gold fill + dark text; Continue variant adds a BoxShadow. Progress bar `minHeight: 8` + `circular(4)` reads as a pill.
8. **TENT6** — `_buildChevronCircle()` renders in both collapsed and expanded states via the outer Stack (not inside `_buildTab`). `Positioned(right: -12)` + `Stack(clipBehavior: Clip.none)` lets the 24 px circle straddle the 1 px border so half the circle sits in scene space.

## KNOWN UNDERBAKED

- **TENT6 / AR RTL mirror** — the info tab still sits on the LEFT edge in AR locale; only the content inside mirrors. Spec 8.8 explicitly allows deferring this to R25-S6. Flagged on device the widget will still look "wrong-edge" to an Arabic-first user.
- **TENT1 / auto-timer vs tap** — if Khaled preferred auto-timer after all (misread spec), one flag flip on `TentTutorialScreen._advance` restores auto-timing. 3-line change.
- **TENT2 / flicker origin** — the glow center at `Align(0.0, 0.55)` is eyeballed against the day-variant tent BG. If the dawn/dusk/night variants have the campfire in a slightly different position, the glow will drift. Device-verify across all 4 time-of-day variants.

## Device verification checklist (Khaled on A56)

**REG1 — registration name field:**
- [ ] Fresh install → registration → name field → type `Khaled` → passes
- [ ] Type `Sa'ed` → passes
- [ ] Type `Abd al-Rahman` → passes
- [ ] Type `عبدالله` (AR locale) → passes
- [ ] Type `Khaled123` → charset error "Only letters, spaces, and - ' allowed."
- [ ] Type `Khaled😀` → charset error
- [ ] Type `Allah` → blocklist error "Please use a personal name."
- [ ] Type `الله` → blocklist error
- [ ] Type `Abd Allah` → passes
- [ ] Inline hint visible below field in both EN and AR locales
- [ ] Error messages localize correctly per locale

**REG2:**
- [ ] Rawi's Call screen on first launch after registration
- [ ] Line 4 ("Answer well, and the chain continues.") renders in gold, same size + style as Line 1 (identity line)
- [ ] No visual rhythm break vs. white italic body (Lines 2–3)

**TENT1:**
- [ ] Fresh install → registration → Rawi's Call → tent → cinematic auto-fires (5 screens)
- [ ] EN locale: each tap advances to next screen in order
- [ ] AR locale: same 5 screens render RTL, Arabic copy intact
- [ ] After screen 5 → cinematic dismisses, tent visible
- [ ] Kill app, reopen → tent loads without cinematic (pref set correctly)

**TENT2:**
- [ ] Fire crackle audio plays on tent entry (not the fallback intro track)
- [ ] Warm glow pulses subtly over the campfire — reads as breath, not blink
- [ ] Animation visible across all 4 time-of-day variants (dawn / day / dusk / night)
- [ ] No frame drops on A56

**TENT3:**
- [ ] Tent right-side nav: Events List icon now shows `view_list_rounded` (gold)
- [ ] Scroll (📜) and Collections (🏛️) visually distinct from Events List — no confusion at a glance
- [ ] Tooltip on long-press still reads `Events` / `الأحداث`

**TENT4:**
- [ ] Tent stat pill row: first pill reads `Light` / `النور` (not `Your Light` / `نورك`)
- [ ] Three-pill row width unchanged — no alignment regression
- [ ] AR locale renders correctly RTL

**TENT5:**
- [ ] Start/Continue button is solid gold (not outlined translucent)
- [ ] Button + `#/155` counter sit together in card center (not spread edge-to-edge)
- [ ] Counter is bold, reads as primary metric
- [ ] Progress bar is 8 px tall (not 2 px)
- [ ] Small / Normal / Large text scales — no overflow or wrap

**TENT6:**
- [ ] Info tab on event scene renders COLLAPSED by default
- [ ] Chevron circle visible on panel's right border, half inside / half outside
- [ ] Collapsed state: circle shows `>` (chevron right)
- [ ] Tap circle → expands → circle shows `<` (chevron left)
- [ ] Tap circle again → collapses
- [ ] Collapsed handle no longer overlaps Rawi's hat on scene entry
- [ ] R26 S1v3-EE8.2 outside-tap dismiss + pan swallow still works
- [ ] Fresh install flow: on entering Event 1, tab is collapsed — not expanded

## Out of scope (do NOT touch in S1 — confirmed untouched)

- **R27-S2** events list redesign (S2-EL1 number + tick consolidation, S2-EL2 tent counter label clarity). Ships as separate bundle after S1 verify.
- AR RTL mirror on info tab widgets (deferred R25-S6).
- Tent exit dialog (deferred R25-S7).
- Any event engine changes — parked for v4.1 spec.

## If verification passes

Proceed to R27-S2 (2 items — events list redesign + tent counter label).

## If any item fails

Paste the debug log + symptom + screenshot. Do not blind-iterate.

---

_Handoff S1 — Apr 22 2026._
