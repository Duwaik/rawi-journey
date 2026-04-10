/// A single line in the Rawi's Scroll — one per completed event.
class ScrollEntry {
  final String eventId;
  final int globalOrder;
  final String lineEn;
  final String lineAr;

  const ScrollEntry({
    required this.eventId,
    required this.globalOrder,
    required this.lineEn,
    required this.lineAr,
  });
}
