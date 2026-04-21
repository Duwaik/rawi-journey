# RAWI — Bug Investigation Apr 21, 2026

> **Source brief:** `RAWI_BUG_INVESTIGATION_BRIEF.md` (events 1–27 device playthrough)
> **Status:** findings only — no code fixes. Planning Claude will spec fixes into v4.1.
> **Method:** code is source of truth. Khaled's observations used only to pinpoint what to grep for; exact event numbers and before/after timing come from files.

---

## TL;DR

| Bug | Root cause | Code wired? | Fix priority |
|-----|-----------|-------------|--------------|
| **A** · Threshold gates stop after 2 | `thresholdChallenges` data list has only 2 entries (events 6, 12). Logic is correct; **content is missing** for planned events 18/25/31/37/43. | ✅ wired | High — content authoring |
| **B** · Witness Moment triggers | Per-event attribute, fires BEFORE event start. 9 events carry one: **14, 17, 19, 24, 29, 31, 34, 47, 150**. | ✅ wired | None — works as designed. ARCHITECTURE.md is misleading (conflates with Chapter Review). |
| **C** · "From Mortal to Messenger" | It's a **Passage** (R20 Part E), fires AFTER event completion. 5 total: **14, 42, 47, 82, 120**. One-shot via `passage_seen_*` pref. | ✅ wired | None — works as designed. Just undocumented. |
| **D** · `27` vs `26/155` | Two different meters. Events list shows `event.globalOrder`; tent shows `completedCount / 155`. Both mathematically correct after finishing 26. | N/A — labeling | Low — UX label clarity |
| **E** · 25-event milestone quiz | `ChapterReviewScreen`, `ChainScreen`, `getChapterReviewAfter`, `getChainAfter` all defined but **never called**. Orphaned code + content. | ❌ **NOT wired** | Medium — feature never shipped |

---

## BUG-A · Threshold gate recurrence

### What Khaled saw
Two `THE THRESHOLD / العَتَبَة` cards fired in the events 1–13 range, then nothing through event 27.

### What the code says
Data file [`lib/data/threshold_challenges.dart`](lib/data/threshold_challenges.dart) defines **only 2** `ThresholdChallenge` entries: `beforeEventOrder: 6` and `beforeEventOrder: 12`. Lines 7–8 comment explicitly states the **intended** cadence:

> In M1, thresholds appear before Events: **6, 12, 18, 25, 31, 37, 43**. Content added as events are written.

Trigger logic in [`lib/screens/event_list_screen.dart:126-128, 215-217, 342-344`](lib/screens/event_list_screen.dart) calls `getThresholdBefore(event.globalOrder)`. Returns `null` for any event not in the list → no gate fires. Logic is correct.

### Root cause
**Content, not code.** The cadence was specced as every 5–7 events but only events 6 and 12 have authored content. Events 18/25/31/37/43 are placeholder slots waiting for Khaled's content pack.

### Intended vs shipped

| globalOrder | Intended | Shipped | Event title |
|-------------|----------|---------|-------------|
| 6 | ✅ | ✅ | before "Death of Aminah" |
| 12 | ✅ | ✅ | before "The Black Stone" |
| 18 | ✅ | ❌ | before "The Torture of the Weak" (actually HS-adjacent — see below) |
| 25 | ✅ | ❌ | before "Boycott Ratified" |
| 31 | ✅ | ❌ | before "Journey to Ta'if" |
| 37 | ✅ | ❌ | before "Stub 37" |
| 43 | ✅ | ❌ | before "Stub 43" |

Note: intended event 18 threshold currently has no content, and event 18 title is **"Umm al-Mu'minin (The Call Goes Public)"** per [`lib/data/m1_data.dart`](lib/data/m1_data.dart) — verify against content-pack intent when authoring.

### Flagged for fix
**Yes — authoring task, not code task.** Ticket: author 5 threshold challenges for events 18/25/31/37/43 following the Quran/hadith-citing style of the existing two. Planning Claude should decide whether v4.1 ships all 5 at once or partial.

---

## BUG-B · Witness Moment trigger mapping

### What Khaled saw
Multi-screen poetic sequences under "The Witness Moment" header firing around several named events. Wasn't sure before vs after.

### What the code says

