class DhikrCard {
  final String id;
  final String arabicText;
  final String transliteration;
  final String meaningEn;
  final String meaningAr;
  final String? count;
  final String? countAr;
  final String whenToSay;
  final String whenToSayAr;
  final String promiseEn;
  final String promiseAr;
  final String sourceRef;
  final String sourceRefAr;

  const DhikrCard({
    required this.id,
    required this.arabicText,
    required this.transliteration,
    required this.meaningEn,
    required this.meaningAr,
    this.count,
    this.countAr,
    required this.whenToSay,
    required this.whenToSayAr,
    required this.promiseEn,
    required this.promiseAr,
    required this.sourceRef,
    required this.sourceRefAr,
  });
}
