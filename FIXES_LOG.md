# Rawi — Fixes Log

> Post-MVP testing rounds. Each round captures bugs from a testing session,
> tracks fix status, and links to the sprint that resolved it.

---

## Round 1 — First Device Test (Samsung A56)
**Date:** 2026-04-02
**Tester:** Khaled
**Build:** Debug APK from Sprint 11 (163MB)
**Overall:** "Fantastic, with some tweaks we will make a great app wallah!"

### Bug Tracker

| # | Severity | Bug | Status | Sprint |
|---|----------|-----|--------|--------|
| R1-01 | CRITICAL | **Figure freezes after app resume** — after pressing home and returning, companion can't move at all. Game loop doesn't restart. | **FIXED** | Sprint 12 |
| R1-02 | CRITICAL | **Figure auto-moves by itself** — companion moves without joystick input. Should only move when user touches joystick. | **FIXED** | Sprint 12 |
| R1-03 | CRITICAL | **VO continues when app backgrounded** — voice over keeps playing after pressing home button. Should pause/stop. | **FIXED** | Sprint 12 |
| R1-04 | HIGH | **Hotspots hidden (UX change)** — progressive reveal hides upcoming hotspots. User wants ALL hotspots visible but dimmed/locked. Only next one active (pulsing, tappable). Rest visible but not tappable until unlocked sequentially. | **FIXED** | Sprint 13 |
| R1-05 | HIGH | **Hub shows Event 1 visual for all events** — "map" screen always shows Event 1 parallax scene. | **FIXED** | Sprint 15 — new `EventListScreen` replaces parallax hub |
| R1-06 | HIGH | **Post-event flow too many taps** — "Witnessed" button → map → tap again. | **FIXED** | Sprint 15 — `_continue()` pops directly to event list, progress auto-refreshes |
| R1-07 | HIGH | **Reset journey doesn't restart app** — stays on settings screen. | **FIXED** | Sprint 15 — `pushAndRemoveUntil(SplashScreen)` clears nav stack |
| R1-08 | HIGH | **App resume goes to last screen** — stays on event screen after home. | **FIXED** | Sprint 15 — event list is now home, lifecycle properly managed in Sprint 12 |
| R1-09 | MEDIUM | **Gender selection images** — circle containers show but images clip oddly at edges. Layout/sizing issue in `_GenderCard`. | **FIXED** | Sprint 14 |
| R1-10 | MEDIUM | **Arabic VO is Egyptian** — should be Jordanian/Palestinian. Voice sounds Egyptian dialect. | **FIXED** | Sprint 14 — switched to Syrian `ar-SY-LaithNeural`/`ar-SY-AmanyNeural` (closest to Palestinian) |
| R1-11 | MEDIUM | **Companion speech bubbles missing VO** — idle/nudge text bubbles have no audio. | **FIXED** | Sprint 14 — wired `_companionVoPath()` into all `_showBubble()` calls |
| R1-12 | MEDIUM | **"Explore the scene" placement** — text at bottom overlaps with joystick area. | **FIXED** | Sprint 14 — moved from `bottom: 180` to `top: topPad + 52` |
| R1-13 | MEDIUM | **Bubble images cropped** — some discovery panel images don't fit the card properly. | **FIXED** | Sprint 14 — changed `BoxFit.cover` + fixed `height: 160` to `BoxFit.contain` + `maxHeight: 180` |
| R1-14 | MEDIUM | **VO doesn't complete full text** — narration stops before finishing the full fragment. | **FIXED** | Sprint 14 — regenerated all VO with full-length fragments matching scene_configs |

### Screenshots
All 11 screenshots saved in `assets/bugs/` from this testing session.

| R1-15 | HIGH | **No gameplay tutorial** — first-time player enters Event 1 with no guidance. | **FIXED** | Sprint 16 — 2-step tutorial overlay with icons, arrows, bilingual text |

### Fix Plan
```
Sprint 12 — Critical Fixes (R1-01, R1-02, R1-03)
Sprint 13 — Hotspot Visibility UX Change (R1-04)
Sprint 14 — Visual & Audio Fixes (R1-09 to R1-14)
Sprint 15 — Hub Redesign + Post-Event Flow (R1-05 to R1-08)
Sprint 16 — Gameplay Tutorial Overlay (R1-15)
```

### Round 1 Summary
**15/15 bugs fixed** across Sprints 12-16.
- 3 critical (freeze, auto-move, VO leak)
- 5 high (hotspot visibility, hub redesign, post-event flow, reset, tutorial)
- 6 medium (gender images, Arabic dialect, companion VO, text placement, image crop, VO text)
- 1 new feature (gameplay tutorial)

