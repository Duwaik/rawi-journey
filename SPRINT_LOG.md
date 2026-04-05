# Rawi — Sprint Execution Log

> Tracks what was actually built in each sprint, decisions made, and issues encountered.
>
> **Terminology (from Sprint 26+):** The Gate (anchor) → The Crossroads (choice card) → The Paths (branch hotspots) → The Gathering (convergence) → The Verdict (final question). Linear events use The Reflection.

---

## Sprint 1 — Splash + Intro Cinematic
**Date:** 2026-04-01
**Status:** COMPLETE

### Built
| File | Type | Details |
|------|------|---------|
| `lib/screens/splash_screen.dart` | NEW | Navy bg, RAWI/راوي logo fade-in with staggered timing (logo 0-60%, bismillah 40-100%). Auto-navigates: 2s hold for first launch → intro cinematic, 1s for returning → hub. Fade transition (600ms). |
| `lib/screens/intro_cinematic_screen.dart` | NEW | Full-screen `scene_welcome.jpg` with dark gradient overlay. 5 sequential bilingual text lines, each: 600ms fade-in → 1800ms hold → 400ms fade-out. Lines: "570 CE" → "The Arabian Peninsula..." → "A world waiting for a message" → "You are the Rawi" → "Witness history. Carry the story." Skip button (top-right). "Begin" CTA fades in at end. |
| `lib/services/prefs_service.dart` | MODIFIED | Added 7 new keys: `onboardingComplete` (bool), `userName` (String), `userGender` (String: male/female), `musicEnabled` (bool), `voEnabled` (bool), `sfxEnabled` (bool). Added `isAr` helper getter. |
| `lib/main.dart` | MODIFIED | Entry point now always routes to `SplashScreen`. Removed `WelcomeScreen` and `AerialHubScreen` imports from main. |

### Flow After Sprint 1
```
First launch:  App → SplashScreen (2s) → IntroCinematicScreen → "Begin" → Hub
Returning:     App → SplashScreen (1s) → Hub
```

### Quality
- `flutter analyze` — zero issues
- Package name updated to `com.rawi.journey` (build.gradle.kts + MainActivity.kt)

---

## Sprint 2 — Registration Flow
**Date:** 2026-04-01
**Status:** COMPLETE

### Built
| File | Type | Details |
|------|------|---------|
| `lib/screens/registration_screen.dart` | NEW | 4-step horizontal PageView with dot indicators. Step 1: Name input (optional, gold underline, skip button). Step 2: Gender selection (two circular image cards — `companion_male.jpg`/`companion_female.jpg` — with gold border, scale animation, glow on selected). Step 3: Language (English/العربية cards with flags). Step 4: Milestone preview (4 cards migrated from welcome_screen, M1 active, M2-M4 locked with lock icon). "Start the Journey" CTA saves all prefs and navigates to hub. |
| `lib/screens/intro_cinematic_screen.dart` | MODIFIED | "Begin" and "Skip" now navigate to `RegistrationScreen` instead of hub. Removed `setOnboardingComplete()` call — registration handles it. Removed TODO comments. |
| `lib/screens/welcome_screen.dart` | DELETED | Fully replaced by splash + intro + registration flow. Milestone card design migrated to registration step 4. |

### Flow After Sprint 2
```
First launch:  App → Splash (2s) → Intro Cinematic → Registration (4 steps) → Hub
Returning:     App → Splash (1s) → Hub
```

### Registration Steps
```
Step 1: Name     → "What shall we call you, traveler?" (optional, skip)
Step 2: Gender   → Two circular avatar cards (male/female JPG images)
Step 3: Language → English 🇬🇧 / العربية 🇸🇦 cards
Step 4: Milestones → 4 chapter cards → "Start the Journey" CTA
```

### Data Saved on Completion
- `userName` → SharedPreferences (if entered)
- `userGender` → 'male' or 'female'
- `language` → 'en' or 'ar'
- `onboardingComplete` → true

### Quality
- `flutter analyze` — zero issues
- Zero dangling imports after welcome_screen deletion

---

## Sprint 3 — Settings (Overlay + Screen)
**Date:** 2026-04-01
**Status:** COMPLETE

### Built
| File | Type | Details |
|------|------|---------|
| `lib/widgets/settings_overlay.dart` | NEW | Semi-transparent dark overlay (slide-down 300ms). Toggle rows: Music ON/OFF, Voice Over ON/OFF, Sound Effects ON/OFF. Language cycle (EN↔AR). Save & Exit button (pops to hub). Resume button (gold, closes overlay). All toggles persist to SharedPreferences immediately. |
| `lib/screens/settings_screen.dart` | NEW | Full-page settings from hub. Sections: Audio (3 toggles), Profile (language cycle, companion gender cycle, name display), Journey (XP, streak, reset with confirmation dialog), About (logo + version + tagline). Back arrow returns to hub. Bilingual labels throughout. |
| `lib/screens/aerial_hub_screen.dart` | MODIFIED | Added ⚙️ gear icon (circle, 34px) after XP badge in top bar. Taps → fades out ambient → pushes SettingsScreen → on return: refreshes state + restarts ambient if music enabled. |
| `lib/screens/immersive_event_screen.dart` | MODIFIED | Added `_showSettings` state bool. Added ⚙️ gear icon (circle, 32px) after language toggle in top bar. `_openSettings()`: stops game loop + audio, shows overlay. `_resumeFromSettings()`: hides overlay, syncs `_isAr` from prefs, restarts ambient if enabled. `_saveAndExit()`: pops to hub. SettingsOverlay rendered as top-level Stack child. |
| `lib/services/audio_service.dart` | MODIFIED | `playAmbient()` checks `PrefsService.musicEnabled` — returns early if false. `playSfx()` checks `PrefsService.sfxEnabled` — returns early if false. Added `prefs_service.dart` import. |

### Settings Access Points
```
From Hub:     ⚙️ top-right → SettingsScreen (full page)
During Game:  ⚙️ top-right → SettingsOverlay (pause overlay)
```

### Toggle Behavior
| Toggle | Pref Key | Default | Effect |
|--------|----------|---------|--------|
| Music | `musicEnabled` | true | Controls ambient audio playback |
| Voice Over | `voEnabled` | true | Ready for Phase 5 TTS wiring |
| Sound Effects | `sfxEnabled` | true | Controls SFX on hotspot discovery |
| Language | `language` | 'en' | Cycles EN↔AR, immediate text update |

### Quality
- `flutter analyze` — 1 info-level hint (BuildContext async gap — false positive on correct `mounted` guard), zero errors/warnings

---

## Sprint 4 — Image-Based Companion
**Date:** 2026-04-01
**Status:** COMPLETE

### Built
| File | Type | Details |
|------|------|---------|
| `lib/widgets/cinematic/companion_figure.dart` | REWRITTEN | Replaced 255-line CustomPainter bust (head, keffiyeh, shoulders, eyes, beard) with image-based circular avatar. Loads `companion_male.jpg` or `companion_female.jpg` based on `PrefsService.userGender`. 60px diameter ClipOval with 2px gold border. Animated golden aura glow (BoxShadow pulsing with animation). Walking bob + breathing + lean animations applied via `Transform.translate` on the container. "You"/"أنت" label below. |
| `lib/screens/immersive_event_screen.dart` | MODIFIED | Adjusted companion positioning offset from (-22, -31) to (-32, -41) to account for larger circle (60px vs old 44px bust). |

### Before → After
```
Before: CustomPainter draws head, keffiyeh, agal, eyes, beard, shoulders, neck (255 lines)
After:  ClipOval + Image.asset inside gold-bordered circle (130 lines)
```

