# RAWI R27-S2 Handoff — Events List Redesign

**Bundle:** R27 S2 (2 items, events list + tent counter clarity)
**Round:** R27 — Apr 22 evening, shipped alongside S1.3 HF
**Spec:** `RAWI_R27_S2_SPEC.md`
**Parent build:** R27-S1.2 HF `676bbed` + R27-S1.3 HF (same handoff bundle)
**Ship together with:** R27-S1.3 HF (see `RAWI_R27_S1_3_HF_HANDOFF.md`)
**Agent:** Claude Code (Claude Opus 4.7, 1M context)
**Date:** Apr 22 2026 evening

---

## Orchestration note

S2 ships AFTER S1.3 in the commit chain and in the same APK build / push.
S2's code paths (events list card + tent counter label) are independent of
S1.3's paths — bisectable if anything regresses.

## Commits

| ID    | Hash       | Description |
|-------|------------|-------------|
| EL1   | `2cbcdaf`  | events list — event number restore + drop duplicate tick |
| EL2   | `bc5cac4`  | tent counter label clarity — resolves BUG-D |

Both on local `main`.

## Per-item summary

### EL1 — event number restore + drop duplicate tick · `2cbcdaf`

Per doc/BUG_INVESTIGATION_APR21.md BUG-D, events list cards previously
replaced the number badge with a tick on completed events (so users
couldn't scan by number for a specific event), AND also showed a separate
tick on the right side — two ticks, zero numbers, per completed event.

Fix:
- The `if (completed) … check-icon … else … number-circle` branch is
  gone. Single badge Container with per-state styling now renders the
  event's `globalOrder` on every card.
- Colors per state:
  - completed: gold α200 on gold α20 bg, gold α64 border
  - next: gold on navy bg, gold α100 border
  - locked: muted #5A7A7A on navy bg, dark border
- Number weight w600 → w700 so it reads as a primary ID.
- Added `textDirection: isAr ? RTL : LTR` on the inner Row so AR mirrors
  correctly — number on trailing side, status on leading side, in both
  locales.

Right side of card unchanged: tick for completed, Start/Continue pill
for next, lock icon for locked. Completed events now read as
`[ 14 ]  Title  [ ✓ ]` instead of `[ ✓ ]  Title  [ ✓ ]`.

Latin digits retained in AR. Arabic-Indic digits are reserved for
scripture and dhikr text elsewhere in the app — matching that
convention for consistency.

### EL2 — tent counter label clarity · `bc5cac4`

BUG-D's other leg: tent shows `26 / 155` which users read as "this is
event 26" (when it's actually "I've completed 26 events, on my way to
event 27"). The number is correct but unlabeled, so it collided
semantically with the events list's `27` badge.

Fix: `RichText` with two `TextSpan`s:
- Prefix: `Completed ` / `مكتمل ` — 11 px w600 gold α180 (smaller,
  dimmer)
- Number: `26 / 155` — 14 px w700 #F0D070 with the faint gold halo
  from S1.3-TENT2

Prefix is secondary but unambiguous; number still anchors the glance.
`TextDirection.rtl` on the RichText puts prefix before number in AR too.

Events list badges stay unlabeled — their meaning is clear from card
context ("this is event #N in the sequence").

## Architectural decisions

- **EL1 — single badge, per-state styling.** The branching
  number-vs-check pattern conflated two different concerns (ID vs
  status). Separating them into a consistent number badge + a
  status-only trailing slot is simpler and respects the "what is this"
  / "where am I in the journey" mental model.

- **EL1 — RTL handled on the Row, not per-child.** One-line addition
  (`textDirection: …`) on the `Row`'s own constructor. Cleaner than
  swapping children order via `isAr ?` ternaries.

- **EL2 — RichText over two separate Text widgets.** Keeps the prefix
  and the number on the same baseline, single line. A Column approach
  would add vertical height and force a card-layout re-check.

## Self-verification

1. **EL1** — traced all three state branches through the new single
   Container: completed / next / locked all now render the number
   with distinct but consistent visual treatment. The right-side
   status widget (check / Start pill / lock) unchanged.
2. **EL2** — RichText renders correctly in both `TextDirection.rtl`
   and `.ltr` via the `textDirection` on the outer RichText. Number
   styling (gold halo) carries from the parent TextSpan to the child
   via `style` inheritance (default).

## KNOWN UNDERBAKED

- **EL1 / AR screenshot** — paper-traced (`textDirection: rtl` flips
  child order, status moves to the leading side, number to the
  trailing side). Not device-screenshotted.
- **EL2 / "Completed" copy length in AR** — `مكتمل` is short; fits in
  the right half of the half-and-half progress card. If Khaled wants
  a longer translation (e.g. `تم إكماله` / `أنجزت`) it may overflow.
  Current choice picked for brevity.

## Device verification checklist (A56)

**EL1:**
- [ ] Scroll through events list in EN — every card has a visible
      number badge on the left
- [ ] Completed events show `[ 14 ]  Title  [ ✓ ]` — no duplicate tick,
      no missing number
- [ ] Next event shows `[ 15 ]  Title  [ Start ]` (or Continue)
- [ ] Locked events show `[ 16 ]  Title  [ 🔒 ]`
- [ ] Scroll in AR — every card mirrors: number on right, status on left
- [ ] Tap any event (including completed) → enters normally

**EL2:**
- [ ] Tent counter reads `Completed 26 / 155` (or current state)
- [ ] Label `Completed` visibly smaller + dimmer than the number
- [ ] AR locale: `مكتمل 26 / 155` in correct RTL reading order
- [ ] Opens events list → `27` badge on the "next" card —
      no semantic collision with tent `26 / 155` anymore

## Combined build artifacts (S1.3 HF + S2)

**Both bundles ship in a single APK build.**

- Path: `build/app/outputs/flutter-apk/app-release.apk`
- Size: 97,274,653 bytes (92.77 MB / 97.27 MB)
- **APK SHA256:** `5a6908c8a338a2905b81cdfc09220641221746a85f546ea64a63a8c99eb4034b`
- **libapp.so arm64 (stripped) SHA256:** `3310c9cf9b9f58441866eae8bd10ec4f779ceb924f3f765d36395a7fecb293da`
- **flutter analyze:** 0 new warnings. 1 pre-existing (`pubspec.yaml:37 assets/audio/vo/`).

Build: `flutter clean` → `flutter pub get` → `gradlew.bat assembleRelease`.
`BUILD SUCCESSFUL in 7m 16s`.

## Full commit chain in this ship

(S1.3 HF + S2, in chain order)

| # | Hash | Bundle | Item |
|---|------|--------|------|
| 1 | `9c282a7` | S1.3 | TENT1 — info tab visual + straddle |
| 2 | `70cfabe` | S1.3 | TENT2 — counter weight |
| 3 | `0e5fc86` | S1.3 | TENT3 — coach-mark 7 steps |
| 4 | `dcead0a` | S1.3 | SET1 — editable profile |
| 5 | `d021bea` | S1.3 | SET2 — joystick Hide |
| 6 | `2cbcdaf` | S2  | EL1 — event number restore |
| 7 | `bc5cac4` | S2  | EL2 — tent counter label |

Plus the two handoff doc commits when those land.

## Push recommendation

One push for both bundles per your call ("Two pushes or one per your call").
Recommend ONE push — the branches are independent in code but shipped as
a single APK, so bisecting from `origin/main` can use the per-commit hashes
above without needing separate branches. If something regresses and you
want to roll back only S2, `git revert 2cbcdaf bc5cac4` cleanly reverses
the events-list pair without touching S1.3.

## Out of scope

- Rawi's Scroll wrapped-scroll visual
- Dhikr screen grouped redesign
- Stars threshold/quiz routing
- Collections structural decision
- Back button exit dialog (R25-S7-1)
- AR RTL back arrow (R25-S7-2)
- v4.1 event engine

---

_Handoff S2 — Apr 22 2026 evening. Ships with R27-S1.3 HF._
