# Rawi — Round 3 Testing Notes
**Date:** 2026-04-02
**Tester:** Khaled
**Build:** Sprint 25 APK (branching system + Go Deeper + transition polish)

---

## Bug Tracker

| # | Severity | Bug | Status |
|---|----------|-----|--------|
| R3-01 | MEDIUM | **Keyboard stays open after name input** | **FIXED** | Sprint 26 — `FocusScope.of(context).unfocus()` in `_nextPage()` |
| R3-02 | HIGH | **Back button exits app during onboarding** | **FIXED** | Sprint 26 — `PopScope` with exit dialog on page 1, `_prevPage()` on pages 2-4 |
| R3-03 | HIGH | **Transition screen feels soulless** | **FIXED** | Sprint 26 — Sky gradient background from event config, gold dust particles, ambient audio fade-in |
| R3-04 | CRITICAL | **Branching hotspot positions cause backtracking** | **FIXED** | Sprint 26 — All 3 events remapped: anchor at bottom, branches in forward triangle above, convergence at top. Proximity guard added while branch card showing. |
| R3-05 | HIGH | **Branch decision card needs VO** | **FIXED** | Sprint 26 — 12 branch VO files generated (3 events x 2 lang x 2 gender). Plays on card show, fades on option selected. |
| R3-06 | CRITICAL | **Post-event flow still broken** | **FIXED** | Sprint 26 — `completeEvent()` + `clearHotspotProgress()` now called synchronously with `await` in `_selectChoice()` BEFORE any navigation. No more fire-and-forget race condition. |

---

## Detailed Notes

### R3-04 — Hotspot Position Remapping Rules

**The principle:** User should NEVER walk backward. Flow is always forward through the scene.

```
Layout concept (per event):

        [Branch A] ←────┐
           ↑             │ (user picks one, then the other)
      [ANCHOR] ──────→ [Branch B]
           ↑             │
        [START]          ↓
                    [CONVERGENCE]
```

**Per event:**
1. Anchor position: locked based on event artwork (natural first stop)
2. Branch A & B: both positioned AFTER anchor in walking direction, in a triangle/fork shape
3. Convergence: positioned at the natural scene endpoint
4. The figure must never need to walk past the anchor to reach a branch hotspot
5. Branch hotspots should not be so close to anchor that proximity triggers while branch card is showing

### R3-06 — Post-Event Flow Expected

```
EXPECTED:
  Answer question → event auto-completes (PrefsService) → XP snackbar
  → 3s delay → auto-pop → event list shows 4/4 + next event unlocked

ACTUAL (broken):
  Answer question → pop → event list shows Play (stale!)
  → tap Play → cinematic → question re-appears → answer again → pop → NOW updated
```

Root cause likely: `_completeAndReturn()` either isn't being called, or the pop happens before `completeEvent()` finishes. Need to trace the exact execution path for branching events — the `convergenceQuestion` phase may have a different completion path than the linear `choose` phase.

---

## Post-R3 Fixes (same session)

