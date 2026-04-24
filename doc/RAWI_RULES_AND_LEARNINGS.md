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

_Document created Apr 24 2026 as part of R28-S1 HUGE sprint. When a
new permanent rule is established, append here with the sprint
marker (`R28-S1`, `R28-S2`, etc.) so future agents can trace the
provenance._
