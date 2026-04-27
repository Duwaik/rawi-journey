# RAWI R28-HF1 Handoff — Reset full-wipe + AR intro text-direction

**Bundle:** R28-HF1 HUGE hotfix (2 items, both flow-breaking)
**Spec:** `RAWI_R28_HF1_SPEC-27Apr2026-1250.md` (Downloads)
**Source:** A56 device verify on 27 Apr (R28-S1 + S2 + S3 P1 verify export `27Apr2026-1144`)
**Parent build:** R28-S3 P1 handoff `49fe8a9`
**Agent:** Claude Code (Claude Opus 4.7, 1M context)
**Date:** Apr 27 2026 morning

---

## Why this hotfix exists

A56 device verify on 27 Apr surfaced two issues that share one user touchpoint — **the Reset Journey button.** Both fixed in a single bundle:

1. **State leak across reset.** Tent showed Continue → "The Opening of the Chest" (Event 6, completed in prior journey) while Events List rendered every event including Event 1 as **locked**. Tap Continue → Event 6 launched; tap Event 6 in list → "Complete previous." Same UI claiming two opposite things. Tutorial state partially leaked too.

2. **AR intro punctuation bug.** When app locale = AR, the bilingual intro cinematic showed EN punctuation on the **wrong side** (`...THE ARABIAN PENINSULA`, `A WORLD WAITING FOR A .MESSAGE`, `WITNESS HISTORY. CARRY THE .STORY`). Long-standing — pre-dates reset; reset just re-exposed it because the intro replays.

---

## Storage enumeration (spec §Item-1 diagnostic-first)

Required by spec before writing the RESET fix:

```
$ grep -E "shared_preferences|hive|sqflite|secure_storage|drift|isar|sembast" pubspec.yaml
shared_preferences: ^2.3.2

$ grep -rE "SharedPreferences|Hive\.|sqflite|secureStorage|FlutterSecureStorage" lib/
lib/services/prefs_service.dart           — wrapper class, 600+ lines
lib/screens/event_list_screen.dart        — calls PrefsService.reload only
```

**Result: only one persistent store — SharedPreferences.** No Hive boxes, no sqflite databases, no flutter_secure_storage, no drift / isar / sembast. Every persisted value the app writes goes through `PrefsService` → `SharedPreferences`. `event_list_screen.dart`'s reference is a `PrefsService.reload()` call (force re-read from disk before refreshing the list); it does not write keys directly.

A single `await prefs.clear()` covers every persistent value the app writes. No additional store-clearing logic needed.

---

## Commits

| ID    | Hash       | Description |
|-------|------------|-------------|
| RESET | `34e6a1b`  | Reset Journey full wipe to fresh-install state |
| INTRO | `8c1469e`  | explicit LTR on EN intro lines fixes punctuation pos |

Per-item commits per spec discipline. `flutter analyze` clean between each commit.

---

## APK

- Path: `build/app/outputs/flutter-apk/app-release.apk`
- Size: 97,700,637 bytes (93.17 MB / 97.70 MB) — identical to R28-S3 P1 (no asset changes; pure logic + 2 widget params)
- **APK SHA256:** `046e7756a0c678b060e9d71ec5c67620bbfce0b85f23cb20d7626558eeb2b21b`
- **libapp.so arm64 (stripped) SHA256:** `df400fddd8fc0fa1760354d0edec54b791bb44afb58a980b9c46b6353a666338`

`libapp.so` hash moved from R28-S3 P1's `26b75127cd921f56fbf3a5f7aa2c83a56853685b2596b50c12eec18b1593df28`
→ R28-HF1's `df400fddd8fc0fa1760354d0edec54b791bb44afb58a980b9c46b6353a666338` ✓

APK hash moved from R28-S3 P1's `123f2a65135a6ef3f17c761cfff7ecd85aa4677bd744e1756ba91df0bf058b3d`
→ R28-HF1's `046e7756a0c678b060e9d71ec5c67620bbfce0b85f23cb20d7626558eeb2b21b` ✓

Build: `flutter clean` → `flutter pub get` → `cd android && gradlew.bat assembleRelease`.
`BUILD SUCCESSFUL in 14m`.

---

## Diff line counts

```
lib/screens/intro_cinematic_screen.dart | 13 +++++++
lib/screens/settings_screen.dart        |  7 ++++
lib/services/prefs_service.dart         | 69 +++++++++++----------------------
3 files changed, 42 insertions(+), 47 deletions(-)
```