### Same Interface Preserved
- `isWalking` — walking bob animation
- `facingDirection` — lean during movement
- `isAr` — "You"/"أنت" label language

### Gender Reactivity
- Reads `PrefsService.userGender` on each build
- Changes take effect on next event load (no hot-reload needed mid-scene)

### Quality
- `flutter analyze` — zero errors/warnings

---

## Sprint 5 — Hotspot System Overhaul
**Date:** 2026-04-01
**Status:** COMPLETE

### Built
| File | Type | Details |
|------|------|---------|
| `lib/widgets/cinematic/scene_hotspot_marker.dart` | REWRITTEN | Replaced circular marker with diamond shape (rotated 45° square, `borderRadius: 4`). Three states: `active` (pulsing diamond + glow — next to discover), `discovered` (dimmed diamond + green tick badge), hidden (not rendered). New `active` bool parameter. Icon stays upright inside rotated container. Pulse ring also diamond-shaped. |
| `lib/screens/immersive_event_screen.dart` | MODIFIED | **Progressive reveal:** Added `_pendingDiscovery` set (found but panel not yet dismissed). Hotspot rendering now filters: only show discovered + pending + next undiscovered hotspot. All shown in choose phase. **Green tick fix:** `_discovered.add()` moved from `_activateHotspot`/`_onHotspotTap` to `_dismissPanel`. Tick only appears after panel dismiss. **Centered card:** Changed `centerMode: _activeHotspot!.id == 'kaabah'` to `centerMode: true` — all hotspots use centered card. Updated `discoveredCount` and progress to include pending. |

### Behavior Change Summary
| Feature | Before | After |
|---------|--------|-------|
| Hotspot shape | Circle (40px) | Diamond (rotated 36px square) |
| Visibility | All hotspots visible from start | Only completed + next one visible (progressive) |
| Green tick | Appears on proximity (auto-discovery) | Appears after user dismisses panel |
| Card mode | Only Ka'bah centered, others bottom panel | All hotspots use centered card |
| Pulse animation | All undiscovered pulse | Only the active (next) hotspot pulses |

### State Machine
```
Hidden → Active (next to discover, pulsing)
  → Pending (found, panel open, no tick yet)
  → Discovered (panel dismissed, green tick shown)
```

### Quality
- `flutter analyze` — zero errors/warnings

---

## Sprint 6 — Scene Polish + Silver Path
**Date:** 2026-04-01
**Status:** COMPLETE

### Built
| File | Type | Details |
|------|------|---------|
| `lib/data/scene_configs.dart` | MODIFIED | Event 1: `showStars: false`, `showMoon: false`. Removed `moonPosition`. Daytime/sunset image no longer has clashing night sky elements. |
| `lib/widgets/cinematic/path_route_painter.dart` | REWRITTEN | Replaced all `AppColors.gold` with silver `Color(0xFFB8C4CC)`. Active: silver glow + solid line. Completed: dim silver dots. Upcoming: subtle silver dots. Removed `app_colors.dart` import. |
| `lib/widgets/cinematic/companion_figure.dart` | MODIFIED | Circle 60→64px, border 2→2.5px, image 56→60px. Glow boosted: blurRadius 14→20, spreadRadius 2→4, alpha +20. |
| `lib/screens/immersive_event_screen.dart` | MODIFIED | Progress text repositioned `bottom: 130 → 180` to clear companion at start position. |

### Quality
- `flutter analyze` — zero errors/warnings

---

## Sprint 7 — Cinematic Transitions
**Date:** 2026-04-01
**Status:** COMPLETE

### Built
| File | Type | Details |
|------|------|---------|
| `lib/screens/cinematic_transition_screen.dart` | NEW | Fade-to-black + title card transition. Flow: black overlay fades in (400ms) → title card fades in (400ms) showing year CE, location, event title in Cinzel gold → hold 2s → title fades out (400ms) → 200ms pause → `onComplete` callback. Bilingual. Decorative gold line separator. |
| `lib/screens/aerial_hub_screen.dart` | MODIFIED | `_openEvent` now pushes `CinematicTransitionScreen` first (opaque: false, instant). On completion, `pushReplacement` swaps to event screen. Also respects `musicEnabled` on return. |

### Transition Flow
```
Hub → tap event → audio fades
  → black fills screen (400ms)
  → title card: "570 CE / Mecca / Arabia Before the Light" (2s)
  → title fades (400ms)
  → pushReplacement → event screen
```

### Quality
- `flutter analyze` — zero errors/warnings

---

## Sprint 8 — Event 2 Bubbles + Event 3 Full Build
**Date:** 2026-04-01
**Status:** COMPLETE

### Built
| File | Type | Details |
|------|------|---------|
| `lib/data/scene_configs.dart` | MODIFIED | **Event 2:** Added `imagePath` to all 4 hotspots: `bubble_army.jpg`, `bubble_muttalib.jpg`, `bubble_elephants.jpg`, `bubble_birds.jpg`. **Event 3 (NEW):** Full `SceneConfig` for `j_1_1_3` — The Black Stone arbitration, 605 CE. Dawn sky gradient (9 stops, deep night → pale gold). 4 hotspots: flood (🌊), dispute (⚔️), alamin (⭐), cloak (📿). Full bilingual fragments EN+AR. 10 path waypoints. Dust particles (40 count). No stars/moon. Film grain. |
| `assets/audio/sfx_flood_rubble.wav` | NEW | 8s, 22050Hz mono. Low rumble + occasional cracks + gravel noise. |
| `assets/audio/sfx_dispute_crowd.wav` | NEW | 8s, 22050Hz mono. Murmuring crowd with multiple voice frequencies. |
| `assets/audio/sfx_dawn_wind.wav` | NEW | 8s, 22050Hz mono. Gentle wind with slow oscillation. |
| `assets/audio/sfx_cloak_fabric.wav` | NEW | 8s, 22050Hz mono. Fabric rustling with high-freq shimmer. |

### Event 3 — The Black Stone (605 CE)
```
Hotspot 1: 🌊 The Flood Damage    (0.25, 0.58) — rebuilding after the flood
Hotspot 2: ⚔️ The Dispute          (0.50, 0.45) — tribes argue over the Stone
Hotspot 3: ⭐ Al-Amin Enters       (0.72, 0.50) — Muhammad ﷺ arrives at dawn
Hotspot 4: 📿 The Wise Solution    (0.55, 0.35) — the cloak solution

Sky: Dawn gradient (purple → terracotta → gold)
Particles: Dust (construction site)
Ambient: desert evening (reused), volume 0.18
```

### All 3 Events Now Have
- Scene image + 4 bubble images each
- 4 hotspots with bilingual fragments
- 10 path waypoints
- SFX per hotspot
- Atmospheric overlays (sky, particles, grain)

### Asset Count After Sprint 8
- Audio: 14 WAV files (1 ambient + 13 SFX)
- Scenes: 17 JPG files (3 scene + 13 bubble + 1 welcome)

### Quality
- `flutter analyze` — zero errors/warnings

---

## Sprint 9 — Companion Speech Bubbles
**Date:** 2026-04-01
**Status:** COMPLETE

