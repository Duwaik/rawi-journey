# RAWI R26 S1v3 Handoff (bundle 1 of 2)

**Bundle:** R26 S1v3 (5 polish / bug-fix items)
**Round:** R26 — Apr 21 device-verify follow-up on v2
**Spec:** `RAWI_R26_S1v3_v4_SPEC.md`
**Parent build:** S1v2 handoff `8ff8b55` (Apr 20 evening)
**Agent:** Claude Code (Claude Opus 4.7, 1M context)
**Date:** Apr 21 2026

---

## Orchestration note

Per Khaled: **v3 first, wait for device verification, then v4.**
v4 (EE6.1 halo radius multiplier, EE6.2 cinematic reveal, EE6.3 end-of-event
flow rebuild) is **NOT in this bundle**. Do not start v4 until v3 device-verify
lands clean.

## Commits

| ID     | Hash       | Description |
|--------|------------|-------------|
| T2.2   | `4246938`  | persist branching choice + completed branches |
| EE1    | `22f6720`  | title pill BG redo — remove fixed top-bar height |
| EE6.4  | `bc42adb`  | tent dhikr 24h lock (replaces session flag) |
| EE8.2  | `d5b6311`  | info tab outside-tap dismiss + pan swallow |
| EE9    | `ccca0c3`  | tap-to-trigger HS in 40–100 px proximity band |

All pushed to local `main`. HEAD: `ccca0c3`. **Not yet pushed to origin**
— Khaled's call after device verify.

## APK

- Path: `build/app/outputs/flutter-apk/app-release.apk`
- Size: 96,356,631 bytes (91.9 MB / 96.36 MB)
- **APK SHA256:** `448ef7a68c78fc685d6aa95a93d001bb3e59f0d5a8c306c7c2faa54dd0cde118`
- **libapp.so arm64 (stripped) SHA256:** `d09ba9446a4dedb7f967d16add1219acdceb038b8d396138260c815ce326cf5b`
- **libapp.so arm64 (merged, pre-strip) SHA256:** `1623771335f942d12607fd1493cc1c144f2c7a1da777567c217ba411f97734a3`

Build: `flutter clean` → `flutter pub get` → `gradlew.bat assembleRelease`.
`BUILD SUCCESSFUL in 13m 34s`, 256 tasks (219 executed, 37 up-to-date —
full Dart recompile + native rebuild after `flutter clean`).

## flutter analyze

**0 new warnings.**
1 pre-existing warning — `pubspec.yaml:37 assets/audio/vo/ doesn't exist`
(unchanged since Sprint 1).

## Per-item summary

### T2.2 — persist branching choice (`4246938`)

**v2 symptom:** resume via tent Continue re-showed the Crossroads card even
after the user had already chosen a branch and completed one branch HS.

**Root cause:** in-memory `_branchChoice` / `_branchUnlockOrder` reset on
initState. The existing B1 "restore Crossroads" fallback only checked the
memory flag, so it always tripped after a relaunch.

**Fix:**
- Added `PrefsService.setBranchChoice / getBranchChoice / clearBranchChoice`
  keyed by event ID, storing the chosen `targetHotspotId`.
- `_onBranchSelected` persists the choice before `setState`.
- `initState` resume block first tries to rehydrate from prefs; only falls
  back to re-showing the Crossroads if no prior choice exists.
- `clearBranchChoice` on event completion alongside `clearHotspotProgress`.

### EE1 — title pill BG redo (`22f6720`)

**v2 symptom:** signboard pill rendered as "title text only — no BG, no gold
border, no italic chapter subtitle" despite the widget (`_buildTitlePill`
at line 1050) being shaped correctly.

**Root cause:** top-bar parent Container at line 2227 had
`height: 48 + topPad`. With topPad ≈ 28 on A56 that gives ~38px usable
height after padding, but the 2-line pill needs ~58px (15px title +
2px gap + 11px italic chapter + 20h/10v padding). The pill was being
clipped vertically to just the title glyph row.

**Fix:** drop the `height:` constraint so the Container sizes to its
tallest child. Bump bottom padding 4 → 10 for breathing room.

### EE6.4 — tent dhikr 24h lock (`bc42adb`)

**v2 symptom:** user can background the app, reopen, tap "I said it" again
for another +25 Light. Stackable without any real cooldown — the v2
session flag (`_saidThisSession`) reset on app restart.

