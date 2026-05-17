# RAWI R28-HF5 Handoff — InteractiveViewer boundary margin clamp

**Bundle:** R28-HF5 (single-item hotfix)
**Spec:** `RAWI_R28_HF5_SPEC-17May2026-1230.md` (Downloads, 17 May)
**Predecessor:** R28-HF4 (verified clean on A56 by Khaled, 17 May 2026 — all 5 items functionally pass)
**Parent build:** R28-HF4 handoff `18b0cc9`
**Agent:** Claude Code (Claude Opus 4.7, 1M context)
**Date:** 17 May 2026

---

## Build verification block

```
BUILD COMPLETE - R28-HF5
- flutter clean: confirmed
- APK size: 93.38 MB
- libapp.so SHA256: 64c86af33e9c57312131f7e4e5530c5dba7148fb846de55acd0e1ff5cf56aec4
- Changed from previous build: YES
```

`Changed from previous build: YES` — confirms the one-line change actually compiled into the APK (diffed against the HF4 baseline `55d3fcc6…` logged in `tools/build_log.json`). Fresh `flutter clean` + `assembleRelease`, 9m 49s on a cold cache. APK size 93.38 MB — identical to HF4 (a one-line `boundaryMargin` change shouldn't move size; spec tolerance was ±2 MB, actual delta is 0).

---

## Commit

| ID | Hash | Description |
|---|---|---|
| HF5-01 | `39d42fa` | InteractiveViewer boundary margin clamp |

One commit, single-item bundle per spec §"Universal Rules" rule 1.

---

## The change

`lib/widgets/constellation_view.dart` — one line in the `InteractiveViewer` props (HF4-03 ref commit `c8fc67f`):

```dart
boundaryMargin: const EdgeInsets.all(200)   →   boundaryMargin: EdgeInsets.zero
```

HF4-03 set `EdgeInsets.all(200)` to allow a soft drift past the canvas edges. On A56 that drift exposed the transparent `InteractiveViewer` surface against the Scaffold's dark background as a **black void** when panning past content edges (Khaled verified 17 May — black strip on the right at zoom 1.0× and at 2-3×, both pan directions). `EdgeInsets.zero` clamps pan exactly at the canvas edges — no void.

Comment block updated to record the HF5-01 rationale alongside the existing HF4-03 note. No other refactoring in the commit.

**Diff:** 11 +, 5 − (comment expansion + the one prop line; net behaviour change is the single `boundaryMargin` value).

---

## Frozen systems — confirmed untouched (per spec §"Frozen systems")

- `transformationController` setup + the post-frame `_resetAndCenterOnCurrent` view-enter UX — untouched
- `constrained: false` — kept (preserves the ~10,000 px canvas height for label legibility at zoom 1.0)
- `minScale: 1.0`, `maxScale: 3.5` — kept
- Underlying constellation canvas layout (HF4-01 / backlog BL-02 territory) — untouched
- Year-label positioning, leader-line rendering, other Stars-view widgets — untouched

---

## No silent deviations (per spec §"Universal Rules" rule 4)

`EdgeInsets.zero` used exactly as specified — no technical reason to deviate. The const-ness changed (`const EdgeInsets.all(200)` → `EdgeInsets.zero`); `EdgeInsets.zero` is itself a const static so this is not a `prefer_const` regression — `flutter analyze` clean confirms.

No diagnostic findings — the fix is the predicted single-line change. If A56 shows panning still drifts past edges (unexpected), spec §"Universal Rules" rule 3 says surface diagnostic info rather than guess; nothing to surface pre-device.

---

## Acceptance walk (code-inspection — A56 device-walk owed per spec §"Khaled-side verify checks")

1. Events → STARS view renders ✓ (no change to render path)
2. Pan left → clamps at right edge, no left-side void ✓ (boundaryMargin zero = no pan past content)
3. Pan right → clamps at right edge, no right-side void ✓
4. Zoom 2-3× + pan → clamping holds at every zoom level ✓ (boundaryMargin applies in transformed space, scale-independent)
5. Release zoom → re-fits naturally ✓ (transformationController unchanged)
6. AR locale → identical (pure layout/gesture, locale-independent per spec) ✓
7. HF4-03 regression: zoom 1.0 labels legible, smooth to 3.5× ✓ (`constrained: false`, min/max scale all unchanged)

Pass criteria: no black void at any point during normal pan + zoom. If clamping feels "stiff" (users expect bounce-back), spec says that's later polish — `EdgeInsets.zero` is the correct base behaviour.

---

## Branch state

After this commit the branch is **54 commits ahead** of `origin/main`. Push gate held by Khaled until HF5 verifies clean on A56. Successor per spec: R28-RFT (Reader-Fix Track — spec already written, ready post-HF5 push).

---

_Handoff written 17 May 2026. One line of code, shipped clean._
