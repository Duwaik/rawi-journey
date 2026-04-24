import 'package:shared_preferences/shared_preferences.dart';
import '../data/m1_data.dart';
import '../models/badge_definition.dart';
import 'debug_log_service.dart';

class PrefsService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Force reload from disk (ensures writes from other screens are visible).
  static Future<void> reload() async {
    await _prefs?.reload();
  }

  // ── KEYS ─────────────────────────────────────────────────────────────────
  static const String _keyLanguage        = 'user_language';
  static const String _keyXp             = 'user_xp';
  static const String _keyStreak         = 'user_streak';
  static const String _keyStreakDate      = 'user_streak_last_date';
  static const String _keyJourneyCurrent  = 'journey_current_order';
  static const String _keyJourneyCompleted = 'journey_completed_prefix';
  static const String _keyWelcomeSeen      = 'welcome_seen';
  static const String _keyOnboardingDone   = 'onboarding_complete';
  static const String _keyFirstLaunch      = 'first_launch_date';
  static const String _keyUserName         = 'user_name';
  static const String _keyUserGender       = 'user_gender';
  static const String _keyMusicEnabled     = 'music_enabled';
  static const String _keyVoEnabled        = 'vo_enabled';
  static const String _keySfxEnabled       = 'sfx_enabled';
  static const String _keyTextScale        = 'text_scale';
  static const String _keyTutorialSeen     = 'tutorial_seen';
  static const String _keyChoiceTutSeen    = 'choice_tutorial_seen';
  static const String _keyEventQTooltipSeen = 'event_q_tooltip_seen';
  static const String _keyAgeTier          = 'age_tier';
  static const String _keyDebugOverlay     = 'debug_overlay_enabled';
  static const String _keyEvent1TutorialShown = 'tutorial_event1_shown';
  static const String _keyLastEventId         = 'last_event_id';
  static const String _keyEventInProgress     = 'event_in_progress';
  // R28 S1-BUG2: persisted ambient resume state for recovery from
  // Activity recreate (Samsung One UI aggressive kill on home). The
  // in-memory `AudioService._resumeAmbientPath` is lost when the Dart
  // isolate is reset — these prefs let `resumeLastAmbient` pick up
  // even on cold recreate, as long as the stamp is recent.
  static const String _keyAudioResumePath      = 'audio_resume_path';
  static const String _keyAudioResumeVolume    = 'audio_resume_volume';
  static const String _keyAudioResumeStampMs   = 'audio_resume_stamp_ms';

  // ── LANGUAGE ──────────────────────────────────────────────────────────────
  static String get language => _prefs?.getString(_keyLanguage) ?? 'en';
  static bool get isAr => language == 'ar';
  static Future<void> setLanguage(String v) async =>
      await _prefs?.setString(_keyLanguage, v);

  // ── XP ────────────────────────────────────────────────────────────────────
  static int get xp => _prefs?.getInt(_keyXp) ?? 0;
  static Future<void> addXp(int amount) async =>
      await _prefs?.setInt(_keyXp, xp + amount);

  // ── STREAK ────────────────────────────────────────────────────────────────
  static int get streak => _prefs?.getInt(_keyStreak) ?? 1;

  static Future<void> updateStreak() async {
    final today = _todayStr();
    final last  = _prefs?.getString(_keyStreakDate) ?? '';
    if (last == today) return;
    if (last.isEmpty) {
      // First ever completion — initialize streak
      await _prefs?.setInt(_keyStreak, 1);
    } else {
      final diff = DateTime.now().difference(DateTime.parse(last)).inDays;
      await _prefs?.setInt(_keyStreak, diff == 1 ? streak + 1 : 1);
    }
    await _prefs?.setString(_keyStreakDate, today);
  }

  // ── JOURNEY PROGRESSION ───────────────────────────────────────────────────
  /// The global order of the currently active (next to complete) event.
  static int get currentOrder => _prefs?.getInt(_keyJourneyCurrent) ?? 1;

  static bool isEventCompleted(int globalOrder) =>
      _prefs?.getBool('${_keyJourneyCompleted}_$globalOrder') ?? false;

  static Future<void> completeEvent(int globalOrder, int xpReward) async {
    await _prefs?.setBool('${_keyJourneyCompleted}_$globalOrder', true);
    // Advance current pointer if this is the active event
    if (globalOrder >= currentOrder) {
      await _prefs?.setInt(_keyJourneyCurrent, globalOrder + 1);
    }
    await addXp(xpReward);
    await updateStreak();
  }

  /// Reset ALL progress — clears every progress-related key.
  /// Preserves: user profile (name, gender, language, text scale, audio toggles).
  static Future<void> resetJourney() async {
    final prefs = _prefs;
    if (prefs == null) return;

    // Clear all progress-related keys (including dynamic ones)
    final keys = prefs.getKeys().toList();
    for (final key in keys) {
      if (key.startsWith(_keyJourneyCompleted) ||
          key.startsWith(_keyHotspotProgress) ||
          key.startsWith(_keyThresholdCompleted) ||
          key.startsWith(_keyPassageSeen) ||
          key.startsWith(_keyDhikrCompleted) ||
          key == _keyDiscoveredCollection ||
          key == _keyDiscoveredSecrets) {
        await prefs.remove(key);
      }
    }

    // Clear all scalar progress keys
    await prefs.setInt(_keyJourneyCurrent, 1);
    await prefs.setInt(_keyXp, 0);
    await prefs.setInt(_keyStreak, 1);
    await prefs.remove(_keyStreakDate);
    await prefs.setStringList(_keyEarnedBadges, []);
    await prefs.setBool(_keyTutorialSeen, false);
    await prefs.setBool(_keyChoiceTutSeen, false);
    // R9-02: Reset onboarding so user sees intro cinematic + registration again
    await prefs.setBool(_keyOnboardingDone, false);
    await prefs.setBool(_keyRawiCallShown, false);
    await prefs.setInt(_keyDhikrCount, 0);
    await setNoorLevel(100);
    await prefs.setBool(_keyDhikrTutorialSeen, false);
    // R27 S1.1-TENT6: also reset all three cinematic/coach-mark
    // tutorial flags so a different user inheriting the device
    // gets the full fresh-install tutorial loop (tent cinematic →
    // icon coach-mark → Event 1 tutorial on first event launch).
    await prefs.remove(_keyTentTutorialShown);
    await prefs.remove(_keyTentIconTutorialShown);
    await prefs.remove(_keyEvent1TutorialShown);
    // Reset tent-dhikr 24 h lock too — a new user shouldn't inherit
    // the previous owner's cooldown timestamp.
    await prefs.remove(_keyLastTentDhikrTs);
  }

  // ── WELCOME SCREEN (legacy — kept for migration) ──────────────────────────
  static bool get isWelcomeSeen => _prefs?.getBool(_keyWelcomeSeen) ?? false;
  static Future<void> setWelcomeSeen() async =>
      await _prefs?.setBool(_keyWelcomeSeen, true);

  // ── ONBOARDING ────────────────────────────────────────────────────────────
  static bool get isOnboardingComplete =>
      _prefs?.getBool(_keyOnboardingDone) ?? false;
  static Future<void> setOnboardingComplete() async {
    await _prefs?.setBool(_keyOnboardingDone, true);
    // Record first launch date if not already set
    if (_prefs?.getString(_keyFirstLaunch) == null) {
      await _prefs?.setString(_keyFirstLaunch, _todayStr());
    }
  }

  static String get firstLaunchDate =>
      _prefs?.getString(_keyFirstLaunch) ?? _todayStr();

  // ── USER PROFILE ──────────────────────────────────────────────────────────
  static String get userName => _prefs?.getString(_keyUserName) ?? '';

  /// R25-S3-HF-5: capitalize the first letter of the trimmed input
  /// before persisting. Future users get properly cased names in
  /// storage; the tent greeting also applies the same transform at
  /// render time as a safety net for users registered before this
  /// shipped.
  static Future<void> setUserName(String v) async {
    final trimmed = v.trim();
    final cased = trimmed.isEmpty
        ? trimmed
        : trimmed[0].toUpperCase() + trimmed.substring(1);
    await _prefs?.setString(_keyUserName, cased);
  }

  static String get userGender => _prefs?.getString(_keyUserGender) ?? 'male';
  static Future<void> setUserGender(String v) async =>
      await _prefs?.setString(_keyUserGender, v);

  // ── AUDIO TOGGLES ─────────────────────────────────────────────────────────
  static bool get musicEnabled => _prefs?.getBool(_keyMusicEnabled) ?? true;
  static Future<void> setMusicEnabled(bool v) async =>
      await _prefs?.setBool(_keyMusicEnabled, v);

  static bool get voEnabled => _prefs?.getBool(_keyVoEnabled) ?? true;
  static Future<void> setVoEnabled(bool v) async =>
      await _prefs?.setBool(_keyVoEnabled, v);

  static bool get sfxEnabled => _prefs?.getBool(_keySfxEnabled) ?? true;
  static Future<void> setSfxEnabled(bool v) async =>
      await _prefs?.setBool(_keySfxEnabled, v);

  // ── HOTSPOT PROGRESS (per event) ───────────────────────────────────────
  static const String _keyHotspotProgress = 'hotspot_progress_';

  /// Save discovered hotspot IDs for an event (survives back press).
  static Future<void> saveHotspotProgress(String eventId, Set<String> discovered) async {
    await _prefs?.setStringList(
        '$_keyHotspotProgress$eventId', discovered.toList());
  }

  /// Load previously discovered hotspot IDs for an event.
  static Set<String> loadHotspotProgress(String eventId) {
    final list = _prefs?.getStringList('$_keyHotspotProgress$eventId');
    return list?.toSet() ?? {};
  }

  /// Clear hotspot progress for an event (on full completion).
  static Future<void> clearHotspotProgress(String eventId) async {
    await _prefs?.remove('$_keyHotspotProgress$eventId');
  }

  /// R26 S1v3-T2.2: branching choice persistence. For branching events
  /// the user picks an option on the Crossroads card; without this
  /// persistence, resuming via Continue re-shows the Crossroads even
  /// though the user already chose (because [_branchChoice] in the
  /// scene widget defaults to null on a fresh initState).
  ///
  /// Stored value = the chosen BranchOption.targetHotspotId. On resume
  /// the scene matches this back to one of the two options and
  /// reconstructs the unlock order. The discovered hotspot set
  /// (via [loadHotspotProgress]) tells the resume logic which branch
  /// HS is the next one to show.
  ///
  /// Cleared on event completion alongside [clearHotspotProgress].
  static const String _keyBranchChoice = 'branching_choice_';
  static String? getBranchChoice(String eventId) =>
      _prefs?.getString('$_keyBranchChoice$eventId');
  static Future<void> setBranchChoice(
      String eventId, String targetHotspotId) async {
    await _prefs?.setString('$_keyBranchChoice$eventId', targetHotspotId);
  }
  static Future<void> clearBranchChoice(String eventId) async {
    await _prefs?.remove('$_keyBranchChoice$eventId');
  }

  // ── RAWI CALL (one-time story screen) ──────────────────────────────────
  static const String _keyRawiCallShown = 'rawi_call_shown';

  static bool get isRawiCallShown =>
      _prefs?.getBool(_keyRawiCallShown) ?? false;

  static Future<void> setRawiCallShown() async =>
      await _prefs?.setBool(_keyRawiCallShown, true);

  // ── COLLECTION ────────────────────────────────────────────────────────
  static const String _keyDiscoveredCollection = 'discovered_collection';

  static List<String> get discoveredCollectionIds =>
      _prefs?.getStringList(_keyDiscoveredCollection) ?? [];

  static Future<void> addToCollection(String itemId) async {
    final current = discoveredCollectionIds;
    if (!current.contains(itemId)) {
      current.add(itemId);
      await _prefs?.setStringList(_keyDiscoveredCollection, current);
    }
  }

  static bool isCollectionItemDiscovered(String itemId) =>
      discoveredCollectionIds.contains(itemId);

  // ── THRESHOLDS ────────────────────────────────────────────────────────
  static const String _keyThresholdCompleted = 'threshold_completed_';

  static bool isThresholdCompleted(int beforeEventOrder) =>
      _prefs?.getBool('$_keyThresholdCompleted$beforeEventOrder') ?? false;

  static Future<void> setThresholdCompleted(int beforeEventOrder) async =>
      await _prefs?.setBool('$_keyThresholdCompleted$beforeEventOrder', true);

  // ── PASSAGES (R20 Part E) ─────────────────────────────────────────────
  // Seen once per globalOrder. Used to play "The Passage / المعبر"
  // cinematic exactly once after events 14/42/47/82/120.
  static const String _keyPassageSeen = 'passage_seen_';

  static bool isPassageSeen(int afterEventOrder) =>
      _prefs?.getBool('$_keyPassageSeen$afterEventOrder') ?? false;

  static Future<void> setPassageSeen(int afterEventOrder) async =>
      await _prefs?.setBool('$_keyPassageSeen$afterEventOrder', true);

  // ── JOYSTICK POSITION (R21-04) ────────────────────────────────────────
  // Explorer Mode joystick placement: 'left' | 'center' | 'right'.
  static const String _keyJoystickPosition = 'joystickPosition';

  /// B12a: when no explicit pref is saved, default mirrors the language —
  /// AR → right, EN → left. Once user picks explicitly via Settings, the
  /// saved value wins regardless of language.
  static String get joystickPosition {
    final saved = _prefs?.getString(_keyJoystickPosition);
    if (saved != null) return saved;
    return isAr ? 'right' : 'left';
  }

  static Future<void> setJoystickPosition(String pos) async =>
      await _prefs?.setString(_keyJoystickPosition, pos);

  // ── FEATURE FLAGS (R23 — all default false, flip when ready) ──────────
  static const String _keyLittleRawi = 'ff_little_rawi';
  static const String _keyAdditionalLangs = 'ff_additional_langs';
  static const String _keyChallengeMode = 'ff_challenge_mode';
  static const String _keyMasteryMap = 'ff_mastery_map';
  static const String _keyManuscripts = 'ff_manuscripts';

  static bool get littleRawiEnabled =>
      _prefs?.getBool(_keyLittleRawi) ?? false;
  static bool get additionalLanguagesEnabled =>
      _prefs?.getBool(_keyAdditionalLangs) ?? false;
  static bool get challengeModeEnabled =>
      _prefs?.getBool(_keyChallengeMode) ?? false;
  static bool get masteryMapEnabled =>
      _prefs?.getBool(_keyMasteryMap) ?? false;
  static bool get manuscriptsEnabled =>
      _prefs?.getBool(_keyManuscripts) ?? false;

  // ── TUTORIAL ──────────────────────────────────────────────────────────
  static bool get isTutorialSeen =>
      _prefs?.getBool(_keyTutorialSeen) ?? false;
  static Future<void> setTutorialSeen() async =>
      await _prefs?.setBool(_keyTutorialSeen, true);

  static bool get isChoiceTutorialSeen =>
      _prefs?.getBool(_keyChoiceTutSeen) ?? false;
  static Future<void> setChoiceTutorialSeen() async =>
      await _prefs?.setBool(_keyChoiceTutSeen, true);

  // B12c: first-time tooltip on the Event Question screen.
  static bool get isEventQTooltipSeen =>
      _prefs?.getBool(_keyEventQTooltipSeen) ?? false;
  static Future<void> setEventQTooltipSeen() async =>
      await _prefs?.setBool(_keyEventQTooltipSeen, true);

  // B27: persistent debug overlay toggle. Default ON during testing,
  // turn OFF for production via Settings triple-tap or pref.
  static bool get isDebugOverlayEnabled =>
      _prefs?.getBool(_keyDebugOverlay) ?? true;
  static Future<void> setDebugOverlayEnabled(bool v) async =>
      await _prefs?.setBool(_keyDebugOverlay, v);

  /// R25-S3-7: one-time Event 1 tutorial overlay shown after the intro
  /// video of the very first event. Flipped true on dismiss; never shown
  /// again until QA resets all tutorials (see [resetAllTutorials]).
  static bool get isEvent1TutorialShown =>
      _prefs?.getBool(_keyEvent1TutorialShown) ?? false;
  static Future<void> setEvent1TutorialShown() async =>
      await _prefs?.setBool(_keyEvent1TutorialShown, true);

  /// R27 S1-TENT1: one-time first-visit tent tutorial cinematic.
  /// 5-screen cinematic that runs on the user's first-ever tent visit
  /// after registration. R27 S1.1-TENT4 moved the write to FIRST-tap
  /// so a force-quit mid-cinematic doesn't replay it.
  static const String _keyTentTutorialShown = 'tent_tutorial_shown';
  static bool get isTentTutorialShown =>
      _prefs?.getBool(_keyTentTutorialShown) ?? false;
  static Future<void> setTentTutorialShown() async =>
      await _prefs?.setBool(_keyTentTutorialShown, true);

  /// R27 S1.1-TENT5: one-time icon coach-mark tutorial that fires
  /// immediately after the tent cinematic completes. 5 sequential
  /// highlights over the right-side nav icons (Events, Stars,
  /// Scroll, Dhikr, Collections). Flag set true on completion OR
  /// on Skip; never re-fires until [resetAllTutorials].
  static const String _keyTentIconTutorialShown = 'tent_icon_tutorial_shown';
  static bool get isTentIconTutorialShown =>
      _prefs?.getBool(_keyTentIconTutorialShown) ?? false;
  static Future<void> setTentIconTutorialShown() async =>
      await _prefs?.setBool(_keyTentIconTutorialShown, true);

  /// R26 S1-T2: "event in progress" flag + the event ID the user left
  /// mid-play. Tent uses these to flip the primary button between
  /// Start (fresh journey) and Continue (resume the saved event).
  ///
  /// Write path: every save-moment inside an event (hotspot discovery,
  /// branch choice, mid-event exit) calls [setInProgressEvent]. The
  /// event-completion path calls [clearInProgressEvent] so the tent
  /// doesn't keep offering Continue on a finished event.
  static String? get lastEventId => _prefs?.getString(_keyLastEventId);
  static bool get isEventInProgress =>
      _prefs?.getBool(_keyEventInProgress) ?? false;
  static Future<void> setInProgressEvent(String eventId) async {
    await _prefs?.setString(_keyLastEventId, eventId);
    await _prefs?.setBool(_keyEventInProgress, true);
  }
  static Future<void> clearInProgressEvent() async {
    await _prefs?.setBool(_keyEventInProgress, false);
  }

  // ── AUDIO RESUME (BUG2 defensive) ──────────────────────────────────────────
  /// R28 S1-BUG2: persisted slot for the ambient track that was playing
  /// when the app last paused. Backs up the in-memory resume key in
  /// `AudioService` so `resumeLastAmbient` can recover even after an
  /// Activity-recreate-driven Dart isolate reset (observed on Samsung
  /// One UI home-button + >5s return).
  ///
  /// Staleness: the stamp lets the read side discard old entries (>10
  /// min) so a true cold launch hours later doesn't auto-play an
  /// ambient the user didn't expect.
  static String? get audioResumePath =>
      _prefs?.getString(_keyAudioResumePath);
  static double get audioResumeVolume =>
      _prefs?.getDouble(_keyAudioResumeVolume) ?? 0.0;
  static int get audioResumeStampMs =>
      _prefs?.getInt(_keyAudioResumeStampMs) ?? 0;
  static Future<void> setAudioResume(String path, double volume) async {
    await _prefs?.setString(_keyAudioResumePath, path);
    await _prefs?.setDouble(_keyAudioResumeVolume, volume);
    await _prefs?.setInt(
        _keyAudioResumeStampMs, DateTime.now().millisecondsSinceEpoch);
  }
  static Future<void> clearAudioResume() async {
    await _prefs?.remove(_keyAudioResumePath);
    await _prefs?.remove(_keyAudioResumeVolume);
    await _prefs?.remove(_keyAudioResumeStampMs);
  }

  /// R25-S3-7: QA/dev helper — clear every tutorial-seen flag so the
  /// next run shows all overlays again. Gated behind kDebugMode at the
  /// UI surface; the pref mutation itself has no production gate.
  static Future<void> resetAllTutorials() async {
    await _prefs?.remove(_keyTutorialSeen);
    await _prefs?.remove(_keyChoiceTutSeen);
    await _prefs?.remove(_keyEventQTooltipSeen);
    await _prefs?.remove(_keyEvent1TutorialShown);
  }

  // ── TEXT SCALE (Accessibility) ─────────────────────────────────────────────
  static double get textScale =>
      _prefs?.getDouble(_keyTextScale) ?? 1.0;
  static Future<void> setTextScale(double v) async =>
      await _prefs?.setDouble(_keyTextScale, v);

  // ── BADGES ────────────────────────────────────────────────────────────────
  static const String _keyEarnedBadges = 'earned_badges';

  static List<String> get earnedBadges =>
      _prefs?.getStringList(_keyEarnedBadges) ?? [];

  static Future<void> _awardBadge(String badgeId) async {
    final current = earnedBadges;
    if (!current.contains(badgeId)) {
      current.add(badgeId);
      await _prefs?.setStringList(_keyEarnedBadges, current);
    }
  }

  /// Check all badge triggers after event completion. Returns newly earned badges.
  static Future<List<BadgeDefinition>> checkAndAwardBadges() async {
    final newBadges = <BadgeDefinition>[];
    final earned = earnedBadges;

    for (final badge in allBadges) {
      if (earned.contains(badge.id)) continue;

      bool qualifies = false;

      switch (badge.trigger.type) {
        case BadgeTriggerType.eventCount:
          final count = List.generate(m1EventCount, (i) => i + 1)
              .where((o) => isEventCompleted(o))
              .length;
          qualifies = count >= (badge.trigger.value ?? 999);
        case BadgeTriggerType.chapterComplete:
          final range = badge.trigger.eventRange!;
          qualifies = List.generate(
            range[1] - range[0] + 1,
            (i) => range[0] + i,
          ).every((o) => isEventCompleted(o));
        case BadgeTriggerType.allEvents:
          qualifies = List.generate(m1EventCount, (i) => i + 1)
              .every((o) => isEventCompleted(o));
      }

      if (qualifies) {
        await _awardBadge(badge.id);
        newBadges.add(badge);
      }
    }

    return newBadges;
  }

  // ── DHIKR (Hasanat) ───────────────────────────────────────────────────────
  static const String _keyDhikrCount = 'dhikr_completed_count';
  static const String _keyDhikrCompleted = 'dhikr_completed_';
  static const String _keyLastTentDhikrTs = 'last_tent_dhikr_ts';

  static int get dhikrCompletedCount =>
      _prefs?.getInt(_keyDhikrCount) ?? 0;

  static Future<void> incrementDhikrCount() async =>
      await _prefs?.setInt(_keyDhikrCount, dhikrCompletedCount + 1);

  static Future<void> setDhikrCompleted(String eventId) async =>
      await _prefs?.setBool('$_keyDhikrCompleted$eventId', true);

  static bool isDhikrCompleted(String eventId) =>
      _prefs?.getBool('$_keyDhikrCompleted$eventId') ?? false;

  /// R26 S1v3-EE6.4: 24h cooldown on the tent-side "I said it" regen.
  /// v2 used a session-local flag which reset any time the user
  /// restarted the app — so they could stack +25 regens by backgrounding
  /// and relaunching. Now we persist the timestamp and gate the next
  /// recharge until 24h have passed.
  ///
  /// Storage: millisecondsSinceEpoch (int). Unset → never tapped.
  /// Caller logic: if now - last < 86400000ms, show the "Said today ✓
  /// Return tomorrow" state and skip the regen.
  static int? get lastTentDhikrTs => _prefs?.getInt(_keyLastTentDhikrTs);

  static Future<void> setLastTentDhikrTs(int ts) async =>
      await _prefs?.setInt(_keyLastTentDhikrTs, ts);

  /// True when the 24h window from the last tent tap has NOT yet passed.
  /// Reads the wall clock at call time, so a user who changes their
  /// system clock backwards still gets a `false` (locked) result because
  /// the delta turns negative. Forward-clock-skew is unavoidable without
  /// a server time source — deferred.
  static bool get isTentDhikrLocked {
    final last = lastTentDhikrTs;
    if (last == null) return false;
    final delta = DateTime.now().millisecondsSinceEpoch - last;
    return delta >= 0 && delta < 86400000;
  }

  // ── DISCOVERED SECRETS (Hidden Scene Elements) ─────────────────────────────
  static const String _keyDiscoveredSecrets = 'discovered_secrets';

  static Set<String> get discoveredSecrets =>
      _prefs?.getStringList(_keyDiscoveredSecrets)?.toSet() ?? {};

  static Future<void> addDiscoveredSecret(String secretId) async {
    final current = discoveredSecrets.toList();
    if (!current.contains(secretId)) {
      current.add(secretId);
      await _prefs?.setStringList(_keyDiscoveredSecrets, current);
    }
  }

  // ── AGE (registration) ──────────────────────────────────────────────────
  // R19-05: Switched from `userAgeRange` (String, 5 buckets) to `userAge`
  // (int, 4-99). Old key kept for backward compat + migration — on first
  // read post-update, existing users get their range midpoint as `userAge`.
  static const String _keyAgeRange = 'userAgeRange'; // legacy
  static const String _keyAge = 'userAge';           // new

  /// User's exact age (4-99). Migrates from the old range bucket on first
  /// read if only the legacy key is set.
  static int get userAge {
    final direct = _prefs?.getInt(_keyAge);
    if (direct != null) return direct;
    // Migration: map legacy range → sensible midpoint integer.
    final range = _prefs?.getString(_keyAgeRange);
    switch (range) {
      case '4-12':  return 10;
      case '13-22': return 18;
      case '23-39': return 30;
      case '40-59': return 50;
      case '60+':   return 65;
      default:      return 18;
    }
  }

  static Future<void> setUserAge(int age) async =>
      await _prefs?.setInt(_keyAge, age.clamp(4, 99));

  /// Legacy getter — still used in a few places until the full migration.
  /// Returns a bucket string derived from `userAge` when possible.
  static String get ageRange {
    final a = userAge;
    if (a <= 12) return '4-12';
    if (a <= 22) return '13-22';
    if (a <= 39) return '23-39';
    if (a <= 59) return '40-59';
    return '60+';
  }

  static Future<void> setAgeRange(String range) async =>
      await _prefs?.setString(_keyAgeRange, range);

  // ── JOURNEY MODE (explorer / reader) ───────���──────────────────────────
  static const String _keyJourneyMode = 'journeyMode';
  static String get journeyMode =>
      _prefs?.getString(_keyJourneyMode) ?? 'explorer';
  static bool get isExplorerMode => journeyMode == 'explorer';
  static Future<void> setJourneyMode(String mode) async =>
      await _prefs?.setString(_keyJourneyMode, mode);

  // ── DHIKR TUTORIAL (Explorer Mode, one-time on Event 1) ──────────────
  static const String _keyDhikrTutorialSeen = 'dhikr_tutorial_seen';
  static bool get isDhikrTutorialSeen =>
      _prefs?.getBool(_keyDhikrTutorialSeen) ?? false;
  static Future<void> setDhikrTutorialSeen() async =>
      await _prefs?.setBool(_keyDhikrTutorialSeen, true);

  // ── NOOR LEVEL (Explorer Mode light mechanic) ──��──────────────────────
  /// Returns the current Noor level in [0, 100]. Default 100 when the
  /// pref hasn't been written yet. Always-clamped on write so readers
  /// never see a negative or >100 value.
  static const String _keyNoorLevel = 'noorLevel';
  static int get noorLevel => _prefs?.getInt(_keyNoorLevel) ?? 100;

  /// R25-S3-4 / R26 S1v2-EE6: clamp writes to [10, 100] AND log the
  /// clamp path to the debug reporter.
  ///
  /// Floor 10 (not 0) is the R26 Light-mechanic rule: light never
  /// fully drops — a user who completes 5+ events without dhikr
  /// lands at 10%, not 0%. Ceiling 100 is unchanged. Registration
  /// still seeds with 100 (see setupInitialState).
  static Future<void> setNoorLevel(int level) async {
    final clamped = level.clamp(10, 100);
    final prev = noorLevel;
    DebugLogService.log('noor', 'setNoorLevel($level)→$clamped (was $prev)');
    await _prefs?.setInt(_keyNoorLevel, clamped);
  }
  /// Deplete noor on event transition. Min floor = 0.
  static Future<void> depleteNoor(int amount) async =>
      await setNoorLevel(noorLevel - amount);
  /// Recharge noor after dhikr. Max cap = 100.
  static Future<void> rechargeNoor(int amount) async =>
      await setNoorLevel(noorLevel + amount);

  // ── LEGACY AGE TIER (kept for backward compat) ────────────────────────
  static int get ageTier => _prefs?.getInt(_keyAgeTier) ?? 1;
  static Future<void> setAgeTier(int tier) async =>
      await _prefs?.setInt(_keyAgeTier, tier);

  // ── HELPERS ───────��───────────────────────────────��───────────────────────
  static String _todayStr() {
    final t = DateTime.now();
    return '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
  }
}
