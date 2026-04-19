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

## Sprint 2 — Tent Screen Layout  🟡 DEVICE TEST IN PROGRESS

**Agent commits:** `189038e` (S2-1+S2-2) · `1720998` (S2-3) · `f9f4c31` (S2-4+S2-5) · `079ef4e` (S2-6) · `631af4b` (S2-7) · `ee2f6ad` (S2-8) · `b452ccc` (S2-1 followup: visibility fix)
**Handoff:** `doc/RAWI_R25_S2_HANDOFF.md`
**Verify date:** Apr 19 2026 — device test found S2-1 invisibility, followup shipped. Re-verification pending.
**APK SHA256 (post-fix):** `5f4995e7caa8118038423ec87e6cc1bdce4c64179f7bcddf406a13c9ff08065f` (91.8 MB) — supersedes the original `b6404443…` build.
**APK SHA256:** `b6404443e8775a3f775aa93818375bfa368fa4cb7c6bc091ab75b28b753e505f` (91.8 MB)
**Net LoC:** +126 / −159 (−33 net)

### Items

| ID | Status | Notes |
|----|--------|-------|
| S2-1 Combine Light + Experience + Dhikr pills | ✅ | Single container, backdrop blur, 3 rows + 2 gold dividers. Positioned `top: screenH*0.44, left: 10`. Reader mode swaps Light→Knowledge, XP→Events per B11. |
| S2-2 Dhikr counter restored as third pill | ✅ | Reads `PrefsService.dhikrCompletedCount` (lifetime counter — same source Settings uses). |
| S2-3 Remove "Your Journey" ghost box + label | ✅ | Ghost box was the floating "Your Journey" label above the card, not a structural wrapper duplication. Label Positioned block deleted. |
| S2-4 Start/Continue on same line as `#/155` | ✅ | Row `spaceBetween`, `Padding(horizontal: 4)` off card edges. Button ~intrinsic width with 32h / 9v padding, count uses 11px muted gold. No `x/4`, no walking emoji. |
| S2-5 Event title centered with more room | ✅ | `TextAlign.center`, 13/14px, w500, `#E8D8B8`, 12px bottom padding. |
| S2-6 Greeting "Assalamu Alaykom, {name}" | ✅ | Time-of-day ladder removed. Grep of old greeting strings returns zero hits. Empty-name falls back to bare salaam. |
| S2-7 Text-size clamp on tent | ✅ | Root `MediaQuery.textScalerOf().clamp(1.0, 1.3)`. Nav label fontSize 7 → 9 (renders 9–11.7px with the clamp). |
| S2-8 Drop per-event hotspot dots | ✅ | Dots + `_buildProgressDots` method + `hasScene`/`hotspotCount` locals all deleted. Chapter dots at list top untouched. |

### Minor tweaks

_None outstanding from agent's side._ Khaled's device test may surface layout or position micro-tweaks; log them here after verification.

### Missing elements

_None._ Dhikr counter picked up an existing lifetime source; no new content required for this sprint.

### Device-test findings

**Apr 19 2026, 13:04 on A56 (tent_day.jpg, Explorer mode, user "KD"):**

| ID | Item | Finding | Resolution |
|----|------|---------|------------|
| S2-1-v1 | Stat pills container | Invisible on device — `top: 0.44` landed on the hooded figure's robed body; 0.55-alpha pill had no contrast against dark reddish-brown robe. | Followup `b452ccc`: moved to `top: 0.22` (sunrise sky, below greeting, above figure). Bumped bg to 0.72 alpha + border to 0.32 alpha + width 0.8 for general robustness across all four time-of-day scenes. Re-verify on device. |

All other S2 items (S2-3 through S2-8) appear correct in the screenshot:
- S2-6 greeting "Assalamu Alaykom, KD" + "The Explorer" subtitle rendering correctly inline.
- S2-3 "Your Journey" label absent.
- S2-4 + S2-5 progress card: title centered ("The Birth of the Prophet ﷺ"), [Start] button on left, "2 / 155" count on right, thin progress bar below.
- S2-8 events-list not yet opened on device — pending check.
- Debug overlay FAB visible at bottom-left (60 entries) — S1-6 working as designed.

### Regressions / new bugs

_None detected in agent-side static verification._

### Deferred to later sprints

- **Daily vs lifetime dhikr counter** (spec §7) — if Khaled wants daily, becomes a deferred finding.
- **Project-wide TextScaler clamp** (current scope is tent only) — would need a separate mini-sprint if non-tent screens also break at large font sizes.
- **Stat pill tap animations** (pulse on update) — spec §7 punted them.

---

