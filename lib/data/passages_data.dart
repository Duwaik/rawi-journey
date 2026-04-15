import '../models/passage_moment.dart';

/// R20 Part E — The 5 Passage moments across the 155-event Seerah.
/// Rare, weighty, memorable. Each plays once after a pivotal event.
const List<PassageMoment> _passages = [
  PassageMoment(
    afterEvent: 14,
    titleEn: 'From Mortal to Messenger',
    titleAr: 'من بشرٍ إلى رسول',
    quoteEn: 'Read, in the name of your Lord who created.',
    quoteAr: 'اقرأ باسم ربّك الذي خلق',
    quoteSource: 'Al-Alaq 96:1',
  ),
  PassageMoment(
    afterEvent: 42,
    titleEn: 'The Road to a New Home',
    titleAr: 'الطريق إلى دارٍ جديدة',
    quoteEn: 'Do not grieve, indeed Allah is with us.',
    quoteAr: 'لا تحزن إنّ الله معنا',
    quoteSource: 'At-Tawbah 9:40',
  ),
  PassageMoment(
    afterEvent: 47,
    titleEn: 'The Dawn is Complete',
    titleAr: 'اكتمل الفجر',
    quoteEn:
        'And those who emigrated for Allah after being wronged, We will surely settle them in a good place in this world.',
    quoteAr:
        'والذين هاجروا في الله من بعد ما ظُلموا لنبوّئنّهم في الدنيا حسنة',
    quoteSource: 'An-Nahl 16:41',
  ),
  PassageMoment(
    afterEvent: 82,
    titleEn: 'The Tide Turns',
    titleAr: 'تحوّل المدّ',
    quoteEn:
        'And Allah turned back those who disbelieved in their rage, having gained nothing.',
    quoteAr: 'وردّ الله الذين كفروا بغيظهم لم ينالوا خيراً',
    quoteSource: 'Al-Ahzab 33:25',
  ),
  PassageMoment(
    afterEvent: 120,
    titleEn: 'Victory Approaches',
    titleAr: 'النصر يقترب',
    quoteEn: 'When the victory of Allah has come and the conquest.',
    quoteAr: 'إذا جاء نصر الله والفتح',
    quoteSource: 'An-Nasr 110:1',
  ),
];

/// Returns the passage that fires *after* [globalOrder] completes, or null.
PassageMoment? getPassageAfter(int globalOrder) {
  for (final p in _passages) {
    if (p.afterEvent == globalOrder) return p;
  }
  return null;
}
