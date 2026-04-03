# RawiJourney — Issues & Enhancements (April 3, 2026)

> **Source:** Khaled's testing session on Samsung A56, Android 15
> **For:** Claude Code agent — fix in priority order within each section
> **Rule:** All new UI must follow the established design system (deep
> navy bg, gold accents, Cinzel/Lora/Nunito fonts, 16–20px radius,
> bilingual AR/EN). No screen ships in EN-only.

---

## SECTION A — BUGS (Fix First)

### A1. Splash Screen White Flash on App Resume
**Screen:** Splash screen
**Screenshot:** Image 1 (black screen, white rounded square around icon)

**Problem:** When the user leaves the app (phone call, notification,
etc.) and returns, the splash screen shows again with the Rawi icon
centered on a black background inside a white rounded container. This
is the Android native splash — not the Flutter splash. It looks broken.

**Fix:** Configure `android/app/src/main/res/values/styles.xml` to use
the app's navy background color (`#0B1E2D`) instead of white for the
`LaunchTheme` window background. Ensure the `NormalTheme` also uses
navy. The icon should render on navy, not inside a white squircle.

**Priority:** High — every app resume shows this.

---

### A2. History Records VO Keeps Playing After Continue
**Screen:** Verdict/Reflection → Event List transition

**Problem:** When the user taps "Continue Journey" after completing an
event, the VO narration for the History Records explanation keeps
playing even after navigating back to the event list screen.

**Fix:** In `_completeAndPop()` and `_continue()` in
`immersive_event_screen.dart`, call `AudioService.stopVoiceover()`
before `Navigator.pop()`. Same pattern already used in `_dismissPanel()`
and `_openSettings()`.

**Priority:** High — audible on every event completion.

---

### A3. Badge Overlay Interrupts VO / Confusing Flow
**Screen:** Verdict card after answering question
**Screenshot:** Image showing badge over History Records text

**Problem:** After the user answers the question, VO starts reading
the History Records explanation. But the badge overlay appears 500ms
later ON TOP of the explanation, leaving the user confused — they hear
audio but can't see what it's about, and there's a badge in the way.

**Fix — Revised completion flow:**
1. User answers → explanation reveals + VO plays
2. VO finishes (or user reads the explanation) → no interruption
3. User taps "Continue Journey"
4. THEN show badge popup (if any) — full-screen overlay
5. User taps to dismiss badge
6. THEN show XP animation popup — same full-screen overlay style
7. XP animation completes → auto-navigate to event list

The key change: badges and XP move to AFTER the user taps Continue,
not while they're still reading the explanation. This also solves A2
(VO stops when they tap Continue, before badge shows).

**Priority:** High — core completion experience.

---

### A4. Badge Not Showing After Event 2
**Screen:** After completing Event 2

**Problem:** "First Step" badge appeared after Event 1, but no badge
appeared after Event 2. User expected something.

**Explanation:** This is working as designed — the badge system has 7
badges with specific triggers:
- **First Step** → Complete any event (triggers on Event 1)
- **Witness of the Dawn** → Complete all Jahiliyyah events (Events 1–3)
- **Seeker of Truth** → Complete 10 events

So Event 2 has no badge trigger. But this creates a "where did the
celebration go?" feeling.

**Recommendation:** The XP popup (see A3 fix above) should appear after
EVERY event as the baseline celebration. Badges are the bonus on top.
With the revised flow (A3), every completion gets the XP moment, and
badge events get both.

---

### A5. Event 3 Card Overflow (16 pixels)
**Screen:** Event list — Black Stone event card
**Screenshot:** Image 4, first batch (yellow "BOTTOM OVERFLOWED BY 16 PIXELS")

**Problem:** Two-line title + hotspot dots exceed card height.

**Fix:** Remove the fixed height constraint on the event card. Let
content size the card. Already specced — agent has this in queue.

**Priority:** Medium — visual bug but non-blocking.

---

### A6. Era Collapse After Completing Events
**Screen:** Event list

**Problem:** After completing all events in Jahiliyyah and moving to
Early Life, both eras stay expanded. The completed era should auto-
collapse and the new active era should auto-expand.

**Fix:** In `_refresh()` in `event_list_screen.dart`, after updating
`_currentOrder`, clear `_expandedEras` and only add the active era:
```dart
void _refresh() {
  setState(() {
    _currentOrder = PrefsService.currentOrder;
    _expandedEras.clear();
    final active = _activeEra();
    if (active != null) _expandedEras.add(active);
  });
}
```

**Priority:** Medium — UX polish.

---

### A7. Skip Button Not Working on Intro Cinematic
**Screen:** Intro cinematic screen (570 CE scene)

**Problem:** The "Skip" button in the top-right corner doesn't respond
to taps.

