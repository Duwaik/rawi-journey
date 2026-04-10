import '../models/scroll_entry.dart';

/// All 14 scroll entries for M1 events 1-14.
/// Keyed by event ID for O(1) lookup after event completion.
const Map<String, ScrollEntry> scrollEntries = {
  'j_1_1_1': ScrollEntry(
    eventId: 'j_1_1_1',
    globalOrder: 1,
    lineEn:
        'The Ka\u2019bah stood among 360 idols, waiting for the one who would restore it.',
    lineAr:
        '\u0648\u0642\u0641\u062A \u0627\u0644\u0643\u0639\u0628\u0629 \u0628\u064A\u0646 \u0663\u0666\u0660 \u0635\u0646\u0645\u0627\u064B \u062A\u0646\u062A\u0638\u0631 \u0645\u0646 \u064A\u0639\u064A\u062F\u0647\u0627 \u0625\u0644\u0649 \u0623\u0635\u0644\u0647\u0627.',
  ),
  'j_1_1_2': ScrollEntry(
    eventId: 'j_1_1_2',
    globalOrder: 2,
    lineEn:
        'An army of elephants came to destroy the House, but the Lord of the House had other plans.',
    lineAr:
        '\u062C\u0627\u0621 \u062C\u064A\u0634 \u0627\u0644\u0641\u064A\u0644\u0629 \u0644\u064A\u0647\u062F\u0645 \u0627\u0644\u0628\u064A\u062A\u060C \u0644\u0643\u0646 \u0644\u0631\u0628\u0651 \u0627\u0644\u0628\u064A\u062A \u062A\u062F\u0628\u064A\u0631\u064C \u0622\u062E\u0631.',
  ),
  'j_1_2_1': ScrollEntry(
    eventId: 'j_1_2_1',
    globalOrder: 3,
    lineEn:
        'A child was born in Mecca, and the heavens knew what the earth did not yet know.',
    lineAr:
        '\u0648\u064F\u0644\u062F \u0637\u0641\u0644 \u0641\u064A \u0645\u0643\u0629\u060C \u0648\u0627\u0644\u0633\u0645\u0627\u0621 \u062A\u0639\u0644\u0645 \u0645\u0627 \u0644\u0627 \u062A\u0639\u0644\u0645\u0647 \u0627\u0644\u0623\u0631\u0636 \u0628\u0639\u062F.',
  ),
  'j_1_2_2': ScrollEntry(
    eventId: 'j_1_2_2',
    globalOrder: 4,
    lineEn:
        'The poorest woman in her tribe took the orphan no one wanted, and her world overflowed.',
    lineAr:
        '\u0623\u062E\u0630\u062A \u0623\u0641\u0642\u0631 \u0627\u0645\u0631\u0623\u0629 \u0641\u064A \u0642\u0628\u064A\u0644\u062A\u0647\u0627 \u0627\u0644\u064A\u062A\u064A\u0645 \u0627\u0644\u0630\u064A \u0644\u0645 \u064A\u0631\u062F\u0647 \u0623\u062D\u062F\u060C \u0641\u0641\u0627\u0636 \u0639\u0627\u0644\u0645\u0647\u0627 \u0628\u0627\u0644\u062E\u064A\u0631.',
  ),
  'j_m1_005': ScrollEntry(
    eventId: 'j_m1_005',
    globalOrder: 5,
    lineEn:
        'Two figures in white opened his chest, washed his heart, and returned it purer than it had ever been.',
    lineAr:
        '\u0634\u0642\u0651 \u0634\u062E\u0635\u0627\u0646 \u0628\u0627\u0644\u0623\u0628\u064A\u0636 \u0635\u062F\u0631\u0647 \u0648\u063A\u0633\u0644\u0627 \u0642\u0644\u0628\u0647 \u0648\u0623\u0639\u0627\u062F\u0627\u0647 \u0623\u0646\u0642\u0649 \u0645\u0645\u0627 \u0643\u0627\u0646.',
  ),
  'j_m1_006': ScrollEntry(
    eventId: 'j_m1_006',
    globalOrder: 6,
    lineEn:
        'She fell on the road home, and a six-year-old boy walked the rest of the way alone.',
    lineAr:
        '\u0633\u0642\u0637\u062A \u0639\u0644\u0649 \u0637\u0631\u064A\u0642 \u0627\u0644\u0639\u0648\u062F\u0629\u060C \u0648\u0645\u0634\u0649 \u0635\u0628\u064A\u0651 \u0641\u064A \u0627\u0644\u0633\u0627\u062F\u0633\u0629 \u0628\u0642\u064A\u0629 \u0627\u0644\u0637\u0631\u064A\u0642 \u0648\u062D\u062F\u0647.',
  ),
  'j_m1_007': ScrollEntry(
    eventId: 'j_m1_007',
    globalOrder: 7,
    lineEn:
        'The old man kept the boy on his own mat at the Ka\u2019bah, where no grown man dared to sit.',
    lineAr:
        '\u0623\u0628\u0642\u0649 \u0627\u0644\u0634\u064A\u062E \u0627\u0644\u0635\u0628\u064A\u0651 \u0639\u0644\u0649 \u0641\u0631\u0627\u0634\u0647 \u0639\u0646\u062F \u0627\u0644\u0643\u0639\u0628\u0629 \u062D\u064A\u062B \u0644\u0645 \u064A\u062C\u0631\u0624 \u0631\u062C\u0644\u064C \u0628\u0627\u0644\u063A \u0639\u0644\u0649 \u0627\u0644\u062C\u0644\u0648\u0633.',
  ),
  'j_1_2_3': ScrollEntry(
    eventId: 'j_1_2_3',
    globalOrder: 8,
    lineEn:
        'A man with no wealth took a boy with no father and shielded him for forty years.',
    lineAr:
        '\u0631\u062C\u0644 \u0628\u0644\u0627 \u0645\u0627\u0644 \u0623\u062E\u0630 \u0635\u0628\u064A\u0627\u064B \u0628\u0644\u0627 \u0623\u0628 \u0648\u062D\u0645\u0627\u0647 \u0623\u0631\u0628\u0639\u064A\u0646 \u0633\u0646\u0629.',
  ),
  'j_1_2_4': ScrollEntry(
    eventId: 'j_1_2_4',
    globalOrder: 9,
    lineEn:
        'Young men swore that no one would be wronged in their city without someone rising to help.',
    lineAr:
        '\u0623\u0642\u0633\u0645 \u0634\u0628\u0627\u0628\u064C \u0623\u0644\u0627 \u064A\u064F\u0638\u0644\u064E\u0645 \u0623\u062D\u062F\u064C \u0641\u064A \u0645\u062F\u064A\u0646\u062A\u0647\u0645 \u062F\u0648\u0646 \u0623\u0646 \u064A\u0646\u0647\u0636 \u0645\u0646 \u064A\u0646\u0635\u0631\u0647.',
  ),
  'j_m1_010': ScrollEntry(
    eventId: 'j_m1_010',
    globalOrder: 10,
    lineEn:
        'Before he carried a message, he carried a reputation that even his enemies could not deny.',
    lineAr:
        '\u0642\u0628\u0644 \u0623\u0646 \u064A\u062D\u0645\u0644 \u0631\u0633\u0627\u0644\u0629 \u062D\u0645\u0644 \u0633\u0645\u0639\u0629\u064B \u0644\u0645 \u064A\u0633\u062A\u0637\u0639 \u062D\u062A\u0649 \u0623\u0639\u062F\u0627\u0624\u0647 \u0625\u0646\u0643\u0627\u0631\u0647\u0627.',
  ),
  'j_m1_011': ScrollEntry(
    eventId: 'j_m1_011',
    globalOrder: 11,
    lineEn:
        'The wealthiest woman in Mecca chose the man with no wealth, because she saw what money cannot buy.',
    lineAr:
        '\u0627\u062E\u062A\u0627\u0631\u062A \u0623\u063A\u0646\u0649 \u0627\u0645\u0631\u0623\u0629 \u0641\u064A \u0645\u0643\u0629 \u0631\u062C\u0644\u0627\u064B \u0628\u0644\u0627 \u0645\u0627\u0644\u060C \u0644\u0623\u0646\u0647\u0627 \u0631\u0623\u062A \u0645\u0627 \u0644\u0627 \u064A\u064F\u0634\u062A\u0631\u0649 \u0628\u0627\u0644\u0645\u0627\u0644.',
  ),
  'j_1_1_3': ScrollEntry(
    eventId: 'j_1_1_3',
    globalOrder: 12,
    lineEn:
        'The tribes reached for their swords, but a young man spread his cloak and turned war into wisdom.',
    lineAr:
        '\u0645\u062F\u0651\u062A \u0627\u0644\u0642\u0628\u0627\u0626\u0644 \u0623\u064A\u062F\u064A\u0647\u0627 \u0625\u0644\u0649 \u0633\u064A\u0648\u0641\u0647\u0627\u060C \u0644\u0643\u0646 \u0634\u0627\u0628\u0627\u064B \u0628\u0633\u0637 \u0631\u062F\u0627\u0621\u0647 \u0648\u062D\u0648\u0651\u0644 \u0627\u0644\u062D\u0631\u0628 \u0625\u0644\u0649 \u062D\u0643\u0645\u0629.',
  ),
  'j_1_2_6': ScrollEntry(
    eventId: 'j_1_2_6',
    globalOrder: 13,
    lineEn:
        'He left the noise of Mecca and climbed alone toward the silence, searching for what no idol could give.',
    lineAr:
        '\u063A\u0627\u062F\u0631 \u0636\u062C\u064A\u062C \u0645\u0643\u0629 \u0648\u0635\u0639\u062F \u0648\u062D\u062F\u0647 \u0646\u062D\u0648 \u0627\u0644\u0635\u0645\u062A\u060C \u064A\u0628\u062D\u062B \u0639\u0645\u0627 \u0644\u0627 \u064A\u0645\u0646\u062D\u0647 \u0635\u0646\u0645.',
  ),
  'j_1_2_7': ScrollEntry(
    eventId: 'j_1_2_7',
    globalOrder: 14,
    lineEn:
        'The silence of the cave broke, and the first word was: Read.',
    lineAr:
        '\u0627\u0646\u0643\u0633\u0631 \u0635\u0645\u062A \u0627\u0644\u063A\u0627\u0631\u060C \u0648\u0643\u0627\u0646\u062A \u0627\u0644\u0643\u0644\u0645\u0629 \u0627\u0644\u0623\u0648\u0644\u0649: \u0627\u0642\u0631\u0623.',
  ),
};
