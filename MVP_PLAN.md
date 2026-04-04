# Rawi MVP Plan — v0.6
# 3 Playable Events + Complete Gaming UX

> Created: 2026-04-01
> Updated: 2026-04-04 (42 sprints + post-audit complete)
> Goal: A demo-ready app that feels like a real game from first tap to last hotspot
> **Status: MVP COMPLETE — R4 POLISHED** — 42 sprints + post-audit. R4 testing round: 12 fixes. Per-hotspot ambient sound infrastructure, tap-to-walk, comprehensive movement freeze, bilingual intro, settings overlay redesign, font pre-cache.
>
> **Done:** All 42 sprints + post-audit + R4 fixes. Ambient sound system ready (awaiting audio assets from Khaled).
> **Remaining:** Firebase Crashlytics (needs google-services.json), font bundling (deferred), asset compression (needs ffmpeg), ambient audio files (8 hotspot + 1 onboarding).
>
> **Event Terminology:** The Gate → The Crossroads → The Paths → The Gathering → The Verdict (branching). The Reflection (linear).
> **Architecture:** See `ARCHITECTURE.md` for full details.

---

## What is the MVP?

A player downloads Rawi and experiences:
1. A cinematic splash screen
2. A story intro ("570 CE... The Arabian Peninsula...")
3. Registration (name, gender, language)
4. A hub screen showing their first event
5. 3 fully immersive events with diamond hotspots, discovery panels, companion, SFX
6. Cinematic transitions between events
7. Settings accessible anytime (music, VO, SFX, language, save & exit)
8. Arabic RTL text support throughout
9. Voice over narration on every discovery panel

**Events in MVP:**
| # | Event | Era | Year |
|---|-------|-----|------|
| 1 | Arabia Before the Light | Jahiliyyah | 500 CE |
| 2 | The Year of the Elephant | Jahiliyyah | 570 CE |
| 3 | The Black Stone — A Wise Arbitration | Jahiliyyah | 605 CE |

---

## Sprint Breakdown

### Sprint 1 — Splash + Intro Cinematic
**New files:** `splash_screen.dart`, `intro_cinematic_screen.dart`
**Modify:** `main.dart`

| # | Task | Details |
|---|------|---------|
| 1.1 | Splash screen | Navy bg, Rawi logo (gold Cinzel) fades in, بسم الله الرحمن الرحيم below (subtle). Auto-nav after 2s (first launch) or 1s (returning). |
| 1.2 | Intro cinematic | Full-screen `scene_welcome.jpg` + dark gradient. Sequential text fade: "570 CE..." → "A world waiting..." → "You are the Rawi" → "Witness history. Carry the story." Skip button top-right. "Begin" CTA at end. Only shows on first launch. |
| 1.3 | Update main.dart routing | Replace `isWelcomeSeen` with `onboardingComplete`. Flow: splash → (onboardingComplete ? hub : intro → registration). |

---

### Sprint 2 — Registration Flow
**New files:** `registration_screen.dart`
**Modify:** `prefs_service.dart`

| # | Task | Details |
|---|------|---------|
| 2.1 | Step 1 — Name | "What shall we call you, traveler?" Gold underline input. Optional — skip button. |
| 2.2 | Step 2 — Gender | "Choose your companion." Two circular image cards: `companion_male.jpg` / `companion_female.jpg` with gold border. Tap to select. |
| 2.3 | Step 3 — Language | "Choose your language." Two cards: English / العربية. |
| 2.4 | Step 4 — Milestone preview | 4 milestone cards (only M1 active). "Start the Journey" CTA. Migrate design from current `welcome_screen.dart`. |
| 2.5 | PageView + dots | Horizontal swipe between steps. Gold/white dot indicators. Back arrow on steps 2-4. |
| 2.6 | PrefsService keys | Add: `userName`, `userGender` ('male'/'female'), `onboardingComplete`, `musicEnabled`, `voEnabled`, `sfxEnabled`. |
| 2.7 | Delete welcome_screen.dart | Fully absorbed into splash + intro + registration. |

---

### Sprint 3 — Settings (Overlay + Screen)
**New files:** `settings_overlay.dart`, `settings_screen.dart`
**Modify:** `aerial_hub_screen.dart`, `immersive_event_screen.dart`, `audio_service.dart`

| # | Task | Details |
|---|------|---------|
| 3.1 | Settings overlay (in-game) | Dark semi-transparent overlay. Slide-down from top. Toggles: Music ON/OFF, VO ON/OFF, SFX ON/OFF, Language EN/AR. Buttons: Save & Exit, Resume. Pauses game loop + audio. |
| 3.2 | Settings screen (hub) | Full page from hub. Same toggles + Profile section (edit name, gender) + Reset Journey (with confirmation dialog) + About/Credits. |
| 3.3 | Wire ⚙️ into hub | Gear icon top-right of hub bar → navigates to settings screen. |
| 3.4 | Wire ⚙️ into immersive | Gear icon top-right during gameplay → opens settings overlay. |
| 3.5 | AudioService respects prefs | `playAmbient()` checks `musicEnabled`. `playSfx()` checks `sfxEnabled`. Future `playVoiceover()` checks `voEnabled`. |
| 3.6 | Pause/resume | Overlay open: pause game loop, mute audio. Overlay close: resume loop, restore audio. |
| 3.7 | Save & Exit | Save `_pathProgress` + `_discovered` to prefs. Pop to hub. Restore on re-entry. |

