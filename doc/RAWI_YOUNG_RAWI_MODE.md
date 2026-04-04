# RawiJourney — Young Rawi Mode (Age-Adaptive Content)

> **Date:** April 5, 2026
> **Status:** SPECCED — Post-launch feature (after all 36 events ship)
> **Origin:** Friend's feedback: "is it possible to target kids more?"
> **Decision:** Not a separate app. One app that adapts content based
> on user age. Same game, same Seerah, different reading level.

---

## Concept

When a user creates their profile, they enter their age. The app
stores an age group and automatically adjusts the text content to
match their reading level. The game experience — scenes, hotspots,
branching, questions, route, art, audio — stays identical. Only the
written content layer adapts.

A 9-year-old and a 35-year-old play the same Event 1, walk the same
route, discover the same Ka'bah hotspot. But the 9-year-old reads
3 simple sentences. The adult reads the full literary narrative plus
"Go Deeper" scholarly content. Same history. Different depth.

---

## Age Groups

| Group | Age | Content Level | "Go Deeper" |
|-------|-----|---------------|-------------|
| Young Rawi | 8–12 | `fragmentSimple` — short sentences, simple vocabulary, same facts | Hidden |
| Rawi | 13–17 | `fragment` — current content (literary narrative) | Collapsed |
| Elder Rawi | 18+ | `fragment` — current content | Auto-expanded |

Three tiers. Clean boundaries. No overlap.

---

## What Changes Per Age Group

### Young Rawi (8–12)
- `fragmentSimple` / `fragmentSimpleAr` used for hotspot cards
- `questionSimple` / `questionSimpleAr` for quiz questions (simpler
  wording, same correct answer)
- Larger default text size (Large instead of Normal)
- More companion encouragement bubbles (higher frequency)
- "Go Deeper" sections hidden entirely
- Verdict question uses simpler language
- History Records explanation simplified

### Rawi (13–17)
- Current content exactly as-is
- "Go Deeper" collapsed (tap to expand)
- Normal text size default
- Standard companion bubble frequency

### Elder Rawi (18+)
- Current content exactly as-is
- "Go Deeper" auto-expanded (visible by default)
- Normal text size default
- Companion bubbles slightly less frequent (adults don't need
  "Keep exploring!" as much)

---

## What Does NOT Change

These are identical across all age groups:
- Scene backgrounds and art
- Hotspot positions and icons
- Route paths and waypoints
- Branching flow (Gate → Crossroads → Paths → Gathering → Verdict)
- XP values and badge triggers
- Chapter completion screens
- Companion avatar (Rawi/Rawiah)
- Audio (VO, ambient, SFX) — VO matches the content level shown
- Event order and Seerah chronology

---

## Data Model Changes

### SceneHotspot — add optional simple fields
```dart
class SceneHotspot {
  // ... existing fields ...

  /// Simplified content for Young Rawi (8–12)
  final String? fragmentSimple;
  final String? fragmentSimpleAr;

  const SceneHotspot({
    // ... existing params ...
    this.fragmentSimple,
    this.fragmentSimpleAr,
  });
}
```

### JourneyQuestion — add optional simple fields
```dart
class JourneyQuestion {
  // ... existing fields ...

  /// Simplified question text for Young Rawi (8–12)
  final String? questionSimple;
  final String? questionSimpleAr;
  final String? explanationSimple;
  final String? explanationSimpleAr;

  const JourneyQuestion({
    // ... existing params ...
    this.questionSimple,
    this.questionSimpleAr,
    this.explanationSimple,
    this.explanationSimpleAr,
  });
}
```

### PrefsService — add age group
```dart
static const String _keyUserAgeGroup = 'user_age_group';

// 'young' (8-12), 'teen' (13-17), 'adult' (18+)
static String get userAgeGroup =>
    _prefs?.getString(_keyUserAgeGroup) ?? 'teen';
static Future<void> setUserAgeGroup(String v) async =>
    await _prefs?.setString(_keyUserAgeGroup, v);

/// Whether to use simplified content
static bool get useSimpleContent => userAgeGroup == 'young';
```

### Content rendering — one conditional
```dart
// Wherever fragment text is displayed:
final text = PrefsService.useSimpleContent
    ? (hotspot.fragmentSimple ?? hotspot.fragment)  // fallback to full
    : hotspot.fragment;
```

The `?? hotspot.fragment` fallback means events without simplified
content yet still work — they show the full text. No crashes, no
empty screens. Content can be simplified incrementally.

---

## Registration Flow Change

After the name field, add an age input:

```
"How old are you?" / "كم عمرك؟"

[ Number input: 1–99 ]
```

Auto-map to age group:
- 8–12 → 'young'
- 13–17 → 'teen'
- 18+ → 'adult'
- Under 8 → 'young' (with parent guidance note)

Simple number input, not a date picker. Kids know their age. They
don't always know their birth date.

---

## Content Writing Guide

### How to write `fragmentSimple`

Take the existing `fragment` and apply these rules:

1. **Same facts.** Every historical detail stays. Don't remove events,
   people, places, or dates.
2. **Shorter sentences.** Max 12 words per sentence. Break complex
   sentences into 2–3 simple ones.
3. **Simple vocabulary.** Replace literary language with everyday
   words. "The idols crowd the sacred precinct" → "360 statues stood
   around the Ka'bah."
4. **Direct address.** Use "you" more. "You see the Ka'bah. Statues
   are everywhere."
5. **3–4 sentences max** per hotspot card (vs 2–3 paragraphs for
   adults).
6. **No metaphors.** Adults get "buried under layers of custom and
   self-interest." Kids get "people forgot what the Ka'bah was really
   built for."

### Example — Event 1, Ka'bah hotspot

**Adult (current `fragment`):**
"The Ka'bah stands at the center of everything — ancient, patient,
waiting. Built by Ibrahim and Isma'il as a house of the One God, it
now sits surrounded by 360 idols. Each tribe has placed its own god
here. The pilgrims come not for tawhid but for trade and ritual. The
stones remember what the people have forgotten."

**Young Rawi (`fragmentSimple`):**
"The Ka'bah is the oldest house of worship on Earth. Prophet Ibrahim
built it for the One God. But now, 360 statues stand around it. Each
tribe put their own statue here. The people forgot why the Ka'bah was
really built."

Same facts. Same Ka'bah. Same 360 idols. Same Ibrahim. Just simpler.

---

## VO Implications

When Young Rawi mode is active, the VO should read the simplified
text, not the full text. This means:
- Generate a separate set of VO files for simplified content
- File naming: `vo_event1_kaabah_simple_en_m.mp3` (add `_simple`)
- The `_voPath()` method checks `PrefsService.useSimpleContent` and
  appends `_simple` to the filename

This doubles the VO file count but the simplified clips are much
shorter (3–4 sentences vs 2–3 paragraphs), so file size is roughly
+40% not +100%.

**For MVP of Young Rawi:** Use the same VO files as adults. The kid
reads the simple text but hears the full VO. It's not perfect but
it works until dedicated simple VO is generated.

---

## Effort Estimate

| Task | Owner | Time |
|------|-------|------|
| Age input in registration + PrefsService | Agent | 1 day |
| Add simple fields to models + conditional rendering | Agent | 1 day |
| Go Deeper auto-expand for adults | Agent | 0.5 days |
| Companion bubble frequency per age group | Agent | 0.5 days |
| Write simplified content (36 events × ~4 hotspots) | Khaled + Claude | 1.5–3 weeks |
| Generate simplified VO (optional, post-launch) | Khaled | 1–2 weeks |
| Testing all 3 age groups across events | Khaled | 2–3 days |
| **Total code:** | | **2–3 days** |
| **Total content:** | | **2–4 weeks** |

The code is trivial. The content is the bottleneck. But it's
simplification of existing text — not original creation — so Claude
can draft and Khaled reviews.

---

## Timeline

**NOT now.** This is a post-launch feature.

1. **Now → Launch:** Finish all 36 events at the current (teen/adult)
   reading level. Ship.
2. **Post-launch (Month 1–2):** Add age input to registration. Add
   empty `fragmentSimple` fields to models. Code ships in 2–3 days.
3. **Post-launch (Month 2–3):** Write simplified content for all 36
   events. Use Claude for drafts, Khaled reviews for accuracy and
   tone. Roll out incrementally — events with simplified content
   show it, events without fall back to full text.
4. **Post-launch (Month 3+):** Generate simplified VO. Full Young
   Rawi experience complete.

---

## Pricing Implication

Young Rawi mode is NOT a separate purchase. It's included in the
$9.99 base app. This is a feature, not a product. Islamic schools
institutional licensing (already on the roadmap) becomes significantly
more attractive with a kids mode built in.

---

## Design Decision — LOCKED

- One app, not two
- Age-based content adaptation, not a toggle
- Same game experience, different reading level
- Content simplified via optional model fields with fallback
- Post-launch feature — zero impact on MVP timeline
- "Go Deeper" behavior varies by age group (hidden/collapsed/expanded)
