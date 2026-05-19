# RAWI R28-S5-P1 Handoff — Reader-Fix Track (RFT)

**Bundle:** `R28-S5-P1` (= the 9-item Reader-Fix Track, `RAWI_R28_RFT_SPEC-07May2026-2230.md`, folded into R28-S5 as Phase 1)
**Spec:** `RAWI_R28_S5_SPEC-19May2026-1200.md` (wrapper) + `RAWI_R28_RFT_SPEC-07May2026-2230.md` (detailed items)
**Base:** local `b31bcbb` (R28-S4-SPINE-P1 tip — see Base note)
**Agent:** Claude Code (Claude Opus 4.7, 1M context)
**Date:** 19 May 2026

---

## Build verification block

```
BUILD COMPLETE - R28-S5-P1
- flutter clean: confirmed
- APK size: 93.25 MB
- libapp.so SHA256: cb3f283576b7018f98a8e4649a09784fa0d216b3a4a7885d4da791e9ab5e438e
- Changed from previous build: YES
```

`Changed: YES` — all 8 RFT code commits compiled in. `libapp.so`
moved off the SPINE-P1 baseline `2880c9b3d26354011a1e90ee142a2d68cb1c54177f5e425320bf6de030ab8681`
→ `cb3f283576b7018f98a8e4649a09784fa0d216b3a4a7885d4da791e9ab5e438e`.
APK 93.25 MB vs SPINE-P1's 93.16 MB (+0.09 MB — substantial new Dart,
zero new assets; within tolerance). Fresh `flutter clean` →
`assembleRelease` (5m 6s) → `verify_build.py`.

- **flutter analyze:** 0 errors, 0 warnings from RFT (clean after
  every commit). The single project-wide warning (`assets/audio/vo/`
  missing, pubspec.yaml) is **pre-existing** — present on the HF6
  baseline; pubspec.yaml untouched this bundle.
- **Tests:** 29/29 passing (`flutter test`), green at each
  architectural step (RFT-02/06/07/08).
- **verify_build.py:** ✅

---

## Base note (flagged, carried from the S5 pre-flight)

R28-S4-SPINE-P1 was **A56-verified clean** by Khaled but the **push to
`origin/main` did not land** — `origin/main` is still `3517fb5` (HF6);
local was `b31bcbb`, 8 ahead / 0 behind. Per Khaled's S5 pre-flight
decision, R28-S5-P1 proceeds on the verified local `b31bcbb` (content-
identical to the intended pushed base; `origin/main` fast-forwards
cleanly once the push lands — strictly ahead, 0 behind, no rebase
risk). **Khaled still owes `git push origin main`** for SPINE-P1 + this
bundle. Baseline pre-flight (`R28-S5-P1-baseline-check`) confirmed
`b31bcbb` reproduces the verified SPINE-P1 libapp byte-for-byte
(`2880c9b3…`, `Changed: NO` — correct for a zero-change baseline).

---

## Commits (one per item; RFT-05 = verified no-op, no commit)

| Item | Hash | Title |
|---|---|---|
| RFT-03 | `0b1d46e` | remove duplicate stacked page-dot indicator |
| RFT-02 | `7b286cc` | typing animation scroll-follows the write cursor |
| RFT-01 | `74c07c0` | gate Reader card behind Event1TutorialOverlay |
| RFT-09 | `e3ed20d` | drop registration mode question + Event-1 Reader invitation |
| RFT-04 | `09cee8e` | Reader last-page CTA "Continue to the question" |
| RFT-06 | `7125603` | state-based verdict entry (fixes back-from-HS4 dead-end) |
| RFT-07 | `cd50d6b` | OBS3 observation-note beat (user-gated, pre-cinematic) |
| RFT-08 | `520eed9` | end-of-event 2-screen split (Reflection / Completion) |

Implemented in the spec's risk order (03→05→02→01→09→04→06→07→08).
`flutter analyze` clean after every commit; `flutter test` 29/29
green at each architectural step (RFT-02/06/07/08).