### Built
| File | Type | Details |
|------|------|---------|
| `lib/data/companion_dialogue.dart` | NEW | Dialogue bank with 7 trigger categories, ~25 lines EN + 25 AR. Categories: `idleStart`, `idleNearHotspot`, `idleMidJourney`, `postDiscovery`, `revisitWarn`, `revisitFirm`, `allDone`. `DialogueLine` class with EN/AR pairs. `CompanionDialogue.get()` cycles through lines by index. |
| `lib/widgets/cinematic/companion_speech_bubble.dart` | NEW | Gold-bordered pill (max 200px). Fade in/out (400ms) via AnimationController. Dark bg with gold border + shadow. Nunito 10px gold text. Bilingual RTL support. Parent controls visibility via `visible` bool. |
| `lib/screens/immersive_event_screen.dart` | MODIFIED | Added `_idleTimer` (10s periodic Timer), `_idleTriggerCount`, `_postDiscoveryCount`, `_revisitCount` map. `_resetIdleTimer()` called on joystick move/release and initState. `_onIdle()` fires after 10s inactivity — picks contextual line (start/near hotspot/mid-journey). `_dismissPanel()` shows post-discovery nudge. `_onHotspotTap()` tracks revisit count — 3rd tap shows gentle redirect, 4th+ shows firm redirect (returns without opening panel). Speech bubble rendered above companion in Column. Timer cancelled on dispose. |

### Trigger Behavior
| Trigger | When | Bubble Duration |
|---------|------|----------------|
| Idle (no hotspots) | 10s no input from start | 3s |
| Idle (near hotspot) | 10s near undiscovered hotspot | 3s |
| Idle (mid-journey) | 10s, 1+ hotspots done | 3s |
| Post-discovery | After panel dismissed | 3s |
| Revisit 3rd | Tap completed hotspot 3rd time | 3s (blocks panel) |
| Revisit 4th+ | Tap completed hotspot 4th+ time | 3s (blocks panel) |
| All done | Last panel dismissed | 3s |

### Quality
- `flutter analyze` — zero errors/warnings

---

## Sprint 10 — Partial RTL
**Date:** 2026-04-01
**Status:** COMPLETE

### Built
| File | Type | Details |
|------|------|---------|
| `lib/screens/aerial_hub_screen.dart` | MODIFIED | Added `TextDirection.rtl` to: event status label ("مكتمل"/"الحدث التالي"), event title, location text. Switched `PrefsService.language == 'ar'` to `PrefsService.isAr`. |
| `lib/widgets/cinematic/discovery_progress.dart` | MODIFIED | Added `TextDirection.rtl` to "استكشف المشهد" text when Arabic. |
| `lib/widgets/cinematic/companion_figure.dart` | MODIFIED | Added `TextDirection.rtl` to "أنت" label. |
| `lib/screens/era_complete_screen.dart` | MODIFIED | Added `TextDirection.rtl` to: chapter complete label, era description, XP earned text, continue button, back to map button. Fixed Arabic arrow direction (→ to ←). |
| `lib/widgets/settings_overlay.dart` | MODIFIED | Added `TextDirection.rtl` to header "الإعدادات". |

### RTL Coverage Summary
| Screen | Status |
|--------|--------|
| Discovery panel (fragment, label, tap to continue) | Already done (pre-v0.6) |
| Choice phase — immersive (question, options, explanation) | Already done (pre-v0.6) |
| Choice phase — flat event screen | Already done (pre-v0.6) |
| Hub screen (event card title, location, status) | **Done Sprint 10** |
| Registration (all 4 steps) | Done Sprint 2 (built with RTL) |
| Splash + intro cinematic | Done Sprint 1 (built with RTL) |
| Discovery progress text | **Done Sprint 10** |
| Companion "You"/"أنت" label | **Done Sprint 10** |
| Era complete screen | **Done Sprint 10** |
| Settings overlay header | **Done Sprint 10** |
| Settings screen | Done Sprint 3 (built with RTL) |

### Quality
- `flutter analyze` — zero errors/warnings

---

## Sprint 11 — Edge TTS Voice Over
**Date:** 2026-04-02
**Status:** COMPLETE

### Built
| File | Type | Details |
|------|------|---------|
| `tools/generate_vo.py` | NEW | Python batch generator using `edge-tts`. 12 fragment texts (4 per event x 3 events) x 4 voice variants (en_m, en_f, ar_m, ar_f) = 48 VO files. 13 companion lines x 4 variants = 52 companion clips. Total: 100 MP3 files. Batched in groups of 10 to avoid rate limiting. Skips existing files. |
| `assets/audio/vo/` | NEW | 48 MP3 files. Naming: `vo_{eventKey}_{hotspotId}_{lang}_{gender}.mp3`. |
| `assets/audio/companion/` | NEW | 52 MP3 files. Naming: `comp_{lineId}_{lang}_{gender}.mp3`. |
| `lib/services/audio_service.dart` | MODIFIED | Added Layer 2 (VO): `_vo` AudioPlayer, `playVoiceover()` with ambient ducking (0.25 → 0.08 during VO), `fadeOutVoiceover()` (500ms fade), `stopVoiceover()`. Respects `PrefsService.voEnabled`. Auto-restores ambient volume when VO completes. |
| `lib/screens/immersive_event_screen.dart` | MODIFIED | Added `_voPath()` — derives VO asset path from event ID + hotspot ID + language + gender. `_playVoForHotspot()` — plays VO 300ms after panel opens. Wired into `_activateHotspot()` and `_onHotspotTap()`. `_dismissPanel()` calls `fadeOutVoiceover()`. `_openSettings()` calls `stopVoiceover()`. |
| `pubspec.yaml` | MODIFIED | Added `assets/audio/vo/` and `assets/audio/companion/` to asset declarations. |

### Voice Pairs
| Gender | Arabic | English |
|--------|--------|---------|
| Male | `ar-JO-TaimNeural` (Jordanian) | `en-GB-RyanNeural` (British) |
| Female | `ar-JO-SanaNeural` (Jordanian) | `en-GB-SoniaNeural` (British) |

### Audio Layer Architecture
```
Layer 1: Ambient (looping)     — 0.25 vol (ducks to 0.08 during VO)
Layer 2: Voice Over (one-shot) — 0.70 vol, 300ms delay after panel open
Layer 3: SFX (one-shot)        — 0.40 vol on hotspot discovery
```

### VO Flow
```
Panel opens → 300ms delay → VO starts → ambient ducks
  → user dismisses panel → VO fades out (500ms) → ambient restores
  → or VO finishes naturally → ambient restores automatically
```

### Asset Count (Final)
- Fragment VO: 48 MP3 (12 fragments x 4 variants)
- Companion VO: 52 MP3 (13 lines x 4 variants)
- SFX: 14 WAV (1 ambient + 13 SFX)
- Images: 17 JPG (3 scene + 13 bubble + 1 welcome) + 2 figures + 1 icon
- **Total audio files: 114**
- **Total assets: 134**

### Quality
- `flutter analyze` — zero errors/warnings

---

## Sprint 12 — Critical Fixes (R1-01, R1-02, R1-03)
**Date:** 2026-04-02
**Status:** COMPLETE
**Fixes:** R1-01 (figure freeze), R1-02 (auto-move), R1-03 (VO leak)

### Built
| File | Type | Details |
|------|------|---------|
| `lib/screens/immersive_event_screen.dart` | MODIFIED | **R1-01 freeze fix:** `didChangeAppLifecycleState` now fully resets on pause: stops game loop, resets controller to 0, zeros joystick input, cancels idle timer, sets walking=false. On resume: restarts ambient (if enabled) and idle timer. **R1-02 auto-move fix:** Changed `_gameLoop.forward()` to `_gameLoop.repeat()` in joystick `onMove` — loop now repeats indefinitely while held. Added `_gameLoop.reset()` in `onRelease` — fully stops and resets to 0. Also added reset in `_openSettings`. **R1-03 VO leak fix:** Added `AudioService.stopVoiceover()` to `didChangeAppLifecycleState` pause handler. VO now stops when app is backgrounded. |

