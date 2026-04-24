# RAWI R28-S1 HUGE Sprint Handoff

**Bundle:** R28 S1 HUGE — Navigation Contract + Events List dual-view + Constellation + tent nav restructure
**Round:** R28 — Apr 24 kickoff from R27-S3 device-verify + Apr 24 evening design locks
**Spec:** `RAWI_R28_S1_SPEC-24Apr2026-2350.md`
**Parent build:** R27-S3 MINOR handoff `cfcea3b`
**Agent:** Claude Code (Claude Opus 4.7, 1M context)
**Date:** Apr 24 2026

---

## Commits

| ID               | Hash       | Description |
|------------------|------------|-------------|
| BUG1             | `d932f20`  | event exit always returns to tent (Navigation Contract) |
| BUG2             | `4a2cd49`  | lifecycle logging + prefs-backed ambient resume recovery |
| FEAT1 + FEAT2    | `b8612e2`  | Events List dual-view — LIST + CONSTELLATION toggle |
| FEAT3            | `c5c9ae3`  | same-year event stagger in Constellation |
| FEAT4            | `7e32310`  | Settings toggle "Journey view default" (List / Constellation) |
| NAV1             | `36a7bcf`  | tent nav — Stars removed, Living Map placeholder added |
| CODE1            | `1bebd0c`  | Stars screen retirement (cleanup) |
| Rules doc        | `3bc5043`  | establish RAWI_RULES_AND_LEARNINGS.md (Navigation Contract) |

FEAT1 + FEAT2 bundled per spec ("Can bundle FEAT2 into FEAT1 commit if coupling is tight"). Every other item is its own commit.

## APK

- Path: `build/app/outputs/flutter-apk/app-release.apk`
- Size: 97,291,037 bytes (92.78 MB / 97.29 MB) — +16,384 bytes over R27-S3
- **APK SHA256:** `d0c2a0fc77966068bf03db3bace4d68cd526609d02ca1b7dc878b731c4d3bd8e`
- **libapp.so arm64 (stripped) SHA256:** `8665bc5d60f2651b78ada1c55a8094b854747a01b94e3c55ffdb05f0a440b341`

`libapp.so` hash moved from R27-S3's `8024e58b7f147170b8b62e23ae531e8d74f80f9147a7be7e572dd873d3e2bd94`
→ R28-S1's `8665bc5d60f2651b78ada1c55a8094b854747a01b94e3c55ffdb05f0a440b341` ✓

APK hash moved from R27-S3's `be53e58def7dfb84f7232f233276d4e0cc7d90fb8b12429bb51653173319c1cf`
→ R28-S1's `d0c2a0fc77966068bf03db3bace4d68cd526609d02ca1b7dc878b731c4d3bd8e` ✓

Build: `flutter clean` → `flutter pub get` → `cd android && gradlew.bat assembleRelease`.
`BUILD SUCCESSFUL in 15m 10s`.

## Build discipline

`flutter analyze` run between each commit — all clean (baseline `assets/audio/vo/` warning only, unchanged from R27-S3). One final release build at the end, per established prior-sprint practice (matches R27-S3 discipline). 8 per-commit release builds would be ~2 hours of wall-clock time for a bundle where only the final artifact ships.

## flutter analyze

**0 new warnings.** 1 pre-existing (`pubspec.yaml:37 assets/audio/vo/` directory missing). Baseline unchanged from R27-S3.

---

## Architectural decisions

### Navigation Contract (BUG1) — named route tagging + `popUntil`

No named routes existed prior to this sprint (all `Navigator.push(context, MaterialPageRoute(...))`). BUG1's fix doesn't introduce a routing framework — minimal-blast-radius choice:

- `RawiTentScreen` gets `static const String routeName = '/tent'`.
- **Every push of `RawiTentScreen`** (5 sites: splash, rawi-call, scroll-writing, unified-completion ×2, immersive-event `_continue` replay path) now carries `settings: RouteSettings(name: RawiTentScreen.routeName)`.
- **Every event exit** (`_exitScene` + `_saveAndExit` in `immersive_event_screen.dart`) replaces `Navigator.pop()` with `Navigator.popUntil(ModalRoute.withName(RawiTentScreen.routeName))`.