## Sprint 3 — Event Scene Header + Noor  🟡 HOTFIX SHIPPED, AWAITING RE-VERIFY

**Sprint commits:** `7ca99a8` (S3-1) · `da66766` (S3-2+S3-3) · `60680dc` (S3-4) · `8aa122c` (S3-5) · `b369567` (S3-6+S3-8) · `3f1c6eb` (S3-7)
**Hotfix commits (9, Apr 19 evening):** `4bdc690` (H1) · `f74147b` (H2) · `7e5b9a6` (H3) · `9b907e4` (H4) · `c5e33db` (H5) · `fa909d2` (H6) · `0738e7c` (H7) · `bf65e75` (H8) · `cc72007` (H9)
**Handoffs:** `doc/RAWI_R25_S3_HANDOFF.md` + `doc/RAWI_R25_S3_HF_HANDOFF.md`
**Verify date:** Apr 19 2026 — sprint landed with 10 open items, hotfix addresses 9 (1 item stays with Khaled for device testing). Re-verification pending.
**APK SHA256 (post-hotfix):** `9b280f681ed612fe5f2bb52c54258d789750375646f69ac42c1de74e34d295d9` (91.9 MB) — supersedes the original `2b225040…` sprint build.
**Net LoC (sprint + hotfix):** +1000 / −320 approximate.

### Items

| ID | Status | Notes |
|----|--------|-------|
| S3-1 Event scene top bar declutter | ✅ | 3-element top bar: `[back] [chapter pill] [⚙]`. Title moved to bottom (hero, no box). Scene dots moved above title. Scaler clamp 1.0–1.3 at scene root. HotspotProgress widget stripped of "Explore the scene" text — dots only. |
| S3-2 Chapter pill non-button style | ✅ | Plain `Container` with backdrop blur. No Button/InkWell/GestureDetector. Radius 10, 0.55 bg, 0.18 border, 11px w500 gold at 0.85 alpha. |
| S3-3 Settings gear guideline styling | ✅ | New shared `TopBarIconButton` widget used by both back + gear. 36×36 circular, 0.18 gold border, 18px gold icon, InkWell ripple clipped to circle, light haptic. |
| S3-4 Noor render on event scene | ✅ | Data-flow audit: tent + scene read same `PrefsService.noorLevel`; writes already clamp [0, 100]. Old `_NoorHud` removed in S3-1 (replaced by info tab). `setNoorLevel` now logs every write to `DebugLogService` under 'noor' for future trace. No 155-event field audit needed. |
| S3-5 "Knowledge" vs "Your Light" label | ✅ | Root cause: `rawi_tent_screen.dart:479` Reader-mode conditional. Consolidated to "Your Light" / "نورك" in both modes. XP→Events value swap kept (B11). No findings note needed. |
| S3-6 Expandable info tab widget | ✅ | `EventSceneInfoTab` at top:40%, left:0. Collapsed = 32px with `ⓘ` + chevron. Expanded = 180px with YOUR LIGHT (lifetime) + faint divider + THIS EVENT (4-dot). 200ms slide animation. Scrim dims scene. |
| S3-7 Event 1 tutorial rewrite | ✅ | `Event1TutorialOverlay` — single full-screen scrim with 3 labelled callouts (dots, info tab, hotspots) + "Got it" / "فهمت" dismiss. Locked copy §9.4. SharedPref `tutorial_event1_shown`. QA reset button in Settings → About under `kDebugMode`. |
| S3-8 StatRowGroup shared widget | ✅ | New `lib/widgets/stat_row_group.dart`. Tent 3-pill container refactored to consume it (supersedes S2-1 invisibility fix from commit `b452ccc`). Info tab Section 1 also consumes it with `showDividers: false`. |

### Q-block — ✅ ANSWERED Apr 19, 2026 (roadmap_2)

- **Q3.1** → Approved minimal header + expandable left-tab info widget. ✅ shipped.
- **Q3.2** → Dropped "Explore the scene" from all events. Event 1 tutorial rewritten. ✅ shipped.
- **Q3.3** → "Knowledge" bug root-cause identified and fixed inside timebox. ✅ shipped.

### Minor tweaks

_None outstanding from agent side._ Info-tab Section 1 sizing is worth eyeballing — spec §9.3 hints at "big 72%" hero-style value but spec §S3-8 required StatRowGroup consumption (11px value). If Khaled feels the value is too small once expanded, a 1-line fontSize bump or a StatRowGroup variant parameter can address it.

### Missing elements

_None._ All four new widgets + Noor instrumentation + pref keys shipped.

### Device-test findings

**Apr 19 2026 evening, A56 — Sprint 3 sprint-build (`2b225040…`):**

