# RAWI R28-S3 Phase 1 Handoff

**Bundle:** R28 S3 Phase 1 — Reader foundation + writing animation engine
**Round:** R28 — Apr 25 morning kickoff after Phase 1 spec rewrite (S3 → P1 + P2 split)
**Spec:** `RAWI_R28_S3_PHASE1_SPEC.md` (Downloads, Apr 25)
**Full design reference:** `RAWI_R28_S3_SPEC.md` (do NOT implement Phase 2 items from this)
**Parent build:** R28-S2 MEDIUM handoff `67168f7`
**Agent:** Claude Code (Claude Opus 4.7, 1M context)
**Date:** Apr 25 2026

---

## What this phase ships

Reader mode goes from the **quadrant-card** layout (4 cards in a 2×2 grid around a stationary center figure, R20-Part-C v3) to the **bottom-card pages** layout (35 % parchment card at the bottom, scene + small distant figure with a book in the top 65 %, swipeable PageView with manuscript-style writing animation per page).

Phase 1 is foundation only — branching expansion, Reader's Note one-time tutorial, reading-room ambient audio, and end-of-event flow integration on the bottom-card surface are all parked for Phase 2.

---

## Starting-state reconciliation (flagged + resolved before code)

The original R28-S3 spec described the work as "April S4 survivors (refined)" + a few reverses, implying April S4 had landed. It hadn't — the codebase was the pre-S4 quadrant-card Reader. Khaled greenlit a fresh Phase 1 spec covering the foundation as net-new infrastructure rather than refinement of nonexistent code.

The R28_S3_PHASE1_SPEC.md formalises this — items P1-01 through P1-11 cover ~1,237 lines of net-new and modified code. R28_S3_SPEC.md (the original) stays as a full design reference but its commit-order assumptions are superseded by the Phase 1 spec.

---

## Commits

| ID         | Hash       | Description |
|------------|------------|-------------|
| P1-01      | `7b4c8fd`  | tear out quadrant card render path from Reader |
| P1-09      | `f82e811`  | stationary Reader figure 0.55× + CustomPaint book sprite |
| P1-10      | `35006a3`  | gate info tab to Explorer mode |
| P1-03      | `345ed1f`  | ManuscriptWritingText widget (shared writing engine) |
| P1-02      | `c287430`  | ReaderBottomCard 35% scaffold (single page) |
| P1-04+05   | `839316e`  | PageView swipe + bottom chevron arrow with pulse |
| P1-06      | `a2bfed7`  | tap-to-complete writing animation per page |
| P1-07      | `3fb63a4`  | vertical scroll on overflow + edge indicator |
| P1-08      | `05f3ee5`  | 4 page dots synced with page index |
| P1-11      | `0c69b9c`  | 1-second establishing beat before page 1 reveal |
| P1-tests   | `ef851c8`  | widget tests + cumulative reveal scheduling fix |

