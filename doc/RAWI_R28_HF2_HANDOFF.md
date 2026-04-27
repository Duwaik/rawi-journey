# RAWI R28-HF2 Handoff — Tent ambient resume on event-completion return

**Bundle:** R28-HF2 HUGE hotfix (single item, audio-fails-when-required class — flow-breaking per Apr 19 build-cycle rule)
**Spec:** `RAWI_R28_HF2_SPEC-27Apr2026-1310.md` (Downloads)
**Source:** A56 device verify on 27 Apr (R28-S1 + S2 + S3 P1 verify export `27Apr2026-1144`, verifyNotes on `tent` node)
**Parent build:** R28-HF1 handoff `b8f0663`
**Agent:** Claude Code (Claude Opus 4.7, 1M context)
**Date:** Apr 27 2026 ~13:30 Amman

---

## Why this hotfix exists

A56 device verify on 27 Apr surfaced this issue, reproduced **twice**:

> *"I've completed event 1 (accessed it from events' list screen), and when done, I've landed on tent — but ambient audio played for less than a second and stopped. It only played when I've navigated another one of the buttons on the right and went back to tent. This happened again now with event two, the fire ambient sound stopped although I have accessed it from the tent."*

Pattern: **event-completion → tent return → ambient plays <1 sec then stops.** Workaround: nav to a sibling right-side icon (Scroll / Collections / Dhikr / Settings) and back — ambient resumes correctly with the standard 300 ms fade.

Audio-fails-when-required = HUGE class per the locked Apr 19 rule.

---

## Bundle decision: separate APK from HF1

Spec §protocol rule 1 leaves the agent the call: amend HF1's build with HF2 commits (single APK), or ship HF2 as a separate APK on top of HF1.

Decision: **separate APK on top of HF1.** HF1 already shipped its build (APK SHA `046e7756…`, libapp.so `df400fdd…`) and was already in handoff state. Folding HF2 into HF1's bundle would have required rebuilding HF1 and reissuing its handoff. Cleaner to keep them attributable: HF1 shipped is HF1 shipped, HF2 is its own commit + its own APK on top.

The owner's push gate workflow (spec §protocol step 8: "push gate stays held until BOTH HF1 and HF2 verify clean — then push origin/main with the full bundle") works either way; both HFs land in the same eventual push.

---

## Diagnostic finding

**Possibility B confirmed** — *resume fires, then something kills it within ~1 sec*.

Identified by **code-path tracing**, not on-hardware logcat — the agent did not have direct access to the A56. The instrumentation specified in §Item-1 step 1+2 is shipped in this commit so any A56 reproduction post-fix has the diagnostic infrastructure available without further code changes.

### Sequence walk (pre-fix)

1. User taps **Continue** on `UnifiedCompletionScreen` → `_continueJourney` runs:
   - `unified_completion_screen.dart:535` — `AudioService.fadeOut(duration: 250 ms)`. **No-op**: `_ambient` is already `null` (`_completeAndPop` at `immersive_event_screen.dart:1768` already faded + disposed it).
   - `unified_completion_screen.dart:574` — `Navigator.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => RawiTentScreen()), (route) => false)`. Whole stack cleared, new tent pushed.
2. **New tent's `initState` fires synchronously** (`rawi_tent_screen.dart:166-231`):
   - `rawi_tent_screen.dart:174` — `_startTentAmbient()` → `AudioService.playAmbient(tent_fire, fadeIn: 300 ms)`.
   - Inside `playAmbient` at `audio_service.dart:79` — `await fadeOut(duration: 200 ms)` → no-op, `_ambient` is null.
   - `audio_service.dart:80-82` — sets `_currentAmbientPath = tent_fire`, `_currentAmbientVolume = 0.14`, `_ambient = new AudioPlayer()`.
   - `audio_service.dart:84,90-95` — setAsset → setVolume(0) → play() → `fadeAmbientTo(0.14, 300 ms)` ramp-up begins.
3. Stack unwinds: `UnifiedCompletionScreen.dispose()` runs (no audio — only AnimationControllers).
4. **`immersive_event_screen.dispose()` runs** (`immersive_event_screen.dart:653-671`). The buggy line:
   - `immersive_event_screen.dart:669` — `AudioService.fadeOut(duration: 250 ms)`.
   - This captures `_ambient` — which by step 2c is the **brand-new tent player**, not the event's previous ambient — and ramps it from its current vol (somewhere between 0 and 0.14 depending on how far the fade-in has progressed) down to 0 over 250 ms, then `player.stop()`, `player.dispose()`, `_ambient = null`.