**Fix:** Check `intro_cinematic_screen.dart` — the Skip button's
`onTap`/`onPressed` handler may be blocked by an animation overlay
or a `GestureDetector` consuming the tap. Ensure the Skip button is
positioned above all animation layers in the Stack and has a proper
hit test area (minimum 44x44 tap target).

**Priority:** Medium — users stuck on first launch.

---

### A8. Character Gets Stuck on Path Segments
**Screen:** In-scene exploration (joystick navigation)

**Problem:** When trying to move up to the next hotspot on a straight
vertical path segment, the companion character vibrates/nudges in place
because the joystick input needs a lateral component first. The path
direction and joystick direction dot product is near zero for
perpendicular input.

**Fix — Curved paths only (NO auto-movement):**

**⚠️ CRITICAL RULE: The companion figure must NEVER move without
explicit joystick input. No auto-nudge, no minimum speed, no automatic
path advancement under ANY circumstance. Movement is 100% user-
controlled at all times. Multiple testers independently reported
unwanted auto-movement — this is non-negotiable. If the user is not
actively pushing the joystick, the figure stays perfectly still.**

Change `pathWaypoints` in `scene_configs.dart` from straight lines to
gentle curves by adding intermediate waypoints. Example: instead of
going straight from (0.5, 0.6) to (0.5, 0.3), route through
(0.45, 0.5) and (0.55, 0.4). This means no segment is ever perfectly
vertical or horizontal, so any joystick direction has a non-zero dot
product with the segment direction — the character moves naturally
without getting stuck.

Apply curved paths to all 3 event scene configs (+ alt paths for
branching). Test each path by pushing the joystick in all directions
at every segment to confirm no dead zones exist.

**Priority:** High — multiple testers reported this.

---

### A9. Path Route Line Cut Off
**Screen:** In-scene exploration

**Problem:** The route line from the current hotspot to the next one
shows only the second half clearly. The first half appears cut off or
invisible.

**Fix:** Check `path_route_painter.dart` — the `pathProgress` value
likely clips the rendered line to only show the upcoming portion. The
full route from current position to next hotspot should be visible.
Review the paint logic for how `discoveredCount` affects which segments
are drawn.

**Priority:** Medium — visual polish.

---

### A10. VO Mute Button Inconsistent Behavior
**Screen:** Discovery panels vs Verdict card

**Problem:** On hotspot discovery bubbles, tapping the mute button
mutes the VO but the button stays the same visually. On the Verdict
(final question) screen, the button properly fades to a dark/dimmed
state when muted. The Verdict behavior is correct — replicate it
everywhere.

**Fix:** The Verdict card already has the correct implementation with
`PrefsService.voEnabled` check for icon opacity/color. Copy that
pattern to `discovery_panel.dart` for the VO mute/unmute button.
Ensure all VO buttons across all screens use the same widget or
pattern.

**Priority:** Low — consistency polish.

---

### A11. Update Content Rules — Companions Visual Prohibition
**File:** `RAWI_MASTER_PLAN.md` Section 4 (Source Hierarchy)

**Problem:** The Prohibited list only mentions "Any visual depiction
of the Prophet ﷺ." It does not mention the Companions (الصحابة),
especially the close Companions (المقربون). This is a global content
law that must be documented at the source.

**Fix:** In `RAWI_MASTER_PLAN.md`, update the Prohibited section under
Section 4 to read:

```
**Prohibited:**
- Isra'iliyyat (unverified narrations from biblical/Israeli sources)
- The Bahira incident (excluded — unverified chain)
- Any visual depiction of the Prophet ﷺ
- Any visual depiction of the Companions (الصحابة), especially the
  close Companions (المقربون) including:
  • The Khulafa al-Rashidun (Abu Bakr, Umar, Uthman, Ali رضي الله عنهم)
  • Mothers of the Believers (Khadijah, Aisha رضي الله عنهن)
  • The Asharah al-Mubasharah (the 10 promised Paradise)
  • Key figures (Hamza, Bilal, Mus'ab, Zayd, Ja'far رضي الله عنهم)
  • Any Companion mentioned by name in event content
  They exist through narration, objects, and atmosphere only —
  never as visible human figures, not even distant silhouettes.
- Speculative dialogue attributed to the Prophet ﷺ without hadith source
```

**This rule applies to ALL visual content:** videos, scene backgrounds,
hotspot card images, badge artwork, and any future visual assets.

**Priority:** High — content integrity.

---

## SECTION B — ENHANCEMENTS (After Bugs)

### B1. Exit Dialog — Follow Design System
**Screen:** Event list → Back button
**Screenshot:** Image 2, first batch (generic AlertDialog)

