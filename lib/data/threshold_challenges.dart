import '../models/threshold_challenge.dart';

/// Threshold challenges — appear before specific events.
/// Roughly every 5-7 events. User must answer a recall question
/// from a previous event to proceed.
///
/// In M1, thresholds appear before Events: 6, 12, 18, 25, 31, 37, 43.
/// Content added as events are written.
const List<ThresholdChallenge> thresholdChallenges = [
  // Before Event 6 (Death of Aminah) — tests recall from Events 1-5
  ThresholdChallenge(
    beforeEventOrder: 6,
    question: 'In Event 2, Abd al-Muttalib went to negotiate with Abraha. What did he ask for?',
    questionAr: 'في الحدث 2، ذهب عبد المطلب للتفاوض مع أبرهة. ماذا طلب؟',
    options: [
      'Protection for the Ka\'bah',
      'His camels back — and said the Ka\'bah has a Lord who will protect it',
      'Safe passage for the women and children',
    ],
    optionsAr: [
      'حماية الكعبة',
      'إبله — وقال إن للكعبة رباً يحميها',
      'ممراً آمناً للنساء والأطفال',
    ],
    correctIndex: 1,
    hintEventTitle: 'The Year of the Elephant',
    hintEventTitleAr: 'عام الفيل',
  ),

  // Before Event 12 (The Black Stone) — tests recall from Events 1-11
  ThresholdChallenge(
    beforeEventOrder: 12,
    question: 'What name did Abd al-Muttalib give his grandson, and what does it mean?',
    questionAr: 'ما الاسم الذي أعطاه عبد المطلب لحفيده، وما معناه؟',
    options: [
      'Ahmad — "The Most Praised"',
      'Muhammad — "The Praised One"',
      'Abdullah — "Servant of Allah"',
    ],
    optionsAr: [
      'أحمد — "الأكثر حمداً"',
      'محمد — "المحمود"',
      'عبد الله — "عبد الله"',
    ],
    correctIndex: 1,
    hintEventTitle: 'The Birth of the Prophet ﷺ',
    hintEventTitleAr: 'مولد النبي ﷺ',
  ),
];

/// Get the threshold challenge for a given event, if any.
ThresholdChallenge? getThresholdBefore(int globalOrder) {
  for (final t in thresholdChallenges) {
    if (t.beforeEventOrder == globalOrder) return t;
  }
  return null;
}
