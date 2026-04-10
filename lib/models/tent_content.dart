class TentContent {
  final String id;
  final String type; // 'hadith', 'history', 'dhikr_reminder', 'teaser'
  final String textEn;
  final String textAr;
  final String? sourceRef;
  final String? linkedEventId;

  const TentContent({
    required this.id,
    required this.type,
    required this.textEn,
    required this.textAr,
    this.sourceRef,
    this.linkedEventId,
  });
}
