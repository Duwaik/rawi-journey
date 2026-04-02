# CRITICAL FIX: Event Completion Flow

## Priority: HIGHEST — Ship-blocking bug

This bug makes the app feel broken. The user completes an event,
gets redirected to the events list, and sees NO progress update.
They must replay the event to see their progress. This has been
reported multiple times and must be permanently fixed.

---

## The Bug (Three Symptoms)

### Symptom 1: Progress not showing after completion
User completes The Verdict → answers question → sees "History
records..." → sees XP → gets auto-redirected to events list →
events list shows the event as NOT completed (Play button still
there, no 4/4, next event still locked).

### Symptom 2: Double-play required
User taps Play again → goes through cinematic transition → lands
directly on The Verdict with "Back to Events" button → taps back →
NOW the events list shows 4/4 and next event is unlocked.

### Symptom 3: Partial save on phone lock
If the user does nothing after the first redirect (doesn't replay),
and the phone locks/unlocks after some time, Event 1 shows 4/4 but
Event 2 remains locked.

---

## Root Cause: Race Condition

The auto-pop timer fires Navigator.pop() BEFORE the async
PrefsService writes have completed. The sequence is:

```
CURRENT (BROKEN):
1. User answers question
2. completeEvent() called — async, returns Future
3. clearHotspotProgress() called — async, returns Future
4. Timer(1-2 seconds) fires Navigator.pop()    ← NOT AWAITING steps 2-3
5. Events list rebuilds, reads SharedPreferences ← stale data
6. User sees no progress
```

The writes are fire-and-forget. The pop happens on a timer regardless
of whether the data has been persisted. SharedPreferences.setX()
returns a Future<bool> — if you don't await it, the write may not
have hit disk when the events list reads the same keys.

---

## The Fix

### Part 1: Await ALL writes before popping

```
FIXED:
1. User answers question
2. Show explanation + XP (no timer, no auto-pop)
3. User taps "Continue →" button (manual CTA)
4. Show loading indicator briefly
5. await PrefsService.completeEvent()       ← AWAIT
6. await PrefsService.clearHotspotProgress() ← AWAIT
7. await PrefsService.unlockNextEvent()      ← AWAIT (if separate)
8. ONLY THEN: Navigator.pop(context, true)   ← pass result
9. Events list receives pop result, calls setState() to rebuild
```

The critical change: NO TIMER. No auto-pop. The user controls when
they leave via a manual button, and the pop ONLY happens after all
writes are confirmed.

### Part 2: Remove the auto-pop timer entirely

Delete any Timer, Future.delayed, or scheduled callback that calls
Navigator.pop after the question is answered. Replace with a manual
CTA button.

The current 1-2 second timer is the direct cause of this bug AND
it prevents users from reading the "History records..." explanation.
Two problems solved by one deletion.

### Part 3: Add a manual "Continue" CTA

After the user answers The Verdict and the explanation is shown:

```
[History records... explanation text]

[Go Deeper] ← collapsible, if content exists (future)

         ⭐ +20 XP          ← prominent gold badge

    [ Continue Journey → ]  ← gold button, full width
```

The "Continue Journey →" button:
- Does NOT appear until the explanation has fully rendered
- On tap: awaits all PrefsService writes
- On tap: then calls Navigator.pop(context, true)
- Label changes based on context:
  - "Continue Journey →" if next event exists
  - "Chapter Complete →" if this was the last event in a chapter
  - "Journey Complete →" if this was the last event (Event 36)

### Part 4: Events list must rebuild on pop

When Navigator.pop returns to the events list, the list must
explicitly rebuild its state. Do NOT rely on the widget just being
there — call setState() or re-read from PrefsService in the
.then() callback or in the didPopNext/didChangeDependencies.

```dart
// When launching an event:
final result = await Navigator.push(context, eventRoute);
if (result == true) {
  // Event was completed — force refresh
  await _loadProgress();  // re-read all prefs
  setState(() {});        // rebuild the list
}
```

If the events list is using a FutureBuilder or StreamBuilder on
PrefsService, make sure the underlying data source actually emits
a new value after the writes. SharedPreferences is not reactive —
you must manually trigger a refresh.

### Part 5: Next-event unlock must be part of the atomic write

The unlock logic for the next event must happen in the SAME await
chain as the completion write. Not in a separate lifecycle callback,
not in an initState on the events list, not in a delayed future.

```dart
Future<void> completeEventAndUnlockNext(String eventId) async {
  await _prefs.setBool('event_${eventId}_completed', true);
  await _prefs.setInt('event_${eventId}_hotspots', 4);

  // Determine next event ID
  final nextId = _getNextEventId(eventId);
  if (nextId != null) {
    await _prefs.setBool('event_${nextId}_unlocked', true);
  }

  // ALL writes done atomically before this method returns
}
```

Then in the completion handler:
```dart
await PrefsService.completeEventAndUnlockNext(event.id);
Navigator.pop(context, true);
```

---

## XP Display Enhancement

While fixing the flow, also improve how XP is shown at completion:

### Current
Small "+20 XP" snackbar that appears briefly and disappears with
the auto-pop timer.

### Fixed
Prominent XP badge inside The Verdict card, positioned between the
explanation and the Continue button:

- Gold star icon (24px) + "+20 XP" text in gold, 18px, weight 500
- Centered in the card
- Subtle scale animation on appear (0.8 → 1.0 over 300ms)
- Stays visible — does not auto-dismiss
- The snackbar version is REMOVED (redundant with the in-card badge)

---

## Testing Checklist

After implementing, test ALL of these:

[ ] Complete Event 1 → tap Continue → events list shows 4/4
    immediately, Event 2 shows Play button
[ ] Complete Event 1 → lock phone → unlock → events list shows
    4/4 AND Event 2 is playable
[ ] Complete Event 1 → force-kill app → reopen → progress persisted
[ ] Complete Event 2 → events list shows Event 3 unlocked
[ ] Complete all events in Jahiliyyah chapter → verify chapter
    completion state is correct
[ ] During The Verdict, user can read full "History records..."
    text without being auto-redirected
[ ] "Continue Journey →" button only appears after explanation
    is fully rendered
[ ] XP badge is visible and prominent in the card
[ ] Arabic mode: same flow, RTL layout, all text correct
[ ] Back button/gesture is DISABLED during The Verdict until
    after the user has answered

---

## Summary for Agent

The fix is conceptually simple:
1. DELETE the auto-pop timer
2. ADD a manual "Continue Journey →" button
3. AWAIT all PrefsService writes before calling Navigator.pop
4. PASS a result back to the events list so it knows to rebuild
5. Combine completion + unlock into one atomic async method

This is not a UI problem. It's a write-then-read race condition
caused by not awaiting async operations. The timer masks the bug
by making it seem like a timing issue, but the real fix is: don't
pop until writes are confirmed, and don't pop without user intent.
