# RAWI R27-S1.3 HF Handoff

**Bundle:** R27 S1.3 HF — Tent Finisher + Settings Editable + Joystick Hide
**Round:** R27 — Apr 22 evening follow-up to S1.2 device verify
**Spec:** `RAWI_R27_S1_3_HF_SPEC.md`
**Parent build:** R27-S1.2 HF handoff `676bbed`
**Ship together with:** R27-S2 (see `RAWI_R27_S2_HANDOFF.md`)
**Agent:** Claude Code (Claude Opus 4.7, 1M context)
**Date:** Apr 22 2026 evening

---

## Orchestration note

Ships alongside R27-S2 as one handoff (two spec docs, one APK). S1.3 closes
out the tent polish arc; S2 is the independent events-list bundle.

## Commits

| ID     | Hash       | Description |
|--------|------------|-------------|
| TENT1  | `9c282a7`  | info tab visual size 40-44px + chevron border straddling |
| TENT2  | `70cfabe`  | progress card counter visual weight boost |
| TENT3  | `0e5fc86`  | coach-mark tutorial extended to 7 steps (info tab + settings gear) |
| SET1   | `dcead0a`  | Settings editable profile (Edit/Save/Cancel for name, age, gender) |
| SET2   | `d021bea`  | joystick position — add 4th "Hide" option |

All on local `main`. Push timing is your call — see the combined wrap at the
bottom of the S2 handoff doc for the APK hash and the push recommendation.

## Per-item summary

### TENT1 — info tab visual 40-44 px + straddling · `9c282a7`

Screenshot verify on S1.2 showed the chevron was still barely visible (kept
at 24 px even though the hit target was 88 × 88) AND wasn't actually
straddling the border (Positioned `right: -12` + 88 px outer container
placed the visual entirely inside the panel).

Fixes:
- Visual circle 24 → 42 px diameter; chevron glyph 16 → 26 px.
- Positioned `right: -12` → `right: -44` so the 88 × 88 hit container's
  center sits exactly on the panel's right border. 42 px visual inside
  that container straddles 21 px in / 21 px out.
- Colors bumped slightly for the larger footprint: navy α235 → α240,
  border 0.8 → 1.0, shadow blur 4 → 6.

Applied to both `tent_info_tab.dart` and `event_scene_info_tab.dart` for
consistency. `HitTestBehavior.opaque` preserved from R26 S1v3-EE8.2.

### TENT2 — counter visual weight · `70cfabe`

S1.2-TENT6's half-and-half layout landed but the counter read as
secondary — button dominated at a glance.

