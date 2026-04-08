import '../models/chain_moment.dart';

/// Chain of Transmission moments — appear after Events 25, 50, 75, 100, 125, 155.
/// Content added as those milestones are reached.
const List<ChainMoment> chainMoments = [
  // Placeholder for Event 25 — content TBD when Early Life + Mecca written
  ChainMoment(
    afterEventOrder: 25,
    eventTitle: 'The Brotherhood — Muakhah',
    eventTitleAr: 'المؤاخاة',
    sahabiName: 'Anas ibn Malik',
    sahabiNameAr: 'أنس بن مالك',
    scholarName: 'Imam al-Bukhari',
    scholarNameAr: 'الإمام البخاري',
    sourceBook: 'Sahih al-Bukhari',
    shareQuote: 'The story lives because someone like you refused to let it die.',
    shareQuoteAr: 'القصة تحيا لأن شخصاً مثلك رفض أن يتركها تموت.',
  ),
];

/// Get the chain moment for a given event, if any.
ChainMoment? getChainAfter(int globalOrder) {
  for (final c in chainMoments) {
    if (c.afterEventOrder == globalOrder) return c;
  }
  return null;
}
