# RawiJourney — Badge Overlay & Completion Flow Redesign

## Problem

The badge overlay, XP animation, and Continue button all appear
simultaneously, competing for attention. The badge overlay doesn't
fully cover the screen — The Verdict card bleeds through behind it.
Text in the badge card has underline styling that reads as hyperlinks.

---

## Fix 1: Full-Screen Badge Overlay

### Dark Overlay
When the badge appears, cover the ENTIRE screen — including The
Verdict card, XP, everything — with black at 85% opacity. Only the
badge card is visible. Nothing from the underlying screen should
bleed through.

### Badge Card Design
- Width: 80% of screen width
- Vertically centered on screen
- Background: app dark color (#0a1520 or equivalent)
- Border: gold (#c9a84c) at full opacity, 1.5px
- Border radius: 16px
- Subtle outer glow: gold at 20% opacity, 2-3px spread (BoxShadow)
- Padding: 32px vertical, 24px horizontal
- NO underlines on any text

### Card Content (top to bottom)
```
[Badge icon — 64px, centered]
  ↕ 16px gap
"BADGE UNLOCKED" — gold (#c9a84c), 11px, uppercase, letter-spacing 2px
  ↕ 12px gap
[Badge Name] — gold, serif font (Lora), 22px, centered, weight 500
  ↕ 8px gap
[Badge Description] — cream/white (#e8d8b8), 14px, centered
  ↕ 24px gap
"Tap to continue" — muted gold (#c9a84c at 50%), 12px, centered
```

### Badge Icon Animation
Same star-pop effect as the XP star:
- Starts at 0.5x scale
- Animates to 1.2x scale
- Settles at 1.0x scale
- Duration: 400ms, ease-out curve
- Fires when the overlay appears

### Card Entry Animation
- Card scales from 0.85x to 1.0x with opacity 0 → 1
- Duration: 400ms, ease-out
- Fires simultaneously with icon pop

### Dismiss
- User taps anywhere on the overlay
- Card scales from 1.0x to 0.9x with opacity 1 → 0
- Duration: 250ms
- After dismiss animation completes, return Future so calling code
  can proceed to XP animation

---

## Fix 2: Sequential Completion Flow

### The Problem
Badge, XP, and Continue all appear at the same time. Three reward
elements competing = none of them land.

### The Solution
Each reward element gets its own moment in strict sequence. Nothing
appears until the previous step completes.

### Sequence
```
0. User answers The Verdict
   → completeEvent() + clearHotspotProgress() AWAITED
   → checkAndAwardBadges() returns any new badges
   → Correct answer highlights with animation
   → "History records..." explanation animates in

1. BADGE MOMENT (if earned)
   → 500ms pause after explanation is fully visible
   → Full-screen dark overlay fades in (300ms)
   → Badge card appears with pop animation
   → User reads, taps to dismiss
   → Overlay fades out (250ms)

2. XP MOMENT
   → 300ms pause after badge dismiss (or after explanation if no badge)
   → Star pops in (scale 0.5 → 1.2 → 1.0, 400ms)
   → Gold particle burst fires (8-12 dots expanding outward, 500ms)
   → XP number counts up 0 → earned value (600ms, ease-out)
   → Total XP line fades in: "★ 0 → 20" (300ms)

3. CONTINUE MOMENT
   → 1000ms pause after XP total appears
   → "Continue Journey →" button fades in (300ms)
   → User taps → Navigator.pop(context, true)
```

### Key Rules
- The badge overlay covers EVERYTHING — XP and Continue are not
  visible behind it
- XP does not start animating until the badge overlay is fully
  dismissed
- Continue button does not appear until XP animation is fully
  complete plus a 1-second pause
- If no badge is earned, skip step 1 entirely — go straight from
  explanation to XP animation

### Implementation Approach
Use a state machine or sequential async/await:

```dart
Future<void> _runCompletionSequence() async {
  // Data writes (immediate, safe against crashes)
  await PrefsService.completeEvent(
      widget.event.globalOrder, widget.event.xpReward);
  await PrefsService.clearHotspotProgress(widget.event.id);

  final newBadges = await PrefsService.checkAndAwardBadges(
      widget.event.globalOrder);

  // Wait for explanation to be visible
  await Future.delayed(const Duration(milliseconds: 500));

  // Step 1: Badge (if earned)
  if (newBadges.isNotEmpty && mounted) {
    for (final badge in newBadges) {
      await _showBadgeOverlay(badge); // returns when user dismisses
    }
    await Future.delayed(const Duration(milliseconds: 300));
  }

  if (!mounted) return;

  // Step 2: XP animation
  setState(() => _showXp = true);
  _xpAnimController.forward(); // star pop + count-up + total
  await Future.delayed(const Duration(milliseconds: 1500));

  if (!mounted) return;

  // Step 3: Continue button
  setState(() => _showContinue = true);
  _continueAnimController.forward(); // fade in
}
```

The _showBadgeOverlay method shows an overlay route (or an overlay
widget within the same screen) and returns a Future that completes
when the user taps to dismiss.

---

## Fix 3: Badge Icon Quality

### Current Problem
The sunrise emoji (🌅) renders small and low-impact even at 64px.

### Short-Term Fix
Make the emoji 64px and add the pop animation. Use the best-matching
emoji for each badge:
- First Step: 🌅
- Witness of the Dawn: 🌙
- Companion of the Beginning: ⭐
- Steadfast in Mecca: 🕋
- Guardian of the Legacy: 🏛️
- Seeker of Truth: 📜
- The Rawi: 👑

### Better Fix (When Time Allows)
Create a simple SVG shield or seal shape for each badge:
- Shield outline in gold
- Interior filled with the chapter's accent color
- Emoji or simple icon centered inside the shield
- This makes every badge feel like an actual medal/achievement
  rather than a floating emoji

### Even Better Fix (Post-MVP)
Generate proper badge artwork via Bing Image Creator — small square
icons with the painterly gold style matching the app. One prompt per
badge. Add to the visual prompts queue.

---

## Summary of Changes

| Item | What to Do |
|------|-----------|
| Dark overlay opacity | Increase to 85%, cover entire screen |
| Badge card width | 80% of screen width |
| Text underlines | Remove all underlines |
| Badge icon size | 64px with pop animation |
| Card entry animation | Scale 0.85→1.0 with fade in |
| Card border | Gold, full opacity, subtle glow |
| Flow sequence | Badge → XP → Continue (never simultaneous) |
| XP visibility | Hidden until badge is dismissed |
| Continue visibility | Hidden until XP animation completes + 1s |
| Dismiss behavior | Tap anywhere, fade out, return Future |
