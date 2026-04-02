# RawiJourney — UI Fixes from Screenshot Review

## Overview

Four fixes from the in-app screenshot review session. These share a
common design thread: the cinematic transition screen (black background,
gold particles, gold typography) is the visual high point of the app.
Fixes #1 and #4 extend that cinematic language to two other screens
that currently don't match it.

---

## Fix 1: Chapter Preview (Onboarding Page 4) — Cinematic Redesign

### Current Problem
The chapter preview page ("YOUR JOURNEY SPANS FOUR CHAPTERS") uses
flat cards on a dark background. It doesn't match the cinematic quality
of the transition screen that immediately follows it. The content is
right — showing the user what eras they'll explore — but the
presentation is mismatched.

### What to Do
Redesign this page to follow the cinematic transition screen's visual
language: black background, gold floating particles, elegant gold
typography, atmospheric and immersive.

### Design Direction
- **Background:** Solid black/very dark, matching the transition screen.
  Add the same gold dust particle effect used on the transition screen.
- **Title:** "YOUR JOURNEY SPANS FOUR CHAPTERS" in the same gold serif
  typography used on the transition screen. Centered, elegant, with
  the same fade-in animation timing.
- **Chapter cards:** NOT flat cards. Instead, render each chapter as
  a text block in the same cinematic style:

  ```
  ── gold line ──

  JAHILIYYAH
  Pre-Islamic Arabia
  3 events

  ── gold line ──

  EARLY LIFE
  The Prophetic Childhood
  8 events

  ── gold line ──

  MECCA
  The Call and the Struggle
  11 events

  ── gold line ──

  MEDINA
  The Community and the Victory
  14 events

  ── gold line ──
  ```

  Each chapter name in gold uppercase (matching era headers on the
  events list). Subtitle in muted cream. Event count in small muted
  text. Separated by thin gold lines — same as the transition screen
  separator.

- **Only the current/unlocked era has full opacity.** Future eras are
  visible but dimmed (40-50% opacity), creating anticipation without
  false promises.
- **No numbered circles.** No card borders. No lock icons. This is a
  cinematic preview, not a UI list. The events list screen handles
  the interactive elements.
- **"Start the Journey →" button** stays at bottom, gold, same style
  as the "Begin" button on the intro.

### Arabic Version
- Chapter names: الجاهلية، النشأة، مكة المكرمة، المدينة المنورة
- Subtitles: الجزيرة قبل الإسلام، الطفولة النبوية، الدعوة والابتلاء،
  المجتمع والنصر
- Same layout direction (RTL), same cinematic style.

### Chapter Data
Use accurate event counts from the actual m1Events data:
| Chapter | English Name | Events |
|---------|-------------|--------|
| Jahiliyyah | Pre-Islamic Arabia | 3 |
| Early Life | The Prophetic Childhood | 8 |
| Mecca | The Call and the Struggle | 11 |
| Medina | The Community and the Victory | 14 |

Total: 36 events. Display "36 events across the Prophetic era" or
similar as a summary line if desired.

---

## Fix 2: Locked Hotspot Visibility

### Current Problem
Locked hotspot diamonds are nearly invisible against the scene
background. The warm brown/gold diamonds blend into the warm brown/gold
environment at 60% dimmed opacity.

### What to Do
Add a contrast backing behind each locked hotspot diamond so it reads
against any scene background.

### Implementation
- Add a semi-transparent dark circle (40px diameter, black at 40%
  opacity) behind each locked hotspot diamond marker.
- The diamond icon and lock indicator sit on top of this backing.
- This creates guaranteed contrast regardless of the scene colors
  underneath — dark backing + light diamond = always visible.
- Active (pulsing gold) hotspots do NOT need the backing — their
  animation already creates sufficient visibility.
- Visited (green checkmark) hotspots do NOT need the backing.

### Why Not Just Increase Opacity
Higher opacity on the diamond alone won't solve it — the problem is
color similarity, not brightness. A gold diamond on a gold-toned scene
needs contrast separation, which only a dark backing provides.

