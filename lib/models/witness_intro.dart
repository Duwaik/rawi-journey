/// Cinematic text crawl shown before major events.
/// 3-4 lines fade in sequentially over ~15 seconds.
/// Sets emotional weight before the scene begins.
class WitnessIntro {
  /// English lines, shown one at a time.
  final List<String> lines;

  /// Arabic lines, shown one at a time.
  final List<String> linesAr;

  const WitnessIntro({
    required this.lines,
    required this.linesAr,
  });
}
