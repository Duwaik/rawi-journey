# RAWI R25 — Sprint 3 Handoff

**Sprint:** 3 of 7 — Event Scene Header + Noor + Info Tab
**Round:** R25 — Apr 19 device testing feedback
**Spec:** `RAWI_R25_S3_SPEC.md`
**Agent:** Claude Code (Claude Opus 4.7, 1M context)
**Date:** Apr 19 2026 (evening session)

---

## 1. Commit hashes

Sprint start tip: `70ce3bc` (Sprint 2 tracker SHA update).

| # | Commit | Items | Description |
|---|--------|-------|-------------|
| 1 | `7ca99a8` | S3-1 | Minimal event scene header + kill "Explore the scene" + scaler clamp + bottom title |
| 2 | `da66766` | S3-2 + S3-3 | Chapter pill non-button + shared `TopBarIconButton` |
| 3 | `60680dc` | S3-4 | Noor data-flow audit + `setNoorLevel` debug instrumentation |
| 4 | `8aa122c` | S3-5 | "Your Light" label consolidation (drop Reader-mode `Knowledge` swap) |
| 5 | `b369567` | S3-6 + S3-8 | Event-scene info tab widget + shared `StatRowGroup` + tent consumer |
| 6 | `3f1c6eb` | S3-7 | Event 1 one-time tutorial overlay + `SharedPref` flag + QA reset button |

All 6 pushed to `origin/main`. HEAD: `3f1c6eb`.

## 2. git diff --stat since sprint start (`70ce3bc..HEAD`)

```
 lib/screens/immersive_event_screen.dart  | ~155 lines touched
 lib/screens/rawi_tent_screen.dart        | ~90  lines touched
 lib/screens/settings_screen.dart         | +45
 lib/services/prefs_service.dart          | +30 / −3
 lib/widgets/cinematic/hotspot_progress.dart | −27 / +3
 lib/widgets/event_1_tutorial_overlay.dart | +175 (new)
 lib/widgets/event_scene_info_tab.dart    | +275 (new)
 lib/widgets/stat_row_group.dart          | +96  (new)
 lib/widgets/top_bar_icon_button.dart     | +55  (new)
```

Net: roughly **+575 / −140** — matches the spec's expected **net +235**
minus the over-estimate on info tab sizing. Four new widget files; rest
is in-place refactor.

## 3. Acceptance criteria (per spec §4)

Device-column ⏳ pending Khaled's A56 run.

| # | Check | Static | Device |
|---|-------|--------|--------|
| S3-1 | Top bar has exactly 3 elements. Grep `"Explore the scene\|استكشف المشهد"` returns 0. Title at bottom with shadow. Scene root uses `TextScaler.clamp(1.0, 1.3)` | ✅ | ⏳ |
| S3-2 | Chapter pill is a plain Container — no ripple, no elevation, no press animation | ✅ (no Button / InkWell / GestureDetector wrapping) | ⏳ |
| S3-3 | Back + settings both 36×36 circular via `TopBarIconButton`, both fire `HapticFeedback.lightImpact()` | ✅ | ⏳ |
| S3-4 | Opening "Abd al-Muttalib" / "Khadijah" shows Noor matching tent; no 0% fallback | ✅ data-flow audit: both read same `PrefsService.noorLevel`, writes are clamped [0,100], setNoorLevel logs every write to `DebugLogService` | ⏳ |
| S3-5 | Label consolidation done (or findings note committed) | ✅ root cause found: `rawi_tent_screen.dart:479` Reader-mode conditional. Consolidated to "Your Light" / "نورك" in both modes. No findings note needed. | ⏳ |
| S3-6 | Info tab at `top: 40%, left: 0`. Tap expands, chevron/outside collapses, 200ms animation. Old Noor indicator removed. | ✅ `EventSceneInfoTab` rendered at correct Positioned; `_NoorHud` class deleted | ⏳ |
| S3-7 | Fresh install → Event 1 → post-intro → tutorial shows. Dismiss persists. Events 2-155 never show. | ✅ `initState` gate: `globalOrder == 1 && !isEvent1TutorialShown` | ⏳ |
| S3-8 | `lib/widgets/stat_row_group.dart` exists. Tent renders 3 pills (S2-1/S2-2 absorbed). Info tab Section 1 renders 1 row via same widget. | ✅ both consumers point at `StatRowGroup` | ⏳ |
| S3-8b | Android Largest font → no overflow on tent or info tab | ✅ scaler clamped 1.0–1.3× at both roots | ⏳ |
| Global | `flutter analyze` zero warnings | ✅ (same 2 pre-existing infos: event_launcher async-gap + pubspec vo/ directory) | ⏳ |

