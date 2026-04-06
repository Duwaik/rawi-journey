# RawiJourney — Updated Execution Plan
## April 6, 2026

> **Strategy:** Character art first → Content for all 36 events →
> Batch polish (VO, sounds, badge art, hotspot images) at the end.
> Don't perfect Events 1-2 in isolation. Build forward.

---

## WHAT'S CONFIRMED DONE (Code Verified)

All R5 through R9 items are implemented in code:
- ✅ Arabic italic conditional fix (17 locations)
- ✅ Western Arabic numerals
- ✅ Intro screen merged (no duplicate)
- ✅ XP overlay larger sizes
- ✅ Scroll indicator clickable + bouncing
- ✅ Event list cinematic desert BG (alpha 235)
- ✅ Continuous ambient_intro.mp3 with 800ms restart delay
- ✅ 8 ambient/SFX clips integrated
- ✅ Audio ducking + isolation
- ✅ Video intro Event 2 with blurred BG extension
- ✅ Tap-to-skip after 3 seconds
- ✅ Registration 2-screen flow with blurred BG
- ✅ Keyboard dismiss on tap outside
- ✅ Adaptive icon (navy + foreground PNGs)
- ✅ Splash screen cinematic BG (blurred desert)
- ✅ Reset journey clears onboarding (full restart)
- ✅ Tutorial overlay 82% dim + gold glow
- ✅ "Made with ❤" removed
- ✅ Completion flow pushAndRemoveUntil
- ✅ Event list layout (gold glow, teasers, hints, bottom text)
- ✅ Chapter era teasers on collapsed headers

**Needs device testing only** — no more code changes needed for these.

---

## STEP 1: CHARACTER ART (Do This Week)

This is the ONE blocker that affects every screen in every event.
Get it right, then never think about it again.

### What to Generate (Bing Image Creator)

**MVP — 4 images × 2 characters = 8 images:**

| # | Character | Pose | Used On |
|---|-----------|------|---------|
| 1 | Rawi | Portrait (1:1) | Registration, Settings |
| 2 | Rawi | Walking (4:7) | In-scene exploration (all events) |
| 3 | Rawi | Witnessing (1:1) | Verdict question, hotspot discovered |
| 4 | Rawi | Carrying (1:1) | XP overlay, badge overlay, chapter completion |
| 5 | Rawiah | Portrait (1:1) | Registration, Settings |
| 6 | Rawiah | Walking (4:7) | In-scene exploration (all events) |
| 7 | Rawiah | Witnessing (1:1) | Verdict question, hotspot discovered |
| 8 | Rawiah | Carrying (1:1) | XP overlay, badge overlay, chapter completion |

**All prompts are ready** in RAWI_CHARACTER_ART_SESSION.md.
Estimated time: ~90 minutes in Bing Image Creator.

### Where Each Pose Appears

```
APP FLOW                          POSE SHOWN
──────────────────────────────────────────────
Splash screen                     (Logo only, no character)
Intro cinematic                   (No character — text only)
Registration                      PORTRAIT (companion select)
Event list                        (No character)
Cinematic transition              (No character — title card)
Video intro (battle events)       (No character — cinematic video)
In-scene exploration              WALKING (figure on path)
Hotspot card opened               WITNESSING (small, in card header)
Branch decision (Crossroads)      (No character)
Verdict question                  WITNESSING (beside question text)
History Records explanation       (No character)
XP celebration                    CARRYING (next to star + XP)
Badge earned                      CARRYING (next to badge)
Chapter completion                CARRYING (celebration moment)
Settings screen                   PORTRAIT (next to user name)
```

### Agent Task After Art Is Ready

Give agent all 8 images with this spec:

```
assets/figures/rawi_portrait.jpg      → Registration + Settings
assets/figures/rawi_walking.jpg       → CompanionFigure in-scene
assets/figures/rawi_witnessing.jpg    → Verdict + hotspot moments
assets/figures/rawi_carrying.jpg      → XP + Badge + Chapter overlays
assets/figures/rawiah_portrait.jpg    → Registration + Settings
assets/figures/rawiah_walking.jpg     → CompanionFigure in-scene
assets/figures/rawiah_witnessing.jpg  → Verdict + hotspot moments
assets/figures/rawiah_carrying.jpg    → XP + Badge + Chapter overlays
```

Agent needs to:
1. Replace existing 4 companion images with new portraits + walking
2. Add witnessing pose to Verdict screen and hotspot discovery
3. Add carrying pose to XP, badge, and chapter overlays
4. All image references use PrefsService.userGender to pick
   rawi_ or rawiah_ prefix

**Once done, character is locked for all 36 events. Never revisit.**

---

## STEP 2: CONTENT WRITING (The Big Push — Weeks 2-7)

After character art is locked, switch entirely to content mode.
Write events in chapter order. Each event follows the template
from RAWI_ROAD_TO_LAUNCH.md.

