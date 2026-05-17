# RAWI R28-HF6 Handoff — Stars view pan/zoom restoration + polish

**Bundle:** R28-HF6 (3 items — HF6-01 diagnostic-first, HF6-02 + HF6-03 straightforward)
**Spec:** `RAWI_R28_HF6_SPEC-17May2026-1400.md` (Downloads, 17 May)
**Predecessor:** R28-HF5 (boundary-margin change landed but introduced 3 regressions — see Diagnostic)
**Parent build:** R28-HF5 handoff `13c92eb`
**Agent:** Claude Code (Claude Opus 4.7, 1M context)
**Date:** 17 May 2026

---

## Build verification block

```
BUILD COMPLETE - R28-HF6
- flutter clean: confirmed
- APK size: 93.38 MB
- libapp.so SHA256: aaf2327df1e81d59dbe386317a1fa7fd2c75b887b746369bc18b981906a1b5ee
- Changed from previous build: YES
```

`Changed: YES` — confirms all 3 HF6 changes compiled into the APK. `libapp.so` moved from HF5's `64c86af33e9c57312131f7e4e5530c5dba7148fb846de55acd0e1ff5cf56aec4` → `aaf2327df1e81d59dbe386317a1fa7fd2c75b887b746369bc18b981906a1b5ee`. APK size 93.38 MB — identical to HF5 (all three items are UI/layout-only; no asset changes; size shift well within the spec's ±1 MB tolerance). Fresh `flutter clean` + `assembleRelease`, 6m 21s.

---

## Commits

| ID | Hash | Description |
|---|---|---|
| HF6-01 | `c94c1fd` | Stars view pan + zoom restoration (diagnostic-first) |
| HF6-02 | `9491f95` | Stars view SafeArea bottom inset |
| HF6-03 | `d7fe566` | Living Map compass dark backdrop matches sibling icons |

3 commits, one per item per spec §"Universal Rules" rule 2. `flutter analyze` clean between every commit. `flutter test` 29/29 pass.

---

## DIAGNOSTIC FINDINGS (HF6-01) — diagnostic-first per spec + RULES_AND_LEARNINGS

Investigation was by **code-trace** (no A56 available to the agent — same constraint as prior HFs; the rules-doc diagnostic-first protocol is satisfied by evidence-based analysis, not guessing).

### What was investigated (spec §"Diagnostic phase" questions, answered)

**1. Canvas natural width.** The canvas was `SizedBox(width: screenW, height: _totalHeight)` — exactly the viewport width (`screenW = MediaQuery.of(context).size.width`, ~384 logical px on A56).

**2. Why pan died.** With `constrained: false`, InteractiveViewer sizes the child to its natural size (screenW wide). `boundaryMargin: EdgeInsets.zero` (from HF5) + child width == viewport width ⇒ **zero horizontal pan range**. Vertical pan survived only because `_totalHeight` (~10,000 px) >> viewport height.

**3. Why zoom died.** At scale 1.0 the child exactly fills the viewport horizontally with zero boundary slack. InteractiveViewer's combined scale+translate clamp (`_clampMatrix` against `_boundaryRect`, which with zero margin == the child rect) snaps every pinch gesture's delta back toward identity — the pinch reads as a no-op because there is no valid transform that changes scale while keeping the zero-margin boundary satisfied at the gesture focal point.

**4. Right-side label position.** The painter draws cluster labels at `anchor.dx + _clusterLabelOffsetX(90) + up to 130 px of title text` (TextPainter maxWidth 130). Singleton stars oscillate to `centerX ± 0.28·screenW`. On A56 the rightmost content reaches **~520 px — overflowing the screenW (~384 px) canvas by ~136 px**. Those labels render in the painter's coordinate space but outside the canvas SizedBox bounds; with zero pan range they're permanently unreachable.

### Root cause

**The canvas SizedBox was too narrow to contain its own content.** HF4-03's `boundaryMargin: EdgeInsets.all(200)` was silently compensating — the 200 px "drift" was effectively extra pan room to reach the overflow content, but it *also* let the user pan past the genuine canvas edge into the transparent InteractiveViewer surface (= the HF5 black-void bug). HF5's `EdgeInsets.zero` removed the compensation **without fixing the undersized canvas**, producing all three regressions at once (pan dead, zoom dead, right labels stuck).

### Fix chosen (and why — spec §"No silent deviations")

Config + layout fix, **not** a boundaryMargin guess:

