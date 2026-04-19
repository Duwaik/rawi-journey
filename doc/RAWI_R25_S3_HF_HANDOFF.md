# RAWI R25 — Sprint 3 Hotfix Handoff

**Batch:** R25 S3 hotfix (9 items)
**Round:** R25 — Apr 19 device testing feedback
**Spec:** `RAWI_R25_S3_HOTFIX_SPEC.md`
**Agent:** Claude Code (Claude Opus 4.7, 1M context)
**Date:** Apr 19 2026 (late evening)

---

## 1. Commit hashes

Hotfix start tip: `bc2be05` (Sprint 3 handoff commit).

| # | Commit | Item | Description |
|---|--------|------|-------------|
| 1 | `4bdc690` | H1 | Wire `StatRowGroup` into tent — SizedBox(width:155) unbounds the Spacer |
| 2 | `f74147b` | H2 | Info tab vertical-stack redesign (no double "Your Light", chevron mid-border) |
| 3 | `7e5b9a6` | H3 | Event title → top-bar pill with chapter subtitle; bottom title removed |
| 4 | `9b907e4` | H4 | Right nav icon-only; 44×44 buttons; label moved to Tooltip |
| 5 | `c5e33db` | H5 | Capitalize name: write-side in PrefsService.setUserName + display-side safety net |
| 6 | `fa909d2` | H6 | Figure halo alpha + spreadRadius keyed to Noor fraction |
| 7 | `0738e7c` | H7 | Knowledge/Your Light consolidation (grep-verified second pass, stale comment updated) |
| 8 | `bf65e75` | H8 | Tutorial rebuild sequential 3 steps, legacy TutorialOverlay retired |
| 9 | `cc72007` | H9 | Explicit Directionality wrapper on info tab for AR layout |

All 9 pushed to `origin/main`. HEAD: `cc72007`.

## 2. Root-cause notes

**H1 was the critical gate for this hotfix.** The Sprint 3 spec's
S3-8 acceptance said "do NOT close with one surface broken" — the
info tab rendered but the tent pills didn't. The fix was simpler than
the spec's diagnostic tree suggested:

- `StatRowGroup` rows use `Spacer()` between label and value.
- The tent's `Positioned(left: 10, child: …)` supplied no right bound
  and no width. The Row's `Spacer` had no bounded parent width to flex
  against, so the container collapsed to 0 width and drew nothing.
- The info tab works fine because its parent animates `width:
  _widthAnim.value` (explicit width).
- Fix: wrap the tent's `ClipRRect` in `SizedBox(width: 155)`.

One `SizedBox`. Four unsuccessful prior attempts (S2-1, `b452ccc`,
S3-8) missed this because the widget tree always LOOKED correct on
inspection — the geometry was the issue, not the logic.

## 3. Deviations from spec

Three worth logging:

1. **H6 figure halo** — spec asked to trace the halo layer; existing
   code already had it as two BoxShadows in `RawiFigure`. Fix was a
   two-line alpha-scaling change rather than a restoration. Also scaled
   `spreadRadius` so low-Noor states genuinely look smaller, not just
   dimmer.
2. **H7** — no actual fix needed, all UI render sites already emit
   "Your Light" / "نورك" after `8aa122c` (Sprint 3 S3-5). Commit
   updated a stale explanatory comment + documented the full grep
   audit in the message for future reference.
3. **H8 step 3 "amplified hotspot pulse"** — spec wanted the real
   scene hotspot (HS1) to pulse brighter during tutorial step 3, which
   would require cross-widget coordination. Instead, the overlay renders
   its own self-contained pulsing gold disc at the typical hotspot
   position. User still sees what a hotspot looks like; the real scene
   hotspots render at their normal intensity throughout. Minor visual
   deviation; flag if device test calls for the real one.

## 4. APK

Path: `build/app/outputs/flutter-apk/app-release.apk`
Size: 91.9 MB (Flutter wrap) / 96.34 MB (gradle raw)
SHA256: `9b280f681ed612fe5f2bb52c54258d789750375646f69ac42c1de74e34d295d9`

Build: clean (`flutter clean` → `flutter pub get` → `gradlew
assembleRelease`). `BUILD SUCCESSFUL in 7m 11s`, 38 tasks executed,
218 up-to-date.

`flutter analyze`: 2 issues — same pre-existing set from Sprint 1
close. Zero new warnings from the 9 hotfix commits.

## 5. What Khaled should verify on A56

**Critical (these were the sprint-breakers):**

1. **Tent stat pills visible** — install this APK over `2b225040…`.
   Open tent. Three stat pills (Your Light / XP or Events / Dhikr) must
   render in a single navy-blurred container on the left at ~22%
   screen height. If they're STILL invisible, there's a deeper layout
   issue — paste the debug log.
2. **Tutorial not double-firing** — fresh install → Event 1 → intro
   video → tutorial. Should see ONE overlay, sequential 3 steps, not
   two competing systems. Old `TutorialOverlay` should never appear.

**Layout:**

3. Info tab expand → Section 1 shows "Your Light" / subtitle / 100%
   vertically stacked (no double header). Chevron sits on right border
   at vertical middle.
4. Event scene top bar → title pill between back button and settings.
   Event title 14px, chapter name 10px below it.
5. Nothing at scene bottom except scene dots (no floating title).
6. Right nav is 5 icon-only buttons, 44×44 each. "Collections" no
   longer truncated.

**Data:**

7. Tent greeting shows `Assalamu Alaykom, Khaled` (capitalized). If
   the stored name is lowercase, display still caps it.
8. Figure halo visibly shrinks as Noor depletes across events. At 100%
   Noor the halo is full; at 0% it collapses to just the 2.5px gold
   border.
9. Toggle Reader ↔ Explorer 10 cycles. Light label stays "Your Light"
   / "نورك" in both modes.

**Localization:**

10. Switch to AR. Info tab all-Arabic, layout mirrored (labels align
    right, Section 2 subtitle uses Arabic-Indic digits `١ من ٤ لحظات`).

**Deferred to device (per hotfix spec §3):**
- S3-4 Noor on "Abd al-Muttalib" / "Khadijah" (if still 0% somewhere,
  debug log now has `noor:` traces from `setNoorLevel`).
- 1.3× text scaler on event scene (Android Settings → Display → Font
  size → Largest, walk through tent + event scene).

## 6. Next steps

- Khaled runs §5 on A56, confirms per row.
- Progress tracker §Sprint 3 + hotfix section populated.
- If all 9 pass: Sprint 3 row in roadmap §1 marked ✅ with tip
  `cc72007`, hotfix chain logged.
- If any fail: paste debug log + symptom, we iterate.
- Sprint 4 spec handoff follows. Q4 block (branch viewability,
  freeze-vs-snap, global vs branching-only) already listed in
  roadmap §5.

---

_Hotfix handoff v1 — Apr 19 2026, 17:50 local._
