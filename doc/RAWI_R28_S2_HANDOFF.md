# RAWI R28-S2 MEDIUM Sprint Handoff

**Bundle:** R28 S2 MEDIUM — Rawi's Scroll rebuild (arc registry + wrapped-scroll card grid + tap-to-unroll preview rows + seal-break animation)
**Round:** R28 — Apr 24 evening kickoff after R28-S1 HUGE shipped
**Spec:** `RAWI_R28_S2_SPEC.md` (Downloads, Apr 24 21:58)
**Unblock paste:** `R28_S2_DATA1_AGENT_UNBLOCK.md` (Khaled-supplied 20 arc titles + 4 modules; the spec referenced an off-disk content-decisions doc)
**Parent build:** R28-S1 HUGE handoff `2acc7d0`
**Agent:** Claude Code (Claude Opus 4.7, 1M context)
**Date:** Apr 24 2026 late evening

---

## R28-S1 aftermath — verified clean before starting

User asked to fix anything S1 broke. Audit found nothing to fix:

- `flutter analyze` baseline: 1 pre-existing warning only (`assets/audio/vo/` dir missing in pubspec.yaml). Same as R28-S1's baseline. No new regressions from the 8 shipped S1 items.
- **Navigation Contract** compliance: all 5 `RawiTentScreen` push sites carry `settings: RouteSettings(name: RawiTentScreen.routeName)` — verified by grep. The contract's permanent rule from R28-S1-BUG1 is intact.
- **Stale `SeerahSky*` references**: zero hits across `lib/` (CODE1 cleanup was thorough). Only mentions are legitimate "Seerah" narrative strings.
- **`m1_data.dart`**: confirmed 155 `JourneyEvent(` constructors. Earlier exploration agent had erroneously flagged truncation — false alarm.
- **Tent → Scroll launch**: bare `Navigator.push(MaterialPageRoute(...))` in `rawi_tent_screen.dart:550`. Not a Navigation Contract violation — Scroll is not an event entry point, no `popUntil` target needed. (Future: when row-tap → body launches an event, that surface MUST tag the new tent push per the contract. Spec already calls this out as inherited.)

No S1 hotfixes needed.

---

## Commits

| ID    | Hash       | Description |
|-------|------------|-------------|
| DATA1 | `d804a86`  | arc registry + event→arc mapping (20 arcs, 4 modules) |
| UI1   | `7ddcb77`  | wrapped-scroll card grid + module headers + lock states |
| UI2   | `a06f438`  | tap-to-unroll + preview rows + re-roll |
| FX1   | `4f71bf6`  | seal-break animation + first-launch backfill |

Per-item commits per spec discipline. `flutter analyze` run between every commit — clean (baseline warning only).

---

## Sequence + verification

Spec says sequence is DATA1 → UI1 → UI2 → FX1, each verifiable on its own. Followed exactly. Acceptance per item:

- **DATA1**: `flutter analyze` clean on the new file. Boundary tests for the mapping function — `arcIdForEvent(1)=1`, `(47)=5`, `(48)=6`, `(82)=10`, `(83)=11`, `(120)=15`, `(121)=16`, `(155)=20`. Plus structural invariants (20 arcs, 4 modules, 5 arcs per module, no gaps/overlaps, every event maps to 1..20). 17/17 pass. See `test/arc_registry_test.dart`.
- **UI1**: stack-reading + analyze. Renders 4 module sections × 5 cards. Locked card tap is `null` → no ripple. Unlocked card tap is `() {}` → ripple but no state change (UI2 swaps in the real handler).
- **UI2**: animation controller + tap behaviors. Outer-tap close, sequential switch, same-card no-op, row-tap absorbed. Visual verification owed on A56 — see device-check list below.
- **FX1**: post-frame backfill flow + seal-break orchestration. Two-pronged: silent backfill on first-build install (no cascade), then per-arc animation on subsequent unlocks. Visual verification owed on A56 — see device-check list below.

`flutter test` (full suite): **23/23 pass** — 17 new arc_registry tests + 5 pre-existing branching + 1 widget smoke.

---

## APK

- Path: `build/app/outputs/flutter-apk/app-release.apk`
- Size: 97,323,805 bytes (92.81 MB / 97.32 MB) — +32,768 bytes over R28-S1
- **APK SHA256:** `d5954af17fb576bfb6acef9bff711ec85eabee41614eb070a78ba36777f822be`
- **libapp.so arm64 (stripped) SHA256:** `e96e06f10da815e3aacba9046b5e46dd792be1638cb04ee6f3d2cda01fa8ffbb`

