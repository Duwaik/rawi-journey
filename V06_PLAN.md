# Rawi v0.6 — Master Plan
# UX Overhaul + Onboarding + RTL + Edge TTS Voice Over

> Originally finalized 2026-04-01 after brainstorm completion
> Updated 2026-04-01 after full codebase audit
> 19 agreed changes → 5 phases → 13 sprints

---

## Agreed Changes (Complete List)

| # | Item | Source | Category |
|---|------|--------|----------|
| 1 | Disable stars/moon on Event 1 (image is daytime/sunset) | Claude (C1) | Visual |
| 2 | All hotspots use centered card mode (not just Ka'bah) | Claude (C2) | Interactivity |
| 3 | Path route — silver color (not gold), brighter | Claude (C3) + Khaled (K1) | Visual |
| 4 | Figure still small/hard to spot — needs to stand out | Claude (C4) | Visual |
| 5 | "Explore the scene 0/4" overlaps figure at start | Claude (C5) | Bug fix |
| 6 | Event 2 needs bubble images (4 prompts) | Claude (C6) | Content |
| 7 | Progressive hotspot reveal — only NEXT hotspot visible | Khaled (K2) | Interactivity |
| 8 | Diamond-shaped hotspots (rotated square, not circle) | Khaled (K3) | Interactivity |
| 9 | Green tick only AFTER panel dismissed (not on arrival) | Khaled (K4) | Bug fix |
| 10 | Cinematic transition between events | Khaled (K5) | Visual |
| 11 | Interactivity improvements (umbrella for K2-K4 + game feel) | Khaled (final) | Interactivity |
| 12 | Partial RTL — Arabic text flows RTL within existing layouts | Khaled (final) | New capability |
| 13 | Edge TTS Voice Over — free narration using Edge TTS voices | Khaled (final) | New capability |
| 14 | **Full gaming onboarding — splash, intro cinematic, registration (name/gender/language)** | **Khaled (audit)** | **New capability** |
| 15 | **In-game settings overlay — language, music, VO, SFX toggles, save & exit** | **Khaled (audit)** | **New capability** |
| 16 | **App icon — configure adaptive icon from generated image** | **Master plan audit** | **Visual** |
| 17 | **Companion speech bubble system — idle hints, nudges** | **Master plan audit** | **Interactivity** |
| 18 | **Image-based companion in circle (replace CustomPainter bust)** | **Khaled (decision)** | **Visual** |
| 19 | **Pause/resume flow — tap to pause, settings accessible mid-game** | **Khaled (audit)** | **UX** |

---

## Phase 0: Housekeeping ✅ COMPLETE

### Sprint 0.1 — Cleanup & App Icon Setup
**Status:** Cleanup DONE. App icon wiring PENDING.

| Task | Status | Details |
|------|--------|---------|
| Delete dead code | **DONE** | Removed: `journey_map_screen.dart`, `companion_marker.dart`, `hotspot_marker.dart`, `narrative_overlay.dart` |
| Delete legacy assets | **DONE** | Removed: `city_kaabah.jpg`, `foreground_courtyard.jpg`, `mountains_mecca.jpg`, `sky_mecca_dusk.jpg` |
| Delete empty directories | **DONE** | Removed: `assets/panoramas/`, `assets/textures/` |
| Move app icon | **DONE** | Moved `app_icon.jpg` from `assets/scenes/` to `assets/icon/` |
| Configure adaptive Android icon | **TODO** | Resize `assets/icon/app_icon.jpg` → generate `mipmap-*` PNGs. Current mipmaps are still default Flutter blue icon (544 bytes). Need `flutter_launcher_icons` package or manual resize. |
| Update README.md | **TODO** | Still says "deenquest_journey" with boilerplate. Should reflect Rawi branding. |

---

## Phase 1: Full Gaming UX Shell
**Goal:** Build every screen a player expects from a proper mobile game — from first launch to mid-game settings to save & exit. This is not just onboarding; it's the entire app shell that wraps around the gameplay.

**Why:** Right now Rawi has gameplay screens but no gaming UX. No way to pause, no settings, no proper intro, no profile setup. A player opening the app should feel like they launched a polished game, not a tech demo.

### Complete Player Flow (Target)

```
FIRST LAUNCH:
  App opens → Splash Screen (logo, 2s) → Intro Cinematic (story setup)
  → Registration (name → gender → language)
  → Milestone Preview ("Your journey begins...")
  → Hub Screen

RETURNING PLAYER:
  App opens → Splash Screen (logo, 1s) → Hub Screen

DURING GAMEPLAY (Immersive Event):
  Pause button (⚙️ top-right) → Settings Overlay
    ├── Language: English / العربية
    ├── Music: ON / OFF (ambient audio)
    ├── Voice Over: ON / OFF
    ├── Sound Effects: ON / OFF
    ├── Save & Exit → saves progress, returns to Hub
    └── Resume → closes overlay, continues gameplay

FROM HUB:
  Settings button (⚙️ top-right) → Settings Screen (full page)
    ├── Same toggles as above
    ├── Profile: name, gender (re-editable)
    ├── Reset Journey (with confirmation)
    └── About / Credits
```

### Sprint 1.1 — Splash + Intro Cinematic
**Goal:** First impression — cinematic, branded, sets the tone.

| Task | Details | Files |
|------|---------|-------|
| Splash Screen | Navy `#0B1E2D` background. Rawi logo fades in (gold). Arabic بسم الله الرحمن الرحيم fades in below (subtle, reverent). Hold 2s first launch, 1s returning. Auto-navigate. | `lib/screens/splash_screen.dart` (NEW) |
| Intro Cinematic | Only on first launch. Full-screen `scene_welcome.jpg` with dark gradient overlay. Text sequence fades in/out (like game intros): "570 CE... The Arabian Peninsula..." → "A world waiting for a message..." → "You are the Rawi — the narrator" → "Witness history. Carry the story." Gold text, Cinzel font, 800ms fade per line, 2s hold. Skip button (subtle, top-right). Ends with "Begin" CTA. | `lib/screens/intro_cinematic_screen.dart` (NEW) |
| Update main.dart routing | New flow: `splash → (onboardingComplete ? hub : intro)`. Remove old `isWelcomeSeen` logic. | `lib/main.dart` |

**Deliverable:** App launch feels cinematic and intentional — not like a Flutter default.

### Sprint 1.2 — Registration Flow
**Goal:** Collect player profile in a way that feels like character creation, not a form.

| Task | Details | Files |
|------|---------|-------|
| Registration — Step 1: Name | "What shall we call you, traveler?" (EN) / "ما اسمك يا مسافر؟" (AR). Text input with gold underline. Optional — can skip. Stored in `PrefsService.userName`. Cinematic background (dark, particles). | `lib/screens/registration_screen.dart` (NEW) |
| Registration — Step 2: Gender | "Choose your companion" (EN) / "اختر رفيقك" (AR). Two circular image cards side by side: `companion_male.jpg` and `companion_female.jpg` inside gold-bordered circles. Tap to select (gold highlight + scale). Stored in `PrefsService.userGender`. Determines: companion avatar in-game + TTS voice pair. | `lib/screens/registration_screen.dart` |
| Registration — Step 3: Language | "Choose your language" (EN) / "اختر لغتك" (AR). Two cards: 🇬🇧 English / 🇸🇦 العربية. Stored in `PrefsService.language`. Can be changed later in settings. | `lib/screens/registration_screen.dart` |
| Registration — Step 4: Milestone Preview | "Your journey spans four chapters..." Show the 4 milestones with icons, titles, event counts. Only M1 active (gold), M2-M4 locked (muted). "Start the Journey" gold CTA button. Migrate milestone card design from current `welcome_screen.dart`. | `lib/screens/registration_screen.dart` |
| PageView navigation | Steps 1-4 as horizontal PageView with dot indicators. Back arrow on steps 2-4. Smooth page transitions. Progress dots at bottom (gold filled / white empty). | `lib/screens/registration_screen.dart` |
| PrefsService updates | Add keys: `userName` (String), `userGender` (String: 'male'/'female', default 'male'), `onboardingComplete` (bool), `musicEnabled` (bool, default true), `voEnabled` (bool, default true), `sfxEnabled` (bool, default true). | `lib/services/prefs_service.dart` |
| Delete welcome_screen.dart | Fully replaced by splash + intro + registration flow. Absorb milestone preview into registration step 4. | Delete `lib/screens/welcome_screen.dart` |

**Assets already available:**
- `assets/figures/companion_male.jpg` — male companion circular card
- `assets/figures/companion_female.jpg` — female companion circular card
- `assets/scenes/scene_welcome.jpg` — background for intro cinematic

**Deliverable:** First launch → splash → intro cinematic → 4-step registration → hub. Feels like Assassin's Creed / Monument Valley first-launch flow.

### Sprint 1.3 — Settings Overlay + Settings Screen
**Goal:** Player can control their experience anytime — during gameplay or from hub.

| Task | Details | Files |
|------|---------|-------|
| In-Game Settings Overlay | Semi-transparent dark overlay (80% opacity). Appears when ⚙️ tapped during immersive event. Pauses game loop + ambient audio. Contains toggle rows (see below). "Resume" button at bottom. Gold accent, Nunito font. Slide-down animation (300ms). | `lib/widgets/settings_overlay.dart` (NEW) |
| Hub Settings Screen | Full-page settings accessible from ⚙️ on hub top bar. Same toggles + additional: Profile section (edit name, gender), Reset Journey (with "Are you sure?" dialog), About/Credits. Back arrow returns to hub. | `lib/screens/settings_screen.dart` (NEW) |
| Toggle: Language | Switch between English / العربية. Immediately applies to all visible text. Persists via `PrefsService.language`. | Both settings widgets |
| Toggle: Music (Ambient) | ON/OFF. Controls `AudioService` ambient layer. When OFF, `AudioService.stopAmbient()` and skip `playAmbient()` calls. Persists via `PrefsService.musicEnabled`. | Both settings widgets, `audio_service.dart` |
| Toggle: Voice Over | ON/OFF. Controls VO playback in discovery panels (Phase 5). For now, toggle exists but VO not yet implemented — just persists the preference. Persists via `PrefsService.voEnabled`. | Both settings widgets |
| Toggle: Sound Effects | ON/OFF. Controls SFX on hotspot discovery. When OFF, skip `playSfx()` calls. Persists via `PrefsService.sfxEnabled`. | Both settings widgets, `audio_service.dart` |
| Save & Exit (overlay only) | Saves current `_pathProgress` and `_discovered` set to PrefsService. Returns to hub via `Navigator.popUntil(isFirst)`. | `immersive_event_screen.dart` |
| Pause/Resume game state | When overlay opens: pause `_gameLoop` AnimationController, duck/mute audio. When overlay closes: resume game loop, restore audio. | `immersive_event_screen.dart` |
| Wire ⚙️ button into hub | Add settings gear icon to hub top bar (right side, next to XP display). Navigates to `SettingsScreen`. | `aerial_hub_screen.dart` |
| Wire ⚙️ button into immersive | Add settings gear icon to immersive event top area (top-right, subtle). Opens `SettingsOverlay`. | `immersive_event_screen.dart` |
| AudioService respects prefs | `playAmbient()` checks `PrefsService.musicEnabled` before playing. `playSfx()` checks `PrefsService.sfxEnabled`. Future `playVoiceover()` will check `PrefsService.voEnabled`. | `audio_service.dart` |

**Toggle Row Design:**
```
┌──────────────────────────────────────┐
│  🔊  Music                    [ON]  │  ← gold toggle when ON, muted when OFF
│  🎙️  Voice Over               [ON]  │
│  🔔  Sound Effects             [ON]  │
│  🌐  Language              English ▸ │  ← tappable, cycles EN/AR
├──────────────────────────────────────┤
│         [ Save & Exit ]              │  ← only in overlay, not hub settings
│         [ Resume ▶ ]                 │  ← only in overlay
└──────────────────────────────────────┘
```

**Deliverable:** Full settings system — accessible from hub and mid-gameplay. Player never feels trapped or unable to control their experience.

### Sprint 1.4 — Image-Based Companion
**Goal:** Replace CustomPainter companion with image-based circular avatar.

| Task | Details | Files |
|------|---------|-------|
| Rewrite companion_figure.dart | Replace CustomPainter bust with circular clipped image. Load `companion_male.jpg` or `companion_female.jpg` based on `PrefsService.userGender`. Gold circle border (2px). Size: ~60px diameter in scene. Keep walking bob + breathing animations (apply to the circle container, not paint). Keep golden aura glow (apply as BoxShadow or BackdropFilter around circle). Keep "You"/"أنت" label below. | `lib/widgets/cinematic/companion_figure.dart` (REWRITE) |
| Facing direction | When companion moves left, no flip needed (image stays upright). Remove `facingDirection` flip logic — circular avatar looks the same either way. | `companion_figure.dart` |
| Gender reactivity | If user changes gender in settings, companion updates on next event load. No need for hot-reload mid-scene. | `companion_figure.dart`, `settings_screen.dart` |

**Assets:**
- `assets/figures/companion_male.jpg` (121KB)
- `assets/figures/companion_female.jpg` (104KB)

**Deliverable:** Companion is a clean circular avatar that matches the selected gender. Feels polished, not hand-drawn.

---

## Phase 2: Visual & Interaction Overhaul
**Goal:** Transform the game feel of Events 1-2 without adding new content.
**Scope:** All brainstorm items that touch existing code.

### Sprint 2.1 — Hotspot System Overhaul
**Goal:** Completely rework hotspot mechanics for better game feel.

| Task | Details | Files |
|------|---------|-------|
| Diamond-shaped hotspots (K3) | Replace 40px circle with rotated square (diamond). Keep 60px pulse ring but diamond-shaped. Emoji icon centered inside diamond. Dark pill label below. | `scene_hotspot_marker.dart` |
| Progressive hotspot reveal (K2) | Only the NEXT undiscovered hotspot shows animated diamond + pulse. Others: hidden (not yet reached) or dimmed with green tick (completed). Sequential guidance — complete hotspot 1 to reveal hotspot 2. | `immersive_event_screen.dart`, `scene_hotspot_marker.dart` |
| Green tick after dismiss (K4) | Bug fix: currently green tick appears when companion REACHES hotspot. Must only appear AFTER user taps to dismiss the panel. | `immersive_event_screen.dart` |
| All hotspots → centered card (C2) | Ka'bah centered card was clearly superior. Apply centered card mode to ALL hotspots (remove `centerMode` flag, make it the default). | `discovery_panel.dart`, `scene_configs.dart` |

**Deliverable:** Rebuilt hotspot system — diamond shape, progressive reveal, correct tick timing, centered cards everywhere.

### Sprint 2.2 — Scene & Figure Polish
**Goal:** Fix visual issues flagged during v0.5.3 testing.

| Task | Details | Files |
|------|---------|-------|
| Disable stars/moon on Event 1 (C1) | Event 1 image is daytime/sunset. Stars + crescent moon clash. Set `showStars: false`, `showMoon: false` in Event 1 SceneConfig. | `scene_configs.dart` |
| Figure more visible (C4) | Options: (a) larger bust, (b) stronger gold outline/glow, (c) contrasting colors against desert. Test on device. Gender-aware after Sprint 1.0. | `companion_figure.dart` |
| Fix progress/figure overlap (C5) | "Explore the scene 0/4" text overlaps companion at start position (0.50, 0.80). Reposition text higher or offset when figure is near bottom. | `discovery_progress.dart`, `immersive_event_screen.dart` |
| Path route silver color (C3/K1) | Replace gold dots with silver `Color(0xFFB8C4CC)`. Must contrast with gold hotspots AND desert tones. **Decision LOCKED: silver.** | `path_route_painter.dart` |

**Deliverable:** Cleaner Event 1 atmosphere, visible companion, no overlap, distinct path.

### Sprint 2.3 — Cinematic Transitions
**Goal:** Replace plain event-to-event transition with cinematic feel.

| Task | Details | Files |
|------|---------|-------|
| Cinematic event transition (K5) | **Decision LOCKED: fade-to-black + title card.** Flow: scene dims → fade to black (400ms) → title card with year + location + event title (hold 2s) → fade into new scene (600ms). Industry standard (Assassin's Creed pattern). | `fly_transition.dart` (rewrite or new file), `immersive_event_screen.dart` |

**Deliverable:** Polished transition that feels cinematic, not jarring.

### Sprint 2.4 — Companion Speech Bubble System
**Goal:** Make the companion figure interactive — contextual hints, navigation guidance, gentle encouragement.

| Task | Details | Files |
|------|---------|-------|
| `CompanionSpeechBubble` widget | Small gold-bordered pill above companion figure. Nunito 10px. Fade in (400ms) → hold 3s → fade out (400ms). No tap required to dismiss. | `lib/widgets/cinematic/companion_speech_bubble.dart` (NEW) |
| Idle timeout trigger | If player does nothing for ~10 seconds, companion shows contextual hint. Hints vary by game state (no hotspots done, near a hotspot, between hotspots, all done). | `immersive_event_screen.dart` |
| Post-discovery nudge | After dismissing a panel, companion briefly says "Onward..." / "There is more to witness" pointing toward next active hotspot. Shows for 3s. | `immersive_event_screen.dart` |
| Revisit limiter | Track visit count per hotspot. 1st-2nd revisit: silent. 3rd: "You've witnessed this. The path ahead holds more...". 4th+: "The journey awaits, companion." | `immersive_event_screen.dart` |
| Pre-scripted dialogue bank | `Map<String, List<String>>` per trigger type x 2 languages. ~30 lines EN + 30 lines AR. All hardcoded in Dart. | `lib/data/companion_dialogue.dart` (NEW) |

**Trigger table:**

| Trigger | When | Example EN | Example AR |
|---------|------|-----------|-----------|
| Idle (no hotspot done) | 10s no input | "The path awaits... try the joystick" | "الطريق ينتظر... جرّب عصا التحكم" |
| Idle (near hotspot) | 10s near undiscovered hotspot | "Something glows nearby..." | "شيء يتوهج بالقرب..." |
| Idle (mid-journey) | 10s, 1+ hotspots done | "The journey continues forward" | "الرحلة تستمر للأمام" |
| Post-discovery | After panel dismissed | "Onward..." / "There is more to witness" | "هيا..." / "هناك المزيد لتشهده" |
| Revisit 3rd time | Tap completed hotspot 3rd time | "You've witnessed this. The path ahead holds more..." | "شهدت هذا. الطريق أمامك يحمل المزيد..." |
| Revisit 4th+ | Tap completed hotspot 4th+ time | "The journey awaits, companion" | "الرحلة بانتظارك يا رفيق" |
| All hotspots done | 4/4 complete, before choice | "A moment of reflection approaches..." | "لحظة تأمل تقترب..." |

**Implementation:** Pure state machine — zero AI, zero network, zero latency. Counters + timers in screen state.

---

## Phase 3: Content Expansion (Events 2-3)
**Goal:** Complete Event 2 visuals. Build Event 3 as the third playable immersive event.
**Dependency:** All images already generated by Khaled. ✅

### Sprint 3.1 — Event 2 Bubble Images + Event 3 Full Build
**Goal:** Wire remaining images and build Event 3 from scratch.

| Task | Details | Files |
|------|---------|-------|
| Wire Event 2 bubble images | Add `imagePath` to Event 2 SceneHotspot configs (army, muttalib, elephants, birds). All use centered card mode (from Sprint 2.1). | `scene_configs.dart` |
| Design Event 3 scene config | Atmosphere: dawn sky gradient, NO stars, NO moon, dust particles (construction site), film grain. Single parallax layer (scene image). | `scene_configs.dart` |
| Define 4 hotspots | flood (0.25, 0.58), dispute (0.50, 0.45), alamin (0.72, 0.50), cloak (0.55, 0.35). Icons, labels (EN+AR), SFX paths, imagePaths. | `scene_configs.dart` |
| Write Event 3 fragments | 4 hotspot fragments (EN+AR) — already written in this plan, transfer to code. | `scene_configs.dart` |
| Design path waypoints | 10 waypoints per plan: Start (0.50, 0.80) → flood → dispute → alamin → cloak. | `scene_configs.dart` |
| Generate 4 SFX audio files | Python script: `sfx_flood_rubble.wav`, `sfx_dispute_crowd.wav`, `sfx_dawn_wind.wav`, `sfx_cloak_fabric.wav`. Each 8s, 22050Hz mono WAV. | `assets/audio/` |
| Test all 12 hotspots (E1+E2+E3) | Verify centered cards, bubble images, diamond shape, progressive reveal all work across all 3 events. | Testing only |

**All images available:** ✅
- `assets/scenes/scene_event3_blackstone.jpg`
- `assets/scenes/bubble_flood.jpg`, `bubble_dispute.jpg`, `bubble_alamin.jpg`, `bubble_cloak.jpg`
- `assets/scenes/bubble_army.jpg`, `bubble_muttalib.jpg`, `bubble_elephants.jpg`, `bubble_birds.jpg`

**Event 3 — Fragments (EN):**

1. **The Flood Damage:** "The rains came without warning — a torrent that swept through the valley and struck the ancient house. Walls crumbled. Stones shifted. The Ka'bah, already weakened by centuries, could no longer stand as it was. The tribes of Quraysh agreed: it must be rebuilt. You watch as men carry stones from the valley, stacking them carefully. The work is slow but united — for now."

2. **The Dispute:** "The walls are nearly done. But one task remains — placing the Black Stone back in its sacred corner. And with it comes a crisis. Every tribe claims the right. You see hands gripping sword hilts. Voices rise. Four days of argument, and still no resolution. The sanctuary, meant for peace, trembles on the edge of bloodshed."

3. **Al-Amin Enters:** "At dawn, the gate of the sanctuary opens. The first man to enter is Muhammad ﷺ — thirty-five years old, known to every tribe yet belonging to no faction. A murmur passes through the crowd: 'Al-Amin.' The Trustworthy. No one objects. They have already placed their trust in him — long before prophethood."

4. **The Wise Solution:** "He asks for a cloak. He spreads it on the ground and places the Black Stone upon it. Then he invites the leader of each tribe to take hold of a corner. Together, they lift. Together, they carry it to its place. He sets the Stone with his own hands. No tribe was denied. No blood was shed. Wisdom — before revelation."

**Event 3 — Fragments (AR):**

1. **أضرار السيل:** "جاءت الأمطار دون سابق إنذار — سيل جارف اجتاح الوادي وضرب البيت العتيق. انهارت الجدران. تزحزحت الحجارة. الكعبة، المتهالكة بفعل القرون، لم تعد تحتمل. اتفقت قبائل قريش: يجب إعادة البناء. تراقب الرجال يحملون الحجارة من الوادي، يرصّونها بعناية. العمل بطيء لكنه موحّد — في الوقت الحالي."

2. **النزاع:** "الجدران شبه مكتملة. لكن مهمة واحدة بقيت — إعادة الحجر الأسود إلى ركنه المقدس. ومعها جاءت الأزمة. كل قبيلة تطالب بالحق. ترى الأيدي تقبض على مقابض السيوف. الأصوات تعلو. أربعة أيام من الخلاف، ولا حل. الحرم، المخصص للسلام، يرتجف على حافة سفك الدماء."

3. **دخول الأمين:** "عند الفجر، يُفتح باب الحرم. أول من يدخل هو محمد ﷺ — في الخامسة والثلاثين، تعرفه كل القبائل لكنه لا ينتمي لأي فريق. همسة تسري في الجمع: 'الأمين.' لا أحد يعترض. لقد ائتمنوه — قبل النبوة بسنين."

4. **الحل الحكيم:** "يطلب رداءً. يبسطه على الأرض ويضع الحجر الأسود فوقه. ثم يدعو زعيم كل قبيلة ليمسك بطرف. معاً يرفعون. معاً يحملونه إلى مكانه. يضع الحجر بيديه الشريفتين. لم تُحرم قبيلة. لم يُسفك دم. حكمة — قبل الوحي."

**Event 3 — Sky Gradient (Dawn):**
```dart
skyGradientStops: [
  (0.0, Color(0xFF0A0C1A)),   // deep night at top
  (0.15, Color(0xFF141830)),  // dark blue
  (0.30, Color(0xFF1E2040)),  // indigo
  (0.45, Color(0xFF3A2848)),  // purple transition
  (0.55, Color(0xFF6A3840)),  // warm mauve
  (0.65, Color(0xFF9A5038)),  // terracotta
  (0.75, Color(0xFFC87840)),  // amber
  (0.85, Color(0xFFE8A050)),  // warm gold
  (1.0, Color(0xFFF0C070)),   // pale gold at horizon
],
```

**Event 3 — Hotspot Design:**

| # | ID | Position (x, y) | Icon | Label EN | Label AR | SFX |
|---|-----|-----------------|------|----------|----------|-----|
| 1 | flood | (0.25, 0.58) | 🌊 | The Flood Damage | أضرار السيل | `sfx_flood_rubble.wav` |
| 2 | dispute | (0.50, 0.45) | ⚔️ | The Dispute | النزاع | `sfx_dispute_crowd.wav` |
| 3 | alamin | (0.72, 0.50) | ⭐ | Al-Amin Enters | دخول الأمين | `sfx_dawn_wind.wav` |
| 4 | cloak | (0.55, 0.35) | 📿 | The Wise Solution | الحل الحكيم | `sfx_cloak_fabric.wav` |

**Event 3 — Path Waypoints (10 points):**
```
Start (0.50, 0.80) → (0.38, 0.70) → flood (0.25, 0.58) → (0.35, 0.52) →
dispute (0.50, 0.45) → (0.60, 0.48) → alamin (0.72, 0.50) → (0.65, 0.42) →
(0.58, 0.38) → cloak (0.55, 0.35)
```

---

## Phase 4: Partial RTL
**Goal:** Arabic text renders right-to-left within existing layouts. UI structure stays LTR.

### Sprint 4.1 — RTL Text Layout
**Goal:** All user-facing text respects Arabic directionality.

| Task | Current Status | Details | Files |
|------|---------------|---------|-------|
| Discovery panel RTL | **DONE** | Fragment text, hotspot label, "Tap to continue" — already use `TextDirection.rtl` when Arabic. | `discovery_panel.dart` |
| Choice phase RTL (immersive) | **DONE** | Question text + option cards already use RTL for Arabic. | `immersive_event_screen.dart` |
| Choice phase RTL (flat event) | **DONE** | `journey_event_screen.dart` already has RTL on narrative, questions, explanations. | `journey_event_screen.dart` |
| Hub screen RTL | **TODO** | Event title/subtitle in bottom card — zero RTL. Era chip text — no RTL. | `aerial_hub_screen.dart` |
| Welcome/Onboarding RTL | **TODO** | All text blocks need RTL for Arabic. (Will apply to new onboarding screen from Phase 1.) | `onboarding_screen.dart` |
| Progress text RTL | **TODO** | "Explore the scene" text direction needs to match language. | `discovery_progress.dart` |
| Companion label RTL | **TODO** | "You"/"أنت" label needs RTL when Arabic. | `companion_figure.dart` |
| Era complete screen RTL | **TODO** | Chapter complete message, next era name, buttons — no RTL. | `era_complete_screen.dart` |

**Note:** This is "partial" RTL — text direction changes per language, but screen layouts (joystick position, hotspot positions, path direction) remain the same. Full RTL mirroring is not needed.

### Sprint 4.2 — RTL Testing & Polish
**Goal:** Verify all Arabic text looks correct across all screens.

| Task | Details |
|------|---------|
| Test Event 1 in Arabic | Toggle language, play through Event 1 fully in Arabic. Check all panels, choice phase, progress. |
| Test Event 2 in Arabic | Same — full playthrough in Arabic. |
| Test Event 3 in Arabic | Same — when Event 3 is built. |
| Test hub in Arabic | Hub screen, onboarding screen, era chip, event card. |
| Fix overflow/alignment | Arabic text is often wider than English — check for overflow in cards and panels. |

---

## Phase 5: Edge TTS Voice Over
**Goal:** Add narration to discovery panels using Microsoft Edge TTS (free, high-quality voices).

### Sprint 5.1 — TTS Infrastructure & Generation
**Goal:** Set up the pipeline and generate audio for Events 1-3.

| Task | Details | Files |
|------|---------|-------|
| Create Python generation script | Script that takes fragment text → generates MP3 via `edge-tts`. Gender-aware voice selection from PrefsService. | `tools/generate_vo.py` (NEW) |
| Generate Event 1 VO | 4 fragments x 2 languages x 2 genders = 16 audio files. | `assets/audio/vo/` |
| Generate Event 2 VO | 4 fragments x 2 languages x 2 genders = 16 audio files. | `assets/audio/vo/` |
| Generate Event 3 VO | 4 fragments x 2 languages x 2 genders = 16 audio files. | `assets/audio/vo/` |
| Generate companion speech VO | ~30 lines x 2 languages x 2 genders = ~120 short clips (~500KB total). | `assets/audio/companion/` |
| Add VO layer to AudioService | New method: `AudioService.playVoiceover(path, volume)`. Separate AudioPlayer instance (Layer 2). Doesn't interrupt ambient (Layer 1) or SFX (Layer 3). | `audio_service.dart` |
| Wire VO into discovery panel | When panel opens → start VO playback. When panel dismissed → stop VO. | `discovery_panel.dart`, `immersive_event_screen.dart` |

**VO Voice Spec (Gender-Aware) — LOCKED:**

| Player Gender | Arabic Voice | English Voice |
|---------------|-------------|---------------|
| Male | `ar-JO-TaimNeural` (Jordanian) | `en-GB-RyanNeural` (British) |
| Female | `ar-JO-SanaNeural` (Jordanian) | `en-GB-SoniaNeural` (British) |

Logic: `PrefsService.userGender` → selects voice pair. No `ar-PS` exists in Edge TTS; Jordanian is closest to Palestinian dialect.

**VO File Naming Convention:**
```
assets/audio/vo/
├── vo_event1_kaabah_en_m.mp3
├── vo_event1_kaabah_en_f.mp3
├── vo_event1_kaabah_ar_m.mp3
├── vo_event1_kaabah_ar_f.mp3
├── ... (16 files per event x 3 events = 48 files total)

assets/audio/companion/
├── comp_idle_01_en_m.mp3
├── comp_idle_01_en_f.mp3
├── comp_idle_01_ar_m.mp3
├── comp_idle_01_ar_f.mp3
├── ... (~120 files total)
```

### Sprint 5.2 — VO Polish & Controls
**Goal:** Fine-tune the voice over experience.

| Task | Details | Files |
|------|---------|-------|
| Volume balancing | Ambient: 0.15 (ducked from 0.25 during VO) → SFX: 0.3 → VO: 0.7. Duck ambient when VO plays, restore when VO ends. | `audio_service.dart` |
| VO mute toggle | Small speaker icon in top bar during events. Tap to mute/unmute VO. Persist preference in SharedPreferences. | `immersive_event_screen.dart`, `prefs_service.dart` |
| VO + panel timing | VO starts 300ms after panel slides up (let visual settle first). If user dismisses panel before VO finishes, fade VO out over 500ms. | `discovery_panel.dart` |
| Re-tap VO | When user re-taps a completed hotspot to re-read, VO replays too. | `immersive_event_screen.dart` |
| Device testing | Test on Samsung A56: audio quality, volume levels, timing, no stuttering. | Testing only |

---

## Sprint Execution Order

```
Phase 0 ─── Sprint 0.1 (Cleanup + app icon)          ✅ CLEANUP DONE, icon wiring TODO

Phase 1 ─── Sprint 1.1 (Splash + intro cinematic)    ← START HERE
         ├── Sprint 1.2 (Registration flow)           ← profile, gender, language
         ├── Sprint 1.3 (Settings overlay + screen)   ← pause, toggles, save & exit
         └── Sprint 1.4 (Image-based companion)       ← circular avatar from JPG

Phase 2 ─── Sprint 2.1 (Hotspot overhaul)            ← core game feel
         ├── Sprint 2.2 (Scene & figure polish)       ← can overlap with 2.1
         ├── Sprint 2.3 (Cinematic transitions)
         └── Sprint 2.4 (Companion speech bubbles)

Phase 3 ─── Sprint 3.1 (Event 2 bubbles + Event 3)   ← all images ready

Phase 4 ─── Sprint 4.1 (RTL text layout)
         └── Sprint 4.2 (RTL testing)

Phase 5 ─── Sprint 5.1 (TTS infra + generation)
         └── Sprint 5.2 (VO polish & controls)
```

**Critical path:** Phase 1 must come first — settings overlay provides the music/VO/SFX toggles that Phase 5 wires up. Registration provides the gender that Phase 5 uses for voice selection. Everything else builds on this shell.

**Parallelism:** Sprints 1.1 + 1.4 can be built in parallel (no dependency). Sprint 1.3 depends on 1.2 (needs PrefsService keys). Phase 2 can start as soon as Phase 1 is done.

---

## Decisions — LOCKED

| # | Decision | Choice | Spec |
|---|----------|--------|------|
| 1 | Path route color | **Silver** | `Color(0xFFB8C4CC)` — contrasts desert tones, distinct from gold hotspots |
| 2 | Transition style | **Fade-to-black + title card** | Flow: scene dims → fade to black (400ms) → title card with year + location + event title (hold 2s) → fade into new scene (600ms) |
| 3 | Edge TTS voices | **Jordanian + Gender-aware** | Male: `ar-JO-TaimNeural` / `en-GB-RyanNeural`. Female: `ar-JO-SanaNeural` / `en-GB-SoniaNeural` |
| 4 | App icon | **Concept C — Bilingual Wordmark** | راوي / RAWI / WITNESS HISTORY, navy+gold, ornamental frame |

---

## Decisions — LOCKED (Latest)

| # | Decision | Khaled's Choice | Date |
|---|----------|-----------------|------|
| 5 | Companion figure style | **Image-based in circle** (not CustomPainter) | 2026-04-01 |
| 6 | App package name | **`com.rawi.journey`** (covers all volumes, not just Seerah) | 2026-04-01 |
| 7 | Name field in registration | **Optional** (can skip) | 2026-04-01 |

---

## Image Prompts — Event 2 Bubbles (for reference)

> All 9 images have been generated. ✅ Prompts preserved here for documentation.

### Event 2 — Bubble Images (570 CE, Year of the Elephant)

**1. `bubble_army.jpg` — Abraha's Army** ✅
```
Digital painting, cinematic, Islamic historical art. Abraha's army marching through Arabian desert, 570 CE. Yemeni and Abyssinian soldiers in simple tunics and leather armor, carrying spears and round shields. Long column of troops stretching into dusty horizon. Barren desert hills, harsh sunlight, dust clouds rising from marching feet. Soldiers seen from distance and behind, no faces visible. No medieval European armor, no castles, no horses, no modern elements.
```

**2. `bubble_muttalib.jpg` — Abd al-Muttalib** ✅
```
Digital painting, cinematic, Islamic historical art. Elderly Arab tribal chief standing alone on rocky hillside overlooking Meccan valley, 570 CE. Seen from behind only. White flowing robes and turban, dignified upright posture, hands clasped behind back. Warm golden sunset light casting long shadow. Simple pre-Islamic Arabian landscape with rocky terrain and dry valley below. No face visible. No modern buildings, no minarets, no marble, no domes.
```

**3. `bubble_elephants.jpg` — The Elephants Refuse** ✅
```
Digital painting, cinematic, Islamic historical art. War elephants kneeling and refusing to advance on desert sand, 570 CE. Large African elephants with simple wooden platforms on their backs, legs folded beneath them. Riders seen as distant silhouettes striking the beasts in frustration. Rocky desert terrain, dramatic dusty sky, sacred boundary ahead. No ornate Indian-style elephant decorations, no buildings, no modern elements, no faces visible.
```

**4. `bubble_birds.jpg` — The Sky Darkens (Ababil)** ✅
```
Digital painting, cinematic, dramatic divine scene. Vast swarm of birds filling the sky over Arabian desert, 570 CE. Thousands of birds resembling hawks or swallows, each carrying small stones, seen from below. Sky darkening with dense bird silhouettes against warm amber sunset. Desert landscape far below. Atmosphere of awe and divine intervention. No modern elements, no buildings, no faces. No fantasy or mythological style — historical and reverent.
```

### Event 3 — All Images ✅

**5. `scene_event3_blackstone.jpg`** ✅ — Reconstruction at Dawn (7:4 horizontal)
**6. `bubble_flood.jpg`** ✅ — Workers rebuilding stone walls
**7. `bubble_dispute.jpg`** ✅ — Tribal groups arguing
**8. `bubble_alamin.jpg`** ✅ — Crowd reacting to golden dawn light
**9. `bubble_cloak.jpg`** ✅ — Tribal leaders lifting white cloak together

---

## Summary

| Phase | Sprints | What Khaled Does | What Claude Builds |
|-------|---------|------------------|--------------------|
| **Phase 0** | 0.1 | ✅ Icon generated | ✅ Cleanup done. TODO: wire icon into Android mipmaps |
| **Phase 1** | 1.1-1.4 | Tests on device | Splash, intro cinematic, registration, settings overlay/screen, image companion |
| **Phase 2** | 2.1-2.4 | Tests on device | Hotspot overhaul, figure polish, transitions, speech bubbles |
| **Phase 3** | 3.1 | — | Event 2 bubble wiring, Event 3 full build, SFX generation |
| **Phase 4** | 4.1-4.2 | Tests Arabic on Samsung A56 | RTL text layout across all screens |
| **Phase 5** | 5.1-5.2 | Tests VO quality on device | TTS pipeline, VO integration, audio layering |

**Total images needed: 0** (all 10 generated ✅)
**Total new audio files Claude generates: ~172** (4 SFX + 48 VO + ~120 companion speech)

---

## Current File Structure (Post-Cleanup)

```
d:\Rawi_Journey\lib\
├── main.dart                              # App entry — Rawi brand
├── app_colors.dart                        # Style C palette
├── transitions.dart                       # Page transitions
├── models\
│   ├── journey_event.dart                 # JourneyEra, JourneyQuestion, JourneyEvent
│   └── scene_config.dart                  # SceneConfig, SceneHotspot, ParticleType
├── data\
│   ├── m1_data.dart                       # 36 events (target: 47)
│   └── scene_configs.dart                 # 2 scene configs (E1, E2). E3 in Phase 3
├── services\
│   ├── audio_service.dart                 # Ambient (L1) + SFX (L3). VO (L2) in Phase 5
│   └── prefs_service.dart                 # Lang, XP, streak, progression. Gender in Phase 1
├── screens\
│   ├── splash_screen.dart                 # NEW Phase 1 — logo splash (2s first, 1s return)
│   ├── intro_cinematic_screen.dart        # NEW Phase 1 — first-launch story intro
│   ├── registration_screen.dart           # NEW Phase 1 — name/gender/language/milestone (PageView)
│   ├── settings_screen.dart               # NEW Phase 1 — full settings page (from hub)
│   ├── welcome_screen.dart                # TO DELETE — replaced by splash + intro + registration
│   ├── aerial_hub_screen.dart             # Main hub — parallax scene + event cards + ⚙️
│   ├── immersive_event_screen.dart        # Full-screen cinematic + ⚙️ pause overlay
│   ├── journey_event_screen.dart          # Flat fallback for events without scene config
│   ├── journey_quiz_screen.dart           # Standalone quiz (kept for future use)
│   └── era_complete_screen.dart           # Era celebration screen
└── widgets\
    ├── settings_overlay.dart              # NEW Phase 1 — in-game pause/settings overlay
    └── cinematic\
    ├── birds_overlay.dart                 # Animated bird swarm (Event 2)
    ├── companion_figure.dart              # Companion bust (CustomPainter)
    ├── crescent_moon.dart                 # Crescent moon with glow
    ├── discovery_panel.dart               # Hotspot fragment panel (bottom or centered card)
    ├── discovery_progress.dart            # "Explore · X/Y" progress dots
    ├── fly_transition.dart                # Zoom+fade transition (to be replaced in Phase 2)
    ├── grain_overlay.dart                 # Film grain noise
    ├── parallax_scene.dart                # Parallax layered scene viewer
    ├── particle_painter.dart              # Floating particles (smoke, dust)
    ├── path_route_painter.dart            # Walking route painter (gold → silver in Phase 2)
    ├── scene_hotspot_marker.dart          # Pulsing hotspot (circle → diamond in Phase 2)
    ├── sky_gradient.dart                  # Full-screen sky gradient
    ├── starfield_layer.dart               # Twinkling stars
    └── virtual_joystick.dart              # On-screen joystick

d:\Rawi_Journey\assets\
├── audio\                                 # 10 WAV files (ambient + SFX for E1-E2)
├── figures\                               # companion_male.jpg, companion_female.jpg
├── icon\                                  # app_icon.jpg (needs mipmap generation)
└── scenes\                                # 17 JPG files (3 scenes + 13 bubbles + 1 welcome)
```

---

## Appendix: Known Technical Debt

| Item | Location | Issue | When to Fix |
|------|----------|-------|-------------|
| Era transitions hardcoded | `journey_event_screen.dart`, `immersive_event_screen.dart` | `const eraTransitions = <int>[3, 11, 22]` — fragile if event list changes | When adding more events |
| Silent audio exceptions | `audio_service.dart` | All exceptions caught and silently ignored | Phase 5 (VO layer) |
| README.md stale | Root | Still says "deenquest_journey" with boilerplate | Phase 0 (quick fix) |
| M1 data incomplete | `m1_data.dart` | 36 of 47 events written (events 37-47 missing) | Post-v0.6 |
| journey_quiz_screen unused | `lib/screens/` | 440 lines, never imported. Kept for future standalone quiz. | Post-v0.6 |
| Package name | `AndroidManifest.xml` | Still default. Needs decision: `com.rawi.journey` or `com.rawi.seerah` | Before Play Store |

---

## Appendix: Full 155-Event Roadmap (Beyond v0.6)

| Milestone | Title | Events | Status |
|-----------|-------|--------|--------|
| M1 | The Prophetic Dawn | 47 | 36 data built, 2 scene configs (E1-E2), E3 in v0.6 |
| M2 | The Community Rises | 35 | Not started |
| M3 | The Turning Tide | 38 | Not started |
| M4 | The Final Chapter | 35 | Not started |
| **Total** | | **155** | **36/155 data, 3/155 interactive after v0.6** |
