# RAWI Rules and Learnings

Living document of permanent project rules and cross-sprint learnings.
Rules listed here are **inherited automatically by every future spec** —
no need to restate them. If a rule needs updating, replace it in place
with an explicit changelog entry; don't branch parallel versions.

Organised newest-first by the sprint that established the rule.

---

## Navigation Contract (R28-S1, permanent)

> **Event exit always returns to tent, regardless of the caller screen.**

Applies to **every current and future entry point into an event**:

- Tent progress card (Start / Continue)
- Events List (LIST view) tap
- Events List CONSTELLATION view tap (completed, current)
- Settings → Continue-last-event path (if added)
- Chapter Review deep-link (planned)
- Rawi's Scroll event reference (planned)
- Living Map placeholder event pins (planned)
- Any other "jump into event X" surface added later

**Implementation contract:**

- Every push of `RawiTentScreen` MUST carry
  `settings: RouteSettings(name: RawiTentScreen.routeName)`. The
  constant is `'/tent'`.
- Event exit paths (back button gated through the confirm dialog, or
  settings "Save and exit") MUST use
  `Navigator.of(context).popUntil(ModalRoute.withName(RawiTentScreen.routeName))`
  — NOT a single `Navigator.pop()` and NOT
  `pushAndRemoveUntil(...)` for mid-session exits. The `popUntil`
  preserves the existing save-on-back guards (verdict gate,
  completing gate, hotspot save, in-progress stamp, audio fade-out)
  which run BEFORE the navigation call.
- End-of-event flows (`UnifiedCompletionScreen → pushAndRemoveUntil`
  to tent) are the exception — they intentionally rebuild the stack
  with a fresh tent. Must still tag the new tent push with the named
  route so subsequent event exits find it.
- New entry points added in future sprints inherit this rule without
  restating it in the spec.

Established in: **R28-S1-BUG1** (fix for Events List → event → back →
landing on Events List instead of tent).

---

## Locked rules (carried from prior sprints)

These are the Frozen Systems list + the cross-sprint learnings that
every HUGE/MINOR spec re-asserts. They live here so specs can
reference instead of restating.

### Frozen systems — DO NOT TOUCH

- **Background art structure** — any BG asset, atmosphere layer, fog
  of war system, halo radius formula. No edits to
  `atmosphere_widget.dart`, `fog_of_war.dart`, `halo.dart`.
- **Figure movement code** — joystick, finger-drag, proximity
  auto-snap, hotspot tap-in-band logic. No edits to movement physics.
- **R26-S1v3-EE8.2 info tab pan swallow** — pan-over-figure-while-
  expanded must NOT move the figure. Preserved across every info
  tab refactor (R27-S1.5-INFO1, R27-S3-INFO1).
- **Audio never hard-cuts** — ambient, voiceover, SFX transitions
  all fade (R24-AUDIO1). `AudioService.fadeOut` / `fadeOutVoiceover`
  enforced. Emergency `stopAmbient` / `stopVoiceover` reserved for
  lifecycle-dispose only.
- **Dhikr icon + screen** stay on the tent nav until the Collections
  3-tab redesign absorbs them. Locked through R28.

### Cross-sprint learnings

- **Idempotent `playAmbient` on same path** — the core primitive that
  made the R27-S3-AUDIO1 "tent cluster ambient" change a non-edit
  for every sibling screen. See `audio_service.dart:44-66`.
- **In-app debug overlay (B27)** — `DebugLogService.log(category,
  msg)` → 200-entry ring buffer visible via the always-on overlay.
  Preferred over logcat for device-verify flows since the user can
  copy + paste without ADB. Used in R28-S1-BUG2 for lifecycle
  diagnostic.
- **RouteAware + `appRouteObserver`** — per-screen lifecycle hook
  (`didPopNext` / `didPushNext`) for ambient re-ensuring and
  progress refresh. Tent uses it; Events List adopted it in
  R27-S3-AUDIO1 for the return-from-event case.
- **Material `*_ios*` arrow glyphs auto-mirror in `Directionality.rtl`**
  (`matchTextDirection: true` in the IconData table). To manually
  flip without double-mirror, force `textDirection: TextDirection.ltr`
  on the Icon and wrap in `Transform.scale(scaleX: -1)`. R27-S3-
  EVENTS-LIST1 established the idiom.
- **Named route tagging for `popUntil`** — R28-S1-BUG1. See
  Navigation Contract above.

---

## Build verification protocol *(added 7 May 2026)*