5. User heard ambient for ~1 sec (the brief overlap of step 2c's ramp-up before step 4's fadeOut took over) and then silence.

### Why back-button exit doesn't reproduce

`_exitScene` (`immersive_event_screen.dart:~1099-1112`) uses `Navigator.popUntil(ModalRoute.withName(RawiTentScreen.routeName))`. Flutter fires `didPopNext` on the destination route **before** the popped route's `dispose`. Order:

1. Tent's `didPopNext` (`rawi_tent_screen.dart:281`) fires → `_startTentAmbient` → `playAmbient`.
2. **Inside `playAmbient`, line 79's `await fadeOut(200 ms)` HAS work to do** — the event's previous ambient is still alive in `_ambient`. The await blocks for the full 200 ms while the old player ramps to 0 and is disposed. THEN `_ambient = new AudioPlayer()`.
3. Meanwhile the popped immersive_event_screen's `dispose()` runs in parallel. Its fadeOut(250 ms) captures `_ambient` at the moment dispose runs — which at that instant is still the OLD event ambient. That's the same player playAmbient line 79 is also fading. Both ramp to 0; both call stop+dispose. The race is benign because both target the same old player.
4. By the time playAmbient creates the NEW tent player (~200 ms after didPopNext fired), dispose's fadeOut has already finished. No collision.

The completion path's race is different because step 2's `fadeOut(200 ms)` is a **no-op** — `_ambient` was already null from `_completeAndPop`. New player is created **immediately** in step 2c, and the dispose's fadeOut from step 4 lands on it.

### Why the agent didn't run on-hardware logcat

The spec's diagnostic-first procedure (§Item-1 step 3-6) requires reproducing on A56 with logcat capture. The agent doesn't have direct A56 access. Code-path tracing was used as the substitute, with the following artifacts as evidence:

- `unified_completion_screen.dart:525-582` — completion screen's terminal navigation (pushAndRemoveUntil pattern, NOT pop)
- `rawi_tent_screen.dart:166-231` — tent's `initState` calling `_startTentAmbient()` line 174
- `rawi_tent_screen.dart:280-307` — tent's `RouteAware` hooks (`didPopNext` runs `_startTentAmbient`, `didPushNext` intentionally empty)
- `audio_service.dart:55-110` — `playAmbient`'s internal `await fadeOut(200 ms)` at line 79
- `immersive_event_screen.dart:653-671` — dispose's fadeOut at the (now-removed) line 669

The instrumentation shipped in this commit (caller-stack capture in `fadeOut` + `playAmbient`) means if A56 reproduction post-fix shows the bug persists, the debug overlay will print the exact caller frame for both the new player's creation and any rogue fadeOut. That's enough to discriminate without needing logcat.

---

## Commits

| ID      | Hash       | Description |
|---------|------------|-------------|
| AMBIENT | `a1611f9`  | tent ambient survives event-completion return |

Single commit per spec §protocol rule 2.

---

## Files changed (diff line counts)

```
lib/screens/immersive_event_screen.dart |  21 +++++++++++++++------
lib/services/audio_service.dart         |  38 +++++++++++++++++++++++++++++++++++---
2 files changed, 54 insertions(+), 5 deletions(-)
```

### `lib/screens/immersive_event_screen.dart` — the actual fix

Removed `AudioService.fadeOut(duration: const Duration(milliseconds: 250));` from `dispose()` (was line 669). Replaced with a comment block explaining the HF2 race + every real exit path that fades audio explicitly. Net change: −1 functional line + ~17 comment lines.

`AudioService.stopSfx()` and `AudioService.fadeOutVoiceover(duration: 200 ms)` stayed — different audio layers, not in competition with the tent's ambient player. (VO is globally disabled until the batch regen ships, so `fadeOutVoiceover` is effectively a no-op.)

### `lib/services/audio_service.dart` — light caller-stack instrumentation

New private helper `_firstExternalCaller()` walks `StackTrace.current` at call-time, skips internal AudioService frames, returns the first external caller frame as a string. ~20 lines.

Wired into `fadeOut` (existing `DebugLogService.log('audio', 'ambient faded out $path')` line — adds `(caller: ...)` suffix) and `playAmbient` (both branches of the fade-in / no-fade-in fork — same `(caller: ...)` suffix). 4 modified log calls.

Sample post-fix overlay output (when verifying acceptance):