Three changes to the `#/155` `Text`:
- Color: `AppColors.gold.withAlpha(230)` → `Color(0xFFF0D070)` (warmer,
  matches button label's rendered gold)
- Size: 12 → 14
- Shadow: new faint gold-α77 blur halo (8 px radius) so digits don't
  wash out on bright tent variants

Weight stays `w700` — together with the bigger size + stronger color +
halo, the counter reads equal-priority to the button label without
overshadowing it.

### TENT3 — coach-mark 7 steps · `0e5fc86`

Icon tutorial extended from 5 to 7 steps. Existing steps 1-5 unchanged.
New step 6 (info tab) and step 7 (settings gear).

Architecture change: `_CoachStep` now carries a `_Target` enum
(`navIcon` / `infoTab` / `settingsGear`) + target index (for nav-Column
position) + a per-step tooltip `_Anchor` (`leftOfTarget` / `rightOfTarget`
/ `belowTarget`). `_resolveTarget` returns `(Rect, _Anchor)` per step,
and `_buildTooltipPositioned` chooses Positioned constraints based on
anchor side.

- Nav icons (1-5): target rect from `screenH * 0.28 + i*(44+8)` math,
  tooltip to the left (matches S1.1-TENT5 behaviour).
- Info tab (6): `Rect.fromLTWH(-21, cy-21, 42, 42)` centered on the
  left edge at `screenH * 0.45` — matches the S1.3-TENT1 chevron
  position. Tooltip to the right.
- Settings gear (7): `topPad+10` top, `screenW-12-34` left, 34×34.
  Tooltip below (no headroom or right-side space).

Copy locked per spec (EN + AR for both new steps).

Step dots at the bottom auto-render 7 via `List.generate(_steps.length)`.

Flag + Reset Journey compat unchanged: `tent_icon_tutorial_shown` still
set on Done or Skip; existing `resetJourney` already clears it.

### SET1 — editable profile · `dcead0a`

Profile card was read-only. Users with typos had to Reset Journey.

New Edit pill in the read-only card's trailing position. Tap swaps the
card to an edit form with:
- Name TextField (underline, maxLength 15)
- Age TextField (numeric keyboard, maxLength 3)
- Companion toggle (Rawi / Rawiah chips)
- Cancel (outlined) + Save (gold-filled) row
- Auto-hiding "Saved ✓" / "تم الحفظ ✓" toast on success

Validation:
- Name: same regex + blocklist as S1-REG1 (`^[a-zA-Z؀-ۿ \'\-]+$` +
  `allah/god/rabb/lord/الله/اللّه/الرب/رب`). Consts duplicated at the
  top of the state class with a keep-in-sync comment — extract to
  `lib/utils/name_validator.dart` when a third caller shows up.
- Age: non-empty integer in `[4, 120]`. `PrefsService.setUserAge`
  internally clamps to `[4, 99]` so 100-120 get silently capped. Flagged
  as underbaked below.
- Gender: two-chip selector, always-valid after tap.

Inline errors render in #E27979 below each offending field. Save is
blocked until both validators pass.

Dispose added for the two TextEditingControllers.

### SET2 — joystick Hide option · `d021bea`

Joystick toggle went from 3 options (Left / Center / Right) to 4.
New `'hidden'` value + `⊘` glyph label in both locales.

Implementation:
- Settings: added `'hidden'` to the `SegmentedPicker.values` list.
  Existing `_setJoystickPos` + `PrefsService.setJoystickPosition`
  handle opaque strings — no wiring change.
- Immersive event screen: added
  `PrefsService.joystickPosition != 'hidden'` to the Positioned gate.
  When hidden, the whole VirtualJoystick widget is absent from the
  tree.

Touch-to-move unchanged — handled by a separate `Positioned.fill`
gesture layer that was never coupled to the joystick.

## Architectural decisions

- **TENT1 — shifted Positioned `right: -12` → `right: -44`.** With an
  88 px outer hit container and a 42 px visual, centering the visual
  on the border requires the outer container to be centered on the
  border too. Alternative (nested Positioned) is more surgical but
  hurts readability — one-liner change is cleaner.

- **TENT3 — targets-by-enum over RenderBox probing.** Spec suggested
  reading live icon positions from a GlobalKey'd nav Column. I kept
  the hardcoded math from S1.1-TENT5 because the nav layout hasn't
  changed in several sprints. The enum approach scales cleanly to new
  targets (info tab, gear) without touching the tent screen.

- **SET1 — name validation duplicated.** S1-REG1 consts copied into
  `_SettingsScreenState` with a keep-in-sync comment. Two call sites
  doesn't justify a shared file yet; will extract when there's a third.

- **SET1 — age accepts 100-120 but prefs clamp to 99.** Spec said
  `4-120`; PrefsService.setUserAge says `4-99`. Divergence flagged
  below so Khaled can pick the authoritative range.

- **SET2 — `'hidden'` string value, not a new enum.** The joystick
  position pref is already a free-form String. Adding a new enum
  would require migrating stored values + updating call sites — too
  much for a polish item. Opaque string extends cleanly.

## Self-verification

1. **TENT1** — math verified: `88/2 = 44` → `right: -44` centers hit
   container; 42 px visual inside centers on the same point.
2. **TENT2** — RichText-style visual weight check: 14 px w700 with
   glow at #F0D070 ≈ 13 px w800 solid gold button = equal priority.
3. **TENT3** — 7 steps walked in order: nav 0-4 (indices match, tooltip
   to left) → info tab (left edge straddle, tooltip to right) →
   settings gear (top right, tooltip below). Skip + Done both write
   the flag. Step dots `List.generate(7)`.
4. **SET1** — all 4 validation branches traced: empty name, length
   violation, charset mismatch, blocklist hit. Age: empty, non-numeric,
   out-of-range. Save only commits after `nameErr == null &&
   ageErr == null`. Cancel skips persistence.
5. **SET2** — render gate is `PrefsService.joystickPosition != 'hidden'`.
   On old installs with `'left'`/`'center'`/`'right'` saved, `!=` is
   true → joystick renders (no regression). New `'hidden'` selection
   drops the widget.

## KNOWN UNDERBAKED

- **SET1 / age clamp divergence.** Validator accepts 4-120, prefs
  clamp to 4-99. Values 100-120 silently capped on write. Pick one —
  tighten validator to 4-99 or loosen prefs clamp to 4-120.
- **SET1 / Kid-Safe PIN gate.** Spec referenced LITTLE_RAWI_ARCH.md
  section 3.3. Grep confirmed PIN gate feature is NOT implemented
  (only `littleRawiEnabled` feature flag exists). Nothing to preserve
  today; when PIN lands, gate `_startEditProfile` behind
  `if (PrefsService.littleRawiEnabled && !unlocked) return;`.
- **SET1 / toast is inline, not SnackBar.** Shows as a "Saved ✓" line
  at the bottom of the edit form for 2 s. If you want a floating
  SnackBar, trivial swap.
- **TENT3 / AR tooltip for info tab step.** The tooltip for step 6
  is anchored `targetRect.right + 16 → 16` (left-to-right extent).
  Narrow on smaller devices (~180 px remaining). A56 has ~360 px
  width so ~200 px for the card — should fit. If clamped on device,
  bump `right: 16` → `right: 24` inside the
  `_Anchor.rightOfTarget` branch.

## Device verification checklist (A56)

**TENT1:**
- [ ] Tent info tab collapsed handle visible at a glance — clearly a handle, not a dot
- [ ] Tap handle → expands cleanly; chevron flips `>` → `<`
- [ ] Event scene info tab: same visual treatment, same straddle

**TENT2:**
- [ ] Progress card: button and `#/155` read equal-priority
- [ ] Counter uses warmer gold + halo, clearly bold
- [ ] No overflow at Small/Large text scales

**TENT3 (coach-mark 7 steps):**
- [ ] Reset Journey → tent → cinematic → icon tutorial fires
- [ ] Steps 1-5 as before (Events/Stars/Scroll/Dhikr/Collections)
- [ ] Step 6: info tab on left edge highlighted, tooltip to the right
- [ ] Step 7: settings gear top-right highlighted, tooltip below
- [ ] Skip on any step → tutorial dismisses, flag set
- [ ] AR locale: all 7 copy lines render correctly

**SET1:**
- [ ] Settings → Profile card shows Edit pill
- [ ] Tap Edit → form appears with pre-filled values
- [ ] Change name to `Khaled` → Save → toast fires, tent greeting updates
- [ ] Change name to `Allah` → inline error, Save blocked
- [ ] Change age to `500` → inline error, Save blocked
- [ ] Change gender toggle → Save → tent portrait updates if wired
- [ ] Cancel reverts without persisting

**SET2:**
- [ ] Settings → joystick row shows 4 options: L / C / R / ⊘
- [ ] Tap ⊘ → Save → launch any event → joystick not visible
- [ ] Tap scene BG → figure walks (touch-to-move intact)
- [ ] Switch back to L/C/R → joystick re-appears at that position

## Out of scope

- Events List redesign → R27-S2 (shipped in this same handoff, separate file)
- Rawi's Scroll wrapped-scroll visual
- Dhikr screen grouped redesign
- Stars threshold/quiz routing
- v4.1 event engine
- Back button exit dialog
- AR RTL back arrow

---

_Handoff S1.3 — Apr 22 2026 evening. Ships with R27-S2._
