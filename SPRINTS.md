# Rawi — Sprint Index

> 39 sprints across 3 days (April 1–3, 2026)
> Next: Sprint 40 (Reward System Rebalance)

---

## Day 1 — April 1, 2026 (Sprints 1–10)
**Focus:** MVP gaming shell + core gameplay

| # | Sprint | Key Deliverable |
|---|--------|----------------|
| 1 | Splash + Intro Cinematic | `splash_screen.dart`, `intro_cinematic_screen.dart`, PrefsService keys |
| 2 | Registration Flow | 4-step PageView (name, gender, language, milestones), delete `welcome_screen.dart` |
| 3 | Settings (Overlay + Screen) | In-game pause overlay, hub settings page, AudioService respects prefs |
| 4 | Image-Based Companion | Rewrite `companion_figure.dart` — ClipOval + JPG, gender-aware |
| 5 | Hotspot System Overhaul | Diamond shape, progressive reveal, green tick after dismiss, all centered cards |
| 6 | Scene Polish + Silver Path | Stars/moon off E1, silver path color, figure visibility, progress overlap fix |
| 7 | Cinematic Transitions | Fade-to-black + title card (year, location, event title) |
| 8 | Event 2 Bubbles + Event 3 | Wire E2 images, build E3 full scene config + 4 SFX WAVs |
| 9 | Companion Speech Bubbles | 7 trigger categories, ~25 EN + 25 AR lines, idle timer, revisit limiter |
| 10 | Partial RTL | TextDirection.rtl on hub, progress, companion, era complete, settings |

---

## Day 2 — April 2, 2026 (Sprints 11–33)
**Focus:** TTS, bug fixing, branching system, badges, UI polish

| # | Sprint | Key Deliverable |
|---|--------|----------------|
| 11 | Edge TTS Voice Over | 100 MP3s generated (48 fragment + 24 choice + 52 companion), 3-layer audio |
| 12 | R1 Critical Fixes | Figure freeze (game loop), auto-move (repeat+reset), VO leak (lifecycle) |
| 13 | Hotspot Visibility | All hotspots visible, locked state (dimmed 60%, lock icon) |
| 14 | Visual + Audio Fixes | Gender images, Syrian Arabic VO, companion VO wiring, text placement, image crop, full fragments |
| 15 | Hub Redesign | `event_list_screen.dart` replaces parallax hub, streamlined post-event flow |
| 16 | Gameplay Tutorial | 2-step overlay (joystick + hotspots), first event only, `tutorialSeen` pref |
| 17 | Post-Event Flow | Complete on choice answer, save hotspot progress on back, skip cinematic for flat events |
| 18 | Animations + Visibility | Particle alpha boost (all 3 events), locked hotspot opacity increase |
| 19 | Event List Polish | Hotspot counters, gold Play button, proximity 0.07→0.09, exit confirmation |
| 20 | Reflection Enhancement | Choice phase VO (24 MP3s), choice tutorial, "What would you do?" text |
| 21 | Branching: Data Models | `BranchPoint`, `BranchOption`, optional fields on JourneyEvent + SceneConfig, 5 safety tests |
| 22 | Branching: Card + Controller | `BranchDecisionCard`, scene controller branching logic, path swap, unlock order |
| 23 | Branching: Wire Events | All 3 events wired (branch prompts, alt paths, convergence fragments, 12 branch VO) |
| 24 | Branching: In-Scene Verdict | `convergenceQuestion` phase, question in-scene card, remove Moment of Reflection |
| 25 | Go Deeper + Polish | `GoDeeperSection` collapsible widget, transition screen chapter label, language fix |
| 26 | Round 3 Fixes | Completion race fix, hotspot remap (forward-only triangle), branch VO, onboarding back, transition particles, keyboard |
| 27 | UI Fixes | Cinematic chapter preview, locked hotspot dark backing, Verdict gold styling, remove Crossroads tutorial |
| 28 | Badge Model | `BadgeDefinition`, `BadgeTrigger`, 7 badges, `PrefsService.checkAndAwardBadges()` |
| 29 | XP Animation | `XpRewardAnimation` — star pop, count-up tween, particle burst, total XP line |
| 30 | Badge Overlay + Wiring | `BadgeOverlay` widget, writes in `_selectChoice`, sequential badge → XP → Continue |
| 31 | Badges on Profile | Badges grid on settings — earned (gold emoji + name) / unearned (🔒 + ???) |
| 32 | Hotspot Visibility+ | Dark backing all states, gold outline ring, stronger glow |
| 33 | Badge Overlay Redesign | Full-screen 85%, Completer pattern, sequential flow (badge → XP → Continue strict) |

---

## Day 3 — April 3, 2026 (Sprints 34–39)
**Focus:** Audit fixes, chronological accuracy, bilingual, accessibility

| # | Sprint | Key Deliverable |
|---|--------|----------------|
| 34 | Audit Fixes | Release signing config, remove latlong2, delete dead code, FootprintPainter perf, language persist, streak edge case |
| 35 | Chronological Reorder | Black Stone (605 CE) → position 8 Early Life, Ta'if (619 CE) → position 17 after Year of Grief |
| 36 | Critical Flow Fixes | VO stop before pop, badge/XP after Continue tap, era auto-collapse, Skip button fix |
| 37 | Path + Visual Fixes | Curved paths (no dead zones), route line visibility boost, mute button consistency, splash navy theme |
| 38 | RawiDialog + Bilingual | Reusable gold/navy dialog, intro cinematic device locale, mandatory name 2-15 chars |
| 39 | Personalization + A11y | Name in companion bubbles, "Rawi since" date, text scale Small/Normal/Large |

---

## Planned

| # | Sprint | Scope |
|---|--------|-------|
| 40 | Reward System Rebalance | Rebalanced 7 badges, 4 chapter completion screens, layered flow (chapter → badge → XP) |
| 41+ | Per RAWI_ISSUES_AND_ENHANCEMENTS_3.md | Settings overhaul, badge artwork, expanded content |

---

## Stats

| Metric | Value |
|--------|-------|
| Total sprints | 39 |
| Total days | 3 |
| Bugs fixed | 40+ across 3 testing rounds |
| Dart files | 41 |
| Dart lines | ~11,500 |
| Audio files | 150+ (84 VO + 52 companion + 14 SFX) |
| Git commits | 15+ |
| Tests | 5 branching safety tests (all passing) |