**File:** [`lib/screens/witness_moment_screen.dart`](lib/screens/witness_moment_screen.dart) (the screen) + [`lib/models/witness_intro.dart`](lib/models/witness_intro.dart) (the model) + per-event `witnessIntro` fields in [`lib/data/m1_data.dart`](lib/data/m1_data.dart).

**Trigger point:** [`lib/screens/event_launcher.dart:173-194`](lib/screens/event_launcher.dart) — after `EventIntroScreen.onComplete` fires, the launcher checks `event.witnessIntro != null`. If set, it pushes `WitnessMomentScreen` before `ImmersiveEventScreen`. So **WM fires BEFORE the event it's attached to**, between the intro cinematic and the playable scene.

**Advancement:** pure auto-timer inside `WitnessMomentScreen._runSequence` — 500 ms fade-in + 2000 ms hold + 400 ms fade-out per line, last line holds 3000 ms then fades. No tap/swipe input. Typical ~12–15 seconds total.

### Definitive trigger list (grep-confirmed in m1_data.dart)

| globalOrder | id | title | fires |
|-------------|----|-------|-------|
| **14** | `j_1_2_7` | The First Revelation | before event |
| **17** | `j_1_3_1` | The Call Goes Public — Mount Safa | before event |
| **19** | `j_1_3_3` | The Torture of the Weak | before event |
| **24** | `j_1_3_7` | Umar Accepts Islam | before event |
| **29** | `j_m1_029` | Year of Grief — Death of Khadijah | before event |
| **31** | `j_m1_031` | Journey to Ta'if | before event |
| **34** | `j_m1_034` | Al-Isra' wal-Mi'raj | before event |
| **47** | `j_m1_047` | Entry into Medina — The City Rejoices | before event |
| **150** | `j_m4_150` | The Departure | before event |

**9 Witness Moments** total across the 155-event journey. Khaled playing events 1–27 would see 4 of them: 14, 17, 19, 24. Matches his "at least 3x in the 14–26 range."

### Contradiction with ARCHITECTURE.md

[`ARCHITECTURE.md:27-35`](ARCHITECTURE.md) titles its table "Chapter Review breakpoints (5 reviews)" with events 14/47/82/120/155. This is **triple-misleading**:

1. **Chapter Reviews are not wired** — see BUG-E.
2. **What actually fires at 14** is a Witness Moment (before) + a Passage (after — see BUG-C), not a Chapter Review.
3. The "5 reviews" list is also **not the Witness Moment list** (14/17/19/24/29/31/34/47/150) nor the **Passage list** (14/42/47/82/120).

### Flagged for fix
**No code fix.** Works as designed. ARCHITECTURE.md needs to be rewritten to distinguish Witness Moments, Passages, and the unwired Chapter Reviews as three separate systems.

---

## BUG-C · "From Mortal to Messenger" card

### What Khaled saw
A single-screen gold serif card reading "FROM MORTAL TO MESSENGER / من بشرٍ إلى رسول" around the event 13/14 boundary. Distinct from Witness Moment (WM has multiple screens + different header).

### What the code says

Literal string match in [`lib/data/passages_data.dart:8-9`](lib/data/passages_data.dart). This is a **Passage** (R20 Part E — defined in the comment at line 3: "The 5 Passage moments across the 155-event Seerah. Rare, weighty, memorable. Each plays once after a pivotal event.").

**Trigger:** [`lib/screens/unified_completion_screen.dart:539-568`](lib/screens/unified_completion_screen.dart). Inside `_continueJourney` (called when the user finishes the end-of-event flow), the code runs `getPassageAfter(event.globalOrder)` and if a passage is returned + not already seen + not replay → it pushes `PassageScreen` via `pushAndRemoveUntil`, which then navigates to the tent on complete.

**One-shot guarantee:** `PrefsService.setPassageSeen(globalOrder)` writes `passage_seen_<order>` = true. On replay or next run, `shouldShowPassage` is false.

### Definitive passage list

| `afterEvent` | titleEn | titleAr | Quote source |
|--------------|---------|---------|--------------|
| **14** | From Mortal to Messenger | من بشرٍ إلى رسول | Al-Alaq 96:1 |
| **42** | The Road to a New Home | الطريق إلى دارٍ جديدة | At-Tawbah 9:40 |
| **47** | The Dawn is Complete | اكتمل الفجر | An-Nahl 16:41 |
| **82** | The Tide Turns | تحوّل المدّ | Al-Ahzab 33:25 |
| **120** | Victory Approaches | النصر يقترب | An-Nasr 110:1 |