### Per Event — What You Write:

1. **Narrative content** — 4 hotspot fragments (EN + AR, ~150-200 words each)
2. **Branch point** (if branching) — prompt + 2 options (EN + AR)
3. **Question** — 1 question + 4 options + explanation (EN + AR)
4. **Scene description** — one paragraph describing the visual setting
   (used to generate BG image later)
5. **Video note** — mark if this event should have a video intro
   (battles, major moments)

### What You DON'T Do During Content Writing:

- ❌ Don't generate VO files yet (batch at end)
- ❌ Don't generate ambient sounds yet (batch at end)
- ❌ Don't generate hotspot card images yet (batch at end)
- ❌ Don't worry about badge artwork yet (batch at end)
- ❌ Don't generate scene BG images yet (agent can use placeholders)

### What the Agent Does In Parallel:

As you deliver each event's content:
1. Add event data to `m1_data.dart`
2. Create scene config in `scene_configs.dart` (with placeholder BG)
3. Wire branching/linear flow
4. Test basic playthrough

### Content Writing Order:

**Chapter 1 — Jahiliyyah (1 remaining):**
- [ ] Event 3: The Black Stone — A Wise Arbitration

**Chapter 2 — Early Life (9 events):**
- [ ] Event 4: Birth of the Prophet ﷺ
- [ ] Event 5: Under the Care of Abd al-Muttalib
- [ ] Event 6: The Guardian: Abu Talib
- [ ] Event 7: Hilf al-Fudul — The Pact of the Virtuous
- [ ] Event 8: Marriage to Khadijah RA
- [ ] Event 9: Solitude in Cave Hira
- [ ] Event 10: The First Revelation
- [ ] Event 11: The First Believers

**Chapter 3 — Mecca (11 events):**
- [ ] Event 12: The Call Goes Public
- [ ] Event 13: Early Persecution
- [ ] Event 14: Migration to Abyssinia
- [ ] Event 15: The Boycott
- [ ] Event 16: Year of Grief
- [ ] Event 17: The Journey to Ta'if
- [ ] Event 18: Al-Isra' wal-Mi'raj 🎬 VIDEO
- [ ] Event 19: First Pledge of Aqabah
- [ ] Event 20: Second Pledge of Aqabah
- [ ] Event 21: The Plot (Hijrah Begins)
- [ ] Event 22: Cave Thawr

**Chapter 4 — Medina (14 events):**
- [ ] Event 23: Arrival in Medina
- [ ] Event 24: Building the Prophet's Mosque
- [ ] Event 25: The Brotherhood — Muakhah
- [ ] Event 26: Battle of Badr ⚔️🎬 VIDEO (already generated!)
- [ ] Event 27: Battle of Uhud ⚔️🎬 VIDEO
- [ ] Event 28: Battle of the Trench ⚔️🎬 VIDEO
- [ ] Event 29: Treaty of Hudaybiyyah
- [ ] Event 30: Letters to the Kings
- [ ] Event 31: Conquest of Mecca 🎬 VIDEO
- [ ] Event 32: Battle of Hunayn ⚔️🎬 VIDEO
- [ ] Event 33: Expedition to Tabuk
- [ ] Event 34: Year of Delegations
- [ ] Event 35: Farewell Pilgrimage 🎬 VIDEO
- [ ] Event 36: Final Illness and Departure

**🎬 = Events that get Luma AI video intros (8 total)**

### Pace:
- 1 event/day = 34 days (5 weeks)
- 2 events/day = 17 days (2.5 weeks)
- Content writing with Claude (this conversation) = faster iteration

---

## STEP 3: SCENE BACKGROUNDS (Batch — 1 Weekend)

After all content is written, generate scene BG images for all
events in one Bing Image Creator session.

- 36 events × 1 scene BG = 36 images
- Use the scene descriptions written in Step 2
- Style: painterly, warm earth tones, no faces, matching existing BGs
- Estimated time: 3-4 hours (one Saturday morning)

---

## STEP 4: VIDEO INTROS (Batch — 1-2 Sessions)

Generate Luma AI videos for the 8 marked events:
1. Event 2: Year of the Elephant ✅ DONE
2. Event 18: Isra' wal-Mi'raj
3. Event 26: Battle of Badr ✅ GENERATED (needs integration)
4. Event 27: Battle of Uhud
5. Event 28: Battle of the Trench
6. Event 31: Conquest of Mecca
7. Event 32: Battle of Hunayn
8. Event 35: Farewell Pilgrimage

Luma free accounts or one month Pro ($28) covers all of these.

---

## STEP 5: VO GENERATION (Batch — 1-2 Days)

Generate ALL voiceover files for ALL 36 events in one session.

**Two options:**

