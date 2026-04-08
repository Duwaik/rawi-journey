# RawiJourney — Rhythm Breakers Spec

> **Purpose:** Five new features that break the repetitive
> walk-read-answer pattern across 155 events. All use the
> existing navy/gold palette. Agent builds these while content
> writing continues for Events 9–20.

---

## Overview

| Feature | Frequency | Effort | Priority |
|---------|-----------|--------|----------|
| Hotspot layout variety | Every event | Zero (scene config only) | 1 — Now |
| The Threshold | Every 5–7 events | 2 sprints | 2 — Build now |
| The Witness Moment | Major events (~10 total) | 1.5 sprints | 3 — Build now |
| The Chain of Transmission | Every 25 events (6 total) | 2 sprints | 4 — Build now |
| Collection cards | After select events | 2 sprints | 5 — Build now |
| Chapter Review Quiz | End of each era (5 total) | 2 sprints | 6 — Build now |

---

## 1. Hotspot Layout Variety

### What
Instead of every event using the same bottom-to-top linear path,
alternate the hotspot XY placement patterns across events.

### Patterns (cycle through these)

**Pattern A — Bottom to top (current default):**
```
        [4]
   [2]      [3]
        [1]
      START
```

**Pattern B — Left to right:**
```
START → [1] → [2] → [3] → [4]
```

**Pattern C — Diamond:**
```
        [3]
   [2]      [4]
        [1]
      START
```

**Pattern D — Center outward:**
```
   [2]      [3]
      START
   [1]      [4]
```

**Pattern E — Top to bottom (descent):**
```
      START
        [1]
   [2]      [3]
        [4]
```

**Pattern F — Zigzag:**
```
START → [1]
              ↓
         [2] ←
    ↓
    [3] → [4]
```

### Implementation
No code changes needed. Just vary the x/y coordinates in each
event's scene config. Content docs will specify which pattern
to use per event.

### Assignment (Events 1–15)
| Event | Pattern |
|-------|---------|
| 1–4 | A (bottom to top) — already built |
| 5 | B (left to right) |
| 6 | A (bottom to top) |
| 7 | C (diamond) |
| 8 | B (left to right) |
| 9 | D (center outward) |
| 10 | A (bottom to top) |
| 11 | F (zigzag) |
| 12 | Already built (branching) |
| 13 | E (top to bottom) |
| 14 | C (diamond) |
| 15 | A (bottom to top) |

Agent should update existing scene configs for Events 5–8 to
match these patterns. Future events will specify in their
content docs.

---

## 2. The Threshold (العَتَبة)

### What
Every 5–7 events, before the user can start the next event, a
locked threshold screen appears. They must answer a recall question
from a PREVIOUS event to unlock it.

### Frequency
Appears before Events: 6, 12, 18, 25, 31, 37, 43 (in M1).
Roughly every 6 events. Exact placement adjustable.

### User Flow
```
User taps next event on list
    ↓
Threshold screen appears (full screen, dark overlay)
    ↓
Gold threshold illustration (faded, right side)
Arabic label: العَتَبة
English label: The Threshold
    ↓
Question from a previous event appears
(randomly selected from Events 1 through N-1)
    ↓
3 answer options (same style as Verdict)
    ↓
CORRECT → threshold opens (gold animation: threshold splits apart)
    → user proceeds to the event
    ↓
WRONG → hint appears ("Think back to Event X...")
    → user tries again (no penalty, no limit)
```

### UI Design
- Full screen dark overlay (85% opacity navy)
- Large threshold silhouette on the right half (transparent, 15% opacity)
- Gold border card in center with question
- Same font/style as Verdict questions
- "The Threshold" / "العَتَبة" label at top in gold
- On correct: threshold splits animation (two halves slide apart,
  gold particles burst, ~1s) then auto-navigate to event