**Fix:**
- New pref key `last_tent_dhikr_ts` stores `millisecondsSinceEpoch`.
- `PrefsService.isTentDhikrLocked` returns true when
  `(now - last)` is in `[0, 86_400_000)` ms.
- Featured Dhikr card in `dhikr_collection_screen.dart` reads the getter
  directly (no state mirroring) and the correct state survives rebuilds
  after a relaunch.
- Locked label: "✓ Said today · Return tomorrow" / "✓ قلتها اليوم · عد غدًا"
- Negative-clock-delta (user moves clock backward): lock stays off so
  they regen early. Forward-clock-skew abuse is unavoidable without a
  server time source — deferred.

### EE8.2 — info tab outside-tap dismiss + pan swallow (`d5b6311`)

**v2 symptom:** tapping outside the expanded info tab neither collapsed
the tab nor absorbed the tap — the tap leaked through as figure movement.

**Root cause:** the widget was wrapped in
`Positioned(top: screenH * 0.40, left: 0, child: EventSceneInfoTab(...))`
with no right/bottom. The internal `Positioned.fill` scrim therefore only
covered the tab's own footprint, not the full scene.

**Fix (widget):**
- Call site → `Positioned.fill` so the widget has full-screen bounds.
- Inside the widget, the tab bar itself is now re-positioned internally
  via `Positioned(top: screenH * 0.40, left: 0, ...)` — visual layout
  preserved.
- Scrim `GestureDetector` now has no-op `onPanDown/onPanUpdate/onPanEnd`
  in addition to `onTap`, so drag-like taps don't get stolen by the
  movement GestureDetector below via the Flutter gesture arena.

### EE9 — tap-to-trigger HS in 40–100 px band (`ccca0c3`)

**Change:** tapping the next-to-unlock marker now activates it when the
figure is inside a `[40, 100]` px band. Inside 40px the game loop's
`_checkHotspotProximity` already auto-triggers; beyond 100px the tap
is still ignored so the walk-and-find beat isn't bypassed from anywhere
on screen.

**Fix:**
- New constants `_hsTapMinPx = 40`, `_hsTapMaxPx = 100`.
- `_onHotspotTap` Explorer-new-HS branch computes pixel distance using
  `MediaQuery.of(context).size` and `_posFor(hotspot)`, calls
  `_activateHotspot` when inside the band.
- `SceneHotspotMarker` gains a `tapReady` bool prop. When true, the
  pulse ring amp scales 20 → 24 for a visibly stronger "tappable" hint.
- Parent build closure computes the distance each frame for the
  `nextHotspotId` marker and passes the flag through.

## Architectural decisions

- **T2.2 — key on `targetHotspotId`, not branch letter.** Stored value is the
  chosen option's `targetHotspotId` string, because reverse-matching back to
  option A vs B is a single `isA = saved == bp.optionA.targetHotspotId` line.
  Keying on "A"/"B" would couple persistence to a presentation detail.

- **EE6.4 — client-clock only, no server anchor.** Khaled's note for v2
  still applies: "don't over-engineer this". The 24h lock uses device
  clock with one explicit edge-case (negative delta = unlock early). Forward-
  skew abuse requires a server time source — parked until there's real
  evidence users are doing it.

- **EE8.2 — scrim lives INSIDE the tab widget, not hoisted to parent.**
  Hoisting would require exposing `expanded` state up through a callback
  and re-driving the animation controller. The Positioned.fill wrapper
  pattern lets the widget stay self-contained while still covering the
  full scene — lowest-surface fix.

- **EE9 — constants at class top, not in spec table.** `_hsTapMinPx = 40`
  and `_hsTapMaxPx = 100` are in one place so Khaled can tune them without
  hunting. If 40 feels too close to the auto-proximity floor on device,
  bump `_hsTapMinPx` down to 30. No other code reads these.

- **EE9 — did NOT add tap-to-trigger for discovered HS revisits.** Spec only
  mentioned new-HS proximity. Revisit re-opens still require the existing
  "tap anywhere" behaviour (handled by the later branch of `_onHotspotTap`).

## Self-verification notes

Per spec §9 anti-iteration guardrails:

1. **T2.2** — flow-traced all 4 resume scenarios:
   - Fresh entry, no choice saved → Crossroads shows (getBranchChoice null → fallback path).
   - Anchor complete, choice saved, branch HS not complete → rehydrate state, skip Crossroads, figure advances to branch HS.
   - Both branch HS complete → rehydrate, skip Crossroads, figure advances to convergence.
   - Fully complete → `clearBranchChoice` was called in `_selectChoice`; subsequent re-entries treat it as a fresh replay.