| # | Fix | Details |
|---|-----|---------|
| POST-1 | **Crossroads tutorial timing** | Tutorial overlay removed entirely (Fix 3 from UI spec). Crossroads card is self-explanatory. |
| POST-2 | **Locked hotspot visibility** | Dark circle backing (40px, black 40%) behind locked diamonds. |
| POST-3 | **The Verdict cinematic styling** | Gold border, deeper dim, gold answer borders, gold explanation section. |
| POST-4 | **Chapter preview redesign** | Cinematic black bg, gold text blocks, chapter names with event counts. |
| POST-5 | **VO timing rules** | Strict start/stop rules, no overlaps, companion bubbles on SFX layer. |
| POST-6 | **VO replay button** | Speaker icon on discovery panels + Verdict card. |
| POST-7 | **"What does history remember?"** | Verdict header changed from "What would you do?" for branching events. |
| POST-8 | **Event list timeline redesign** | Chapter headers, gold timeline thread, progress dots, card visual states. |
| POST-9 | **CRITICAL: Completion flow fix** | Deleted auto-pop timer. Manual "Continue Journey" button. Await all writes. Back blocked during Verdict. XP badge in-card. |
| POST-10 | **Terminology update** | Gate, Crossroads, Paths, Gathering, Verdict, Reflection — everywhere. |
| POST-11 | **pushReplacement fix** | Root cause of stale events list — push+await+pop chain instead of pushReplacement. |
| POST-12 | **VO buttons split** | Replay (🔄) + mute (🔇) instead of single confusing speaker icon. |
| POST-13 | **Collapsible eras** | Only active era expanded by default. Tap header to toggle. |
| POST-14 | **Card overflow fix** | Event 3 two-line title overflow — Row crossAxisAlignment.start. |
| POST-15 | **XP animation** | Star pop, count-up tween, particle burst, total XP line, delayed Continue. |
| POST-16 | **Badge system** | 7 badges, BadgeDefinition model, checkAndAwardBadges, badge overlay, profile grid. |
| POST-17 | **Hotspot visibility** | Dark backing on all states, gold outline ring, stronger glow. |
| POST-18 | **Ambient audio disabled** | Looping desert ambient reported annoying. Will redesign. |
| POST-19 | **Badge overlay redesign** | Full-screen 85% overlay, sequential completion flow (badges awarded one at a time). |
| POST-20 | **Audit fixes** | Signing config added, latlong2 removed, dead code cleaned, performance improvements, persistence fixes. |
| POST-21 | **Chronological reorder** | Black Stone (605 CE) moved from Jahiliyyah pos 3 → Early Life pos 8. Ta'if (619 CE) moved to pos 17 (after Year of Grief). |
| POST-22 | **RawiDialog** | Reusable gold/navy dialog widget, replaced all AlertDialogs. |
| POST-23 | **Intro bilingual** | Device locale detection, Arabic text on Arabic devices. |
| POST-24 | **Name mandatory** | 2-15 chars, Skip removed, Continue disabled until valid. |
| POST-25 | **Name personalization** | {name} in companion bubbles, "Well done, {name}" on allDone. |
| POST-26 | **Settings polish** | Name + "Rawi since" date + Accessibility text scale toggle. |
| POST-27 | **Accessibility** | Text scale Normal/Large (1.0x/1.3x) via MediaQuery override. |
| POST-28 | **Reward system rebalance** | 7 badges rebalanced (Seeker@5, Witness@11, Keeper@15, Steadfast@22, Scholar@30, Guardian@36, Rawi@36), chapter completion screens, layered flow (chapter → badge → XP → auto-pop). |
| POST-29 | **Bubble image scaling** | Bubble images scale with text size preference. |
| POST-30 | **Scroll hint indicators** | `scroll_hint_wrapper.dart` — scroll hints on discovery panel, Verdict, Reflection. |
| POST-31 | **Bug fixes A12-A17** | Exit fix, save progress fix, idle overlap fix, font reflect fix, splash v31 (Android 12+), Rawi/Rawiah labels. |
| POST-32 | **Master Plan table fix** | Black Stone row corrected in RAWI_MASTER_PLAN.md. |
| POST-33 | **Doc cleanup** | Removed duplicate issue files from repo. |

---

## Round 4 Fixes (Sprint 42 — April 4, 2026)