---

### Sprint 4 — Image-Based Companion
**Modify:** `companion_figure.dart`

| # | Task | Details |
|---|------|---------|
| 4.1 | Rewrite companion_figure | Replace CustomPainter with `ClipOval` + `Image.asset`. Load male/female JPG based on `PrefsService.userGender`. Gold border (2px). ~60px diameter. |
| 4.2 | Keep animations | Walking bob + breathing applied to container (not paint). Golden aura as BoxShadow. |
| 4.3 | Keep "You"/"أنت" label | Below the circle. Bilingual. |

---

### Sprint 5 — Hotspot System Overhaul
**Modify:** `scene_hotspot_marker.dart`, `immersive_event_screen.dart`, `discovery_panel.dart`

| # | Task | Details |
|---|------|---------|
| 5.1 | Diamond-shaped hotspots | Rotated square (45°). Pulse ring also diamond-shaped. Emoji centered. Dark pill label below. |
| 5.2 | Progressive reveal | Only NEXT undiscovered hotspot visible + pulsing. Completed = dimmed + green tick. Not-yet-reached = hidden. |
| 5.3 | Green tick after dismiss | Tick appears only after user dismisses discovery panel, not on proximity. |
| 5.4 | All hotspots centered card | Remove `centerMode: _activeHotspot!.id == 'kaabah'` check. All hotspots use centered card mode. |

---

### Sprint 6 — Scene Polish + Path Color
**Modify:** `scene_configs.dart`, `companion_figure.dart`, `discovery_progress.dart`, `path_route_painter.dart`

| # | Task | Details |
|---|------|---------|
| 6.1 | Event 1: disable stars/moon | Set `showStars: false`, `showMoon: false` in Event 1 config. |
| 6.2 | Silver path route | Replace all `AppColors.gold` in `path_route_painter.dart` with `Color(0xFFB8C4CC)`. |
| 6.3 | Fix progress/figure overlap | Reposition "Explore the scene 0/4" text higher when companion is near bottom of screen. |
| 6.4 | Figure visibility | Larger circle (70px?), stronger gold glow/shadow. Test on device. |

---

### Sprint 7 — Cinematic Transitions
**Modify/New:** `fly_transition.dart` or new `cinematic_transition.dart`
**Modify:** `immersive_event_screen.dart`, `aerial_hub_screen.dart`

| # | Task | Details |
|---|------|---------|
| 7.1 | Fade-to-black transition | Scene dims (300ms) → fade to black (400ms) → title card appears. |
| 7.2 | Title card | Year + location + event title. Gold Cinzel title, Nunito subtitle. Hold 2s. Bilingual. |
| 7.3 | Fade into new scene | Title card fades out (400ms) → new scene fades in (600ms). |
| 7.4 | Wire into event flow | Hub → event and event → next event both use cinematic transition. |

---

### Sprint 8 — Event 2 Bubbles + Event 3 Full Build
**Modify:** `scene_configs.dart`
**Generate:** 4 SFX WAV files

| # | Task | Details |
|---|------|---------|
| 8.1 | Wire Event 2 bubble images | Add `imagePath` to all 4 Event 2 hotspots: `bubble_army.jpg`, `bubble_muttalib.jpg`, `bubble_elephants.jpg`, `bubble_birds.jpg`. |
| 8.2 | Generate Event 3 SFX | Python: `sfx_flood_rubble.wav`, `sfx_dispute_crowd.wav`, `sfx_dawn_wind.wav`, `sfx_cloak_fabric.wav`. 8s, 22050Hz mono. |
| 8.3 | Build Event 3 scene config | Full `SceneConfig` for `j_1_1_3`: dawn gradient, dust particles, no stars/moon, film grain, 4 hotspots, 10 waypoints. Fragments EN+AR from V06 plan. |
| 8.4 | Test all 3 events | Play through E1 → E2 → E3 with all new systems (diamond hotspots, progressive reveal, centered cards, cinematic transitions). |

---

### Sprint 9 — Companion Speech Bubbles
**New files:** `companion_speech_bubble.dart`, `companion_dialogue.dart`
**Modify:** `immersive_event_screen.dart`

| # | Task | Details |
|---|------|---------|
| 9.1 | Speech bubble widget | Gold-bordered pill above companion. Nunito 10px. Fade in (400ms) → hold 3s → fade out (400ms). |
| 9.2 | Dialogue data | `Map<String, List<String>>` per trigger type x 2 languages. ~30 lines EN + 30 AR. |
| 9.3 | Idle trigger | 10s no input → contextual hint based on game state. |
| 9.4 | Post-discovery nudge | After panel dismissed → "Onward..." / "There is more to witness." 3s duration. |
| 9.5 | Revisit limiter | 3rd revisit: gentle redirect. 4th+: firmer redirect. |