**Commit-prefix / sprint-name reconciliation (flagged):** commits use
the RFT spec's `R28-RFT-NN:` prefix (item-ID traceability); the build
verify uses the S5 wrapper's `--sprint "R28-S5-P1"` (governing). Build
cadence followed the RFT spec's explicit relaxation (one final build,
not per-item) — but `flutter analyze` ran after **every** commit.

---

## Diagnostic-first findings (evidenced cause vs. spec hypothesis)

- **RFT-03** — spec hypothesis "duplicate scaffold/old-widget cruft."
  **Actual:** the duplicate is the Explorer `HotspotProgress` block;
  its sibling `EventSceneInfoTab` got the `&& _explorerMode` Reader-
  gate in R28-S3-P1-10 but this block was missed in that same pass.
  Fix = apply the identical sibling gate.
- **RFT-02** — spec asked "if a ScrollController already exists,
  integrate." **Confirmed:** `_PageContent` already owns
  `_scrollCtrl` + `SingleChildScrollView`; integrated, no 2nd
  controller. No auto-follow existed (real work).
- **RFT-05** — **already satisfied; no code change.** The spec's
  literal fix (`PageView reverse when AR`) shipped in R28-S3-P1
  (`reverse: widget.isAr`, reader_bottom_card.dart). Acceptance #5
  (dots progress R→L in AR) is handled by the app-wide
  `Directionality(rtl)` in main.dart. The 7-May premise predates
  R28-S3-P1's Path-B landing. **Needs A56 confirmation** — if AR
  swipe still felt wrong on device there's a subtler issue to
  instrument.
- **RFT-06** — confirmed transition-based trigger in `_dismissPanel`;
  storage `PrefsService.*HotspotProgress(event.id)`. **Spec internal
  inconsistency found:** the proposed persisted `verdictShown` flag
  would BREAK the spec's own verify check 4 (complete all 4 → back
  *before the verdict appears* → re-enter → verdict must fire) since
  it'd already be true. Answering the verdict is atomic with event
  completion (`_selectChoice`→`completeEvent`), so
  `isEventCompleted`/`_alreadyCompleted` is already the exact
  re-trigger guard. Implemented with `!_alreadyCompleted` + a state-
  based entry safety net, **no redundant `verdictShown` pref**. All 5
  RFT-06 verify checks satisfied. Reasoned deviation, flagged.

---

## Reinterpretations / spec deviations (all flagged, none silent)

