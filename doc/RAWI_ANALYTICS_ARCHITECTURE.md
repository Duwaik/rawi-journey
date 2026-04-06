# RawiJourney — Analytics & Crash Reporting Architecture

> **Status:** Architectural design — implement before public launch.
> This is infrastructure, not a feature. Invisible to users,
> essential for the team.

---

## 1. Two Systems Needed

| System | Purpose | When |
|--------|---------|------|
| **Crash Reporting** | Capture app crashes + stack traces, sent automatically | Pre-launch |
| **User Behavior Analytics** | Track how users interact, what they tap, where they go | Pre-launch |

Both must work **fully offline** (queue events locally, send when
connected) since RawiJourney is designed as an offline-first app.

---

## 2. Crash Reporting

### What We Need
- Automatic crash capture (unhandled exceptions + fatal errors)
- Stack traces with device info (OS version, device model, app version)
- Sent to a dashboard we can review
- Zero user friction — no popups, no "send report?" dialogs

### Recommended Tool: Firebase Crashlytics
- Free tier is more than enough
- Flutter plugin: `firebase_crashlytics`
- Works offline — queues crashes, sends on next connection
- Dashboard groups crashes by frequency and severity
- Minimal setup — ~30 minutes to integrate

### Alternative (if avoiding Google): Sentry
- `sentry_flutter` package
- Free tier: 5K events/month (plenty for early stage)
- Self-hosted option available
- Slightly more setup than Firebase

### Implementation
```dart
// In main.dart — wrap the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  
  runApp(const RawiJourneyApp());
}
```

### What Gets Captured Automatically
- App crashes (unhandled exceptions)
- ANRs (App Not Responding)
- Device model, OS version, app version
- Stack trace with file + line number
- Memory state at time of crash