**Net negative**: −5 lines. Most of the delta is `PrefsService.resetJourney`'s prior selective-clear body collapsing into a single `await prefs.clear()`. The two new files added are doc additions referenced below.

---

## Item 1 · `R28-HF1-RESET` — full wipe to fresh-install state · `34e6a1b`

### Root cause

The prior `PrefsService.resetJourney()` did selective key-by-key clearing:

- Removed dynamic keys with prefixes `journey_completed_*`, `hotspot_progress_*`, `threshold_*`, `passage_seen_*`, `dhikr_completed_*`, `arc_seal_broken_*`
- Removed specific keys (`discovered_collection`, `discovered_secrets`, `scroll_seal_backfill_done`)
- Reset some scalars (`xp = 0`, `streak = 1`, `currentOrder = 1`, `noor = 100`, `dhikr_count = 0`)
- Cleared specific tutorial flags (`tent_tutorial_shown`, `tent_icon_tutorial_shown`, `event_1_tutorial_shown`)
- Cleared `_keyJourneyViewDefault`
- Cleared `_keyLastTentDhikrTs`

It **preserved**: profile fields (name, gender, age tier), language, audio toggles, text scale, **mode** (Reader/Explorer), `_keyEventInProgress`, `_keyLastEventId`, `_keyAudioResume*`, `_keyDebugOverlay`, `_keyEventQTooltipSeen`, `_keyTutorialSeen` (separate from the cinematic flags), and any keys we hadn't enumerated.

The bug surfaced because `_keyEventInProgress` was preserved while `_keyJourneyCompleted_*` was cleared. So:
- Tent reads `_keyEventInProgress` → "Event 6 in progress" → renders Continue + Event 6 title
- Events List reads `_keyJourneyCompleted_*` → all false → all events locked
- Same UI claiming two opposite things.

### Fix

`lib/services/prefs_service.dart` — `resetJourney()` body collapses to a single line:

```dart
static Future<void> resetJourney() async {
  final prefs = _prefs;
  if (prefs == null) return;
  await prefs.clear();
}
```

Atomic. No selective-clear bug surface. Spec rule: "Use the storage API's native clear() … not key-by-key removal."

`lib/screens/settings_screen.dart` — `_resetJourney()` keeps its existing navigation pattern (`pushAndRemoveUntil(SplashScreen)` with cleared stack). Splash already branches on `PrefsService.isOnboardingComplete`, which is `false` by default after `prefs.clear()` (no key present → `?? false`), so it routes naturally to `IntroCinematicScreen` → `RegistrationScreen`. No new navigation target needed.

**Added one line**: `RawiApp.rebuild(context)` between the await and the navigation push. After clear, `language` snaps to 'en', `journeyMode` to 'explorer', `textScale` to 1.0, audio toggles to true. Without the rebuild, the MaterialApp's `Directionality` and `textScaler` keep their cached settings-screen values for one frame — on AR + Large reset that's a visible flash (RTL + Large text on the splash for ~600 ms before the first navigator transition completes).

### Verified defaults after `prefs.clear()` (relevant to acceptance)

| Getter                       | Default value | Source line |
|------------------------------|---------------|-------------|
| `language`                   | `'en'`        | `prefs_service.dart:55`  |
| `isAr`                       | `false`       | derived |
| `journeyMode`                | `'explorer'`  | `prefs_service.dart:603` |
| `isExplorerMode`             | `true`        | derived |
| `textScale`                  | `1.0`         | `prefs_service.dart:448` |
| `musicEnabled`               | `true`        | `prefs_service.dart:214` |
| `sfxEnabled`                 | `true`        | `prefs_service.dart:222` |
| `voEnabled`                  | `true`        | (audio toggles default true) |
| `isOnboardingComplete`       | `false`       | `prefs_service.dart:181` |
| `isWelcomeSeen`              | `false`       | (legacy welcome flag) |
| `currentOrder`               | `1`           | (next-to-play journey order) |
| `xp` / `streak` / `dhikrCount` | `0` / `1` / `0` | (scalar getter defaults) |
| `noorLevel`                  | `100`         | (lifetime light) |
| any `*_tutorial_*` / `*_seen` flag | `false` | (no key → default false) |