| # | Fix | Details |
|---|-----|---------|
| R4-01 | **Splash font flicker** | `GoogleFonts.pendingFonts()` pre-caches fonts before splash. |
| R4-02 | **Intro bilingual + no Skip + BG music** | Both EN+AR on every line, Skip removed, onboarding music plays intro→registration, fades on "Start the Journey". |
| R4-03b | **Figure auto-movement (non-negotiable)** | Absolute guard in `_onFrame()` for ALL overlay states. Joystick zeroed + loop stopped before branch card. |
| R4-03c | **Route line partially invisible** | Rewrote `PathRoutePainter`: ahead=bright silver with glow, behind=faded, current segment split at figure position. |
| R4-03d | **Hotspot tap → auto-walk** | Tapping next active hotspot auto-walks figure along path. `_autoWalkTo()` with `_pathProgressForHotspot()`. Locked hotspots ignore tap. |
| R4-03e | **Era label contrast** | Navy bg `withAlpha(200)`, era color border `withAlpha(120)`. |
| R4-03f | **Progress dots visibility** | Empty dots now gold border `withAlpha(80)` at 1.5px width. |
| R4-04 | **XP overlay not full-screen** | Verdict/Reflection hidden when chapter/badge/XP overlays active. |
| R4-06 | **Settings overlay redesign** | Centered card, gold/navy, compact toggles, "Paused" header. |
| R4-10 | **Play → Continue** | Shows "Continue"/"أكمل" for events with saved hotspot progress. |
| R4-11 | **Chapter overlay overlapping** | Same guard as R4-04 + chapter bg opacity 245 (near-opaque). |
| AMB | **Ambient sound infrastructure** | `ambientPath` on SceneHotspot, `playAmbient()` re-enabled, `fadeAmbientTo()`, per-hotspot ambient play/stop, onboarding music wiring. |
| R4-12 | **Auto-walk overlay guard** | `_onAutoWalkFrame` stops when any overlay opens |
| R4-13 | **Auto-walk softlock on background** | `_stopAutoWalk()` called in `didChangeAppLifecycleState` paused handler |
| R4-14 | **VO stream listener leak** | `_voSub` subscription stored and cancelled explicitly |
| R4-15 | **setState 60fps perf (REVERTED)** | Optimization broke movement — reverted to per-frame setState |
| R4-16 | **Arabic italic intro** | `FontStyle.normal` on Arabic lines + Begin button |
| R4-17 | **Arabic first line** | "الميلاد ٥٧٠" → "٥٧٠ ميلادي" (later R5-03 corrected to Western Arabic) |
| R4-18 | **Begin button font** | Lora font + "/" separator ("Begin / ابدأ") |
| R4-19 | **Branch card cut off** | `ScrollHintWrapper` added to branch decision card |
| R4-20 | **Locked hotspot grey labels** | Labels hidden entirely for locked hotspots |
| R4-21 | **White squircle on resume** | Adaptive icon XML created (later refined in R6-02) |
| R4-22 | **Continue button spacing** | `SizedBox(width: 12)` between event text and button |
| R4-08 | **VO truncated content** | Regenerated 12 VO files with full fragment text (poet, birds, cloak — convergence hotspots had abbreviated text in `generate_vo.py`) |

---

## Round 5 Fixes (Sprints 43–47 — April 5, 2026)

### Sprint 43 — R5 Sprint A+B (11 fixes)
| # | Fix | Details |
|---|-----|---------|
| R5-01 | **App icon wrong** | Removed broken self-referencing adaptive icon XML (later refined) |
| R5-02 | **Arabic italic (REPEATED)** | Explicit `FontStyle.normal` on all Arabic — root-caused in Sprint 45 |
| R5-03 | **Hindi numerals** | Global sweep: 6 instances converted to Western Arabic |
| R5-04 | **Typo العالم** | Added missing "ال" |
| R5-05 | **"THE NARRATOR" line break** | Split onto two lines with quotes |
| R5-06 | **Transition particles freeze** | Continuous `_particleCtrl.repeat()` AnimationController |
| R5-07 | **Scroll indicator subtle** | 28→36px icon, bounce 6→10, gold border, stronger glow |
| R5-10 | **XP overlay too small** | 64→96px star, 32→48 XP text, 280→340 width |
| R5-11 | **Event card overflow** | Center-aligned Row, removed stray SizedBox |
| R5-14 | **Badge persistence** | Code verified correct (read/write same key) |
| R5-15 | **Events 4-8 "0/0"** | Checkmark instead of 0/0 for no-config events |