2. **EE1** — grep-confirmed `widget.event.title` has exactly one render site
   (`_buildTitlePill` at line 1075). Removing the fixed height only affects
   the pill wrapper — no other top-bar element depends on the 48+topPad
   constraint. **Device-screenshot verify is pending** — I can't compare to
   the reference image.

3. **EE6.4** — verified `PrefsService.isTentDhikrLocked` getter + the
   `_FeaturedDhikrCardState._onSaidIt` early-return guard. The state-less
   lookup pattern (`_isLockedForToday` as a getter, not a mirrored bool)
   means rebuild-safety is free.

4. **EE8.2** — verified Stack z-order:
   - Parent Stack (`immersive_event_screen.dart`): movement GestureDetector
     at line ~2038 → hotspot markers → info tab at line ~2281. Info tab
     paints last → receives hits first.
   - Inside info tab: scrim (Positioned.fill, only when `_expanded`) →
     tab body (Positioned at 40%). Scrim paints BEHIND the tab body.
   - Collapsed state: Stack contains only the Positioned tab — no
     full-screen scrim. Outside-tap falls through to movement as before.

5. **EE9** — pixel-distance math verified against the marker-positioning
   math at line 2107 (`hPos.dx * screenW`). `(companionX - posX) * screenW`
   + `(companionY - posY) * screenH` is consistent with how the marker
   is actually placed on screen.

## Device verification checklist (Khaled on A56)

**T2.2 (v2's hardest regression):**
- [ ] Enter a branching event (e.g. j_1_1_2), complete the anchor, pick branch A, complete branch A HS → back out → tent shows Continue → tap Continue → Crossroads does NOT re-appear, figure walks to convergence HS.
- [ ] Same flow, pick branch B → back out → Continue → figure walks the alt path to branch B convergence (no Crossroads).
- [ ] Kill app fully, relaunch → same event still resumes without Crossroads.
- [ ] Complete the event → replay from map → first entry shows Crossroads again (choice was cleared on completion).

**EE1:**
- [ ] Top bar shows a pill with:
  - Visible translucent dark BG (rgba(10,14,24,0.55))
  - Gold 0.35-alpha border, 0.8 px
  - Backdrop blur
  - 2 lines: title (15px) + italic chapter (11px)

**EE6.4:**
- [ ] From tent, tap "I've said it ✓" on Dhikr of the Day → Light goes +25 → button flips to "✓ Said today · Return tomorrow".
- [ ] Background app, reopen → button still shows locked state (24h gate holds).
- [ ] Kill app, relaunch → button still locked.
- [ ] Change device clock forward by 25h → button unlocks. (Abuse acknowledged.)

**EE8.2:**
- [ ] Enter event → tap info tab → it expands with full-screen scrim dimming the scene.
- [ ] Tap outside the tab (anywhere on the scrim) → tab collapses → figure does NOT move.
- [ ] Tap, drag briefly outside → tab collapses → figure does NOT move (pan swallow working).
- [ ] Collapsed state → tap or drag on scene → figure moves normally (no scrim interference).

**EE9:**
- [ ] Walk figure toward next HS; stop when figure is ~70 px from marker → tap the marker → HS activates (content card reveal).
- [ ] Walk figure so it is ~150 px from marker → tap the marker → nothing happens.
- [ ] Walk figure all the way to the marker (< 40 px) → HS auto-activates as before (proximity path unchanged).
- [ ] Inside the band, visually confirm the pulse ring is visibly larger/stronger than outside the band (tapReady hint).

## Out of scope (do NOT touch in v3 — confirmed untouched)

- v4 items: EE6.1 halo radius multiplier, EE6.2 cinematic fog reveal,
  EE6.3 end-of-event flow rebuild. Wait for v3 verify.
- MINOR items from R26-S1 spec — still parked.
- Reader mode, bottom-sheet cards, R26-S2 scope.
- BG image / BG rendering (permanently frozen).

## If verification passes

Proceed to v4 bundle (EE6.1, EE6.2, EE6.3) per
`RAWI_R26_S1v3_v4_SPEC.md` §v4.

## If any item fails

Paste the debug log (the `noor: setNoorLevel(x)→y (was z)` traces are
still live from v2) + symptom. Do not blind-iterate. Per two-strike rule:
diagnose, then patch.

---

_Handoff v3 — Apr 21 2026._
