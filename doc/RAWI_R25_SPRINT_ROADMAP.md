# RAWI R25 — Sprint Roadmap (Apr 19 Device Testing)

> **Persistent document. Updated each session. Read this first before working on any R25 item.**
> Parent round: R24 (Batch 3) — see `RAWI_R24_BATCH3_SPEC_COMPLETE.md`
> Source: Khaled's Apr 19 midnight device testing session, 28 screenshots

---

## 0. GROUND RULES

- **One sprint per session.** Finish it completely before the next begins.
- **Sprint complete = agent pushed + Khaled verified on A56 + commit hash logged below.**
- **Each sprint has an "INPUTS NEEDED" block.** Khaled answers these BEFORE the sprint starts, during the PREVIOUS sprint's agent-execution phase. No sprint begins with open questions.
- **If a sprint uncovers new issues**, note them in §11 (Deferred Findings) — do not expand scope mid-sprint.
- **All my unbiased opinions for flagged items are LOCKED into this doc** (§9). Revisit only if device testing proves them wrong.

---

## 1. STATUS TRACKER

| Sprint | Title | Status | Agent Commit | Verified On Device |
|--------|-------|--------|--------------|--------------------|
| 1 | Tent → Event Navigation + Audio | ✅ Verified | `bf337c2` (tip, followup incl.) | Apr 19, 2026 — A56, all 7 items pass |
| 2 | Tent Screen Layout | 🔲 Not started | — | — |
| 3 | Event Scene Header + Noor | 🔲 Not started | — | — |
| 4 | Reader Mode Flow | 🔲 Not started | — | — |
| 5 | End of Event + Badge | 🔲 Not started | — | — |
| 6 | Stars + Scroll | 🔲 Not started | — | — |
| 7 | Global Polish | 🔲 Not started | — | — |

Legend: 🔲 Not started · 🟡 In progress · 🟢 Agent done, awaiting device · ✅ Verified

---

## 2. SPRINT 1 — Tent → Event Navigation + Audio (🔴 P0)

**Hypothesis:** Tent launches an event without cleanly tearing down the events-list screen. This single root cause likely explains the flash, the audio bleed, the frozen video, and the Threshold-redirect error.

### Items
- **S1-1** Tent → event: events-list screen visible for milliseconds before event loads (screenshot-confirmed on Birth, Khadijah, others)
- **S1-2** Tent → Threshold/non-event items → redirects to events list with "Complete the Threshold first" message. Tent must launch Threshold, scrolls, etc. directly.
- **S1-3** Event 2 (Year of the Elephant) video freezes on first scene when launched from tent. Force-close required. Works fine from events-list Start button.
- **S1-4** When Event 2 eventually loads, video music doesn't play — events-list BG sound continues over it.
- **S1-5** Rawi figure VO still active on event scenes (locked OFF long ago per agreement).
- **S1-6** Debug reporter did NOT capture the Event 2 freeze despite repeated occurrences. Related to B27 (persistent debug widget) — absorb here.
- **S1-7 (from B26):** Event 2 video needs graceful timeout + recovery if it fails to start.

### Agent scope
- Audit tent navigation: how does `autoOpenEventOrder` (B3 from Batch 3A) launch events? Is the events-list route pushed and popped silently, or skipped entirely?
- Ensure audio controllers from events-list screen (BG sound) are disposed BEFORE event/video controllers initialize.
- Add dispose hooks for Rawi figure VO on scene entry.
- Extend debug widget (B27) to log every nav transition and audio controller lifecycle event.
- Event 2 specific: add 8-second watchdog on VideoIntroScreen — if `onInitialized` hasn't fired, show "Replay" button instead of frozen frame.

### ✅ INPUTS — ANSWERED Apr 19, 2026
- **Q1.1** → Tent progress card cycles through all item types (event | threshold | scroll | non-event). Start button routes directly based on item type. No events-list interstitial.
- **Q1.2** → Rawi figure VO off EVERYWHERE. No exceptions. Gate behind `kRawiFigureVoEnabled = false` const.
- **Q1.3** → Root cause fix must eliminate freeze (S1-3/S1-4). Fallback UI = option B: "Replay / Skip" after 8s watchdog.

