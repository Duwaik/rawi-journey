# RawiJourney — Hasanat System Architecture

> **Status:** Architectural design — NOT for implementation yet.
> This document captures the vision, mechanics, and open questions.
> Implementation timing: after core 36 events are complete.

---

## 1. Concept

RawiJourney has two parallel reward tracks:

| Track | Earned By | Purpose |
|-------|-----------|---------|
| **XP** | Playing the game (hotspots, questions) | Progress & gamification |
| **Hasanat** | User-initiated dhikr after events | Spiritual practice & daily habit building |

XP is automatic. Hasanat are voluntary. Both are visible but separate.

**Core philosophy:** The app doesn't just teach kids *about* Islam —
it teaches them to *practice* it. The dhikr system turns knowledge
into daily habits they carry for life and pass to their children.

---

## 2. Two Layers — Designed Together, Built Separately

### Layer 1 — Launch (Single Contextual Dhikr)
One dhikr per event. Appears after the XP overlay. Short, contextual,
optional. This is the seed that introduces the habit. Minimal UI,
minimal effort to build. Ships with the 36 events.

### Layer 2 — Post-Launch Update ("Dhikr Garden")
A dedicated section where multiple adhkar are available:
- **Multiple dhikr per session** — not limited to one. User can say
  SubhanAllah, Alhamdulillah, Allahu Akbar, all in one sitting.
  Each tap increments Hasanat. Repeatable (e.g., SubhanAllah ×33).
- **Time-aware adhkar** — app detects morning vs evening from device
  clock. On app launch, before gameplay, shows relevant adhkar:
  morning adhkar in the morning, evening adhkar in the evening.
  This is NOT a notification — it only appears when the user opens
  the app. Appears only after the user has completed their first event
  (not on day one).
- **No limits** — the user can say as many as they want, as many
  times as they want. The counter keeps going.
- **Marketed as an update:** "RawiJourney now includes daily adhkar."
  Users who loved Layer 1 will be excited. New users discover it
  as a bonus feature.

**Build order:** Layer 1 ships with launch. Layer 2 ships as a
post-launch update once user engagement with Layer 1 is validated.
Architecture supports both from day one — Layer 2 is just more
content and one new screen, not a rewrite.

---

## 3. Dhikr — Not Quran

**Decision: Dhikr only across all eras. No Quran verses.**

Rationale:
- Consistent experience from Seerah through Ottoman era
- Quran recitation suits the Prophetic era but feels forced in later eras
- Dhikr are short, practical, and immediately usable in daily life
- Accessible for all ages including young children (8+)
- Avoids overdoing the spiritual layer — keeps it light and genuine

---

## 4. Dhikr Selection Criteria

Each dhikr presented in the app should be:
- **Short** — memorizable by a child in under a minute
- **Daily-use** — tied to a real-life moment (waking up, eating,
  leaving home, sleeping, etc.)
- **Authenticated** — from Sahih sources only
- **Contextually connected** — where possible, thematically linked
  to the event the user just completed

---

## 5. Dhikr Card Content

Each dhikr card shows 4 elements:

```
┌─────────────────────────────────┐
│  Arabic text (large, centered)  │
│  بِسْمِ اللَّهِ                │
│                                 │
│  Transliteration                │
│  Bismillah                      │
│                                 │
│  English meaning                │
│  "In the name of Allah"         │
│                                 │
│  🕐 When to say it:             │
│  Before eating or drinking      │
│                                 │
│  ┌───────────────────────────┐  │
│  │  I've said it ✓           │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

The "When to say it" line is what turns information into a life habit.
This is the differentiator — no other app does this in-context.

---

## 6. User Flow

### After Event Completion
```
Verdict → Continue → Chapter overlay → XP overlay
    ↓
"Would you like to earn Hasanat?"
    ↓                    ↓
   Yes                   No
    ↓                    ↓
Dhikr card appears    → Event list
    ↓                   (no penalty)
User reads dhikr
    ↓
Taps "I've said it"
    ↓
Hasanat counter increments
    ↓
Brief celebration
    ↓
