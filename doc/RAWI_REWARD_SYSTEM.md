# RawiJourney — Reward System Design

> **Date:** April 3, 2026
> **Status:** LOCKED — all decisions final
> **Scope:** All 36 events (scales to 155)

---

## Design Principle

Rewards are paced so the user feels consistent progress without
celebration fatigue. Three layers, each at a different frequency:

- **XP** — every event (constant heartbeat)
- **Chapter completion** — 4 times across 36 events (narrative beats)
- **Badges** — roughly every 5–7 events (spaced milestones)

No two reward types should trigger on the same event unless it's the
grand finale (Event 36).

---

## Layer 1 — XP (Every Event)

**Trigger:** Completing any event
**Display:** Post-Continue popup (full-screen overlay):
- Star icon with scale bounce (0.5x → 1.2x → 1.0x)
- Gold particle burst
- Count-up from previous total to new total
- Auto-dismiss after 2 seconds → navigate to event list

**XP values:** Per-event, defined in m1_data.dart (20–50 range).

This is the baseline celebration. Every single event gets this.
It's the "you did something" moment.

---

## Layer 2 — Chapter Completion (4 Moments)

**Trigger:** Completing the last event in a chapter
**Display:** Cinematic chapter summary screen (era_complete_screen):
- Full-screen dark overlay with gold particles
- Chapter title in Cinzel Decorative
- Narrative closing line (unique per chapter)
- Fade to event list with next chapter expanded

| Chapter | Final Event | Closing Line (EN) | Closing Line (AR) |
|---------|------------|-------------------|-------------------|
| Jahiliyyah | Event 2 | "You have witnessed the age before the light. The world is waiting." | "شهدتَ عصر ما قبل النور. العالم ينتظر." |
| Early Life | Event 11 | "From orphan to the Trustworthy. The revelation is near." | "من يتيم إلى الأمين. الوحي قريب." |
| Mecca | Event 22 | "Thirteen years of patience. The Hijrah has begun." | "ثلاثة عشر عاماً من الصبر. بدأت الهجرة." |
| Medina | Event 36 | "The message is complete. You are the Rawi now." | "اكتملت الرسالة. أنتَ الراوي الآن." |

**Note:** Chapter completion is NOT a badge. It's a narrative moment.
Different visual treatment, different emotional register. Badges are
achievements. Chapter completions are story beats.

---

## Layer 3 — Badges (Spaced Milestones)

### Rebalanced Badge List (7 badges)

| # | Badge ID | Name (EN) | Name (AR) | Trigger | ~Event | Gap |
|---|----------|-----------|-----------|---------|--------|-----|
| 1 | seeker | Seeker | الباحث | Complete 5 events | ~5 | — |
| 2 | witness | Witness of the Dawn | شاهد الفجر | Complete Early Life chapter (Events 1–11) | ~11 | 6 |
| 3 | keeper | Keeper of the Path | حارس الدرب | Complete 15 events | ~15 | 4 |
| 4 | steadfast | Steadfast in Mecca | صامد في مكة | Complete Mecca chapter (Events 1–22) | ~22 | 7 |
| 5 | scholar | Scholar | العالِم | Complete 30 events | ~30 | 8 |
| 6 | guardian | Guardian of the Legacy | حارس الإرث | Complete Medina chapter (Events 1–36) | 36 | 6 |
| 7 | rawi | The Rawi | الراوي | Complete all 36 events | 36 | 0 |

### Key Changes from Previous System

1. **"First Step" removed.** Completing one event isn't an achievement.
   The first badge now comes at Event 5 — the user has committed.

2. **Jahiliyyah has no dedicated badge.** With only 2 events it's too
   small. Merged into "Witness of the Dawn" which covers Jahiliyyah +
   Early Life (Events 1–11).

3. **Count milestones fill the gaps.** "Seeker" (5), "Keeper" (15),
   "Scholar" (30) ensure no drought longer than 7–8 events between
   badge moments.

4. **"The Rawi" stacks with "Guardian."** Finishing Event 36 awards
   both — the chapter badge and the grand finale badge. Double
   celebration for the user who completes everything. This is the one
   exception to the "no stacking" rule, and it's the proper finale.

