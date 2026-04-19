# RAWI R25 — Sprint Roadmap (Apr 19 Device Testing)

> **Persistent document. Updated each session. Read this first before working on any R25 item.**
> Parent round: R24 (Batch 3) — see `RAWI_R24_BATCH3_SPEC_COMPLETE.md`
> Source: Khaled's Apr 19 midnight device testing session, 28 screenshots
> **Last updated:** Apr 19, 2026 morning — Sprint 2 spec written, Sprint 3 inputs locked

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
| 2 | Tent Screen Layout | 🟡 Device test found S2-1 invisibility — followup shipped, re-verify pending | `b452ccc` (tip, visibility fix) | — |
| 3 | Event Scene Header + Noor | 🔲 Inputs locked, ready when S2 closes | — | — |
| 4 | Reader Mode Flow | 🔲 Not started | — | — |
| 5 | End of Event + Badge | 🔲 Not started | — | — |
| 6 | Stars + Scroll | 🔲 Not started | — | — |
| 7 | Global Polish | 🔲 Not started | — | — |

Legend: 🔲 Not started · 🟡 In progress · 🟢 Agent done, awaiting device · ✅ Verified

---

## 2. SPRINT 1 — Tent → Event Navigation + Audio (🔴 P0)

**Hypothesis:** Tent launches an event without cleanly tearing down the events-list screen. This single root cause likely explains the flash, the audio bleed, the frozen video, and the Threshold-redirect error.

### Items
- **S1-1** Tent → event: events-list screen visible for milliseconds before event loads ✅
- **S1-2** Tent → Threshold/non-event items → redirects to events list ✅
- **S1-3** Event 2 (Year of the Elephant) video freezes on first scene ✅
- **S1-4** Event 2 audio bleed — events-list BG continues over video ✅
- **S1-5** Rawi figure VO still active on event scenes ✅
- **S1-6** Debug reporter did NOT capture the Event 2 freeze ✅
- **S1-7** Event 2 video graceful timeout + recovery ✅

### ✅ INPUTS — ANSWERED Apr 19, 2026
- **Q1.1** → Tent progress card cycles through all item types. Start button routes directly. No events-list interstitial.
- **Q1.2** → Rawi figure VO off EVERYWHERE. Gate behind `kRawiFigureVoEnabled = false` const.
- **Q1.3** → Root cause fix. Fallback UI = "Replay / Skip" after 8s watchdog.

---

## 3. SPRINT 2 — Tent Screen Layout

**Spec:** `RAWI_R25_S2_SPEC.md` (handed to agent Apr 19, 2026 morning session)

### Items
- **S2-1** Combine Light + Experience + Dhikr counter into ONE left-side container
- **S2-2** Dhikr counter restored as the third pill (resolved by S2-1)
- **S2-3** "Your Journey" ghost box removed
- **S2-4** Start/Continue button inline with `#/155`, padded off card edges
- **S2-5** Event title centered with breathing room
- **S2-6** Greeting unified: `Assalamu Alaykom, {name}` / `السلام عليكم، {name}`
- **S2-7** `TextScaler.clamp(1.0, 1.3)` at tent root + nav label min-size floor
- **S2-8** Drop per-event hotspot dots and `x/4` from events-list rows (absorbed mid-session)

### ✅ INPUTS — ANSWERED Apr 19, 2026
- **Q2.1** → Three stat pills in shared left-side container
- **Q2.2** → Text size max cap: 1.3×
- **Q2.3** → Greeting: `Assalamu Alaykom, {name}` / `السلام عليكم، {name}`
- **Q2.4** → Progress-card button: `Start` / `Continue` label only. No `x/4` badge, no number pill
- **Q2.5** → Button + count row: both padded ~4px off card edges, 14px gap between, button fills more width
- **Q2.6** → Drop per-event hotspot progress (dots + `x/4`) from events-list rows too

---

## 4. SPRINT 3 — Event Scene Header + Noor