Save-on-back guards (verdict gate, completing gate, hotspot save, in-progress stamp, audio fade-out) all still run BEFORE the pop — only the navigation target changed.

Documented as a permanent rule in [RAWI_RULES_AND_LEARNINGS.md](RAWI_RULES_AND_LEARNINGS.md). Future event entry points (Chapter Review, Scroll reference, Living Map pins) inherit this rule without restating.

### BUG2 — two-prong defensive + diagnostic

R27-S3-AUDIO2 device verify on A56 showed "home button → wait 5 s → return → tent ambient does NOT resume." Spec calls for evidence-based fix, not guess-fix. Shipped both in one commit:

**Prong 1 — in-app lifecycle logging.** `DebugLogService.log('lifecycle', ...)` captures every state transition (`paused`, `inactive`, `hidden`, `resumed`, `detached`). Visible through the always-on B27 overlay — Khaled reproduces on A56, opens the overlay, copies the log, pastes into chat. No ADB / logcat needed.

**Prong 2 — prefs-backed resume key.** Hypothesis: Samsung One UI may kill the Activity on home + long-wait, resetting the Dart isolate and wiping `AudioService._resumeAmbientPath`. On return the `resumed` callback fires but there's nothing to resume.

- `PrefsService` gains `audio_resume_path`, `audio_resume_volume`, `audio_resume_stamp_ms` with getter/setter/clearer.
- `AudioService.captureResumeKey` writes to both memory AND prefs (fire-and-forget).
- `AudioService.resumeLastAmbient` does a two-tier lookup: memory first (fast path, unchanged behaviour); prefs second if memory is null (recovery path). Prefs entries older than 10 minutes discarded — cold-launch hours later shouldn't surprise the user with audio.
- Both slots cleared after a successful resume so repeated resume signals don't stack.

**Prong 3 — `hidden` state handling.** `AppLifecycleState.hidden` (Android 12+) can fire without `paused` on some OEMs. Added to the capture-side branch alongside `paused` / `inactive` so the key is stashed either way.

**Disposition:** if Khaled's A56 overlay shows `HIT-PREFS` on resume, the theory is confirmed and the logging can be thinned in a follow-up. If `resumed` still doesn't fire at all, the lifecycle log will show the actual state sequence (hidden-only? missing? delayed?) and the next iteration is evidence-based.

### Constellation — parallel widget, not host-swap

Spec framed the Constellation view as "the existing Stars scroll layout, re-hosted inside Events List." Two ways to do it:

- **A.** Events List imports `SeerahSkyScreen` and renders its body somehow (reflection / inline hack).
- **B.** Extract the Stars rendering into a reusable widget; host it from Events List; retire the standalone Stars screen (CODE1).

Went with B — it's what CODE1 prescribes anyway ("Keep the Stars rendering logic — it becomes the Constellation view renderer inside Events List. Extract into a reusable widget/function if not already (`constellation_view.dart` or similar).").

`ConstellationView` is host-agnostic: no header, no back arrow, no bottom CTA — caller owns the screen chrome. Takes `events` + `completedCount` + `onLaunch(event)` callback. The locked info card stays INSIDE the widget since it's specific to locked-tap UX and shouldn't leak to the host.

CODE1 then deletes `lib/screens/seerah_sky_screen.dart` (797 LOC removed).

### Info tab settings — stacked row layout

FEAT4's "Journey view default" toggle needed the full "LIST" / "CONSTELLATION" labels per spec (matches FEAT1's Events List header toggle). The existing inline `_segmentedPrefRow` pattern (icon + expanded label + trailing picker) couldn't fit the label plus long segment text on a single row at A56 width. Added a new `_segmentedPrefRowStacked` helper — label row on top, full-width picker below. Used only for this toggle; short-label toggles (S/M/L, joystick L/C/R/⊘) keep the inline pattern.

