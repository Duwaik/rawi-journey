/// Pre-scripted companion dialogue lines organized by trigger type.
/// Each trigger has a list of lines in EN and AR, cycled through sequentially.
class CompanionDialogue {
  CompanionDialogue._();

  /// Idle — no hotspots discovered yet, player hasn't moved.
  static const idleStart = <DialogueLine>[
    DialogueLine('idle_01', 'The path awaits... try the joystick.', 'الطريق ينتظر... جرّب عصا التحكم.'),
    DialogueLine('idle_02', 'Move forward, companion.', 'تقدّم يا رفيق.'),
    DialogueLine('idle_03', 'History is waiting to be witnessed.', 'التاريخ ينتظر من يشهده.'),
    DialogueLine('idle_04', 'Use the joystick to explore.', 'استخدم عصا التحكم للاستكشاف.'),
  ];

  /// Idle — near an undiscovered hotspot.
  static const idleNearHotspot = <DialogueLine>[
    DialogueLine('idle_04', 'Something glows nearby...', 'شيء يتوهج بالقرب...'),
    DialogueLine('idle_05', 'Look — a point of interest.', 'انظر — نقطة اهتمام.'),
    DialogueLine('idle_06', 'There is something here worth seeing.', 'هناك شيء هنا يستحق المشاهدة.'),
  ];

  /// Idle — mid-journey, 1+ hotspots done.
  static const idleMidJourney = <DialogueLine>[
    DialogueLine('idle_05', 'The journey continues forward.', 'الرحلة تستمر للأمام.'),
    DialogueLine('idle_06', 'There is more to witness ahead.', 'هناك المزيد لتشهده أمامك.'),
    DialogueLine('idle_03', 'Keep moving, companion.', 'واصل التقدم يا رفيق.'),
    DialogueLine('idle_02', 'The path calls...', 'الطريق ينادي...'),
  ];

  /// After dismissing a discovery panel.
  static const postDiscovery = <DialogueLine>[
    DialogueLine('post_01', 'Onward...', 'هيا...'),
    DialogueLine('post_02', 'There is more to witness.', 'هناك المزيد لتشهده.'),
    DialogueLine('post_03', 'The journey continues.', 'الرحلة تستمر.'),
    DialogueLine('post_01', 'Come, let us see what lies ahead.', 'تعال، لنرَ ما ينتظرنا.'),
  ];

  /// Re-tapping a completed hotspot (3rd time).
  static const revisitWarn = <DialogueLine>[
    DialogueLine('revisit_01', "You've witnessed this. The path ahead holds more...", 'شهدت هذا. الطريق أمامك يحمل المزيد...'),
    DialogueLine('revisit_01', 'This moment has been preserved. Move on.', 'هذه اللحظة حُفظت. تقدّم.'),
  ];

  /// Re-tapping a completed hotspot (4th+ time).
  static const revisitFirm = <DialogueLine>[
    DialogueLine('revisit_02', 'The journey awaits, companion.', 'الرحلة بانتظارك يا رفيق.'),
    DialogueLine('revisit_02', 'Forward — there is still much to see.', 'للأمام — لا يزال هناك الكثير لتراه.'),
  ];

  /// All hotspots done, before choice phase.
  static const allDone = <DialogueLine>[
    DialogueLine('alldone_01', 'A moment of reflection approaches...', 'لحظة تأمل تقترب...'),
    DialogueLine('alldone_02', 'You have witnessed everything. Now — choose.', 'شهدت كل شيء. الآن — اختر.'),
  ];

  /// Get a line from a list, cycling by index.
  static String get(List<DialogueLine> lines, int index, {required bool isAr}) {
    final line = lines[index % lines.length];
    return isAr ? line.ar : line.en;
  }

  /// Get line ID for VO file lookup.
  static String getId(List<DialogueLine> lines, int index) {
    return lines[index % lines.length].id;
  }
}

class DialogueLine {
  final String id;
  final String en;
  final String ar;
  const DialogueLine(this.id, this.en, this.ar);
}