### Data Model
```dart
class ThresholdChallenge {
  final int beforeEventOrder;  // appears before this event
  final String question;
  final String questionAr;
  final List<String> options;
  final List<String> optionsAr;
  final int correctIndex;
  final String hintEventTitle;  // "Think back to: The Year of the Elephant"
  final String hintEventTitleAr;
}
```

Store gate challenges in a separate file: `threshold_challenges.dart`

### Event List Appearance
- Sits between events on the timeline
- Square node with gold fill (vs round for events)
- Gold left-accent border on card
- Label: "The Threshold" / "العَتَبة"
- Subtitle: "Answer to unlock the next path"
- Locked appearance until the user reaches it
- After completion: checkmark, muted gold

---

## 3. The Witness Moment (لحظة الشهادة)

### What
On high-impact events, instead of jumping straight into the scene,
a full-screen cinematic text crawl plays first. Like a movie
opening. 15 seconds max. Sets the emotional weight before the
hotspots begin.

### Which Events Get It (~10 across 155)
| Event | Title | Why |
|-------|-------|-----|
| 14 | The First Revelation | The most significant night in history |
| 29 | Death of Khadijah | Emotional devastation |
| 31 | Journey to Ta'if | Lowest point of the Prophet's life |
| 34 | Al-Isra' wal-Mi'raj | Supernatural journey |
| 47 | Entry into Medina | End of M1, new era begins |
| 57 | Battle of Badr | First major battle |
| 110 | Conquest of Mecca | The culmination |
| 140 | The Farewell Sermon | Final address |
| 150 | The Departure | The Prophet ﷺ passes away |
| 155 | You Are the Rawi | The closing |

### User Flow
```
User taps event on list
    ↓
Cinematic transition screen (date, location, title)
    ↓
NEW: Witness Moment screen (instead of going to scene)
    ↓
Black screen, text fades in line by line (gold on dark)
3–4 sentences, each appearing with a 2s delay
Example for Event 14 (First Revelation):
  "It is the month of Ramadan."
  "The mountain is silent."
  "Inside the cave, something is about to change."
  "Forever."
    ↓
After last line: 3s hold, then auto-fade to scene
    ↓
Normal hotspot exploration begins
```