### Items
- **S3-1** Event scene top bar cluttered: simplify to 3 elements
- **S3-2** Chapter pill currently looks like a tappable button (misleading) — non-button pill style
- **S3-3** Settings gear styling doesn't match guideline
- **S3-4** Noor (light) does NOT render on event scene for some events
- **S3-5** "Knowledge" label appears instead of "Your Light" after mode switches
- **S3-6** Replace old Noor indicator with expandable left-tab info widget _(new — from this session)_
- **S3-7** Event 1 tutorial rewrite — cover scene-dots meaning + info-tab icon _(new — absorbs dropped "Explore the scene" copy)_

### Agent scope
- Redesign event scene header per §9.1 below
- Remove "Explore the scene" text from ALL events (tutorial rewrite covers intro)
- Audit Noor rendering logic: is noor% read from same source on tent and scene? Scene reading stale/default?
- **S3-5 investigation:** grep `"Knowledge"` / `"Your Light"` / `"المعرفة"` / `"نورك"` across codebase. Based on Khaled's hypothesis, focus on reader ↔ explorer mode toggle code paths. If repro path identified, fix and verify. If still elusive after ~30min investigation, report back to Khaled with code pointers for a follow-up device test.
- Build expandable info-tab widget per §9.3 below
- Rewrite tutorial copy for Event 1 per §9.4 below

### ✅ INPUTS — ANSWERED Apr 19, 2026
- **Q3.1** → Approve minimal header (§9.1). PLUS: Noor indicator becomes expandable left-tab widget (§9.3) — collapsed = neutral info icon; expanded = two-section panel showing lifetime Your Light + this-event progress.
- **Q3.2** → Drop "Explore the scene" text from ALL events. Rewrite Event 1 tutorial to cover the dots + the new info-tab icon instead.
- **Q3.3** → S3-5 "Knowledge" label bug — no hard repro. Agent investigates reader ↔ explorer toggle path first. If stuck, defer to next device test.

---

## 5. SPRINT 4 — Reader Mode Flow

### Items
- **S4-1** After HS1 completes, both HS2 AND HS3 appear simultaneously before branching content
- **S4-2** Figure moves slower than finger/toggle — snap or freeze on HS trigger

### Agent scope
- Rework hotspot reveal sequencing in reader mode
- Figure movement: freeze or snap on HS trigger (per Q4.2)

### ⚠️ INPUTS NEEDED FROM KHALED (answer during Sprint 3)
- **Q4.1** After user chooses branch A in HS2/HS3, is the other branch ever viewable? (a) Never, (b) On revisit, (c) After completion.
- **Q4.2** Figure on HS trigger: (a) freeze at current position, (b) snap/animate to HS marker. Snap feels more intentional.
- **Q4.3** Does reader-mode fix apply globally (all 155) or just branching-HS events?

---

## 6. SPRINT 5 — End of Event + Badge

### Items
- **S5-1** Dhikr end screen redesign (see §9.2 for locked approach)
- **S5-2** Badge unlock screen: end screen, tent overlay popup, or both?
- **S5-3** Collections: one screen, or split into "Collections" + "Badges" tabs?

### Agent scope
- Rebuild dhikr screen layout per §9.2
- Implement badge popup overlay (if chosen)
- Add Badges tab inside Collections (if chosen)

### ⚠️ INPUTS NEEDED FROM KHALED (answer during Sprint 4)
- **Q5.1** Approve dhikr redesign (§9.2), including AR+EN default with transliteration behind toggle?
- **Q5.2** Badge presentation: (a) end screen only, (b) overlay popup on tent only, (c) both.

---

## 7. SPRINT 6 — Stars + Scroll

### Items
- **S6-1** Stars screen Start button redirects to tent instead of launching event
- **S6-2** Stars screen missing side nav
- **S6-3** Tapping individual star → gray screen. Should show completed-event summary
- **S6-4** Scroll layout — arc notes stacked, needs grouped layout

### Agent scope
- Fix stars Start button (reuse tent launch logic)
- Add side nav to stars screen
- Route star tap → completed-event summary
- Scroll layout: separate mini-spec after Khaled provides sketch or approves options