---

## Fix 3: Remove The Crossroads Tutorial Overlay

### Current Problem
The first-time tutorial for The Crossroads ("THE CROSSROADS — You have
witnessed what happened. Now choose your path...") renders as a
semi-transparent overlay directly on top of the branch decision card.
Both layers of text are visible simultaneously, bleeding into each
other. The result is unreadable.

### What to Do
Remove the tutorial overlay entirely. Delete the widget and the
first-time check flag.

### Why
The branch decision card is self-explanatory. It shows a narrative
prompt and two clearly tappable options with distinct labels. A user
who has already navigated to a hotspot with a joystick, read a
discovery card, and tapped to continue does not need instructions to
tap one of two buttons.

If a tutorial is truly needed later, it should appear BEFORE the card
(as its own full-screen step) and dismiss completely before the card
is revealed — never as an overlay on top of interactive content. But
for now, remove it entirely.

---

## Fix 4: The Verdict — Cinematic Styling

### Current Problem
The Verdict (convergence question) card looks identical to regular
hotspot discovery cards — same dark card, same teal-ish borders, same
styling. It doesn't signal "this is the climactic moment of the event."

### What to Do
Apply the cinematic transition screen's visual language to The Verdict
card, creating consistency across the three key atmospheric moments:
transition screen → chapter preview → The Verdict.

### Design Changes

**Card border:** Change from standard teal/dark border to gold border
(#c9a84c at 40-50% opacity). This matches The Crossroads card style
and visually links the two choice moments as a pair.

**"What does history remember?"** — render this line in gold (#c9a84c),
not the current muted gray. This is the signature prompt. Make it the
visual anchor of the card. Use the same serif font used on the
cinematic transition screen if possible.

**Scene dim overlay:** Increase from current ~40% to 60-70% opacity.
The scene should feel like it's holding its breath. The card must
command full attention.

**Icon above card:** Replace the green checkmark with a gold crescent
moon icon (matching the RAWI brand) or remove it entirely. The green
check says "done" — but The Verdict is about to begin, not end.

**Answer option borders:** Change from teal to gold at low opacity
(#c9a84c at 30%). When the user taps the correct answer, the border
fills to full gold opacity with a gold checkmark. Wrong options dim
to 20% opacity. This creates a gold reveal moment.

**"History records..." section:** After the user answers, the
explanation section animates in. The "History records..." label and
crescent icon should be gold. The explanation text stays cream/white.

**"Back to Events →" button:** Only appears AFTER the user has answered
and read the explanation. Never visible before answering. Style it
with a gold border or gold text to match the card's elevated treatment.

**Gold dust particles:** If technically feasible without performance
issues, add a subtle gold particle effect behind the card (same as
transition screen particles) to create that cinematic atmosphere
during The Verdict. This is a nice-to-have, not a blocker.

### Consistency Thread
The three "cinematic" moments in the app should share a visual DNA:
1. **Cinematic transition** (entering an event) — black, gold text,
   particles, atmospheric
2. **Chapter preview** (onboarding page 4) — same language, chapter
   overview content
3. **The Verdict** (ending an event) — same language, question +
   reveal content

This creates a bookend effect: the user enters an event through a
cinematic moment and exits through one. Everything in between (scene
exploration, hotspot cards, The Crossroads) uses the in-scene card
styling. The cinematic language is reserved for transitions and
climactic moments.

---

## Implementation Order

| Priority | Fix | Effort |
|----------|-----|--------|
| 1 | Fix 3: Remove Crossroads tutorial | 10 minutes |
| 2 | Fix 2: Locked hotspot backing | 30 minutes |
| 3 | Fix 4: The Verdict cinematic styling | 1–2 hours |
| 4 | Fix 1: Chapter preview redesign | 2–3 hours |

Fix 3 is a deletion — do it first. Fix 2 is a small visual addition.
Fix 4 is styling changes on an existing widget. Fix 1 is the most
work since it's a redesign of an existing onboarding page.