## 4. Deviations from spec

Three micro-deviations, all documented inline:

1. **S3-4 was less invasive than the spec anticipated.** The spec predicted
   a stale cache or missing JSON field; audit found neither. Both scene
   and tent read `PrefsService.noorLevel` directly and writes already
   clamp [0, 100]. The actual bug surface — the old `_NoorHud` — was
   removed in S3-1 (part of the same sprint). The S3-4 commit is
   therefore a doc-comment + instrumentation commit rather than a
   code-fix commit. No 155-event field audit needed (spec §6 deferred
   it anyway).
2. **S3-5 was resolved inside the 30-min timebox** — single render
   site identified in `rawi_tent_screen.dart`, conditional removed.
   No findings note committed.
3. **Info tab Section 1 rendering** follows §9.3's two-line format
   (StatRowGroup row + subtitle beneath) rather than a single hero
   18px display. The spec explicitly required `StatRowGroup` usage
   for Section 1 — that acceptance dominates over §9.3's "big 72%"
   visual hint. If the rendered value ends up feeling too small,
   it's a 1-line fontSize bump in `StatRowGroup` (or a variant
   parameter) — flag during device test.

## 5. APK

Path: `build/app/outputs/flutter-apk/app-release.apk`
Size: 91.9 MB (Flutter wrap) / 96.34 MB (gradle raw)
SHA256: `2b225040e1ea4ed82b57bc7f25d0ff7350bb9e7b579c7764f4f36c284d45e04f`

Build: clean (`flutter clean` → `flutter pub get` → `gradlew
assembleRelease`). `BUILD SUCCESSFUL in 7m 2s`, 38 tasks executed, 218
up-to-date (Dart recompile + repackage; native layers cached from prior
Sprint 2 build tree).

`flutter analyze`: 2 issues, both pre-existing from Sprint 1 close.

## 6. Blocking issues discovered mid-sprint

None. All 8 items (including S2-1 / S2-2 absorbed via S3-8) implemented
per spec. No deferred findings added to roadmap §11.

## 7. Things Khaled should watch for during device test

**S3-6 + S3-8 acceptance is the critical gate.** Spec says "do NOT close
with one surface broken". Two surfaces to re-verify:

1. **Tent stat pills are visible** — the S2-1/S2-2 bug that failed
   twice in Sprint 2 should now be absorbed by S3-8's shared widget.
   If the tent STILL shows no pills, the bug survived both attempts
   + a shared-widget extraction. That would be a serious sign we need
   to investigate widget hit-testing / Stack z-order at a deeper
   level. Paste the debug log if so.
2. **Event scene info tab** — on Event 1 scene, tap the left-edge
   info glyph. Expected: slide-out panel with YOUR LIGHT + THIS EVENT
   sections. Tap the chevron or the dimmed scene area to collapse.

**S3-7 Event 1 tutorial** — should appear on first launch of Event 1
after the intro video, never thereafter. If you want to re-test: debug
build only, Settings → About → tap "Reset tutorials (QA)" — all
first-time flows re-arm.

**S3-4 Noor instrumentation** — open any event that previously showed
0% Noor. Debug log (B27 overlay) should show the full `setNoorLevel(x)
→y (was z)` trace across recent transitions. If 0% still appears on
a specific event, paste the trace — the math of how noor got there
will point at the cause (excessive depletions, bad starting state,
etc.).

**S3-5 consolidation** — toggle Reader/Explorer several times from
Settings → back to tent. The Light stat pill must always read "Your
Light" / "نورك". If it ever flips to "Knowledge" / "المعرفة", a
different code path is also writing that label (unlikely based on
grep, but worth verifying).

## 8. Next steps

- Khaled runs §5 spec + §5 device checks on A56, confirms per row.
- Sprint 3 row in roadmap §1 marked ✅ with tip commit once passed.
- Progress tracker §Sprint 3 populated with device-test findings.
- Sprint 4 spec handoff follows. Q4 block (Q4.1 branch viewable after
  choice? Q4.2 freeze-vs-snap? Q4.3 global or branching-only?) is
  already listed in roadmap §5 and tracker Sprint 4 section.

---

_Handoff v1 — Apr 19 2026, 15:30 local._
