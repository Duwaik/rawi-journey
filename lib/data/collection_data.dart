import '../models/collection_item.dart';

/// Collection items — unlocked after specific events.
/// Roughly every 3-4 events. Content added as events are written.
const List<CollectionItem> allCollectionItems = [
  CollectionItem(
    id: 'kaabah_house',
    name: 'The Ka\'bah — House of Ibrahim',
    nameAr: 'الكعبة — بيت إبراهيم',
    description: 'Built by Prophet Ibrahim and his son Ismail as a house of the One God.',
    descriptionAr: 'بناها النبي إبراهيم وابنه إسماعيل بيتاً للإله الواحد.',
    category: 'places',
    unlockedByEvent: 2,
    sourceRef: 'Quran 2:127',
    sourceRefAr: 'القرآن 2:127',
  ),
  CollectionItem(
    id: 'halimah',
    name: 'Halimah al-Sa\'diyyah',
    nameAr: 'حليمة السعدية',
    description: 'The blessed nurse who took the orphan no one wanted.',
    descriptionAr: 'المرضعة المباركة التي أخذت اليتيم الذي لم يرده أحد.',
    category: 'people',
    unlockedByEvent: 4,
    sourceRef: 'Al-Raheeq Al-Makhtum, Ch. 5',
    sourceRefAr: 'الرحيق المختوم، الفصل 5',
  ),
  CollectionItem(
    id: 'seat_muttalib',
    name: 'The Seat of Abd al-Muttalib',
    nameAr: 'فراش عبد المطلب',
    description: 'The seat by the Ka\'bah that no one dared sit on — except the orphan boy.',
    descriptionAr: 'الفراش عند الكعبة الذي لم يجرؤ أحد على الجلوس عليه — إلا الصبي اليتيم.',
    category: 'artifacts',
    unlockedByEvent: 7,
    sourceRef: 'Ibn Hisham',
    sourceRefAr: 'ابن هشام',
  ),
  CollectionItem(
    id: 'road_syria',
    name: 'The Road to Syria',
    nameAr: 'طريق الشام',
    description: 'The first time Muhammad ﷺ saw the world beyond Mecca — with Abu Talib.',
    descriptionAr: 'أول مرة يرى فيها محمد ﷺ العالم خارج مكة — مع أبي طالب.',
    category: 'places',
    unlockedByEvent: 8,
    sourceRef: 'Sahih Bukhari #3884',
    sourceRefAr: 'صحيح البخاري #3884',
  ),
  CollectionItem(
    id: 'black_stone',
    name: 'The Black Stone',
    nameAr: 'الحجر الأسود',
    description: 'Placed by Muhammad ﷺ with wisdom that united the tribes.',
    descriptionAr: 'وضعه محمد ﷺ بحكمة وحّدت القبائل.',
    category: 'artifacts',
    unlockedByEvent: 12,
    sourceRef: 'Al-Raheeq Al-Makhtum, Ch. 6',
    sourceRefAr: 'الرحيق المختوم، الفصل 6',
  ),
];

/// Get collection items unlocked by a specific event.
List<CollectionItem> getCollectionItemsFor(int globalOrder) {
  return allCollectionItems
      .where((item) => item.unlockedByEvent == globalOrder)
      .toList();
}
