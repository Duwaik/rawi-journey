/// A recall challenge that appears before certain events.
/// The user must answer correctly to proceed ("unlock the threshold").
class ThresholdChallenge {
  /// This threshold appears before this event's globalOrder.
  final int beforeEventOrder;

  /// Question text (EN + AR).
  final String question;
  final String questionAr;

  /// 3 answer options.
  final List<String> options;
  final List<String> optionsAr;

  /// Index of the correct answer (0-based).
  final int correctIndex;

  /// Hint shown on wrong answer: "Think back to: [event title]"
  final String hintEventTitle;
  final String hintEventTitleAr;

  const ThresholdChallenge({
    required this.beforeEventOrder,
    required this.question,
    required this.questionAr,
    required this.options,
    required this.optionsAr,
    required this.correctIndex,
    required this.hintEventTitle,
    required this.hintEventTitleAr,
  });
}
