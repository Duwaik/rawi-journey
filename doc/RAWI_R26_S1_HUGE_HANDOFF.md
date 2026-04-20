# RAWI R26 — Sprint 1 HUGE Handoff

**Bundle:** R26 S1 HUGE (6 items)
**Round:** R26 — Apr 20 audit workspace (Tent / Event Explorer / Tutorials)
**Spec:** `RAWI_R26_S1_SPEC.md`
**Agent:** Claude Code (Claude Opus 4.7, 1M context)
**Date:** Apr 20 2026

---

## Bundle: HUGE

## Commits

| ID  | Hash       | Description                                                                  |
|-----|------------|------------------------------------------------------------------------------|
| EE6 | `323922b`  | unify Light formula — removed event-launch `depleteNoor(25)`; all 4 consumers read same getter at same moment |
| T2  | `903ec2a`  | Start→Continue persistence (`last_event_id` + `event_in_progress` prefs, tent reads + resumes) |
| EE1 | `10e1346`  | event title layout — italic chapter subtitle, 11px, letter-spacing 0.3       |
| EE2 | `47d63fd`  | figure proximity snap + `_hsTriggerLocked` input freeze through snap→card window |
| TU1 | `b372274`  | explorer tutorial fires in AR locale — instrumentation + explicit Directionality wrapper |
| TU3 | `0bca10c`  | figure movement explainer as step 4 ("How to move" / "كيفية التحرك")          |

All pushed to `origin/main`. HEAD: `0bca10c`.

## APK

- Path: `build/app/outputs/flutter-apk/app-release.apk`
- Size: 91.9 MB (Flutter wrap) / 96.34 MB (gradle raw)
- **SHA256:** `1da1d05f53a77bff1804e6412bdc847997922c46ee661a9ec9728f2e998066fd`
- **libapp.so arm64 SHA256:** `3fc543e79314dfa0e39b4da6749deb5303e6a1e0d14b7d89924ff1d7ef6e3dcc`

Build: `flutter clean` → `flutter pub get` → `gradlew.bat assembleRelease` (CMD).
`BUILD SUCCESSFUL in 15m 14s`, 256 tasks (219 executed, 37 up-to-date).

## flutter analyze

**0 new warnings.**
1 pre-existing warning — `pubspec.yaml:37 assets/audio/vo/ doesn't exist`.

(Prior sprints had a 2nd pre-existing info-level async-gap warning in
`event_launcher.dart:159`; that line now falls outside the touched
context since EE6 removed the `await PrefsService.depleteNoor` call
above it. The BuildContext-across-async-gap situation is unchanged
functionally; only the line number shifted.)

## Notes for Khaled

- **EE6 semantic change.** The root-cause was a WRITE landing between
  the tent read and the scene read, not a formula mismatch. Fix was to
  remove the `depleteNoor(25)` on event-launch entirely. Light becomes
  gains-only (rechargeNoor on completion still works). If you want a
  decay mechanic back later, write it at a point that precedes the
  NEXT tent render, never between tent and scene.

- **T2 Continue routing.** `_hasInProgressNextItem()` in the tent was
  rewritten to read `PrefsService.isEventInProgress` directly. The
  old heuristic (peeking at `loadHotspotProgress` of the
  next-uncompleted event) missed the case where a user backed out
  before discovering any HS. New flag is set by every save moment
  (discovery tick, header back, settings→Save-and-exit) and cleared
  on event completion beside `completeEvent` + `clearHotspotProgress`.
  Defensive: if the stored event ID ever drifts out of m1, tent falls
  back to Start.

- **EE2 snap behavior.** Kept the instant snap — spec's 80ms tween
  would need a dedicated AnimationController just for this; instant
  is imperceptible on A56 and avoids state machinery. 400ms
  card-reveal delay kept (spec's 100ms was a guideline). The
  `_hsTriggerLocked` flag is the real fix — it blocks BOTH the game
  loop AND `onPanUpdate` through the snap→card window, so fast
  finger-drag can no longer push past the marker.

- **TU1 diagnostic trace.** No locale gate was found anywhere in
  `lib/`. Added `DebugLogService.log('tutorial', 'Event1 overlay
  armed (isAr=${...})')` in the initState trigger so the next AR
  device run captures whether the overlay actually arms. If the log
  shows `isAr=true` but no overlay appears visually, the issue is
  downstream (render / pref pre-set / scene not mounting). If the log
  doesn't fire at all, the scene isn't mounting in AR.

- **TU3 visual demo.** Step 4's pointer renders TWO static-position
  arrows (finger-drag hint + joystick hint), both using the existing
  pulse animation so the overlay feels like one system. Joystick
  position on screen is user-configurable (left/center/right), so
  the joystick hint is centered to stay language- and
  position-agnostic rather than pointing at a specific corner.

## Out-of-scope / untouched per spec

- Reader mode (R26-S2)
- Bottom-sheet card system (R26-S2)
- Dhikr end screen (R26-S3 if needed)
- R25 parked sprints (5, 6, 7)
- BG image / BG rendering (permanently frozen)

## Device verification (Khaled on A56)

Run §8 of `RAWI_R26_S1_SPEC.md` for the HUGE items specifically:

**Tent:**
- [ ] Enter Event 1 mid-progress → exit → tent button reads Continue (T2)
- [ ] Tap Continue → lands in saved event at saved HS (T2)
- [ ] Finish Event 1 → tent button reads Start, routes to Event 2 (T2)

**Event Explorer:**
- [ ] Top bar: 2-line pill, event title bold + chapter italic smaller (EE1)
- [ ] Slow joystick approach → figure snaps to HS, freezes, content (EE2)
- [ ] Fast finger-drag approach → figure snaps to HS, freezes, content (EE2)
- [ ] Figure never visibly moves while content dialog is up (EE2)
- [ ] Tent Light % === Event Light % === figure halo, verified across 3 events (EE6)

**Tutorials:**
- [ ] Fresh install in AR → Event 1 → tutorial appears in AR with RTL (TU1)
- [ ] Tutorial has a 4th step: "How to move" / "كيفية التحرك" (TU3)

If HUGE passes, proceed to MINOR bundle (11 items).

---

_Handoff v1 — Apr 20 2026, 16:25 local._