1. **RFT-01** — no dedicated Reader tutorial exists; the only event
   tutorial is the Explorer-flavored `Event1TutorialOverlay` (event-1
   only). Khaled-chosen scope (S5-P1 question): gate `ReaderBottomCard`
   under that overlay (not-mounted while up → strictly stronger than
   the spec's opacity-0 + IgnorePointer; 250ms fade-in on dismiss).
2. **RFT-09** — registration mode question was a *section* on the age
   page, not its own step → no step indicator to renumber. Invitation
   delivered as a self-contained widget + `readerInvitationShown` pref;
   wired into the (pre-RFT-08) completion screen for testability, then
   **relocated into Screen B by RFT-08** (the spec's stated
   dependency).
3. **RFT-04** — branching-event Reader flow uses the same
   last-page→verdict entry as linear (the Explorer-only in-scene
   convergence branch is not on the Reader path).
4. **RFT-06** — no `verdictShown` pref (see Diagnostic findings).
5. **RFT-07** — observation copy is Khaled's content pass. Ships
   clearly-tagged PLACEHOLDER per (eventId, answerIndex); real copy
   drops into `observationNotes` with **no code change**. Beat runs on
   the first-completion path only (replays keep immediate Continue —
   they have no cinematic reveal).
6. **RFT-08** — A→B affordance is a CTA button (spec allowed "CTA or
   swipe-up"). Two nav buttons both contract-safe per the LOCKED
   Navigation Contract (Khaled-chosen S5-P1 nav-button question):
   "Continue Journey" = `_continueJourney` (tent, via Passage if
   pending); "Return to Tent" = `_returnToTent` (straight to tent, no
   Passage; Passage-seen untouched). Shared `_exitPrelude()` keeps the
   LOCKED -25% Light penalty + audio fades identical. The 4 s
   auto-exit was removed (spec: user-gated). **Cosmetic only:** the
   edit tooling auto-escaped a few comment glyphs in
   unified_completion_screen.dart to literal `\uXXXX` text (comments
   only — no functional/analyzer impact) and one stale "Section 6"
   comment remains.

---

## AR strings — flagged for Khaled sign-off

First-pass AR copy added this bundle: RFT-04 `تابع إلى السؤال`,
RFT-08 `تابع` / `رأى الراوي:` / `العودة إلى الخيمة`, RFT-09 invitation
prompt + `نعم، جرّب القارئ` / `ابقَ مع المستكشف`. RFT-07 observation
notes are placeholder (EN+AR slots) pending the content pass.

---

## Frozen systems — untouched (verified)

BG art, figure movement, scroll content, dhikr widget logic, XP calc,
badge logic, hotspot interaction, verdict answer logic, cinematic
reveal animation/timing, Settings mode toggle, Navigation Contract
(both RFT-08 nav buttons end at the tent), Passage logic, mode-pref
storage. Glowing Moments code left intact (RFT spec out-of-scope).

---

## Regression watch (per R28-S5 spec)

- **HF6-02 SafeArea** — N/A this bundle (no Stars/timeline edits).
- **R28-S4-SPINE-P1 (S4S-01..06)** — N/A (no Stars edits); base
  reproduced byte-for-byte at pre-flight.
- **Tent ambient continuity / Navigation Contract** — preserved;
  RFT-08 routes both nav buttons to the tent via the shared exit
  prelude (penalty + audio fades unchanged).

---

## Khaled-side A56 verify — owed (highlights)

Per-item checklists are in the RFT spec. Highest-attention items
(visual/animation, no A56 in the agent's hands):

- **RFT-08** — the 2-screen split: A (scroll/dhikr/25%-warning →
  Continue) → B (XP/badge/chapter/caption/invitation/2 nav). Verify no
  auto-exit, dhikr penalty still applies on skip via *both* nav
  buttons, Passage still fires via "Continue Journey", "Return to Tent"
  skips Passage but still lands at tent, AR layout.
- **RFT-07** — observation note appears after answering, user-gated
  Continue, then the existing cinematic reveal; placeholder text shows
  in the correct per-answer slot.
- **RFT-06** — back-from-HS4 (complete all 4, back before/after the
  verdict, re-enter → verdict fires; answered → no re-trigger;
  first-completion still works).
- **RFT-05** — confirm AR Reader swipe direction is correct (verified
  in code as already-satisfied; on-device confirmation requested).
- **RFT-01 / RFT-02 / RFT-03 / RFT-04 / RFT-09** per their spec
  checklists.

---

## Branch state

After this handoff commit: local is **`origin/main` + (8 SPINE-P1) +
(1 gitignore chore) + (8 RFT) + handoff**, all unpushed. **Push gate:
Khaled.** No agent push. SPINE-P1 push is still owed and folds in with
this. After A56 verify clean, Khaled pushes; the P1 push triggers the
self-contained **R28-S5-P2** spec (Stars cleanup: BL-03/BL-04 marker
suppression, S4S-07 AR parity, S4S-08 tutorial overlay) — which I do
NOT start until P1 is A56-verified + pushed.

---

_Handoff written 19 May 2026. 9/9 RFT items addressed (8 commits + 1
verified no-op). Diagnostic-first throughout; every deviation flagged,
none silent. RFT-08 (2-screen split) + RFT-07 (observation beat) are
the items most needing on-device animation/timing verification._
