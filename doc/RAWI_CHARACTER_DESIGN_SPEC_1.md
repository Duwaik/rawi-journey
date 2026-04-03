# RawiJourney — Rawi & Rawiah Character Design Spec

> **Date:** April 3, 2026
> **Status:** LOCKED — concept and direction agreed
> **Scope:** Character identity, visual design, in-app behavior,
> brand extension
> **Principle:** The Rawi (راوي) and Rawiah (راوية) are not avatars.
> They are characters — the emotional anchor of the entire experience.

---

## 1. The Concept

### Who They Are
In Islamic tradition, a **Rawi** is the human link in the chain of
narration (isnad) — the person who witnesses an event and carries the
account forward so it reaches the next generation. Every hadith you've
ever read reached you because a Rawi carried it.

The **Rawi** (male) and **Rawiah** (female) are fictional characters
— timeless young travelers who move through Islamic history as
witnesses. They are not Sahabah. They are not historical figures.
They exist outside time, present at every moment, with one purpose:
to witness and carry truth.

The user doesn't just control them. The user **becomes** them.

### Why They Matter
- Every Muslim who teaches their child about the Seerah is being
  a Rawi. The character makes that role visible and aspirational.
- Muslim women are specifically honored — the Rawiah is not an
  afterthought or a gender swap. She is a narrator in her own
  right. Aisha رضي الله عنها narrated over 2,200 hadith. The
  tradition of female Rawis is foundational, not supplementary.
- The characters create an emotional anchor — someone to journey
  WITH, not just a cursor moving between hotspots.
- A well-designed character becomes a brand that lives beyond the
  app — recognizable, shareable, cultural.

---

## 2. Visual Identity

### Design Principles
1. **Silhouette-first.** At 20 pixels on a phone notification or at
   500 pixels on a poster, the character must be instantly recognizable
   from outline alone. Think Miyazaki, not Marvel.
2. **Painterly, warm, cinematic.** Same art direction as every other
   visual in Rawi — golden-hour lighting, earth tones, handcrafted.
3. **No specific ethnicity.** The Rawi/Rawiah should feel universal
   to the Muslim ummah — not specifically Arab, South Asian, African,
   or European. Warm skin tone, features that don't anchor to one
   region. Every Muslim should be able to see themselves.
4. **Modest, dignified, timeless.** Clothing is simple, flowing,
   non-era-specific. Not 7th century Arabian and not modern — timeless.
5. **The scroll is the signature.** Both characters carry a scroll —
   the physical representation of their purpose. It's their
   equivalent of a lightsaber or shield. Instantly identifies them.