### Root Causes
| Bug | Root Cause | Fix |
|-----|-----------|-----|
| R1-01 freeze | `AnimationController.forward()` with 100s duration — once completed (value=1.0), calling forward again is a no-op. After app pause/resume, controller stuck at last value. | Reset to 0 on pause. Use `repeat()` instead of `forward()`. |
| R1-02 auto-move | Same `forward()` issue — loop kept ticking through 100s even after joystick release in edge cases. Race between `stop()` and frame callbacks. | `repeat()` + `reset()` on release. Joystick values zeroed. |
| R1-03 VO leak | `didChangeAppLifecycleState` only stopped ambient + SFX, not the VO player. | Added `stopVoiceover()` to pause handler. |

### Quality
- `flutter analyze` — zero errors/warnings

---

## Sprint 13 — Hotspot Visibility UX Change (R1-04)
**Date:** 2026-04-02
**Status:** COMPLETE
**Fixes:** R1-04

### Built
| File | Type | Details |
|------|------|---------|
| `lib/widgets/cinematic/scene_hotspot_marker.dart` | REWRITTEN | Added `locked` state (4th visual state). Locked: 35% opacity, muted diamond border, smaller icon (14px, white38), lock icon badge (top-right), dimmed label. `onTap` is null when locked (not tappable). |
| `lib/screens/immersive_event_screen.dart` | MODIFIED | Removed `.where()` filter — all hotspots now rendered. Each gets state: `discovered` (tick), `active` (pulsing, next), `locked` (dimmed, untappable), or pending (panel open). |

### Visual States
```
🔒 Locked   — dimmed 35% opacity, muted border, lock badge, not tappable
💎 Active   — pulsing gold diamond, glow, tappable (next to discover)
📋 Pending  — found but panel still open, no tick yet
✅ Discovered — dimmed diamond, green tick badge, re-tappable
```

### Before → After
```
Before: Only show completed + next hotspot. Rest hidden.
After:  ALL 4 hotspots visible from start. Locked ones dimmed with 🔒.
        Player sees the full map of what's ahead.
```

### Quality
- `flutter analyze` — zero errors/warnings

---

## Sprint 14 — Visual & Audio Fixes (R1-09 to R1-14)
**Date:** 2026-04-02
**Status:** COMPLETE
**Fixes:** R1-09, R1-10, R1-11, R1-12, R1-13, R1-14

### Built
| File | Type | Fix |
|------|------|-----|
| `lib/screens/registration_screen.dart` | MODIFIED | **R1-09:** Restructured `_GenderCard` — moved label Text outside the circular AnimatedContainer. Circle now only wraps the ClipOval image. Label sits below independently. |
| `tools/generate_vo.py` | MODIFIED | **R1-10:** Changed Arabic voices from `ar-JO-TaimNeural`/`ar-JO-SanaNeural` to `ar-SY-LaithNeural`/`ar-SY-AmanyNeural` (Syrian — closest to Palestinian). **R1-14:** Updated all 12 fragments to match full text from scene_configs.dart (missing last sentences added). |
| `assets/audio/vo/` | REGENERATED | All 48 fragment VO files regenerated with full text + Syrian Arabic voices. |
| `assets/audio/companion/` | REGENERATED | All 26 Arabic companion clips regenerated with Syrian voices. |
| `lib/data/companion_dialogue.dart` | MODIFIED | **R1-11:** Added `id` field to `DialogueLine`. Added `getId()` static method. All lines now have IDs matching companion VO filenames. |
| `lib/screens/immersive_event_screen.dart` | MODIFIED | **R1-11:** Added `_companionVoPath()` helper. All 5 `_showBubble()` call sites now pass `voPath` — idle, revisit warn/firm, post-discovery, all-done. **R1-12:** Moved discovery progress from `bottom: 180` to `top: topPad + 52` (below era bar). |
| `lib/widgets/cinematic/discovery_panel.dart` | MODIFIED | **R1-13:** Changed centered card image from `BoxFit.cover` + `height: 160` to `BoxFit.contain` + `maxHeight: 180` via ConstrainedBox. Images no longer crop. |

### Quality
- `flutter analyze` — zero errors/warnings

---

## Sprint 15 — Hub Redesign + Post-Event Flow (R1-05 to R1-08)
**Date:** 2026-04-02
**Status:** COMPLETE
**Fixes:** R1-05, R1-06, R1-07, R1-08

### Built
| File | Type | Details |
|------|------|---------|
| `lib/screens/event_list_screen.dart` | NEW | **R1-05:** Replaces parallax hub. RAWI header with progress badge (X/36), XP badge, settings gear. Scrollable ListView of all 36 events. Each card shows: event number (circle), title (bilingual RTL), location + year, status badge. States: completed (green check + X/X hotspots), next (highlighted border + glow + "Play" badge), locked (40% opacity + lock icon). Tapping completed/next opens cinematic transition → event. Cinematic transition + audio management carried over from old hub. |
| `lib/screens/splash_screen.dart` | MODIFIED | **R1-08:** Now navigates to `EventListScreen` instead of `AerialHubScreen`. |
| `lib/screens/registration_screen.dart` | MODIFIED | Same — navigates to `EventListScreen` after onboarding. |
| `lib/screens/immersive_event_screen.dart` | MODIFIED | **R1-06:** `_continue()` simplified — always pops back to event list. Removed `_didCompleteEra()` and `EraCompleteScreen` routing. Removed unused `era_complete_screen.dart` import. Progress updates immediately on pop since event list refreshes in `_refresh()`. |
| `lib/screens/settings_screen.dart` | MODIFIED | **R1-07:** Reset journey now calls `Navigator.pushAndRemoveUntil(SplashScreen)` — clears entire nav stack, restarts from splash as if freshly installed. |

### Flow Change
```
BEFORE:
  Hub (parallax + single card) → event → "Witnessed" button → hub (stale) → tap → hub (updated)

AFTER:
  Event List (all events with progress) → tap → cinematic transition → event
  → "Continue" → pop → Event List (instantly refreshed, next event highlighted)
```

### Dead Code Created
- `lib/screens/aerial_hub_screen.dart` — no longer imported anywhere. Can be deleted in next cleanup.

### Quality
- `flutter analyze` — zero errors/warnings

---

## Sprint 16 — Gameplay Tutorial Overlay (R1-15)
**Date:** 2026-04-02
**Status:** COMPLETE
**Fixes:** R1-15

### Built
| File | Type | Details |
|------|------|---------|
| `lib/widgets/tutorial_overlay.dart` | NEW | Semi-transparent overlay (black 70%). 2-step sequential tutorial, tap anywhere to advance. Step 1: gamepad icon + "Use the joystick to move" + arrow pointing bottom-left (joystick area). Step 2: diamond icon + "Discover the glowing diamonds" + arrow pointing up (hotspot area). Step dots at bottom. "Tap to continue" prompt. Bilingual EN+AR. Fade in (400ms) / fade out (400ms). Marks `tutorialSeen` in prefs on completion. |
| `lib/services/prefs_service.dart` | MODIFIED | Added `tutorialSeen` key + getter/setter. |
| `lib/screens/immersive_event_screen.dart` | MODIFIED | Added `_showTutorial` state. On first event (globalOrder == 1) + tutorial not seen → shows overlay before gameplay. On completion callback → hides overlay + starts idle timer. Rendered as top-level Stack child above settings overlay. |

