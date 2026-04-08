/// Cross-event quiz shown after completing all events in an era.
/// 5-7 questions testing connections between events.
class ChapterReview {
  final int afterEventOrder;
  final String eraTitle;
  final String eraTitleAr;
  final List<ReviewQuestion> questions;

  const ChapterReview({
    required this.afterEventOrder,
    required this.eraTitle,
    required this.eraTitleAr,
    required this.questions,
  });
}

class ReviewQuestion {
  final String question;
  final String questionAr;
  final List<String> options;
  final List<String> optionsAr;
  final int correctIndex;
  final String explanation;
  final String explanationAr;
  final String sourceRef;
  final String sourceRefAr;

  const ReviewQuestion({
    required this.question,
    required this.questionAr,
    required this.options,
    required this.optionsAr,
    required this.correctIndex,
    required this.explanation,
    required this.explanationAr,
    required this.sourceRef,
    required this.sourceRefAr,
  });
}