### Custom Keys to Add
- Current event ID (which event was the user playing?)
- Current screen (registration, event list, immersive, etc.)
- Selected companion (Rawi/Rawiah)
- Language setting (EN/AR)
- Total XP (proxy for how far they've progressed)

---

## 3. User Behavior Analytics (Heatmap & Interaction Tracking)

### What We Want to Know

**Navigation patterns:**
- Which events do users play first? In order or skipping?
- How long do they spend on each event?
- Where do they drop off? (start event but don't finish)
- Do they replay completed events?

**In-scene behavior:**
- Which hotspots do they visit first?
- How long do they read each hotspot card?
- Do they use the joystick or tap-to-walk more?
- Do they listen to VO or skip it?
- Which branch do they choose (Path A vs Path B)?

**Engagement signals:**
- How many events per session?
- Session duration?
- Return rate (daily, weekly)?
- Do they change language mid-session?
- Do they engage with dhikr (Layer 1)?

**Friction points:**
- Where do users pause for a long time? (confused?)
- Do they tap locked hotspots repeatedly? (frustrated?)
- Do they tap the back button during an event? (wanting to leave?)
- Do they change text size? (readability issue?)

### Recommended Tool: Firebase Analytics
- Free, unlimited events
- Works with Crashlytics (same Firebase project)
- Custom events + parameters
- Funnel visualization
- Flutter plugin: `firebase_analytics`

### Alternative: Mixpanel or Amplitude
- Better for product analytics and funnels
- Free tiers available
- More powerful than Firebase Analytics for behavior analysis
- But adds another dependency

### Key Events to Track

```
// Screen views
app_open (time_of_day, device_model)
screen_view (screen_name)

// Onboarding
companion_selected (rawi/rawiah)
language_selected (en/ar)
registration_completed (time_spent_seconds)

// Event engagement
event_started (event_id, event_name, chapter)
event_completed (event_id, time_spent_seconds, xp_earned)
event_abandoned (event_id, last_hotspot_visited, time_spent)

// In-scene behavior
hotspot_visited (event_id, hotspot_id, hotspot_name, visit_order)
hotspot_time_spent (event_id, hotspot_id, seconds)
vo_played (event_id, hotspot_id, listened_full: bool)
vo_skipped (event_id, hotspot_id, skipped_at_seconds)
branch_chosen (event_id, branch_option: A/B)
joystick_used (event_id, total_seconds)
hotspot_tap_walked (event_id, hotspot_id)

// Verdict
verdict_answered (event_id, answer_index, correct: bool, time_to_answer)
verdict_explanation_read (event_id, time_spent_seconds)

// Rewards
xp_overlay_seen (event_id, xp_earned, total_xp)
chapter_overlay_seen (chapter_name)
badge_earned (badge_id, badge_name)

// Hasanat (Layer 1)
dhikr_prompt_shown (event_id)
dhikr_accepted (event_id, dhikr_id)
dhikr_declined (event_id)
dhikr_completed (event_id, dhikr_id, hasanat_earned)

// Settings
language_changed (from, to)
text_size_changed (from, to)
music_toggled (on/off)
vo_toggled (on/off)

// Retention
app_session_start (session_number, days_since_last)
app_session_end (duration_seconds, events_completed)
```

### Privacy Considerations
- **No personal data collected** — no name, no email, no location
- Analytics are anonymous (Firebase assigns anonymous IDs)
- Fully compliant with app store policies
- Consider adding a one-line note in Settings: "Anonymous usage
  data helps us improve RawiJourney. No personal data is collected."
- No opt-out toggle needed for anonymous analytics, but could add
  one as goodwill

---

## 4. Heatmap Visualization

True touch-position heatmaps (like Hotjar for web) are harder on
mobile. Two approaches:

### Option A: Event-Based Heatmap (Recommended)
Track which UI elements get tapped and in what order. Reconstruct
behavior from event logs. This is what the events above give you.
No special tool needed — Firebase Analytics + a spreadsheet can
show you where users spend time and what they tap.

### Option B: Session Recording (Post-Launch)
Tools like UXCam or Smartlook can record actual screen sessions
and generate touch heatmaps. Powerful but:
- Adds SDK weight
- Privacy implications (recording screens)
- Overkill for early stage
- Recommend adding ONLY if event-based analytics don't answer
  your questions

**Recommendation:** Start with Option A. It answers 90% of your
questions with zero privacy concerns and no extra tools.

---

## 5. Dashboard & Monitoring

### What to Monitor Weekly
- Crash-free rate (target: >99%)
- Top 3 crashes by frequency
- Event completion rate per event
- Average session duration
- Drop-off points (which events lose users?)
- Branch choice distribution (A vs B per event)
- VO listen rate
- Dhikr engagement rate

### What to Monitor Monthly
- Retention curves (Day 1, Day 7, Day 30)
- Chapter completion rates
- Language distribution
- Device/OS distribution
- Text size usage (accessibility signal)

---

## 6. Implementation Plan

| # | Task | Effort | When |
|---|------|--------|------|
| 1 | Add Firebase to project (Core + Crashlytics) | 0.5 sprint | Before public launch |
| 2 | Add crash reporting wrapper in main.dart | 0.5 sprint | Before public launch |
| 3 | Add custom crash keys (event ID, screen, etc.) | 0.5 sprint | Before public launch |
| 4 | Add Firebase Analytics + core events | 1 sprint | Before public launch |
| 5 | Add in-scene behavior events | 1 sprint | Before public launch |
| 6 | Test crash reporting (force a crash, verify dashboard) | 0.5 sprint | Before public launch |
| **Total** | | **~4 sprints** | |

---

## 7. Decision Log

| Decision | Status |
|----------|--------|
| Crash reporting required before launch | ✅ Locked |
| User behavior analytics required before launch | ✅ Locked |
| Must work offline (queue + send) | ✅ Locked |
| No personal data collected | ✅ Locked |
| Tool choice: Firebase vs Sentry/Mixpanel | ⬜ TBD |
| Session recording (UXCam etc.) | ⬜ Deferred to post-launch |
| Privacy note in Settings | ⬜ TBD |

---

## 8. Compatibility Note

RawiJourney is designed as a **fully offline, buy-once app**.
Adding Firebase does NOT change this:
- Firebase Crashlytics and Analytics queue events locally
- Events are sent only when the device has connectivity
- The app functions 100% without internet
- No Firebase features are user-facing
- No login, no cloud sync, no remote config needed