- New const `_canvasPadX = 170.0` (covers the worst-case ~136 px overflow — LTR cluster labels right / AR cluster labels left — with margin).
- Canvas width = `screenW + 2·_canvasPadX`.
- Content recentres via `centerX = canvasW / 2`. The wave `amplitude` stays `screenW·0.28` (a fraction of the **viewport** width) so the singleton spread is unchanged — only the centerline shifts so all content sits inside the padded canvas.
- **`boundaryMargin: EdgeInsets.zero` is KEPT** (HF5's decision preserved per spec — it was correct, the canvas was wrong). With the correctly-sized canvas it now clamps at the *true* content edges: horizontal pan range = `canvasW − viewportW` (~340 px on A56, all labels reachable), zoom works (child genuinely larger than viewport on both axes), and there is **no void** because the canvas's own deep-sky gradient fills the full `canvasW` — the padded region is backdrop, never the transparent surface.
- Threaded: `_generatePositions(canvasW, screenW, bottomPad)`; SizedBox width / CustomPaint size / background-dust X spread → `canvasW`; `_SkyPainter._paintSingleStar` now receives the canvas centerline (`size.width/2`) so the label left/right heuristic tracks the wider canvas instead of the hardcoded `pos.dx > 180` (~half of an old ~360 px screen); `_resetAndCenterOnCurrent` translates X by `−(canvasW − viewportW)/2` so view-enter starts centred on the content band, not pinned to the left padding.

**Not an architectural escape-hatch case.** The spec offered a Path-B escape if the diagnostic revealed an architectural issue. It didn't — this is a config/canvas-sizing bug, fully fixable at the widget level. HF6-01 ships.

---

## Per-item summary

### HF6-01 · pan + zoom restoration · `c94c1fd`

See diagnostic above. `lib/widgets/constellation_view.dart`, +76 / −14. Frozen systems (transformationController + view-enter UX, minScale 1.0 / maxScale 3.5, `constrained: false`, HF4-01 cluster layout, HF4-04 badge) untouched.

### HF6-02 · SafeArea bottom inset · `9491f95`

The InteractiveViewer viewport extended behind the Android system nav bar; the oldest events (570 CE, timeline bottom) rendered under the back/home/recent buttons. Pre-existing (not HF5 fallout) — surfaced during the 17 May deep verify.

Fix: wrapped the InteractiveViewer in `SafeArea(top: false)`. `top: false` because the Stars header + LIST/STARS toggle are already correctly below the status bar (wrapping top would double-inset them). `bottom` defaults true → viewport stops above the nav region. The `_LockedInfoCard` modal stays **outside** the SafeArea (separate `Positioned.fill` sibling — its scrim should still cover the full screen including the nav strip).

**Implementation note (no silent deviation):** the InteractiveViewer child block is NOT re-indented under the new wrapper — re-indenting ~110 lines would bloat the diff for zero functional gain (Dart + `flutter analyze` don't enforce dart-format). The change is SafeArea-open + one labeled close paren. `lib/widgets/constellation_view.dart`, +15 / −1.

### HF6-03 · compass dark backdrop · `d7fe566`

The Living Map compass placeholder used HF3-LMAP1's "outlined ghost" treatment (gold alpha 10 wash + gold alpha 70 / 1.2 px border). Against morning/light tent BG variants it had almost no contrast — the "soon" pill read louder than the icon.

Fix: matched the sibling nav-icon backdrop **exactly** (`_navIcon` / `_navIconMaterial`): `Colors.black.withAlpha(180)` fill, `AppColors.gold.withAlpha(40)` border, radius 12, size 44×44. Now the compass sits on the same solid dark rounded square every other right-side icon has — readable on any BG.

Kept (not in scope): icon at `AppColors.gold.withAlpha(150)` — subordinate to the active icons' full gold so it still reads as a placeholder. The "soon" badge + dimmed glyph signal "exists, not yet active"; only the missing dark backdrop was the bug, and the dark square alone restores visibility. Frozen: badge (HF4-04), compass glyph, tap behaviour, the 4 active icons, tent BG. `lib/screens/rawi_tent_screen.dart`, +15 / −5.

---

## Spec-deviation flags (per spec §"No silent deviations")

1. **HF6-01 kept `boundaryMargin: EdgeInsets.zero`** rather than tuning it. The spec's fix-shape menu listed `EdgeInsets.symmetric(horizontal: N)` as one option, but the diagnostic showed the margin was never the real problem — the undersized canvas was. Fixing the canvas + keeping zero margin is the root-cause fix; a non-zero margin would reintroduce a (smaller) void. Surfaced here per the rule.
2. **HF6-02 did not re-indent the wrapped block** — diff-size pragmatism, documented in the commit + above.
3. **HF6-03 left the icon alpha at 150** (not bumped to full gold to perfectly match siblings) — the spec scoped the fix to the *backdrop*; the placeholder-subordination intent from HF3-LMAP1 is deliberately preserved. The dark backdrop alone resolves the visibility complaint. If A56 verify wants the icon at full gold too, that's a one-token follow-up.

---

## Khaled-side verify (A56) — owed

Per spec, the 7-check HF6-01 walk + HF6-02 (5 checks) + HF6-03 (5 checks). Key ones:
- HF6-01: horizontal pan reaches all labels (incl. previously-stuck right side); pan past edge clamps with no/minimal void; pinch-zoom 1.0×→3.5× works; pan-while-zoomed clamps at edges; AR identical; HF4-03 core not regressed (labels legible at 1.0×).
- HF6-02: scroll to timeline bottom → 570 CE events sit *above* the system nav, not behind; bottom event-card slider still works; gesture-nav + 3-button nav both clear.
- HF6-03: compass has the same dark rounded square as siblings; visible on light/morning BG; "soon" badge unchanged; tap still no-ops with coming-soon tooltip.

---

## Branch state

After this handoff commit the branch is **~58 commits ahead** of `origin/main`. Push gate held by Khaled until HF6 verifies clean on A56. Successor per spec: R28-RFT (Reader-Fix Track — spec already written, ready post-HF6 push).

---

_Handoff written 17 May 2026. Diagnostic first, fix second — no guessing. HF6-01's root cause (undersized canvas masked by boundaryMargin) traced before any code changed._