**Problem:** The "Exit game?" dialog uses default Material Design
styling — white/gray background, flat text. Doesn't match the app's
cinematic dark navy + gold design language.

**Fix:** Replace the default `AlertDialog` with a custom dialog
matching the app's design system:
- Background: `AppColors.card` (`#132233`)
- Border: `AppColors.gold` at 30% opacity, 1px, 16px radius
- Title: Cinzel Decorative, gold color
- Body: Nunito, `AppColors.textBody`
- "Stay" button: outlined gold border, transparent bg
- "Exit" button: filled gold bg, dark text
- Bilingual: title and body text switch based on `_isAr`

This dialog style should be extracted as a reusable `RawiDialog` widget
and used as the default for ALL future dialogs in the app.

**Priority:** Medium — visual consistency.

---

### B2. XP/Badge Celebration Redesign
**Related to:** A3, A4

**New design — unified celebration popup:**

After user taps "Continue Journey":
1. Full-screen dark overlay (85% opacity)
2. If badge earned: Badge card (gold border, badge icon, title,
   description) with pop animation → "Tap to continue"
3. XP card (same style): Star icon + count-up animation from previous
   total to new total → auto-dismiss after 2s
4. Auto-navigate to event list

Key principle: XP celebration happens on EVERY event. Badge is bonus.
Both use the same popup container style. Never overlap with the
explanation text or VO playback.

**Priority:** Medium — ties into A3 fix.

---

### B3. Badge Artwork
**Screenshot:** Image 1, third batch (generic sunrise emoji badge)

**Problem:** Current badge is a stock emoji-style sunrise graphic.
Doesn't match the app's painterly, cinematic quality.

**Recommendation:** Design custom badge artwork in the same painterly
style as the companion avatars and scene backgrounds. Options:

1. **AI-generated via Midjourney/Bing** (like the scene art): Create
   7 badge illustrations with Islamic geometric patterns, gold
   borders, themed to each badge (e.g., crescent for "First Step",
   star pattern for "Seeker of Truth", minaret silhouette for
   "Witness of the Dawn"). Square, ~200x200px, warm earth tones.

2. **SVG geometric badges:** Simpler approach — create geometric
   Islamic patterns as SVG badges. Gold on navy, clean and scalable.
   Can be done in code with CustomPainter or as SVG assets.

**Recommended approach:** Option 1 for visual consistency with the
rest of the app. Generate them in the same batch as hotspot card images.

**Priority:** Low — cosmetic but impacts perceived quality.

---

### B4. Intro Cinematic — Bilingual + Line Breaks
**Screen:** Intro cinematic (570 CE / Arabian Peninsula / etc.)
**Screenshot:** Image 2, second batch (570 CE only in English)

**Problem:** All intro cinematic text lines show in English only.
Need Arabic versions. Also, the text shows as a single block rather
than individual atmospheric lines.

**Fix:** In `intro_cinematic_screen.dart`:
1. Add Arabic versions of all 5 text lines
2. Switch based on `PrefsService.isAr`
3. Each line should render on its own with the sequential fade-in
   animation already in place (600ms in → 1800ms hold → 400ms out)
4. Arabic text: use `TextDirection.rtl`

**Priority:** Medium — first impression for Arabic users.

---

### B5. Registration Screens — Bilingual + Mandatory Name
**Screen:** Registration flow (4 steps)
**Screenshot:** Image 3, second batch (EN-only name screen)

**Problem:** All registration screens show English text only.

**Fix:**
1. Add Arabic versions of all text ("What shall we call you, traveler?"
   → "ماذا نناديك، أيها الرّحّال؟", "Continue" → "متابعة",
   "Skip" → "تخطي", etc.)
2. Switch based on device locale or `PrefsService.language` (if set
   from a previous install)

**Name field — make mandatory:**
- Remove the "Skip" button entirely
- Minimum 2 characters, maximum 15 characters
- Disable "Continue" until 2+ characters are entered
- Add character counter or validation hint: "2–15 characters" /
  "٢–١٥ حرفاً"
- 15 chars covers virtually every first name in both Arabic
  (عبدالرحمن = 9) and English (Christopher = 11) without breaking
  speech bubbles, headers, or celebration screens

**Name personalization — use it throughout the experience:**
- Companion speech bubbles: address user by name occasionally
- Event completion: "Well done, [name]" / "أحسنت يا [name]"
- Profile section on settings: "Khaled, Rawi since April 2026"
- The name is already stored — make it feel like a profile, not
  just a field

**Priority:** Medium — first-time experience.

---

### B6. Settings Screen — UI Overhaul
**Screen:** Settings
**Screenshot:** Image 1, second batch (long scrolling settings)