`libapp.so` hash moved from R28-S1's `8665bc5d60f2651b78ada1c55a8094b854747a01b94e3c55ffdb05f0a440b341`
→ R28-S2's `e96e06f10da815e3aacba9046b5e46dd792be1638cb04ee6f3d2cda01fa8ffbb` ✓

APK hash moved from R28-S1's `d0c2a0fc77966068bf03db3bace4d68cd526609d02ca1b7dc878b731c4d3bd8e`
→ R28-S2's `d5954af17fb576bfb6acef9bff711ec85eabee41614eb070a78ba36777f822be` ✓

Build: `flutter clean` → `flutter pub get` → `cd android && gradlew.bat assembleRelease`.
`BUILD SUCCESSFUL in 12m 9s`.

---

## Architectural decisions

### DATA1 — `arcIdForEvent` as a free function, not a field on JourneyEvent

Spec said "Add to event metadata: `arcId: int` (1–20)". Two implementations were possible:

- **Path A**: add `final int arcId` to `JourneyEvent` and update all 155 constructor calls in `m1_data.dart`.
- **Path B**: add a free function `arcIdForEvent(int globalOrder) → int` in `arc_registry.dart`. No `JourneyEvent` change. Callers compute `arcIdForEvent(event.globalOrder)`.

Picked B. Spec explicitly allows it ("a function `arcIdForEvent(int eventId) -> int` (or equivalent lookup table). Owner can rebalance narrative-properly in a later content pass without touching UI code"). Rationale: zero risk to the 155 event definitions, mapping rebalance becomes a 1-line change in `arc_registry.dart`, no model→data dependency.

The acceptance "no event has `arcId == null` or outside 1..20" is verified by a test that iterates all globalOrders 1..155 and asserts the function returns 1..20.

### UI1 — kept the existing `scroll_viewer_screen.dart` filename

Could have created a new `arcs_grid_screen.dart` and deprecated the old. Chose to overwrite in place: the tent nav already imports `ScrollViewerScreen`, the screen's role hasn't changed (still "the Scroll"), only its presentation. Single-file rewrite + delete of the superseded `scroll_arcs.dart` is the smallest-blast-radius option. UI1 deletes `scroll_arcs.dart` AT THE SAME COMMIT as the screen rewrite — no broken intermediate state.

### UI1 — unlock rule simplified to a single comparison

Spec: "Arc is unlocked iff any event in its event range has status `current` or `completed`."

This collapses to **`PrefsService.currentOrder >= arc.firstEvent`** because `currentOrder` is the next-to-play index — completed events are strictly below it, the current event equals it. So the first event of an arc being current → currentOrder == firstEvent → unlocked. A completed event somewhere in the arc's range → currentOrder > firstEvent → unlocked. Cheaper than iterating the range.

### UI2 — caps anchored via width-based ratio, not height-based

The spec wanted caps to "stay anchored at their original top and bottom positions" while parchment grew downward on unroll. Approach taken: the painter's `capH = w * 0.12` is a **width**-based constant — when the card's height grows, `capH` doesn't change. So the top cap stays at `(0, 0..capH)` and the bottom cap stays at `(0, h-capH..h)`. Parchment fills everything between, stretching naturally. Visually reads as "scroll opens, caps follow the ends, parchment exposes" — same metaphor as a real unrolling parchment.

Each card knows its own width (passed from a `LayoutBuilder` at the module level), so the open-height computation `closedH + panelExtraH` is deterministic per arc.

### UI2 — outer-tap close via translucent GestureDetector

Wrapped the Scaffold body in a `GestureDetector(behavior: HitTestBehavior.translucent, onTap: _closeIfExpanded)`. The card `InkWell`s consume their own taps before the outer detector fires, so a tap on a card never closes the panel inadvertently. A tap inside the panel (rows, play arrow) is absorbed by an opaque `GestureDetector` that wraps the panel content — also doesn't reach the outer detector. Net result:

- Tap on a card body (parchment, cord, but NOT the panel area when expanded) → InkWell handler.
- Tap inside the panel → no-op (absorbed).
- Tap anywhere else (background, between cards, header padding, scroll padding) → close.

### UI2 — same-card tap is no-op (spec-literal)

Spec defines re-roll only via outer-tap, sequential switch, and AppBar back. Tap on the same expanded card is undefined. Chose no-op (matches the "outside-tap closes" wording literally). Flagged as a UX choice — see Underbaked.

### UI2 — sequential switch when tapping a different unlocked card

`_onCardTap` awaits `_ctrl.reverse()` before forwarding the new card's animation. The `_switching` flag guards against re-entry from rapid taps. This matches the spec's "sequential, not simultaneous, to avoid layout jank" requirement.