### Option A: Khaled's Own Voice
- Record AR narration yourself (authentic Jordanian accent!)
- Use a quiet room + phone mic or basic USB mic
- This SOLVES the Syrian accent problem permanently
- Record EN narration too, or use Edge TTS for EN only
- Most authentic option — YOUR voice telling the Seerah

### Option B: Edge TTS Batch Generation
- Identify Jordanian voice ID (ar-JO) for male + female
- Script all fragments → batch generate with Edge TTS
- Faster but less personal

**Recommendation:** Option A for Arabic (your voice = Jordanian
accent = authentic = unique selling point). Option B for English.

### Per event VO needs:
- 4 hotspot fragments × 2 languages × 2 genders = 16 files
- 1 branch prompt × 2 × 2 = 4 files
- 1 explanation × 2 × 2 = 4 files
- **~24 VO files per event × 36 events = ~864 files total**

If using your own voice (AR only, 1 gender): 36 events × ~5 clips = ~180 recordings.
At 30 seconds each average = ~90 minutes of recording. Doable in a day.

---

## STEP 6: AMBIENT SOUNDS (Batch — 1 Evening)

Generate ambient clips for ALL events in one ElevenLabs session.

### Per event needs:
- 4 hotspot ambients + 1 verdict ambient = 5 clips
- 36 events × 5 = 180 clips

**But many events share similar settings:**
- Mecca marketplace scenes → reuse merchant/courtyard ambients
- Desert/outdoor scenes → reuse wind/sand ambients
- Battle events → reuse army/drum ambients with variations

Realistically: ~40-50 unique clips needed, rest are reused.
One ElevenLabs Pro month ($5-11) covers this.

---

## STEP 7: FINAL POLISH (Last Week Before Launch)

Everything that was skipped gets done in one focused sprint:

- [ ] Badge artwork — 7 images from Bing (1 hour)
- [ ] Hotspot card images — 4 per event × 36 = 144 images from Bing
      (but many can reuse — estimate 60-80 unique images, 2 days)
- [ ] App icon finalization (using character silhouette)
- [ ] Play Store listing (screenshots, description, metadata)
- [ ] Final end-to-end testing (all 36 events, both languages)
- [ ] Any remaining bug fixes

---

## TIMELINE SUMMARY

```
WEEK 1:  Character art (8 images) + device test R8/R9
         Agent wires character into all screens
         
WEEK 2-3: Content writing — Jahiliyyah complete + Early Life
          Agent builds scene configs in parallel
          
WEEK 4-5: Content writing — Mecca chapter
          
WEEK 6-7: Content writing — Medina chapter
          Video generation for battle events (Luma)
          
WEEK 8:   Batch generation sprint:
          - Scene BG images (Bing, 1 day)
          - VO files (your voice or Edge TTS, 1-2 days)
          - Ambient sounds (ElevenLabs, 1 evening)
          - Badge artwork (Bing, 1 hour)
          - Hotspot card images (Bing, 2 days)
          
WEEK 9:   Final testing + Play Store submission
```

---

## WHY THIS ORDER IS FASTEST

1. **Character art first** — blocks all screens, do once, done forever
2. **Content is the bottleneck** — everything else flows FROM content
3. **No context switching** — write for 5 weeks straight, then
   generate assets for 1 week straight
4. **Batch is efficient** — generating 180 VO files in one session
   is 10x faster than generating 5 files per event as you go
5. **Agent stays busy** — while you write, agent builds configs
6. **Nothing is wasted** — every pipeline is proven (Bing, ElevenLabs,
   Luma, Edge TTS), you're just scaling what already works

---

## ITEMS EXPLICITLY DEFERRED TO BATCH PHASE

These are NOT forgotten — they're strategically deferred:

| Item | Why Deferred | When |
|------|-------------|------|
| VO accent (Jordanian) | Batch all VO at end | Week 8 |
| VO skipping fix | Irrelevant if re-recording | Week 8 |
| Remaining 7 sound clips | Batch all sounds at end | Week 8 |
| Badge artwork | Cosmetic, placeholder works | Week 8 |
| Hotspot card images | Need content first | Week 8 |
| Scene BG images (Events 3-36) | Need content first | Week 8 |
| "Go Deeper" content | Phase 2 — after launch | Post-launch |
| App icon (if still broken) | flutter_launcher_icons | Week 8 |
| Figure off-route (R4-03a) | Cosmetic, rare | Week 8 |
| Route line visibility (R4-03c) | Cosmetic | Week 8 |
| Language change instant reflect | Low impact | Week 8 |

---

## WHAT TO DO RIGHT NOW

1. **Today:** Test R8/R9 build on device — verify everything works
2. **Today/Tomorrow:** Generate 8 character art images (Bing, 90 min)
3. **Hand images to agent** — wire into all screens per placement map
4. **Start writing Event 3** — use the content template
5. **Don't look back.** Content mode begins.