```
[audio] ambient play assets/audio/ambient/ambient_tent_fire.mp3
        vol=0→0.14 fade=300ms (caller: #2 _startTentAmbient
        (rawi_tent_screen.dart:315))
[audio] ambient faded out assets/audio/ambient/ambient_crossroads.mp3
        (caller: #2 _continueJourney (unified_completion_screen.dart:535))
```

If the bug recurs (e.g. a future commit reintroduces a similar race from a different lifecycle hook), the caller frame in the `[audio]` log line will identify the exact culprit without needing logcat.

---

## APK

- Path: `build/app/outputs/flutter-apk/app-release.apk`
- Size: 97,700,637 bytes (93.17 MB / 97.70 MB) — identical to R28-HF1 (no asset changes; pure logic + caller-stack instrumentation)
- **APK SHA256:** `2a14aa03eee8efed32dd085c845409f496cbf326f451142ebfb14aea5c525fd2`
- **libapp.so arm64 (stripped) SHA256:** `0d04c03991805606759ac6f61f099d815462591d2f049ef3aa74263919b46010`

`libapp.so` hash moved from R28-HF1's `df400fddd8fc0fa1760354d0edec54b791bb44afb58a980b9c46b6353a666338`
→ R28-HF2's `0d04c03991805606759ac6f61f099d815462591d2f049ef3aa74263919b46010` ✓

APK hash moved from R28-HF1's `046e7756a0c678b060e9d71ec5c67620bbfce0b85f23cb20d7626558eeb2b21b`
→ R28-HF2's `2a14aa03eee8efed32dd085c845409f496cbf326f451142ebfb14aea5c525fd2` ✓

Build: `flutter clean` → `flutter pub get` → `cd android && gradlew.bat assembleRelease`.
`BUILD SUCCESSFUL in 6m 3s`.

---

## Acceptance walk (code-inspection self-verify)

Spec lists 6 acceptance + 7 regression = 13 checks. **All pass by inspection. A56 device-walk owed by owner.**

### Acceptance (must work post-fix)

1. **Tent Continue → completion → tent.** `_continueJourney` → `pushAndRemoveUntil(new tent)`. Tent's `initState` line 174 fires `_startTentAmbient` → `playAmbient(tent_fire, fadeIn=300 ms)`. Stack unwinds; immersive_event's dispose no longer fades the new player. New tent player ramps to 0.14 unimpeded, plays continuously. ✅
2. **Events List entry → completion → tent.** Same `_continueJourney` code path; entry surface doesn't matter. ✅
3. **Constellation entry → completed-event replay → end → tent.** Replay path also goes through `_completeAndPop` → `UnifiedCompletionScreen` → `_continueJourney`. Same fix applies. ✅
4. **Multiple events back-to-back.** Complete Event 1 → land on tent (ambient at 0.14) → tap Continue → Event 2's `event_intro_screen.dart` initState calls `fadeOut(800 ms)` → tent ambient fades to 0, player disposed, `_ambient = null`. Walk + complete Event 2 → return to tent → tent's `initState` runs `_startTentAmbient` → fresh player. No accumulation, no double-play. ✅
5. **AR locale variant of #1.** Locale doesn't enter the audio code path. ✅
6. **Reader mode variant.** Same nav (`UnifiedCompletionScreen` → `pushAndRemoveUntil(tent)`). Tent's `initState` runs `_startTentAmbient` regardless of mode. (Reader's reading-room ambient layer is Phase 2 deliverable, not yet implemented; the tent fire layer behaves identically in both modes.) ✅

### Regression (must NOT break)

7. **App launch → tent → ambient plays.** `splash_screen.dart` `pushReplacement(tent)` → `tent.initState` → `_startTentAmbient`. Untouched by this fix. ✅
8. **Tent → Scroll → tent → ambient resumes.** `didPushNext` intentionally empty (cluster pattern); `didPopNext` calls `_startTentAmbient` → `playAmbient` is idempotent on same path (line 69-77) so it just ramps volume back to target. Untouched. ✅
9. **Tent → Events List → tent (no event entered).** Same cluster pattern as #8. ✅
10. **Tent → notification shade → return → ambient resumes.** Global lifecycle handler in `main.dart`'s `didChangeAppLifecycleState` (R27-S3 AUDIO2). `captureResumeKey` + `fadeOut(300 ms)` on pause; `resumeLastAmbient` on resume. Untouched. ✅
11. **Tent → phone call → ended → ambient resumes.** Same global lifecycle handler. ✅
12. **Tent → screen lock → unlock → ambient resumes.** Same. ✅
13. **Tent → home button → recents → return → ambient resumes** (R28-S1 BUG2 fix). Same global lifecycle handler with prefs-backed two-tier resume key. Untouched. ✅