### FX1 — per-arc AnimationController in a Map (not a single shared one)

Multiple arcs can be mid-break simultaneously (200 ms stagger between starts → up to 4 overlapping at peak). Two ways to drive that:

- **A**: one `AnimationController` with a long duration covering the whole cascade; each card maps a window via `Interval`.
- **B**: one `AnimationController` per animating arc; map controlled lifecycle.

Picked B. Each arc's animation lifecycle is independent — start, set the `arc_seal_broken_<N>` pref on completion, dispose, remove from map. No need to track a global cascade duration. Required switching from `SingleTickerProviderStateMixin` to `TickerProviderStateMixin` (still hosts the unroll's `_ctrl` too).

### FX1 — first-launch backfill is silent + idempotent

Tracked via the `scroll_seal_backfill_done` pref (bool, set once per install). The post-frame routine checks this flag first:

- **Backfill not done**: iterate all arcs; for each unlocked-but-not-flagged arc, set `arc_seal_broken_<N>` true silently. Set `scroll_seal_backfill_done`. Return — no animation cascade.
- **Backfill done**: any unlocked-but-not-flagged arcs are NEW unlocks since last open → schedule animations.

So an existing user updating from R28-S1 with arcs 1, 2, 3 already unlocked sees a quiet first-open (no 3-arc cascade). Then the next event they complete that unlocks arc 4 plays the animation as expected.

### FX1 — painter composes lock state, unroll fade, and seal-break in one pass

`_ScrollGraphicPainter` now takes 3 inputs: `unlocked: bool`, `cordOpacity: double` (UI2), `sealBreakProgress: double` (FX1). At steady state the seal-break value is 1.0 (no-op for the painter). When the seal-break animation runs, the painter:

- Lerp parchment + cap + rule colors gray → amber over phase 0.20–0.65.
- Render fragmenting wax seal (3 falling blobs + faint full-seal underlay) over phase 0.18–0.55.
- Render diagonal crack line over phase 0–0.20 (fades out 0.20–0.30 as fragments take over).
- Render 10 particle dots with golden-angle spread over phase 0.18–0.40.
- Render cord with alpha = `cordPhaseAlpha * cordOpacity` over phase 0.60–0.85.

The cord's two alpha sources compose: if a user taps the card mid-break (rare race), the unroll fade-out cleanly multiplies with the seal-break fade-in. No special-casing.

---

## Per-item summary

### R28-S2-DATA1 · arc registry · `d804a86`

`lib/data/arc_registry.dart` (new): 20 `ArcDefinition` entries + 4 `ModuleDefinition` entries. Titles copied verbatim from `R28_S2_DATA1_AGENT_UNBLOCK.md`. Mapping is the spec's sequential stub — flagged below as carried over.

`test/arc_registry_test.dart` (new): 17 tests, structural + boundary + every-event-coverage. All pass.

`lib/data/scroll_arcs.dart` retained until UI1 to avoid a broken intermediate state.

### R28-S2-UI1 · card grid + lock states · `7ddcb77`

`lib/screens/scroll_viewer_screen.dart` rewritten end-to-end. AppBar (back arrow auto-mirrored in AR + Cinzel Decorative gold title). Four `_ModuleSection`s, each rendering a header + 2-column grid via `GridView.count`. Cards:

- **Unlocked**: amber parchment (`#D4A95C`), darker amber caps (`#8B6D2E`), 4 horizontal writing-guide rules, vertical coral cord (`#B03A30`) with knot + bow.
- **Locked**: gray parchment (`#5A564E`) + gray caps (`#3D3A35`), oxblood wax seal (`#7B1F1A`) with stacked irregular blobs + highlight + signet dot. Tap is genuinely null.

Below each card: EN title (Lora w500) + AR title (Amiri w700) + progress (`N/M` for unlocked, `sealed` / `مختوم` italic for locked).

`lib/data/scroll_arcs.dart` deleted (797-byte file, replaced by arc_registry.dart).

### R28-S2-UI2 · unroll + preview rows · `a06f438`

Same file. `GridView.count` replaced with explicit row layout (`Column` of `_CardRow`s, each `Row(crossAxisAlignment: start)` of 2 `Expanded` cells). LayoutBuilder at the module level computes cell width.

State: `_expandedArcId`, `_ctrl` (500 ms easeOutCubic), `_progress`. Behaviour:

- Tap unlocked card → `_onCardTap(arcId)` → if same as expanded: no-op; if none expanded: forward; if different: reverse current then forward new (sequential, gated by `_switching`).
- Tap outside any card → `_closeIfExpanded` via the body's translucent `GestureDetector`.
- Tap inside the panel → absorbed by an opaque `GestureDetector` wrapping `_PreviewPanel`.

`_PreviewPanel` renders inside the parchment area between the (animated) caps. Per visible event: small-caps `ENTRY N · EVENT M` label + italic-serif first-sentence preview + amber play-arrow icon. Preview text from `scrollEntries[eventId].lineEn/Ar`, split on `[.!?؟]` or first 80 chars. Falls back to "Entry yet to be written…" / "قيد الكتابة…". Locked entries within the arc collapse into a single dashed-rule + "N entries yet to be written…" / "N قيد الكتابة…" summary line.

Row staggered fade-in: row N starts fading at `progress = N * 0.06`, 0.18 fade window. Summary fades in at progress 0.55, 0.25 window.

Cord fades out as part of the unroll: `cordOpacity = 1 - progress`. Painter draws cord with `alpha = cordPhase * cordOpacity` so this composes cleanly with FX1 in the rare race where a user taps a card mid-seal-break.

### R28-S2-FX1 · seal-break animation · `4f71bf6`

`lib/services/prefs_service.dart`: 2 new keys + getters/setters + `resetJourney()` cleanup. See PrefsService changes section in the commit message.

`lib/screens/scroll_viewer_screen.dart`: `TickerProviderStateMixin`, `Map<int, AnimationController> _sealCtrls`, `_runSealBreakLifecycle()` post-frame routine, `_startSealBreak(arcId)`. Each `_ArcCard` receives an optional `sealAnim: Animation<double>?` from its module's `sealCtrls` map. The painter renders the full break sequence (crack → fragments → particles → color shift → cord fade-in) over 750 ms total.

**Audio**: not shipped — visual-only ship per spec's optional flag. Flagged below.

---

## Underbaked flag tolerance — carried per spec

1. **Stub event-to-arc mapping (DATA1)** — sequential split (10/10/9/9/9 · 7×5 · 8/8/8/7/7 · 7×5), not narrative-driven. Final remap (e.g. moving "Year of the Elephant" into arc 4 regardless of sequential position) is a content-session task. The mapping is a single pure function in `arc_registry.dart` — no UI or callsite touches when remapping.

2. **Cord behavior on unroll (UI2)** — picked **fade-out** over "unties + falls". Reason: simpler animation path, no extra animation primitive, composes cleanly with FX1's cord fade-in via shared `cordOpacity * cordPhase`. If Khaled wants the unties-and-falls metaphor, it's a `_paintCord`-only change with a swing/translate path on the cord — leaves the rest of the architecture intact.

3. **Wax color (UI1)** — shipped `#7B1F1A` (oxblood) per the spec's suggestion range. Highlight `#A73028`, shadow `#4A100C`. If the oxblood reads too dark on the A56 OLED, easy retune.

4. **Seal-break audio (FX1)** — cut for time, visual-only ship. The animation has good "oh!" feel without it but a faint "crack + paper rustle" at phase 0.15 (right at the crack moment) would be a polish win. ElevenLabs gen + a `playSfx` call at `_startSealBreak` is ~10 LOC.

5. **Completed-arc visual distinction (UI1)** — no visual difference between "unlocked-with-progress" and "all events in arc completed" this sprint. Spec explicitly defers this. Card just shows `9/9` instead of `4/9`. Future design pass could add a subtle gold-rim glow + a small completed-stamp glyph. Flag stays open.

6. **Tap-on-same-expanded-card behaviour (UI2)** — shipped as no-op. Spec is silent (only mentions outer-tap, sequential switch, and back arrow as close mechanisms). Some users may instinctively tap the card again to toggle close — easy 4-line swap to `if (_expandedArcId == arcId) { close(); return; }`.

7. **Off-screen seal-break animations (FX1)** — current behavior fires animations for every newly-unlocked arc on screen-open, regardless of viewport. If a card is below the fold during its 750 ms animation, the user misses the visual but the seal still ends up "broken" in prefs. Common case (single-arc unlock after one event completion) usually has the new card above the fold. The "intersection-observer" pattern from the spec is unimplemented — a `VisibilityDetector` package or RenderObject inspection would defer the start until the card scrolls into view. Acceptable trade-off for ship; flag if it bites in cascade scenarios.

8. **Module header arrow auto-mirror in AR** — used `Icons.arrow_forward_rounded` for the back arrow in AR (not the LTR `arrow_back_rounded`). Visual-spot check on emulator looks right — A56 device verify needed.

---

## Device-verify asks on A56 (priority order)