### Tutorial Flow
```
First event, first time:
  Scene loads → tutorial overlay appears (blocks gameplay)
  → Step 1: "Use the joystick to move" [tap]
  → Step 2: "Discover the glowing diamonds" [tap]
  → Overlay fades out → gameplay begins → idle timer starts

Subsequent events / replays:
  No tutorial shown (tutorialSeen = true)
```

### Quality
- `flutter analyze` — zero errors/warnings

---

## Sprint 17 — Post-Event Flow Overhaul (R2-05, R2-06, R2-10)
**Date:** 2026-04-02
**Status:** COMPLETE
**Fixes:** R2-05, R2-06, R2-10

### Built
| File | Type | Details |
|------|------|---------|
| `lib/screens/immersive_event_screen.dart` | MODIFIED | **R2-05:** Split `_continue()` into `_completeAndReturn()` (auto-completes on choice answer, shows XP snackbar, auto-pops after 3s) and `_continue()` (replay-only manual pop). "Continue the Journey" button removed for first-time play — event auto-completes when choice is answered. Button only shows on replays as "Back to Events". **R2-06:** Added `PopScope` wrapping Scaffold — on back press, saves `_discovered` set to `PrefsService.saveHotspotProgress()`. On init, loads saved progress and advances path position to match. Cleared on completion via `clearHotspotProgress()`. |
| `lib/services/prefs_service.dart` | MODIFIED | **R2-06:** Added `saveHotspotProgress()`, `loadHotspotProgress()`, `clearHotspotProgress()` — persists discovered hotspot IDs per event as StringList. |
| `lib/screens/event_list_screen.dart` | MODIFIED | **R2-10:** Split `_openEvent()` — immersive events (with scene config) get cinematic transition → fly down. Flat events (no scene config) get direct fade transition, no cinematic. |

### Flow Change
```
BEFORE:
  Choice answered → "Continue the Journey" button → tap → pop (stale)
  → tap Play again → cinematic → "Witnessed" → tap → finally updates

AFTER:
  Choice answered → auto-complete + XP snackbar → 3s delay (read explanation)
  → auto-pop to event list (instantly updated, next event highlighted)
```

### Quality
- `flutter analyze` — zero errors/warnings

---

## Sprint 18 — Scene Animations + Hotspot Visibility (R2-02, R2-08, R2-09)
**Date:** 2026-04-02
**Status:** COMPLETE
**Fixes:** R2-02, R2-08, R2-09

### Built
| File | Type | Details |
|------|------|---------|
| `lib/widgets/cinematic/scene_hotspot_marker.dart` | MODIFIED | **R2-08:** Locked opacity 0.35→0.6. Border alpha 50→80. Added subtle glow BoxShadow for locked state. Icon color white38→white54. Locked hotspots now clearly visible against dark backgrounds. |
| `lib/data/scene_configs.dart` | MODIFIED | **R2-02:** Event 1 particle alpha 0x35→0x80 (20%→50%), count 30→40. **R2-09:** Event 3 particle alpha 0x28→0x70 (16%→44%). Event 2 also boosted 0x30→0x70 for consistency. |
| `lib/widgets/cinematic/particle_painter.dart` | MODIFIED | Fixed alpha calculation — was using `baseColor.a * 255.0` with redundant rounding. Now uses clean `(baseColor.a * 255.0)` multiplication. |

### Quality
- `flutter analyze` — zero errors/warnings

---

## Sprint 19 — Event List Polish + UX (R2-01, R2-03, R2-07)
**Date:** 2026-04-02
**Status:** COMPLETE
**Fixes:** R2-01, R2-03, R2-07

### Built
| File | Type | Details |
|------|------|---------|
| `lib/screens/event_list_screen.dart` | MODIFIED | **R2-01:** Added `◆ X/4` hotspot counter below location text for all events with scenes (reads saved progress from `PrefsService.loadHotspotProgress()`). Completed = green, in-progress = gold, untouched = muted. Play button restyled: gold filled background + glow BoxShadow + dark text (`AppColors.bg`) — stands out as clear CTA. Completed events show green check icon instead of text. **R2-07:** Wrapped in `PopScope` — back button shows bilingual "Exit game?" / "مغادرة اللعبة؟" confirmation dialog. Stay = dismiss, Exit = pop. |
| `lib/screens/immersive_event_screen.dart` | MODIFIED | **R2-03:** Hotspot proximity radius increased from 0.07 to 0.09. Last hotspot triggers more reliably. |

### Quality
- `flutter analyze` — zero errors/warnings

---

## Sprint 20 — "Moment of Reflection" Enhancement (R2-04)
**Date:** 2026-04-02
**Status:** COMPLETE
**Fixes:** R2-04

### Built
| File | Type | Details |
|------|------|---------|
| `assets/audio/vo/vo_event*_q_*.mp3` | NEW (24 files) | Question VO for all 3 events x 4 voice variants. Generated with edge-tts (Syrian Arabic + British English). |
| `assets/audio/vo/vo_event*_exp_*.mp3` | NEW (included above) | Explanation/history records VO for all 3 events x 4 variants. |
| `lib/screens/immersive_event_screen.dart` | MODIFIED | **VO:** Added `_choiceVoPath()` and `_playChoiceVo()` helpers. Question VO plays 500ms after choice phase starts. Explanation VO plays on answer selection. **Tutorial:** Added `_showChoiceTutorial` state. On first choice phase (`!isChoiceTutorialSeen`), shows dark overlay with: help icon, "A Moment of Reflection" title, explanation text ("You have witnessed the events. Now choose what you would do — then discover what history records."), tap to dismiss. Persists via `choiceTutorialSeen` pref. **Intro text:** Changed "A moment arrives." to "What would you do?" (bolder, clearer purpose). |
| `lib/services/prefs_service.dart` | MODIFIED | Added `choiceTutorialSeen` key + getter/setter. |

### Choice Phase Flow (After Fix)
```
All hotspots discovered → companion: "A moment of reflection approaches..."
  → choice tutorial overlay (first time only, tap to dismiss)
  → question text appears + question VO plays
  → user taps an answer → explanation reveals + explanation VO plays
  → 3s delay → event auto-completes + XP snackbar → auto-pop to event list
```

### Asset Count Update
- Choice VO: 24 MP3 files (3 events x 2 types x 4 variants)
- **Total VO files: 72** (48 fragment + 24 choice)
- **Total audio assets: 124** (72 VO + 52 companion)

### Quality
- `flutter analyze` — zero errors/warnings

---

## Sprint 21 — Branching System: Data Models + Safety Net
**Date:** 2026-04-02
**Status:** COMPLETE

### Built
| File | Type | Details |
|------|------|---------|
| `lib/models/branch_point.dart` | NEW | `BranchPoint` (id, prompt EN+AR, optionA, optionB) and `BranchOption` (label EN+AR, targetHotspotId). Pure data models — no UI. |
| `lib/models/journey_event.dart` | MODIFIED | Added 3 optional fields: `anchorHotspotId`, `branchPoint`, `convergenceHotspotId`. Added `isBranching` getter (true when `branchPoint != null`). All fields default to null — backward compatible. Events 4-36 unchanged. |
| `lib/models/scene_config.dart` | MODIFIED | Added `pathWaypointsAlt` (optional alternate walking path for branch Option B). Defaults to null. |
| `lib/screens/immersive_event_screen.dart` | MODIFIED | Added `_isBranching` getter — explicit safety guard for linear vs branching flow. Will be referenced in Sprint 22 scene controller logic. |
| `test/branching_test.dart` | NEW | 5 tests verifying: (1) All Events 4-36 have `isBranching == false`, (2) `isBranching` true only when branchPoint set, (3) `pathWaypointsAlt` null by default, (4) All non-E1/E2/E3 scene configs have no alt paths, (5) BranchPoint model stores all fields. **All 5 passed.** |

