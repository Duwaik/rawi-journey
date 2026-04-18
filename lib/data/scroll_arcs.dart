/// B9: 20 story-arc scrolls grouping the 155 events into narrative chapters.
/// Each arc is rendered as a rolled scroll that "unrolls" when all its
/// events are completed. Partially completed arcs show progress.
class ScrollArc {
  final int index; // 1..20
  final int firstEvent;
  final int lastEvent; // inclusive
  final String titleEn;
  final String titleAr;
  final int module; // 1..4

  const ScrollArc({
    required this.index,
    required this.firstEvent,
    required this.lastEvent,
    required this.titleEn,
    required this.titleAr,
    required this.module,
  });

  int get eventCount => lastEvent - firstEvent + 1;
  bool contains(int globalOrder) =>
      globalOrder >= firstEvent && globalOrder <= lastEvent;
}

const List<ScrollArc> scrollArcs = [
  // Module 1 — The Prophetic Dawn (Events 1–47)
  ScrollArc(index: 1, firstEvent: 1, lastEvent: 5, titleEn: 'Before the Light', titleAr: 'قبل النور', module: 1),
  ScrollArc(index: 2, firstEvent: 6, lastEvent: 10, titleEn: "The Orphan's Path", titleAr: 'درب اليتيم', module: 1),
  ScrollArc(index: 3, firstEvent: 11, lastEvent: 14, titleEn: 'The First Revelation', titleAr: 'الوحي الأوّل', module: 1),
  ScrollArc(index: 4, firstEvent: 15, lastEvent: 22, titleEn: 'The Secret Call & Persecution', titleAr: 'الدعوة السرّية والابتلاء', module: 1),
  ScrollArc(index: 5, firstEvent: 23, lastEvent: 28, titleEn: 'Resilience & Boycott', titleAr: 'الصمود والحصار', module: 1),
  ScrollArc(index: 6, firstEvent: 29, lastEvent: 34, titleEn: 'The Year of Sorrow & New Hope', titleAr: 'عام الحزن وبوادر الأمل', module: 1),
  ScrollArc(index: 7, firstEvent: 35, lastEvent: 42, titleEn: 'The Road to Medina', titleAr: 'الطريق إلى المدينة', module: 1),
  ScrollArc(index: 8, firstEvent: 43, lastEvent: 47, titleEn: 'The Hijrah', titleAr: 'الهجرة', module: 1),
  // Module 2 — The Community Rises (Events 48–82)
  ScrollArc(index: 9, firstEvent: 48, lastEvent: 55, titleEn: 'Building the City', titleAr: 'بناء المدينة', module: 2),
  ScrollArc(index: 10, firstEvent: 56, lastEvent: 63, titleEn: 'The First Battles', titleAr: 'المعارك الأولى', module: 2),
  ScrollArc(index: 11, firstEvent: 64, lastEvent: 72, titleEn: 'Trials After Badr', titleAr: 'محن ما بعد بدر', module: 2),
  ScrollArc(index: 12, firstEvent: 73, lastEvent: 82, titleEn: 'The Trench & Beyond', titleAr: 'الخندق وما بعده', module: 2),
  // Module 3 — The Turning Tide (Events 83–120)
  ScrollArc(index: 13, firstEvent: 83, lastEvent: 90, titleEn: 'Hudaybiyah & Peace', titleAr: 'الحديبية والصلح', module: 3),
  ScrollArc(index: 14, firstEvent: 91, lastEvent: 100, titleEn: 'Expansion of the Message', titleAr: 'انتشار الرسالة', module: 3),
  ScrollArc(index: 15, firstEvent: 101, lastEvent: 110, titleEn: 'The Conquest Approaches', titleAr: 'اقتراب الفتح', module: 3),
  ScrollArc(index: 16, firstEvent: 111, lastEvent: 120, titleEn: 'The Liberation of Mecca', titleAr: 'فتح مكّة', module: 3),
  // Module 4 — The Final Chapter (Events 121–155)
  ScrollArc(index: 17, firstEvent: 121, lastEvent: 130, titleEn: 'After the Conquest', titleAr: 'بعد الفتح', module: 4),
  ScrollArc(index: 18, firstEvent: 131, lastEvent: 140, titleEn: 'The Farewell Year', titleAr: 'عام الوداع', module: 4),
  ScrollArc(index: 19, firstEvent: 141, lastEvent: 148, titleEn: 'The Final Days', titleAr: 'الأيّام الأخيرة', module: 4),
  ScrollArc(index: 20, firstEvent: 149, lastEvent: 155, titleEn: 'The Departure', titleAr: 'الرحيل', module: 4),
];

/// Returns the arc that contains [globalOrder], or null if out of range.
ScrollArc? arcForEvent(int globalOrder) {
  for (final a in scrollArcs) {
    if (a.contains(globalOrder)) return a;
  }
  return null;
}

const Map<int, ({String en, String ar})> moduleTitles = {
  1: (en: 'The Prophetic Dawn', ar: 'الفجر النبوي'),
  2: (en: 'The Community Rises', ar: 'نهوض الأمّة'),
  3: (en: 'The Turning Tide', ar: 'تحوّل المدّ'),
  4: (en: 'The Final Chapter', ar: 'الفصل الأخير'),
};