**5 Passages total.** Khaled playing events 1–27 would see exactly 1: "From Mortal to Messenger" after completing event 14.

### Why 13 vs 14 uncertainty resolves

Event 14 is sandwiched between two separate cinematics:
1. **Pre-event:** Witness Moment (WM) fires BEFORE event 14 starts — "You have witnessed the moment the truth left the shadows" (per the screenshot Khaled described).
2. **Post-event:** Passage "From Mortal to Messenger" fires AFTER event 14 completes, on the way to the tent.

So he saw WM before the event and Passage after — both tied to event 14, neither tied to 13. His note "13/14 boundary" captures the after-13 = before-14 window correctly; the card he saw specifically was the post-14 Passage.

### Flagged for fix
**No code fix.** Works as designed. Just needs an ARCHITECTURE.md section documenting Passages as a distinct system with its own 5-event list.

---

## BUG-D · Event numbering `27` vs `26 / 155`

### What Khaled saw
- Events list: "Three Years of Siege" shown with `27` in the circular badge.
- Tent: counter reads `26 / 155` for the same event.

### What the code says

**Events list badge** ([`lib/screens/event_list_screen.dart:460`](lib/screens/event_list_screen.dart)):
```dart
'${event.globalOrder}'
```
Renders the event's own `globalOrder`. "Three Years of Siege" has `globalOrder: 27` in [`lib/data/m1_data.dart:1134`](lib/data/m1_data.dart).

**Tent counter** ([`lib/screens/rawi_tent_screen.dart:464`](lib/screens/rawi_tent_screen.dart)):
```dart
'$completed / ${m1Events.length}'
```
Where `completed` is defined at line 71:
```dart
int get _completedCount {
  int c = 0;
  for (final e in m1Events) {
    if (PrefsService.isEventCompleted(e.globalOrder)) c++;
  }
  return c;
}
```
And `m1Events.length == 155` (variable is misnamed — holds all 155 events across M1–M4, not just M1).

### Root cause
**Two different meters, both mathematically correct:**
- Events list `27` = this event's `globalOrder` (its position in the full sequence).
- Tent `26 / 155` = number of events the user has completed / total.

After finishing event 26 (Boycott Ratified) and before finishing event 27, `completed = 26`. The next event to play is globalOrder 27. The difference of 1 is inherent to the measurement choice — one is a position index, the other is a completion count.

### Why it reads as a bug
The tent label `$completed / 155` reads to the user as "I'm on event 26 of 155" when it actually means "I've finished 26 events." Zero ambiguity would come from either:
- Changing tent label to `${completed} completed · ${m1Events.length} total` (explicit semantic), or
- Changing tent label to `${m1Events[completed].globalOrder} / 155` (match list badge — "next event is #27").

**Second form has an off-by-one risk** when completed == 155 (no next event); first form avoids that entirely.

### Integrity sanity checks passed
- [`lib/data/m1_data.dart`](lib/data/m1_data.dart) has exactly 155 `globalOrder:` entries (verified by grep count).
- No duplicate globalOrder values (verified by `grep -c`).
- `m1Events.length = 155` in the getter at line 6136: `final int m1EventCount = m1Events.length;`.

### Flagged for fix
**Yes — low-priority UX label change.** Planning Claude should pick between the two reform options. Likely `26 / 155 completed` or `Event 27 of 155`. No data change needed.

---

## BUG-E · 25-event milestone quiz

### What Khaled saw
No milestone quiz fired through events 1–27, though his mental model suggested one should at 25/26.

### What the code says

**Screens exist but are never instantiated:**
- [`lib/screens/chapter_review_screen.dart`](lib/screens/chapter_review_screen.dart) — `class ChapterReviewScreen extends StatefulWidget` defined.
- [`lib/screens/chain_screen.dart`](lib/screens/chain_screen.dart) — `class ChainScreen extends StatefulWidget` defined.

Grep across the entire `lib/` tree for `ChapterReviewScreen(` or `ChainScreen(` constructor calls:

```
d:\Rawi_Journey\lib\screens\chapter_review_screen.dart  (class definition only)
d:\Rawi_Journey\lib\screens\chain_screen.dart  (class definition only)
```

