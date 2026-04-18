import 'package:shared_preferences/shared_preferences.dart';
import '../data/m1_data.dart';
import '../models/badge_definition.dart';

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
  static Future<void> setUserName(String v) async =>
      await _prefs?.setString(_keyUserName, v);

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

  static int get dhikrCompletedCount =>
      _prefs?.getInt(_keyDhikrCount) ?? 0;

  static Future<void> incrementDhikrCount() async =>
      await _prefs?.setInt(_keyDhikrCount, dhikrCompletedCount + 1);

  static Future<void> setDhikrCompleted(String eventId) async =>
      await _prefs?.setBool('$_keyDhikrCompleted$eventId', true);

  static bool isDhikrCompleted(String eventId) =>
      _prefs?.getBool('$_keyDhikrCompleted$eventId') ?? false;

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
  static const String _keyNoorLevel = 'noorLevel';
  static int get noorLevel => _prefs?.getInt(_keyNoorLevel) ?? 100;
  static Future<void> setNoorLevel(int level) async =>
      await _prefs?.setInt(_keyNoorLevel, level.clamp(0, 100));
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