Event list
```

### Key rules:
- **Always optional** — "No" carries zero penalty, no guilt messaging
- **Honor-based** — user confirms they said it. No verification.
  This respects sincerity (ikhlas)
- **One dhikr per event** — never overwhelming, never preachy
- **No repeat nagging** — if user says "No" twice in a row, reduce
  frequency (show every 3rd event instead)

---

## 7. Hasanat Counter

### Display
- Separate from XP on the home/profile screen
- Visual: crescent moon or prayer beads icon (not a star)
- Running total that persists forever (never resets)
- Example: "☪ 47 Hasanat"

### Earning
- Each completed dhikr = a set amount (e.g., 1 Hasanah per dhikr,
  or tied to the hadith's stated reward where applicable)
- Some dhikr have multiplied rewards per hadith — show this:
  "Subhan Allah wa bihamdihi — 100 times = sins forgiven"
  earning could reflect the hadith's reward, not a game number

### Where it appears (TBD — pick one or two):
- Option A: Home screen next to XP
- Option B: Profile/Settings screen only
- Option C: Dedicated "My Hasanat" screen with history
- Option D: Small counter on event list header

---

## 8. Example Dhikr Library (Starter)

| # | Arabic | Transliteration | Meaning | When to say it | Source |
|---|--------|----------------|---------|----------------|--------|
| 1 | بِسْمِ اللَّهِ | Bismillah | In the name of Allah | Before eating, drinking, or starting anything | Multiple sahih |
| 2 | الحَمْدُ لِلَّهِ | Alhamdulillah | All praise is for Allah | After eating, after sneezing, when grateful | Multiple sahih |
| 3 | سُبْحَانَ اللَّهِ | SubhanAllah | Glory be to Allah | When amazed, morning/evening adhkar | Muslim |
| 4 | لَا إِلٰهَ إِلَّا اللَّهُ | La ilaha illallah | There is no god but Allah | The best dhikr — anytime | Tirmidhi |
| 5 | أَسْتَغْفِرُ اللَّهَ | Astaghfirullah | I seek Allah's forgiveness | After mistakes, morning/evening | Bukhari/Muslim |
| 6 | بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ | Bismillah tawakkaltu ala Allah | In Allah's name, I place my trust in Him | When leaving the house | Abu Dawud, Tirmidhi |
| 7 | اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا | Allahumma bika asbahna wa bika amsayna | O Allah, by You we enter morning and evening | Morning and evening | Tirmidhi |
| 8 | سُبْحَانَ اللَّهِ وَبِحَمْدِهِ | SubhanAllahi wa bihamdih | Glory and praise be to Allah | Morning/evening — sins forgiven | Bukhari/Muslim |
| 9 | حَسْبِيَ اللَّهُ لَا إِلٰهَ إِلَّا هُوَ | Hasbiyallahu la ilaha illa hu | Allah is sufficient for me, none worthy of worship but Him | When worried or anxious | Abu Dawud |
| 10 | رَضِيتُ بِاللَّهِ رَبًّا | Raditu billahi rabba | I am pleased with Allah as my Lord | Morning/evening — tastes sweetness of faith | Muslim |

This is a starter list. Full list to be curated when implementation
begins. Each event gets one dhikr assigned — 36 events = 36 dhikr
(some may repeat for reinforcement, which is fine).

---

## 9. Contextual Pairing (Examples)

| Event | Theme | Suggested Dhikr |
|-------|-------|-----------------|
| 1. Arabia Before the Light | Tawheed vs idolatry | La ilaha illallah |
| 2. Year of the Elephant | Allah's protection | Hasbiyallahu la ilaha illa hu |
| 4. Birth of the Prophet ﷺ | Gratitude | Alhamdulillah |
| 17. Isra' wal Mi'raj | Glorifying Allah | SubhanAllah |
| 22. Journey to Ta'if | Patience in hardship | Astaghfirullah |
| 31. Conquest of Mecca | Forgiveness & mercy | Astaghfirullah |
| 35. Farewell Pilgrimage | Trust in Allah | Bismillah tawakkaltu ala Allah |

---

## 10. Open Questions

1. **Display location:** Where does the Hasanat total live? Home
   screen, profile, or dedicated screen?
2. **Celebration:** What does the Hasanat earned moment look like?
   Same style as XP (star + count) but with a crescent? Or simpler?
3. **Hadith reward display:** Do we show the specific reward from
   the hadith (e.g., "a house built in Jannah") or keep it generic?
4. **Frequency:** Every event, or every chapter completion?
5. **Repeat dhikr:** Can the same dhikr appear for multiple events
   (for reinforcement) or should each of the 36 be unique?
6. **Young Rawi mode:** Does the dhikr layer adapt per age tier, or
   is it the same for all ages?
7. **Offline tracking:** Hasanat counter stored in SharedPreferences
   alongside XP? Same PrefsService pattern?

---

## 11. What This Is NOT

- NOT a full prayer tracker app
- NOT a Quran reading app
- NOT a daily adhkar app with notifications
- It's a **single contextual dhikr moment** after each event that
  plants seeds for daily practice. Light touch, deep impact.

---

## 12. Implementation Estimate (When Ready)

| Task | Effort |
|------|--------|
| Data model (Dhikr, HasanatCounter) | 1 sprint |
| Dhikr card UI | 1 sprint |
| Flow integration (post-XP prompt) | 1 sprint |
| Hasanat counter on profile/home | 0.5 sprint |
| Content: 36 dhikr selections + pairing | 1–2 days |
| **Total** | ~3.5 sprints |

---

## 13. Decision Log

| Decision | Status |
|----------|--------|
| Dhikr only, no Quran verses | ✅ Locked |
| Consistent across all eras | ✅ Locked |
| Honor-based confirmation | ✅ Locked |
| Always optional, no guilt | ✅ Locked |
| XP stays as-is, Hasanat is additive | ✅ Locked |
| Short daily-use adhkar targeting kids | ✅ Locked |
| Display location | ⬜ TBD |
| Celebration design | ⬜ TBD |
| Frequency (per event vs per chapter) | ⬜ TBD |
| Implementation timing | ⬜ After 36 events written |
| Layer 1 ships at launch, Layer 2 post-launch | ✅ Locked |
| Layer 2: multiple dhikr, repeatable, no limits | ✅ Locked |
| Layer 2: time-aware adhkar on app launch | ✅ Locked |
| Layer 2: only after first event completed | ✅ Locked |
