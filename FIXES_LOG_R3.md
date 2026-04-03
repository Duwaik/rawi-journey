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
