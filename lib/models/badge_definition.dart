/// Badge earned at chapter milestones and event count thresholds.
/// Checked after each event completion via PrefsService.checkAndAwardBadges().
class BadgeDefinition {
  final String id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final String icon; // emoji
  final BadgeTrigger trigger;

  const BadgeDefinition({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.icon,
    required this.trigger,
  });
}

class BadgeTrigger {
  final BadgeTriggerType type;
  final int? value;
  final List<int>? eventRange; // [start, end] global order inclusive

  const BadgeTrigger({
    required this.type,
    this.value,
    this.eventRange,
  });
}

enum BadgeTriggerType {
  eventCount,
  chapterComplete,
  allEvents,
}

// ── All badge definitions ────────────────────────────────────────────────────

// ── Rebalanced badges (per RAWI_REWARD_SYSTEM.md) ────────────────────────────
// Paced so no drought longer than 7-8 events between badge moments.
// "First Step" removed — completing 1 event isn't an achievement.
// Jahiliyyah has no dedicated badge (only 2 events) — merged into Witness.

const List<BadgeDefinition> allBadges = [
  BadgeDefinition(
    id: 'seeker',
    name: 'Seeker',
    nameAr: 'الباحث',
    description: 'You completed 5 events',
    descriptionAr: 'أكملت 5 أحداث',
    icon: '🌅',
    trigger: BadgeTrigger(type: BadgeTriggerType.eventCount, value: 5),
  ),
  BadgeDefinition(
    id: 'witness',
    name: 'Witness of the Dawn',
    nameAr: 'شاهد الفجر',
    description: 'You witnessed the dawn of the Prophetic era',
    descriptionAr: 'شهدت فجر العصر النبوي',
    icon: '🌙',
    trigger: BadgeTrigger(
      type: BadgeTriggerType.chapterComplete,
      eventRange: [1, 11], // Jahiliyyah + Early Life
    ),
  ),
  BadgeDefinition(
    id: 'keeper',
    name: 'Keeper of the Path',
    nameAr: 'حارس الدرب',
    description: 'You completed 15 events',
    descriptionAr: 'أكملت 15 حدثاً',
    icon: '🔥',
    trigger: BadgeTrigger(type: BadgeTriggerType.eventCount, value: 15),
  ),
  BadgeDefinition(
    id: 'steadfast',
    name: 'Steadfast in Mecca',
    nameAr: 'صامد في مكة',
    description: 'You endured the Meccan struggle',
    descriptionAr: 'صبرت على ابتلاء مكة',
    icon: '🕋',
    trigger: BadgeTrigger(
      type: BadgeTriggerType.chapterComplete,
      eventRange: [1, 22], // All through Mecca
    ),
  ),
  BadgeDefinition(
    id: 'scholar',
    name: 'Scholar',
    nameAr: 'العالِم',
    description: 'You completed 30 events',
    descriptionAr: 'أكملت 30 حدثاً',
    icon: '📜',
    trigger: BadgeTrigger(type: BadgeTriggerType.eventCount, value: 30),
  ),
  BadgeDefinition(
    id: 'guardian',
    name: 'Guardian of the Legacy',
    nameAr: 'حارس الإرث',
    description: 'You witnessed the rise of the community',
    descriptionAr: 'شهدت قيام الأمة',
    icon: '🏛️',
    trigger: BadgeTrigger(
      type: BadgeTriggerType.chapterComplete,
      eventRange: [1, 36], // All events
    ),
  ),
  BadgeDefinition(
    id: 'rawi',
    name: 'The Rawi',
    nameAr: 'الراوي',
    description: 'You witnessed the entire Prophetic journey',
    descriptionAr: 'شهدت رحلة النبوة كاملة',
    icon: '👑',
    trigger: BadgeTrigger(type: BadgeTriggerType.allEvents),
  ),
];
