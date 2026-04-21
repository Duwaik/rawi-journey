# RAWI R26 S1v4 Handoff (bundle 2 of 2)

**Bundle:** R26 S1v4 (3 design-rebuild items)
**Round:** R26 — Apr 21 design-rebuild bundle
**Spec:** `RAWI_R26_S1v3_v4_SPEC.md` §Part 2
**Parent build:** S1v3 handoff `2a0b17f` (Apr 21 earlier today)
**Agent:** Claude Code (Claude Opus 4.7, 1M context)
**Date:** Apr 21 2026

---

## Orchestration note

v3 shipped but the device-verify on v3 has not yet come back from the A56.
Khaled asked to continue into v4 anyway ("continue - then build"), so this
bundle ships without a v3 device-green. If v3 device-verify later turns up
an issue, bisect against the v3 commits (`4246938`, `22f6720`, `bc42adb`,
`d5b6311`, `ccca0c3`) — none of the v4 changes depend on the v3 items.

## Commits

| ID    | Hash       | Description |
|-------|------------|-------------|
| EE6.1 | `dce4e13`  | halo radius math — 4x/3x/2x/1x/0.5x by noor % |
| EE6.2 | `6804c9b`  | cinematic fog reveal on event completion |
| EE6.3 | `308cd7a`  | end-of-event flow — scroll→dhikr→XP auto-flow over revealed scene |

Handoff: `…` (this file, uncommitted at read time).
HEAD pre-handoff: `308cd7a`. **Not pushed to origin** — Khaled's call.

## APK

- Path: `build/app/outputs/flutter-apk/app-release.apk`
- Size: 96,356,631 bytes (91.9 MB / 96.36 MB)
- **APK SHA256:** `1c7a764fc70092e3031f2f3bf625608308e628af2a601a6cb0fed9899fc25152`
- **libapp.so arm64 (stripped) SHA256:** `65a6f30b94c1aa57f4c3726408d8d5f7965f3b4004596eefe4f0905696b2eda6`

Build: `flutter clean` → `flutter pub get` → `gradlew.bat assembleRelease`.
`BUILD SUCCESSFUL in 8m 29s`, 256 tasks (38 executed, 218 up-to-date —
Dart recompile + repackage; native cached from v3 since no Kotlin/Java
changed).

## flutter analyze

**0 new warnings.**
1 pre-existing warning — `pubspec.yaml:37 assets/audio/vo/ doesn't exist`
(unchanged since Sprint 1).

## Per-item summary

### EE6.1 — halo radius math (`dce4e13`)

**Was:** `rawiLightRadius = 25 + (noor/100) * 95` — at 100% → 120 px,
at 10% → 34.5 px. Linear and undershoots the spec's top end.

**Now:**

```dart
final multiplier = (noorLevel / 25.0).clamp(0.5, 4.0);
final radius     = _haloBaseUnit * multiplier;
```

Where `_haloBaseUnit = 60.0` px (the one device-tuning knob).

| Light % | Multiplier | Radius (px) |
|---------|------------|-------------|
| 100%    | 4x         | 240         |
| 75%     | 3x         | 180         |
| 50%     | 2x         | 120         |
| 25%     | 1x         | 60          |
| 10%     | 0.5x (clamp) | 30        |

Intermediate values scale linearly (35% → 1.4x → 84 px) — no pop-in.

**Untouched:** HS hotspot halos (70 px hardcoded inside `FogOverlay._punchHole`)
and the avatar-circle glow in `rawi_figure.dart`. Only the scene-illumination
radius around Rawi changes.

### EE6.2 — cinematic fog reveal (`6804c9b`)

Replaces the old "tap Continue after a 1.5 s delay" gate between the verdict
answer and `UnifiedCompletionScreen` with a 4 s cinematic beat.

**Flow (non-replay):**
1. User taps verdict option.
2. Existing persistence runs (`completeEvent`, `clearHotspotProgress`,
   `clearBranchChoice`, `clearInProgressEvent`, badges).
3. 500 ms — verdict card dismiss animation finishes.
4. `_cinematicRevealActive = true` flips — verdict card hidden, dim
   overlay tweens 0.35 → 0.0 over 500 ms. Fog is already cleared by the
   pre-verdict `_triggerFogReveal`, so the scene is visible throughout.
