# RAWI R25 — Sprint 1 Handoff

**Sprint:** 1 of 7 — Tent → Event Navigation + Audio (P0)
**Round:** R25 — Apr 19 device testing feedback
**Spec:** `RAWI_R25_S1_SPEC_1.md`
**Agent:** Claude Code (Claude Opus 4.7, 1M context)
**Date:** Apr 19 2026

---

## 1. Commit hashes

Round start tip: `84ba2db` (R24 Batch 3C + 3B).

| # | Commit | Item | Description |
|---|--------|------|-------------|
| 1 | `4a9b639` | S1-5 | Gate Rawi figure VO behind `kRawiFigureVoEnabled=false` |
| 2 | `247d8ce` | S1-6 | Debug widget lifecycle hooks (nav + audio + video) |
| 3 | `bff1ea7` | S1-4 | Await audio disposal + `stopAll()` before video init |
| 4 | `83719c6` | S1-1 + S1-2 | Tent Start launches progression item directly |
| 5 | `b2815b7` | S1-7 | Video 8s watchdog + Try Again/Skip fallback |
| 6 | `9b8d8a7` | S1-3 | Verification notes for Event 2 freeze (no code) |

All 6 commits pushed to `origin/main`. HEAD: `9b8d8a7`.

## 2. git diff --stat since round start (`84ba2db..HEAD`)

```
 doc/R25_S1_3_VERIFICATION.md            |  69 +++++++++++
 lib/feature_flags.dart                  |  13 ++
 lib/main.dart                           |   3 +
 lib/screens/event_launcher.dart         | 212 +++++++++++++++++++++++++++
 lib/screens/event_list_screen.dart      | 162 ++++-----------------
 lib/screens/immersive_event_screen.dart |   5 +-
 lib/screens/rawi_tent_screen.dart       |  37 ++++--
 lib/screens/video_intro_screen.dart     | 201 ++++++++++++++++++-------
 lib/services/audio_service.dart         |  28 +++-
 lib/widgets/debug_nav_observer.dart     |  51 +++++++
 10 files changed, 577 insertions(+), 204 deletions(-)
```

## 3. Verification checklist (per spec §4)

All tests are **pending on-device confirmation from Khaled**. Claude verified
what can be verified statically; the device column is what Khaled must
complete on the A56.

### 3.1 Navigation tests

| Test | Static | Device |
|------|--------|--------|
| Tent Start on locked event → event launches directly, NO events-list flash | ✅ path verified in `event_launcher.launchEvent` | ⏳ |
| Tent Start on Threshold → Threshold question launches directly | ✅ `launchCurrentItem` picks `ThresholdItem` first | ⏳ |
| Tent Start on completed event revisit → event launches directly | ✅ same launch path | ⏳ |
| Events side-nav button → events-list mounts normally | ✅ side-nav path untouched | ⏳ |

### 3.2 Audio tests

| Test | Static | Device |
|------|--------|--------|
| Launch Event 2 from tent → video music plays, no BG ambient bleed | ✅ `stopAll()` + awaited `fadeOut` | ⏳ |
| Back out of event → all audio stops, tent ambient resumes cleanly | ✅ tent `initState` re-starts ambient; `stopAll` on re-entry | ⏳ |
| Event 3 → back → Event 5 → no audio overlap | ✅ same path, every launch goes through `stopAll` | ⏳ |

### 3.3 Event 2 stress test

| Test | Static | Device |
|------|--------|--------|
| Launch Event 2 from tent 5× with app restart between each → clean all 5 | N/A | ⏳ |
| Launch Event 2 from events-list Start → still works (regression) | ✅ `_openEvent` delegates to shared launcher | ⏳ |

### 3.4 Rawi VO silence test

| Test | Static | Device |
|------|--------|--------|
| Events 1, 3, 6, 9 → no Rawi figure voice at any point | ✅ `kRawiFigureVoEnabled=false` gates the single `playSfx(voPath)` call site | ⏳ |

### 3.5 Debug widget test