### Rawi (Male) — Visual Elements
- Simple flowing cloak/thobe in warm earth tones (sand, deep brown)
- Head covering (loosely draped, not era-specific)
- Carries a scroll — held at the side or tucked under arm
- Upward contemplative gaze (already established in current avatar)
- Warm golden circle border (already in app — this becomes the
  character's "frame" across all contexts)
- Clean, youthful face — not a boy, not old. Ageless traveler.

### Rawiah (Female) — Visual Elements
- Flowing modest dress/abaya in complementary earth tones
  (deeper tones — burgundy-brown, olive, warm navy)
- Hijab draped naturally, catching golden-hour light
- Carries the same scroll — held with both hands or at her side
- Same contemplative gaze, same warm golden circle frame
- Equally dignified presence — not softer, not smaller. Equal.

### Signature Silhouette (Both)
The recognizable shape from any distance:
- Standing figure with slight forward lean (moving through history)
- Cloak/dress catching wind (sense of journey, movement)
- Scroll visible at the side or in hand
- Golden circle halo/frame around the figure

This silhouette becomes the brand mark. It appears on:
- App icon (already exists — refine to match character design)
- Loading screens
- Social share cards
- Badge overlay frames
- Future merchandise
- Print materials

### Art Generation
- **Tool:** Bing Image Creator (same pipeline as all Rawi art)
- **Deliverables per character:**
  1. Full portrait (onboarding selection screen) — warm, approachable
  2. In-scene figure (exploration) — smaller, walking pose, side view
  3. Contemplative pose (Verdict/chapter completion) — reflective
  4. Celebrating pose (badge/XP moments) — subtle joy, scroll raised
  5. Silhouette version (brand mark) — clean outline, no detail
- **Total: 10 images (5 per character)**

---

## 3. In-App Behavior

### Current State → Target State

| Aspect | Current | Target |
|--------|---------|--------|
| Identity | "Companion" — generic avatar | **The Rawi / Rawiah** — named character |
| Role | Follows user, shows bubbles | Witnesses history, reacts, narrates |
| Visual | Static circle, one pose | Multiple poses matching emotional context |
| Speech | Functional nudges ("explore!") | Reflective narration + guidance |
| Growth | Same from Event 1 to 36 | Visually evolves across the journey |
| Name usage | "You" label below figure | User's name integrated into dialogue |

### 3.1 — Emotional Poses (4 States)

The character has 4 visual states, each a separate asset:

| State | When | Visual |
|-------|------|--------|
| **Walking** | Joystick active, exploring | Current walking animation — side view, slight bob |
| **Witnessing** | Hotspot discovered, panel open | Standing still, facing the hotspot, slight head tilt — taking it in |
| **Reflecting** | Verdict question, chapter completion | Head slightly bowed, scroll held close to chest — weight of history |
| **Carrying** | Badge earned, event completed | Scroll raised slightly, gentle upward gaze — purpose fulfilled |

Implementation: 4 image assets per character × 2 characters = 8 images.
Swap based on `_phase` and current interaction state.

### 3.2 — Narration Voice (Speech Bubbles)

Replace functional nudge text with narration that fits the character's
role as a witness and storyteller.

**Current examples (functional):**
- "Explore the scene!"
- "Tap the glowing hotspot"
- "Keep going, you're almost there!"

**Target examples (narrative):**

Idle — first discovery:
- EN: "Do you feel it? History is waiting to be witnessed."
- AR: "هل تشعر بذلك؟ التاريخ ينتظر من يشهده."

After hotspot discovery:
- EN: "Remember this. Someone must carry it forward."
- AR: "تذكّر هذا. لا بد من راوٍ يحمل الرواية."

Near convergence hotspot:
- EN: "Every path leads to the same truth."
- AR: "كل الطرق تقود إلى الحقيقة ذاتها."

After Verdict answered:
- EN: "Now you know what history remembers."
- AR: "الآن تعلم ما يحفظه التاريخ."

Chapter completion:
- EN: "We have witnessed an era, [name]. The story continues."
- AR: "شهدنا حقبة كاملة يا [name]. الرواية تستمر."

Post-discovery nudge (using user's name):
- EN: "What else will you uncover, [name]?"
- AR: "ماذا ستكشف أيضاً يا [name]؟"

### 3.3 — Growth System

The Rawi/Rawiah visually evolves as the user progresses. Subtle
changes that reward long-term players.

| Stage | Event Range | Visual Change |
|-------|-------------|---------------|
| Novice | Events 1–11 | Base appearance. Scroll is short/new. Golden circle is thin. |
| Journeyer | Events 12–22 | Scroll slightly longer. Golden circle slightly brighter. Cloak has subtle gold trim at the edge. |
| Keeper | Events 23–36 | Scroll clearly longer, showing use. Golden circle warm and full. Cloak gold trim more visible. Posture carries more weight. |
| The Rawi | All 36 complete | Full radiance. Scroll illuminated. Golden circle glows. The character has become the narrator. |

Implementation: 4 tiers × 4 poses × 2 characters = 32 assets total.
This is the full vision. **For MVP, start with 1 tier (Novice) — 8
assets. Add growth tiers post-MVP.** The system just checks
`PrefsService.currentOrder` and swaps the asset set.

---

## 4. Onboarding Integration

### Current Registration Step 2: "Choose your companion"
Shows male/female avatar selection.

### Updated Registration Step 2: "Who carries the story?"
Frame the choice as identity, not avatar selection:

- EN: "Every great story needs a narrator. Who carries this one?"
- AR: "كل رواية عظيمة تحتاج راوياً. من يحمل هذه الرواية؟"

Two cards:
- **Rawi (راوي)** — male character portrait
- **Rawiah (راوية)** — female character portrait

Gold border on selection. The choice feels meaningful — not "pick a
skin" but "who are you in this story?"

---

## 5. Screen Presence Map

The Rawi/Rawiah appears across the app in two modes:
- **Active** — large, animated, the character IS the experience
- **Ambient** — smaller, static, the character is WITH you quietly

The balance: present enough to feel like a real companion, restrained
enough to never feel like wallpaper.

### 5.1 — Active Presence (Character IS the Experience)

These are the moments where the character is large, central, and
driving the emotional register of the screen.

#### Exploration Scene (existing — enhance)
- **Where:** Full in-scene gameplay
- **Pose:** Walking (joystick active), Witnessing (hotspot open)
- **Size:** ~64px figure in the scene
- **Behavior:** Walks the path, faces discovered hotspots, speech
  bubbles with narrative voice, addresses user by name
- **Already exists** — enhance with pose-swapping and narrative dialogue

#### Verdict Moment
- **Where:** The Verdict question card (branching events)
- **Pose:** Reflecting — head slightly bowed, scroll held close
- **Size:** ~80px, positioned beside the question card (left side
  for EN, right side for AR)
- **Behavior:** Static during question. After answer reveals, a subtle
  shift — scroll held closer, as if recording what history remembers.
  Does NOT block the question text or answer options.

#### Chapter Completion
- **Where:** Era complete cinematic screen
- **Pose:** Reflecting — scroll held close, weight of what they've
  witnessed
- **Size:** Large — ~120px centered or left-aligned with closing
  narrative text beside them
- **Behavior:** Fades in with the chapter closing line. Static. The
  moment is about stillness and gravity. Gold particles drift around
  them.
- **Text beside them:** "We have witnessed an era, [name]. The story
  continues." / "شهدنا حقبة كاملة يا [name]. الرواية تستمر."

#### Badge Earned
- **Where:** Badge overlay popup
- **Pose:** Carrying — scroll raised slightly, gentle upward gaze
- **Size:** ~60px, below the badge artwork
- **Behavior:** Appears with the badge card. Character silhouette
  grounds the badge — "your narrator earned this."

#### XP Celebration
- **Where:** XP popup overlay (after badge, or standalone)
- **Pose:** Carrying — scroll raised
- **Size:** ~48px, beside the XP count-up animation
- **Behavior:** Present during the count-up. Fades out with the
  popup. Subtle — the XP number is the focus, the character is
  the context.

### 5.2 — Ambient Presence (Character is WITH You)

These are the quieter moments — the character appears at smaller
scale as a constant companion. Not animated, not interactive. Just
present. Like a friend sitting in the room while you browse.

#### Splash Screen (Returning Users)
- **Where:** App resume / returning user splash
- **Size:** ~40px silhouette beside the RAWI logo
- **Behavior:** Fades in with the logo. Below the logo or to its
  right: "Welcome back, [name]" / "أهلاً بعودتك يا [name]" in
  small gold text.
- **Why:** The first thing the user sees is their narrator welcoming
  them back. The app remembers them.

#### Event List Header
- **Where:** Top of the event list screen, beside "RAWI / The Seerah"
- **Size:** ~48px portrait (circular, golden frame — same as in-scene
  but smaller)
- **Placement:** Left of the title for EN, right for AR. Sits in the
  header bar area alongside the progress counter and XP badge.
- **Behavior:** Static. Tapping it could navigate to the profile
  section in settings (future enhancement).
- **Why:** The character anchors the journey screen. They're surveying
  the timeline with you.

#### Settings — Profile Section
- **Where:** Top of settings screen, the profile area
- **Size:** ~80px portrait (circular, golden frame)
- **Layout:** Character portrait on the left. Beside it:
  - User's name (large, gold)
  - "Rawi since [month year]" / "راوي منذ [month year]"
  - XP total + streak
  - Badges earned count
- **Behavior:** Static. This IS the user's identity in the app. The
  character portrait and the user's name together form the profile.
- **Why:** Makes SharedPreferences data feel like a real profile.
  Emotional ownership.

#### Intro Cinematic
- **Where:** First-launch cinematic (570 CE / Arabian Peninsula...)
- **Size:** ~32px silhouette, bottom-left corner (EN) or bottom-right
  (AR)
- **Behavior:** Fades in at the first text line. Stays through all 5
  lines. Subtle — almost a watermark. The character is already present
  before the journey begins. They've always been there.
- **Why:** Sets up the conceit from frame one: you are not alone in
  this story. Your narrator is already with you.

#### Empty States / Locked Content
- **Where:** When tapping a locked event, or viewing an empty chapter
- **Size:** ~64px, centered in the empty area
- **Pose:** Witnessing (looking toward what's ahead)
- **Text below:** "The next chapter awaits, [name]." /
  "الفصل التالي بانتظارك يا [name]."
- **Why:** Locked content feels like anticipation, not restriction.
  The narrator is waiting with you.

### 5.3 — Where They DON'T Appear

Equally important — screens where the character would be noise:

| Screen | Why No Character |
|--------|-----------------|
| Discovery panels (hotspot content) | Content speaks for itself. Character would crowd the card and compete with the bubble image. |
| In-game settings overlay (pause) | Functional screen. Character adds visual noise to a utility moment. |
| The Crossroads branch card | The decision belongs to the user, not the narrator. The character steps back so the user owns the choice. |
| Registration steps 2–4 | Gender, language, chapter preview — these are setup screens. Character only appears on the "Who carries the story?" step. |
| Audio/toggle settings rows | Utility UI. No character presence needed. |

### 5.4 — Summary Table

| Screen | Mode | Pose | Size | Priority |
|--------|------|------|------|----------|
| Exploration scene | Active | Walking / Witnessing | 64px | MVP |
| Verdict question | Active | Reflecting | 80px | MVP |
| Chapter completion | Active | Reflecting | 120px | MVP |
| Badge overlay | Active | Carrying | 60px | Phase 2 |
| XP celebration | Active | Carrying | 48px | Phase 2 |
| Splash (returning) | Ambient | Silhouette | 40px | Phase 2 |
| Event list header | Ambient | Portrait | 48px | Phase 2 |
| Settings profile | Ambient | Portrait | 80px | Phase 2 |
| Intro cinematic | Ambient | Silhouette | 32px | Phase 3 |
| Empty states | Ambient | Witnessing | 64px | Phase 3 |

MVP: 3 screens (already partially built)
Phase 2: 5 additional screens
Phase 3: 2 polish screens

---

## 6. Character in Celebration Moments

> Detailed in Section 5.1 above. Summary:

| Moment | Character Role |
|--------|---------------|
| Event completion (XP) | Carrying pose beside count-up. Present, not dominant. |
| Badge earned | Carrying pose below badge artwork. Grounds the achievement. |
| Chapter completion | Reflecting pose, large, beside closing narrative. The emotional peak. |

---

## 7. Brand Extension (Post-MVP Vision)

The Rawi/Rawiah as characters that live beyond the app:

### Social Sharing
"Share your journey" generates a card:
- Rawi/Rawiah silhouette
- "[Name] has witnessed the Jahiliyyah era"
- "I am a Rawi" / "أنا راوي" (or "أنا راوية")
- App logo + download link

### Stickers & Digital Assets
- WhatsApp/Telegram sticker pack: Rawi/Rawiah in various poses
  with Islamic greeting text (السلام عليكم, ما شاء الله, بارك الله فيك)
- Instagram/TikTok frames for Seerah content creators

### Print & Merchandise (Long-term)
- The silhouette as a logo on physical products
- Children's books featuring the Rawi/Rawiah witnessing Seerah events
- Classroom posters for Islamic schools (institutional licensing tie-in)

### Second App / Spin-off
- "Rawiah: Women of Islam" — a companion app focusing on the women
  of Islamic history, narrated by the Rawiah character
- Same engine, same art direction, dedicated female perspective

---

## 8. Content Rules (Character-Specific)

- The Rawi/Rawiah are **fictional** — they are never confused with
  historical figures. They never claim to be Sahabah.
- They **witness** events — they do not participate in them or
  change outcomes.
- They speak **reflectively** — they narrate what happened, they
  don't give opinions on Islamic jurisprudence or theology.
- They address the user **by name** — creating personal connection.
- They are **equal** — the Rawiah is not a secondary character. She
  has the same poses, the same narration quality, the same growth
  system, the same brand presence.
- They are **modest and dignified** at all times — no casual poses,
  no humor that undermines the gravity of what they're witnessing.

---

## 9. Implementation Phases

### Phase 1 — MVP (Events 1–3)
**Character assets:** Walking + Witnessing poses (2 poses × 2 = 4 assets)
**Active presence on:**
- Exploration scene (enhance existing companion)
- Verdict question (Reflecting pose beside card)
- Chapter completion (Reflecting pose, large, with closing narrative)

**Other MVP tasks:**
- Refine existing male/female companion art to match Rawi/Rawiah
  character design spec (silhouette, scroll, golden frame)
- Update onboarding text ("Who carries the story?")
- Replace functional speech bubble text with narrative voice
- Update "You" label to "Rawi" / "Rawiah"

### Phase 2 — Full Seerah (Events 1–36)
**Character assets:** Add Reflecting + Carrying poses (total: 4 poses × 2 = 8 assets) + silhouette version
**Active presence added on:**
- Badge overlay (Carrying pose below badge)
- XP celebration (Carrying pose beside count-up)

**Ambient presence added on:**
- Splash screen returning users (silhouette + "Welcome back, [name]")
- Event list header (48px portrait beside title)
- Settings profile section (80px portrait anchoring profile area)

**Other Phase 2 tasks:**
- Social sharing with character silhouette
- Name personalization across all character touchpoints

### Phase 3 — Growth & Brand
**Character assets:** 4-tier growth system (32 assets total)
**Ambient presence added on:**
- Intro cinematic (small silhouette, bottom corner)
- Empty states / locked content (Witnessing pose + anticipation text)

**Other Phase 3 tasks:**
- Visual growth system (scroll length, circle brightness, cloak trim)
- Sticker packs
- Brand materials (silhouette logo, merchandise templates)
- Rawiah spin-off exploration

---

## 10. For the Agent

### MVP Tasks:
1. Update registration screen text: "Who carries the story?" /
   "من يحمل هذه الرواية؟" — bilingual
2. Update companion label from "You" to "Rawi" / "Rawiah" based
   on gender selection
3. Replace `companion_dialogue.dart` content with narrative voice
   lines (Khaled to provide final bilingual text)
4. Prepare asset-swapping infrastructure: `CompanionFigure` widget
   should accept a `pose` parameter (walking, witnessing, reflecting,
   carrying) and load the corresponding image asset
5. Update all references from "companion" to "Rawi/Rawiah" in
   UI-facing text (settings, overlays, registration)
6. Add Reflecting pose to Verdict question screen — character
   positioned beside the question card
7. Add Reflecting pose to chapter completion screen — large character
   with closing narrative text

### Phase 2 Tasks:
1. Add Rawi/Rawiah silhouette + "Welcome back, [name]" to returning
   user splash screen
2. Add 48px character portrait to event list header beside title
3. Build profile section at top of settings screen with character
   portrait, name, "Rawi since [date]", XP, streak, badges count
4. Add Carrying pose to badge overlay and XP celebration popup
5. Wire silhouette for social sharing card generation

### Phase 3 Tasks:
1. Add small silhouette to intro cinematic (bottom corner)
2. Add Witnessing pose + text to empty states / locked content
3. Implement 4-tier growth system: swap asset sets based on
   `PrefsService.currentOrder` thresholds (1–11, 12–22, 23–36, 36+)

### Khaled's Tasks:
1. Generate refined Rawi/Rawiah portraits via Bing Image Creator
   (minimum 4 assets for MVP: walking + witnessing × 2 characters)
2. Generate silhouette version for brand mark
3. Write final bilingual dialogue lines for speech bubbles
4. Write onboarding text (EN + AR)
5. Generate Reflecting + Carrying pose assets for Phase 2
