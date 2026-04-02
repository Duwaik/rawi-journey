# RawiJourney — Events List Screen Redesign Spec

## Overview

The events list screen (the main RAWI - The Seerah screen) needs a
visual upgrade from a flat numbered list to a timeline-based journey
view. The functionality stays the same — the user sees all 36 events,
taps Play on the current one, locked events show a lock. What changes
is the visual presentation to feel like a journey map rather than a
settings menu.

The header (RAWI logo, progress counter, XP, settings gear) stays
as it is with one exception: the subtitle beneath "RAWI" becomes
contextual (see Change 5 below). The list body below the header is
where the main visual changes happen.

---

## Change 1: Chapter Headers

### What
Insert visual section dividers between event groups based on the `era`
field that already exists on every JourneyEvent.

### Chapters
- **JAHILIYYAH** — "Pre-Islamic Arabia" — Events 1–3
- **EARLY LIFE** — "570 – 610 CE" — Events 4–11
- **MECCA** — "610 – 622 CE" — Events 12–22
- **MEDINA** — "622 – 632 CE" — Events 23–36

### Design
Each chapter header is a horizontal row containing:
- A short gold line (24px wide, 1px tall, color: gold accent #c9a84c)
- Chapter name in gold, 11px, uppercase, letter-spacing 1.5px, weight 500
- Era subtitle in muted teal/gray, 10px, normal case
- A flex-expanded thin line filling the rest (1px tall, dark: #1e3040)

The header sits between the last event of the previous chapter and the
first event of the new chapter, with 12px padding above and 8px below.

### Logic
Group the m1Events list by `event.era` (JourneyEra.jahiliyyah,
JourneyEra.earlyLife, JourneyEra.mecca, JourneyEra.medina). Before
rendering the first event of each group, insert the chapter header
widget. Use a map of era to display name and subtitle.

---

## Change 2: Timeline Thread

### What
Replace the numbered circles on the left side of each event card with
a vertical timeline line and node dots.

### Structure
Each event row becomes a Row with two children:
1. **Timeline column** (fixed width: 32px) — contains a dot and a
   vertical line segment
2. **Event card** (expanded) — the existing card content

### Timeline Column Layout
The column is a Column with:
- A circle (the node dot) at the top, centered
- A vertical line (Container with width 1.5px) filling the remaining
  height, centered

The line connects each event to the next. The last event in the entire
list has no line below its dot.

### Node Dot States

**Completed event:**
- Solid gold filled circle
- Size: 12px diameter
- Color: gold accent (#c9a84c)
- Border: 2px solid gold

**Current event (next to play):**
- Hollow circle with gold border
- Size: 14px diameter (slightly larger)
- Background: app background color (#0a1520)
- Border: 2px solid gold
- Optional: subtle gold glow/shadow (box-shadow equivalent)

**Locked event:**
- Small dimmed circle
- Size: 10px diameter
- Background: dark muted (#1e3040)
- Border: 1.5px solid slightly lighter (#2a4050)

### Timeline Line States

**Between completed events:** Gold line (#c9a84c), 1.5px wide
**Between completed and current:** Gold line
**Between current and locked:** Dark muted line (#1e3040), 1.5px wide
**Between locked events:** Dark muted line

---

## Change 3: Event Card Visual States

### Completed Event Card
- Border: 1px solid gold at 25% opacity (#c9a84c40)
- Background: subtle warm tint — very dark warm brown at low opacity
  overlaid on the base card color. Think of the current card color but
  with a slight warm golden warmth to it.
- The numbered circle is REMOVED (replaced by timeline dot). In its
  place, show a small green/gold checkmark icon inside a dark circle.
- Event title: warm cream color (#e8d8b8), 14px, weight 500
- Subtitle (location + date): muted teal (#6a8a7a), 11px
- Right side: shows "4/4" text in gold, small
- Hotspot progress dots: 4 small circles (8px each) in a row under
  the subtitle. All filled gold for completed events.
- Corner radius: 12px

### Current Event Card (Next to Play)
- Border: 1px solid gold at 40% opacity (#c9a84c60) — slightly
  brighter than completed
- Background: similar warm tint but at lower opacity
- Number circle: 32px, dark background (#1a2030), 1px gold border at
  40% opacity, number in gold, weight 500
- Event title: warm cream (#e8d8b8), 14px, weight 500
- Subtitle: muted teal (#6a8a7a), 11px
- Hotspot progress dots: 4 small circles, all empty (border only,
  #3a5a5a) since the event hasn't been played yet
- Right side: Gold "Play" button — background #c9a84c, text dark
  (#0a1520), 12px weight 500, padding 6px 16px, border-radius 8px
- Corner radius: 12px

### Locked Event Card
- Border: 0.5px solid dark muted (#1e3040)
- Background: no special tint, base card color
- Entire card at 50% opacity
- Number circle: 32px, very dark (#0e1a24), number in muted (#3a5a5a)
- Event title: muted (#5a7a7a), 14px, weight 500
- Subtitle: darker muted (#3a5a5a), 11px
- No hotspot progress dots shown
- Right side: small lock icon (16px) in muted color (#3a5a5a)
- Corner radius: 12px

---

## Change 4: Hotspot Progress Dots

### What
Replace the text-based "0/4" or "4/4" counter on each card with a row
of small circular dots representing each hotspot in the event.

### Design
- Row of circles, one per hotspot (most events have 4)
- Each circle: 8px diameter, 4px gap between them
- Positioned below the subtitle line, with 4px margin-top

### States
- **Discovered hotspot:** Filled solid gold (#c9a84c)
- **Undiscovered hotspot:** Empty circle with muted border (1px solid
  #3a5a5a), transparent fill

### Data
Use the existing hotspot progress data from PrefsService. The count of
hotspots per event comes from the sceneConfigs map (number of hotspots
in the SceneConfig for that event ID). The number discovered comes from
the saved progress.

### Visibility
- Completed events: show dots, all filled
- Current event: show dots, filled based on progress (likely all empty
  if not started, partially filled if in progress)
- Locked events: do NOT show dots

---

## Change 5: Contextual Module Subtitle

### What
The subtitle beneath the "RAWI" logo in the header currently reads
"The Seerah" and is hardcoded. Change it to be driven by the current
module's data so it adapts when future eras are added.

### Why
RawiJourney will eventually cover multiple eras beyond the Prophetic
Seerah — Companions, Umayyad, Abbasid, Al-Andalus, Ottoman. "The
Seerah" only applies to M1. The subtitle should reflect whichever
module the user is currently browsing.

### Implementation
Add `subtitle` and `subtitleAr` fields to the module data (or
wherever the M1 metadata lives). The header reads from this field
instead of a hardcoded string.

### Module Subtitles (Current + Future)
| Module | English Subtitle | Arabic Subtitle |
|--------|-----------------|-----------------|
| M1 — Prophetic Journey | The Seerah | السيرة النبوية |
| M2 — Companions (future) | The Companions | الصحابة الكرام |
| M3 — Golden Age (future) | The Golden Age | العصر الذهبي |
| M4 — Al-Andalus (future) | Al-Andalus | الأندلس |

### For MVP
Only M1 exists, so the subtitle shows "The Seerah" / "السيرة النبوية".
But the code should read from a data field, not a hardcoded string,
so no code changes are needed when M2 is added later.

---

## Implementation Notes

### What NOT to Change
- Header bar layout (RAWI logo, counters, settings) — keep as-is
  (only the subtitle text changes — see Change 5)
- Event data structure — no model changes needed
- Navigation behavior — tapping Play still opens the cinematic
  transition then the event scene
- Lock/unlock logic — stays the same
- Scroll behavior — still a scrollable list

### Build Order
1. Add chapter header widget and grouping logic
2. Replace left-side number with timeline column
3. Update card visual states (borders, tints, opacity)
4. Add hotspot progress dots
5. Test with various progress states (no events done, some done, all
   in a chapter done)

### RTL Consideration
When the app is in Arabic mode, the timeline thread should appear on
the RIGHT side instead of the left. The chapter headers read
right-to-left. The card content flips as usual. Make sure the timeline
column respects the app's directionality setting.

### Arabic Chapter Names
- JAHILIYYAH → الجاهلية — "الجزيرة قبل الإسلام"
- EARLY LIFE → النشأة — "570 – 610 م"
- MECCA → مكة المكرمة — "610 – 622 م"
- MEDINA → المدينة المنورة — "622 – 632 م"

### Performance
The list is 36 items maximum. No lazy loading needed. However, use
const constructors for the timeline dots and chapter headers where
possible to avoid unnecessary rebuilds.
