# RAWI R25 — Progress Tracker

> **Persistent. One entry per sprint. Update after every handoff + device test.**
> Read this to evaluate R25 at round close. Canonical roadmap:
> `RAWI_R25_SPRINT_ROADMAP.md`. Per-sprint handoffs: `RAWI_R25_S{N}_HANDOFF.md`.

---

## Legend

- ✅ **Done** — shipped, verified on device, no outstanding work on the item
- 🟡 **Minor tweak needed** — works on device but has a small rough edge
- 🟠 **Missing element** — spec called for it, content/asset blocks full delivery
- ❌ **Regression / new bug** — surfaced during device test, not in original spec
- ⏳ **Awaiting next sprint** — intentional hand-off to a later sprint

Every entry that isn't ✅ must list: **what**, **why**, **owner**, **target sprint to resolve**.

---

## Sprint 1 — Tent → Event Navigation + Audio  ✅ CLOSED 2026-04-19

**Agent commits:** `4a9b639` (S1-5) · `247d8ce` (S1-6) · `bff1ea7` (S1-4) · `83719c6` (S1-1+S1-2) · `b2815b7` (S1-7) · `9b8d8a7` (S1-3 doc) · `2fee0d0` (handoff doc) · `bf337c2` (followup: missing-asset guard)
**Handoff:** `doc/RAWI_R25_S1_HANDOFF.md`
**Verify date:** 2026-04-19, Samsung A56, Khaled confirmed all 7 items pass.

### Items

| ID | Status | Notes |
|----|--------|-------|
| S1-1 Tent → event direct launch | ✅ | No events-list flash. Single `launchCurrentItem` path. |
| S1-2 Threshold accessible from tent | ✅ | Progress card shows "The Threshold" / "العتبة" when pending. |
| S1-3 Event 2 video no longer freezes | ✅ | Clean launch 5/5 after S1-1/S1-4. |
| S1-4 Audio lifecycle: no BG bleed | ✅ | `AudioService.stopAll()` awaited before video init. |
| S1-5 Rawi VO killed everywhere | ✅ | `kRawiFigureVoEnabled=false` gates the one call site. |
| S1-6 Debug reporter lifecycle hooks | ✅ | Nav observer + audio + video logs feeding existing panel. |
| S1-7 Event 2 watchdog + fallback | ✅ | 8s init, 6s stall, Try Again / Skip UI. |

### Minor tweaks

_None outstanding._ Followup commit `bf337c2` (guard missing audio assets) addressed D1–D4 log spam; the underlying log spam itself was the only minor rough edge and is now silenced.

### Missing elements

| Item | What | Why | Owner | Target |
|------|------|-----|-------|--------|
| 🟠 Tent fire ambient | `assets/audio/ambient/ambient_tent_fire.mp3` not in bundle | Code path ready (tent falls back to `ambient_intro.mp3` silently). Audio track pending Khaled. | Khaled | Any time — drop in, rebuild, it plays |
| 🟠 Event 1 SFX set | `sfx_kaabah_wind.wav`, `sfx_birds_swarm.wav`, `sfx_muttalib_silence.wav` | Hotspot SFX referenced in scene data. Skipped silently via guard. | Khaled | Before Sprint 3 device test (scene audio polish) |
| 🟠 Ambient SFX | `sfx_footsteps_sand.wav`, `sfx_elephants_rumble.wav` | Movement + Event 2 ambience. Skipped silently via guard. | Khaled | Before Sprint 4 (Reader Mode flow) so audio parity holds |

### Device-test findings (D1–D4)

Raised during Sprint 1 verification. All four were audio-log-spam symptoms of the missing assets above. Root cause resolved by followup `bf337c2` — each missing path now logs exactly once, then no-ops for the session.

### Regressions / new bugs

_None._

### Deferred to later sprints

- Content delivery of the 6 missing audio assets (see Missing Elements).
- All Sprint 2–7 scope remains untouched per spec's "one sprint per session" rule.

---

## Sprint 2 — Tent Screen Layout  🔲 NOT STARTED

**Agent commits:** —
**Handoff:** —
**Verify date:** —

### Items

| ID | Status | Notes |
|----|--------|-------|
| S2-1 Combine Light + Experience + Dhikr pills | 🔲 | — |
| S2-2 Dhikr counter restored as third pill | 🔲 | Resolved via S2-1 per Q2.1. |
| S2-3 Remove "Your Journey" ghost box | 🔲 | — |
| S2-4 Start/Continue on same line as #/155 | 🔲 | — |
| S2-5 Event title centered with more room | 🔲 | — |
| S2-6 Greeting "Assalamu Alaykom, {name}" | 🔲 | Q2.3 locked the name-inclusive variant. |
| S2-7 Text-size clamp on tent | 🔲 | Cap at 1.3× per Q2.2. |

### Minor tweaks / Missing elements / Regressions / Deferred

_Populate during and after Sprint 2 device test._

---

## Sprint 3 — Event Scene Header + Noor  🔲 NOT STARTED

**Agent commits:** —
**Handoff:** —
**Verify date:** —

### Items