**Why this exists.** Stale Flutter builds (where `flutter clean` was skipped, or Gradle cached aggressively) can produce APKs that look "built" but contain no new code. The fix that shipped on the agent's machine never makes it onto Khaled's A56. This costs verify cycles, wastes build attempts, and erodes trust in the handoff signal. The protocol below catches it before the APK is installed.

### The protocol

Before every release-build handoff, the agent runs this sequence:

1. `flutter clean` — clears all build artifacts
2. `cd D:\Rawi_Journey\android && gradlew.bat assembleRelease` — fresh build
3. `python D:\Rawi_Journey\tools\verify_build.py --sprint "<sprint name>"` — generates the verification block

The script produces a **4-line block** that the agent pastes into the handoff message (the line beginning `BUILD COMPLETE` is a header, the four bullets that follow are the verification block):

```
BUILD COMPLETE - <sprint name>
- flutter clean: confirmed
- APK size: X.XX MB
- libapp.so SHA256: <hash>
- Changed from previous build: YES / NO
```

### The hard rule

- **If `Changed from previous build: NO`** and code was actually modified: the build is **invalid**. Re-run `flutter clean` + `assembleRelease`, then verify again. **DO NOT install this APK on A56.**
- **If the agent's handoff message does not contain this 4-line block:** Khaled does not test the APK. The agent gets asked to re-run the protocol and re-paste.

### Why this works

The script hashes `lib/arm64-v8a/libapp.so` from inside the APK and compares against the most recent entry in `tools/build_log.json`. If the hash is identical to the previous build, no Dart code actually changed in the APK regardless of what `flutter build` claims — it's a stale build. This is the only reliable signal: file timestamps, build-output paths, and Gradle messages can all lie. The compiled native code can't.

The script auto-locates the APK at `build/app/outputs/apk/release/app-release.apk` (default Flutter output path). For unusual paths, pass `--apk <path>`. The build log is kept at `tools/build_log.json` (last 50 entries, auto-trimmed).

### Scope

A56 only — arm64-v8a APKs only. Cross-architecture and other devices are out of scope. The script will warn if `lib/arm64-v8a/libapp.so` isn't found and fall back to any `libapp.so` it can locate, but the protocol's safety guarantee is for arm64-v8a builds on A56.

---

## Diagnostic-first default rule *(added 7 May 2026)*

**Any bug without hard repro steps gets a diagnostic build before any fix attempt.** This was already the rule for HF3's two intermittent items (first hotspot tap miss, progress card N-1 regression). Formalizing it as a default makes it explicit and removes ambiguity:

| Bug shape | Action |
|---|---|
| "Sometimes happens" / "intermittent" / "occasionally" | **Diagnostic build first.** No guess-fixes. |
| "Always happens when X" / clear repro | Fix attempt is fine — proceed normally. |
| When in doubt | **Diagnostic.** Cost of one extra diagnostic build is small. Cost of a wrong fix that ships is high. |

### What a diagnostic build looks like

The agent adds **instrumentation** targeted at the suspected mechanism — examples:

- **Lifecycle bugs** → logcat tags on key lifecycle callbacks (resume, pause, dispose), route observers
- **Gesture / hit-test bugs** → render-tree dumps at first paint, gesture event traces, hit-test geometry logs
- **Audio bugs** → AudioService caller-stack instrumentation (HF2 used this pattern)
- **State / persistence bugs** → SharedPreferences read/write tracing, state-transition logs
- **Rendering / layout bugs** → BuildContext walks, RenderBox geometry dumps at the moment the bug manifests

The diagnostic build is shipped to Khaled like any other build (with the verification protocol above). Khaled runs it on A56, captures the relevant log/output, sends back to agent. Agent fixes based on **evidence**, not hypothesis.

### Why this matters

Guess-fixes for intermittent bugs land you in a long debug-build cycle: try-fix-A, install, test, doesn't work, try-fix-B, install, test, doesn't work, etc. Each attempt costs a build and a verify session. One diagnostic build replaces N guess attempts with a single targeted fix from a position of knowledge.

### Pairing with build verification

Every diagnostic build also goes through `verify_build.py`. A diagnostic build that doesn't reach the device (because it's stale) is worse than no diagnostic at all — you'd be reading the previous build's logs and drawing wrong conclusions.

---

_Document created Apr 24 2026 as part of R28-S1 HUGE sprint. When a
new permanent rule is established, append here with the sprint
marker (`R28-S1`, `R28-S2`, etc.) so future agents can trace the
provenance._

_Build-verification protocol + Diagnostic-first default appended 7 May 2026 from `RAWI_RULES_PATCH-07May2026-1930.md` (source: `RAWI_WORKFLOW_ENHANCEMENTS-5May2026-2200.md` enhancements #2 + #3). Append-only — all rules above this line preserved verbatim._
