/// R20 Part E — "The Passage / المعبر".
///
/// A rare cinematic era-transition moment shown after 5 pivotal events.
/// Not a gate (like Threshold) and not a reward (like Badge). A breath —
/// a full-screen title + quote + continue button.
class PassageMoment {
  final int afterEvent;
  final String titleEn;
  final String titleAr;
  final String quoteEn;
  final String quoteAr;
  final String quoteSource;
  final String? imagePath;
  final String? soundPath;

  const PassageMoment({
    required this.afterEvent,
    required this.titleEn,
    required this.titleAr,
    required this.quoteEn,
    required this.quoteAr,
    required this.quoteSource,
    this.imagePath,
    this.soundPath,
  });
}
