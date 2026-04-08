/// Appears every 25 events. Shows the chain of transmission from
/// event → sahabi → scholar → 1400 years → the user.
class ChainMoment {
  /// Appears after this event's globalOrder (25, 50, 75, 100, 125, 155).
  final int afterEventOrder;

  final String eventTitle;
  final String eventTitleAr;

  /// The sahabi who narrated this part of the story.
  final String sahabiName;
  final String sahabiNameAr;

  /// The scholar who recorded it.
  final String scholarName;
  final String scholarNameAr;

  /// Source book (e.g., "Sahih Muslim").
  final String sourceBook;

  /// Powerful quote for the share card (deferred).
  final String shareQuote;
  final String shareQuoteAr;

  const ChainMoment({
    required this.afterEventOrder,
    required this.eventTitle,
    required this.eventTitleAr,
    required this.sahabiName,
    required this.sahabiNameAr,
    required this.scholarName,
    required this.scholarNameAr,
    required this.sourceBook,
    required this.shareQuote,
    required this.shareQuoteAr,
  });
}