### UI Design
- Pure black background
- Text in Lora (serif), gold (#C9A84C), centered
- Each line fades in over 0.5s, holds for 2s
- Subtle gold dust particles floating (very sparse, ~10)
- No buttons, no interaction — pure atmosphere
- Auto-advances after the last line + 3s hold
- Total duration: ~15s

### Data Model
```dart
class WitnessIntro {
  final List<String> lines;    // EN lines, shown sequentially
  final List<String> linesAr;  // AR lines
}
```

Add optional `witnessIntro` field to `JourneyEvent`:
```dart
class JourneyEvent {
  // ... existing fields ...
  final WitnessIntro? witnessIntro;
}
```

### Event List Appearance
- Hollow circle node on timeline
- Dashed gold border on card
- Serif font for title
- Label: "The Witness Moment" / "لحظة الشهادة"
- Does NOT appear as a separate list item — it's PART of the
  event. The event card itself gets the dashed border treatment
  to signal "this one is special."

---

## 4. The Chain of Transmission (سلسلة الإسناد)

### What
Every 25 events, the app breaks the fourth wall. A special screen
shows a golden chain from the event → the sahabi who narrated it
→ the scholar who recorded it → 1400 years → the USER (by name).

### When
After Events: 25, 50, 75, 100, 125, 155

### User Flow
```
User completes Event 25 (or 50, 75, etc.)
    ↓
Normal completion: Verdict → Chapter → XP
    ↓
NEW: Chain screen appears (instead of returning to list)
    ↓
Vertical golden chain with nodes:
  [Event witnessed]
       |
  [Sahabi who narrated]
       |
  [Scholar who recorded]
       |
     . . .
  1400 years of transmission
       |
  [USER'S NAME — "You are link #X in the chain"]
    ↓
Bilingual quote:
"The story lives because someone like you
refused to let it die."
    ↓
"Will you pass it on?" button
    → Generates shareable card (WhatsApp/Instagram)
    → Card shows: event title, powerful quote,
      user's name as the Rawi, app branding
    ↓
"Continue journey" link below
```

### UI Design (from the mockup, refined)
- Full screen navy background
- Vertical gold chain line (2px, animated drawing top to bottom)
- Circular nodes at each stop:
  - Event: 44px, gold border, crescent icon
  - Sahabi: 40px, navy fill, gold border, pen icon
  - Scholar: 40px, navy fill, gold border, book icon
  - Dotted gap: "1400 years of transmission"
  - User: 52px, gold fill (30%), gold border (2px), user initial
- User's name from PrefsService in gold, 15px
- "You are link #X" below name
- Quote in Lora italic, gold, centered
- Arabic quote below in same style
- "Will you pass it on?" — gold bordered pill button
- "Continue journey" — muted text link below
- Transparent faded illustrations on right: chain links

### Share Card Design
When "Will you pass it on?" is tapped:
- Generate image (or use share_plus package)
- Card content:
  - Navy background
  - Gold border
  - Event title in gold
  - A selected powerful quote from the last 25 events
  - "Carried by [USER NAME], the Rawi"
  - RawiJourney logo/branding at bottom
  - QR code or app store link (post-launch)

### Data Model
```dart
class ChainMoment {
  final int afterEventOrder;   // 25, 50, 75, 100, 125, 155
  final String eventTitle;     // the event just completed
  final String eventTitleAr;
  final String sahabiName;     // who narrated
  final String sahabiNameAr;
  final String scholarName;    // who recorded
  final String scholarNameAr;
  final String sourceBook;     // e.g., "Sahih Muslim"
  final String shareQuote;     // powerful quote for share card
  final String shareQuoteAr;
}
```

Store in `chain_moments.dart`. Content will be written as we
reach those events.

### Event List Appearance
- Larger gold node on timeline (20px vs 12px for events)
- Full gold border on card (1.5px)
- Arabic subtitle above English title
- Serif font
- Transparent chain link illustration on right half
- Label: "The Chain of Transmission" / "سلسلة الإسناد"
- Subtitle: "You become the narrator"
- Visually the most prominent breaker on the list

---

## 5. Collection Cards

### What
After completing certain events, before returning to the event
list, a card appears: "You have discovered: [item]". These are
collectible items that go into a gallery accessible from the
home screen.

### When
After events that introduce a significant person, place, or
concept. Not every event — roughly every 3–4 events. Examples:

| After Event | Collection Card |
|-------------|----------------|
| 2 | The Ka'bah — House of Ibrahim |
| 4 | Halimah al-Sa'diyyah — The Blessed Nurse |
| 7 | The Seat of Abd al-Muttalib |
| 8 | The Road to Syria |
| 12 | The Black Stone |
| 14 | Cave Hira |
| 14 | The First Ayah — Iqra |
| 29 | Khadijah — Mother of the Believers |
| 34 | Al-Buraq |
| 47 | The City of Medina |
| 57 | The Wells of Badr |
| 110 | The Key to the Ka'bah |

### User Flow
```
User completes event → Verdict → XP
    ↓
NEW: Collection card slides up from bottom
    ↓
"You have discovered:" / "لقد اكتشفت:"
[Card with item name, small illustration placeholder,
 1-line description]
    ↓
"Add to collection" button (auto-adds, just confirms)
    ↓
Brief gold particle celebration
    ↓
Returns to event list
```

### Collection Gallery Screen
- Accessible from home/event list (new icon or tab)
- Grid of cards (3 columns)
- Discovered: full color with name
- Undiscovered: silhouette/locked with "???"
- Shows "12/45 discovered" progress
- Tapping a discovered card shows: image, name, description,
  which event it came from, and the source reference

### Data Model
```dart
class CollectionItem {
  final String id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final String category;        // 'people', 'places', 'artifacts', 'moments'
  final int unlockedByEvent;    // globalOrder of the event
  final String? imagePath;      // placeholder until batch generation
  final String sourceRef;
  final String sourceRefAr;
}
```

Store in `collection_data.dart`.

### Event List Appearance
- Does NOT appear as a separate item on the list
- The event card that unlocks a collection item gets a small
  gold badge/icon in the corner (like a tiny card icon)
- After completion: the badge turns to a checkmark

---

## 6. Chapter Review Quiz (مراجعة الفصل)

### What
After completing all events in an era, a quiz screen appears
with 5–7 cross-event questions. These test connections between
events, not just recall of individual hotspots.

### When
| Review | After Event | Events Covered |
|--------|------------|----------------|
| 1 | 14 (First Revelation) | 1–14 |
| 2 | 47 (Entry into Medina) | 15–47 |
| 3 | 82 (Throne Shook) | 48–82 |
| 4 | 120 (Peninsula Transforms) | 83–120 |
| 5 | 155 (You Are the Rawi) | 121–155 |

### User Flow
```
User completes final event of era → Verdict → XP → Chapter overlay
    ↓
NEW: "Chapter Review" screen appears
    ↓
Title: "مراجعة الفصل" / "Chapter Review"
Subtitle: "How well do you remember?"
    ↓
5–7 questions shown one at a time
    ↓
Each question: same Verdict UI (3 options, select one)
    → Correct: gold flash, move to next
    → Wrong: correct answer highlights, brief explanation, move on
    ↓
After all questions: score screen
    "You answered 5/7 correctly"
    ↓
If 5+ correct: "Master" badge for this era + bonus XP
If 3-4 correct: "Scholar" status + standard XP
If <3 correct: "Keep learning" + small XP + option to retry
    ↓
Returns to event list
```

### Question Types (cross-event)
These are harder than per-event Verdict questions because they
require remembering across multiple events:

Example for Review 1 (Events 1–14):
- "Which event happened first: the Opening of the Chest or the
  Death of Aminah?" (chronological ordering)
- "Two people called Muhammad ﷺ 'Al-Amin' before prophethood.
  One was the Quraysh. Who was the other?" (connecting events)
- "What do Halimah's milk and the land of Banu Sa'd have in
  common?" (thematic connection — both were blessed by his presence)

### Data Model
```dart
class ChapterReview {
  final int afterEventOrder;
  final String eraTitle;
  final String eraTitleAr;
  final List<ReviewQuestion> questions;
}

class ReviewQuestion {
  final String question;
  final String questionAr;
  final List<String> options;
  final List<String> optionsAr;
  final int correctIndex;
  final String explanation;
  final String explanationAr;
  final String sourceRef;
  final String sourceRefAr;
}
```

Store in `chapter_reviews.dart`. Content written after all events
in each era are complete.

### Event List Appearance
- Diamond-shaped node on timeline (rotated square)
- Gold bottom-accent border on card
- Label: "Chapter Review" / "مراجعة الفصل"
- Subtitle: "Test your knowledge across events"
- Transparent open book illustration on right half
- After completion: shows score badge (Master/Scholar/Keep learning)

---

## Event List Integration

All rhythm breakers appear on the event list between regular
events. The timeline thread (vertical gold line) connects
everything. Visual hierarchy:

```
Regular event:     Small gold dot (12px) + navy card, thin border
The Threshold:          Square gold node (16px) + gold left-accent border
Witness event:     Hollow circle (16px) + dashed border on event card
Chain:             Large gold dot (20px) + full gold border card
Collection badge:  Small icon on event card corner (not separate item)
Chapter Review:    Diamond node (16px rotated) + gold bottom-accent
```

All use navy + gold only. Differentiation through:
- Node shape (circle, square, diamond, hollow)
- Border style (solid, dashed, accent-left, accent-bottom)
- Font (sans for UI, serif for Chain and Witness)
- Transparent illustrations on right half of breaker cards

---

## Implementation Priority

The agent should build in this order:

**Sprint A — Feature building (standalone):**
1. **Hotspot layout variety** — just update scene config XY values
2. **The Threshold** — model + UI + threshold_challenges.dart (start with 2 thresholds for Events 1–15)
3. **The Witness Moment** — model + UI + witnessIntro on JourneyEvent
4. **Collection cards** — model + UI + collection gallery screen
5. **Chapter Review** — model + UI (content after events written)
6. **The Chain** — model + UI screen only (NO share_plus, defer sharing to post-launch)

**Sprint B — Event list integration:**
7. **Event list visual integration** — all breakers visible on timeline
   (only after Sprint A features are tested standalone)

Content for Thresholds, Witness Moments, and Collections for Events
1–20 will be provided as we write those events.

Chain content and Chapter Review questions come after full eras
are written.

---

## Agent Feedback Resolutions (April 8, 2026)

### 1. Naming: "The Gate" renamed to "The Threshold" (العَتَبة)
"The Gate" conflicts with the branching system's anchor hotspot
terminology. All references updated in this document.

### 2. Completion Flow Cap: 3 overlays maximum per event
A user completing a major milestone could see 6+ overlays stacked.
This causes fatigue, especially for younger users.

**Rule:** Maximum 3 overlays per event completion. Priority order:
1. Verdict (always)
2. XP celebration (always)
3. ONE special overlay (whichever applies):
   - Chain of Transmission, OR
   - Badge earned, OR
   - Chapter completion

Collection cards do NOT appear in the completion flow. Instead,
they queue and appear as a "welcome back" moment on the next
app open. Never stack Chain + Badge + Chapter on the same event.

### 3. Witness Moment vs Video Intro: pick one, not both
Some events (e.g., Event 34 Isra/Mi'raj) are listed for both a
video intro AND a Witness Moment. This creates a double opening.

**Rule:** Each event gets ONE cinematic opening, not both.
- If it has a Witness Moment (text crawl): no video intro
- If it has a video intro (Luma AI): no Witness Moment
- Witness Moments are for emotional/spiritual events (Isra/Mi'raj,
  Khadijah's death, Farewell Sermon)
- Video intros are for visual/action events (Badr, Uhud, Conquest)

### 4. Build Strategy: data models first, integrate into list later
Building 4 new interstitial types directly into `_buildListItems()`
risks breaking the existing event list.

**Rule:** Agent builds data models + standalone screens first in
Sprint A. Integrates into the event list in Sprint B. Do NOT
modify `_buildListItems()` until features are tested standalone.

### 5. Badge Triggers: leave as-is for now
Current badge triggers reference the old 36-event structure.
Do NOT update them now. Update after all 47 M1 events are written
and final globalOrders are confirmed.

### 6. Share Card: defer to post-launch
The Chain of Transmission's "Will you pass it on?" share card
requires the `share_plus` package. Do NOT add this dependency now.

**For now:** Build the Chain screen WITHOUT the share button.
Show the full chain, the quote, the user's name. End with
"Continue journey" only. Add sharing post-launch.

---

## Locked Decisions

| Decision | Status |
|----------|--------|
| All breakers use navy/gold palette only | ✅ |
| Transparent illustrations on right half of cards | ✅ |
| Hotspot layout varies per event | ✅ |
| Threshold every 5–7 events (renamed from "Gate") | ✅ |
| Witness Moment on ~10 major events | ✅ |
| Chain every 25 events (6 total) | ✅ |
| Collection cards on select events | ✅ |
| Chapter Review at end of each era (5 total) | ✅ |
| All visible on event list with distinct visual treatments | ✅ |
| Max 3 overlays per event completion | ✅ |
| Witness Moment OR Video Intro, never both | ✅ |
| Build data models first, integrate into list later | ✅ |
| Badge triggers: leave as-is until M1 content complete | ✅ |
| Share card deferred to post-launch | ✅ |
| "The Threshold" (العَتَبة) not "The Gate" (البوابة) | ✅ |