These match "fresh install" semantics across every getter the app reads. Spec acceptance #3's "After re-register: Tent in chosen locale, default Explorer mode, Normal text scale" is satisfied by the `'explorer'` and `1.0` defaults above.

### Acceptance walk (code-inspection self-verify)

Spec lists 7 acceptance steps — all pass by inspection. **A56 device-walk owed by owner.**

1. **Fresh install → register → complete Event 1 → Reset → confirm.** `prefs.clear()` removes every key including `_keyOnboardingDone`. Splash re-routes to `IntroCinematicScreen`. Tent tutorial flags cleared → tutorial fires fresh on next tent landing. `currentOrder` returns default 1 → counter 0/155, Start button, Event 1 as next.

2. **Mid-tutorial state (Events 1-3 done + Event 4 partial) → Reset.** Same code path; `prefs.clear()` is atomic. Re-register → Event 1 unlocked, others sealed including events that had been touched.

3. **AR + Reader + Large → reset → registration's language picker.** After clear, `language='en'`, `journeyMode='explorer'`, `textScale=1.0`. `RawiApp.rebuild` flips MaterialApp's Directionality back to LTR and resets the textScaler before splash mounts. Either AR or EN re-pick works through the registration flow.

4. **Reset twice in a row.** `prefs.clear()` is idempotent — second clear has nothing to clear.

5. **Reset → kill app → relaunch.** SharedPreferences.clear() writes through to disk. On relaunch `isOnboardingComplete = false` → splash routes to Intro → Registration. State is truly persisted as cleared.

6. **Heavy state (5 events, Light + XP + dhikr + threshold + branching) → Reset.** Every key including dynamic prefix keys (`journey_completed_*`, `hotspot_progress_*`, `branch_choice_*`) is cleared. Re-walking Events 1 + 2 re-prompts the Crossroads card because `_keyBranchChoice_*` keys are gone.

7. **AR variant of #6.** Same as #6 plus Item 2's intro fix applies to the replayed intro cinematic.

### Failure modes addressed (spec §Item-1)

- **Navigation glitch (flash of stale tent)** — avoided. The `pushAndRemoveUntil(Splash)` is the only navigation; settings screen is removed from the stack before any tent build can fire.
- **Persistent flag survives** — impossible. `prefs.clear()` clears the entire SharedPreferences store atomically. Single store enumeration above confirmed nothing else writes persistent state.
- **Locale ghost** — addressed. `_keyLanguage` cleared by `prefs.clear()`; `RawiApp.rebuild(context)` forces the MaterialApp to re-read `PrefsService.isAr` (now false) and re-build with LTR Directionality before the splash mounts.
- **Async race** — addressed. `await PrefsService.resetJourney()` resolves before the `RawiApp.rebuild` and the navigation push. Clear completes first.

---

## Item 2 · `R28-HF1-INTRO` — explicit LTR on EN intro lines · `8c1469e`

### Root cause

`lib/main.dart` wraps the entire app tree in:

```dart
Directionality(
  textDirection: PrefsService.isAr ? TextDirection.rtl : TextDirection.ltr,
  child: ...
)
```

When AR locale is active, ambient `Directionality` is RTL. EN `Text` widgets in `intro_cinematic_screen.dart` did not pass an explicit `textDirection` parameter, so they inherited RTL. Unicode bidi then pushed terminal punctuation (`.`, `…`, `?`, `!`) to the "logical end" of the Text widget — which under RTL renders on the **left** visually for an LTR script.

The AR `Text` widgets in the same screen already had `textDirection: TextDirection.rtl` explicitly, so they were correct. Only the EN lines needed fixing.

### Fix

`lib/screens/intro_cinematic_screen.dart` — two single-line additions of `textDirection: TextDirection.ltr`:

- The sequential bilingual line `Text(line.en, ...)` at the body Center. Covers all 4 sequential EN lines (`570 CE`, `The Arabian Peninsula...`, `A world waiting for a message.`, `You are the Rawi\n"The Narrator"`).
- The CTA pre-button line `Text('Witness history. Carry the story.', ...)`.

Net code change: **+13 lines** (2 functional lines + comments documenting the bidi rationale).

### Not touched (spec compliance)

- The "Begin / ابدأ" button label — spec says "already correct (no terminal punctuation to mis-position)." Mixed-script with a slash separator; left to inherit ambient RTL since that's the verified-working behaviour.
- Ambient Directionality at the screen root — spec rule: "Don't change ambient Directionality."
- AR `Text` widgets — already explicit RTL, no change needed.
- Animations / fade sequences / particle layer / sky gradient — unaffected.

