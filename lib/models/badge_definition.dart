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
  firstEvent,
  eventCount,
  chapterComplete,
  allEvents,
}

// ── All badge definitions ────────────────────────────────────────────────────

const List<BadgeDefinition> allBadges = [
  BadgeDefinition(
    id: 'first_step',
    name: 'First Step',
    nameAr: 'الخطوة الأولى',
    description: 'You completed your first event',
    descriptionAr: 'أكملت أول حدث في رحلتك',
    icon: '🌅',
    trigger: BadgeTrigger(type: BadgeTriggerType.firstEvent),
  ),
  BadgeDefinition(
    id: 'witness_of_dawn',
    name: 'Witness of the Dawn',
    nameAr: 'شاهد الفجر',
    description: 'You witnessed Pre-Islamic Arabia',
    descriptionAr: 'شهدت الجزيرة العربية قبل النور',
    icon: '🌙',
    trigger: BadgeTrigger(
      type: BadgeTriggerType.chapterComplete,
      eventRange: [1, 3],
    ),
  ),
  BadgeDefinition(
    id: 'companion_of_beginning',
    name: 'Companion of the Beginning',
    nameAr: 'رفيق البداية',
    description: 'You walked through the Prophetic childhood',
    descriptionAr: 'عشت مع النشأة النبوية',
    icon: '⭐',
    trigger: BadgeTrigger(
      type: BadgeTriggerType.chapterComplete,
      eventRange: [4, 11],
    ),
  ),
  BadgeDefinition(
    id: 'steadfast_in_mecca',
    name: 'Steadfast in Mecca',
    nameAr: 'الثابت في مكة',
    description: 'You endured the Meccan struggle',
    descriptionAr: 'صبرت على ابتلاء مكة',
    icon: '🕋',
    trigger: BadgeTrigger(
      type: BadgeTriggerType.chapterComplete,
      eventRange: [12, 22],
    ),
  ),
  BadgeDefinition(
    id: 'guardian_of_legacy',
    name: 'Guardian of the Legacy',
    nameAr: 'حارس الإرث',
    description: 'You witnessed the rise of the community',
    descriptionAr: 'شهدت قيام الأمة',
    icon: '🏛️',
    trigger: BadgeTrigger(
      type: BadgeTriggerType.chapterComplete,
      eventRange: [23, 36],
    ),
  ),
  BadgeDefinition(
    id: 'seeker_of_truth',
    name: 'Seeker of Truth',
    nameAr: 'طالب الحق',
    description: 'You completed 10 events',
    descriptionAr: 'أكملت 10 أحداث',
    icon: '📜',
    trigger: BadgeTrigger(
      type: BadgeTriggerType.eventCount,
      value: 10,
    ),
  ),
  BadgeDefinition(
    id: 'the_rawi',
    name: 'The Rawi',
    nameAr: 'الراوي',
    description: 'You witnessed the entire Prophetic journey',
    descriptionAr: 'شهدت رحلة النبوة كاملة',
    icon: '👑',
    trigger: BadgeTrigger(
      type: BadgeTriggerType.allEvents,
      value: 36,
    ),
  ),
];