### Safety Net
```
if (event.branchPoint == null) → linear flow (Events 4–36 untouched)
if (event.branchPoint != null) → branching flow (Events 1–3 in Sprint 22+)
```
This guard is explicit from Sprint 21, not patched in later.

### Quality
- `flutter analyze` — zero errors, 1 expected warning (_isBranching unused until Sprint 22)
- `flutter test` — **5/5 passed**
- `BUILD SUCCESSFUL`

---

## Sprint 22 — Branching System: Card + Scene Controller
**Date:** 2026-04-02
**Status:** COMPLETE

### Built
| File | Type | Details |
|------|------|---------|
| `lib/widgets/cinematic/branch_decision_card.dart` | NEW | Gold-pulsing bordered card overlay. Shows branch prompt (narrative text) + two tappable option buttons. Animated gold border (1800ms pulse cycle). Slide-in animation. ScrollView for long prompts. Styled to match discovery panel but signals "choice" via animated glow. |
| `lib/screens/immersive_event_screen.dart` | MODIFIED | **State:** Added `_showBranchCard`, `_branchChoice`, `_branchUnlockOrder`. **Dismiss logic:** After anchor hotspot dismissed in branching mode → shows BranchDecisionCard instead of normal flow. **Branch handler:** `_onBranchSelected()` sets unlock order (anchor → chosen → other → convergence), swaps to alt path if Option B, recomputes segment lengths. **Path:** All `_scene.pathWaypoints` references replaced with `_activeWaypoints` getter (returns original or alt based on choice). **Hotspot unlock:** Branching-aware — uses `_branchUnlockOrder` to determine next active hotspot. Before choice: only anchor active. After choice: follows branch order. Linear events: unchanged (uses sequential index). **UI:** BranchDecisionCard rendered in Stack with dark overlay backdrop. |

### Branching Flow (Now Working)
```
Linear event (4+):    walk → hotspot 1 → 2 → 3 → 4 → question  (UNCHANGED)
Branching event (1-3): walk → anchor → BRANCH CARD → chosen → other → convergence → question
                                        ↓                                    
                                   Path A or B selected, waypoints swap
```

### Safety
- `_isBranching` guard prevents branching logic from running on linear events
- All 5 branching safety tests still pass
- Events 4-36 completely untouched

### Quality
- `flutter analyze` — zero errors/warnings
- `flutter test` — **5/5 passed**
- `BUILD SUCCESSFUL`

---

## Sprint 23 — Branching System: Wire All 3 Events
**Date:** 2026-04-02
**Status:** COMPLETE

### Built
| File | Type | Details |
|------|------|---------|
| `lib/data/m1_data.dart` | MODIFIED | Added `BranchPoint` import. Wired branching fields for Events 1-3: anchor, convergence, branchPoint with full bilingual prompts + two options each. Events 4-36 untouched. |
| `lib/data/scene_configs.dart` | MODIFIED | **Convergence fragments:** Added transition lines to poet (E1), birds (E2), cloak (E3) — "Whether you X or Y — you have arrived at the same truth... And the question remains —". **Alt paths:** Added `pathWaypointsAlt` for all 3 events with reordered waypoints matching branch Option B. |
| `assets/audio/vo/` | REGENERATED | 12 convergence VO files regenerated with longer text (poet, birds, cloak x 4 variants). |

### Branching Roles
| Event | Anchor | Branch A | Branch B | Convergence |
|-------|--------|----------|----------|-------------|
| E1 Arabia | Ka'bah | Merchants | Idols | Poet |
| E2 Elephant | Army | Elephants | Muttalib | Birds |
| E3 Black Stone | Flood | Dispute | Al-Amin | Cloak |

### Quality
- `flutter analyze` — zero errors/warnings
- `flutter test` — **5/5 passed** (Events 4-36 confirmed safe)
- `BUILD SUCCESSFUL`

---

## Sprint 24 — Branching System: In-Scene Question + Remove Moment of Reflection
**Date:** 2026-04-02
**Status:** COMPLETE

### Built
| File | Type | Details |
|------|------|---------|
| `lib/screens/immersive_event_screen.dart` | MODIFIED | **New phase:** Added `_Phase.convergenceQuestion` to enum. **Dismiss logic:** After convergence hotspot dismissed in branching mode → transitions to `convergenceQuestion` phase (not `choose`). Linear events unchanged → still use `choose` phase. **In-scene question:** `_buildConvergenceQuestion()` — centered card overlay with dark backdrop. Shows "What would you do?" header, question text (Cinzel), tappable options, "History records..." explanation on answer. Same answer logic as linear (`_selectChoice` → `_completeAndReturn`). **Moment of Reflection eliminated:** `_buildChoiceOverlay` guarded by `!_isBranching` — branching events never see the old overlay. **Dim overlay + hotspot markers** updated to include `convergenceQuestion` phase. |

### Branching Event Flow (Complete)
```
Scene loads → all hotspots visible (locked)
  → walk to ANCHOR (only active hotspot) → discover fragment
  → BRANCH CARD appears (gold-pulsing, two choices)
  → user picks Option A or B → path swaps, next hotspot unlocks
  → walk to CHOSEN hotspot → discover fragment
  → OTHER hotspot unlocks → walk to it → discover fragment
  → CONVERGENCE hotspot unlocks → walk to it → discover fragment
    (includes transition line: "And the question remains —")
  → IN-SCENE QUESTION CARD slides up
    → user taps answer → explanation reveals + VO plays
    → 3s delay → auto-complete + XP → pop to event list
```

### Linear Event Flow (Unchanged — Events 4-36)
```
Scene loads → walk linearly → hotspot 1 → 2 → 3 → 4
  → "Moment of Reflection" overlay → full-screen question
  → answer → explanation → auto-complete → pop
```

### Quality
- `flutter analyze` — zero errors/warnings
- `flutter test` — **5/5 passed**
- `BUILD SUCCESSFUL`

---

## Sprint 26 — Round 3 Fixes (R3-01 through R3-06)
**Date:** 2026-04-02
**Status:** COMPLETE
**Fixes:** All 6 R3 bugs

### Built
| File | Fix |
|------|-----|
| `immersive_event_screen.dart` | **R3-06:** `_selectChoice` now `await`s `completeEvent()` inline — no race. **R3-04:** Proximity guard while branch card showing. |
| `scene_configs.dart` | **R3-04:** All hotspots remapped forward-only: anchor bottom, branches triangle, convergence top. All 6 paths updated. |
| `assets/audio/vo/` (12 new) | **R3-05:** Branch prompt VO for all 3 events x 4 variants. |
| `cinematic_transition_screen.dart` | **R3-03:** Sky gradient bg, gold dust particles, ambient audio fade-in. |
| `registration_screen.dart` | **R3-02:** PopScope (exit dialog page 1, prev page 2-4). **R3-01:** Keyboard dismiss on navigation. |

### Hotspot Layout
```
All events: Anchor(~0.60y) → Branches(~0.42y triangle) → Convergence(~0.28y) — forward only
```

### Quality
- `flutter analyze` — zero errors/warnings
- `flutter test` — **5/5 passed**
- `BUILD SUCCESSFUL`

---

## Sprint 33 — Badge Overlay Redesign + Sequential Completion
**Date:** 2026-04-03
**Status:** COMPLETE