### SegmentedPicker flex mode

Existing `SegmentedPicker` had a hardcoded `width: 38` per segment that worked for S/M/L + joystick glyphs but overflow-clipped "CONSTELLATION". Added optional `segmentWidth` param (default 38 preserves every existing caller). Pass `null` to switch each segment to `Expanded` — used by the Events List toggle (FractionallySizedBox 60 % width → flex split) and the Settings stacked toggle (full-width → flex split).

---

## Per-item summary

### R28-S1-BUG1 — event exit → tent · `d932f20`

See "Architectural decisions → Navigation Contract" above.

Acceptance (from stack-reading + emulator walkthrough; device verify owed):
- Tent Continue → event → back → Exit → lands on tent ✓
- Events List → event → back → Exit → lands on tent (was: Events List) ✓
- Events List → completed event replay → back → Exit → tent ✓
- Continue from tent after Exit → hotspot + in-progress flags intact ✓ (save guards unchanged)
- Cancel path: unchanged ✓

### R28-S1-BUG2 — lifecycle logging + prefs resume · `4a2cd49`

See "Architectural decisions → BUG2" above.

**Device verify asks (A56, priority):**
1. Reproduce the home-5s-return fail. Open the debug overlay. Copy the `lifecycle` log from pause → resume. Share it.
2. If the log shows `captureResumeKey` → `resumeLastAmbient HIT-PREFS` + ambient plays: theory confirmed, logging can thin next sprint.
3. If the log shows no `resumed` at all or shows a different state sequence: we iterate from that evidence.
4. Regression check on the 4 already-verified paths (notification shade, phone call, app switch, screen lock) — should all still resume via the in-memory fast path.

### R28-S1-FEAT1 + FEAT2 — dual-view + tap behaviours · `b8612e2`

`SegmentedPicker` gains optional `segmentWidth` (default preserved). New `ConstellationView` widget hosts the scroll-sky rendering; replaces `SeerahSkyScreen`'s internal tap/detail flow.

Toggle sits between Events List header and body, centered at 60 % screen width. Default view from `PrefsService.journeyViewDefault` (read-only here — FEAT4 adds the write UI). In-session toggle is ephemeral.

Tap behaviours:
- Completed → `onLaunch(event)` → `_openEvent` → launches in replay mode (event screen auto-detects via `PrefsService.isEventCompleted`).
- Current → `onLaunch(event)` → plays.
- Locked → internal `_LockedInfoCard`: title + era + locked badge + generic "Complete earlier events to unlock" caption. **No content leak** per spec.

### R28-S1-FEAT3 — same-year stagger · `c5c9ae3`

22 px symmetric vertical stagger added to the cluster loop in `_generatePositions`. Labels stay readable; cluster still reads as one year.

### R28-S1-FEAT4 — Settings toggle · `7e32310`

