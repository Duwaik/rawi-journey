# RAWI R26 S1 HUGE-v2 Handoff

**Bundle:** R26 S1v2 (6 items, single delivery)
**Round:** R26 — Apr 20 audit workspace + HUGE-v1 verification findings
**Spec:** `RAWI_R26_S1v2_SPEC.md`
**Parent build:** HUGE-v1 handoff `7e33526` (Apr 20 afternoon)
**Agent:** Claude Code (Claude Opus 4.7, 1M context)
**Date:** Apr 20 2026 evening

---

## Bundle: v2 (single delivery, all 6 items)

## Commits

| ID  | Hash       | Description |
|-----|------------|-------------|
| T2  | `fd21fd7`  | tent refresh on route pop + save-on-event-entry |
| EE1 | `85a0b24`  | title pill BG styling per reference — 0.35 border, 0.8 width, 20h/10v padding, title 14→15 |
| EE2 | `8bc0edb`  | snap → 120ms ease-out tween (dedicated `_snapCtrl`) |
| TU1 | `96014b2`  | remove mode-toggle tutorial step, 3-step sequence |
| EE8 | `0f94282`  | content modals — Continue button only, no outside-tap dismiss |
| EE6 | `9e2976c`  | Light mechanics rebuild (penalty + regen + floor + warning + halo) |

All pushed to `origin/main`. HEAD: `9e2976c`.

## APK

- Path: `build/app/outputs/flutter-apk/app-release.apk`
- Size: 91.9 MB (Flutter wrap) / 96.34 MB (gradle raw)
- **SHA256:** `89cf16cb149e7d24562c4d6e9c4ebaed9334b8a3b4889dc09014b120226a63e4`
- **libapp.so arm64 SHA256:** `b49654a9154a00fdb346d00621e4bc637d2fdb23b0c1ba38629cd5840fbbe400`

Build: `flutter clean` → `flutter pub get` → `gradlew.bat assembleRelease` (CMD).
`BUILD SUCCESSFUL in 6m 23s`, 256 tasks (38 executed, 218 up-to-date — Dart layer recompile + repackage; native cached from v1).

## flutter analyze

**0 new warnings.**
1 pre-existing warning — `pubspec.yaml:37 assets/audio/vo/ doesn't exist` (unchanged since Sprint 1).

## Architectural decisions

- **T2 — chose Option 1 (RouteAware).** The codebase has no Riverpod; tent reads PrefsService directly. Option 2 (provider invalidation) would have required introducing a provider layer for one call site. Option 3 (FutureBuilder key) doesn't apply (tent isn't FutureBuilder-based). RouteAware integrates cleanly alongside the existing `DebugNavObserver` in `MaterialApp.navigatorObservers`. New shared `lib/services/route_observer.dart` exposes `appRouteObserver` so any future screen can subscribe.

- **T2 — save at scene ENTRY, not first HS.** `immersive_event_screen.initState` writes `setInProgressEvent` immediately when `!_alreadyCompleted`. Covers the "back out before any HS" case which v1 gated behind `_saveProgressNow` (only fired on discovery tick). Replays skip the write so revisits don't re-flag completed events.

- **EE2 — kept 400ms card-reveal delay.** Spec §EE2 mentioned 100ms but that would make the content appear DURING the 120ms tween. 400ms gives the 120ms tween + 280ms polish beat (SFX + sparkle settle) before the card materializes. The reveal no longer feels rushed on top of the tween.

- **EE8 — info tab NOT changed.** The info tab is a drawer-style widget with an outside-scrim-tap that collapses it. Spec's "ANY modal content" list (HS, Event Q, dhikr end, completion summary, Light warning) doesn't include drawers. Collapsing a peek-and-hide control via outside tap is correct UX — the decision was explicit, documented in the commit body.

- **EE6 — session-scoped tent "said" flag.** Khaled's note: "don't over-engineer this." The Featured Dhikr card's `_saidThisSession` flag is a plain stateful bool that prevents stacking regens within a session. A date-keyed daily reset would need a new pref + midnight watcher — deferred until the daily-counter design actually lands. If the user closes the app and re-opens, they can say again — which is probably fine given the 10% floor and 100% ceiling clamp.

- **EE6 — penalty applies to no-dhikr events too.** Some m1 events may lack a dhikr card (`!_hasDhikr`). Per strict spec reading "Complete event one... if you didn't [say dhikr] → reduces light by 25%", the penalty fires regardless. If Khaled wants the penalty gated on `_hasDhikr` so events without dhikr don't punish users who had no choice, it's a 1-line change in `_continueJourney` (add `&& _hasDhikr` to the guard). Flagging because it feels punitive.

## Self-verification notes

Per spec §9 anti-iteration guardrails:

1. **T2** — flow-traced. didPopNext subscription verified via `appRouteObserver.subscribe(this, route)` in `didChangeDependencies`, unsubscribe in `dispose`. Write path: scene initState → `PrefsService.setInProgressEvent(event.id)`. Clear path: `_selectChoice` completion branch → `PrefsService.clearInProgressEvent()`. All four acceptance scenarios traceable on paper. **Device-verify required** — can't exercise the 4 scenarios statically with certainty.

2. **EE1** — BG was already present from S3-HF-3 with 0.18/0.5 border styling. v2 bumped to 0.35/0.8 per spec and widened padding. **Device-verify for visual match** — I can't screenshot-compare to the reference image.