### ⚠️ INPUTS NEEDED FROM KHALED (answer during Sprint 5)
- **Q6.1** Stars-screen nav: full 5-button, or simplified (Scroll + Dhikr + Collections)?
- **Q6.2** Scroll layout: will you sketch, or want me to propose 2-3 options via visualizer?
- **Q6.3** Star tap → FULL replay or READ-ONLY summary card?

---

## 8. SPRINT 7 — Global Polish

### Items
- **S7-1** Back button on tent no longer shows exit dialog — restore
- **S7-2** Back arrow direction on events-list in AR mode — RTL mirror

### Agent scope
- Restore `WillPopScope` on tent with `showDialog` confirm
- Audit back arrows across AR screens for RTL mirroring

### ⚠️ INPUTS NEEDED FROM KHALED (answer during Sprint 6)
- **Q7.1** Exit dialog copy: keep existing or rewrite? Both AR + EN.
- **Q7.2** Back-arrow direction issue: only on events-list, or other screens too?

---

## 9. LOCKED DESIGN DECISIONS FROM THIS ROUND

### 9.1 Event Scene Header ✅ LOCKED Apr 19, 2026

**Three elements top bar only:** `[< back]  [Chapter pill]  [⚙ settings]`
**Title row at bottom:** centered, event name as hero, no surrounding box
**Left edge (mid-height):** expandable info-tab widget (see §9.3)
**Kill:** "Explore the scene" text everywhere

Rationale: minimalism carries the mood. Reducing elements > reflowing them.

### 9.2 Dhikr End Screen (locked pending Q5.1)

**New order (top → bottom):**
1. `✨ EARN HASANAT` heading
2. Arabic dhikr (large, gold)
3. English meaning (italic)
4. ~~Transliteration~~ → behind a Settings toggle "Show pronunciation"
5. **Hold-and-recite button** (moved up)
6. [Say it · When · Promise] block — user reads WHILE holding
7. Source citation
8. Button morphs Hold → Continue after completion OR Skip

**Reader mode:** replace Hold with simple "Continue" tap.

### 9.3 Event-Scene Info Tab Widget ✅ LOCKED Apr 19, 2026

Replaces the current Noor indicator on event scenes.

**Collapsed state:**
- Positioned `Positioned(top: ~40%, left: 0)` on the scene Stack
- Background: `rgba(10, 14, 24, 0.72)` with `BackdropFilter` blur
- Border: `0.5px solid rgba(212, 168, 67, 0.22)`, no left border
- Corner radius: `BorderRadius.only(topRight: 12, bottomRight: 12)`
- Padding: 9px vertical, 11px right / 9px left
- Content: **info icon** (`ⓘ` — circle with inner "i" glyph, NOT the Noor sun icon) + small rightward chevron
- Icon color: `#d4a843`, 14×14
- No number, no label, no percentage — collapsed shows nothing but the hint