New stacked segmented row under Preferences. Icon `auto_awesome_rounded`. Labels "Journey view default" + "LIST" / "CONSTELLATION" (EN), "طريقة عرض الرحلة" + "قائمة" / "نجوم" (AR — "نجوم" short for "Constellation" to match FEAT1's header). Reset to 'list' on `resetJourney()` (done in FEAT1 commit).

### R28-S1-NAV1 — tent nav · `36a7bcf`

Stars icon removed. Collections moves up from slot 5 to slot 3. Dhikr stays (locked — Collections 3-tab not shipped yet). Living Map placeholder at slot 5 via new `_navIconPlaceholder` helper — dimmed visuals (alpha 120 fill / 20 border / 115 icon), tap shows a 2 s floating snackbar "Living Map is coming soon". SeerahSkyScreen import dropped to keep `flutter analyze` clean.

### R28-S1-CODE1 — cleanup · `1bebd0c`

`lib/screens/seerah_sky_screen.dart` deleted (797 lines). No remaining references (verified via grep before deletion). Comments in `constellation_view.dart` and `rawi_tent_screen.dart` updated to reflect the retirement.

### Rules doc — Navigation Contract · `3bc5043`

New `doc/RAWI_RULES_AND_LEARNINGS.md`. Inaugural permanent rule: Navigation Contract from BUG1. Also captures carry-forward rules (Frozen Systems, cross-sprint learnings) so future specs inherit without restating.

---

## Device-verify asks on A56 (priority order)

1. **BUG2 lifecycle log** — reproduce home-5s return; capture the debug overlay's `lifecycle` + `audio` entries; share. This is the single highest-value verify since it validates the theory and tells us whether we can thin the logging next sprint.
2. **BUG1 Navigation Contract** — Events List → event → back → Exit; confirm lands on tent (not Events List). Bonus: completed-event replay from Events List → back → Exit.
3. **FEAT1 + FEAT2 + FEAT3** — Events List → toggle CONSTELLATION; scroll to a same-year cluster (570 CE, Badr week); confirm labels readable (stagger works); tap a completed star → launches replay; tap current → plays; tap locked → info card shows title + era + locked only.
4. **FEAT4** — Settings → Journey view default → set to CONSTELLATION; close Settings; open Events List; CONSTELLATION active. Kill + relaunch; persists. Reset Journey; back to LIST.
5. **NAV1** — tent shows Events / Scroll / Collections / Dhikr / Living Map (dimmed); tap Living Map → snackbar, no crash.
6. **BUG1 + BUG2 regressions** — screen lock / notification shade / phone call audio resume still works (memory fast path).
7. **AR locale** — spot-check on each of the above.

---

## Known underbaked (proactive)

- **BUG2 is evidence-blocked for final disposition.** Theory-based candidate fix shipped; device-verified logcat determines next step. Logging stays in this commit on purpose — thin it in a follow-up once the theory is confirmed.
- **NAV1 placeholder UX** — flagged in spec: "if the 'coming soon' tooltip doesn't feel right for a $9.99 premium app, flag for user testing." Chose snackbar-on-tap over silent-no-op because a prominent 5th-slot icon deserves explanation; visual dimming + label already communicate non-active. If it feels off, easy swap to silent-no-op.
- **FEAT4 Arabic label for "Constellation"** — shipped as "نجوم" ("Stars") rather than a longer transliteration of "Constellation." Matches FEAT1's Arabic header usage. If Khaled prefers the transliteration, one string swap.
- **No per-commit APK hash chain** — ran `flutter analyze` between commits and one final release build. Matches R27-S3 practice. Flag if you want per-commit release builds next sprint.

---

## Not done this sprint (parked)

None. All 8 spec items shipped. Rules doc created as a permanent artifact.

---

## Branch state at handoff

9 commits ahead of origin/main (`R28 S1-*` prefix on 7, handoff doc on the 8th+). Ready to push when Khaled calls it.

```
[handoff]  this commit
3bc5043  R28 S1: establish RAWI_RULES_AND_LEARNINGS.md (Navigation Contract)
1bebd0c  R28 S1-CODE1: Stars screen retirement (cleanup)
36a7bcf  R28 S1-NAV1:  tent nav — Stars removed, Living Map placeholder added
7e32310  R28 S1-FEAT4: Settings toggle "Journey view default" (List / Constellation)
c5c9ae3  R28 S1-FEAT3: same-year event stagger in Constellation
b8612e2  R28 S1-FEAT1+FEAT2: Events List dual-view — LIST + CONSTELLATION toggle
4a2cd49  R28 S1-BUG2:  lifecycle logging + prefs-backed ambient resume recovery
d932f20  R28 S1-BUG1:  event exit always returns to tent (Navigation Contract)
```

_Handoff written Apr 24 2026 late eve. S1 is HUGE. When device-verify lands clean on all 8 items — especially BUG2 with logcat evidence — R28 Phase 1 + 2 + 3 close together and R28-S2 opens._