---

## 3. SPRINT 2 — Tent Screen Layout

### Items
- **S2-1** Combine Light + Experience + **Dhikr counter** into ONE left-side container (three stat pills in shared BG). Sized down slightly, shifted down a touch. _(Resolves S2-2 placement too.)_
- **S2-2** Dhikr counter restored as the third pill in the S2-1 group. Counter visible at all times.
- **S2-3** "Your Journey" has a ghost box rendering behind its own container. Remove the duplicate.
- **S2-4** Start/Continue button should sit on the SAME LINE as `#/155` (currently stacked). Frees vertical space for event title.
- **S2-5** Event title on progress card should be centered, given more room.
- **S2-6** Greeting unified: `Assalamu Alaykom, {name}` / `السلام عليكم، {name}` on one line, no time-of-day variants.
- **S2-7** Text size increase breaks tent layout (items overlap/clip). Every element needs min-height flex or max-font-size cap.

### Agent scope
- Edit `rawi_tent_screen.dart` stat pill widgets to merge into shared container.
- Find dhikr counter source (likely `useDhikrCounter` hook or provider) → expose on tent in a visible badge.
- Remove duplicate "Your Journey" box wrapper.
- Restructure progress card Row: `[title centered | Start/Continue button | #/155 count]`.
- Replace `_getGreeting()` with static `Assalamu Alaykom` / `السلام عليكم`.
- Add `TextScaler.clamp(1.0, 1.3)` at tent screen root + verify no overflow at max.

### ✅ INPUTS — ANSWERED Apr 19, 2026
- **Q2.1** → Dhikr counter joins Light + Experience as third pill in the same left-side container. Three stat pills in one BG group.
- **Q2.2** → Text size max cap: 1.3×. No additional accessibility rework.
- **Q2.3** → Greeting: "Assalamu Alaykom, {name}" / "السلام عليكم، {name}". Name follows greeting.

---

## 4. SPRINT 3 — Event Scene Header + Noor

### Items
- **S3-1** Event scene top bar cluttered: chapter pill + name + "Explore the scene" + settings + light all competing.
- **S3-2** Chapter pill currently looks like a tappable button (misleading). Must match UI guideline non-button pill style.
- **S3-3** Settings gear styling doesn't match guideline.
- **S3-4** Noor (light) does NOT render on event scene for some events (confirmed: "Under the Care of Abd al-Muttalib", "Marriage to Khadijah" scene shows no light around figure despite tent showing 100%).
- **S3-5** "Knowledge" label appears instead of "Your Light" after mode switches — investigate whether this is a string bug or a mode-state bug.

### Agent scope
- Redesign event scene header per §9 below.
- Reduce top bar elements; move light to top-left small circle (already partially done per screenshot 11), DROP the "Explore the scene" text, keep only dots.
- Audit Noor rendering logic: is noor% read from same source on tent and scene? Is scene reading a stale/default value?
- Grep "Knowledge" and "Your Light" strings across codebase to find where one substitutes the other.

### ⚠️ INPUTS NEEDED FROM KHALED (answer during Sprint 2)
- **Q3.1** Approve my minimal header proposal (§9.1), or do you still prefer the vertical side-column idea?
- **Q3.2** Drop "Explore the scene" text entirely, or keep it only on Event 1 as a first-time tutorial?
- **Q3.3** For "Knowledge" label bug: can you reproduce it? Specifically after which mode toggle sequence? (Reader → Listen? Listen → Reader? Settings → Back?)

---

## 5. SPRINT 4 — Reader Mode Flow

