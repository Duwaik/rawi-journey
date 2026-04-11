# Rawi — Architecture Document

> Last updated: 2026-04-10
> Package: `com.rawi.journey`
> Flutter 3.41.4 | Dart 3.11.1+

---

## Master List (Single Source of Truth)

The canonical 155-event sequence lives in
[`doc/RAWI_155_MASTER_LIST.md`](doc/RAWI_155_MASTER_LIST.md).
All event ordering, titles, and honorifics (e.g., "الزواج من خديجة
رضي الله عنها", "إسلام حمزة رضي الله عنه", "إسلام عمر رضي الله عنه",
"وفاة خديجة رضي الله عنها", "استشهاد حمزة رضي الله عنه") are locked
in the master list. No other doc overrides it.

**Module structure (155 events, 4 modules):**

| Module | Title | Events | Range |
|--------|-------|--------|-------|
| M1 | The Prophetic Dawn | 47 | 1–47 |
| M2 | The Community Rises | 35 | 48–82 |
| M3 | The Turning Tide | 38 | 83–120 |
| M4 | The Final Chapter | 35 | 121–155 |

**Chapter Review breakpoints (5 reviews):**

| Review | After Event | Meaning |
|--------|-------------|---------|
| 1 | #14 | Pre-prophethood complete — TRIGGERS NOW |
| 2 | #47 | M1 complete (Meccan period done) |
| 3 | #82 | M2 complete (Early Medina done) |
| 4 | #120 | M3 complete (Conquest done) |
| 5 | #155 | M4 complete (Entire Seerah done) |

**Blocked events:** 18 events pending Khaled's verification before
content writing — see [`doc/RAWI_BLOCKED_EVENTS.md`](doc/RAWI_BLOCKED_EVENTS.md).

---

## Project Stats

