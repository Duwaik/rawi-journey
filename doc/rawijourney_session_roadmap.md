# RawiJourney — Session Agreements & Roadmap

## Summary

This document captures every change, fix, and enhancement agreed upon
during the product strategy session. Organized by priority phase.

---

## Phase 1 — MVP Critical (Before Launch)

### 1.1 Branching System ✅ SPECCED
**Status:** Spec delivered. Agent has 4-sprint plan (Sprints 21–24).

Merge linear hotspot exploration + separate "Moment of Reflection"
question screen into an integrated branching flow:
- Anchor hotspot (mandatory first stop)
- Branch decision card (in-scene, gold-pulsing border, two options)
- User-chosen hotspot order (both visited, sequence changes)
- Convergence hotspot (all paths lead here)
- Question rendered in-scene as bottom sheet over dimmed scene
- "Moment of Reflection" overlay screen REMOVED

**Data model:** BranchPoint, BranchOption (new models). Optional fields
on JourneyEvent (anchorHotspotId, branchPoint, convergenceHotspotId).
pathWaypointsAlt on SceneConfig. Backward compatible — Events 4–36
continue working linearly.

**Content written for:** Events 1, 2, and 3 (all branch points,
convergence fragments, walking path variants).

**Agent note:** Add guard — events without branchPoint must resolve to
linear flow. Test both branch paths for all 3 events.

---

### 1.2 Companion Avatars ✅ DONE
**Status:** All 4 images generated and selected.

- Male onboarding: Set 1, bottom-left
- Female onboarding: Set 1, top-left
- Male in-scene: Last set, bottom-right (upward contemplative gaze)
- Female in-scene: Final set, top-left (matched gaze/lighting)

Hand to agent for asset replacement in Flutter.

---

### 1.3 Hotspot Card Images ⬜ IN PROGRESS
**Status:** 12 prompts ready in rawijourney_visual_prompts_600.md.
Khaled generating via Bing Image Creator.

Events 1, 2, 3 — four hotspot images each. Key style rules:
- Square composition
- No faces (hands, objects, architecture, atmosphere only)
- Painterly style matching scene backgrounds
- Warm golden-hour earth tone palette

---

### 1.4 Known Bugs (From Previous Sessions)
**Status:** Outstanding — assign to agent.

- **ProfileScreen language change:** Doesn't reflect instantly. Needs
  pop-before-runApp fix.
- **Android display name:** Still showing "deenquest_new" in
  AndroidManifest.xml. Update to "RawiJourney" (or final app name).

---

## Phase 2 — Launch Enhancements (Ship With or Shortly After)

### 2.1 "Go Deeper" Content Layer
**What:** Every hotspot card and every "History Records" explanation gets
an expandable "Go Deeper" section — 1–2 paragraphs with actual source
references, scholarly context, hadith citations, and historical nuance.

**Why:** Solves the "am I only targeting kids?" problem without
redesigning anything. Kids skip it, adults love it. Same content, two
depths — like Wikipedia's simple vs full article.

**Implementation:** Add optional `deeperContent` and `deeperContentAr`
fields to SceneHotspot and JourneyQuestion models. Render as a
collapsible section below the main fragment/explanation. Icon: a book
or scroll emoji with "Go Deeper" / "تعمّق أكثر" label.

**Content scope for MVP:** 12 hotspot cards + 3 question explanations =
15 "Go Deeper" sections to write for Events 1–3.

---