### Items
- **S4-1** After HS1 completes, both HS2 AND HS3 appear simultaneously before the branching content. Should be: branching content first → user chooses → only chosen branch's hotspot appears, other stays hidden.
- **S4-2** Figure moves slower than finger/toggle — user outruns figure, skips over hotspot visually, but hotspot content still triggers. Confusing. Figure should freeze or snap when HS triggers.

### Agent scope
- Rework hotspot reveal sequencing in reader mode: branching content first, then reveal only the chosen branch's HS2 or HS3.
- Figure movement: when HS proximity trigger fires, freeze figure at current position OR snap figure to HS marker (pick one — see Q4.2).

### ⚠️ INPUTS NEEDED FROM KHALED (answer during Sprint 3)
- **Q4.1** After user chooses branch A in HS2/HS3, is the other branch ever viewable? (a) Never — one-choice-locked, (b) Viewable on revisit, (c) Unlocked after completion.
- **Q4.2** Figure on HS trigger: (a) freeze at current position, (b) snap/animate to HS marker position? Snap feels more intentional.
- **Q4.3** Does this reader-mode fix apply to hotspot sequencing globally (all 155 events) or just the branching-HS events?

---

## 6. SPRINT 5 — End of Event + Badge

### Items
- **S5-1** Dhikr end screen redesign (see §9.2 for locked approach).
- **S5-2** Badge unlock screen is too plain. Options: (a) redesign current end-of-event badge reveal, (b) show badge as OVERLAY POPUP on return to tent, (c) both.
- **S5-3** Collections structure: keep as one collection screen, or split into two tabs — "Collections" (scrolls/manuscripts/dhikr) and "Badges"?

### Agent scope
- Rebuild dhikr screen layout per §9.2.
- Implement badge popup overlay (if chosen).
- Add Badges tab (if chosen) inside Collections screen.

### ⚠️ INPUTS NEEDED FROM KHALED (answer during Sprint 4)
- **Q5.1** Approve my dhikr redesign (§9.2), including AR+EN default with transliteration behind a toggle?
- **Q5.2** Badge presentation: (a) improve current end screen only, (b) overlay popup on tent only, (c) BOTH — end screen + tent popup?
- **Q5.3** Collections: (a) one flat screen with filters, (b) two tabs "Collections" + "Badges", (c) three tabs separating scrolls / dhikr / badges?

---

## 7. SPRINT 6 — Stars + Scroll

### Items
- **S6-1** From stars screen, tapping "Start" on a new event redirects back to tent instead of launching event. Should launch event directly, same as tent does.
- **S6-2** Stars screen missing side nav (events/stars/scroll/dhikr/collections) — should have parity with tent nav.
- **S6-3** Tapping an individual star → gray screen. Should show completed-event summary (same view as clicking a completed event from tent/events-list).
- **S6-4** Scroll layout — currently all arc notes render stacked vertically. Needs proper grouped layout. _See B9 from Batch 3B._

### Agent scope
- Fix stars-screen Start button to launch event directly (reuse tent launch logic).
- Add side nav to stars screen.
- Route star tap → completed-event summary screen.
- Scroll layout: separate design task — may need its own mini-spec after Khaled provides sketch or approves a proposal.

### ⚠️ INPUTS NEEDED FROM KHALED (answer during Sprint 5)
- **Q6.1** Does the stars screen need full side nav (all 5 buttons: Events, Stars-inactive, Scroll, Dhikr, Collections) or simplified (just Scroll + Dhikr + Collections)?
- **Q6.2** Scroll layout: will you sketch the intended layout, or should I propose 2–3 layout options with the visualizer?
- **Q6.3** For star tap → completed event view: is it the FULL replay (scene + hotspots + dhikr) or a READ-ONLY summary card?

---

## 8. SPRINT 7 — Global Polish

### Items
- **S7-1** Back button on tent no longer shows exit dialog — exits app directly. Restore dialog.
- **S7-2** Back arrow direction on events-list in AR mode points wrong way. Should mirror per RTL.