---

## Round 2 — Second Device Test (Samsung A56)
**Date:** 2026-04-02
**Tester:** Khaled
**Build:** Debug APK from Sprint 16

### Bug Tracker

| # | Severity | Bug | Details | Status | Sprint |
|---|----------|-----|---------|--------|--------|
| R2-01 | HIGH | **Event list: missing hotspot counter + weak Play button** | No counter on next/locked events. Play button too subtle. | **FIXED** | Sprint 19 — added ◆ X/4 counter from saved progress, Play button now gold filled with glow |
| R2-02 | HIGH | **Event 1 has no visible animation** | Particles configured but alpha too low (0x35 = 20%). Invisible on device. | **FIXED** | Sprint 18 — alpha boosted 0x35→0x80, count 30→40 |
| R2-03 | MEDIUM | **Last hotspot proximity too tight** | Figure needs to overshoot past last hotspot to trigger. | **FIXED** | Sprint 19 — radius 0.07→0.09 |
| R2-04 | HIGH | **"Moment of reflection" (choice phase) UX problems** | (1) No VO for question/explanation. (2) No tutorial. (3) Unclear purpose. | **FIXED** | Sprint 20 — question+explanation VO (24 MP3s), choice tutorial overlay, intro text "What would you do?" |
| R2-05 | CRITICAL | **Post-event flow still has unnecessary steps** | Current broken flow: finish choice phase → "Continue the Journey" → stale event list → replay cinematic → "Witnessed" → finally updates. Expected: auto-complete on choice answer → auto-pop to updated event list. | **FIXED** | Sprint 17 |
| R2-06 | HIGH | **Back button during event loses all progress** | If user presses Android back, ALL discovered hotspots lost. Expected: save and resume. | **FIXED** | Sprint 17 |
| R2-07 | MEDIUM | **Back button on event list exits app** | No exit confirmation. | **FIXED** | Sprint 19 — PopScope with bilingual "Exit game?" dialog |
| R2-08 | HIGH | **Locked hotspots still not visible on scene** | Opacity 0.35 too low on dark backgrounds. Rendering logic correct but visually invisible. | **FIXED** | Sprint 18 — opacity 0.35→0.6, border 50→80 alpha, added subtle glow, icon white38→white54 |
| R2-09 | MEDIUM | **Event 3 no animation** | Same root cause as R2-02 — particle alpha too low (0x28 = 16%). | **FIXED** | Sprint 18 — alpha boosted 0x28→0x70. Event 2 also boosted 0x30→0x70. |
| R2-10 | MEDIUM | **Reset then replay shows cinematic for Event 4** | Cinematic transition played before flat events (no scene). Disconnected feel. | **FIXED** | Sprint 17 — cinematic only for immersive events, flat events get direct fade |

### Screenshots
11 screenshots saved in `assets/bugs/` (02.46.* series) from this testing session.

### Key User Expectations (from feedback)
1. **Event completion = after choice answer** — not after tapping Continue/Witnessed
2. **Hotspot progress persists** — even if user backs out mid-event
3. **ALL hotspots always visible** on scene (locked = dimmed, not hidden)
4. **No unnecessary screens** between events — complete → event list (updated) → next event
5. **Animations matter** — static scenes feel unfinished
6. **Back button = confirm exit**, not instant quit

### Fix Plan
```
Sprint 17 — Post-event flow overhaul (R2-05, R2-06, R2-10)
            - Complete event on choice answer, not on Continue tap
            - Save hotspot progress on back press
            - Skip cinematic for flat events (4+)

Sprint 18 — Scene animations + hotspot visibility (R2-02, R2-08, R2-09)
            - Debug particle rendering on Events 1 & 3
            - Fix locked hotspot rendering (verify + increase opacity)

Sprint 19 — Event list polish + UX (R2-01, R2-03, R2-07)
            - Add hotspot counter to all event cards
            - Stronger Play button styling
            - Last hotspot proximity increase
            - Back button exit confirmation

Sprint 20 — "Moment of reflection" enhancement (R2-04)
            - Add VO for question + explanation
            - Add tutorial step for first choice phase
            - Clearer UX intro text
```

### Round 2 Summary
**10/10 bugs fixed** across Sprints 17-20.
- 1 critical (post-event flow overhaul)
- 5 high (hotspot visibility, animations, back progress save, event list, choice UX)
- 4 medium (proximity, exit confirmation, Event 3 particles, cinematic for flat events)