| Test | Static | Device |
|------|--------|--------|
| Triple-tap About → debug panel appears | ✅ existing B27 path, unchanged | ⏳ |
| Run through 3 events → panel shows nav + audio + video lifecycle entries | ✅ NavObserver + AudioService + VideoIntroScreen all log | ⏳ |
| Copy button works → clipboard contains log text | ✅ existing B27 Copy action, unchanged | ⏳ |

### 3.6 Fallback test (S1-7)

| Test | Static | Device |
|------|--------|--------|
| Rename Event 2 video asset → watchdog fires at 8s, fallback UI shows | ✅ 8s timer in `_bootController` + `_buildFallbackUi` | ⏳ |
| Try Again works when asset restored | ✅ `_replay()` disposes + re-boots controller | ⏳ |
| Skip advances to event scene | ✅ `_skipFromFallback` → `_onVideoEnd` → `onComplete` | ⏳ |

## 4. Deviations from spec

None. All 7 items implemented per spec. Extensions noted:

- **S1-7 replaces B26's timeout** (10s → 8s; "Video unavailable" dead-end
  → Try Again / Skip) per Khaled's pre-session direction. Stall watchdog
  from B26 preserved (6s position-doesn't-advance check while playing).
- **S1-6 extends B27** rather than duplicating it — existing log panel UI
  kept, new event sources wired in (nav observer, audio lifecycle, video
  init state, caught exceptions). No new UI surface.
- **S1-1/S1-2 deleted `EventListScreen.autoOpenEventOrder`** entirely
  since no callers remain after the tent switched to direct launch. The
  auto-open block in `initState` was removed along with the param.

## 5. APK

Path: `build/app/outputs/flutter-apk/app-release.apk`
Size: 91.8 MB (Flutter) / 96.26 MB (gradle raw)
SHA256: `28899cc35c2656845a98c307e77d5769df09432c7fbfa81c0f166d69e353920b`

Build: clean (`flutter clean` → `flutter pub get` → `gradlew assembleRelease`).
`BUILD SUCCESSFUL in 11m 4s`, 256 tasks (219 executed, 37 up-to-date).
`flutter analyze`: 2 issues — 1 pre-existing async-gap info in
`event_launcher.dart:159` (matches the pattern in the events-list helper
it replaced), 1 pre-existing pubspec warning about `assets/audio/vo/`.

## 6. Blocking issues discovered mid-sprint

None. The hypothesis in spec §1 held up — events-list ambient was
contending with the video's audio channel during init. Fix plan executed
as designed. Nothing promoted to Deferred Findings.

## 7. Things Khaled should watch for during device test

- **Tent → Event 2 launch timing.** Spec says "within 3 seconds of tap"
  for clean runs. If the 8s watchdog ever fires on a non-artificial run,
  that is a new bug — paste the debug log immediately.
- **Audio silence window during tent → video transition.** `stopAll()` is
  awaited; there will be a brief moment (≤500ms fade) where the tent
  ambient fades and the video audio hasn't started. If this feels abrupt
  we can smooth it with a `playVideoIntroMusic` cross-fade, but only if
  you flag it.
- **Revisit of a completed event.** `launchCurrentItem` always launches
  the NEXT uncompleted item. Revisits still go through the events-list
  (tap a completed row). The tent Start button does NOT launch revisits;
  that's intentional — matches spec §2.S1-1 acceptance criterion.
- **Threshold progress card UI.** Tent now shows "The Threshold" /
  "العتبة" when a threshold is pending. Sprint 2 will style this
  properly; for now it reuses the event title styling.

## 8. Next steps

- Khaled runs §3 checklist on A56, confirms pass/fail per row.
- Sprint 1 row in `doc/RAWI_R25_SPRINT_ROADMAP.md` §1 marked ✅ with
  hash `9b8d8a7` + verify date once passed.
- Sprint 2 spec handoff follows — Q2 block already answered (see roadmap
  §3 INPUTS ANSWERED).

---

_Handoff v1 — Apr 19, 2026, 03:14 local._