### Built
| File | Type | Details |
|------|------|---------|
| `badge_overlay.dart` | MODIFIED | Full-screen 85% overlay, sequential badge completion flow |
| `immersive_event_screen.dart` | MODIFIED | Wired badge overlay into completion sequence |

---

## Sprint 34 — Audit Fixes (2, 5-10)
**Date:** 2026-04-03
**Status:** COMPLETE

### Built
| File | Type | Details |
|------|------|---------|
| `android/app/build.gradle.kts` | MODIFIED | Signing config for release builds |
| `pubspec.yaml` | MODIFIED | Removed latlong2 dependency |
| Multiple files | MODIFIED | Dead code removal, performance improvements, persistence fixes |

---

## Sprint 35 — Chronological Reorder
**Date:** 2026-04-03
**Status:** COMPLETE

### Built
| File | Type | Details |
|------|------|---------|
| `m1_data.dart` | MODIFIED | Black Stone (605 CE) moved from position 3 to position 8, Ta'if (619 CE) moved to position 17 (after Year of Grief) |

---

## Sprint 38 — RawiDialog, Intro Bilingual, Mandatory Name
**Date:** 2026-04-03
**Status:** COMPLETE

| File | Fix |
|------|-----|
| `rawi_dialog.dart` (NEW) | Reusable gold/navy dialog — replaced all 3 AlertDialogs |
| `intro_cinematic_screen.dart` | Device locale detection for Arabic intro text |
| `registration_screen.dart` | Name mandatory 2-15 chars, Skip removed, device locale for initial lang |

---

## Sprint 39 — Name Personalization, Accessibility, Settings Polish
**Date:** 2026-04-03
**Status:** COMPLETE

| File | Fix |
|------|-----|
| `companion_dialogue.dart` | {name} placeholder in allDone lines, name param in get() |
| `immersive_event_screen.dart` | All bubble calls pass PrefsService.userName |
| `settings_screen.dart` | Name always shown, "Rawi since" date, text scale toggle |
| `prefs_service.dart` | firstLaunchDate, textScale getters/setters |
| `main.dart` | MediaQuery.textScaler override for accessibility |

---

## Sprint 40 — Reward System Rebalance
**Date:** 2026-04-03
**Status:** COMPLETE

| File | Type | Details |
|------|------|---------|
| `badge_definition.dart` | MODIFIED | Rebalanced 7 badges: Seeker@5, Witness@11, Keeper@15, Steadfast@22, Scholar@30, Guardian@36, Rawi@36 |
| `immersive_event_screen.dart` | MODIFIED | Chapter completion screens, layered reward flow (chapter → badge → XP → auto-pop) |
| `prefs_service.dart` | MODIFIED | Badge check integration with chapter completion |

---

## Sprint 41 — Bug Fixes A12-A17 + Rawi/Rawiah Character Identity
**Date:** 2026-04-03
**Status:** COMPLETE

| File | Type | Details |
|------|------|---------|
| `immersive_event_screen.dart` | MODIFIED | Exit fix, save progress fix, idle overlap fix |
| `companion_figure.dart` | MODIFIED | Rawi/Rawiah labels (not "companion"), pose infrastructure |
| `registration_screen.dart` | MODIFIED | Updated registration text for character identity |
| `splash_screen.dart` | MODIFIED | Android 12+ splash fix (v31) |

---

## Sprint 42 — R4 Issues + Ambient Sound Design
**Date:** 2026-04-04
**Status:** COMPLETE

### R4 Issues Fixed

| # | Issue | Fix |
|---|-------|-----|
| R4-01 | Splash font flicker | `GoogleFonts.pendingFonts()` pre-caches Cinzel/Lora/Nunito before splash renders |
| R4-02 | Intro cinematic single-language | Bilingual display (EN Cinzel + AR Lora italic), Skip button removed, onboarding BG music wired |
| R4-03b | Figure auto-movement during branch card | Absolute `_showBranchCard` guard in `_onFrame()`, joystick zeroed + game loop stopped before card shows |
| R4-03b+ | Movement during any overlay | Comprehensive freeze: checks ALL overlay states (activeHotspot, branchCard, settings, badge, chapter, XP, tutorial, non-explore phases) |
| R4-03c | Route line partially invisible | Rewrote `PathRoutePainter` — segments ahead of figure always bright silver with glow, behind faded, current segment split at figure position |
| R4-03d | Hotspot tap bypasses movement | Tap-to-walk: tapping next active hotspot auto-walks figure along path. `_autoWalkTo()` + `_pathProgressForHotspot()`. Locked hotspots ignore tap. |
| R4-03e | Era label low contrast | Navy bg `AppColors.bg.withAlpha(200)`, era color border `withAlpha(120)` |
| R4-03f | Progress dots hard to see | Empty dots now `AppColors.gold.withAlpha(80)` border at 1.5px |
| R4-04 | XP overlay inline (not full-screen) | Verdict/Reflection cards hidden when `_showXpAnimation`, `_showChapterComplete`, or `_showBadgeOverlay` true |
| R4-06 | Settings overlay outdated | Full redesign: centered card, gold/navy, compact toggles, "Paused" header, Resume (gold) + Save & Exit (outlined) |
| R4-10 | "Play" for in-progress events | Checks `loadHotspotProgress()`, shows "Continue"/"أكمل" when progress exists |
| R4-11 | Chapter overlay overlapping Verdict | Same guard as R4-04 + chapter bg opacity increased to 245 (near-opaque) |

### Ambient Sound Design (Infrastructure)

| File | Type | Details |
|------|------|---------|
| `scene_config.dart` | MODIFIED | Added `ambientPath` optional field to `SceneHotspot` |
| `audio_service.dart` | REWRITTEN | Re-enabled `playAmbient()` (removed `return;`), added `loop` param, `fadeAmbientTo()` helper, VO duck adjusted to 0.06/0.18 |
| `immersive_event_screen.dart` | MODIFIED | Hotspot ambient plays on panel open (0.18 vol), fades out on dismiss (800ms). Scene-level ambient loop removed. Comprehensive movement freeze. Auto-walk system. |
| `intro_cinematic_screen.dart` | REWRITTEN | Bilingual display, Skip removed, onboarding music starts on load |
| `registration_screen.dart` | MODIFIED | Onboarding music fades out (2.5s) on "Start the Journey" |
| `settings_overlay.dart` | REWRITTEN | Gold/navy centered card design, compact toggle rows |
| `path_route_painter.dart` | REWRITTEN | Figure-relative rendering: ahead=bright, behind=faded, current=split |
| `event_list_screen.dart` | MODIFIED | Progress dots gold border, Play→Continue for in-progress |
| `main.dart` | MODIFIED | `GoogleFonts.pendingFonts()` pre-cache |
| `pubspec.yaml` | MODIFIED | Added `assets/audio/ambient/` |

### Quality
- `flutter analyze` — 0 errors, 0 warnings (2 info-level)
- `flutter test` — 6/6 passing
- APK builds successfully

---

## Sprint 43 — R5 Sprint A+B (Font, Intro, Cards, XP, Scroll)
**Date:** 2026-04-05
**Status:** COMPLETE