### 2.2 Transition Screen Update
**What:** The event intro transition (black screen → "500 CE / Arabian
Peninsula / Arabia Before the Light") currently works well but could
be enhanced to better bridge the events list and the scene.

**Possible improvements:**
- Brief 1-sentence narrative teaser below the title that sets the mood
  before the scene loads (e.g., "The Ka'bah stands surrounded by 360
  idols. Something is coming.")
- Subtle particle effect or ambient sound starting on this screen to
  begin the immersion before the scene
- Consider showing the chapter name ("Jahiliyyah — Pre-Islamic Arabia")
  as a small label above the date

**Priority:** Low — current version is already 9/10. These are polish.

---

### 2.3 Streak & Mastery Loops
**What:** Visual knowledge map showing the user's mastery progress across
chapters and eras.

**Display:** "You've mastered the Jahiliyyah period. You're 40% through
Early Life. You haven't started the Meccan period."

**Why:** Progress visualization is addictive in a healthy way. Gives
returning users a reason to come back — they can see what they haven't
mastered yet.

**Implementation:** Leverage existing spaced repetition quiz system with
5-session Review Pool cooldown. Add a mastery map screen (or section on
Profile/Home) showing chapter-level completion percentages. Color-code:
gold = mastered, teal = in progress, gray = locked.

---

### 2.4 Timed Challenge Mode
**What:** "How many can you answer in 60 seconds?" mode on
already-mastered content.

**Why:** Almost zero new infrastructure. Adds replayability and a reason
to return after completing all events. Competitive against yourself.

**Implementation:** New screen accessible from Home. Pulls questions
from the Mastered Questions collection. Timer countdown UI. Score
tracked as personal best. Could show streak counter during the
challenge.

---

### 2.5 Collections & Discovery
**What:** Tag every hotspot card with one or more thematic collections.
Users see a gallery of collections with progress.

**Example collections from existing content:**
- "Women of Early Islam" (Khadijah, Halima, Aminah...)
- "Firsts in Islam" (first believer, first mu'adhin, first martyr...)
- "Battles & Turning Points" (Badr, Uhud, Trench, Hunayn...)
- "Companions" (Abu Bakr, Umar, Uthman, Ali, Bilal, Mus'ab...)
- "Places of the Seerah" (Mecca, Medina, Ta'if, Abyssinia, Tabuk...)
- "Moments of Mercy" (Ta'if supplication, Conquest forgiveness...)
- "Covenants & Treaties" (Hilf al-Fudul, Aqabah, Hudaybiyyah...)

**Display:** Collection gallery screen. Each collection shows "7/12
discovered" with silhouette placeholders for undiscovered items. Cards
auto-populate as user plays through events.

**Implementation:** Add `collections` tag list field to SceneHotspot
(e.g., `['companions', 'firsts']`). New CollectionsScreen with grid
of collection cards. One metadata + UI layer, zero new content needed.

---

## Phase 3 — Post-Launch Growth

### 3.1 Events List Visual Upgrade
**What:** Replace the flat list screen with something more visual —
a stylized map, illustrated timeline, or chapter-based visual navigation.

**Why:** Currently the most "app-like" screen after a cinematic intro.
Creates a slight letdown. Post-launch improvement when there's user
feedback on navigation patterns.

---

### 3.2 Language Expansion
**What:** Add Turkish, Urdu, Bahasa Indonesian, French (West Africa)
as additional language options.

**Why:** Massively expands addressable market. The bilingual AR/EN
foundation makes this straightforward — it's content translation
(verified) on existing architecture.

**Priority:** Post-launch, after validating with AR/EN users first.

---

### 3.3 Pricing Strategy
**Agreed approach:**
- Launch at $3.99–$4.99 for the MVP (Events 1–3 + quiz mechanics)
- As content expands to full Prophetic era (36 events), raise to $9.99
  for new users
- Consider expansion pack model: base app + era packs ($2.99 each) for
  Khulafa' al-Rashidun, Umayyad, Abbasid, Al-Andalus, Ottoman
- Institutional licensing to Islamic schools as future revenue stream

---

### 3.4 Content Expansion Roadmap
**Post-MVP eras (from previous sessions):**
- السيرة النبوية الشريفة (full 36 events — MVP is first 3)
- الصحابة الكرام
- Expanded علماء المسلمين

**Content pillars for each era:**
- Narrative events with branching hotspots
- Quiz questions per event
- "Go Deeper" scholarly content
- Collections metadata tagging
- Scene backgrounds + hotspot card images
- Bilingual content (AR/EN minimum)

---

### 3.5 Visual Content Pipeline
**Phased approach (from previous sessions):**
- **v1 (MVP):** Midjourney/Bing pre-generated images
- **v2:** Firebase CMS for content management
- **v3:** AI-assisted generation with approval workflow

---

## Implementation Order (Recommended)

| Priority | Item | Owner | Effort |
|----------|------|-------|--------|
| 1 | Branching system (Sprints 21–24) | Agent | 4 sprints |
| 2 | Avatar replacement | Agent | 1 task |
| 3 | Hotspot card images | Khaled (Bing) | 12 images |
| 4 | Bug fixes (ProfileScreen, manifest) | Agent | 1 sprint |
| 5 | "Go Deeper" content layer | Agent + Khaled | 2 sprints |
| 6 | Transition screen polish | Agent | 1 sprint |
| 7 | Collections metadata + UI | Agent | 2 sprints |
| 8 | Timed challenge mode | Agent | 1 sprint |
| 9 | Streak/mastery visualization | Agent | 2 sprints |
| 10 | Events list visual upgrade | Agent | 2–3 sprints |

---

## Design Decisions Locked This Session

1. Branching system replaces linear exploration + separate question
2. Joystick stays — path just routes to correct hotspot
3. Question renders as bottom sheet over dimmed scene, not separate screen
4. "Moment of Reflection" overlay eliminated
5. Companion avatars: painterly style, upward contemplative gaze for in-scene
6. Hotspot card images: no faces, square, painterly, earth tones
7. "Go Deeper" as collapsible section solves the adults vs kids problem
8. Collections are metadata layer on existing content, not new content
9. Events without branchPoint keep working linearly (backward compatible)
10. Progress counter still 0/4 → 4/4 (anchor + 2 branch + convergence)