**Zero constructor calls.** The screens are dead code — they're never pushed onto the navigator.

**Data exists but the getter is never called:**
- [`lib/data/chapter_reviews.dart`](lib/data/chapter_reviews.dart) — 5 `ChapterReview` entries at afterEventOrder 14/47/82/120/155, each with multi-question quizzes. `getChapterReviewAfter(int globalOrder)` defined at line 596.
- [`lib/data/chain_moments.dart`](lib/data/chain_moments.dart) — 1 `ChainMoment` entry at afterEventOrder 25 ("The Brotherhood — Muakhah"). `getChainAfter(int globalOrder)` defined at line 22.

Grep for `getChapterReviewAfter(` and `getChainAfter(` callers: **zero call sites** outside their own definitions and the `tools/build_chapter_reviews.py` generator.

### Root cause
**Feature is spec-only / orphaned code.** The data, model, and UI screen for both Chapter Review quiz and Chain Transmission moments were built, but nobody ever wired the trigger in. `unified_completion_screen._continueJourney` checks for Passage (`getPassageAfter`) and routes to `PassageScreen`, but it doesn't check for Chapter Review or Chain — it goes straight to tent.

### Note on the `_continueJourney` handoff point
This is the natural home for both triggers. The existing Passage branch at [`unified_completion_screen.dart:539-568`](lib/screens/unified_completion_screen.dart) is the pattern to mirror when the feature is actually wired.

### ARCHITECTURE.md drift
Line 31 says "Chapter Review breakpoints (5 reviews): Review 1 · #14 · Pre-prophethood complete — **TRIGGERS NOW**". This is wrong — it triggers **never**. The "TRIGGERS NOW" marker was probably accurate when written (future agents should treat pre-audit markers as aspirational).

### Flagged for fix
**Yes — feature wiring, medium priority.** Planning Claude should decide:
1. Wire Chapter Review at event 14/47/82/120/155 (5 quizzes, after Passage).
2. Wire Chain Moment at event 25 (currently 1 entry; spec calls for 25/50/75/100/125/155 per `lib/data/chain_moments.dart:3`).
3. Or move both to a post-launch sprint and update ARCHITECTURE.md to mark them as "shipped-but-unwired / spec-only."

---

## Consolidated ARCHITECTURE.md deltas (input for Tier 1 refresh)

When the Tier 1 doc refresh happens, these corrections must land:

1. **Replace the "Chapter Review breakpoints" table** with three separate tables:
   - **Witness Moments** (9 events, fires BEFORE event start) — 14, 17, 19, 24, 29, 31, 34, 47, 150
   - **Passages** (5 events, fires AFTER event completion) — 14, 42, 47, 82, 120
   - **Chapter Reviews** (5 defined but **⚠️ NOT WIRED**) — 14, 47, 82, 120, 155
   - **Chain Moments** (1 defined, 6 planned, **⚠️ NOT WIRED**) — currently 25; planned 25, 50, 75, 100, 125, 155
   - **Thresholds** (2 authored of 7 planned) — authored 6, 12; planned 18, 25, 31, 37, 43

2. **Tent counter semantics** — document that `$completed / 155` is completed-count, not next-event-globalOrder. Add a note flagging the UX ambiguity for future redesign.

3. **Remove the "TRIGGERS NOW" marker** from the Chapter Review row (inaccurate).

4. **Add note:** `lib/screens/chapter_review_screen.dart` and `lib/screens/chain_screen.dart` are orphaned; they're built UI waiting for a trigger wiring in `unified_completion_screen._continueJourney`.

5. **Rename** or at least annotate `m1Events` in [`lib/data/m1_data.dart`](lib/data/m1_data.dart) — the variable holds all 155 events across M1–M4 despite the M1-scoped name. (This is a potential future refactor; flag but don't mandate.)

---

## What's NOT flagged

- No additional bugs surfaced during investigation.
- No drift found in Passage/WitnessMoment trigger logic — both work as designed.
- No data-integrity issues in the 155-event globalOrder sequence.
- No stale "+50% noor" / removed-Continue-button / session-dhikr-flag references popped up in the files I touched (consistent with the earlier doc audit).

---

_Investigation complete Apr 21, 2026 evening. All findings are code-sourced; Khaled's field recall was used only to pinpoint search targets. Planning Claude — over to you for v4.1 spec._