| Metric | Count |
|--------|-------|
| Dart files | 78 |
| Dart lines | ~17,700 |
| Asset files | 119 (52 companion + 14 SFX + 8 ElevenLabs ambient/SFX + 16 scenes + 4 figures + 1 icon + 1 video + others) |
| Playable immersive events | 152 (Events 1-36, 38-44, 47-155 with scene configs) |
| Content-ready events | 152 (1-36, 38-44, 47-155 — generated from Khaled's content packs) |
| Total events in scope | 155 across 4 modules (M1:47, M2:35, M3:38, M4:35) |
| Dhikr cards | 147 (Sahih Bukhari/Muslim/Abu Dawud sourced) |
| Scroll entries | 151 |
| Engagement features | 8 built (Fog, Proximity, Haptics, Secrets, Evolution, Reactions, Scroll, Living Map) |
| Total events in data | 155 (3 stubs at 37/45/46 awaiting Khaled content) |
| Era distribution | Jahiliyyah 2, Early Life 13, Mecca 32, Medina 108 |
| Blocked events | 15 implemented (review-flagged), 3 stubs pending content |
| Generator script | tools/generate_events.py — parses Downloads .md, splices into 4 dart files |
| Git commits | 80+ |

---

## Event Terminology

```
The Gate       → First mandatory hotspot (sets the scene)
The Crossroads → Two-option choice card after The Gate
The Paths      → The two middle hotspots (visited in chosen order)
The Gathering  → Final hotspot where all paths meet
The Verdict    → Final question ("What does history remember?")
The Reflection → Old linear end-of-event question ("What would you do?")

Full branching flow: The Gate → The Crossroads → The Paths → The Gathering → The Verdict
Full linear flow:   Hotspot 1 → 2 → 3 → 4 → The Reflection
```

---

## File Tree

```
d:\Rawi_Journey\
├── lib\
│   ├── main.dart                              # App entry, theme, splash routing
│   ├── app_colors.dart                        # Design system colors
│   ├── transitions.dart                       # Page transition helpers
│   │
│   ├── models\
│   │   ├── journey_event.dart                 # JourneyEvent, JourneyQuestion, JourneyEra
│   │   │                                        + branching fields (anchorHotspotId, 
│   │   │                                          branchPoint, convergenceHotspotId)
│   │   ├── scene_config.dart                  # SceneConfig, SceneHotspot, ParticleType
│   │   │                                        + pathWaypointsAlt, deeperContent, ambientPath
│   │   ├── branch_point.dart                  # BranchPoint, BranchOption (The Crossroads)
│   │   ├── badge_definition.dart              # BadgeDefinition, BadgeTrigger — rebalanced 7 badges
│   │   ├── dhikr_card.dart                    # DhikrCard model (arabic, transliteration, source)
│   │   ├── scroll_entry.dart                  # ScrollEntry model for Rawi's Scroll
│   │   ├── scene_secret.dart                  # SceneSecret model for hidden elements
│   │   └── rawi_stage.dart                    # RawiStage enum — 5 evolution stages
│   │                                            (Seeker@5, Witness@11, Keeper@15, Steadfast@22,
│   │                                             Scholar@30, Guardian@36, Rawi@36)
│   │
│   ├── data\
│   │   ├── m1_data.dart                       # 40 events (Milestone 1) with branching
│   │   │                                        data for Events 1-2 + 12 (Black Stone)
│   │   ├── scene_configs.dart                 # 14 scene configs (E1-8 + Black Stone + E13-14
│   │   │                                        + placeholders) with alt paths, hotspot positions,
│   │   │                                        sky gradients, particles
│   │   └── rawi_dialogue.dart                 # Speech bubble dialogue bank (7 triggers,
│   │                                            EN+AR, ~25 lines each)
│   │
│   ├── services\
│   │   ├── audio_service.dart                 # 3-layer audio: ambient (L1), VO (L2), SFX (L3)
│   │   │                                        + ducking, fadeOut, fadeAmbientTo, pref checks
│   │   └── prefs_service.dart                 # SharedPreferences: language, gender, name,
│   │                                            XP, streak, completion, hotspot progress,
│   │                                            audio toggles, onboarding, tutorial flags
│   │
│   ├── screens\
│   │   ├── splash_screen.dart                 # Logo splash (2s first, 1s returning)
│   │   ├── intro_cinematic_screen.dart        # First-launch story intro (5 text lines)
│   │   ├── registration_screen.dart           # 4-step onboarding: name → gender → language
│   │   │                                        → cinematic chapter preview
│   │   ├── event_list_screen.dart             # Timeline journey view — chapter headers,
│   │   │                                        gold timeline thread, progress dots, Play CTA
│   │   ├── event_intro_screen.dart            # Fade-to-black + title card + particles +
│   │   │                                        sky gradient + ambient fade-in
│   │   ├── video_intro_screen.dart             # Full-screen cinematic video intro (video_player)
│   │   ├── immersive_event_screen.dart        # THE CORE:
│   │   │   ├── Joystick-driven exploration
│   │   │   ├── Branching: Gate → Crossroads → Paths → Gathering → Verdict
│   │   │   ├── Linear: sequential hotspots → Reflection
│   │   │   ├── Hotspot panels with VO + Go Deeper
│   │   │   ├── Rawi speech bubbles (idle, nudge, revisit)
│   │   │   ├── Fog of War overlay + proximity detection
│   │   │   ├── Settings overlay (pause)
│   │   │   ├── Tutorial overlay (first event)
│   │   │   ├── PopScope: save progress on back, block during Verdict
│   │   │   └── Completion: await writes → manual Continue → pop(true)
│   │   ├── legacy_event_screen.dart           # Flat narrative fallback (legacy events)
│   │   ├── dhikr_screen.dart                  # Full-screen cinematic dhikr after XP
│   │   ├── scroll_writing_screen.dart         # Rawi's Scroll — writing animation
│   │   ├── scroll_viewer_screen.dart          # Rawi's Scroll — 14-entry viewer
│   │   ├── living_map_screen.dart             # Interactive map — zoom/pan, 17 locations,
│   │   │                                        route lines, 4 marker states, bottom sheet
│   │   ├── settings_screen.dart               # Full settings page (5 cinematic cards)
│   │   ├── era_complete_screen.dart           # Era celebration (used by flat events)
│   │   └── xp_reward_animation.dart            # XP count-up + star pop + particle burst
│   │
│   └── widgets\
│       ├── settings_overlay.dart              # In-game pause overlay
│       ├── tutorial_overlay.dart              # First-event tutorial (joystick + hotspots)
│       ├── fog_overlay.dart                   # Fog of War — CustomPainter revealing explored areas
│       └── cinematic\
│           ├── crossroads_card.dart           # The Crossroads — gold-pulsing choice card
│           ├── hotspot_panel.dart             # Hotspot fragment card + image + Go Deeper + 
│           │                                    VO replay button
│           ├── go_deeper_section.dart         # Collapsible scholarly content section
│           ├── rawi_figure.dart               # Rawi/Rawiah avatar (gender-based, stage-aware)
│           ├── rawi_speech_bubble.dart        # Gold pill above Rawi/Rawiah
│           ├── scene_hotspot_marker.dart      # Diamond marker: active/locked/discovered +
│           │                                    dark backing for locked
│           ├── parallax_scene.dart            # Parallax layer viewer
│           ├── path_route_painter.dart        # Silver walking route visualization
│           ├── virtual_joystick.dart          # On-screen joystick control
│           ├── particle_painter.dart          # Floating particles (smoke, dust)
│           ├── birds_overlay.dart             # Bird swarm animation (Event 2)
│           ├── sky_gradient.dart              # Full-screen sky gradient
│           ├── starfield_layer.dart           # Twinkling stars
│           ├── crescent_moon.dart             # Moon with glow
│           ├── grain_overlay.dart             # Film grain noise
│           ├── fly_transition.dart            # Zoom+fade transition
│           ├── discovery_progress.dart        # "Explore · X/4" progress dots
│           └── scroll_hint_wrapper.dart      # Scroll hint indicators
│
│   ├── rawi_dialog.dart                       # Reusable gold/navy dialog (replaces AlertDialog)
│   └── character_art.dart                     # Stage-aware Rawi character rendering (5 stages)
│
├── assets\
│   ├── audio\                                 # 14 WAV (13 SFX + 1 footsteps)
│   ├── audio\vo\                              # 84 MP3 (48 hotspot + 24 choice + 12 branch)
│   ├── audio\companion\                       # 52 MP3 (13 lines x 4 variants)
│   ├── audio\ambient\                         # Per-hotspot atmospheric beds + onboarding music (ElevenLabs)
│   ├── video\                                 # Cinematic event intros (Runway-generated MP4s)
│   ├── scenes\                                # 16 JPG (3 scene + 12 bubble + 1 welcome)
│   ├── figures\                               # 4 JPG (male/female x onboarding/inscene)
│   └── icon\                                  # 1 JPG (app icon)
│
├── test\
│   ├── widget_test.dart                       # Smoke test
│   └── branching_test.dart                    # 5 tests: linear fallback safety net
│
├── tools\
│   └── generate_vo.py                         # Edge TTS batch generator (Syrian AR + British EN)
│
├── doc\
│   ├── rawijourney_session_roadmap.md         # Product strategy + roadmap
│   ├── rawijourney_visual_prompts_600.md      # 12 Bing prompts for hotspot images
│   ├── rawijourney_events_list_redesign_1.md  # Timeline list spec
│   ├── rawijourney_ui_fixes.md                # UI fixes spec
│   └── rawijourney_critical_flow_fix.md       # Completion flow fix spec
│
├── RAWI_MASTER_PLAN.md                        # Full project vision (155 events, 4 volumes)
├── MVP_PLAN.md                                # MVP execution plan
├── V06_PLAN.md                                # v0.6 detailed spec (original)
├── SPRINT_LOG.md                              # All 63 sprint execution details
├── FIXES_LOG.md                               # Round 1-2 bug tracker
├── FIXES_LOG_R3.md                            # Round 3 bug tracker
└── ARCHITECTURE.md                            # This file
```

---

## Navigation Flow

```
App Launch
  │
  ├── First time: Splash (2s) → Intro Cinematic → Registration (4 steps) → Event List
  │
  └── Returning: Splash (1s) → Event List
  
Event List
  │
  ├── Tap Play (immersive event):
  │     If video intro exists (first play only) → VideoIntroScreen → pushReplacement → Immersive
  │     Otherwise → Cinematic Transition → pushReplacement → Immersive Event Screen
  │     │
  │     ├── Branching (Events 1-3):
  │     │     Gate → Crossroads → Paths → Gathering → Verdict → Continue → pop(true)
  │     │
  │     └── Linear (Events 4-36 future):
  │           Hotspot 1 → 2 → 3 → 4 → Reflection → Continue → pop(true)
  │     
  ├── Tap Play (flat event) → Journey Event Screen → pop
  │
  ├── ⚙️ Settings → Settings Screen → pop → refresh
  │
  └── Back → "Exit game?" dialog
  
In-Game (Immersive)
  │
  ├── ⚙️ → Settings Overlay (pause) → Resume / Save & Exit
  │
  ├── Back → Save hotspot progress → pop
  │     (blocked during unanswered Verdict)
  │
  └── App backgrounded → stop all audio, reset game loop
```

---

## Data Flow

```
┌──────────────────┐
│   m1_data.dart   │  36 JourneyEvent objects
│   (1637 lines)   │  Events 1-3 have BranchPoint + anchor/convergence IDs
└────────┬─────────┘
         │
┌────────▼─────────┐
│ scene_configs.dart│  3 SceneConfig objects (Events 1-3)
│   (323 lines)    │  Hotspots, waypoints (+ alt paths), sky, particles, SFX
└────────┬─────────┘
         │
┌────────▼──────────────────────────────────────────┐
│          immersive_event_screen.dart               │
│              (1551 lines)                          │
│                                                    │
│  State machine:                                    │
│    explore → [convergenceQuestion | choose]         │
│    → complete                                      │
│                                                    │
│  Branching engine:                                 │
│    _isBranching? → anchor check → Crossroads card  │
│    → path swap → unlock order → Gathering → Verdict│
│                                                    │
│  Completion:                                       │
│    _selectChoice → phase=complete                  │
│    → user taps Continue Journey                    │
│    → await completeEvent()                         │
│    → await clearHotspotProgress()                  │
│    → Navigator.pop(context, true)                  │
│    → event list rebuilds with fresh prefs          │
└───────────────────────────────────────────────────┘
```

---

## Audio Architecture

```
Layer 1 — Ambient (RE-ENABLED — contextual, strict window containment)
  8 ElevenLabs clips integrated as of Sprint 46. Every ambient lives
  strictly inside its window with short fades (200-500ms) preventing
  bleeds between screens, hotspots, and overlays.

  - Intro ambient (ambient_intro.mp3): plays during intro cinematic +
    registration, fades out 2.5s on "Start the Journey". First launch only.
  - Transition ambient (ambient_transition.mp3): plays on
    CinematicTransitionScreen, fades out on dispose.
  - Crossroads ambient (ambient_crossroads.mp3): plays while branch
    decision card is shown, fades out on option selected.
  - Hotspot ambient: each SceneHotspot has optional ambientPath.
    Plays while discovery panel is open (0.18 vol), fades on dismiss
    (200ms — fast enough to avoid race with next hotspot).
  - Ducks to 0.06 during VO, restores to 0.18 when VO completes.

  Exit points sealed: scene dispose, PopScope back press, header back
  (_exitScene), _saveAndExit, _continue, _completeAndPop, _dismissPanel,
  _onBranchSelected, CinematicTransition.dispose. _resumeFromSettings
  restarts whichever ambient was playing when settings opened.

  Race-safe: fadeOut's internal `if (_ambient != player) return;` guard
  exits cleanly if a new playAmbient replaces it mid-fade.

  CRITICAL: playAmbient must be awaited BEFORE fadeAmbientTo (Sprint 48
  R6-04 fix). Otherwise the fade starts while setAsset is still loading
  and the ambient never plays.

Layer 2 — Voice Over (one-shot)
  Volume: 0.6-0.7
  Respects: PrefsService.voEnabled
  Triggers: hotspot panel (400ms), Crossroads (600ms), Verdict (600ms/500ms)
  Stops: immediate on panel dismiss, option select, settings, app background
  Replay: speaker button on discovery panel + Verdict card

Layer 3 — SFX (one-shot)
  Volume: 0.4-0.5
  Respects: PrefsService.sfxEnabled
  Triggers: hotspot discovery, companion bubbles
  
VO Rules:
  1. STOP previous before starting new
  2. Never overlap with visuals
  3. Companion bubbles use SFX layer (short, no duck)
  4. All VO has replay button
```

---

## PrefsService Keys

| Key | Type | Default | Purpose |
|-----|------|---------|---------|
| `user_language` | String | 'en' | EN/AR toggle |
| `user_name` | String | '' | Player name (optional) |
| `user_gender` | String | 'male' | Companion + VO voice selection |
| `onboarding_complete` | bool | false | Skip onboarding on return |
| `tutorial_seen` | bool | false | First-event tutorial |
| `music_enabled` | bool | true | Ambient audio toggle |
| `vo_enabled` | bool | true | Voice over toggle |
| `sfx_enabled` | bool | true | Sound effects toggle |
| `user_xp` | int | 0 | Total XP earned |
| `user_streak` | int | 1 | Consecutive days |
| `journey_current_order` | int | 1 | Next event to complete |
| `journey_completed_prefix_N` | bool | false | Per-event completion flag |
| `hotspot_progress_EVENT_ID` | StringList | [] | Saved discovered hotspot IDs |
| `earned_badges` | StringList | [] | Badge IDs the user has earned |

---

## Planned Extension Points

### Young Rawi Mode (Post-Launch)
Age-adaptive content — same game, different reading level. Three groups:
Young Rawi (8-12), Rawi (13-17), Elder Rawi (18+).

**Model changes when implementing:**
- `SceneHotspot`: add `fragmentSimple`, `fragmentSimpleAr` (optional)
- `JourneyQuestion`: add `questionSimple`, `questionSimpleAr`, `explanationSimple`, `explanationSimpleAr` (optional)
- `PrefsService`: add `userAgeGroup` ('young'/'teen'/'adult'), `useSimpleContent` getter
- Registration: add age number input after name field

**Rendering:** `useSimpleContent ? (simple ?? full) : full` — fallback ensures
events without simplified content still work. Go Deeper: hidden (young),
collapsed (teen, current), auto-expanded (adult).

**Full spec:** `RAWI_YOUNG_RAWI_MODE.md`

---

### Hasanat System (LIVE — Sprint 59)
Dual reward track: XP (game progress) + Hasanat (spiritual dhikr).
Flow: Verdict → XP overlay → Dhikr screen → Event List.

**Built:**
- `DhikrCard` model (`dhikr_card.dart`): arabic, transliteration, meaning, whenToSay, source
- 14 dhikr cards — all sourced from Sahih Bukhari/Muslim only, no invented numbers
- `dhikr_screen.dart`: full-screen cinematic UI (navy gradient, gold card, promise section, source citation)
- Honor-based design: "I've said it" / "Not now" — no enforcement
- `hasanatTotal` counter in PrefsService, displayed on profile and event list header
- Layer 2 (post-launch): "Dhikr Garden" screen, morning/evening detection

---

### Engagement System (LIVE — Sprint 62)
8 features built in Phase 1, 3 architected for Phase 2.

**Phase 1 — Built:**
| Feature | Implementation |
|---------|---------------|
| 1. Fog of War | `fog_overlay.dart` — CustomPainter revealing explored areas around companion |
| 2. Hotspot Proximity | 3-zone detection (far, near, arrived) with visual/audio feedback |
| 3. Haptic Feedback | 9 haptic moments: discovery, verdict, badge, XP, scroll, secret, etc. |
| 4. Hidden Scene Elements | `SceneSecret` model, secrets placed in Events 1-2, discoverable off-path |
| 5. Scene Evolution | Sky gradient, particles, and ambient evolve as hotspots are discovered |
| 6. Rawi Reactions | Bounce animations on companion for key moments |
| 7. Rawi's Scroll | 14 entries, writing animation (`scroll_writing_screen.dart`), viewer (`scroll_viewer_screen.dart`) |
| 8. Rawi Evolution | 5 stages (`rawi_stage.dart`), `CharacterArt` renders stage-appropriate companion |

**Phase 2 — Architecture Only:**
- Feature 10: Rawi's Tent (hub for collected items)
- Feature 11: Companion's Voice (dynamic dialogue system)
- Feature 12: Little Rawi Mode (age-adaptive content)

---

### Living Map (LIVE — Sprint 63)
Interactive map accessible from event list header icon.

**Built:**
- `living_map_screen.dart`: `InteractiveViewer` with zoom/pan
- 17 locations mapped to all 40 M1 events
- Route lines connecting sequential event locations
- 4 marker states: locked, available, active, completed
- Bottom sheet: event list filtered by selected location
- Promoted from Phase 2 to Phase 1 during Sprint 63

### Analytics & Crash Reporting (Pre-Launch — required)
Firebase Crashlytics + Analytics. Offline-first (queue + send).
No personal data. Anonymous device IDs only.

**Implementation when ready:**
- `firebase_core`, `firebase_crashlytics`, `firebase_analytics` packages
- Crash wrapper in `main.dart` (FlutterError.onError + PlatformDispatcher)
- Custom crash keys: event ID, screen name, language, XP
- 40+ custom analytics events across onboarding, gameplay, rewards, settings
- ~4 sprints total

**Full spec:** `doc/RAWI_ANALYTICS_ARCHITECTURE.md`

---

## Branching System Safety

Events 4-36 have `branchPoint == null`. The `_isBranching` guard in
`immersive_event_screen.dart` ensures ALL branching logic is skipped
for linear events. Verified by 5 unit tests in `branching_test.dart`.

**Chronological reorder (Sprint 35):** Black Stone (605 CE) moved from
Jahiliyyah position 3 to Early Life position 8. Ta'if (619 CE) moved
to position 17 (after Year of Grief). Event order in m1_data now
follows strict chronological sequence.

**155-event restructure (Sprint 54):** Expanded from 36 to 155-event
structure across 4 modules (M1: 47, M2: 35, M3: 38, M4: 35). M1 currently
has 39 events in code. GlobalOrders renumbered to match canonical sequence
in `doc/RAWI_UPDATED_EVENT_SEQUENCE.md`.

**Event ID convention (LOCKED):**
- Existing events keep legacy IDs: `j_1_1_1`, `j_1_2_3`, etc.
- New events use module-based IDs: `j_m1_005`, `j_m1_006`, `j_m1_007`
- NEVER overwrite an existing ID with different content — add a new ID instead
- Full ID renumbering deferred until all 47 M1 events are written
- Canonical sequence: `doc/RAWI_UPDATED_EVENT_SEQUENCE.md`

---

## Sprint History

| Sprints | Focus |
|---------|-------|
| 1-4 | Gaming shell (splash, registration, settings, companion) |
| 5-11 | MVP gameplay (hotspots, polish, transitions, Event 3, speech, RTL, TTS) |
| 12-16 | Round 1 fixes (15 bugs) |
| 17-20 | Round 2 fixes (10 bugs) |
| 21-24 | Branching system (Gate → Crossroads → Paths → Gathering → Verdict) |
| 25 | Go Deeper + transition polish + language fix |
| 26 | Round 3 fixes (6 bugs) |
| 27 | UI fixes, VO timing, event list redesign, critical flow fix, collapsible eras |
| 28 | Badge data model + definitions (7 badges) |
| 29 | XP count-up animation (star pop, particle burst, total line) |
| 30 | Badge overlay + completion flow wiring |
| 31 | Badges on settings/profile screen |
| 32 | Hotspot visibility enhancement |
| 33 | Badge overlay redesign (full-screen 85%, sequential completion flow) |
| 34 | Audit fixes (signing config, latlong2 removed, dead code, perf, persistence) |
| 35 | Chronological reorder (Black Stone → pos 8, Ta'if → pos 17) |
| 36 | Critical flow fixes (VO stop, badge/XP after Continue, era collapse, Skip) |
| 37 | Path + visual fixes (curved paths, route visibility, mute, splash navy) |
| 38 | RawiDialog + bilingual intro + mandatory name |
| 39 | Name personalization + accessibility (text scale Small/Normal/Large) |
| 40 | Reward system rebalance (7 badges, chapter screens, layered flow) |
| 41 | Bug fixes A12-A17 + Rawi/Rawiah character identity |
| — | Post-audit: Master Plan fix, Android 12+ splash, doc cleanup |
| 42 | R4 issues (12 fixes) + ambient sound infrastructure + movement overhaul |
| 43 | R5 Sprint A+B (11 fixes: icon, Arabic italic, Hindi numerals, XP sizes, scroll indicator) |
| 44 | R5 Sprint C+D (registration 2-screen redesign, settings reorder, reset sweep, badge placeholder) |
| 45 | R5 Code Review (Arabic italic root cause fix, transition particles, adaptive icon) |
| 46 | Sound integration (8 ElevenLabs clips: ambients + SFX wired) |
| 47 | Audio isolation (strict window containment, short fades, no bleeds) |
| 48 | R6 testing (P0 freeze fix via pushReplacement, icon refinement, duplicate CTA, ambient race) |
| 49 | R7 cinematic continuity (continuous ambient, events list BG, crossfade, flutter_launcher_icons, LOCKED fade rule) |
| 50 | R8 completion flow (pushAndRemoveUntil, event list layout: gold glow, dots, teasers, lock hints) |
| 51 | Video integration (video_player, Event 2 cinematic intro, blurred BG extension) |
| 52 | R9 final polish (splash BG, reset onboarding, overlay, scroll clickable, tutorial glow, video blur) |
| 53 | R10-R12 fixes + Events 3-4 (DYK feature, source refs, direct questions, auto-move failsafe) |
| 54 | **155-event restructure** + Events 5-8 (new ID convention j_m1_NNN, 39 events, 9 playable) |
| 55 | Content review: Event 11 question fix (4→3 options), Event 12 full rewrite from spec (all DYK, sources, fragments) |
| 56 | R13 action plan: Event 13 scene config, 6 DYK, AR rewrites, prefix removal, narrative clearing |
| 57 | R14+R15 device testing: 15 fixes (paths, verdict UI, VO cleanup, DYK audit, hotspot order, progress, auto-collapse) |
| 58 | Terminology rename: 7 file renames, phase enum merge, comment cleanup |
| 59 | **Hasanat system**: DhikrCard model, 13 dhikr cards, cinematic dhikr screen, flow integration, profile counter |
| 60 | Event 14 (First Revelation): scene config Pattern B, 4 hotspots, Witness Moment, new dhikr card (Muslim 2726). 11 playable. |
| 61 | R16 device testing: 7 fixes (RTL Directionality, unskippable videos, dhikr UI, back progress re-fix, settings redesign, instant lang switch) |
| 62 | **Engagement architecture**: 8 features built (Fog, Proximity, Haptics, Secrets, Evolution, Reactions, Scroll 14 entries, Rawi Evolution 5 stages) |
| 63 | **Living Map**: InteractiveViewer, 17 locations, route lines, 4 marker states, bottom sheet. Promoted from Phase 2. |