### Badge Display Rules

- Badge popup appears AFTER the user taps "Continue Journey"
- Badge popup appears BEFORE the XP popup
- If both a badge and chapter completion trigger on the same event:
  Chapter completion screen first → Badge popup → XP popup
- Never interrupt the History Records explanation or VO playback
- Badge popup: full-screen dark overlay (85%), gold-bordered card,
  badge artwork, title, description, "Tap to continue"

### Scaling to 155 Events

When M2–M4 are added, insert additional badges:

| Badge | Trigger | ~Event |
|-------|---------|--------|
| Pilgrim | Complete 50 events | ~50 |
| Chronicler | Complete 75 events | ~75 |
| Torchbearer | Complete 100 events | ~100 |
| Legacy Builder | Complete 125 events | ~125 |
| Master Rawi | Complete all 155 events | 155 |

Plus chapter/sub-era badges for M2, M3, M4 milestones.

---

## Badge Artwork — Style Decision (LOCKED)

Two options being evaluated. Khaled to choose after seeing sketches.

### ✅ DECIDED: Option A — Painterly Illustrations

**Decision:** Painterly, AI-generated badge artwork. Every visual in
Rawi is painted — scenes, companions, hotspot bubbles, transitions.
The badges must live in the same world. Geometric patterns are cleaner
technically but break the cinematic atmosphere that defines the app.

**Pipeline:** Bing Image Creator (same tool used for hotspot card images).
7 prompts, one generation batch, dropped into `assets/badges/`.

**Style rules (same as hotspot card images):**
- Circular composition (will be clipped to circle in the app)
- Painterly / oil painting style
- Warm golden-hour earth tone palette
- No faces, no text in the image
- Deep navy or dark background to match the app's badge overlay
- Each badge has a unique scene/symbol that tells its story

**Badge artwork concepts:**

| Badge | Visual Concept |
|-------|---------------|
| Seeker | Desert path at twilight, footprints in sand leading toward a distant glow on the horizon, crescent moon above |
| Witness of the Dawn | Dawn breaking over mountain range, first rays of gold splitting a dark sky, silhouette of Arabian landscape |
| Keeper of the Path | Ancient stone pathway winding through desert canyon, warm torchlight illuminating the way, scattered date palms |
| Steadfast in Mecca | Ka'bah silhouette at night, warm glow surrounding it, stars above, sense of solitude and reverence |
| Scholar | Open scroll/manuscript on a wooden surface, inkwell, warm candlelight, scattered pages with calligraphy feel |
| Guardian of the Legacy | Masjid Nabawi dome silhouette at golden hour, palm trees, warm light radiating outward |
| The Rawi | Large crescent moon over an open illuminated manuscript, golden particles rising from the pages, night sky with stars — the grand finale badge |

**Image specs:**
- Square source image (1024x1024 from Bing)
- Cropped to circle in app via `ClipOval` or `CircleAvatar`
- Final rendered size: ~160x160 in badge overlay, ~48x48 in settings
- Gold circular border added in code (not baked into the image)

**Khaled's task:** Generate 7 badge images via Bing Image Creator using
the visual concepts above. Prompts to be written (under 600 chars each,
matching the hotspot card prompt format).

---

## Reward Flow — Complete Example

**User completes Event 5 (first badge trigger):**
1. Answer question → explanation reveals + VO plays
2. User reads explanation, VO finishes
3. User taps "Continue Journey →"
4. VO stops immediately
5. Badge popup: "Seeker — You've completed 5 events" → Tap to dismiss
6. XP popup: ★ +25 XP (120 → 145) → auto-dismiss 2s
7. Navigate to event list

**User completes Event 11 (chapter + badge):**
1. Answer question → explanation → Continue
2. Chapter completion screen: "From orphan to the Trustworthy..."
3. Badge popup: "Witness of the Dawn" → Tap to dismiss
4. XP popup
5. Navigate to event list (Early Life collapsed, Mecca expanded)

**User completes Event 14 (no badge, no chapter):**
1. Answer question → explanation → Continue
2. XP popup only
3. Navigate to event list