11 commits, one per spec item (P1-04+05 bundled per the spec's suggested order).

The "R28 S3-P1-V: Verification + Explorer regression sweep" commit from the spec's §11 is intentionally absent — V-01/V-02/V-03 are verification statements, not code. The verification details live in the V-Verification section below and in the test additions.

The commit order does not match the spec's §11 strictly: P1-01 → P1-09 → P1-10 → P1-03 → P1-02 → P1-04+05 → P1-06 → P1-07 → P1-08 → P1-11 → tests. Rationale: P1-09 and P1-10 are tiny isolated edits to immersive_event_screen.dart that I batched right after the P1-01 cleanup (all 3 touch the same file) so the screen reaches a coherent state before the bottom-card widgets land. The widgets-only commits (P1-03 onward) then build cleanly on top.

---

## APK

- Path: `build/app/outputs/flutter-apk/app-release.apk`
- Size: 97,700,637 bytes (93.17 MB / 97.70 MB) — +376,832 bytes over R28-S2
- **APK SHA256:** `123f2a65135a6ef3f17c761cfff7ecd85aa4677bd744e1756ba91df0bf058b3d`
- **libapp.so arm64 (stripped) SHA256:** `26b75127cd921f56fbf3a5f7aa2c83a56853685b2596b50c12eec18b1593df28`

`libapp.so` hash moved from R28-S2's `e96e06f10da815e3aacba9046b5e46dd792be1638cb04ee6f3d2cda01fa8ffbb`
→ R28-S3 P1's `26b75127cd921f56fbf3a5f7aa2c83a56853685b2596b50c12eec18b1593df28` ✓

APK hash moved from R28-S2's `d5954af17fb576bfb6acef9bff711ec85eabee41614eb070a78ba36777f822be`
→ R28-S3 P1's `123f2a65135a6ef3f17c761cfff7ecd85aa4677bd744e1756ba91df0bf058b3d` ✓

Build: `flutter clean` → `flutter pub get` → `cd android && gradlew.bat assembleRelease`.
`BUILD SUCCESSFUL in 10m 57s`.

---

## Architectural decisions

### P1-01 — quadrant card path removed, file kept

`reader_hotspot_card.dart` and the `ReaderCardQuadrant` / `ReaderCardState` enums stay in the repo — Phase 1 spec §10 says "keep the file/enum if other code references it; flag for full deletion in Phase 2 cleanup if it becomes truly orphaned."

Removed from `immersive_event_screen.dart`:
- import of `widgets/cinematic/reader_hotspot_card.dart`
- `_readerQuadrant(int)` helper
- `_readerCardState(SceneHotspot)` helper (linear + branching state machine)
- `_onReaderCardTap(SceneHotspot, ReaderCardState)` dispatcher
- the Reader render branch inside the hotspot-markers IIFE

The IIFE wrapper at `~line 2197` (was `...(() { if (_explorerMode) {return X;} else {return Y;} }())`) collapsed: the outer condition gates on `_explorerMode`, the body is a direct `_scene.hotspots.map(...)` over Explorer markers. Net `~150` lines removed.

What stays: `_onHotspotTap`, `_onBranchSelected`, `_isBranching`, `_discovered`, `_pendingDiscovery` — broadly used by Explorer + the branching engine. Phase 2 will reuse most of these for Reader page-progression / branch wiring.

### P1-09 — figure scale via Transform.scale, book sprite as a sibling Stack child

Two ways to scale the Reader figure:
- **A**: pass a scale param into `RawiFigure` and have it size its internal SizedBox.
- **B**: keep RawiFigure unchanged (still a 68×86 SizedBox internally), wrap in `Transform.scale(scale: 0.55, alignment: Alignment.center)`.

Picked **B**. Keeps the figure widget untouched (zero risk to Explorer figure rendering, matches BG-frozen rule's spirit), and the book sprite can be a sibling `Positioned` inside the same SizedBox so it scales together with the figure under the outer `Transform.scale`.

The book sprite is its own widget `lib/widgets/reader/reader_book_sprite.dart` — pure CustomPaint, no asset file. Two trapezoids meeting at a center vertical spine, parchment fill (`#E8DCC4`), thin ink-line border (`#6B4A1E`). Sized 13×10 in the unscaled SizedBox → ~7.2×5.5 visually after the 0.55× scale. Anchored at `top: 86 * 0.55 - 10/2` ≈ hand area.

The bounce controller (`_figureScale`) is intentionally bypassed for the Reader figure path — spec calls for stationary, no idle sway. Explorer figure render still drives `_figureScale` for its hotspot-celebration bounce, untouched.

**A56-tune flags carried in the commit message:** 45 % vertical position; 55 % book anchor down from figure top; 13×10 book size. All three are constants in `immersive_event_screen.dart` (the `_PageContent` block) and `reader_book_sprite.dart`.

### P1-10 — single-condition info tab gate

The info tab's render condition was `_phase == _Phase.explore && _activeHotspot == null`. Added `&& _explorerMode`. Spec §12 lists this as a two-strike candidate — if A56 still shows the tab in Reader, log the build context's `_explorerMode` at the render site before re-coding. The current single-source-of-truth is `_explorerMode = PrefsService.isExplorerMode` captured once in initState — no per-frame race expected.

### P1-03 — Ticker-driven cumulative scheduling, private quill audio

`ManuscriptWritingText` is a single-Ticker widget. Each frame the ticker callback executes a `while` loop that reveals every unit whose cumulative scheduled deadline has been crossed:

```dart
while (_revealedCount < _units.length && _now >= _nextRevealAt) {
  _units[_revealedCount].revealedAt = _now;
  final justRevealed = _units[_revealedCount];
  _revealedCount++;
  _nextRevealAt = _nextRevealAt + Duration(milliseconds: justRevealed.nextDelayMs);
}
```

Cumulative scheduling — `_nextRevealAt` advances from its OWN previous value, not from `_now`. A late frame catches up multiple units in one tick instead of stalling. (This was originally a per-frame implementation; the test suite caught the failure mode and the cumulative version landed in the same `R28 S3-P1-tests` commit alongside the test.)

Natural completion is also ticker-driven — `_naturalCompletionAt = _now + 150 ms` is set when the last unit reveals; the next frame whose `_now >= _naturalCompletionAt` fires `_completeInternal(natural: true)`. Dropped the original `Future.delayed` because it's harder to drive deterministically from tests.

**AR splitting** is whitespace-based — words are never split internally, so glyph clusters / letter-joins stay intact (spec rule: char-by-char in AR breaks letter connections). Whitespace attaches to the preceding word so layout doesn't shift between reveals.

**Quill audio** lives entirely inside `ManuscriptWritingText` — owns its own `AudioPlayer` instance, never touches `AudioService`. Why: spec §10 says don't touch Scroll's audio path (R28-S2 verify state must not re-open). A self-contained quill player keeps blast radius zero. Asset slug is `assets/audio/sfx/quill_writing_loop.mp3` — does NOT exist in the repo today; widget's setAsset is wrapped in try/catch + DebugLogService.log, so a missing asset is a silent debug entry. Asset drop-in later requires zero code change.

**Pen-nib cursor** is the inline `▎` glyph (left vertical bar) with abs-sin alpha pulse 0.4 → 1.0 over 800 ms. Inserted at the position right after the latest revealed unit. Visual is "writing cursor bar" rather than a custom-painted pen-nib triangle. **Underbaked flag** — if A56 visual feels too text-cursor-y vs the spec's "pen-nib" intent, a small `CustomPaint` triangle inside a `WidgetSpan` is a tight follow-up.

### P1-02 / P1-04 / P1-05 / P1-08 — single ReaderBottomCard widget

All four spec items are part of the same widget so they live together in `lib/widgets/reader/reader_bottom_card.dart`. The widget is StatefulWidget with:

- `_pageCtrl: PageController` — drives slide animation + page index.
- `_pulseCtrl: AnimationController(reverse: true, 1000 ms)` — chevron pulse.
- `_currentPage: int` — listener-set on page round changes.
- `_firstPageReady: bool` — gates page 1's render for the establishing beat (P1-11).

**LTR/RTL via PageView.reverse** — the page-flow direction inverts when `isAr` flips, so swipe-left/right means "forward" consistently per locale. Chevron icon also flips: `chevron_right_rounded` for LTR forward, `chevron_left_rounded` for RTL forward.

**Each page is a `_PageContent`** (a private StatefulWidget) — owns its own `ManuscriptWritingController` + `ScrollController`, so completing page 1 doesn't affect page 2's animation, and scroll position on each page is independent. PageView keeps offstage adjacent pages alive by default — swiping back returns to a page in its current animation state without restart. ValueKey on the hotspot id ensures PageView identifies each page across rebuilds.

**Tap-to-complete (P1-06)** is a `GestureDetector(behavior: HitTestBehavior.opaque, onTap: ...)` wrapping the page content. `controller.completeNow()` is idempotent (early-returns when `_completed`), so post-completion taps are silent no-ops. Horizontal swipes still win the gesture arena because `TapGestureRecognizer` requires no movement — once a finger moves, `PageView`'s `HorizontalDragGestureRecognizer` takes over.

**Vertical scroll (P1-07)** uses `Scrollbar` + `SingleChildScrollView` inside the page padding. Local `Theme` override sets the scrollbar to thickness 2, parchment-ink color (`ReaderBottomCard.inkMuted` at alpha 150). Default `thumbVisibility` (null) = appears on scroll, fades shortly after, never visible when content fits the 35 % card. Edge: `Scrollbar` reads ambient `Directionality`, so the bar lands on the trailing edge automatically — right for LTR, left for RTL. Each page is wrapped in `Directionality(textDirection: isAr ? rtl : ltr)`.

**Page dots (P1-08)** sit at `bottom: bottomPad + 48` (above the chevron at `bottomPad + 12`). 4 dots, 6×6 px, 8 px gap. Current dot uses `AppColors.gold` (the same token as tent pills, settings toggle, Constellation highlight, scroll arc accents). Other dots use `ReaderBottomCard.inkMuted` at alpha 80. `AnimatedContainer(180 ms)` smooths the swap on page change. Always visible, even on the last page when the chevron hides.

### P1-11 — single Future.delayed in initState

`_firstPageReady` flag flips after a 1000 ms `Future.delayed`. While false, the PageView's `itemBuilder` returns an `_EmptyPage` (just `SizedBox.expand`) for index 0 — no `_PageContent`, no `ManuscriptWritingText`, no controllers. After 1 s, setState rebuilds with `_PageContent` and the writing animation begins via its 80 ms internal initial delay.

Pages 2-4: PageView builds them lazily on swipe-in. Each mounts fresh when first reached, so its reveal starts as the user lands on it. Acceptable Phase 1 behaviour — only page 1 needs the establishing beat.

Phase 2 will hoist this beat behind a `noteDismissed` gate so it plays AFTER the Reader's Note dismisses on first-ever event. The current single-`Future.delayed` design is deliberately minimal so Phase 2 can swap the trigger without restructuring.

---

## Per-item summary

### R28 S3-P1-01 · tear out quadrant cards · `7b4c8fd`

See architectural decisions above.

### R28 S3-P1-09 · figure 0.55× + book sprite · `f82e811`

Reader figure block at `~line 2197` of `immersive_event_screen.dart`. Position changed from `top: screenH/2 - 32` to `top: screenH * 0.45 - 43`. Wrapped in `Transform.scale(scale: 0.55, alignment: Alignment.center)`. Bounce controller bypassed for Reader. Book sprite added as a sibling Stack child inside the SizedBox.

`lib/widgets/reader/reader_book_sprite.dart` (new, ~76 lines): `ReaderBookSprite` widget rendering two trapezoid pages meeting at a center spine via `_ReaderBookSpritePainter`. Default size `Size(13, 10)`. Stroke width adapts to the size (`(h * 0.06).clamp(0.5, 1.4)`).

### R28 S3-P1-10 · info tab Reader gate · `35006a3`

Single-condition addition (`&& _explorerMode`) at `~line 2295`. Two-strike candidate per spec.

### R28 S3-P1-03 · ManuscriptWritingText · `345ed1f`

`lib/widgets/reader/manuscript_writing_text.dart` (new, ~420 lines incl. `R28 S3-P1-tests` revisions). Public API + cadence + ink-bloom + cursor + quill audio. Self-contained, zero AudioService coupling.

Cadence values (tunable constants at the top of the State class):
- `_baseEnCharMs = 35`
- `_baseArWordMs = 130`
- `_commaMs = 500` (commas, semicolons, colons — both EN and AR variants)
- `_periodMs = 900` (periods, question marks, exclamation marks — both EN and AR variants)
- `_inkBloomMs = 100` (alpha 0 → 1 fade per revealed unit)
- `_initialDelayMs = 80` (before the very first unit)

### R28 S3-P1-02 · ReaderBottomCard 35% scaffold · `c287430`

Initial scaffold — single page rendering the first hotspot's fragment. PageView, dots, chevron, etc. landed in subsequent commits but live in this same file.

Color tokens (file-private statics, exported via `ReaderBottomCard.parchment` / `.ink` / `.inkMuted`):
- `parchment = #F5E6C8` (matches the Scroll writing screen so future Scroll migration is visually seamless)
- `ink = #3D2A10`
- `inkMuted = #6B4A1E`

Wired into `immersive_event_screen.dart` build tree just before the dim overlay, gated `if (!_explorerMode && _phase == _Phase.explore)`. Hidden during verdict/complete phases — Phase 2 will replace that gate with a Phase-2-aware end-of-event flow.

### R28 S3-P1-04+05 · PageView + chevron · `839316e`

PageView.builder with `reverse: isAr`. Chevron at bottom-center of the card, 12 px above safe-area bottom. 2-second pulse via `AnimationController(reverse: true, 1000 ms)`. Chevron icon flips per locale. Hidden on last page.

### R28 S3-P1-06 · tap-to-complete · `a2bfed7`

GestureDetector wraps each page. Tap = `controller.completeNow()`. Idempotent post-completion. Gesture arena lets horizontal swipes through.

### R28 S3-P1-07 · vertical scroll · `3fb63a4`

Scrollbar + SingleChildScrollView inside the page padding. Local Theme override for thickness 2 + parchment-ink color. Edge handled by ambient Directionality.

### R28 S3-P1-08 · page dots · `05f3ee5`

Row of 4 AnimatedContainers, gold accent on current page, smooth 180 ms color transitions on page change.

### R28 S3-P1-11 · 1-second establishing beat · `0c69b9c`

`_firstPageReady` flag + `_EmptyPage` placeholder for page 1's first second.

### R28 S3-P1-tests · widget tests + reveal-scheduling fix · `ef851c8`

`test/reader_phase1_test.dart` (new, ~278 lines, 6 tests):
1. EN char-by-char reveal completes
2. AR word-by-word reveal completes (no glyph-split crash)
3. controller.completeNow() snaps text + fires onComplete
4. completeNow is idempotent (extra calls = no-op, onComplete fires once)
5. All 4 page dots render with gold accent on page 0
6. Horizontal fling advances current page in LTR (page 1 dot becomes gold)

Bundled fix to `manuscript_writing_text.dart` — cumulative `_nextRevealAt` + ticker-driven natural completion (replacing `Future.delayed`). The original implementation passed `flutter analyze` but failed the EN/AR reveal tests because `tester.pump(5s)` fires a Ticker only once at elapsed=5s, leaving the natural-completion deadline unfired. The fix makes the widget robust under both per-frame ticking on device and large-jump frames in tests.

Test suite: **29/29 pass** (17 arc_registry + 5 branching + 6 reader_phase1 + 1 smoke).

---

## V-Verification (V-01 / V-02 / V-03)

**V-01 — Mode persistence (SharedPreferences):** verified by diff. `lib/services/prefs_service.dart` is unchanged in this phase (`git diff 67168f7..HEAD -- lib/services/prefs_service.dart` is empty). The `journeyMode` key + `setJourneyMode` + `isExplorerMode` getters carry over from R28-S2 untouched.

**V-02 — Mode toggle in tent settings:** verified by diff. `lib/screens/settings_screen.dart` is unchanged in this phase. The "Journey Mode" card + Explorer/Reader switcher are intact.

**V-03 — Scope narrow / Explorer non-regression:** verified by diff scope. Phase 1 modified one shared file (`immersive_event_screen.dart`) and added 4 new files (3 widgets in `lib/widgets/reader/` + 1 test file). All `immersive_event_screen.dart` changes are mode-gated additions or removals of the Reader-only quadrant render path:

- P1-01 removed Reader render branch only — Explorer markers untouched, just lost their IIFE wrapper. Logic identical.
- P1-09 changed Reader figure block only — Explorer figure render at `_companionX/_companionY` is untouched.
- P1-10 added `&& _explorerMode` to the info tab gate — Explorer keeps showing the tab.
- P1-02's wire-in is a new gated render block (`if (!_explorerMode && _phase == _Phase.explore) ReaderBottomCard(...)`).

Files verified untouched in Explorer-side modules: `lib/services/audio_service.dart`, `lib/widgets/cinematic/rawi_figure.dart`, `lib/widgets/event_scene_info_tab.dart`, `lib/widgets/cinematic/fog_of_war.dart`, `lib/widgets/cinematic/atmosphere_widget.dart`, `lib/widgets/cinematic/halo.dart`, `lib/data/scene_configs.dart`, `lib/services/prefs_service.dart`, `lib/screens/settings_screen.dart`, `lib/screens/scroll_writing_screen.dart`, `lib/screens/scroll_viewer_screen.dart`.

**Final cross-mode regression sweep is Phase 2 acceptance work** (per Phase 1 spec §4) — Phase 1's V-03 is the narrower diff-scope check.

---

## Underbaked flag tolerance — carried per spec

1. **Pen-nib cursor visual** — shipped as inline `▎` glyph with abs-sin alpha pulse. If A56 reads as too text-cursor-y vs the spec's "pen-nib" intent, swap to a `CustomPaint` triangle inside a `WidgetSpan`. ~30 LOC follow-up. Scoped to `_buildCursorSpan` in `manuscript_writing_text.dart`.

2. **Quill audio asset missing** — `assets/audio/sfx/quill_writing_loop.mp3` does not exist. Widget handles gracefully (try/catch + debug log). Asset drop-in is zero-code. Audio Settings toggles already respected (sfxEnabled gate).

3. **Pages 2-4 lazy-build behaviour** — PageView builds adjacent pages on swipe-in, so each non-first page's reveal starts as the user lands on it. Spec §5.11 only required the 1 s beat for page 1, so this is acceptable. If A56 testing surfaces "pages already animated when I get there" (unlikely given they only mount on swipe), Phase 2's page-progression wiring is the right place to gate this.

4. **AR letter-joins under per-word TextSpans** — Flutter's text shaping operates on the assembled string regardless of TextSpan boundaries, so AR ligatures should render correctly. The widget tests assert lifecycle (no crash, completion fires), not glyph fidelity — that's A56-judged. If A56 shows broken joins, the diagnostic is to log glyph cluster boundaries inside `_splitArWords` before changing the chunking strategy (per spec §12 two-strike rule).

5. **Figure tune-on-A56 constants** — book at 55 % down from figure top, figure at 45 % from screen top, book size 13×10 in unscaled box. Three single-line constants in `immersive_event_screen.dart` (the Reader figure Positioned block) and `reader_book_sprite.dart`. Spec authorizes visual tuning on device.

6. **Empty Reader on last page after final swipe** — Phase 1 leaves the user on page 4 with no end-of-event flow. Forward swipe past page 4 is a PageView no-op; back-arrow exit returns to tent (Navigation Contract). Spec acceptance: "After last page: forward swipe is a no-op (Phase 2 wires end-of-event flow)."

7. **Visual A56 verification still owed** — the writing-engine test suite asserts state contracts, not visual fidelity. AR letter-joins, ink-bloom feel, cursor pulse rate, scrollbar visibility timing, chevron pulse aesthetic, page-dot color contrast on the parchment background — all device-judged.

---

## Two-strike candidates flagged in spec §12

1. **P1-07 gesture separation** — vertical scroll vs horizontal page advance. If A56 swipes feel ambiguous, log gesture detection at the `GestureDetector` + `Scrollbar` + `PageView` boundary before tweaking. The current implementation relies on Flutter's natural gesture-arena disambiguation (TapGestureRecognizer requires no movement, so as soon as a swipe starts, PageView's HorizontalDragGestureRecognizer wins; SingleChildScrollView captures vertical-only).

2. **P1-03 AR word-by-word reveal** — if letter connections break visually, log glyph cluster boundaries from `_splitArWords` before changing the chunking strategy. Current chunking: whitespace-based, words are atomic.

3. **P1-10 info tab gate** — if A56 shows the info tab in Reader after the gate, log the build context's `_explorerMode` flag value at the render site at `immersive_event_screen.dart:~2295` before re-coding. Single-source-of-truth captured in initState.

---

## Device-verify asks on A56 (priority order)

Spec §8 calls for at least items 1–7 + 11. Recommended order:

1. Fresh install. Set mode to Reader in tent. Open Event 1.
2. Verify the 1-second establishing beat: figure visible centre-scene with the small book at hand area, parchment card sits empty for ~1 s, then page 1 begins writing with quill audio (silent if asset is missing) and a pen-nib cursor tracking the write position.
3. Mid-writing, tap on the text. Animation snaps to fully revealed. Cursor disappears. Quill silences immediately.
4. Swipe left (LTR forward) → page 2 slides in. Page 2 begins writing.
5. Tap bottom chevron → page 3.
6. Swipe right → page 2 (back-nav). Page 2 stays in its completed state.
7. Swipe left → page 3 → page 4. On page 4, chevron is hidden. Forward swipe is a no-op.
8. Switch app language to AR (tent → settings). Re-open Event 1. Verify AR text reveals word-by-word, RTL swipe direction works (right = forward), chevron points left.
9. (If a long-fragment event is available — events 1-5 may all fit) trigger an overflow page and verify vertical scroll works with horizontal swipe still advancing.
10. Verify scene info tab is hidden in Reader.
11. Switch to Explorer in tent settings. Open Event 1. Run a full Explorer Event 1. Verify figure walks, info tab visible, no quadrant cards leftover. **This is the V-03 device-side check.**
12. Switch back to Reader. Verify mode persisted (V-01 / V-02).
13. Kill app. Restart. Verify mode still Reader.
14. Audio: missing `quill_writing_loop.mp3` does not crash; debug overlay should show one "asset missing" log entry at writing animation start.

---

## Not done this phase (Phase 2 work)

Per Phase 1 spec §4:

- Branch as card page + 35 → 50 → 35 expansion animation (events 1, 2, 3) — full-spec S4-1, S4-4, N7
- Reader's Note one-time tutorial card with `reader_note_seen_v1` flag — full-spec N6
- Reading-room ambient audio layer — full-spec N5
- End-of-event flow integration on Reader bottom-card surface (Event Question, dhikr card, XP reveal sequencing) — full-spec inherited locks
- Final Explorer regression sweep across full Reader sessions — full-spec S4-10 acceptance

---

## Build state at handoff

After this commit, the branch is **11 commits** beyond R28-S2 MEDIUM handoff (`67168f7`) plus this handoff doc:

```
[handoff]   this commit
ef851c8  R28 S3-P1-tests:    widget tests + cumulative reveal scheduling fix
0c69b9c  R28 S3-P1-11:       1-second establishing beat before page 1 reveal
05f3ee5  R28 S3-P1-08:       4 page dots synced with page index
3fb63a4  R28 S3-P1-07:       vertical scroll on overflow + edge indicator
a2bfed7  R28 S3-P1-06:       tap-to-complete writing animation per page
839316e  R28 S3-P1-04+05:    PageView swipe + bottom chevron arrow with pulse
c287430  R28 S3-P1-02:       ReaderBottomCard 35% scaffold (single page)
345ed1f  R28 S3-P1-03:       ManuscriptWritingText widget (shared writing engine)
35006a3  R28 S3-P1-10:       gate info tab to Explorer mode
f82e811  R28 S3-P1-09:       stationary Reader figure 0.55× + CustomPaint book sprite
7b4c8fd  R28 S3-P1-01:       tear out quadrant card render path from Reader
67168f7  R28 S2 MEDIUM:      handoff doc
```

Phase 1 spec §13: "Push to origin/main when self-verify passes." Self-verify checklist (§9):

- [x] APK size delta vs R28-S2 baseline non-zero — _confirmed below_
- [x] libapp.so arm64 SHA256 moved from R28-S2 baseline — _confirmed below_
- [x] flutter analyze: 0 warnings (1 pre-existing baseline `audio/vo/` warning, unchanged from R28-S2)
- [x] All 11 P1 items + 3 V items implemented
- [x] Quadrant card rendering removed from Reader path
- [x] `_explorerMode` guard wraps every Reader-only render block
- [x] Scroll's existing animation untouched, R28-S2 code paths unmodified
- [x] At least 4 widget tests added (6 shipped)
- [ ] Walked the device-testing checklist §8 at minimum items 1–7 + 11 — **A56-side, owed by Khaled**

Push to origin/main is queued pending the build-hash confirmation below.

---

_Handoff written Apr 25 2026 morning. R28-S3 Phase 1 is the foundation. When A56 verify lands clean — especially the AR letter-joins, gesture separation, and the V-03 Explorer regression sweep — Phase 2 spec gets written covering branching expansion + Reader's Note + reading-room ambient + end-of-event flow integration._
