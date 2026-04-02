# Rawi — Architecture Document

> Last updated: 2026-04-02
> Package: `com.rawi.journey`
> Flutter 3.41.4 | Dart 3.11.1+

---

## Project Stats

| Metric | Count |
|--------|-------|
| Dart files | 41 |
| Dart lines | ~11,000 |
| Asset files | 193 (84 VO + 52 companion + 14 SFX + 16 scenes + 4 figures + 1 icon + others) |
| Playable immersive events | 3 (branching) |
| Flat narrative events | 33 (linear, Events 4-36) |
| Total events in data | 36 |
| Git commits | 6 |

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
│   │   │                                        + pathWaypointsAlt, deeperContent fields
│   │   ├── branch_point.dart                  # BranchPoint, BranchOption (The Crossroads)
│   │   └── badge_definition.dart              # BadgeDefinition, BadgeTrigger (Sprint 28)
│   │
│   ├── data\
│   │   ├── m1_data.dart                       # 36 events (Milestone 1) with branching
│   │   │                                        data for Events 1-3
│   │   ├── scene_configs.dart                 # 3 scene configs (E1-E3) with alt paths,
│   │   │                                        hotspot positions, sky gradients, particles
│   │   └── companion_dialogue.dart            # Speech bubble dialogue bank (7 triggers,
│   │                                            EN+AR, ~25 lines each)
│   │
│   ├── services\
│   │   ├── audio_service.dart                 # 3-layer audio: ambient (L1), VO (L2), SFX (L3)
│   │   │                                        + ducking, fadeOut, pref checks
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
│   │   ├── cinematic_transition_screen.dart   # Fade-to-black + title card + particles +
│   │   │                                        sky gradient + ambient fade-in
│   │   ├── immersive_event_screen.dart        # THE CORE — 1551 lines:
│   │   │   ├── Joystick-driven exploration
│   │   │   ├── Branching: Gate → Crossroads → Paths → Gathering → Verdict
│   │   │   ├── Linear: sequential hotspots → Reflection
│   │   │   ├── Discovery panels with VO + Go Deeper
│   │   │   ├── Companion speech bubbles (idle, nudge, revisit)
│   │   │   ├── Settings overlay (pause)
│   │   │   ├── Tutorial overlay (first event)
│   │   │   ├── PopScope: save progress on back, block during Verdict
│   │   │   └── Completion: await writes → manual Continue → pop(true)
│   │   ├── journey_event_screen.dart          # Flat narrative fallback (Events 4-36)
│   │   ├── journey_quiz_screen.dart           # Standalone quiz (future use)
│   │   ├── settings_screen.dart               # Full settings page (from event list)
│   │   ├── era_complete_screen.dart           # Era celebration (used by flat events)
│   │   └── aerial_hub_screen.dart             # OLD parallax hub (dead code, replaced by
│   │                                            event_list_screen)
│   │
│   └── widgets\
│       ├── settings_overlay.dart              # In-game pause overlay
│       ├── tutorial_overlay.dart              # First-event tutorial (joystick + hotspots)
│       └── cinematic\
│           ├── branch_decision_card.dart      # The Crossroads — gold-pulsing choice card
│           ├── discovery_panel.dart           # Hotspot fragment card + image + Go Deeper + 
│           │                                    VO replay button
│           ├── go_deeper_section.dart         # Collapsible scholarly content section
│           ├── companion_figure.dart          # Circular avatar (gender-based in-scene image)
│           ├── companion_speech_bubble.dart   # Gold pill above companion
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
│           └── discovery_progress.dart        # "Explore · X/4" progress dots
│
├── assets\
│   ├── audio\                                 # 14 WAV (1 ambient + 13 SFX)
│   ├── audio\vo\                              # 84 MP3 (48 hotspot + 24 choice + 12 branch)
│   ├── audio\companion\                       # 52 MP3 (13 lines x 4 variants)
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
├── SPRINT_LOG.md                              # All 26+ sprint execution details
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
  ├── Tap Play (immersive event) → Cinematic Transition → Immersive Event Screen
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
Layer 1 — Ambient (looping)
  Volume: 0.10-0.25 (ducks to 0.06-0.08 during VO)
  Respects: PrefsService.musicEnabled
  Stops: on pause, settings, app background

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

## Branching System Safety

Events 4-36 have `branchPoint == null`. The `_isBranching` guard in
`immersive_event_screen.dart` ensures ALL branching logic is skipped
for linear events. Verified by 5 unit tests in `branching_test.dart`.

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