1. **UI1 fresh-install check** — install + skip onboarding to event 1 current. Open Scroll. Confirm: 4 module sections each with 5 cards; arc 1 is amber-with-cord (unlocked); arcs 2–20 are gray-with-wax-seal (locked); module headers show "MODULE 1" / "Jahiliyyah" / "47 events" etc.

2. **UI1 sealed-card tap** — tap any sealed card. Should be 100 % no-op: no ripple, no animation, no crash.

3. **UI2 unlocked-card tap** — tap arc 1. Card height grows ~500 ms, cord fades out, preview row(s) fade in top-down. With currentOrder=1 and arc 1 having 10 events, you should see 1 row (event 1's preview) + a "9 entries yet to be written…" summary line below a dashed rule.

4. **UI2 outer-tap close** — while arc 1 is open, tap anywhere outside the card (background, header padding, between rows). Card re-rolls, cord fades back in.

5. **UI2 same-card no-op** — while arc 1 is open, tap arc 1 again. **Nothing should happen.** (If this feels wrong, see Underbaked #6 — easy swap.)

6. **UI2 sequential switch** — manually unlock more events via the in-app journey reset / replay flow until arc 2 is also unlocked. Tap arc 1 → opens. Tap arc 2 → arc 1 closes, then arc 2 opens. No layout jank, no overlap.

7. **UI2 row-tap absorbed** — while a card is open, tap a preview row's play-triangle. **Nothing should happen** — no crash, no card close, no event launch.

8. **FX1 first-build silent backfill** — install this APK on a device with R28-S1 progress where currentOrder is past the first arc boundary (e.g., currentOrder ≥ 6, putting arc 1 fully complete and arc 2 unlocked). Open Scroll for the first time. **No animation cascade should play** — both arcs should just appear in their unlocked state.

9. **FX1 single-arc unlock** — from a state where arc 2 is locked (currentOrder < 11), complete event 11 (or whatever's needed to bump currentOrder to 11). Return to tent. Open Scroll. Arc 2 card should play the seal-break animation: crack → fragments fall → particles → color shifts to amber → cord fades in. Total ~750 ms.

10. **FX1 no-replay** — close + reopen Scroll. Arc 2 stays unlocked, no re-animation.

11. **FX1 cascade (rare)** — if the dev helpers allow, simulate completing enough events to unlock arcs 3, 4, 5 in one go. Open Scroll. Three seal-breaks play top-to-bottom with ~200 ms stagger between starts (overlapping).

12. **AR locale** — set language to AR via Settings. Repeat #1–#5. RTL layout, AR titles render in Amiri serif, module headers mirror, back arrow points right (auto-mirror to forward in AR), preview row labels read right-to-left, summary line shows "N قيد الكتابة…".

13. **Regression — Navigation Contract** — open an event from Events List, hit back, hit Exit. Lands on tent (R28-S1-BUG1 still works).

14. **Regression — ambient resume** — home button, wait 30 s, return. Tent ambient resumes (R28-S1-BUG2 still works).

---

## Not done this sprint (parked)

- **Seal-break audio SFX** — see Underbaked #4. Ship visual-only.
- **Narrator-voice rewrites** for all 151 entries — own future content session, not a sprint task.
- **Row-tap → body panel** — explicitly out-of-scope for S2. Future UI sprint wires this up; the preview row container + play-triangle affordance from this sprint stay, only row interactivity changes.
- **Writing animation language** (quill audio, char/word reveal, ink-bloom) — lands when bodies render.
- **Dhikr taxonomy migration** — bundled with Dhikr tab UI in a later sprint (probably R28-S3 per spec).

---

## Build state at handoff

After this commit, the branch is **5 commits** beyond R28-S1 HUGE handoff (`2acc7d0`):

```
[handoff]  this commit
4f71bf6  R28 S2-FX1:   seal-break animation + first-launch backfill
a06f438  R28 S2-UI2:   tap-to-unroll + preview rows + re-roll
7ddcb77  R28 S2-UI1:   wrapped-scroll card grid + module headers + lock states
d804a86  R28 S2-DATA1: arc registry + event→arc mapping (20 arcs, 4 modules)
2acc7d0  R28 S1 HUGE:  handoff doc
```

**Do NOT push to origin.** Owner holds the push gate (carried from R28-S1).

---

_Handoff written Apr 24 2026 late evening. R28-S2 is MEDIUM. When device-verify lands clean — especially FX1 cascade and the first-build silent backfill — R28-S2 closes and either R28-S3 (Dhikr taxonomy) or a content session (narrator-voice + narrative arc remap) opens._
