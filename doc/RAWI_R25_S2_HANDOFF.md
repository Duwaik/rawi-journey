# RAWI R25 — Sprint 2 Handoff

**Sprint:** 2 of 7 — Tent Screen Layout
**Round:** R25 — Apr 19 device testing feedback
**Spec:** `RAWI_R25_S2_SPEC.md`
**Agent:** Claude Code (Claude Opus 4.7, 1M context)
**Date:** Apr 19 2026

---

## 1. Commit hashes

Sprint start tip: `ef47b1b` (Sprint 1 close + progress tracker).

| # | Commit | Items | Description |
|---|--------|-------|-------------|
| 1 | `189038e` | S2-1 + S2-2 | Stat pills container (Light + XP + Dhikr) |
| 2 | `1720998` | S2-3 | Remove "Your Journey" label above progress card |
| 3 | `f9f4c31` | S2-4 + S2-5 | Progress card row + centered title |
| 4 | `079ef4e` | S2-6 | Unified greeting with name inline |
| 5 | `631af4b` | S2-7 | TextScaler clamp + nav label minimum |
| 6 | `ee2f6ad` | S2-8 | Drop per-event hotspot dots from events-list |

All 6 commits pushed to `origin/main`. HEAD: `ee2f6ad`.

## 2. git diff --stat since sprint start (`ef47b1b..HEAD`)

```
 lib/screens/event_list_screen.dart  |  41 +---------
 lib/screens/rawi_tent_screen.dart   | 244 ++++++++++++++-----------------
 2 files changed, 126 insertions(+), 159 deletions(-)
```

Net **−33 lines** — Sprint 2 simplified more than it added, matching the
spec's expected −50 LoC range. All changes confined to the two files the
spec named.

## 3. Acceptance criteria (per spec §5)

Static verification done. Device-column ⏳ pending Khaled's A56 run.

| # | Check | Static | Device |
|---|-------|--------|--------|
| S2-1 | Three stat pills in one container, dividers visible | ✅ `_buildStatPillsContainer` with three `_statRow` + two `_statDivider` | ⏳ |
| S2-1 | Dhikr count matches what dhikr sheet shows | ✅ reads `PrefsService.dhikrCompletedCount`, same source the sheet/settings use | ⏳ |
| S2-2 | Zero-state `🤲 Dhikr 0`; +1 on completion | ✅ counter reflects live pref value on every rebuild | ⏳ |
| S2-3 | No ghost box, "Your Journey" label gone | ✅ label Positioned block deleted | ⏳ |
| S2-4 | Button + count on same line, ~4px off card edges | ✅ Row with `spaceBetween`, `Padding(horizontal: 4)` wrapper | ⏳ |
| S2-4 | Button label `Start` fresh / `Continue` mid-progress, no `x/4` | ✅ `_hasInProgressNextItem` gates `_buildStartContinueButton(isContinue)` | ⏳ |
| S2-5 | Title centered, breathing room above + below | ✅ `Padding(bottom: 12)`, `TextAlign.center`, 13/14px | ⏳ |
| S2-6 | Greeting `Assalamu Alaykom, {name}` (EN) / `السلام عليكم، {name}` (AR) | ✅ `_greeting` getter; no time-of-day logic remains | ⏳ |
| S2-6 | Grep clean of old greeting strings | ✅ `grep -r "Good morning\|Good evening\|Good afternoon\|صباح الخير\|مساء الخير" lib/` returns zero hits | ⏳ |
| S2-7 | Largest font size doesn't break tent | ✅ root `MediaQuery.textScalerOf().clamp(1.0, 1.3)` + nav label bumped 7 → 9 | ⏳ (manually verify on device) |
| S2-8 | Events list rows have no per-event dots or `x/4` | ✅ `_buildProgressDots` call + method deleted, `hasScene`/`hotspotCount` locals removed | ⏳ |

## 4. Deviations from spec

Two micro-deviations, both documented inline:

1. **Ghost box (S2-3) had no structural duplication.** The spec
   predicted a wrapper `Container` with decoration holding a child
   `Container` with its own decoration. The tent's progress card only
   has one decorated `Container`; the "ghost box" Khaled saw was the
   floating "Your Journey" label positioned 120px above the card. That
   label's removal also satisfies the spec's "label is removed entirely"
   requirement — single commit handled both symptoms.
2. **Journey-complete state (isComplete)** kept the existing
   "اكتملت الرحلة ✦" / "Journey complete ✦" text in the centered title
   slot, with button row hidden. Spec §S2-4 focuses on Start/Continue
   for active journeys but doesn't prescribe the complete-state UI; I
   preserved the existing celebration label so finished users still
   get the gold flourish.

## 5. APK

Path: `build/app/outputs/flutter-apk/app-release.apk`
Size: 91.8 MB (Flutter wrap) / 96.26 MB (gradle raw)
SHA256: `b6404443e8775a3f775aa93818375bfa368fa4cb7c6bc091ab75b28b753e505f`

Build: clean (`flutter clean` → `flutter pub get` → `gradlew assembleRelease`).
`BUILD SUCCESSFUL in 12m 55s`, 256 tasks (219 executed, 37 up-to-date).
`flutter analyze`: 2 issues — same pre-existing set from Sprint 1 close
(async-gap info in `event_launcher.dart:159`, missing `assets/audio/vo/`
directory warning). Zero Sprint 2 regressions.

## 6. Blocking issues discovered mid-sprint

None. All 8 items implemented per spec.

## 7. Things Khaled should watch for during device test

- **Stat-pills container position.** Placed at `screenH * 0.44, left: 10`
  per spec. If this visually crowds the fire on the A56 aspect ratio, flag
  it as a minor tweak — we can shift to `left: 12` / `top: 0.46` without
  a full rework.
- **Dhikr counter source.** Currently `PrefsService.dhikrCompletedCount`
  — a **lifetime** counter that increments on each "I said it" / hold
  completion. Settings screen displays the same number. If Khaled wants
  daily instead of lifetime, that's a spec §7 deferred-finding (not this
  sprint).
- **Start vs Continue label.** Button says `Continue` when `loadHotspotProgress
  (eventId)` is non-empty for the next event. If an event saves then all
  its hotspots get cleared mid-session, the label briefly stays `Continue`
  until next rebuild. Not expected to happen in normal flow; logging it
  here for completeness.
- **Greeting name.** Empty `PrefsService.userName` falls back to bare
  salaam with no trailing comma ("Assalamu Alaykom" / "السلام عليكم"),
  per spec §7 deferred handling. If a fresh install lands on tent without
  a name, that's expected.
- **TextScaler clamp scope.** Only the tent screen is clamped. Other
  screens still honor the full system scaler. If Khaled wants a
  project-wide clamp, that's a spec §7 deferred-finding.

## 8. Next steps

- Khaled runs §5 spec checklist + §6 device checks on A56, confirms per
  row.
- Sprint 2 row in `doc/RAWI_R25_SPRINT_ROADMAP.md` §1 marked ✅ with tip
  commit `ee2f6ad` + verify date once passed.
- Progress tracker row for Sprint 2 populated by the update-commit that
  ships with this handoff.
- Sprint 3 spec handoff follows. Q3 block (Q3.1 approve minimal header,
  Q3.2 "Explore the scene" drop, Q3.3 Knowledge/Your Light reproduction)
  is already listed in the roadmap §4 and tracker Sprint 3 section.

---

_Handoff v1 — Apr 19 2026, 12:50 local._