### Agent scope
- Restore `WillPopScope` on tent screen with `showDialog` confirm.
- Audit back arrows across all AR screens for RTL mirroring (check `Transform.flip` or `Directionality`-aware icon).

### ⚠️ INPUTS NEEDED FROM KHALED (answer during Sprint 6)
- **Q7.1** Exit dialog copy: keep existing ("Are you sure?"), or rewrite? Both AR + EN.
- **Q7.2** Is the back-arrow-direction issue only on events-list, or also on event scene, stars, scroll, collections, etc.? (I'll check all screens during Sprint 6 if unclear.)

---

## 9. LOCKED DESIGN DECISIONS FROM THIS ROUND

### 9.1 Event Scene Header (locked pending Q3.1)

**Three elements top bar only:** `[< back]  [Chapter pill]  [⚙ settings]`
**Title row below:** centered, event name as hero element, no surrounding box
**Top-left corner:** small Noor circle stack (icon + 0/4 dots beneath)
**Kill:** "Explore the scene" text (dots alone speak after Event 1)

Rationale: minimalism carries the mood. Reducing elements > reflowing them.

### 9.2 Dhikr End Screen (locked pending Q5.1)

**New order (top → bottom):**
1. `✨ EARN HASANAT` heading
2. Arabic dhikr (large, gold)
3. English meaning (italic)
4. ~~Transliteration~~ → behind a Settings toggle "Show pronunciation"
5. **Hold-and-recite button** (moved up — was at bottom)
6. [Say it · When · Promise] block — user reads these WHILE holding
7. Source citation
8. Button morphs Hold → Continue after completion OR Skip

**Reader mode:** replace Hold button with simple "Continue" tap — Hold gesture too heavy for skim users.

Rationale: recitation + meaning should settle together, not in separate steps.

---

## 10. DEPENDENCIES + ASSETS NEEDED

| Item | Asset | Who provides | When |
|------|-------|--------------|------|
| S1-6 Debug widget | None (code only) | Agent | Sprint 1 |
| S2-2 Dhikr counter | None (code only) | Agent | Sprint 2 |
| S3-4 Noor render | None (code only) | Agent | Sprint 3 |
| S5-2 Badge overlay | Maybe new badge reveal art | Khaled (TBD) | If chosen in Q5.2 |
| S6-4 Scroll layout | Possible sketch | Khaled | Before Sprint 6 |

---

## 11. DEFERRED FINDINGS (add here, don't expand sprints mid-flight)

_(Empty — populate as new issues surface during device testing.)_

---

## 12. QUESTION INTAKE SCHEDULE

| Session covers sprint | Claude asks Khaled questions for |
|------------------------|-----------------------------------|
| Session 1: Sprint 1 spec | — (no prior questions needed) + **Q2 block** at end |
| Session 2: Sprint 1 verify + Sprint 2 spec | — (Q2 already answered) + **Q3 block** at end |
| Session 3: Sprint 2 verify + Sprint 3 spec | **Q4 block** |
| Session 4: Sprint 3 verify + Sprint 4 spec | **Q5 block** |
| Session 5: Sprint 4 verify + Sprint 5 spec | **Q6 block** |
| Session 6: Sprint 5 verify + Sprint 6 spec | **Q7 block** |
| Session 7: Sprint 6 verify + Sprint 7 spec | — |
| Session 8: Sprint 7 verify | Close R25 |

**Pattern:** While agent executes sprint N, Khaled answers questions for sprint N+1 so it's ready when N completes.

---

## 13. ROUND COMPLETION CRITERIA

R25 is closed when:
- ✅ All 7 sprint rows in §1 marked ✅ with commit hashes + verify dates
- ✅ No items in §11 Deferred Findings (or all promoted to R26)
- ✅ Final `flutter analyze` clean
- ✅ Khaled signs off on full flow test (tent → event → dhikr → badge → back to tent) on A56

---

_Start date: Apr 19, 2026. Target close: within 4 weeks at 1 sprint/session._
_يلا نحلّها واحدة واحدة._