5. 3000 ms quiet scene-held moment (spec: "fog dissolves from current
   state to fully clear" — no-op when already 0).
6. 1000 ms final held beat.
7. `_completeAndPop()` pushes `UnifiedCompletionScreen`.

**Replay flow is unchanged** — `_alreadyCompleted = true` still gets the
immediate Continue button so the user can quick-skip past a known event.

### EE6.3 — end-of-event flow rebuild (`308cd7a`)

Biggest surface-area change of the bundle. Every edit sits in two files:
`immersive_event_screen.dart` (one push) and `unified_completion_screen.dart`.

**Sub-changes:**

1. **Revealed scene BG visible behind cards.** Navigation from the event
   scene to Unified switched from `pushReplacement(MaterialPageRoute)` to
   `Navigator.push(PageRouteBuilder(opaque: false, barrierColor: transparent))`.
   The event scene route stays mounted behind Unified so the cards paint
   over the actual scene. Unified's existing
   `pushAndRemoveUntil(tent, (r) => false)` clears both routes on exit,
   so back-nav to the just-finished event is still impossible.

2. **Scaffold transparency.** Unified's `Scaffold.backgroundColor` is
   now `Colors.transparent`, and the old navy gradient container is
   replaced with a single 0.72-alpha dark scrim (`0xFF04060D` @ 0.72)
   so card copy stays readable regardless of scene brightness.

3. **Section order:** scroll → dhikr → XP (was scroll → XP → dhikr).
   Chapter + badge sections keep their place at the top when present
   (era-end / newly-awarded badges).

4. **Auto-flow with dhikr as the only user-gated beat.**
   - Scroll: 3 s reveal + 0.2 s shimmer + 3.8 s quiet read ≈ 7 s total
     before auto-advancing to dhikr (spec "7-second auto-read timer").
   - Dhikr: user gates via hold ring OR "I've said it" OR Skip.
   - `_onHoldComplete` / `_onSaidIt` / `_onNotNow` no longer flip
     `_canExit = true` or fade in Continue — they now call
     `_startXpCountUp()` directly, moving the user into the XP beat.
   - `_afterXp` on fresh completion: 4 s hold + auto
     `_continueJourney()` (spec "4-second display, no tap required").
   - Replays still hit the Continue button so a user browsing past
     events isn't auto-kicked out.

5. **"Noor +50%" label removed** from the hold-and-recite area. The
   +50 rechargeNoor mechanic was already deleted in v2-EE6 — keeping
   the label misrepresented the current mechanic. Spec explicitly
   required it gone.

**25% Light warning dialog preserved.** The `_onNotNow` skip path still
intercepts at `noorLevel == 25` with the "Your light is fading" dialog.
"Skip anyway" falls through to `_startXpCountUp` → `_afterXp` →
`_continueJourney`, where the -25 penalty lands per v2-EE6 rules.

**Passage screen hand-off preserved.** `_continueJourney` still detects
era-end passages and routes through `PassageScreen` before the tent.

## Architectural decisions

- **EE6.1 — no new prop on FogOverlay.** The multiplier formula lives at
  the call site in `immersive_event_screen.dart` because `rawiLightRadius`
  already takes a raw pixel number. Pushing the formula into FogOverlay
  would mean teaching the widget about `noorLevel` — breaks its "dumb
  painter" contract.

- **EE6.2 — keep pre-verdict `_triggerFogReveal`.** The spec reads
  "fog dissolves from current state to fully clear" after the verdict.
  The pre-verdict golden-tint burst + fog fade is a UX affordance
  (immediate reward on finishing all HS) and removing it would feel
  like a regression. Interpretation: the 3 s post-verdict is a
  quiet scene-held moment; if fog was already 0, the "dissolve" is
  a no-op but the beat still lands.

- **EE6.3 — `push`, not `pushReplacement`, and keep scene mounted.**
  `pushReplacement(opaque: false)` is still ambiguous in Flutter — the
  previous route is popped after the transition completes, which would
  race the scrim fade. `push` keeps both mounted; PopScope blocks
  back-nav; `pushAndRemoveUntil` on exit cleans up both. Memory cost
  is one extra scene tree for the duration of Unified (~ a few
  seconds) — acceptable.

- **EE6.3 — 3800 ms extra wait hardcoded after scroll shimmer.** Could
  have been expressed as "wait until 7 000 ms since scroll start" using
  a timestamp, but hardcoded mathing it from the known controller
  durations (3000 reveal + 200 shimmer) keeps the code in lockstep
  with the animation timings already defined above. If Khaled tunes
  those, this number should be re-derived.

- **EE6.3 — replays keep Continue button, fresh completions don't.**
  Fresh completions are a guided one-way flow to the tent; a Continue
  button between XP and tent would feel redundant and break the
  cinematic. Replays are the user deliberately re-reading a past
  event; kicking them out after 4 s would feel hostile. Hybrid
  resolution: `widget.alreadyCompleted` gates the behavior.

## Self-verification notes

Per spec §5 anti-iteration:

1. **EE6.1** — formula flow-traced at 5 Light values:
   - 100% → `(100/25)=4.0 clamp 0.5-4.0 → 4.0` × 60 = 240 ✓
   - 75% → `3.0` × 60 = 180 ✓
   - 50% → `2.0` × 60 = 120 ✓
   - 25% → `1.0` × 60 = 60 ✓
   - 10% → `0.4 clamp 0.5` × 60 = 30 ✓

2. **EE6.2** — walked the `_selectChoice` branch statically:
   - `_allAnswered && !_alreadyCompleted` path runs persistence
   - awaits (500 + 3000 + 1000) = 4500 ms total with `mounted` checks
     at each step (won't explode if user kills the app mid-beat)
   - `_completeAndPop` push is now non-opaque and keeps the scene visible
   - dim overlay + verdict card guards (`!_cinematicRevealActive`) both
     grep-confirmed in build method.

3. **EE6.3** — traced all three dhikr-resolution paths:
   - Hold-ring complete → `_onHoldComplete` → `setDhikrCompleted` +
     `_dhikrAcknowledged = true` → `_startXpCountUp` → XP count-up →
     `_afterXp` → (not-replay) 4 s → `_continueJourney` (no penalty
     since `_dhikrAcknowledged`).
   - "I've said it" (Reader mode) → `_onSaidIt` → same tail, no penalty.
   - Skip (any mode) → `_onNotNow` →
     - Light == 25? → warning dialog → "Skip anyway" proceeds;
       "Say dhikr" returns to card unmodified.
     - Light != 25? → straight through.
     - Either skip branch → `_startXpCountUp` → `_afterXp` →
       `_continueJourney` → -25 penalty (since `_dhikrAcknowledged` false).
   - No-dhikr event (`!_hasDhikr`) → scroll timer expires → skip dhikr
     section → `_startXpCountUp` → `_afterXp` → `_continueJourney`.

   **⚠️ KNOWN UNDERBAKED — `_canExit` stays false on fresh completions.**
   Because we removed the `_canExit = true` flips in the dhikr
   resolution paths, PopScope stays locked the entire flow on fresh
   completions (Android back button no-ops). This matches the spec's
   "auto-flow only" intent but means the user can't abort the XP beat
   if they want to. Accept for now — if Khaled finds the 4 s XP hold
   annoying in practice, flip `_canExit = true` inside `_afterXp`
   before the 4 s wait.

4. **Route transparency / scene-behind** — I can trace the widget tree
   on paper: ImmersiveEventScreen's Scaffold body Stack remains in the
   widget tree, Unified's transparent Scaffold sits above it. The 0.72
   scrim handles contrast. **Device-verify pending** — I can't confirm
   visually.

## Device verification checklist (Khaled on A56)

**EE6.1 — halo radius at 4 Light values:**
- [ ] Event 1 entry at 100% Light → halo covers roughly 4× base unit
      area around Rawi (≈ 240 px radius). Screenshot.
- [ ] Complete one event without dhikr → 75% → halo visibly smaller.
      Screenshot.
- [ ] Continue without dhikr → 50%, 25%, 10% floor → halo shrinks
      each step, barely-visible pool at 10%.
- [ ] Halo scales smoothly (no pop-in) as Light changes.
- [ ] HS hotspot halos look unchanged (70 px cosmetic halo).

**EE6.2 — cinematic reveal after verdict:**
- [ ] Answer the verdict on Event 1 → verdict card fades out → scene
      held quiet for ~4 s → Unified slides in. No Continue tap needed.
- [ ] During the 4 s beat: no dim overlay, no verdict card, just
      scene + figure.
- [ ] Works on BG-less events too (reveal over black BG).
- [ ] Replay a completed event → still gets the old Continue button
      immediately (no cinematic beat).

**EE6.3 — end-of-event flow:**
- [ ] After the reveal, scroll note rises over the scene BG — not a
      blank navy gradient. Scene visible through the scrim.
- [ ] Scroll auto-advances to dhikr after ~7 s total (no Continue
      tap required in this step).
- [ ] Dhikr section is the dhikr screen (hold ring / said-it / skip).
- [ ] No "Noor +50%" label anywhere near the hold ring.
- [ ] Complete the dhikr (hold or say-it) → XP counts up → 4 s hold
      → tent appears. Auto-flow, no Continue button in path.
- [ ] Skip the dhikr at 25% Light → warning dialog fires. Tap "Skip
      anyway" → XP → -25 penalty → tent. Light clamps to 10.
- [ ] Replay a completed event → still ends on a Continue button
      (user controls exit).
- [ ] Era-end event → passage screen plays as before.

**Regression-watch (not new in v4, but likely to be disturbed):**
- [ ] All v3 items still work (branching resume, title pill, tent
      dhikr lock, info-tab dismiss, tap-to-trigger HS).

## Out of scope (do NOT touch — confirmed untouched)

- MINOR items from R26-S1 spec (11 items) — parked for R26-S2.
- Reader mode bottom-sheet cards.
- R25 Sprint 5/6/7 backlog.
- BG asset generation.

## If verification passes

Next sprint target per spec §3 is **R26-S2 = the original MINOR bundle**
(11 items of polish): tent stat pills collapsible, refresh button,
progress bar thickness, Start button style, tent exit dialog, event
exit dialog, info tab inner spacing, info tab chevron circle, info
tab AR RTL, joystick explainer, one item I forgot.

## If any item fails

Per two-strike rule: paste symptom + debug log (the `noor:
setNoorLevel(x)→y` traces still run from v2) + screenshot if visual.
Diagnose before patching.

---

_Handoff v4 — Apr 21 2026 afternoon._
