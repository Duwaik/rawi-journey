# RawiJourney — Event Status Map (Post-Reorder)

> **Purpose:** Accurate record of which events have scene configs
> and which need them. Accounts for the Seerah reordering
> (Black Stone moved to #8, Ta'if moved to #17).

---

## Scene Config Status

Scene configs exist in `scene_configs.dart` keyed by event ID.
Only events WITH a scene config are fully playable (hotspots,
walking paths, branching, in-scene exploration).

Events WITHOUT a scene config play as linear narrative + quiz only.

### ✅ PLAYABLE (3 events — have scene configs)

| # | ID | Title | Chapter | Branching | Notes |
|---|-----|-------|---------|-----------|-------|
| 1 | j_1_1_1 | Arabia Before the Light | Jahiliyyah | ✅ | 4 hotspots, both paths |
| 2 | j_1_1_2 | The Year of the Elephant | Jahiliyyah | ✅ | 4 hotspots, both paths, video intro |
| 8 | j_1_1_3 | The Black Stone — A Wise Arbitration | Early Life | ✅ | 4 hotspots, both paths |

### ⬜ NEED SCENE CONFIGS (33 events)

**Early Life — positions 3–7, 9–11:**

| # | ID | Title |
|---|-----|-------|
| 3 | j_1_2_1 | The Birth of the Prophet ﷺ |
| 4 | j_1_2_2 | Under the Care of Abd al-Muttalib |
| 5 | j_1_2_3 | The Guardian: Abu Talib |
| 6 | j_1_2_4 | Hilf al-Fudul — The Pact of the Virtuous |
| 7 | j_1_2_5 | Marriage to Khadijah RA |
| 9 | j_1_2_6 | Solitude in Cave Hira |
| 10 | j_1_2_7 | The First Revelation |
| 11 | j_1_2_8 | The First Believers |

**Mecca — positions 12–22:**

| # | ID | Title |
|---|-----|-------|
| 12 | j_1_3_1 | The Call Goes Public |
| 13 | j_1_3_2 | Persecution Begins |
| 14 | j_1_3_3 | Migration to Abyssinia |
| 15 | j_1_3_4 | The Boycott — Three Years of Siege |
| 16 | j_1_3_5 | Year of Grief — Khadijah and Abu Talib |
| 17 | j_1_3_11 | The Journey to Ta'if — Rejection and Resilience |
| 18 | j_1_3_6 | Al-Isra' wal-Mi'raj — The Night Journey |
| 19 | j_1_3_7 | The Pledge of Aqabah — First |
| 20 | j_1_3_8 | The Second Pledge of Aqabah |
| 21 | j_1_3_9 | The Plot to Kill the Prophet ﷺ |
| 22 | j_1_3_10 | Cave Thawr — Three Days in Hiding |

**Medina — positions 23–36:**

| # | ID | Title |
|---|-----|-------|
| 23 | j_1_4_1 | Arrival in Medina — The Hijrah |
| 24 | j_1_4_2 | Building the Prophet's Mosque |
| 25 | j_1_4_3 | The Brotherhood — Muakhah |
| 26 | j_1_4_4 | The Battle of Badr |
| 27 | j_1_4_5 | The Battle of Uhud |
| 28 | j_1_4_6 | The Battle of the Trench — Al-Khandaq |
| 29 | j_1_4_7 | Treaty of Hudaybiyyah |
| 30 | j_1_4_8 | Letters to the Kings |
| 31 | j_1_4_9 | The Conquest of Mecca |
| 32 | j_1_4_10 | The Battle of Hunayn |
| 33 | j_1_4_11 | The Expedition to Tabuk |
| 34 | j_1_4_12 | Year of Delegations |
| 35 | j_1_4_13 | The Farewell Pilgrimage |
| 36 | j_1_4_14 | The Final Illness and Departure |

---

## What Each Event Needs to Become Playable

Already done for all 36:
- ✅ Narrative text (EN + AR)
- ✅ Question + answer options (EN + AR)
- ✅ Explanation text (EN + AR)

Still needed per event (33 events):
- ⬜ Scene config (hotspots, walking paths, parallax layers)
- ⬜ Scene background image (scene_eventN_*.jpg)
- ⬜ Hotspot card images (bubble_*.jpg) — 4 per event
- ⬜ Hotspot fragments (EN + AR) — 4 per event
- ⬜ Branching content (for branch events only)
- ⬜ Ambient sound clips (1 per hotspot)
- ⬜ VO files (8 per hotspot: EN/AR × M/F × hotspot + question + explanation)
- ⬜ Video intro (battle/major events only)

---

## Audio Status

### VO Files (in assets/audio/vo/)
- Event 1 (j_1_1_1): ✅ All hotspots + question (28 files)
- Event 2 (j_1_1_2): ✅ All hotspots + question (28 files)
- Event 3 (j_1_1_3): ✅ All hotspots + question (28 files)
- Events 4–36: ⬜ None

### Ambient Clips (in assets/audio/ambient/)
- ambient_intro.mp3 ✅
- ambient_crossroads.mp3 ✅
- ambient_transition.mp3 ✅
- ambient_e1_kaabah.mp3 ✅
- ambient_e1_idols.mp3 ✅
- ambient_e1_merchants.mp3 ✅
- sfx_badge.mp3 ✅
- sfx_xp.mp3 ✅

### Hotspot SFX (in assets/audio/ root)
- Event 1: sfx_kaabah_wind, sfx_idols_incense, sfx_merchants_bustle, sfx_poet_crowd ✅
- Event 2: sfx_army_march, sfx_elephants_rumble, sfx_muttalib_silence, sfx_birds_swarm ✅
- Event 3: sfx_flood_rubble, sfx_dispute_crowd, sfx_dawn_wind, sfx_cloak_fabric ✅

### Video
- Event 2: event2_intro.mp4 ✅
- All others: ⬜ None

---

## Key Note: ID vs Position

Due to the Seerah reorder, event IDs do NOT match their position:
- j_1_1_3 (originally Jahiliyyah event 3) is now at **position 8** (Early Life)
- j_1_3_11 (Ta'if) is at **position 17** (Mecca)

Always use `globalOrder` for position, never assume from the ID.