### R5 Issues Fixed (11)
| # | Issue | Fix |
|---|-------|-----|
| R5-01 | App icon wrong | Removed broken self-referencing adaptive icon XML |
| R5-02 | Arabic italic | Explicit `FontStyle.normal` on all Arabic text + Begin button |
| R5-03 | Hindi numerals ٥٧٠ | Global sweep: 6 instances converted to Western Arabic (intro, badges, registration) |
| R5-04 | Typo عالم→العالم | One string fix |
| R5-05 | "THE NARRATOR" line break | Split "You are the Rawi" / "The Narrator" onto two lines with quotes |
| R5-06 | Transition particles freeze | Added continuous `_particleCtrl.repeat()` AnimationController |
| R5-07 | Scroll indicator subtle | 28→36px icon, bounce 6→10, gold border, stronger glow |
| R5-10 | XP overlay too small | 64→96px star, 32→48 XP text, 280→340 width, 12 particles, 18→24 total |
| R5-11 | Event card overflow | Center-aligned Row, removed stray SizedBox |
| R5-14 | Badge persistence | Code verified correct |
| R5-15 | Events 4-8 "0/0" | Checkmark instead of 0/0 for no-config events |

---

## Sprint 44 — R5 Sprint C+D (Registration, Settings, Reset, Badge Placeholder)
**Date:** 2026-04-05
**Status:** COMPLETE

| File | Type | Details |
|------|------|---------|
| `intro_cinematic_screen.dart` | MODIFIED | R5-05b: Arabic narrator duplicate removed |
| `xp_reward_animation.dart` | MODIFIED | R5-11b: Removed fixed 120 height, added `clipBehavior: none` |
| `prefs_service.dart` | MODIFIED | R5-16: `resetJourney()` now sweeps hotspot progress, badges, streak, tutorials, journey pointer |
| `registration_screen.dart` | REWRITTEN | **Part 2: 2-screen redesign.** Screen 1: Identity (name + companion together, scrollable). Screen 2: Language only. Blurred cinematic desert bg (BackdropFilter + dark overlay). Chapter preview killed entirely. |
| `settings_screen.dart` | REWRITTEN | **Part 3: Reorder.** Profile → Journey → Preferences → About → Reset (destructive, last). Audio toggles folded into Preferences. Badges removed. "Made with ♥ in Amman" tagline. |
| `badge_overlay.dart` | MODIFIED | R5-12: Geometric gold placeholder (diamond + rosette + small emoji hint inside navy circle) |

---

## Sprint 45 — R5 Code Review (Root-Cause Arabic Italic Fix + 6 Findings)
**Date:** 2026-04-05
**Status:** COMPLETE

### Key Finding — Arabic Italic Root Cause
Lora has **no Arabic glyphs**. When Arabic renders, Flutter falls back to a system font — but `fontStyle: FontStyle.italic` was still applied to the fallback, making Arabic italic. 14 instances switched to `isAr ? FontStyle.normal : FontStyle.italic` across discovery panel, branch card, verdict/reflection, splash, event list, journey screens. 2 English-only strings intentionally left italic.

### Other Findings
| # | Fix |
|---|-----|
| F2 | Transition particles gated on `_blackOpacity` (was `_cardOpacity`). Hold time 2000→3000ms |
| F3 | XP overlay — star 64→96, text 32→48, width 280→340, total 18→24, particle radius 70→100 |
| F6 | Scroll indicator — bounce 6→10, padding 14/6→18/10, icon 28→36, gold border 1→1.5px |
| F7 | Adaptive icon: `mipmap-anydpi-v26/ic_launcher.xml` with navy_bg background + inset drawable foreground |

---

## Sprint 46 — Sound Integration (8 ElevenLabs Clips)
**Date:** 2026-04-05
**Status:** COMPLETE

| File | Wired Into | Behavior |
|------|-----------|----------|
| `ambient_intro.mp3` | `intro_cinematic_screen` initState | Fade in to 0.22, carries into registration, fades out 2.5s on "Start the Journey" |
| `ambient_transition.mp3` | `cinematic_transition_screen` initState | Fade in to 0.20, fades out on dispose |
| `ambient_crossroads.mp3` | `_dismissPanel()` when branch card shows | Plays at 0.20, stops on option select |
| `ambient_e1_kaabah.mp3` | `SceneHotspot.ambientPath` (Gate) | Plays while panel open |
| `ambient_e1_merchants.mp3` | `SceneHotspot.ambientPath` (Path A) | Plays while panel open |
| `ambient_e1_idols.mp3` | `SceneHotspot.ambientPath` (Path B) | Plays while panel open |
| `sfx_xp.mp3` | `XpRewardAnimation.initState` | One-shot 0.7 vol |
| `sfx_badge.mp3` | `BadgeOverlay.initState` | One-shot 0.7 vol |

Also removed dead scene-level ambient call in cinematic_transition (was reading `config.ambientAudioPath` on every build).

---

## Sprint 47 — Audio Isolation (Strict Window Containment)
**Date:** 2026-04-05
**Status:** COMPLETE

Every ambient now starts and stops within its exact window. No bleeds between screens, hotspots, overlays, or transitions.

### Fade Schedule
| Transition | Fade |
|---|---|
| Hotspot panel dismiss → next hotspot | 200ms |
| Branch option selected | 300ms |
| Reward flow start (`_completeAndPop`) | 300ms |
| Scene back / save&exit / continue | 250ms |
| Scene dispose | 250ms |
| Cinematic transition → scene | 500ms |
| Registration → event list | 2500ms (elegant welcome exit) |

### Exit Points Sealed
- Scene `dispose`, PopScope back press, header back (`_exitScene` new method), `_saveAndExit`, `_continue`, `_completeAndPop`, `_dismissPanel`, `_onBranchSelected`, `CinematicTransition.dispose`, `_resumeFromSettings` (restarts ambient that was playing when settings opened — crossroads OR hotspot).

Race-safe: `fadeOut`'s internal `if (_ambient != player) return;` guard exits the fade loop cleanly if a new `playAmbient` replaces it mid-fade.

---

## Sprint 48 — R6 Testing Round (5 Fixes)
**Date:** 2026-04-05
**Status:** COMPLETE

| # | Issue | Root Cause + Fix |
|---|-------|------------------|
| **R6-01** P0 | Freeze after reset→replay→complete | Nested `Navigator.push` pattern (EventList → CinematicTransition → Immersive) had context lifecycle issues on second playthrough. Also `playAmbient('ambient_desert_evening.wav')` was being called on a non-existent file after every event. **Fix:** `pushReplacement` — CinematicTransition is replaced by Immersive, no nested context. Removed dead ambient call. |
| **R6-02** P0 | App icon still wrong | External `drawable/ic_launcher_foreground.xml` inset approach didn't render on Samsung launchers. **Fix:** Inline `<inset>` inside `<foreground>` of adaptive-icon. Created `ic_launcher_round.xml` variant. Added `android:roundIcon` to manifest. |
| **R6-03** P1 | Duplicate intro CTA screen | "Witness history..." appeared in both `_lines` list AND CTA section. **Fix:** Removed from `_lines`, CTA now uses Cinzel 22px (matching sequence style). |
| **R6-04** P1 | Intro ambient silent on device | `playAmbient` was fire-and-forget before `fadeAmbientTo`. The fade started while `setAsset` was still loading. **Fix:** Extracted into `_startIntroAmbient()` async method that awaits `playAmbient` THEN fades. Same fix applied to cinematic_transition. |
| **R6-05** P1 | Registration bg shifts with keyboard | `resizeToAvoidBottomInset: true` (default) resizing the Stack. **Fix:** Set to `false` + wrapped body in `GestureDetector` with `onTap: unfocus` — tap anywhere outside the text field dismisses keyboard. |

### Quality
- `flutter analyze` — 0 errors, 2 info-level only
- `flutter test` — 6/6 passing
- APK builds cleanly via direct Gradle
