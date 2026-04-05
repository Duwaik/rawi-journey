import 'package:shared_preferences/shared_preferences.dart';
import '../data/m1_data.dart';
import '../models/badge_definition.dart';

class PrefsService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
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
          key.startsWith(_keyHotspotProgress)) {
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

  // ── TUTORIAL ──────────────────────────────────────────────────────────
  static bool get isTutorialSeen =>
      _prefs?.getBool(_keyTutorialSeen) ?? false;
  static Future<void> setTutorialSeen() async =>
      await _prefs?.setBool(_keyTutorialSeen, true);

  static bool get isChoiceTutorialSeen =>
      _prefs?.getBool(_keyChoiceTutSeen) ?? false;
  static Future<void> setChoiceTutorialSeen() async =>
      await _prefs?.setBool(_keyChoiceTutSeen, true);

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

  // ── HELPERS ───────────────────────────────────────────────────────────────
  static String _todayStr() {
    final t = DateTime.now();
    return '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
  }
}
