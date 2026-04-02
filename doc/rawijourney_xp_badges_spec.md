# RawiJourney — XP Animation & Badge System Spec

## Overview

Two enhancements to the event completion reward flow:
1. Animated XP reveal that feels like an achievement
2. Badge system that unlocks at chapter milestones

Both live in the completion phase of The Verdict — between the
"History records..." explanation and the "Continue Journey →" button.

---

## Part 1: XP Animation

### Current State
A static "★ +30 XP" text line appears below the explanation. Flat,
no animation, no celebration. The Continue button appears immediately
alongside it.

### New Behavior

**Step 1 — XP reveal animation (starts after explanation is fully
visible):**
- The gold star icon starts at 0.5x scale, animates to 1.2x, then
  settles at 1.0x (a "pop" effect). Duration: 400ms, ease-out curve.
- The XP number counts up from 0 to the actual value (e.g., 0 → 30)
  over 600ms. Use a Tween<int> with an animation controller. Display
  as "+{value} XP" with each frame updating the number.
- A subtle gold particle burst behind the star at the moment it pops.
  8-12 small gold dots that expand outward and fade. Duration: 500ms.
  These are simple positioned containers with opacity + transform
  animations, not a full particle system.
- Show the total XP line below: "★ 50 → 80" (previous total → new
  total) in smaller muted gold text (12px). This appears after the
  count-up finishes, with a simple fade-in over 300ms.

**Step 2 — Badge reveal (if earned, see Part 2):**
- If a badge was earned this event, the badge overlay appears 500ms
  after the XP animation completes.
- If no badge, skip to Step 3.

**Step 3 — Continue button appears:**
- "Continue Journey →" button fades in 1 second after the XP animation
  finishes (or 1 second after badge dismiss if a badge was shown).
- The delay is intentional — it forces a moment of satisfaction before
  the user moves on.

### Animation Sequence Timeline
```
0.0s  — Explanation fully visible
0.2s  — Star pops in (scale 0.5 → 1.2 → 1.0)
0.2s  — Gold particle burst fires
0.3s  — XP count-up starts (0 → 30)
0.9s  — XP count-up ends
1.0s  — Total XP line fades in ("★ 50 → 80")
1.5s  — Badge overlay appears (if earned) OR Continue button fades in
        If badge: Continue button appears 1s after badge dismiss
```

### Technical Notes
- Use a single AnimationController with staggered intervals for the
  star pop, count-up, and total reveal. Or three separate controllers
  chained with listeners.
- The particle burst can be 8 small Container widgets in a Stack,
  each with a Transform.translate animation moving outward at
  different angles (use cos/sin for x/y offsets at 0°, 45°, 90°, etc.)
  and an opacity animation from 1.0 to 0.0.
- The count-up Tween should use Curves.easeOut so it slows at the end
  for a more satisfying feel.

---

## Part 2: Badge System

### Data Model

Create file: `lib/models/badge_definition.dart`

```dart
class BadgeDefinition {
  final String id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final String icon; // emoji or asset path
  final BadgeTrigger trigger;

  const BadgeDefinition({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.icon,
    required this.trigger,
  });
}

class BadgeTrigger {
  final BadgeTriggerType type;
  final int? value; // e.g., event count threshold
  final List<int>? eventRange; // e.g., [1, 3] for events 1-3

  const BadgeTrigger({
    required this.type,
    this.value,
    this.eventRange,
  });
}

enum BadgeTriggerType {
  firstEvent,        // Complete any single event
  eventCount,        // Complete N events total
  chapterComplete,   // Complete all events in a range
  allEvents,         // Complete all 36
  perfectStreak,     // Answer all questions correctly (future)
}
```

### Badge Definitions