### Sprint 44 — R5 Sprint C+D
| # | Fix | Details |
|---|-----|---------|
| R5-05b | **Arabic narrator duplicate** | Single line (was "أنت الراوي\n\"الراوي\"") |
| R5-11b | **XP overlay overflow** | Removed fixed 120 height, `clipBehavior: none` |
| R5-16 | **Reset Journey bug** | Full sweep: hotspot progress, badges, streak, tutorials, journey pointer. Preserves profile. |
| Part 2 | **Registration redesign** | 2 screens (Identity + Language) instead of 4. Blurred cinematic bg. Chapter preview killed. |
| Part 3 | **Settings reorder** | Profile → Journey → Preferences → About → Reset (destructive, last). Badges removed. |
| R5-12 | **Badge placeholder** | Geometric gold diamond + rosette + navy circle (no more stock emoji) |

### Sprint 45 — R5 Code Review
| # | Fix | Details |
|---|-----|---------|
| F1 | **Arabic italic ROOT CAUSE** | Lora has no Arabic glyphs — fallback font inherited italic. 14 instances switched to `isAr ? FontStyle.normal : FontStyle.italic` |
| F2 | **Transition particles gate** | `_cardOpacity` → `_blackOpacity` (visible entire lifetime). Hold 2000→3000ms |
| F3 | **XP overlay sizes** | Star 64→96, text 32→48, width 280→340, total 18→24, particle radius 70→100 |
| F6 | **Scroll indicator** | Icon 28→36, bounce 6→10, padding 14/6→18/10, gold border 1→1.5px |
| F7 | **Adaptive icon** | `mipmap-anydpi-v26/ic_launcher.xml` with navy_bg + inset drawable foreground |

### Sprint 46 — Sound Integration (8 ElevenLabs clips)
- `ambient_intro.mp3` → intro cinematic
- `ambient_transition.mp3` → cinematic transition
- `ambient_crossroads.mp3` → branch card
- `ambient_e1_kaabah/merchants/idols.mp3` → Event 1 hotspot `ambientPath`
- `sfx_xp.mp3` → XpRewardAnimation initState
- `sfx_badge.mp3` → BadgeOverlay initState

### Sprint 47 — Audio Isolation
Strict window containment across 10+ exit points. Short fades (200-500ms) replace hard stops. Race-safe via `fadeOut`'s player identity check.

---

## Round 6 Fixes (Sprint 48 — April 5, 2026)

| # | Fix | Priority | Details |
|---|-----|----------|---------|
| R6-01 | **Freeze after reset→replay→complete** | P0 | Nested `Navigator.push` caused context lifecycle issues on second playthrough. Replaced with `pushReplacement`. Also removed dead `playAmbient('ambient_desert_evening.wav')` call (non-existent file). |
| R6-02 | **App icon wrong (again)** | P0 | External `drawable/ic_launcher_foreground.xml` inset didn't render on Samsung. Inline `<inset>` inside `<foreground>`. Created `ic_launcher_round.xml`. Added `android:roundIcon` to manifest. |
| R6-03 | **Duplicate intro CTA screen** | P1 | "Witness history..." was in both `_lines` AND CTA section. Removed from `_lines`. CTA now uses Cinzel 22px matching sequence style. |
| R6-04 | **Intro ambient silent** | P1 | `playAmbient` fire-and-forget before `fadeAmbientTo` — fade started while `setAsset` loading. Extracted into `_startIntroAmbient()` that awaits play THEN fades. Same fix in cinematic_transition. |
| R6-05 | **Registration bg shifts with keyboard** | P1 | `resizeToAvoidBottomInset: false` + `GestureDetector` wrapping body with `onTap: unfocus` (tap anywhere to dismiss). |