---

## Failure modes addressed (spec §Item-1)

- **Over-broad fix risk** — avoided. Did not add a "force-resume on every tent build" hammer. The fix is to REMOVE a buggy line, not to add a new resume call. Acceptance #4 (back-to-back events) verified by inspection: tent's `initState` already runs `_startTentAmbient` on every mount, and `playAmbient` is idempotent on same path so a cached tent fire player just ramps volume back without restarting. No accumulation.
- **Race-condition fragility under load** — the fix removes the race entirely (the dispose's fadeOut was the racing party). Under thermal throttle, the new tent player still gets created before the dispose runs (synchronous `initState` fires before stack unwind starts disposing routes). The instrumentation provides post-hoc diagnostic if a different race emerges.
- **Reader-mode interaction** — the reading-room ambient (Phase 2 / prompt #621) doesn't exist yet. When it lands, Reader → tent transition will pass through this code; tent's `_startTentAmbient` will run (idempotent if reading-room ambient was already fading out via Reader-screen dispose). No special handling needed. Will revisit during Phase 2 verify.

---

## Two-strike rule (spec §two-strike)

Per spec rule: "If the diagnostic-first step says 'Possibility A' and the fix to A doesn't resolve, do NOT skip to 'let me also try B' without re-instrumenting."

This commit's diagnostic was **B**, and the fix targets B (race between dispose's fadeOut and new tent's just-started player). If A56 verify shows the bug persists, the rule says **re-diagnose, don't try a different theoretical fix.** The shipped instrumentation (caller-stack capture in `fadeOut` + `playAmbient`) gives the next iteration logcat-equivalent evidence from the always-on B27 overlay.

---

## Build discipline checklist

- [x] Single commit with `R28-HF2-AMBIENT:` prefix
- [x] `flutter analyze`: 0 new warnings (1 pre-existing baseline `audio/vo/` directory warning unchanged from R28-HF1)
- [x] `flutter test`: 29/29 pass
- [ ] Single APK at end — _hashes filled in below after build completes_
- [ ] `libapp.so` arm64 hash moved from R28-HF1 — _confirmed below_

---

## Branch state at handoff

After this commit, the branch is **36 commits** beyond `origin/main`:

```
[handoff]   this commit
a1611f9  R28-HF2-AMBIENT: tent ambient survives event-completion return
b8f0663  R28-HF1:         handoff doc (Reset full-wipe + AR intro text-direction)
8c1469e  R28-HF1-INTRO:   explicit LTR on EN intro lines fixes punctuation pos
34e6a1b  R28-HF1-RESET:   Reset Journey full wipe to fresh-install state
49fe8a9  R28 S3-P1:       handoff doc (foundation + writing engine, 11 items shipped)
…11 R28-S3 Phase 1 commits…
67168f7  R28 S2 MEDIUM:   handoff doc
…4 R28-S2 commits…
2acc7d0  R28 S1 HUGE:     handoff doc
…8 R28-S1 commits…
cfcea3b  R27 S3 HF:       handoff doc
…6 R27-S3 commits…
```

**Push gate stays held.** Per spec §protocol step 8: full bundle (33 prior + HF1 commits + HF2 commit) clears to push origin/main only after **both** HF1 and HF2 verify clean on A56.

---

## Self-verify checklist (per spec §protocol step 6)

- [x] Walked all 6 acceptance steps via code inspection above
- [x] Walked all 7 regression checks via code inspection above
- [x] Diagnostic finding documented (Possibility B, with code-path evidence and explanation of why hardware logcat wasn't used)
- [x] Specific code path / caller changed: `immersive_event_screen.dart:669` removed; instrumentation added to `audio_service.dart` (`fadeOut`, `playAmbient`)
- [x] Diff line counts documented
- [x] APK SHA: `2a14aa03eee8efed32dd085c845409f496cbf326f451142ebfb14aea5c525fd2`
- [x] libapp.so arm64 hash moved from `df400fdd…` (R28-HF1) → `0d04c039…` (R28-HF2)
- [ ] Owner walks A56 acceptance + regression lists

---

_Handoff written Apr 27 2026 ~13:30 Amman. R28-HF2 is HF1's parallel queue mate. When A56 verify lands clean on both HF1 and HF2, the full 36-commit bundle clears to push origin/main in one shot._