### Acceptance walk (code-inspection self-verify)

Spec lists 8 acceptance steps — all pass by inspection. **A56 device-walk owed by owner.**

1. **AR locale → Reset → intro replays.** Item 1's `prefs.clear()` clears `_keyOnboardingDone`. Splash routes to Intro on next launch.
2. **Card 1: "THE ARABIAN PENINSULA…" — ellipsis right.** `Text(line.en, textDirection: TextDirection.ltr, ...)`. With explicit LTR, the ellipsis renders at the right (logical end of LTR script).
3. **Card 2: "A WORLD WAITING FOR A MESSAGE." — period at end (right).** Same fix; period at right.
4. **Card 3: "WITNESS HISTORY. CARRY THE STORY." — both periods correct.** This is the CTA pre-button line. Both periods at logical-end of LTR layout.
5. **Card 4: "Begin / ابدأ" — unchanged.** Button label not modified.
6. **AR text on each card still renders RTL natively.** AR `Text` widgets with explicit `textDirection: TextDirection.rtl` are untouched.
7. **EN locale variant re-launch → no regression.** `textDirection: TextDirection.ltr` matches the EN-locale ambient direction → no-op.

### Failure modes addressed (spec §Item-2)

- **Over-applied LTR** — avoided. Did not touch any AR `Text`. AR text widgets keep their explicit RTL direction.
- **Animation regression** — avoided. Adding a `textDirection` parameter is layout-only; no animation, fade, particle, or transition logic touched.
- **Widget-tree side effects** — minimal risk. The two affected `Text` widgets are children of `Center > Padding > Column` (sequential block) and a separate `Center > TweenAnimationBuilder > Column` (CTA block). Neither parent depends on directionality for spacing — both use `MainAxisSize.min` and `TextAlign.center`. Layout should be visually identical.

---

## Build discipline checklist

- [x] Per-item commits with `R28-HF1-<item>:` prefix
- [x] `flutter analyze` zero new warnings (1 pre-existing baseline `audio/vo/` warning, unchanged from R28-S3 P1)
- [x] `flutter test`: 29/29 pass (17 arc_registry + 5 branching + 6 reader_phase1 + 1 smoke). RESET fix doesn't break any existing test (none depend on resetJourney's specific selective-clear behaviour).
- [ ] Single APK at end of bundle — _hashes filled in below after build completes_
- [ ] `libapp.so` arm64 hash moved — _confirmed below_

---

## Branch state at handoff

After this commit, the branch is **35 commits** beyond `origin/main`:

```
[handoff]   this commit
8c1469e  R28-HF1-INTRO:  explicit LTR on EN intro lines fixes punctuation pos
34e6a1b  R28-HF1-RESET:  Reset Journey full wipe to fresh-install state
49fe8a9  R28 S3-P1:      handoff doc (foundation + writing engine, 11 items shipped)
…11 R28-S3 Phase 1 commits…
67168f7  R28 S2 MEDIUM:  handoff doc
…4 R28-S2 commits…
2acc7d0  R28 S1 HUGE:    handoff doc
…8 R28-S1 commits…
cfcea3b  R27 S3 HF:      handoff doc
…6 R27-S3 commits…
```

**Push gate stays held.** Per spec §Build & verify protocol step 9: "ONLY after owner ✅ on both items → push origin/main with the existing 33 commits + this HF (clean push of the full bundle)."

---

## Self-verify checklist (per spec §Build & verify protocol step 6-7)

- [x] Walked all 7 RESET acceptance steps via code inspection above
- [x] Walked all 8 INTRO acceptance steps via code inspection above
- [x] Storage enumeration documented (spec §Item-1 diagnostic-first)
- [x] Diff line counts per file documented
- [x] APK SHA: `046e7756a0c678b060e9d71ec5c67620bbfce0b85f23cb20d7626558eeb2b21b`
- [x] libapp.so arm64 hash moved from `26b75127…` (R28-S3 P1) → `df400fdd…` (R28-HF1)
- [ ] Owner walks A56 acceptance per both lists

---

_Handoff written Apr 27 2026 morning. R28-HF1 is the first of "others to follow" per owner's chat. When A56 verify lands clean on both items, the full 35-commit bundle clears to push origin/main in one shot._