**Problem:** The settings screen has duplicated sections (Journey
appears twice, Badges appears three times, Reset Journey appears
twice). Khaled confirmed this is a screenshot artifact, not a code
bug. But the overall settings layout needs to follow the design system
better.

**Fix:**
- Apply the same card style as event list (navy card bg, gold accents,
  rounded corners)
- Section headers: gold uppercase text with divider line (matching
  era headers in event list)
- Toggle switches: gold when active, muted when off
- Bilingual all labels
- Single clean layout: Audio → Profile → Journey Stats → Badges →
  About → Reset (danger zone, red text, confirmation dialog)

**Priority:** Low — functional but not polished.

---

### B7. Accessibility — Larger Text/Images for Elderly Users
**Source:** Khaled's father tested the app

**Problem:** Discovery panel bubble images and text are too small for
elderly users or those with vision issues.

**Recommendation — single version with accessibility setting:**

Do NOT build two separate layouts. Instead:
1. Add a "Text Size" option in Settings: Normal / Large
2. Store in PrefsService as `textScale` (1.0 or 1.3)
3. Apply via `MediaQuery` override in `MaterialApp`:
   ```dart
   builder: (context, child) {
     final scale = PrefsService.textScale;
     return MediaQuery(
       data: MediaQuery.of(context).copyWith(
         textScaler: TextScaler.linear(scale),
       ),
       child: child!,
     );
   }
   ```
4. For bubble images in discovery panels: use the same scale factor
   to increase the image container height (e.g., 160px → 208px)

This gives elderly users a one-tap solution without maintaining two
layouts. The birth-date auto-detection idea is clever but adds
complexity and assumptions — a simple toggle is more respectful and
reliable.

**Priority:** Low — post-MVP polish, but easy to implement.

---

## SECTION C — STRATEGIC DECISIONS (LOCKED)

These decisions were discussed and agreed upon. They are final.

### C1. User Profile System ✅ DECIDED: Stay Offline, Make It Feel Personal
**Decision:** No cloud profile, no Firebase, no accounts for MVP.
Keep SharedPreferences as the storage layer. BUT — make the existing
local data feel like a real profile throughout the experience:

- Name is mandatory (2–15 characters), used throughout the app
- Add a "Profile" section in settings showing: name, companion,
  language, XP, streak, badges earned, events completed, "Rawi since
  [first launch date]"
- Companion speech bubbles address the user by name
- Completion screens say "Well done, [name]"
- Future (v2): consider expanded avatar selection (4–6 painterly
  portraits with different looks — younger/older, different skin
  tones, different head coverings) instead of just male/female.
  Photo upload rejected — breaks the painterly art style.
- Future (v3+): optional cloud backup if users request it

### C2. Online/Offline Game ✅ DECIDED: Offline
**Decision:** RawiJourney ships as a fully offline, buy-once-own-forever
app. No server dependency, no accounts, no connectivity required.
Online features (cloud save, analytics) deferred to v2+ based on user
feedback. The $9.99 price point supports this model.

### C3. Name Field ✅ DECIDED: Mandatory, No Skip
**Decision:**
- Name is mandatory on registration step 1
- Minimum 2 characters, maximum 15 characters
- "Skip" button removed entirely
- "Continue" disabled until 2+ characters entered
- Applies to both EN and AR registration flows

---

## EXECUTION ORDER

### Phase 1 — Critical Bugs
| # | Item | Ref |
|---|------|-----|
| 1 | VO keeps playing after Continue | A2 |
| 2 | Badge/XP flow interrupts VO | A3 |
| 3 | Character stuck on paths | A8 |
| 4 | Splash white flash on resume | A1 |
| 5 | Skip button not working | A7 |
| 6 | Update content rules — Companions visual prohibition | A11 |

### Phase 2 — UI Bugs
| # | Item | Ref |
|---|------|-----|
| 7 | Event 3 card overflow | A5 |
| 8 | Era auto-collapse | A6 |
| 9 | Path route line cut off | A9 |
| 10 | VO mute button consistency | A10 |

### Phase 3 — Enhancements
| # | Item | Ref |
|---|------|-----|
| 11 | Exit dialog redesign | B1 |
| 12 | XP/Badge celebration popup | B2 |
| 13 | Intro cinematic bilingual | B4 |
| 14 | Registration bilingual + mandatory name (2–15 chars) | B5 |
| 15 | Name personalization throughout experience | B5 / C1 |
| 16 | Settings screen overhaul + profile section | B6 / C1 |
| 17 | Badge artwork | B3 |
| 18 | Accessibility text scale | B7 |

### Future (Post-MVP)
| Item | Ref |
|------|-----|
| Expanded avatar gallery (4–6 painterly portraits) | C1 |
| Cloud backup option (if users request it) | C1 / C2 |