**Expanded state (tap the collapsed tab):**
- Slides out to ~180px wide
- Scene behind dims with `rgba(0, 0, 0, 0.3)` overlay
- Same pill styling, heavier opacity (`rgba(10, 14, 24, 0.88)`), border alpha up to 0.28
- Two clearly separated sections with a faint divider between them:

  **Section 1 — YOUR LIGHT (lifetime, matches tent)**
  - Small Noor icon (the sun glyph — SAME as tent's stat pill for consistency)
  - Label: `YOUR LIGHT` / `نورك` — 10px, `rgba(212, 168, 67, 0.75)`, letter-spaced
  - Value: big `72%` — 18px, `#e8d8b8`, `FontWeight.w500`
  - Subtitle: `across all events` / `عبر كل الأحداث` — 9px, `rgba(212, 168, 67, 0.4)`

  **Section 2 — THIS EVENT (event-scoped progress)**
  - Small check-in-circle icon
  - Label: `THIS EVENT` / `هذا الحدث` — 10px, `rgba(212, 168, 67, 0.75)`, letter-spaced
  - Visual: 4 small dots (8×8), filled gold for completed hotspots, outlined for remaining
  - Subtitle: `3 of 4 moments` / `٣ من ٤ لحظات` — 9px, `rgba(212, 168, 67, 0.55)`

- Collapse chevron (leftward) at top-right corner of expanded panel
- Tap outside or tap chevron to collapse

**Interaction:**
- Tap collapsed tab → smooth slide-out animation (~200ms ease-out)
- Tap chevron / tap overlay → slide back in
- Pop animation on state change, not a jarring toggle

**Why info icon, not Noor glyph:**
Using the Noor icon on the collapsed tab would imply the tab = Noor meter, but the tab actually reveals BOTH Noor AND event progress. Neutral info icon removes ambiguity. Noor icon appears inside, next to its specific section.

### 9.4 Event 1 Tutorial Copy ✅ LOCKED Apr 19, 2026

Replaces the old "Explore the scene" text globally with a one-time tutorial on first event launch.

**Trigger:** First time user enters Event 1 scene, after intro video.
**Format:** overlay tooltips on the 2-3 elements being introduced.
**Elements to introduce:**
1. Scene dots at bottom (scene progression within the event)
2. Info tab on left edge (lifetime light + event progress)
3. (Optional) Rawi figure + hotspot markers

**Copy (EN):**
- Scene dots: `"These dots show your progress through this event's moments."`
- Info tab: `"Tap here anytime to see your light and this event's progress."`
- (Optional) Hotspots: `"Move closer to a glowing spot to witness its story."`

**Copy (AR):**
- Scene dots: `"هذه النقاط تُظهر تقدمك في لحظات هذا الحدث."`
- Info tab: `"اضغط هنا في أي وقت لرؤية نورك وتقدمك في هذا الحدث."`
- Hotspots: `"اقترب من نقطة متوهجة لتشهد قصتها."`

**Dismissal:** "Got it" / "فهمت" button. Never shown again after dismissal.

---

## 10. DEPENDENCIES + ASSETS NEEDED

| Item | Asset | Who provides | When |
|------|-------|--------------|------|
| S1-6 Debug widget | None (code only) | Agent | Sprint 1 ✅ |
| S2-2 Dhikr counter | None (code only) | Agent | Sprint 2 |
| S3-4 Noor render | None (code only) | Agent | Sprint 3 |
| S3-6 Info tab | None (code only) | Agent | Sprint 3 |
| S3-7 Tutorial | Copy locked in §9.4 | — | Sprint 3 |
| S5-2 Badge overlay | Maybe new badge reveal art | Khaled (TBD) | If chosen in Q5.2 |
| S6-4 Scroll layout | Possible sketch | Khaled | Before Sprint 6 |

---

## 11. DEFERRED FINDINGS

### From Sprint 1 device testing (Apr 19, 2026)

**D1 — Missing audio asset: `ambient_tent_fire.mp3`** 🔴
- Maps to B13 from Batch 3B. Short-term: guard. Long-term: generate/provide asset.

**D2 — Missing event SFX assets** 🟠
- `sfx_kaabah_wind.wav`, `sfx_birds_swarm.wav`, `sfx_muttalib_silence.wav`, `sfx_footsteps_sand.wav`, `sfx_elephants_rumble.wav`
- Part of 620-prompt backlog. Guard short-term. Dedicated sound-asset sprint long-term.

**D3 — "Healed stale pending discoveries" on Event 2 [elephants]** 🟡
- B1 safety net fired. NOT a bug. Monitor frequency.

**D4 — Mixed `PageRouteBuilder` + `MaterialPageRoute` usage** 🟢
- Tech debt. Single-commit cleanup eventually.

---

## 12. QUESTION INTAKE SCHEDULE

| Session | Claude asks Khaled questions for |
|---------|-----------------------------------|
| Session 1: Sprint 1 spec | **Q2 block** at end ✅ |
| Session 2: S1 verify + S2 spec | **Q3 block** at end ✅ (this session) |
| Session 3: S2 verify + S3 spec | **Q4 block** |
| Session 4: S3 verify + S4 spec | **Q5 block** |
| Session 5: S4 verify + S5 spec | **Q6 block** |
| Session 6: S5 verify + S6 spec | **Q7 block** |
| Session 7: S6 verify + S7 spec | — |
| Session 8: S7 verify | Close R25 |

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
