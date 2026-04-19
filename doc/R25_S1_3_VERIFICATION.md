# R25-S1-3 — Event 2 Video Freeze Verification

**Status:** Awaiting device confirmation on A56.
**Author:** Claude Code agent, Apr 19 2026 session.
**Parent spec:** `RAWI_R25_S1_SPEC_1.md` §2.S1-3.

## Why no code change in this commit

Per spec:
> Expected result after S1-1 + S1-4 are fixed: Video should initialize
> normally because events-list audio no longer contests the audio channel.
> Verification step: After S1-1 and S1-4 are committed, test Event 2
> launch from tent. If STILL freezes, escalate with new investigation.

## What the preceding commits are expected to resolve

- **S1-1** (`83719c6`): Tent Start launches `VideoIntroScreen` directly
  via `launchEvent()` — events-list no longer mounts in the launch path,
  so its ambient player never starts, so there is no player for the
  video controller to contend with.
- **S1-4** (`bff1ea7`): `VideoIntroScreen._bootController` calls
  `AudioService.stopAll()` before `VideoPlayerController.initialize()`.
  Even if something else is holding the audio channel, it is released
  before init begins. `event_list_screen._openEvent` also now awaits
  `AudioService.fadeOut()` for the legacy path (list → video), so
  launches from the list Start button are equally safe.
- **S1-6** (`247d8ce`): If init still fails despite the above,
  `DebugLogService` now captures `video: init start`,
  `video: isInitialized=true`, `video: init failed …`,
  `video: init timeout (8s) …`, `video: stall watchdog fired …`, plus
  every `audio` and `nav` lifecycle event around it. The next failure
  is instrumented, not silent.
- **S1-7** (`b2815b7`): If init still fails on a bad run, the user
  gets Try Again / Skip, not a frozen first scene — no more forced
  app restart.

## Device verification checklist

Run on Samsung A56 (Android 15), fresh install of the Sprint 1 APK:

- [ ] Cold launch app → tent → tap Start when Event 2 is the next item
  - Expected: NO flash of events-list. Fade to video. Video music +
    first scene within 3 seconds of tap.
- [ ] Back out to tent → repeat 4 more times with full app restart each
  - Expected: 5/5 clean launches.
- [ ] Enter events-list via side nav → tap Event 2 Start
  - Expected: Still works (regression check). Ambient fades, video plays.
- [ ] Toggle debug overlay on → run Event 2 launch once
  - Expected: Log shows
    `nav: push VideoIntroScreen` →
    `audio: stopAll requested (ambient=.../ambient_intro.mp3)` →
    `audio: ambient faded out .../ambient_intro.mp3` (or `STOP`) →
    `video: init start assets/video/event2_intro.mp4` →
    `video: isInitialized=true dur=…` within 8 seconds.
- [ ] Artificial failure: rename `assets/video/event2_intro.mp4` to
      `event2_intro.mp4.bak`, rebuild, launch Event 2
  - Expected: 8s watchdog fires, fallback UI appears with Try Again +
    Skip. Log shows `video: init timeout (8s) …` + `video: fallback
    shown reason=init_timeout`.
- [ ] Restore asset, tap Try Again
  - Expected: Video boots cleanly, fallback disappears.

If any checkbox fails, escalate with the copied debug log pasted into
the Sprint 1 handoff — that is now a separate bug, not S1-3 rolling over.

## If verification passes

Mark Sprint 1 row in `doc/RAWI_R25_SPRINT_ROADMAP.md` §1 as ✅ with this
commit hash appended.