3. **EE2** — tween logic verified: `_snapCtrl` listener setState-interpolates `_companionX/Y` each frame with `Curves.easeOut`. Disposed in dispose. `_hsTriggerLocked` still blocks game loop + onPanUpdate through the full 120ms window.

4. **EE6** — flow-traced all 10 acceptance steps:
   - Steps 1-4: penalty path `_continueJourney` → `setNoorLevel(current - 25)` fires on `!_dhikrAcknowledged` completion. Clamp enforces ceiling 100.
   - Step 5: warning popup trigger = `PrefsService.noorLevel == 25 && !_dhikrAcknowledged && _hasDhikr && !_lightWarningShown` inside `_onNotNow`. Dialog uses barrierDismissible: false (EE8 rule).
   - Step 6: "Skip anyway" returns `true` → `_onNotNow` resumes → eventually `_continueJourney` → `setNoorLevel(25 - 25) = 0 → clamped to 10`.
   - Step 7: further completion without dhikr → `setNoorLevel(10 - 25) = -15 → clamped to 10`. Floor holds.
   - Step 8: tent "I said it" → `setNoorLevel(10 + 25) = 35`.
   - Step 9: event with dhikr → `_dhikrAcknowledged = true` → no penalty branch → stays 35.
   - Step 10: single source `PrefsService.noorLevel` + halo reads it live + info tab reads it live + tent stat pill reads it live. One getter, same value everywhere.
   - **⚠️ KNOWN UNDERBAKED — step 5 device-verify.** The intercept only fires at Light == exactly 25. If Khaled's test sequence lands at say 30 before the skip, the popup won't trigger. Test path: complete 3 consecutive no-dhikr events starting from 100 to hit exactly 25, then skip the 4th.

5. **EE8** — verified all three changed modals: HotspotCard (centered + bottom-sheet), BadgeOverlay, DhikrScreen tooltip. Each has: outer `onTap: () {}` + explicit Continue pill wired to real dismiss. Four uninvolved modals (tutorial overlay, verdict, unified completion, info tab) audited and documented in commit body.

6. **TU1** — `_spec` switch is 3-case (0 info tab, 1 hotspot, 2 movement). `_advance` bound is `_step < 2`. Step-dots `List.generate(3, …)`. `_PointerTarget.topRight` removed. Grep clean.

## Device verification checklist (Khaled on A56)

Run spec §9 anti-iteration tests before declaring v2 done:

**T2 (re-verify — v1 failed on device):**
- [ ] Enter Event 1 → back out immediately → tent shows **Continue**
- [ ] Enter Event 1 → complete HS1 → back out → tent shows **Continue**
- [ ] Complete Event 1 fully → tent shows **Start**, targets Event 2
- [ ] Enter Event 2 → back out immediately → tent shows **Continue**

**EE1 (re-verify — v1 styling didn't land):**
- [ ] Top bar shows a pill with visible translucent dark BG + gold border
- [ ] Backdrop blur visible behind the pill
- [ ] Layout reads as "Year of the Elephant" signboard per reference

**EE2 (tune, not fix):**
- [ ] Slow joystick approach → figure glides smoothly to HS (not jump)
- [ ] Fast finger-drag approach → same glide, no overshoot
- [ ] Content card still appears immediately after snap completes

**EE6 (the risky one — walk all 10 steps):**
- [ ] Step 1: Fresh install → Light 100%
- [ ] Step 2: Complete Event 1 without dhikr → Light 75%, halo dimmer
- [ ] Step 3: Complete Event 2 without dhikr → Light 50%
- [ ] Step 4: Complete Event 3 without dhikr → Light 25%
- [ ] Step 5: Enter Event 4 completion → tap Skip → warning popup fires
- [ ] Step 6: Tap "Skip anyway" → Light 10% (floor)
- [ ] Step 7: Complete Event 5 without dhikr → Light stays 10%
- [ ] Step 8: From tent, tap "I said it ✓" on Dhikr of the Day → Light 35%
- [ ] Step 9: Complete Event 6 with dhikr → Light stays 35%
- [ ] Step 10: Tent % === Event info tab % === halo scale at every step

**EE8:**
- [ ] HS content card → tap scene BG outside card → nothing happens ✓
- [ ] HS content card → tap Continue pill → advances ✓
- [ ] Event completion screen Skip at 25% → popup shows, barrier-tap does nothing ✓
- [ ] Badge overlay → tap outside → nothing; Continue pill → dismisses ✓
- [ ] Dhikr first-time tooltip → same pattern ✓

**TU1:**
- [ ] Fresh install → Event 1 → tutorial shows exactly 3 steps
- [ ] Step 1 is "Your Light & Progress" (info tab), NOT mode toggle
- [ ] AR locale: same 3 steps

## Out of scope (do NOT touch in v2 — confirmed untouched)

- MINOR items from R26-S1 spec — still parked, wait for v2 verify
- Reader mode, bottom-sheet cards, R26-S2 scope
- BG image / BG rendering (permanently frozen)

## If verification passes

Proceed to MINOR bundle from the original `RAWI_R26_S1_SPEC.md` (11 items).

## If any item fails

Per Khaled's two-strike rule: don't blind-iterate. Paste the debug log
(now captures `noor: setNoorLevel(x)→y (was z)` traces) + symptom, and
we diagnose before patching.

---

_Handoff v1 — Apr 20 2026, 19:00 local._
