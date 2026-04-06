# Rawi — Sprint Index

> 52 sprints + post-audit across 6 days (April 1–6, 2026)
> All sprints complete. R4–R9 testing rounds fixed (70+ items). MVP Events 1-2 flawless.

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

## Day 3 — April 3, 2026 (Sprints 34–41 + Post-Audit)
**Focus:** Audit fixes, chronological accuracy, bilingual, accessibility, reward rebalance, character identity

| # | Sprint | Key Deliverable |
|---|--------|----------------|
| 34 | Audit Fixes | Release signing config, remove latlong2, delete dead code, FootprintPainter perf, language persist, streak edge case |
| 35 | Chronological Reorder | Black Stone (605 CE) → position 8 Early Life, Ta'if (619 CE) → position 17 after Year of Grief |
| 36 | Critical Flow Fixes | VO stop before pop, badge/XP after Continue tap, era auto-collapse, Skip button fix |
| 37 | Path + Visual Fixes | Curved paths (no dead zones), route line visibility boost, mute button consistency, splash navy theme |
| 38 | RawiDialog + Bilingual | Reusable gold/navy dialog, intro cinematic device locale, mandatory name 2-15 chars |
| 39 | Personalization + A11y | Name in companion bubbles, "Rawi since" date, text scale Small/Normal/Large |
| 40 | Reward System Rebalance | Rebalanced 7 badges, chapter completion screens, layered flow (chapter → badge → XP → auto-pop) |
| 41 | Bug Fixes A12-A17 + Character Identity | Exit/save/idle overlap/font/splash fixes, Rawi/Rawiah labels, pose infra, registration text |
| — | Post-Audit | Master Plan table fix, Android 12+ splash, doc cleanup (removed duplicate issue files) |

---

## Day 4 — April 4, 2026 (Sprint 42)
**Focus:** R4 testing fixes, ambient sound infrastructure, movement system overhaul

| # | Sprint | Key Deliverable |
|---|--------|----------------|
| 42 | R4 Issues + Ambient Sound Design | Font pre-cache, bilingual intro, auto-walk, movement freeze, route painter rewrite, settings overlay redesign, per-hotspot ambient system, onboarding music, XP/chapter overlay z-order |

---

## Day 5 — April 5, 2026 (Sprints 43–48)
**Focus:** R5/R6 testing rounds — registration redesign, settings reorder, sound integration, audio isolation, freeze fix

| # | Sprint | Key Deliverable |
|---|--------|----------------|
| 43 | R5 Sprint A+B | 11 fixes: app icon, Arabic italic, Hindi numerals, typo, narrator line, transition particles, scroll indicator, XP overlay sizes, event card overflow, badge persistence, 0/0 display |
| 44 | R5 Sprint C+D | Registration 2-screen redesign (Identity + Language, blurred bg, kill chapter preview). Settings reorder (Profile → Journey → Preferences → About → Reset, badges removed). Reset Journey full sweep. Badge geometric placeholder. |
| 45 | R5 Code Review | **Arabic italic ROOT CAUSE**: Lora has no Arabic glyphs, fallback inherited italic. Conditional `isAr` on 14 instances. Transition particle gate fix. XP sizes bump. Scroll indicator bigger. Adaptive icon XML. |
| 46 | Sound Integration | 8 ElevenLabs clips wired: intro + transition + crossroads ambients, 3 Event 1 hotspot ambients via `ambientPath`, XP + badge SFX one-shots. |
| 47 | Audio Isolation | Strict window containment across 10+ exit points. Short fades (200-500ms) replace hard stops. No bleeds between screens/hotspots/overlays. Race-safe via player identity check. |
| 48 | R6 Testing | P0 freeze fix (pushReplacement), icon refinement, duplicate CTA, ambient race, keyboard |

---

## Day 6 — April 6, 2026 (Sprints 49–52)
**Focus:** Cinematic continuity, completion flow, video integration, final polish

| # | Sprint | Key Deliverable |
|---|--------|----------------|
| 49 | R7 Cinematic Continuity | Continuous `ambient_intro.mp3` splash→events list. Events list desert BG. Registration crossfade. `flutter_launcher_icons`. **LOCKED RULE: no hard audio cuts.** Global audio audit. |
| 50 | R8 Completion Flow + Event List | `pushAndRemoveUntil(EventListScreen)` on complete. Active card gold glow, 10px progress dots, lock hint text, chapter teasers, motivational bottom text. |
| 51 | Video Integration | `video_player` package. `VideoIntroScreen` — full-screen with blurred BG extension. Event 2 cinematic intro (18MB MP4). First-play only. |
| 52 | R9 Final Polish | Splash cinematic BG. Reset clears onboarding. Overlay 92%. Ambient 800ms delay. Tutorial gold glow. Scroll indicator clickable. Video blur BG. Settings tagline. |

---

## Planned

| # | Sprint | Scope |
|---|--------|-------|
| 53+ | Content writing | Events 3-36 data + scene configs. One event per day. Follow RAWI_ROAD_TO_LAUNCH.md. |
| — | Pending Khaled | Remaining 7 ambient clips, Jordanian VO regen, badge painterly artwork |
| — | Post-Launch | Young Rawi Mode (age-adaptive content — see `doc/RAWI_YOUNG_RAWI_MODE.md`) |

---

## Stats

| Metric | Value |
|--------|-------|
| Total sprints | 52 + post-audit |
| Total days | 6 |
| Bugs fixed | 120+ across 9 testing rounds + audit |
| Dart files | 44 |
| Dart lines | ~12,250 |
| Audio files | 159 (84 VO + 52 companion + 14 SFX + 8 ambient + 1 video) |
| Video files | 1 (event2_intro.mp4, 18MB) |
| Git commits | 55 |
| Tests | 6 (5 branching + 1 smoke, all passing) |