---

### Sprint 10 — Partial RTL
**Modify:** Multiple screens

| # | Task | Details |
|---|------|---------|
| 10.1 | Hub screen RTL | Event title, subtitle, era chip — `TextDirection.rtl` when Arabic. |
| 10.2 | Registration/onboarding RTL | All new screens respect language direction. |
| 10.3 | Progress text RTL | "Explore the scene" matches language. |
| 10.4 | Companion label RTL | "أنت" aligns right. |
| 10.5 | Era complete screen RTL | All text blocks. |
| 10.6 | Settings RTL | Toggle labels, section headers. |
| 10.7 | Full Arabic playthrough test | E1 → E2 → E3 entirely in Arabic. Fix overflow. |

---

### Sprint 11 — Edge TTS Voice Over
**New files:** `tools/generate_vo.py`
**Modify:** `audio_service.dart`, `discovery_panel.dart`, `immersive_event_screen.dart`

| # | Task | Details |
|---|------|---------|
| 11.1 | Python generation script | Takes fragment text → MP3 via `edge-tts`. Gender + language aware. |
| 11.2 | Generate E1-E3 VO | 4 fragments x 2 lang x 2 genders x 3 events = 48 MP3 files. |
| 11.3 | Generate companion speech VO | ~30 lines x 2 lang x 2 genders = ~120 short clips. |
| 11.4 | Add VO layer to AudioService | `playVoiceover(path, volume)` — separate player instance. Respects `voEnabled` pref. |
| 11.5 | Wire VO into discovery panel | Panel opens → VO starts (300ms delay). Panel dismissed → VO fades out (500ms). |
| 11.6 | Volume balancing | Ambient ducks to 0.15 during VO. VO at 0.7. SFX at 0.3. |
| 11.7 | Re-tap VO | Re-tapping completed hotspot replays VO. |

---

## Sprint Map (Visual)

```
Sprint 1  ── Splash + Intro Cinematic
Sprint 2  ── Registration Flow
Sprint 3  ── Settings (Overlay + Screen)
Sprint 4  ── Image-Based Companion
              ↓ Gaming shell complete ↓
Sprint 5  ── Hotspot System Overhaul
Sprint 6  ── Scene Polish + Silver Path
Sprint 7  ── Cinematic Transitions
Sprint 8  ── Event 2 Bubbles + Event 3
Sprint 9  ── Companion Speech Bubbles
              ↓ Gameplay complete ↓
Sprint 10 ── Partial RTL
Sprint 11 ── Edge TTS Voice Over
              ↓ MVP DONE ↓
```

---

## Definition of Done (MVP)

- [ ] First launch: splash → intro → registration → hub (smooth, cinematic)
- [ ] Returning launch: splash → hub (1s)
- [ ] Hub shows current event with ⚙️ settings access
- [ ] 3 immersive events playable end-to-end (E1 → E2 → E3)
- [ ] Diamond hotspots with progressive reveal
- [ ] Centered discovery cards with bubble images on all 12 hotspots
- [ ] Cinematic fade-to-black transitions between events
- [ ] Companion: circular image avatar, gender-selected, with speech bubbles
- [ ] Settings: music/VO/SFX toggles, language switch, save & exit
- [ ] All Arabic text renders RTL
- [ ] Voice over narration on all 12 discovery panels
- [ ] App icon configured (not default blue Flutter icon)
- [ ] Package name: `com.rawi.journey`
- [ ] `flutter analyze` — zero issues

---

## New Files to Create (11 total)

| File | Sprint | Purpose |
|------|--------|---------|
| `lib/screens/splash_screen.dart` | 1 | Logo splash |
| `lib/screens/intro_cinematic_screen.dart` | 1 | First-launch story intro |
| `lib/screens/registration_screen.dart` | 2 | 4-step profile setup |
| `lib/screens/settings_screen.dart` | 3 | Hub settings page |
| `lib/widgets/settings_overlay.dart` | 3 | In-game pause overlay |
| `lib/widgets/cinematic/companion_speech_bubble.dart` | 9 | Speech pill above companion |
| `lib/data/companion_dialogue.dart` | 9 | Dialogue bank EN+AR |
| `lib/screens/cinematic_transition_screen.dart` | 7 | Fade-to-black + title card |
| `tools/generate_vo.py` | 11 | Edge TTS batch generator |
| `assets/audio/vo/` (directory) | 11 | 48 VO MP3 files |
| `assets/audio/companion/` (directory) | 11 | ~120 companion speech clips |

## Files to Delete (1)

| File | Sprint | Reason |
|------|--------|--------|
| `lib/screens/welcome_screen.dart` | 2 | Replaced by splash + intro + registration |

## Files to Rewrite (2)

| File | Sprint | Change |
|------|--------|--------|
| `lib/widgets/cinematic/companion_figure.dart` | 4 | CustomPainter → image circle |
| `lib/widgets/cinematic/fly_transition.dart` | 7 | Simple zoom → cinematic fade-to-black |