10 open items flagged. Hotfix `bc2be05..cc72007` ships fixes for 9:

| Item | Finding on device | Hotfix resolution |
|------|-------------------|-------------------|
| Tent pills still invisible (H1) | 3-pill container not painting on tent; info tab rendered OK. | `4bdc690` — explicit `SizedBox(width: 155)` unblocks the Spacer inside StatRowGroup's rows. One-line geometry fix. |
| Double "Your Light" in info tab (H2) | Section 1 showed uppercase header AND row label → two "Your Light" strings. Value sat far right. | `f74147b` — section redesigned as vertical stack (title, subtitle, 18px value). Section 2 matches. Chevron moved to right mid-border. |
| Title at scene bottom crowded (H3) | Title collided with scene dots, joystick, speech bubbles, Android nav. | `7e5b9a6` — title moved back to top-bar center pill with chapter as subtitle. Bottom title block removed. |
| "Collectio" truncated on right nav (H4) | Labels don't fit at 52×52 button + text-scaler range. | `9b907e4` — right nav is icon-only; buttons shrink 52→44. Label surfaces via Tooltip on long-press. |
| Lowercase name in greeting (H5) | `Assalamu Alaykom, khaled`. | `c5e33db` — capitalize write-side (setUserName) + display-side safety net for existing users. |
| Missing figure halo (H6) | Info tab read Noor correctly; figure aura didn't scale with Noor %. | `fa909d2` — halo alpha + spreadRadius now keyed to `noorLevel/100`. At 100% identical to pre-hotfix; at 0% collapses to border only. |
| "Knowledge" label still reproduces (H7) | Reported by Khaled after mode toggle cycles. | `0738e7c` — grep verified zero UI render sites emit "Knowledge" post-`8aa122c`. Likely stale install when reported. Comment updated; added note that any future appearance is a NEW bug path. |
| Two tutorial systems firing (H8) | Old TutorialOverlay rendered alongside new Event1TutorialOverlay. | `bf65e75` — legacy retired (import removed, trigger nulled, seen-flag auto-written). Event1TutorialOverlay rebuilt as sequential 3 steps with the legacy's elegant centered style. |
| AR strings on info tab (H9) | Strings were already bilingual; RTL layout risk from Positioned-absolute parent chain. | `cc72007` — explicit Directionality wrapper guarantees AR layout semantics. |

**Deferred to Khaled device retest (not in hotfix scope):**
- S3-4 Noor render on "Abd al-Muttalib" / "Khadijah" events — `60680dc` added `setNoorLevel` DebugLog trace; next device run should capture any remaining discrepancy with numerical evidence.
- 1.3× text scaler on event scene — Android accessibility max test.

### Regressions / new bugs

None introduced by the hotfix batch. The 9 commits are either surgical
fixes, targeted refactors, or documented revisions of prior Sprint 3
intent.

### Deferred to later sprints

- **155-event Noor JSON audit** (roadmap §6) — deferred to a content pass if the debug trace reveals field-gaps on specific events.
- **Info-tab hero-style Section 1 sizing** — retired by H2 redesign (now the 18px hero value IS the section value). ✅ addressed.
- **Rank-label string update** (Q3.7 — `الرحالة الصغير` / `الرحالة الشاب` / `الرحال الحكيم`) — roadmap says "one-off string update commit before Sprint 5". NOT in Sprint 3 scope. Separate commit when Khaled signals.
- **Delete `lib/widgets/tutorial_overlay.dart`** — left in place per H8 spec. Once Khaled confirms the new tutorial on device, clean-up commit can remove the retired file.
- **H8 Step 3 "amplified hotspot pulse"** — overlay renders its own pulsing demo disc instead of boosting the real HS1's pulse. If device test calls for the real one, wire via a ValueNotifier in a follow-up commit.

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

### Deferred findings (mirrored from roadmap §11)

| ID | Severity | What | Disposition |
|----|----------|------|-------------|
| D1 | 🔴 | Missing `ambient_tent_fire.mp3` (maps to B13). Short-term: guard (shipped in `bf337c2`). Long-term: asset delivery. | Content delivery |
| D2 | 🟠 | Missing SFX set: `sfx_kaabah_wind/birds_swarm/muttalib_silence/footsteps_sand/elephants_rumble`. Guarded (Sprint 1 followup). Dedicated sound-asset sprint TBD. | Content delivery |
| D3 | 🟡 | "Healed stale pending discoveries" log fired on Event 2. B1 safety net working as intended. Monitor frequency. | Observe |
| D4 | 🟢 | Mixed `PageRouteBuilder` + `MaterialPageRoute` usage. Tech debt; single-commit cleanup eventually. | Tech debt |

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