| ID | Status | Notes |
|----|--------|-------|
| S3-1 Event scene top bar declutter | 🔲 | — |
| S3-2 Chapter pill non-button style | 🔲 | — |
| S3-3 Settings gear guideline styling | 🔲 | — |
| S3-4 Noor render on event scene | 🔲 | — |
| S3-5 "Knowledge" vs "Your Light" label bug | 🔲 | Reproduction steps pending Q3.3. |

### Q-block outstanding

- **Q3.1** Approve minimal header (§9.1) or keep side-column idea?
- **Q3.2** Drop "Explore the scene" entirely or keep only on Event 1?
- **Q3.3** Can Khaled reproduce the "Knowledge" label bug? Which mode toggle sequence?

_Populate remaining sections after Sprint 3 device test._

---

## Sprint 4 — Reader Mode Flow  🔲 NOT STARTED

**Agent commits:** —
**Handoff:** —
**Verify date:** —

### Items

| ID | Status | Notes |
|----|--------|-------|
| S4-1 Branching content before HS2/HS3 reveal | 🔲 | — |
| S4-2 Figure freeze/snap on HS trigger | 🔲 | — |

### Q-block outstanding

- **Q4.1** Is the other branch ever viewable after choice?
- **Q4.2** Freeze or snap to HS marker?
- **Q4.3** Global hotspot sequencing fix or branching-only?

---

## Sprint 5 — End of Event + Badge  🔲 NOT STARTED

**Agent commits:** —
**Handoff:** —
**Verify date:** —

### Items

| ID | Status | Notes |
|----|--------|-------|
| S5-1 Dhikr end screen redesign (§9.2) | 🔲 | — |
| S5-2 Badge unlock UX | 🔲 | Depends on Q5.2 — end screen vs tent popup vs both. |
| S5-3 Collections structure (one vs tabs) | 🔲 | Depends on Q5.3. |

### Q-block outstanding

- **Q5.1** Approve dhikr redesign + transliteration-behind-toggle?
- **Q5.2** Badge presentation variant?
- **Q5.3** Collections flat / tabs / three-tab split?

---

## Sprint 6 — Stars + Scroll  🔲 NOT STARTED

**Agent commits:** —
**Handoff:** —
**Verify date:** —

### Items

| ID | Status | Notes |
|----|--------|-------|
| S6-1 Stars Start launches event directly | 🔲 | Reuse `launchCurrentItem` from Sprint 1. |
| S6-2 Side nav on stars screen | 🔲 | — |
| S6-3 Star tap → completed-event summary | 🔲 | Depends on Q6.3 — full replay or read-only. |
| S6-4 Scroll layout redesign | 🔲 | Partial from Batch 3B B9. |

### Q-block outstanding

- **Q6.1** Full side nav or simplified?
- **Q6.2** Khaled's sketch for scroll layout or Claude proposes?
- **Q6.3** Star tap → full replay or read-only summary?

---

## Sprint 7 — Global Polish  🔲 NOT STARTED

**Agent commits:** —
**Handoff:** —
**Verify date:** —

### Items

| ID | Status | Notes |
|----|--------|-------|
| S7-1 Tent back exit dialog restored | 🔲 | — |
| S7-2 AR back-arrow RTL mirroring | 🔲 | — |

### Q-block outstanding

- **Q7.1** Exit dialog copy — keep or rewrite (AR + EN)?
- **Q7.2** Back-arrow issue scope (events-list only or everywhere)?

---

## Cross-cutting concerns (evaluate at round close)

### Content assets still missing at R25 close

_Populated live as each sprint's device test surfaces more. Final list
feeds the content-delivery checklist before launch._

- `assets/audio/ambient/ambient_tent_fire.mp3` (Sprint 1 — tent ambient)
- `assets/audio/sfx_kaabah_wind.wav` (Sprint 1 — hotspot SFX)
- `assets/audio/sfx_birds_swarm.wav` (Sprint 1 — hotspot SFX)
- `assets/audio/sfx_muttalib_silence.wav` (Sprint 1 — hotspot SFX)
- `assets/audio/sfx_footsteps_sand.wav` (Sprint 1 — movement SFX)
- `assets/audio/sfx_elephants_rumble.wav` (Sprint 1 — Event 2 ambience)

### Locked design decisions referenced by multiple sprints

See `RAWI_R25_SPRINT_ROADMAP.md` §9:

- §9.1 Event Scene Header (Sprint 3 implements, Sprint 6 reuses on Stars)
- §9.2 Dhikr End Screen (Sprint 5 implements, Sprint 4 Reader Mode
  references for Hold→Continue substitution)

### Round completion criteria (from roadmap §13)

- [ ] All 7 sprint rows ✅ with commit hashes + verify dates
- [ ] No items in §11 Deferred Findings (or promoted to R26)
- [ ] Final `flutter analyze` clean
- [ ] Khaled signs off on full flow test (tent → event → dhikr → badge → tent) on A56

---

_Tracker v1 — created 2026-04-19, Sprint 1 close._
_Update at the end of every sprint handoff, before the next sprint begins._