```dart
const List<BadgeDefinition> allBadges = [
  BadgeDefinition(
    id: 'first_step',
    name: 'First Step',
    nameAr: 'الخطوة الأولى',
    description: 'You completed your first event',
    descriptionAr: 'أكملت أول حدث في رحلتك',
    icon: '🌅',
    trigger: BadgeTrigger(type: BadgeTriggerType.firstEvent),
  ),
  BadgeDefinition(
    id: 'witness_of_dawn',
    name: 'Witness of the Dawn',
    nameAr: 'شاهد الفجر',
    description: 'You witnessed Pre-Islamic Arabia',
    descriptionAr: 'شهدت الجزيرة العربية قبل النور',
    icon: '🌙',
    trigger: BadgeTrigger(
      type: BadgeTriggerType.chapterComplete,
      eventRange: [1, 3],
    ),
  ),
  BadgeDefinition(
    id: 'companion_of_beginning',
    name: 'Companion of the Beginning',
    nameAr: 'رفيق البداية',
    description: 'You walked through the Prophetic childhood',
    descriptionAr: 'عشت مع النشأة النبوية',
    icon: '⭐',
    trigger: BadgeTrigger(
      type: BadgeTriggerType.chapterComplete,
      eventRange: [4, 11],
    ),
  ),
  BadgeDefinition(
    id: 'steadfast_in_mecca',
    name: 'Steadfast in Mecca',
    nameAr: 'الثابت في مكة',
    description: 'You endured the Meccan struggle',
    descriptionAr: 'صبرت على ابتلاء مكة',
    icon: '🕋',
    trigger: BadgeTrigger(
      type: BadgeTriggerType.chapterComplete,
      eventRange: [12, 22],
    ),
  ),
  BadgeDefinition(
    id: 'guardian_of_legacy',
    name: 'Guardian of the Legacy',
    nameAr: 'حارس الإرث',
    description: 'You witnessed the rise of the community',
    descriptionAr: 'شهدت قيام الأمة',
    icon: '🏛️',
    trigger: BadgeTrigger(
      type: BadgeTriggerType.chapterComplete,
      eventRange: [23, 36],
    ),
  ),
  BadgeDefinition(
    id: 'seeker_of_truth',
    name: 'Seeker of Truth',
    nameAr: 'طالب الحق',
    description: 'You completed 10 events',
    descriptionAr: 'أكملت 10 أحداث',
    icon: '📜',
    trigger: BadgeTrigger(
      type: BadgeTriggerType.eventCount,
      value: 10,
    ),
  ),
  BadgeDefinition(
    id: 'the_rawi',
    name: 'The Rawi',
    nameAr: 'الراوي',
    description: 'You witnessed the entire Prophetic journey',
    descriptionAr: 'شهدت رحلة النبوة كاملة',
    icon: '👑',
    trigger: BadgeTrigger(
      type: BadgeTriggerType.allEvents,
      value: 36,
    ),
  ),
];
```

### PrefsService Additions

```dart
// Store earned badges
static List<String> get earnedBadges =>
    _prefs?.getStringList('earned_badges') ?? [];

static Future<void> _awardBadge(String badgeId) async {
  final current = earnedBadges;
  if (!current.contains(badgeId)) {
    current.add(badgeId);
    await _prefs?.setStringList('earned_badges', current);
  }
}

/// Call after completeEvent(). Returns newly earned badges (if any).
static Future<List<BadgeDefinition>> checkAndAwardBadges(
    int completedGlobalOrder) async {
  final newBadges = <BadgeDefinition>[];
  final earned = earnedBadges;

  for (final badge in allBadges) {
    if (earned.contains(badge.id)) continue; // already earned

    bool qualifies = false;

    switch (badge.trigger.type) {
      case BadgeTriggerType.firstEvent:
        qualifies = true; // completing any event qualifies
        break;
      case BadgeTriggerType.eventCount:
        final count = List.generate(36, (i) => i + 1)
            .where((o) => isEventCompleted(o))
            .length;
        qualifies = count >= (badge.trigger.value ?? 999);
        break;
      case BadgeTriggerType.chapterComplete:
        final range = badge.trigger.eventRange!;
        qualifies = List.generate(
          range[1] - range[0] + 1,
          (i) => range[0] + i,
        ).every((o) => isEventCompleted(o));
        break;
      case BadgeTriggerType.allEvents:
        qualifies = List.generate(36, (i) => i + 1)
            .every((o) => isEventCompleted(o));
        break;
      case BadgeTriggerType.perfectStreak:
        qualifies = false; // future implementation
        break;
    }

    if (qualifies) {
      await _awardBadge(badge.id);
      newBadges.add(badge);
    }
  }

  return newBadges;
}
```

### Integration in _completeAndPop

Update `immersive_event_screen.dart`:

```dart
Future<void> _completeAndPop() async {
  if (!_alreadyCompleted) {
    await PrefsService.completeEvent(
        widget.event.globalOrder, widget.event.xpReward);
    await PrefsService.clearHotspotProgress(widget.event.id);

    // Check for new badges AFTER completion is saved
    final newBadges = await PrefsService.checkAndAwardBadges(
        widget.event.globalOrder);

    if (newBadges.isNotEmpty && mounted) {
      // Show badge overlay for first earned badge
      // (if multiple earned simultaneously, show them in sequence)
      for (final badge in newBadges) {
        await _showBadgeOverlay(badge);
      }
    }
  }
  if (!mounted) return;
  Navigator.pop(context, true);
}
```

**Wait — this changes the flow.** The badge should show BEFORE the
pop, not after. But the current `_completeAndPop` is called from the
Continue button. We need a different sequence:

### Revised Completion Flow

```
User answers The Verdict
  → Correct answer highlights
  → "History records..." explanation reveals
  → XP animation plays (star pop, count-up, total)
  → Badge overlay appears (if earned) — user taps to dismiss
  → "Continue Journey →" button fades in
  → User taps Continue
  → Writes to prefs (completeEvent, clearProgress)
  → Navigator.pop(context, true)
```

Actually, the writes should happen BEFORE the XP animation — we want
the data saved immediately after answering, not deferred to Continue.
The Continue button just handles navigation. Revised:

### Final Flow

```
User answers The Verdict
  → _selectChoice fires
  → completeEvent() + clearHotspotProgress() AWAITED immediately
  → checkAndAwardBadges() returns any new badges
  → Correct answer highlights
  → "History records..." explanation reveals
  → XP animation plays
  → Badge overlay appears (if earned) — user taps to dismiss
  → "Continue Journey →" fades in
  → User taps Continue → Navigator.pop(context, true)
```

This way:
- Data is saved immediately (no risk of loss if app crashes)
- XP animation is purely visual (data already written)
- Badge check happens with correct saved state
- Continue button only navigates, doesn't write

---

## Part 3: Badge Overlay Widget

### Design
The badge overlay should match The Verdict's cinematic language:
- Full-screen dark overlay (black at 70% opacity)
- Centered card with gold border (matching The Verdict card)
- Gold dust particles in background (if already available)

### Card Content (top to bottom)
```
[Badge icon — large, 48px, centered]

"Badge Unlocked" in gold, 12px uppercase, letter-spacing 1.5px

[Badge Name] in gold serif, 20px, centered
e.g., "Witness of the Dawn"

[Badge Description] in cream/white, 14px, centered
e.g., "You witnessed Pre-Islamic Arabia"

[Tap to continue] in muted text, 12px
```

### Animation
- Card scales in from 0.8x to 1.0x with opacity 0→1, duration 400ms
- Badge icon does the same star-pop effect (scale up then settle)
- A gold shimmer or brief sparkle effect on the icon

### Dismiss
User taps anywhere on the overlay to dismiss. Returns a Future so
the calling code can await it and proceed to show the Continue button.

---

## Part 4: Badge Display on Profile

### Where
Add a "Badges" section on the Profile screen (or wherever user stats
are shown). Grid of badge icons — earned badges shown in full color
with name below, unearned badges shown as dark silhouettes with "?"
label.

### Design
- 3-column grid
- Each cell: icon (32px) + name (11px) below
- Earned: full color icon, gold name text
- Unearned: dark gray icon silhouette, muted name text, maybe "???"
  instead of name to create curiosity

This is a separate screen/section — implement after the core badge
earn flow is working.

---

## Implementation Order

| Step | What | Effort |
|------|------|--------|
| 1 | XP count-up animation (star pop + number tween) | 1 hour |
| 2 | XP total line ("50 → 80") | 15 min |
| 3 | Delayed Continue button (1s after XP) | 15 min |
| 4 | BadgeDefinition model + badge data | 30 min |
| 5 | PrefsService badge storage + checkAndAwardBadges | 30 min |
| 6 | Badge overlay widget | 1 hour |
| 7 | Wire into completion flow | 30 min |
| 8 | Profile badge display (can be later) | 1-2 hours |

Steps 1-3 are the XP animation — do these first, they're high
impact and independent. Steps 4-7 are the badge system — one unit
of work. Step 8 is separate and can come later.
