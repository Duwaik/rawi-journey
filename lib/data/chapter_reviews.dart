import '../models/chapter_review.dart';

/// Chapter review quizzes — appear after the final event of each era.
/// Content written after all events in each era are complete.
///
/// Reviews appear after Events: 14, 47, 82, 120, 155
const List<ChapterReview> chapterReviews = [
  // Content TBD after Events 1-14 are all written
];

/// Get the chapter review for a given event, if any.
ChapterReview? getChapterReviewAfter(int globalOrder) {
  for (final r in chapterReviews) {
    if (r.afterEventOrder == globalOrder) return r;
  }
  return null;
}
