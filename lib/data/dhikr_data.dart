import '../models/dhikr_card.dart';

/// Dhikr cards keyed by event ID. Each event unlocks one unique dhikr.
const Map<String, DhikrCard> dhikrCards = {
  // ── Event 1: Arabia Before the Light ──────────────────────────────────
  'j_1_1_1': DhikrCard(
    id: 'j_1_1_1',
    arabicText:
        '\u0644\u0627 \u0625\u0644\u0647 \u0625\u0644\u0627 \u0627\u0644\u0644\u0647 \u0648\u062D\u062F\u0647 \u0644\u0627 \u0634\u0631\u064A\u0643 \u0644\u0647\u060C \u0644\u0647 \u0627\u0644\u0645\u064F\u0644\u0643 \u0648\u0644\u0647 \u0627\u0644\u062D\u0645\u062F\u060C \u0648\u0647\u0648 \u0639\u0644\u0649 \u0643\u0644 \u0634\u064A\u0621 \u0642\u062F\u064A\u0631',
    transliteration:
        'La ilaha illallahu wahdahu la shareeka lah, lahul-mulku wa lahul-hamdu, wa huwa \'ala kulli shay\'in qadeer',
    meaningEn:
        'There is no god but Allah alone, with no partner. His is the dominion and His is the praise, and He is able to do all things.',
    meaningAr:
        '\u0644\u0627 \u0625\u0644\u0647 \u0625\u0644\u0627 \u0627\u0644\u0644\u0647 \u0648\u062D\u062F\u0647 \u0644\u0627 \u0634\u0631\u064A\u0643 \u0644\u0647\u060C \u0644\u0647 \u0627\u0644\u0645\u064F\u0644\u0643 \u0648\u0644\u0647 \u0627\u0644\u062D\u0645\u062F\u060C \u0648\u0647\u0648 \u0639\u0644\u0649 \u0643\u0644 \u0634\u064A\u0621 \u0642\u062F\u064A\u0631',
    count: '100 times daily',
    countAr: '\u0661\u0660\u0660 \u0645\u0631\u0629 \u064A\u0648\u0645\u064A\u0627\u064B',
    whenToSay: 'Every morning',
    whenToSayAr: '\u0643\u0644 \u0635\u0628\u0627\u062D',
    promiseEn:
        'Whoever says this 100 times a day, it is as if he freed 10 slaves, 100 good deeds are written for him, 100 sins are erased, and he is protected from the Shaytan for the rest of that day.',
    promiseAr:
        '\u0645\u0646 \u0642\u0627\u0644\u0647\u0627 \u0645\u0626\u0629 \u0645\u0631\u0629 \u0641\u064A \u064A\u0648\u0645 \u0643\u0627\u0646\u062A \u0644\u0647 \u0639\u064E\u062F\u0644 \u0639\u0634\u0631 \u0631\u0642\u0627\u0628\u060C \u0648\u0643\u064F\u062A\u0628\u062A \u0644\u0647 \u0645\u0626\u0629 \u062D\u0633\u0646\u0629\u060C \u0648\u0645\u064F\u062D\u064A\u062A \u0639\u0646\u0647 \u0645\u0626\u0629 \u0633\u064A\u0626\u0629\u060C \u0648\u0643\u0627\u0646\u062A \u0644\u0647 \u062D\u0631\u0632\u0627\u064B \u0645\u0646 \u0627\u0644\u0634\u064A\u0637\u0627\u0646 \u064A\u0648\u0645\u0647 \u0630\u0644\u0643 \u062D\u062A\u0649 \u064A\u0645\u0633\u064A.',
    sourceRef: 'Sahih Bukhari 6403',
    sourceRefAr: '\u0635\u062D\u064A\u062D \u0627\u0644\u0628\u062E\u0627\u0631\u064A \u0666\u0664\u0660\u0663',
  ),

  // ── Event 2: The Year of the Elephant ─────────────────────────────────
  'j_1_1_2': DhikrCard(
    id: 'j_1_1_2',
    arabicText:
        '\u062D\u064E\u0633\u0652\u0628\u064F\u0646\u064E\u0627 \u0627\u0644\u0644\u0651\u064E\u0647\u064F \u0648\u064E\u0646\u0650\u0639\u0652\u0645\u064E \u0627\u0644\u0652\u0648\u064E\u0643\u0650\u064A\u0644\u064F',
    transliteration: 'Hasbunallahu wa ni\'mal-wakeel',
    meaningEn:
        'Allah is sufficient for us, and He is the best Disposer of affairs.',
    meaningAr:
        '\u062D\u0633\u0628\u0646\u0627 \u0627\u0644\u0644\u0647 \u0648\u0646\u0639\u0645 \u0627\u0644\u0648\u0643\u064A\u0644',
    count: 'Once, with conviction',
    countAr: '\u0645\u0631\u0629 \u0648\u0627\u062D\u062F\u0629 \u0628\u064A\u0642\u064A\u0646',
    whenToSay: 'When you feel afraid or face something overwhelming',
    whenToSayAr: '\u0639\u0646\u062F \u0627\u0644\u062E\u0648\u0641 \u0623\u0648 \u0645\u0648\u0627\u062C\u0647\u0629 \u0623\u0645\u0631 \u0639\u0638\u064A\u0645',
    promiseEn:
        'Ibrahim (peace be upon him) said it when he was thrown into the fire. Muhammad \uFDFA said it when he was told: \'The people have gathered against you, so fear them.\' But it only increased them in faith, and they said: \'Allah is sufficient for us, and He is the best Disposer of affairs.\'',
    promiseAr:
        '\u0642\u0627\u0644\u0647\u0627 \u0625\u0628\u0631\u0627\u0647\u064A\u0645 \u0639\u0644\u064A\u0647 \u0627\u0644\u0633\u0644\u0627\u0645 \u062D\u064A\u0646 \u0623\u0644\u0642\u064A \u0641\u064A \u0627\u0644\u0646\u0627\u0631\u060C \u0648\u0642\u0627\u0644\u0647\u0627 \u0645\u062D\u0645\u062F \uFDFA \u062D\u064A\u0646 \u0642\u064A\u0644 \u0644\u0647: \'\u0625\u0646 \u0627\u0644\u0646\u0627\u0633 \u0642\u062F \u062C\u0645\u0639\u0648\u0627 \u0644\u0643\u0645 \u0641\u0627\u062E\u0634\u0648\u0647\u0645.\' \u0641\u0632\u0627\u062F\u0647\u0645 \u0625\u064A\u0645\u0627\u0646\u0627\u064B \u0648\u0642\u0627\u0644\u0648\u0627: \u062D\u0633\u0628\u0646\u0627 \u0627\u0644\u0644\u0647 \u0648\u0646\u0639\u0645 \u0627\u0644\u0648\u0643\u064A\u0644.',
    sourceRef: 'Sahih Bukhari 4563',
    sourceRefAr: '\u0635\u062D\u064A\u062D \u0627\u0644\u0628\u062E\u0627\u0631\u064A \u0664\u0665\u0666\u0663',
  ),

  // ── Event 3: Birth of the Prophet ﷺ ──────────────────────────────────
  'j_1_2_1': DhikrCard(
    id: 'j_1_2_1',
    arabicText:
        '\u0627\u0644\u0644\u0651\u064E\u0647\u064F\u0645\u0651\u064E \u0635\u064E\u0644\u0651\u0650 \u0648\u064E\u0633\u064E\u0644\u0651\u0650\u0645\u0652 \u0639\u064E\u0644\u0649\u0670 \u0646\u064E\u0628\u0650\u064A\u0651\u0650\u0646\u064E\u0627 \u0645\u064F\u062D\u064E\u0645\u0651\u064E\u062F\u064D',
    transliteration: 'Allahumma salli wa sallim \'ala nabiyyina Muhammad',
    meaningEn:
        'O Allah, send blessings and peace upon our Prophet Muhammad.',
    meaningAr:
        '\u0627\u0644\u0644\u0647\u0645 \u0635\u0644\u0651 \u0648\u0633\u0644\u0651\u0645 \u0639\u0644\u0649 \u0646\u0628\u064A\u0646\u0627 \u0645\u062D\u0645\u062F',
    count: '10 times',
    countAr: '\u0661\u0660 \u0645\u0631\u0627\u062A',
    whenToSay: 'Whenever you hear his name \uFDFA, and on Fridays',
    whenToSayAr: '\u0639\u0646\u062F \u0633\u0645\u0627\u0639 \u0627\u0633\u0645\u0647 \uFDFA \u0648\u064A\u0648\u0645 \u0627\u0644\u062C\u0645\u0639\u0629',
    promiseEn:
        'Whoever sends blessings upon me once, Allah sends ten blessings upon him.',
    promiseAr:
        '\u0645\u0646 \u0635\u0644\u0651\u0649 \u0639\u0644\u064A\u0651 \u0635\u0644\u0627\u0629 \u0648\u0627\u062D\u062F\u0629 \u0635\u0644\u0651\u0649 \u0627\u0644\u0644\u0647 \u0639\u0644\u064A\u0647 \u0628\u0647\u0627 \u0639\u0634\u0631\u0627\u064B.',
    sourceRef: 'Sahih Muslim 408',
    sourceRefAr: '\u0635\u062D\u064A\u062D \u0645\u0633\u0644\u0645 \u0664\u0660\u0668',
  ),

  // ── Event 4: The Nursing Years: Halimah ───────────────────────────────
  'j_1_2_2': DhikrCard(
    id: 'j_1_2_2',
    arabicText:
        '\u0633\u064F\u0628\u0652\u062D\u064E\u0627\u0646\u064E \u0627\u0644\u0644\u0651\u064E\u0647\u0650 \u0648\u064E\u0628\u0650\u062D\u064E\u0645\u0652\u062F\u0650\u0647\u0650\u060C \u0633\u064F\u0628\u0652\u062D\u064E\u0627\u0646\u064E \u0627\u0644\u0644\u0651\u064E\u0647\u0650 \u0627\u0644\u0652\u0639\u064E\u0638\u0650\u064A\u0645\u0650',
    transliteration: 'Subhanallahi wa bihamdihi, Subhanallahil-\'Azeem',
    meaningEn:
        'Glory be to Allah and praise Him. Glory be to Allah, the Magnificent.',
    meaningAr:
        '\u0633\u0628\u062D\u0627\u0646 \u0627\u0644\u0644\u0647 \u0648\u0628\u062D\u0645\u062F\u0647\u060C \u0633\u0628\u062D\u0627\u0646 \u0627\u0644\u0644\u0647 \u0627\u0644\u0639\u0638\u064A\u0645',
    count: null,
    countAr: null,
    whenToSay: 'Anytime \u2014 morning, evening, between tasks',
    whenToSayAr: '\u0641\u064A \u0623\u064A \u0648\u0642\u062A \u2014 \u0635\u0628\u0627\u062D\u0627\u064B\u060C \u0645\u0633\u0627\u0621\u064B\u060C \u0628\u064A\u0646 \u0627\u0644\u0645\u0647\u0627\u0645',
    promiseEn:
        'Two words: light on the tongue, heavy on the Scale, beloved to the Most Merciful.',
    promiseAr:
        '\u0643\u0644\u0645\u062A\u0627\u0646 \u062E\u0641\u064A\u0641\u062A\u0627\u0646 \u0639\u0644\u0649 \u0627\u0644\u0644\u0633\u0627\u0646\u060C \u062B\u0642\u064A\u0644\u062A\u0627\u0646 \u0641\u064A \u0627\u0644\u0645\u064A\u0632\u0627\u0646\u060C \u062D\u0628\u064A\u0628\u062A\u0627\u0646 \u0625\u0644\u0649 \u0627\u0644\u0631\u062D\u0645\u0646: \u0633\u0628\u062D\u0627\u0646 \u0627\u0644\u0644\u0647 \u0648\u0628\u062D\u0645\u062F\u0647\u060C \u0633\u0628\u062D\u0627\u0646 \u0627\u0644\u0644\u0647 \u0627\u0644\u0639\u0638\u064A\u0645.',
    sourceRef: 'Sahih Bukhari 6682, Sahih Muslim 2694',
    sourceRefAr: '\u0635\u062D\u064A\u062D \u0627\u0644\u0628\u062E\u0627\u0631\u064A \u0666\u0666\u0668\u0662\u060C \u0635\u062D\u064A\u062D \u0645\u0633\u0644\u0645 \u0662\u0666\u0669\u0664',
  ),

  // ── Event 5: The Opening of the Chest ─────────────────────────────────
  'j_m1_005': DhikrCard(
    id: 'j_m1_005',
    arabicText:
        '\u0627\u0644\u0644\u0651\u064E\u0647\u064F\u0645\u0651\u064E \u0623\u064E\u0646\u0652\u062A\u064E \u0631\u064E\u0628\u0651\u0650\u064A \u0644\u0627 \u0625\u0650\u0644\u064E\u0647\u064E \u0625\u0650\u0644\u0627 \u0623\u064E\u0646\u0652\u062A\u064E\u060C \u062E\u064E\u0644\u064E\u0642\u0652\u062A\u064E\u0646\u0650\u064A \u0648\u064E\u0623\u064E\u0646\u064E\u0627 \u0639\u064E\u0628\u0652\u062F\u064F\u0643\u064E\u060C \u0648\u064E\u0623\u064E\u0646\u064E\u0627 \u0639\u064E\u0644\u0649\u0670 \u0639\u064E\u0647\u0652\u062F\u0650\u0643\u064E \u0648\u064E\u0648\u064E\u0639\u0652\u062F\u0650\u0643\u064E \u0645\u064E\u0627 \u0627\u0633\u0652\u062A\u064E\u0637\u064E\u0639\u0652\u062A\u064F\u060C \u0623\u064E\u0639\u064F\u0648\u0630\u064F \u0628\u0650\u0643\u064E \u0645\u0650\u0646\u0652 \u0634\u064E\u0631\u0651\u0650 \u0645\u064E\u0627 \u0635\u064E\u0646\u064E\u0639\u0652\u062A\u064F\u060C \u0623\u064E\u0628\u064F\u0648\u0621\u064F \u0644\u064E\u0643\u064E \u0628\u0650\u0646\u0650\u0639\u0652\u0645\u064E\u062A\u0650\u0643\u064E \u0639\u064E\u0644\u064E\u064A\u0651\u064E\u060C \u0648\u064E\u0623\u064E\u0628\u064F\u0648\u0621\u064F \u0628\u0650\u0630\u064E\u0646\u0652\u0628\u0650\u064A \u0641\u064E\u0627\u063A\u0652\u0641\u0650\u0631\u0652 \u0644\u0650\u064A \u0641\u064E\u0625\u0650\u0646\u0651\u064E\u0647\u064F \u0644\u0627 \u064A\u064E\u063A\u0652\u0641\u0650\u0631\u064F \u0627\u0644\u0630\u0651\u064F\u0646\u064F\u0648\u0628\u064E \u0625\u0650\u0644\u0627 \u0623\u064E\u0646\u0652\u062A\u064E',
    transliteration:
        'Allahumma anta Rabbi la ilaha illa anta, khalaqtani wa ana \'abduka, wa ana \'ala \'ahdika wa wa\'dika mastata\'tu, a\'udhu bika min sharri ma sana\'tu, abu\'u laka bi ni\'matika \'alayya, wa abu\'u bi dhanbi, faghfir li fa innahu la yaghfirudh-dhunuba illa anta',
    meaningEn:
        'O Allah, You are my Lord, there is no god but You. You created me and I am Your servant. I keep Your covenant and promise as best I can. I seek refuge in You from the evil I have done. I acknowledge Your blessings upon me, and I acknowledge my sin, so forgive me \u2014 for none forgives sins but You.',
    meaningAr:
        '\u0627\u0644\u0644\u0647\u0645 \u0623\u0646\u062A \u0631\u0628\u064A \u0644\u0627 \u0625\u0644\u0647 \u0625\u0644\u0627 \u0623\u0646\u062A\u060C \u062E\u0644\u0642\u062A\u0646\u064A \u0648\u0623\u0646\u0627 \u0639\u0628\u062F\u0643\u060C \u0648\u0623\u0646\u0627 \u0639\u0644\u0649 \u0639\u0647\u062F\u0643 \u0648\u0648\u0639\u062F\u0643 \u0645\u0627 \u0627\u0633\u062A\u0637\u0639\u062A\u060C \u0623\u0639\u0648\u0630 \u0628\u0643 \u0645\u0646 \u0634\u0631 \u0645\u0627 \u0635\u0646\u0639\u062A\u060C \u0623\u0628\u0648\u0621 \u0644\u0643 \u0628\u0646\u0639\u0645\u062A\u0643 \u0639\u0644\u064A\u060C \u0648\u0623\u0628\u0648\u0621 \u0628\u0630\u0646\u0628\u064A \u0641\u0627\u063A\u0641\u0631 \u0644\u064A \u0641\u0625\u0646\u0647 \u0644\u0627 \u064A\u063A\u0641\u0631 \u0627\u0644\u0630\u0646\u0648\u0628 \u0625\u0644\u0627 \u0623\u0646\u062A',
    count: 'Once in the morning, once in the evening',
    countAr: '\u0645\u0631\u0629 \u0635\u0628\u0627\u062D\u0627\u064B \u0648\u0645\u0631\u0629 \u0645\u0633\u0627\u0621\u064B',
    whenToSay: 'Morning and evening \u2014 this is Sayyid al-Istighfar',
    whenToSayAr: '\u0635\u0628\u0627\u062D\u0627\u064B \u0648\u0645\u0633\u0627\u0621\u064B \u2014 \u0647\u0630\u0627 \u0633\u064A\u062F \u0627\u0644\u0627\u0633\u062A\u063A\u0641\u0627\u0631',
    promiseEn:
        'Whoever says this during the day with firm belief and dies that day before evening, he is among the people of Paradise. And whoever says it at night with firm belief and dies before morning, he is among the people of Paradise.',
    promiseAr:
        '\u0645\u0646 \u0642\u0627\u0644\u0647\u0627 \u0645\u0646 \u0627\u0644\u0646\u0647\u0627\u0631 \u0645\u0648\u0642\u0646\u0627\u064B \u0628\u0647\u0627 \u0641\u0645\u0627\u062A \u0645\u0646 \u064A\u0648\u0645\u0647 \u0642\u0628\u0644 \u0623\u0646 \u064A\u0645\u0633\u064A \u0641\u0647\u0648 \u0645\u0646 \u0623\u0647\u0644 \u0627\u0644\u062C\u0646\u0629\u060C \u0648\u0645\u0646 \u0642\u0627\u0644\u0647\u0627 \u0645\u0646 \u0627\u0644\u0644\u064A\u0644 \u0648\u0647\u0648 \u0645\u0648\u0642\u0646 \u0628\u0647\u0627 \u0641\u0645\u0627\u062A \u0642\u0628\u0644 \u0623\u0646 \u064A\u0635\u0628\u062D \u0641\u0647\u0648 \u0645\u0646 \u0623\u0647\u0644 \u0627\u0644\u062C\u0646\u0629.',
    sourceRef: 'Sahih Bukhari 6306',
    sourceRefAr: '\u0635\u062D\u064A\u062D \u0627\u0644\u0628\u062E\u0627\u0631\u064A \u0666\u0663\u0660\u0666',
  ),

  // ── Event 6: Death of Aminah ──────────────────────────────────────────
  'j_m1_006': DhikrCard(
    id: 'j_m1_006',
    arabicText:
        '\u0625\u0650\u0646\u0651\u064E\u0627 \u0644\u0650\u0644\u0651\u064E\u0647\u0650 \u0648\u064E\u0625\u0650\u0646\u0651\u064E\u0627 \u0625\u0650\u0644\u064E\u064A\u0652\u0647\u0650 \u0631\u064E\u0627\u062C\u0650\u0639\u064F\u0648\u0646\u064E\u060C \u0627\u0644\u0644\u0651\u064E\u0647\u064F\u0645\u0651\u064E \u0623\u0652\u062C\u064F\u0631\u0652\u0646\u0650\u064A \u0641\u0650\u064A \u0645\u064F\u0635\u0650\u064A\u0628\u064E\u062A\u0650\u064A \u0648\u064E\u0627\u062E\u0652\u0644\u064F\u0641\u0652 \u0644\u0650\u064A \u062E\u064E\u064A\u0652\u0631\u064B\u0627 \u0645\u0650\u0646\u0652\u0647\u064E\u0627',
    transliteration:
        'Inna lillahi wa inna ilayhi raji\'un. Allahumma\'jurni fi musibati wakhluf li khayran minha',
    meaningEn:
        'To Allah we belong and to Him we return. O Allah, reward me in my affliction and replace it with something better.',
    meaningAr:
        '\u0625\u0646\u0627 \u0644\u0644\u0647 \u0648\u0625\u0646\u0627 \u0625\u0644\u064A\u0647 \u0631\u0627\u062C\u0639\u0648\u0646\u060C \u0627\u0644\u0644\u0647\u0645 \u0623\u062C\u0631\u0646\u064A \u0641\u064A \u0645\u0635\u064A\u0628\u062A\u064A \u0648\u0627\u062E\u0644\u0641 \u0644\u064A \u062E\u064A\u0631\u0627\u064B \u0645\u0646\u0647\u0627',
    count: 'Once, whenever affliction strikes',
    countAr: '\u0645\u0631\u0629 \u0648\u0627\u062D\u062F\u0629 \u0639\u0646\u062F \u0627\u0644\u0645\u0635\u064A\u0628\u0629',
    whenToSay:
        'When you lose something or someone, when something goes wrong',
    whenToSayAr: '\u0639\u0646\u062F \u0641\u0642\u062F\u0627\u0646 \u0634\u064A\u0621 \u0623\u0648 \u0634\u062E\u0635\u060C \u0639\u0646\u062F\u0645\u0627 \u064A\u0633\u0648\u0621 \u0623\u0645\u0631',
    promiseEn:
        'No servant is struck by affliction and says this except that Allah rewards him in his affliction and replaces it with something better.',
    promiseAr:
        '\u0645\u0627 \u0645\u0646 \u0639\u0628\u062F \u062A\u0635\u064A\u0628\u0647 \u0645\u0635\u064A\u0628\u0629 \u0641\u064A\u0642\u0648\u0644 \u0630\u0644\u0643 \u0625\u0644\u0627 \u0623\u062C\u0631\u0647 \u0627\u0644\u0644\u0647 \u0641\u064A \u0645\u0635\u064A\u0628\u062A\u0647 \u0648\u0623\u062E\u0644\u0641 \u0644\u0647 \u062E\u064A\u0631\u0627\u064B \u0645\u0646\u0647\u0627.',
    sourceRef: 'Sahih Muslim 918',
    sourceRefAr: '\u0635\u062D\u064A\u062D \u0645\u0633\u0644\u0645 \u0669\u0661\u0668',
  ),

  // ── Event 7: Under the Care of Abd al-Muttalib ────────────────────────
  'j_m1_007': DhikrCard(
    id: 'j_m1_007',
    arabicText: '\u0627\u0644\u0652\u062D\u064E\u0645\u0652\u062F\u064F \u0644\u0650\u0644\u0651\u064E\u0647\u0650',
    transliteration: 'Alhamdulillah',
    meaningEn: 'All praise is due to Allah.',
    meaningAr: '\u0627\u0644\u062D\u0645\u062F \u0644\u0644\u0647',
    count: null,
    countAr: null,
    whenToSay:
        'After eating, after waking up, when something good happens, always',
    whenToSayAr: '\u0628\u0639\u062F \u0627\u0644\u0623\u0643\u0644\u060C \u0628\u0639\u062F \u0627\u0644\u0627\u0633\u062A\u064A\u0642\u0627\u0638\u060C \u0639\u0646\u062F \u062D\u062F\u0648\u062B \u0634\u064A\u0621 \u062C\u064A\u062F\u060C \u062F\u0627\u0626\u0645\u0627\u064B',
    promiseEn: 'Alhamdulillah fills the Scale.',
    promiseAr: '\u0627\u0644\u062D\u0645\u062F \u0644\u0644\u0647 \u062A\u0645\u0644\u0623 \u0627\u0644\u0645\u064A\u0632\u0627\u0646.',
    sourceRef: 'Sahih Muslim 223',
    sourceRefAr: '\u0635\u062D\u064A\u062D \u0645\u0633\u0644\u0645 \u0662\u0662\u0663',
  ),

  // ── Event 8: The Guardian: Abu Talib ──────────────────────────────────
  'j_1_2_3': DhikrCard(
    id: 'j_1_2_3',
    arabicText:
        '\u0644\u0627 \u062D\u064E\u0648\u0652\u0644\u064E \u0648\u064E\u0644\u0627 \u0642\u064F\u0648\u0651\u064E\u0629\u064E \u0625\u0650\u0644\u0627 \u0628\u0650\u0627\u0644\u0644\u0651\u064E\u0647\u0650',
    transliteration: 'La hawla wa la quwwata illa billah',
    meaningEn:
        'There is no power and no strength except with Allah.',
    meaningAr:
        '\u0644\u0627 \u062D\u0648\u0644 \u0648\u0644\u0627 \u0642\u0648\u0629 \u0625\u0644\u0627 \u0628\u0627\u0644\u0644\u0647',
    count: 'Once, with conviction',
    countAr: '\u0645\u0631\u0629 \u0648\u0627\u062D\u062F\u0629 \u0628\u064A\u0642\u064A\u0646',
    whenToSay: 'When something feels too heavy, too hard, too much',
    whenToSayAr: '\u0639\u0646\u062F\u0645\u0627 \u064A\u0643\u0648\u0646 \u0627\u0644\u0623\u0645\u0631 \u0635\u0639\u0628\u0627\u064B \u0623\u0648 \u062B\u0642\u064A\u0644\u0627\u064B',
    promiseEn: 'It is a treasure from the treasures of Paradise.',
    promiseAr: '\u0643\u0646\u0632 \u0645\u0646 \u0643\u0646\u0648\u0632 \u0627\u0644\u062C\u0646\u0629.',
    sourceRef: 'Sahih Bukhari 6384, Sahih Muslim 2704',
    sourceRefAr: '\u0635\u062D\u064A\u062D \u0627\u0644\u0628\u062E\u0627\u0631\u064A \u0666\u0663\u0668\u0664\u060C \u0635\u062D\u064A\u062D \u0645\u0633\u0644\u0645 \u0662\u0667\u0660\u0664',
  ),

  // ── Event 9: Hilf al-Fudul ────────────────────────────────────────────
  'j_1_2_4': DhikrCard(
    id: 'j_1_2_4',
    arabicText:
        '\u0633\u064F\u0628\u0652\u062D\u064E\u0627\u0646\u064E \u0627\u0644\u0644\u0651\u064E\u0647\u0650 \u0648\u064E\u0628\u0650\u062D\u064E\u0645\u0652\u062F\u0650\u0647\u0650',
    transliteration: 'Subhanallahi wa bihamdihi',
    meaningEn: 'Glory be to Allah and praise Him.',
    meaningAr: '\u0633\u0628\u062D\u0627\u0646 \u0627\u0644\u0644\u0647 \u0648\u0628\u062D\u0645\u062F\u0647',
    count: '100 times daily',
    countAr: '\u0661\u0660\u0660 \u0645\u0631\u0629 \u064A\u0648\u0645\u064A\u0627\u064B',
    whenToSay: 'Morning and evening',
    whenToSayAr: '\u0635\u0628\u0627\u062D\u0627\u064B \u0648\u0645\u0633\u0627\u0621\u064B',
    promiseEn:
        'Whoever says it 100 times a day, his sins are forgiven even if they were like the foam of the sea.',
    promiseAr:
        '\u0645\u0646 \u0642\u0627\u0644 \u0633\u0628\u062D\u0627\u0646 \u0627\u0644\u0644\u0647 \u0648\u0628\u062D\u0645\u062F\u0647 \u0641\u064A \u064A\u0648\u0645 \u0645\u0626\u0629 \u0645\u0631\u0629 \u062D\u064F\u0637\u0651\u062A \u062E\u0637\u0627\u064A\u0627\u0647 \u0648\u0625\u0646 \u0643\u0627\u0646\u062A \u0645\u062B\u0644 \u0632\u0628\u062F \u0627\u0644\u0628\u062D\u0631.',
    sourceRef: 'Sahih Bukhari 6405',
    sourceRefAr: '\u0635\u062D\u064A\u062D \u0627\u0644\u0628\u062E\u0627\u0631\u064A \u0666\u0664\u0660\u0665',
  ),

  // ── Event 10: Al-Amin: The Trustworthy ────────────────────────────────
  'j_m1_010': DhikrCard(
    id: 'j_m1_010',
    arabicText:
        '\u0633\u064F\u0628\u0652\u062D\u064E\u0627\u0646\u064E \u0627\u0644\u0644\u0651\u064E\u0647\u0650\u060C \u0648\u064E\u0627\u0644\u0652\u062D\u064E\u0645\u0652\u062F\u064F \u0644\u0650\u0644\u0651\u064E\u0647\u0650\u060C \u0648\u064E\u0644\u0627 \u0625\u0650\u0644\u064E\u0647\u064E \u0625\u0650\u0644\u0627 \u0627\u0644\u0644\u0651\u064E\u0647\u064F\u060C \u0648\u064E\u0627\u0644\u0644\u0651\u064E\u0647\u064F \u0623\u064E\u0643\u0652\u0628\u064E\u0631\u064F',
    transliteration:
        'Subhanallah, walhamdulillah, wa la ilaha illallah, wallahu akbar',
    meaningEn:
        'Glory be to Allah. Praise be to Allah. There is no god but Allah. Allah is the Greatest.',
    meaningAr:
        '\u0633\u0628\u062D\u0627\u0646 \u0627\u0644\u0644\u0647\u060C \u0648\u0627\u0644\u062D\u0645\u062F \u0644\u0644\u0647\u060C \u0648\u0644\u0627 \u0625\u0644\u0647 \u0625\u0644\u0627 \u0627\u0644\u0644\u0647\u060C \u0648\u0627\u0644\u0644\u0647 \u0623\u0643\u0628\u0631',
    count: 'Once, with reflection on each word',
    countAr: '\u0645\u0631\u0629 \u0648\u0627\u062D\u062F\u0629 \u0628\u062A\u062F\u0628\u0631',
    whenToSay: 'Anytime \u2014 these four are always appropriate',
    whenToSayAr: '\u0641\u064A \u0623\u064A \u0648\u0642\u062A \u2014 \u0647\u0630\u0647 \u0627\u0644\u0623\u0631\u0628\u0639 \u0645\u0646\u0627\u0633\u0628\u0629 \u062F\u0627\u0626\u0645\u0627\u064B',
    promiseEn:
        'They are more beloved to Allah than everything the sun rises upon.',
    promiseAr:
        '\u0644\u0623\u064E\u0646 \u0623\u0642\u0648\u0644: \u0633\u0628\u062D\u0627\u0646 \u0627\u0644\u0644\u0647 \u0648\u0627\u0644\u062D\u0645\u062F \u0644\u0644\u0647 \u0648\u0644\u0627 \u0625\u0644\u0647 \u0625\u0644\u0627 \u0627\u0644\u0644\u0647 \u0648\u0627\u0644\u0644\u0647 \u0623\u0643\u0628\u0631\u060C \u0623\u062D\u0628\u0651\u064F \u0625\u0644\u064A\u0651 \u0645\u0645\u0627 \u0637\u0644\u0639\u062A \u0639\u0644\u064A\u0647 \u0627\u0644\u0634\u0645\u0633.',
    sourceRef: 'Sahih Muslim 2695',
    sourceRefAr: '\u0635\u062D\u064A\u062D \u0645\u0633\u0644\u0645 \u0662\u0666\u0669\u0665',
  ),

  // ── Event 11: Marriage to Khadijah ────────────────────────────────────
  'j_m1_011': DhikrCard(
    id: 'j_m1_011',
    arabicText:
        '\u0633\u064F\u0628\u0652\u062D\u064E\u0627\u0646\u064E \u0627\u0644\u0644\u0651\u064E\u0647\u0650 (\u0663\u0663) \u0648\u064E\u0627\u0644\u0652\u062D\u064E\u0645\u0652\u062F\u064F \u0644\u0650\u0644\u0651\u064E\u0647\u0650 (\u0663\u0663) \u0648\u064E\u0627\u0644\u0644\u0651\u064E\u0647\u064F \u0623\u064E\u0643\u0652\u0628\u064E\u0631\u064F (\u0663\u0664)',
    transliteration:
        'Subhanallah (33 times), Alhamdulillah (33 times), Allahu Akbar (34 times)',
    meaningEn:
        'Glory be to Allah (33), Praise be to Allah (33), Allah is the Greatest (34).',
    meaningAr:
        '\u0633\u0628\u062D\u0627\u0646 \u0627\u0644\u0644\u0647 (\u0663\u0663) \u0648\u0627\u0644\u062D\u0645\u062F \u0644\u0644\u0647 (\u0663\u0663) \u0648\u0627\u0644\u0644\u0647 \u0623\u0643\u0628\u0631 (\u0663\u0664)',
    count: '33 + 33 + 34 = 100 after each prayer',
    countAr: '\u0663\u0663 + \u0663\u0663 + \u0663\u0664 = \u0661\u0660\u0660 \u0628\u0639\u062F \u0643\u0644 \u0635\u0644\u0627\u0629',
    whenToSay: 'After every obligatory prayer',
    whenToSayAr: '\u0628\u0639\u062F \u0643\u0644 \u0635\u0644\u0627\u0629 \u0645\u0641\u0631\u0648\u0636\u0629',
    promiseEn:
        'Whoever says this after every prayer, his sins are forgiven even if they were like the foam of the sea.',
    promiseAr:
        '\u0645\u0646 \u0633\u0628\u0651\u062D \u0627\u0644\u0644\u0647 \u0641\u064A \u062F\u0628\u0631 \u0643\u0644 \u0635\u0644\u0627\u0629 \u062B\u0644\u0627\u062B\u0627\u064B \u0648\u062B\u0644\u0627\u062B\u064A\u0646\u060C \u0648\u062D\u0645\u062F \u0627\u0644\u0644\u0647 \u062B\u0644\u0627\u062B\u0627\u064B \u0648\u062B\u0644\u0627\u062B\u064A\u0646\u060C \u0648\u0643\u0628\u0651\u0631 \u0627\u0644\u0644\u0647 \u062B\u0644\u0627\u062B\u0627\u064B \u0648\u062B\u0644\u0627\u062B\u064A\u0646\u060C \u0641\u062A\u0644\u0643 \u062A\u0633\u0639 \u0648\u062A\u0633\u0639\u0648\u0646\u060C \u0648\u0642\u0627\u0644 \u062A\u0645\u0627\u0645 \u0627\u0644\u0645\u0626\u0629: \u0644\u0627 \u0625\u0644\u0647 \u0625\u0644\u0627 \u0627\u0644\u0644\u0647 \u0648\u062D\u062F\u0647 \u0644\u0627 \u0634\u0631\u064A\u0643 \u0644\u0647\u060C \u0644\u0647 \u0627\u0644\u0645\u0644\u0643 \u0648\u0644\u0647 \u0627\u0644\u062D\u0645\u062F \u0648\u0647\u0648 \u0639\u0644\u0649 \u0643\u0644 \u0634\u064A\u0621 \u0642\u062F\u064A\u0631\u060C \u063A\u064F\u0641\u0631\u062A \u062E\u0637\u0627\u064A\u0627\u0647 \u0648\u0625\u0646 \u0643\u0627\u0646\u062A \u0645\u062B\u0644 \u0632\u0628\u062F \u0627\u0644\u0628\u062D\u0631.',
    sourceRef: 'Sahih Muslim 597',
    sourceRefAr: '\u0635\u062D\u064A\u062D \u0645\u0633\u0644\u0645 \u0665\u0669\u0667',
  ),

  // ── Event 12: The Black Stone ─────────────────────────────────────────
  'j_1_1_3': DhikrCard(
    id: 'j_1_1_3',
    arabicText:
        '\u0623\u064E\u0633\u0652\u062A\u064E\u063A\u0652\u0641\u0650\u0631\u064F \u0627\u0644\u0644\u0651\u064E\u0647\u064E \u0648\u064E\u0623\u064E\u062A\u064F\u0648\u0628\u064F \u0625\u0650\u0644\u064E\u064A\u0652\u0647\u0650',
    transliteration: 'Astaghfirullaha wa atubu ilayh',
    meaningEn:
        'I seek Allah\'s forgiveness and turn to Him in repentance.',
    meaningAr:
        '\u0623\u0633\u062A\u063A\u0641\u0631 \u0627\u0644\u0644\u0647 \u0648\u0623\u062A\u0648\u0628 \u0625\u0644\u064A\u0647',
    count: '100 times daily',
    countAr: '\u0661\u0660\u0660 \u0645\u0631\u0629 \u064A\u0648\u0645\u064A\u0627\u064B',
    whenToSay: 'Throughout the day, and before sleeping',
    whenToSayAr: '\u0637\u0648\u0627\u0644 \u0627\u0644\u064A\u0648\u0645\u060C \u0648\u0642\u0628\u0644 \u0627\u0644\u0646\u0648\u0645',
    promiseEn:
        'The Prophet \uFDFA himself used to seek Allah\'s forgiveness more than 70 times a day. And he was already forgiven.',
    promiseAr:
        '\u0648\u0627\u0644\u0644\u0647 \u0625\u0646\u064A \u0644\u0623\u0633\u062A\u063A\u0641\u0631 \u0627\u0644\u0644\u0647 \u0648\u0623\u062A\u0648\u0628 \u0625\u0644\u064A\u0647 \u0641\u064A \u0627\u0644\u064A\u0648\u0645 \u0623\u0643\u062B\u0631 \u0645\u0646 \u0633\u0628\u0639\u064A\u0646 \u0645\u0631\u0629.',
    sourceRef: 'Sahih Bukhari 6307',
    sourceRefAr: '\u0635\u062D\u064A\u062D \u0627\u0644\u0628\u062E\u0627\u0631\u064A \u0666\u0663\u0660\u0667',
  ),

  // ── Event 13: Solitude in Cave Hira ───────────────────────────────────
  'j_1_2_6': DhikrCard(
    id: 'j_1_2_6',
    arabicText: '\u0633\u064F\u0628\u0652\u062D\u064E\u0627\u0646\u064E \u0627\u0644\u0644\u0651\u064E\u0647\u0650',
    transliteration: 'Subhanallah',
    meaningEn: 'Glory be to Allah.',
    meaningAr: '\u0633\u0628\u062D\u0627\u0646 \u0627\u0644\u0644\u0647',
    count: '100 times',
    countAr: '\u0661\u0660\u0660 \u0645\u0631\u0629',
    whenToSay:
        'In quiet moments \u2014 morning, evening, or whenever you pause',
    whenToSayAr: '\u0641\u064A \u0644\u062D\u0638\u0627\u062A \u0627\u0644\u0647\u062F\u0648\u0621 \u2014 \u0635\u0628\u0627\u062D\u0627\u064B\u060C \u0645\u0633\u0627\u0621\u064B\u060C \u0623\u0648 \u0639\u0646\u062F\u0645\u0627 \u062A\u062A\u0648\u0642\u0641',
    promiseEn:
        'Whoever says \'Subhanallah\' 100 times, 1,000 good deeds are written for him, or 1,000 sins are erased from him.',
    promiseAr:
        '\u0645\u0646 \u0642\u0627\u0644 \u0633\u0628\u062D\u0627\u0646 \u0627\u0644\u0644\u0647 \u0645\u0626\u0629 \u0645\u0631\u0629 \u0643\u064F\u062A\u0628\u062A \u0644\u0647 \u0623\u0644\u0641 \u062D\u0633\u0646\u0629 \u0623\u0648 \u062D\u064F\u0637\u0651\u062A \u0639\u0646\u0647 \u0623\u0644\u0641 \u062E\u0637\u064A\u0626\u0629.',
    sourceRef: 'Sahih Muslim 2698',
    sourceRefAr: '\u0635\u062D\u064A\u062D \u0645\u0633\u0644\u0645 \u0662\u0666\u0669\u0668',
  ),

  // ── Event 14: The First Revelation ──────────────────────────────────────
  'j_1_2_7': DhikrCard(
    id: 'subhanallah_khalq',
    arabicText: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ عَدَدَ خَلْقِهِ وَرِضَا نَفْسِهِ وَزِنَةَ عَرْشِهِ وَمِدَادَ كَلِمَاتِهِ',
    transliteration: 'Subhanallahi wa bihamdihi \'adada khalqihi wa rida nafsihi wa zinata \'arshihi wa midada kalimatihi',
    meaningEn: 'Glory be to Allah and praise Him, by the number of His creation, by His pleasure, by the weight of His Throne, and by the extent of His Words.',
    meaningAr: 'سبحان الله وبحمده بعدد خلقه ورضا نفسه وزنة عرشه ومداد كلماته.',
    count: '3 times',
    countAr: '٣ مرات',
    whenToSay: 'Every morning',
    whenToSayAr: 'كل صباح',
    promiseEn: 'The Prophet \uFDFA left Juwayriyah in the morning after Fajr while she was making dhikr, and returned after the sun was well up to find her still sitting. He said: \'I have said three phrases three times since I left you, and if weighed against all you have said since morning, they would outweigh them.\'',
    promiseAr: 'لقد قلتُ بعدكِ ثلاث كلمات ثلاث مرات، لو وُزِنت بما قلتِ منذ الغداة لوزنتهنّ: سبحان الله وبحمده عدد خلقه ورضا نفسه وزنة عرشه ومداد كلماته.',
    sourceRef: 'Sahih Muslim 2726',
    sourceRefAr: 'صحيح مسلم ٢٧٢٦',
  ),

  // ── Event 15: The First Believers ───────────────────────────────────────
  'j_1_2_8': DhikrCard(
    id: 'j_1_2_8',
    arabicText: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى وَالتُّقَى وَالْعَفَافَ وَالْغِنَى',
    transliteration: 'Allahumma inni as\'alukal-huda wat-tuqa wal-\'afafa wal-ghina',
    meaningEn: 'O Allah, I ask You for guidance, piety, chastity, and self-sufficiency.',
    meaningAr: 'اللهم إني أسألك الهدى والتقى والعفاف والغنى.',
    count: 'Once, in the morning',
    countAr: 'مرة واحدة في الصباح',
    whenToSay: 'At the start of your day, when you need direction',
    whenToSayAr: 'في بداية يومك، حين تحتاج إلى توجيه',
    promiseEn: 'The Prophet \uFDFA used to say this supplication. It combines the four things every believer needs: guidance to know the truth, piety to follow it, dignity to protect it, and sufficiency to never compromise it.',
    promiseAr: 'كان النبي \uFDFA يقول هذا الدعاء. وهو يجمع أربعة أشياء يحتاجها كل مؤمن: الهدى ليعرف الحق والتقوى ليتبعه والعفاف ليصونه والغنى حتى لا يساوم عليه.',
    sourceRef: 'Sahih Muslim 2721',
    sourceRefAr: 'صحيح مسلم ٢٧٢١',
  ),

  // ── Event 16: Three Years of Secret Preaching ──────────────────────────
  'j_m1_016': DhikrCard(
    id: 'j_m1_016',
    arabicText: 'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
    transliteration: 'Allahumma a\'inni \'ala dhikrika wa shukrika wa husni \'ibadatik',
    meaningEn: 'O Allah, help me to remember You, thank You, and worship You beautifully.',
    meaningAr: 'اللهم أعنّي على ذكرك وشكرك وحسن عبادتك.',
    count: 'Once after every prayer',
    countAr: 'مرة بعد كل صلاة',
    whenToSay: 'After each obligatory prayer, before moving',
    whenToSayAr: 'بعد كل صلاة مفروضة، قبل أن تتحرك',
    promiseEn: 'The Prophet \uFDFA took Mu\'adh ibn Jabal (may Allah be pleased with him) by the hand and said: "O Mu\'adh, by Allah I love you. I advise you: never leave saying this after every prayer."',
    promiseAr: 'أخذ النبي \uFDFA بيد معاذ بن جبل رضي الله عنه وقال: "يا معاذ والله إني لأحبك. أوصيك: لا تدعنّ دبر كل صلاة أن تقول: اللهم أعني على ذكرك وشكرك وحسن عبادتك."',
    sourceRef: 'Abu Dawud 1522 (Sahih)',
    sourceRefAr: 'سنن أبي داود ١٥٢٢ (صحيح)',
  ),

  // ── Event 17: The Call Goes Public — Mount Safa ─────────────────────────
  'j_1_3_1': DhikrCard(
    id: 'j_1_3_1',
    arabicText: 'اللَّهُمَّ إِنِّي ظَلَمْتُ نَفْسِي ظُلْمًا كَثِيرًا وَلَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ فَاغْفِرْ لِي مَغْفِرَةً مِنْ عِنْدِكَ وَارْحَمْنِي إِنَّكَ أَنْتَ الْغَفُورُ الرَّحِيمُ',
    transliteration: 'Allahumma inni zalamtu nafsi zulman kathiran, wa la yaghfirudh-dhunuba illa anta, faghfir li maghfiratan min \'indika, warhamni innaka antal-Ghafur-ur-Rahim',
    meaningEn: 'O Allah, I have wronged myself greatly, and none forgives sins but You. Forgive me with a forgiveness from You, and have mercy on me. You are the Forgiving, the Merciful.',
    meaningAr: 'اللهم إني ظلمتُ نفسي ظلماً كثيراً ولا يغفر الذنوب إلا أنت فاغفر لي مغفرةً من عندك وارحمني إنك أنت الغفور الرحيم.',
    count: 'Once, with sincerity',
    countAr: 'مرة واحدة بإخلاص',
    whenToSay: 'After prayer, when you feel the weight of your shortcomings',
    whenToSayAr: 'بعد الصلاة، حين تشعر بثقل تقصيرك',
    promiseEn: 'The Prophet \uFDFA taught Abu Bakr (may Allah be pleased with him) this supplication to say in his prayer. The man who never hesitated to believe was still taught to ask for forgiveness.',
    promiseAr: 'علّم النبي \uFDFA أبا بكر رضي الله عنه هذا الدعاء ليقوله في صلاته. الرجل الذي لم يتردد في الإيمان قط عُلّم مع ذلك أن يطلب المغفرة.',
    sourceRef: 'Sahih Bukhari 834, Sahih Muslim 2705',
    sourceRefAr: 'صحيح البخاري ٨٣٤، صحيح مسلم ٢٧٠٥',
  ),

  // ── Event 18: Quraysh React — First Persecution ─────────────────────────
  'j_1_3_2': DhikrCard(
    id: 'j_1_3_2',
    arabicText: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    transliteration: 'Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina \'adhab an-nar',
    meaningEn: 'Our Lord, give us good in this world and good in the Hereafter, and protect us from the punishment of the Fire.',
    meaningAr: 'ربنا آتنا في الدنيا حسنة وفي الآخرة حسنة وقنا عذاب النار.',
    count: 'As often as you wish',
    countAr: 'كلما شئت',
    whenToSay: 'Anytime, especially between the two corners during tawaf',
    whenToSayAr: 'في أي وقت، وخاصة بين الركنين في الطواف',
    promiseEn: 'This was the most frequent supplication of the Prophet \uFDFA. He asked for balance: good in this life and good in the next.',
    promiseAr: 'هذا أكثر دعاء كان يدعو به النبي \uFDFA. طلب التوازن: حسنة في الدنيا وحسنة في الآخرة.',
    sourceRef: 'Sahih Bukhari 4522, Sahih Muslim 2690, Quran 2:201',
    sourceRefAr: 'صحيح البخاري ٤٥٢٢، صحيح مسلم ٢٦٩٠، القرآن ٢:٢٠١',
  ),

  // ── Event 19: The Torture of the Weak ───────────────────────────────────
  'j_1_3_3': DhikrCard(
    id: 'j_1_3_3',
    arabicText: 'لَا إِلَهَ إِلَّا اللَّهُ',
    transliteration: 'La ilaha illallah',
    meaningEn: 'There is no god but Allah.',
    meaningAr: 'لا إله إلا الله.',
    count: 'As many times as your heart needs',
    countAr: 'بقدر ما يحتاج قلبك',
    whenToSay: 'Always. The first and last words a Muslim should speak.',
    whenToSayAr: 'دائماً. أول وآخر كلمات يقولها المسلم.',
    promiseEn: 'Whoever\'s last words are "La ilaha illallah" enters Paradise.',
    promiseAr: 'من كان آخر كلامه لا إله إلا الله دخل الجنة.',
    sourceRef: 'Abu Dawud 3116 (Sahih)',
    sourceRefAr: 'سنن أبي داود ٣١١٦ (صحيح)',
  ),

  // ── Event 20: First Migration to Abyssinia ──────────────────────────────
  'j_1_3_4': DhikrCard(
    id: 'j_1_3_4',
    arabicText: 'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
    transliteration: 'Bismillah, tawakkaltu \'alallah, wa la hawla wa la quwwata illa billah',
    meaningEn: 'In the name of Allah, I place my trust in Allah. There is no power and no strength except with Allah.',
    meaningAr: 'بسم الله توكلت على الله ولا حول ولا قوة إلا بالله.',
    count: 'Once, when leaving home',
    countAr: 'مرة واحدة عند الخروج من البيت',
    whenToSay: 'Every time you step out of your door',
    whenToSayAr: 'كلما خرجت من بابك',
    promiseEn: 'Whoever says this when leaving his home is told: "You are guided, you are sufficed, you are protected." And the devil turns away from him.',
    promiseAr: 'من قال حين يخرج من بيته: بسم الله توكلت على الله لا حول ولا قوة إلا بالله، يُقال له: كُفيت ووُقيت وهُديت. ويتنحى عنه الشيطان.',
    sourceRef: 'Abu Dawud 5095, Tirmidhi 3426 (Sahih)',
    sourceRefAr: 'سنن أبي داود ٥٠٩٥، الترمذي ٣٤٢٦ (صحيح)',
  ),
  // ── Event 21: The Quraysh Delegation to the Negus ─
  'j_1_3_5': DhikrCard(
    id: 'j_1_3_5',
    arabicText: 'اللَّهُمَّ اغْفِرْ لِي ذَنْبِي كُلَّهُ دِقَّهُ وَجِلَّهُ وَأَوَّلَهُ وَآخِرَهُ وَعَلانِيَتَهُ وَسِرَّهُ',
    transliteration: 'Allahumma-ghfir li dhanbi kullahu, diqqahu wa jillahu, wa awwalahu wa akhirahu, wa \'alaniyyatahu wa sirrahu',
    meaningEn: '"O Allah, forgive all my sins — the small and the great, the first and the last, the public and the private."',
    meaningAr: 'اللَّهُمَّ اغْفِرْ لِي ذَنْبِي كُلَّهُ دِقَّهُ وَجِلَّهُ وَأَوَّلَهُ وَآخِرَهُ وَعَلانِيَتَهُ وَسِرَّهُ',
    count: 'Once, in sujud (prostration)',
    countAr: null,
    whenToSay: 'During prostration in prayer',
    whenToSayAr: '',
    promiseEn: '"The Prophet \uFDFA used to say this in his sujud. It is the most comprehensive request for forgiveness — covering every dimension of sin."',
    promiseAr: '"كان النبي \uFDFA يقول هذا في سجوده. وهو أشمل طلب للمغفرة يغطي كل أبعاد الذنب."',
    sourceRef: 'Sahih Muslim 483',
    sourceRefAr: '',
  ),

  // ── Event 22: The Negus Protects the Muslims ─
  'j_1_3_11': DhikrCard(
    id: 'j_1_3_11',
    arabicText: 'اللَّهُمَّ مَا أَصْبَحَ بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لا شَرِيكَ لَكَ فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ',
    transliteration: 'Allahumma ma asbaha bi min ni\'matin aw bi ahadin min khalqika faminka wahdaka la shareeka laka falakal-hamdu wa lakash-shukr',
    meaningEn: '"O Allah, whatever blessing I or any of Your creation wakes up with is from You alone, with no partner. So to You belongs all praise and all thanks."',
    meaningAr: 'اللَّهُمَّ مَا أَصْبَحَ بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لا شَرِيكَ لَكَ فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ',
    count: 'Once every morning',
    countAr: null,
    whenToSay: 'First thing in the morning',
    whenToSayAr: '',
    promiseEn: '"Whoever says this in the morning has fulfilled his gratitude for that day. And whoever says it in the evening has fulfilled his gratitude for that night."',
    promiseAr: '"من قالها حين يصبح فقد أدّى شكر يومه ومن قالها حين يمسي فقد أدّى شكر ليلته."',
    sourceRef: 'Abu Dawud 5073 (graded Sahih by Al-Albani)',
    sourceRefAr: '',
  ),

  // ── Event 23: Hamza Accepts Islam ─
  'j_1_3_6': DhikrCard(
    id: 'j_1_3_6',
    arabicText: 'يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَى دِينِكَ',
    transliteration: 'Ya Muqallib al-qulub, thabbit qalbi \'ala dinik',
    meaningEn: '"O Turner of hearts, make my heart firm upon Your religion."',
    meaningAr: 'يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَى دِينِكَ',
    count: 'As often as you need',
    countAr: null,
    whenToSay: 'When you feel doubt, weakness, or confusion',
    whenToSayAr: '',
    promiseEn: '"This was the most frequent supplication of the Prophet \uFDFA. When Umm Salamah asked him why he said it so often, he replied: \'There is no human heart except that it is between two fingers of the Most Merciful. He turns it however He wills.\'"',
    promiseAr: '"كان هذا أكثر دعاء النبي \uFDFA. وحين سألته أم سلمة لماذا يكثر منه أجاب: \'ما من قلب إلا وهو بين إصبعين من أصابع الرحمن يقلّبه كيف يشاء.\'"',
    sourceRef: 'Tirmidhi 2140, graded Sahih. Also in Sahih Muslim 2654 (variant wording)',
    sourceRefAr: '',
  ),

  // ── Event 24: Umar Accepts Islam ─
  'j_1_3_7': DhikrCard(
    id: 'j_1_3_7',
    arabicText: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ سُبْحَانَ اللَّهِ الْعَظِيمِ أَسْتَغْفِرُ اللَّهَ',
    transliteration: 'Subhanallahi wa bihamdihi, Subhanallahil-\'Azeem, Astaghfirullah',
    meaningEn: '"Glory be to Allah and praise Him. Glory be to Allah the Magnificent. I seek Allah\'s forgiveness."',
    meaningAr: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ سُبْحَانَ اللَّهِ الْعَظِيمِ أَسْتَغْفِرُ اللَّهَ',
    count: '3 times each',
    countAr: null,
    whenToSay: 'After every prayer, or when reflecting on how quickly everything can change',
    whenToSayAr: '',
    promiseEn: '"These are three phrases that, if said after every prayer, the person will not be disappointed."',
    promiseAr: '"ثلاث كلمات من قالهن دبر كل صلاة لم يخب."',
    sourceRef: 'Sahih Muslim 594',
    sourceRefAr: '',
  ),

  // ⚠️ NEEDS REVIEW — Event #25
  // ── Event 25: Second Migration to Abyssinia ─
  'j_1_3_8': DhikrCard(
    id: 'j_1_3_8',
    arabicText: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
    transliteration: 'Allahumma la sahla illa ma ja\'altahu sahla, wa anta taj\'alul-hazna idha shi\'ta sahla',
    meaningEn: '"O Allah, there is no ease except what You make easy. And You can make grief, if You will, easy."',
    meaningAr: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
    count: 'Once, when things feel hard',
    countAr: null,
    whenToSay: 'When you face difficulty, exile, loss, or hardship',
    whenToSayAr: '',
    promiseEn: '"The Prophet \uFDFA used to say this supplication. It is the prayer of every person who is far from home, carrying a weight they did not choose."',
    promiseAr: '"كان النبي \uFDFA يقول هذا الدعاء. وهو دعاء كل شخص بعيد عن وطنه يحمل ثقلاً لم يختره."',
    sourceRef: 'Ibn Hibban (graded Sahih), also attributed in Ibn al-Sunni',
    sourceRefAr: '',
  ),

  // ── Event 26: The Boycott Begins ─
  'j_1_3_9': DhikrCard(
    id: 'j_1_3_9',
    arabicText: 'حَسْبِيَ اللَّهُ لا إِلَهَ إِلا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
    transliteration: 'Hasbiyal-lahu la ilaha illa huwa, \'alayhi tawakkaltu wa huwa Rabbul-\'Arshil-\'Azeem',
    meaningEn: '"Allah is sufficient for me. There is no god but Him. In Him I place my trust, and He is the Lord of the Mighty Throne."',
    meaningAr: 'حَسْبِيَ اللَّهُ لا إِلَهَ إِلا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
    count: '7 times, morning and evening',
    countAr: null,
    whenToSay: 'Morning and evening, especially during hardship',
    whenToSayAr: '',
    promiseEn: '"Whoever says this seven times in the morning and evening, Allah will suffice him in whatever concerns him."',
    promiseAr: '"من قالها حين يصبح وحين يمسي سبع مرات كفاه الله ما أهمّه."',
    sourceRef: 'Abu Dawud 5081 (graded Sahih by Ibn al-Qayyim, also referenced from Quran 9:129)',
    sourceRefAr: '',
  ),

  // ── Event 27: Three Years of Siege ─
  'j_1_3_10': DhikrCard(
    id: 'j_1_3_10',
    arabicText: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ وَالْعَجْزِ وَالْكَسَلِ وَالْبُخْلِ وَالْجُبْنِ وَضَلَعِ الدَّيْنِ وَغَلَبَةِ الرِّجَالِ',
    transliteration: 'Allahumma inni a\'udhu bika minal-hammi wal-hazan, wal-\'ajzi wal-kasal, wal-bukhli wal-jubn, wa dala\'id-dayni wa ghalabatir-rijal',
    meaningEn: '"O Allah, I seek refuge in You from anxiety and grief, from inability and laziness, from miserliness and cowardice, and from the burden of debt and the overpowering of people."',
    meaningAr: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ وَالْعَجْزِ وَالْكَسَلِ وَالْبُخْلِ وَالْجُبْنِ وَضَلَعِ الدَّيْنِ وَغَلَبَةِ الرِّجَالِ',
    count: 'Once, when you need it',
    countAr: null,
    whenToSay: 'When anxiety, grief, or helplessness overwhelms you',
    whenToSayAr: '',
    promiseEn: '"The Prophet \uFDFA used to say this frequently. It covers every form of human distress — emotional, physical, financial, and social."',
    promiseAr: '"كان النبي \uFDFA يكثر من هذا الدعاء. وهو يشمل كل أنواع الضيق البشري: العاطفي والجسدي والمالي والاجتماعي."',
    sourceRef: 'Sahih Bukhari 6369',
    sourceRefAr: '',
  ),

  // ⚠️ NEEDS REVIEW — Event #28
  // ── Event 28: The Boycott Ends ─
  'j_m1_028': DhikrCard(
    id: 'j_m1_028',
    arabicText: 'الْحَمْدُ لِلَّهِ الَّذِي بِنِعْمَتِهِ تَتِمُّ الصَّالِحَاتُ',
    transliteration: 'Alhamdulillahil-ladhi bi ni\'matihi tatimmus-salihat',
    meaningEn: '"All praise is due to Allah, by whose grace all good things are completed."',
    meaningAr: 'الْحَمْدُ لِلَّهِ الَّذِي بِنِعْمَتِهِ تَتِمُّ الصَّالِحَاتُ',
    count: 'Once, whenever something good happens',
    countAr: null,
    whenToSay: 'When relief comes, when good news arrives, when hardship ends',
    whenToSayAr: '',
    promiseEn: '"The Prophet \uFDFA would say this when something pleasing happened to him. It attributes every good outcome to Allah\'s grace."',
    promiseAr: '"كان النبي \uFDFA يقولها إذا جاءه ما يسرّه. وهي تنسب كل نتيجة طيبة إلى نعمة الله."',
    sourceRef: 'Ibn Majah 3803 (graded Sahih by Al-Albani)',
    sourceRefAr: '',
  ),

  // ── Event 29: Year of Grief — Death of Khadijah ─
  'j_m1_029': DhikrCard(
    id: 'j_m1_029',
    arabicText: 'إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ اللَّهُمَّ عِنْدَكَ أَحْتَسِبُ مُصِيبَتِي فَأْجُرْنِي فِيهَا',
    transliteration: 'Inna lillahi wa inna ilayhi raji\'un. Allahumma \'indaka ahtasibu musibati fa\'jurni fiha',
    meaningEn: '"To Allah we belong and to Him we return. O Allah, with You I entrust my grief — so reward me for it."',
    meaningAr: 'إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ اللَّهُمَّ عِنْدَكَ أَحْتَسِبُ مُصِيبَتِي فَأْجُرْنِي فِيهَا',
    count: 'Once, from the heart',
    countAr: null,
    whenToSay: 'When losing someone you love',
    whenToSayAr: '',
    promiseEn: '"No servant is afflicted with a calamity and says this except that Allah rewards him and replaces his loss with something better."',
    promiseAr: '"ما من عبد تصيبه مصيبة فيقول هذا إلا أجره الله في مصيبته وأخلف له خيراً منها."',
    sourceRef: 'Sahih Muslim 918',
    sourceRefAr: '',
  ),

  // ── Event 30: Year of Grief — Death of Abu Talib ─
  'j_m1_030': DhikrCard(
    id: 'j_m1_030',
    arabicText: 'اللَّهُمَّ اجْعَلْ فِي قَلْبِي نُوراً وَفِي بَصَرِي نُوراً وَفِي سَمْعِي نُوراً وَعَنْ يَمِينِي نُوراً وَعَنْ يَسَارِي نُوراً',
    transliteration: 'Allahumma-j\'al fi qalbi nuran, wa fi basari nuran, wa fi sam\'i nuran, wa \'an yamini nuran, wa \'an yasari nuran',
    meaningEn: '"O Allah, place light in my heart, light in my sight, light in my hearing, light on my right, and light on my left."',
    meaningAr: 'اللَّهُمَّ اجْعَلْ فِي قَلْبِي نُوراً وَفِي بَصَرِي نُوراً وَفِي سَمْعِي نُوراً وَعَنْ يَمِينِي نُوراً وَعَنْ يَسَارِي نُوراً',
    count: 'Once, in the darkest moments',
    countAr: null,
    whenToSay: 'When darkness surrounds you — grief, loss, confusion',
    whenToSayAr: '',
    promiseEn: '"The Prophet \uFDFA would say this when going to the mosque for Fajr — walking through the literal darkness, asking for light in every direction."',
    promiseAr: '"كان النبي \uFDFA يقول هذا وهو ذاهب إلى المسجد لصلاة الفجر — يمشي في الظلام الحقيقي ويطلب النور من كل اتجاه."',
    sourceRef: 'Sahih Bukhari 6316, Sahih Muslim 763',
    sourceRefAr: '',
  ),

  // ── Event 31: Journey to Ta'if ─
  'j_m1_031': DhikrCard(
    id: 'j_m1_031',
    arabicText: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ',
    transliteration: 'Allahumma inni as\'alukal-\'afiyah fid-dunya wal-akhirah',
    meaningEn: '"O Allah, I ask You for wellbeing in this world and the Hereafter."',
    meaningAr: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ',
    count: 'Once, morning and evening',
    countAr: null,
    whenToSay: 'Every morning and evening',
    whenToSayAr: '',
    promiseEn: '"The Prophet \uFDFA said: \'Ask Allah for wellbeing. After certainty of faith, no one is given anything better than wellbeing.\'"',
    promiseAr: '"قال النبي \uFDFA: \'سلوا الله العافية فإنه لم يُعطَ أحد بعد اليقين خيراً من العافية.\'"',
    sourceRef: 'Tirmidhi 3558, Ibn Majah 3849 (graded Sahih)',
    sourceRefAr: '',
  ),

  // ⚠️ NEEDS REVIEW — Event #32
  // ── Event 32: The Return — Wadi Nakhlah ─
  'j_m1_032': DhikrCard(
    id: 'j_m1_032',
    arabicText: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
    transliteration: 'A\'udhu bikalimatillahit-tammati min sharri ma khalaq',
    meaningEn: '"I seek refuge in the perfect words of Allah from the evil of what He has created."',
    meaningAr: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
    count: '3 times, evening',
    countAr: null,
    whenToSay: 'Every evening, and when stopping at a new place',
    whenToSayAr: '',
    promiseEn: '"Whoever says this when stopping somewhere, nothing will harm him until he leaves that place."',
    promiseAr: '"من نزل منزلاً فقال هذا لم يضرّه شيء حتى يرتحل من منزله ذلك."',
    sourceRef: 'Sahih Muslim 2708',
    sourceRefAr: '',
  ),

  // ⚠️ NEEDS REVIEW — Event #33
  // ── Event 33: Seeking Help from the Tribes ─
  'j_m1_033': DhikrCard(
    id: 'j_m1_033',
    arabicText: 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
    transliteration: 'Rabbi-shrah li sadri wa yassir li amri',
    meaningEn: '"My Lord, expand for me my chest and ease for me my task."',
    meaningAr: 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
    count: 'Once, before any important task',
    countAr: null,
    whenToSay: 'Before a meeting, a speech, a difficult conversation',
    whenToSayAr: '',
    promiseEn: '"This was Musa\'s عليه السلام prayer before speaking to Pharaoh. If it was enough for the greatest confrontation in prophetic history, it is enough for whatever you face today."',
    promiseAr: '"هذا دعاء موسى عليه السلام قبل مواجهة فرعون. فإن كان كافياً لأعظم مواجهة في تاريخ النبوات فهو كافٍ لأي شيء تواجهه اليوم."',
    sourceRef: 'Quran 20:25-26 (Musa\'s prayer, used as du\'a)',
    sourceRefAr: '',
  ),

  // ── Event 34: Al-Isra' wal-Mi'raj ─
  'j_m1_034': DhikrCard(
    id: 'j_m1_034',
    arabicText: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ سُبْحَانَ اللَّهِ الْعَظِيمِ',
    transliteration: 'Subhanallahi wa bihamdihi, Subhanallahil-\'Azeem',
    meaningEn: '"Glory be to Allah and praise Him. Glory be to Allah the Magnificent."',
    meaningAr: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ سُبْحَانَ اللَّهِ الْعَظِيمِ',
    count: 'Once, with awe',
    countAr: null,
    whenToSay: 'After hearing something that amazes you about Allah\'s creation',
    whenToSayAr: '',
    promiseEn: '"Two words: light on the tongue, heavy on the Scale, beloved to the Most Merciful."',
    promiseAr: '"كلمتان خفيفتان على اللسان ثقيلتان في الميزان حبيبتان إلى الرحمن."',
    sourceRef: 'Sahih Bukhari 6682, Sahih Muslim 2694',
    sourceRefAr: '',
  ),

  // ⚠️ NEEDS REVIEW — Event #35
  // ── Event 35: Abu Bakr Believes Without Hesitation ─
  'j_m1_035': DhikrCard(
    id: 'j_m1_035',
    arabicText: 'رَبَّنَا لا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِنْ لَدُنْكَ رَحْمَةً إِنَّكَ أَنْتَ الْوَهَّابُ',
    transliteration: 'Allahumma ya Muqallib al-qulub thabbit qalbi \'ala dinik',
    meaningEn: '"O Allah, O Turner of hearts, make my heart firm upon Your religion."',
    meaningAr: 'رَبَّنَا لا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِنْ لَدُنْكَ رَحْمَةً إِنَّكَ أَنْتَ الْوَهَّابُ',
    count: 'As often as needed',
    countAr: null,
    whenToSay: 'When doubt creeps in, when faith wavers',
    whenToSayAr: '',
    promiseEn: '"The Prophet \uFDFA said this more than any other supplication. The heart is between Allah\'s fingers — only He can keep it steady."',
    promiseAr: '"كان النبي \uFDFA يكثر من هذا الدعاء أكثر من غيره. القلب بين إصبعين من أصابع الرحمن — هو وحده يمكنه تثبيته."',
    sourceRef: 'Tirmidhi 2140 | Sahih Muslim 2654',
    sourceRefAr: '',
  ),

  // ── Event 36: The First Pledge of Aqabah ─
  'j_m1_036': DhikrCard(
    id: 'j_m1_036',
    arabicText: 'اللَّهُمَّ اهْدِنِي وَسَدِّدْنِي',
    transliteration: 'Allahummah-dini wa saddidni',
    meaningEn: '"O Allah, guide me and keep me on the straight path."',
    meaningAr: 'اللَّهُمَّ اهْدِنِي وَسَدِّدْنِي',
    count: 'Once, daily',
    countAr: null,
    whenToSay: 'When making decisions, choosing a path',
    whenToSayAr: '',
    promiseEn: '"The Prophet \uFDFA said: \'Remember by guidance your being guided on the path, and by steadiness the straightness of the arrow.\' Simple, focused, direct."',
    promiseAr: '"قال النبي \uFDFA: \'اذكر بالهداية هدايتك الطريق وبالسداد تسديدك السهم.\' بسيط ومركّز ومباشر."',
    sourceRef: 'Sahih Muslim 2725',
    sourceRefAr: '',
  ),

  // ── Event 38: The Second Pledge of Aqabah ─
  'j_m1_038': DhikrCard(
    id: 'j_m1_038',
    arabicText: 'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ',
    transliteration: 'Allahumma bika asbahna wa bika amsayna wa bika nahya wa bika namutu wa ilaykan-nushur',
    meaningEn: '"O Allah, by You we enter the morning, by You we enter the evening, by You we live, by You we die, and to You is the resurrection."',
    meaningAr: 'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ',
    count: 'Once, every morning',
    countAr: null,
    whenToSay: 'When you wake — before anything else',
    whenToSayAr: '',
    promiseEn: '"The Prophet \uFDFA would say this every morning. It places your entire day — and your entire life — in Allah\'s hands from the first breath."',
    promiseAr: '"كان النبي \uFDFA يقول هذا كل صباح. يضع يومك كله — وحياتك كلها — بين يدي الله من أول نفس."',
    sourceRef: 'Abu Dawud 5068, Tirmidhi 3391 (graded Sahih)',
    sourceRefAr: '',
  ),

  // ── Event 39: The Plot to Kill the Prophet ﷺ ─
  'j_m1_039': DhikrCard(
    id: 'j_m1_039',
    arabicText: 'بِسْمِ اللَّهِ الَّذِي لا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
    transliteration: 'Bismillahil-ladhi la yadurru ma\'asmihi shay\'un fil-ardi wa la fis-sama\'i wa huwas-Sami\'ul-\'Aleem',
    meaningEn: '"In the name of Allah, with whose name nothing on earth or in heaven can harm. He is the All-Hearing, the All-Knowing."',
    meaningAr: 'بِسْمِ اللَّهِ الَّذِي لا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
    count: '3 times, morning and evening',
    countAr: null,
    whenToSay: 'Morning and evening — especially when facing danger',
    whenToSayAr: '',
    promiseEn: '"Whoever says this three times in the morning and evening, nothing will harm him."',
    promiseAr: '"من قالها ثلاثاً حين يصبح وثلاثاً حين يمسي لم يضرّه شيء."',
    sourceRef: 'Abu Dawud 5088, Tirmidhi 3388 (graded Sahih)',
    sourceRefAr: '',
  ),

  // ── Event 40: Night of the Hijrah — Ali in the Bed ─
  'j_m1_040': DhikrCard(
    id: 'j_m1_040',
    arabicText: 'اللَّهُمَّ أَنْتَ رَبِّي لا إِلَهَ إِلا أَنْتَ عَلَيْكَ تَوَكَّلْتُ وَأَنْتَ رَبُّ الْعَرْشِ الْكَرِيمِ',
    transliteration: 'Allahumma anta Rabbi la ilaha illa anta, \'alayka tawakkaltu wa anta Rabbul-\'Arshil-Karim',
    meaningEn: '"O Allah, You are my Lord. There is no god but You. In You I place my trust, and You are the Lord of the Noble Throne."',
    meaningAr: 'اللَّهُمَّ أَنْتَ رَبِّي لا إِلَهَ إِلا أَنْتَ عَلَيْكَ تَوَكَّلْتُ وَأَنْتَ رَبُّ الْعَرْشِ الْكَرِيمِ',
    count: 'Once, with full reliance',
    countAr: null,
    whenToSay: 'When placing your life in Allah\'s hands',
    whenToSayAr: '',
    promiseEn: '"Whoever says this trusting Allah fully, Allah will suffice him."',
    promiseAr: '"من قالها متوكلاً كفاه الله."',
    sourceRef: 'Abu Dawud 5072 (referenced from Quran 9:129)',
    sourceRefAr: '',
  ),

  // ── Event 41: Suraqa ibn Malik — The Pursuit ─
  'j_m1_041': DhikrCard(
    id: 'j_m1_041',
    arabicText: 'تَوَكَّلْتُ عَلَى اللَّهِ رَبِّي وَرَبِّكُمْ مَا مِنْ دَابَّةٍ إِلا هُوَ آخِذٌ بِنَاصِيَتِهَا',
    transliteration: 'Allahumma inni a\'udhu bika min sharri kulli dhi sharrin anta akhidhun binasiyatih',
    meaningEn: '"O Allah, I seek refuge in You from the evil of every creature whose forelock is in Your hand."',
    meaningAr: 'تَوَكَّلْتُ عَلَى اللَّهِ رَبِّي وَرَبِّكُمْ مَا مِنْ دَابَّةٍ إِلا هُوَ آخِذٌ بِنَاصِيَتِهَا',
    count: 'Once, when you feel unsafe',
    countAr: null,
    whenToSay: 'When traveling, when feeling threatened',
    whenToSayAr: '',
    promiseEn: '"Every creature\'s forelock is in Allah\'s hand. Nothing moves without His permission — not a horse, not a hunter, not an empire."',
    promiseAr: '"كل مخلوق ناصيته بيد الله. لا شيء يتحرك بغير إذنه — لا فرس ولا صائد ولا إمبراطورية."',
    sourceRef: 'Sahih Muslim 2713 (part of longer du\'a)',
    sourceRefAr: '',
  ),

  // ── Event 42: Three Days in Cave Thawr ─
  'j_m1_042': DhikrCard(
    id: 'j_m1_042',
    arabicText: 'حَسْبِيَ اللَّهُ وَنِعْمَ الْوَكِيلُ',
    transliteration: 'Hasbiyal-lahu wa ni\'mal-wakeel',
    meaningEn: '"Allah is sufficient for me, and He is the best Disposer of affairs."',
    meaningAr: 'حَسْبِيَ اللَّهُ وَنِعْمَ الْوَكِيلُ',
    count: 'Once, with complete trust',
    countAr: null,
    whenToSay: 'When danger is at the door and there is nowhere to run',
    whenToSayAr: '',
    promiseEn: '"Ibrahim عليه السلام said it when thrown into the fire. Muhammad \uFDFA said it when surrounded by enemies. The same words, the same trust, across the centuries."',
    promiseAr: '"قالها إبراهيم عليه السلام حين أُلقي في النار وقالها محمد \uFDFA حين أحاط به الأعداء. الكلمات نفسها والثقة نفسها عبر القرون."',
    sourceRef: 'Sahih Bukhari 4563',
    sourceRefAr: '',
  ),

  // ── Event 47: Entry into Medina — The City Rejoices ─
  'j_m1_047': DhikrCard(
    id: 'j_m1_047',
    arabicText: 'اللَّهُمَّ اجْعَلْ لِي بِالْمَدِينَةِ حُبًّا كَمَا جَعَلْتَ لَنَا بِمَكَّةَ أَوْ أَشَدَّ',
    transliteration: 'Allahumma barik lana fi madinatina',
    meaningEn: '"O Allah, bless our city for us."',
    meaningAr: 'اللَّهُمَّ اجْعَلْ لِي بِالْمَدِينَةِ حُبًّا كَمَا جَعَلْتَ لَنَا بِمَكَّةَ أَوْ أَشَدَّ',
    count: null,
    countAr: null,
    whenToSay: 'When arriving at a new home',
    whenToSayAr: '',
    promiseEn: '',
    promiseAr: '',
    sourceRef: 'Derived from Sahih Muslim 1373 (Prophet\'s \uFDFA du\'a for Medina)',
    sourceRefAr: '',
  ),

  // ── Event 51: The Adhan ─
  'j_m2_051': DhikrCard(
    id: 'j_m2_051',
    arabicText: 'اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ وَالصَّلَاةِ الْقَائِمَةِ، آتِ مُحَمَّدًا الْوَسِيلَةَ وَالْفَضِيلَةَ، وَابْعَثْهُ مَقَامًا مَحْمُودًا الَّذِي وَعَدْتَهُ',
    transliteration: 'Allahumma Rabba hadhihi al-da\'wati al-tammah, wa al-salati al-qa\'imah, ati Muhammadan al-wasilata wal-fadilah, wab\'ath-hu maqaman mahmudan alladhi wa\'adtah',
    meaningEn: 'O Allah, Lord of this perfect call and established prayer, grant Muhammad the intercession and distinction, and raise him to the praised station You promised him',
    meaningAr: 'اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ وَالصَّلَاةِ الْقَائِمَةِ، آتِ مُحَمَّدًا الْوَسِيلَةَ وَالْفَضِيلَةَ، وَابْعَثْهُ مَقَامًا مَحْمُودًا الَّذِي وَعَدْتَهُ',
    count: 'Once after every Adhan',
    countAr: null,
    whenToSay: 'After hearing the Adhan',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA said: "Whoever says this after hearing the Adhan, my intercession will be granted for him on the Day of Resurrection."',
    promiseAr: 'قال النبيّ \uFDFA: "من قال حين يسمع النداء: اللهمّ ربّ هذه الدعوة التامّة... حلّت له شفاعتي يوم القيامة."',
    sourceRef: 'Sahih al-Bukhari #614',
    sourceRefAr: '',
  ),

  // ── Event 52: Change of Qibla ─
  'j_m2_052': DhikrCard(
    id: 'j_m2_052',
    arabicText: 'اللَّهُمَّ اهْدِنِي فِيمَنْ هَدَيْتَ، وَعَافِنِي فِيمَنْ عَافَيْتَ، وَتَوَلَّنِي فِيمَنْ تَوَلَّيْتَ',
    transliteration: 'Allahumma ihdini fiman hadayt, wa \'afini fiman \'afayt, wa tawallani fiman tawallayt',
    meaningEn: 'O Allah, guide me among those You have guided, grant me health among those You have granted health, and take care of me among those You have taken care of',
    meaningAr: 'اللَّهُمَّ اهْدِنِي فِيمَنْ هَدَيْتَ، وَعَافِنِي فِيمَنْ عَافَيْتَ، وَتَوَلَّنِي فِيمَنْ تَوَلَّيْتَ',
    count: 'Once in Witr prayer',
    countAr: null,
    whenToSay: 'In Qunut of Witr prayer',
    whenToSayAr: '',
    promiseEn: 'This is the du\'a the Prophet \uFDFA taught al-Hasan ibn Ali رضي الله عنهما to say in Witr prayer, and it is among the most beloved supplications for guidance.',
    promiseAr: 'هذا الدعاء الذي علّمه النبيّ \uFDFA للحسن بن عليّ رضي الله عنهما ليقوله في قنوت الوتر، وهو من أحبّ أدعية طلب الهداية.',
    sourceRef: 'Sunan Abu Dawud #1425; Sunan al-Tirmidhi #464 (Sahih)',
    sourceRefAr: '',
  ),

  // ⚠️ NEEDS REVIEW — Event #53
  // ── Event 53: First Expeditions ─
  'j_m2_053': DhikrCard(
    id: 'j_m2_053',
    arabicText: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الثَّبَاتَ فِي الْأَمْرِ، وَالْعَزِيمَةَ عَلَى الرُّشْدِ',
    transliteration: 'Allahumma inni as\'aluka al-thabata fil-amr, wal-\'azimata \'ala al-rushd',
    meaningEn: 'O Allah, I ask You for steadfastness in my affairs and determination upon the right path',
    meaningAr: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الثَّبَاتَ فِي الْأَمْرِ، وَالْعَزِيمَةَ عَلَى الرُّشْدِ',
    count: 'Once daily',
    countAr: null,
    whenToSay: 'Morning or before an important task',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA used to ask Allah for steadfastness and determination, and he taught his companions to seek these two qualities as foundations of success in this world and the next.',
    promiseAr: 'كان النبيّ \uFDFA يسأل الله الثبات والعزيمة، وعلّم أصحابه أن يطلبوا هاتين الصفتين لأنّهما أساس النجاح في الدنيا والآخرة.',
    sourceRef: 'Sunan al-Nasa\'i #1304 (Sahih)',
    sourceRefAr: '',
  ),

  // ── Event 54: Abdullah ibn Jahsh's Expedition ─
  'j_m2_054': DhikrCard(
    id: 'j_m2_054',
    arabicText: 'رَبَّنَا لَا تُؤَاخِذْنَا إِنْ نَسِينَا أَوْ أَخْطَأْنَا',
    transliteration: 'Rabbana la tu\'akhidhna in nasina aw akhta\'na',
    meaningEn: 'Our Lord, do not take us to account if we forget or make a mistake',
    meaningAr: 'رَبَّنَا لَا تُؤَاخِذْنَا إِنْ نَسِينَا أَوْ أَخْطَأْنَا',
    count: 'Once daily',
    countAr: null,
    whenToSay: 'After prayer or before sleep',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA reported that when the believers recited this supplication, Allah said: "I have done so (I have granted it)."',
    promiseAr: 'أخبر النبيّ \uFDFA أنّه لمّا قرأ المؤمنون هذا الدعاء قال الله تعالى: "قد فعلتُ."',
    sourceRef: 'Sahih Muslim #126',
    sourceRefAr: '',
  ),

  // ── Event 55: Road to Badr ─
  'j_m2_055': DhikrCard(
    id: 'j_m2_055',
    arabicText: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْجُبْنِ، وَأَعُوذُ بِكَ مِنَ الْبُخْلِ، وَأَعُوذُ بِكَ مِنْ أَنْ أُرَدَّ إِلَىٰ أَرْذَلِ الْعُمُرِ',
    transliteration: 'Allahumma inni a\'udhu bika min al-jubn, wa a\'udhu bika min al-bukhl, wa a\'udhu bika min an uradda ila ardhali al-\'umur',
    meaningEn: 'O Allah, I seek refuge in You from cowardice, from miserliness, and from being returned to the worst age of life',
    meaningAr: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْجُبْنِ، وَأَعُوذُ بِكَ مِنَ الْبُخْلِ، وَأَعُوذُ بِكَ مِنْ أَنْ أُرَدَّ إِلَىٰ أَرْذَلِ الْعُمُرِ',
    count: 'Once daily',
    countAr: null,
    whenToSay: 'Morning or evening',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA used to seek refuge from these things regularly, teaching that courage and generosity are among the highest qualities a believer can possess.',
    promiseAr: 'كان النبيّ \uFDFA يتعوّذ من هذه الأمور بانتظام، معلّمًا أنّ الشجاعة والسخاء من أعلى صفات المؤمن.',
    sourceRef: 'Sahih al-Bukhari #6390',
    sourceRefAr: '',
  ),

  // ── Event 56: Badr — March to the Well ─
  'j_m2_056': DhikrCard(
    id: 'j_m2_056',
    arabicText: 'اللَّهُمَّ إِنِّي أَسْتَوْدِعُكَ مَا عَلَّمْتَنِي فَارْدُدْهُ إِلَيَّ عِنْدَ حَاجَتِي وَلَا تَنْسِنِيهِ',
    transliteration: 'Allahumma inni astawdi\'uka ma \'allamtani fardudhu ilayya \'inda hajati wa la tansinihi',
    meaningEn: 'O Allah, I entrust to You what You have taught me, so return it to me when I need it and do not let me forget it',
    meaningAr: 'اللَّهُمَّ إِنِّي أَسْتَوْدِعُكَ مَا عَلَّمْتَنِي فَارْدُدْهُ إِلَيَّ عِنْدَ حَاجَتِي وَلَا تَنْسِنِيهِ',
    count: 'Once before studying or important tasks',
    countAr: null,
    whenToSay: 'Before any important undertaking',
    whenToSayAr: '',
    promiseEn: 'Entrusting one\'s affairs to Allah is the essence of tawakkul, and the Prophet \uFDFA taught that whoever relies on Allah, He is sufficient for him.',
    promiseAr: 'تفويض الأمور إلى الله جوهر التوكّل، وقد علّم النبيّ \uFDFA أنّ من يتوكّل على الله فهو حسبه.',
    sourceRef: 'Attributed; supported by Quran 65:3 and the principle of tawakkul in Sahih al-Bukhari #5653',
    sourceRefAr: '',
  ),

  // ── Event 57: Badr — The Battle ─
  'j_m2_057': DhikrCard(
    id: 'j_m2_057',
    arabicText: 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ وَلَا تَكِلْنِي إِلَىٰ نَفْسِي طَرْفَةَ عَيْنٍ',
    transliteration: 'Ya Hayyu ya Qayyum, bi-rahmatika astaghith, aslih li sha\'ni kullahu wa la takilni ila nafsi tarfata \'ayn',
    meaningEn: 'O Ever-Living, O Sustainer, by Your mercy I seek help. Set right all my affairs, and do not leave me to myself for the blink of an eye',
    meaningAr: 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ وَلَا تَكِلْنِي إِلَىٰ نَفْسِي طَرْفَةَ عَيْنٍ',
    count: 'Once in times of difficulty',
    countAr: null,
    whenToSay: 'When facing hardship or anxiety',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA said this supplication encompasses reliance on Allah for all affairs, and whoever says it sincerely, Allah will not leave them to struggle alone.',
    promiseAr: 'قال النبيّ \uFDFA إنّ هذا الدعاء يشمل التوكّل على الله في جميع الأمور، ومن قاله بصدقٍ لم يكله الله إلى نفسه.',
    sourceRef: 'Sunan al-Nasa\'i (Al-Kubra) #10405; graded Hasan by al-Albani',
    sourceRefAr: '',
  ),

  // ── Event 58: Angels of Badr ─
  'j_m2_058': DhikrCard(
    id: 'j_m2_058',
    arabicText: 'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ، صَدَقَ وَعْدَهُ، وَنَصَرَ عَبْدَهُ، وَهَزَمَ الْأَحْزَابَ وَحْدَهُ',
    transliteration: 'La ilaha illallahu wahdah, sadaqa wa\'dah, wa nasara \'abdah, wa hazama al-ahzaba wahdah',
    meaningEn: 'There is no god but Allah alone, He fulfilled His promise, supported His servant, and defeated the parties alone',
    meaningAr: 'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ، صَدَقَ وَعْدَهُ، وَنَصَرَ عَبْدَهُ، وَهَزَمَ الْأَحْزَابَ وَحْدَهُ',
    count: 'Once after returning from any journey or achievement',
    countAr: null,
    whenToSay: 'Upon returning from travel or completing a task',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA used to say this upon returning from expeditions and battles, affirming that all victory comes from Allah alone.',
    promiseAr: 'كان النبيّ \uFDFA يقول هذا الدعاء عند العودة من الغزوات والأسفار، مؤكّدًا أنّ كلّ نصرٍ من الله وحده.',
    sourceRef: 'Sahih al-Bukhari #1797; Sahih Muslim #1344',
    sourceRefAr: '',
  ),

  // ── Event 59: Prisoners of Badr ─
  'j_m2_059': DhikrCard(
    id: 'j_m2_059',
    arabicText: 'اللَّهُمَّ أَلْهِمْنِي رُشْدِي وَأَعِذْنِي مِنْ شَرِّ نَفْسِي',
    transliteration: 'Allahumma alhimni rushdi wa a\'idhni min sharri nafsi',
    meaningEn: 'O Allah, inspire me with right guidance and protect me from the evil of my own self',
    meaningAr: 'اللَّهُمَّ أَلْهِمْنِي رُشْدِي وَأَعِذْنِي مِنْ شَرِّ نَفْسِي',
    count: 'Once daily',
    countAr: null,
    whenToSay: 'Morning or when making a decision',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA taught this du\'a as protection from one\'s own impulses, reminding that the greatest enemy can be within.',
    promiseAr: 'علّم النبيّ \uFDFA هذا الدعاء حمايةً من نزوات النفس، مذكّرًا بأنّ أخطر عدوٍّ قد يكون في الداخل.',
    sourceRef: 'Sunan al-Tirmidhi #3483 (Hasan)',
    sourceRefAr: '',
  ),

  // ── Event 60: Banu Qaynuqa ─
  'j_m2_060': DhikrCard(
    id: 'j_m2_060',
    arabicText: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ',
    transliteration: 'Allahumma inni as\'aluka al-\'afwa wal-\'afiya fi al-dunya wal-akhira',
    meaningEn: 'O Allah, I ask You for pardon and wellbeing in this life and the next',
    meaningAr: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ',
    count: 'Morning and evening',
    countAr: null,
    whenToSay: 'In the morning and evening adhkar',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA said: "Ask Allah for al-\'afiya (wellbeing), for no one is given anything better after certainty of faith than wellbeing."',
    promiseAr: 'قال النبيّ \uFDFA: "سَلُوا اللهَ العافية، فإنّه لم يُعطَ أحدٌ بعد اليقين خيرًا من العافية."',
    sourceRef: 'Sunan al-Tirmidhi #3558; Sunan Ibn Majah #3849 (Sahih)',
    sourceRefAr: '',
  ),

  // ── Event 61: Ka'b ibn al-Ashraf ─
  'j_m2_061': DhikrCard(
    id: 'j_m2_061',
    arabicText: 'اللَّهُمَّ اكْفِنِيهِمْ بِمَا شِئْتَ',
    transliteration: 'Allahumma ikfinihim bima shi\'t',
    meaningEn: 'O Allah, suffice me against them however You will',
    meaningAr: 'اللَّهُمَّ اكْفِنِيهِمْ بِمَا شِئْتَ',
    count: 'When facing opposition or harm',
    countAr: null,
    whenToSay: 'When threatened or facing hostility',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA used to make this supplication when facing those who wished to harm the Muslim community, entrusting the outcome to Allah.',
    promiseAr: 'كان النبيّ \uFDFA يدعو بهذا الدعاء حين يواجه من يريد أذى المجتمع المسلم، مفوّضًا النتيجة إلى الله.',
    sourceRef: 'Sahih Muslim #3005 (contextual; also see Bukhari #2935 for similar wording)',
    sourceRefAr: '',
  ),

  // ── Event 62: Uhud — Quraysh Return ─
  'j_m2_062': DhikrCard(
    id: 'j_m2_062',
    arabicText: 'اللَّهُمَّ مُنْزِلَ الْكِتَابِ، سَرِيعَ الْحِسَابِ، اهْزِمِ الْأَحْزَابَ، اللَّهُمَّ اهْزِمْهُمْ وَزَلْزِلْهُمْ',
    transliteration: 'Allahumma munzila al-kitab, sari\'a al-hisab, ihzim al-ahzab, Allahumma ihzimhum wa zalzilhum',
    meaningEn: 'O Allah, Revealer of the Book, Swift in reckoning, defeat the parties. O Allah, defeat them and shake them',
    meaningAr: 'اللَّهُمَّ مُنْزِلَ الْكِتَابِ، سَرِيعَ الْحِسَابِ، اهْزِمِ الْأَحْزَابَ، اللَّهُمَّ اهْزِمْهُمْ وَزَلْزِلْهُمْ',
    count: 'When facing a threat or trial',
    countAr: null,
    whenToSay: 'In times of communal danger',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA would make this supplication when facing enemy forces, and Allah answered him at Badr, at the Trench, and beyond.',
    promiseAr: 'كان النبيّ \uFDFA يدعو بهذا الدعاء عند مواجهة قوّات العدوّ، واستجاب الله له في بدر والخندق وغيرهما.',
    sourceRef: 'Sahih al-Bukhari #2933; Sahih Muslim #1742',
    sourceRefAr: '',
  ),

  // ── Event 63: Uhud — March Out ─
  'j_m2_063': DhikrCard(
    id: 'j_m2_063',
    arabicText: 'اللَّهُمَّ بَاعِدْ بَيْنِي وَبَيْنَ خَطَايَايَ كَمَا بَاعَدْتَ بَيْنَ الْمَشْرِقِ وَالْمَغْرِبِ',
    transliteration: 'Allahumma ba\'id bayni wa bayna khatayaya kama ba\'adta bayna al-mashriqi wal-maghrib',
    meaningEn: 'O Allah, distance me from my sins as You have distanced the East from the West',
    meaningAr: 'اللَّهُمَّ بَاعِدْ بَيْنِي وَبَيْنَ خَطَايَايَ كَمَا بَاعَدْتَ بَيْنَ الْمَشْرِقِ وَالْمَغْرِبِ',
    count: 'Once in the opening supplication of prayer',
    countAr: null,
    whenToSay: 'At the beginning of prayer (istiftah)',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA used to open his prayer with this supplication, seeking purification from sin as vast as the distance between horizons.',
    promiseAr: 'كان النبيّ \uFDFA يفتتح صلاته بهذا الدعاء طالبًا التطهير من الذنوب بقدر المسافة بين الأفقين.',
    sourceRef: 'Sahih al-Bukhari #744; Sahih Muslim #598',
    sourceRefAr: '',
  ),

  // ── Event 64: Uhud — The Battle ─
  'j_m2_064': DhikrCard(
    id: 'j_m2_064',
    arabicText: 'إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ، اللَّهُمَّ أْجُرْنِي فِي مُصِيبَتِي وَأَخْلِفْ لِي خَيْرًا مِنْهَا',
    transliteration: 'Inna lillahi wa inna ilayhi raji\'un, Allahumma ajurni fi musibati wa akhlif li khayran minha',
    meaningEn: 'To Allah we belong and to Him we return. O Allah, reward me in my calamity and replace it with something better',
    meaningAr: 'إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ، اللَّهُمَّ أْجُرْنِي فِي مُصِيبَتِي وَأَخْلِفْ لِي خَيْرًا مِنْهَا',
    count: 'When calamity strikes',
    countAr: null,
    whenToSay: 'Upon any loss or difficulty',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA said: "There is no Muslim who is struck with a calamity and says this except that Allah rewards him in his calamity and replaces it with something better."',
    promiseAr: 'قال النبيّ \uFDFA: "ما من مسلم تصيبه مصيبة فيقول ذلك إلّا أجره الله في مصيبته وأخلف له خيرًا منها."',
    sourceRef: 'Sahih Muslim #918',
    sourceRefAr: '',
  ),

  // ── Event 65: The Archers' Choice ─
  'j_m2_065': DhikrCard(
    id: 'j_m2_065',
    arabicText: 'رَبَّنَا اغْفِرْ لَنَا ذُنُوبَنَا وَإِسْرَافَنَا فِي أَمْرِنَا وَثَبِّتْ أَقْدَامَنَا وَانْصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ',
    transliteration: 'Rabbana ighfir lana dhunubana wa israfana fi amrina wa thabbit aqdamana wansurna \'ala al-qawm al-kafirin',
    meaningEn: 'Our Lord, forgive us our sins and our excess in our affairs, and make our feet firm, and give us victory over the disbelieving people',
    meaningAr: 'رَبَّنَا اغْفِرْ لَنَا ذُنُوبَنَا وَإِسْرَافَنَا فِي أَمْرِنَا وَثَبِّتْ أَقْدَامَنَا وَانْصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ',
    count: 'Once when seeking forgiveness and resolve',
    countAr: null,
    whenToSay: 'After making mistakes or in times of difficulty',
    whenToSayAr: '',
    promiseEn: 'This is the supplication the Quran attributes to the righteous who came before, who combined asking for forgiveness with asking for steadfastness. Allah responded: "So Allah gave them the reward of this world and the good reward of the Hereafter" (3:148).',
    promiseAr: 'هذا الدعاء الذي نسبه القرآن للصالحين من قبل، الذين جمعوا بين طلب المغفرة وطلب الثبات. فاستجاب الله: ﴿فَآتَاهُمُ اللَّهُ ثَوَابَ الدُّنْيَا وَحُسْنَ ثَوَابِ الْآخِرَةِ﴾.',
    sourceRef: 'Quran 3:147-148',
    sourceRefAr: '',
  ),

  // ── Event 66: Hamza's Martyrdom ─
  'j_m2_066': DhikrCard(
    id: 'j_m2_066',
    arabicText: 'اللَّهُمَّ اغْفِرْ لِحَيِّنَا وَمَيِّتِنَا وَشَاهِدِنَا وَغَائِبِنَا وَصَغِيرِنَا وَكَبِيرِنَا',
    transliteration: 'Allahumma ighfir li-hayyina wa mayyitina wa shahidina wa gha\'ibina wa saghirina wa kabirina',
    meaningEn: 'O Allah, forgive our living and our dead, those present and those absent, our young and our old',
    meaningAr: 'اللَّهُمَّ اغْفِرْ لِحَيِّنَا وَمَيِّتِنَا وَشَاهِدِنَا وَغَائِبِنَا وَصَغِيرِنَا وَكَبِيرِنَا',
    count: 'Once in funeral prayer or when remembering the dead',
    countAr: null,
    whenToSay: 'In salat al-janazah or when remembering the deceased',
    whenToSayAr: '',
    promiseEn: 'This is from the Prophet\'s \uFDFA funeral prayer supplication, teaching the community to pray for all their dead, past and present, with comprehensive mercy.',
    promiseAr: 'هذا من دعاء صلاة الجنازة الذي علّمه النبيّ \uFDFA، يعلّم الأمّة أن تدعو لجميع موتاها بالرحمة الشاملة.',
    sourceRef: 'Sunan Abu Dawud #3201; Sunan Ibn Majah #1498 (Sahih)',
    sourceRefAr: '',
  ),

  // ⚠️ NEEDS REVIEW — Event #67
  // ── Event 67: Hamra al-Asad ─
  'j_m2_067': DhikrCard(
    id: 'j_m2_067',
    arabicText: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
    transliteration: 'Hasbunallahu wa ni\'ma al-wakil',
    meaningEn: 'Sufficient for us is Allah, and He is the best disposer of affairs',
    meaningAr: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
    count: 'Seven times morning and evening',
    countAr: null,
    whenToSay: 'When facing fear or overwhelming odds',
    whenToSayAr: '',
    promiseEn: 'This is the very phrase the companions said at Hamra al-Asad, and Allah praised them for it in the Quran. The Prophet \uFDFA said Ibrahim عليه السلام said it when thrown into the fire, and it was sufficient.',
    promiseAr: 'هذه العبارة ذاتها التي قالها الصحابة في حمراء الأسد فأثنى عليهم الله في القرآن. وقال النبيّ \uFDFA إنّ إبراهيم عليه السلام قالها حين أُلقي في النار فكانت كافية.',
    sourceRef: 'Quran 3:173; Sahih al-Bukhari #4563',
    sourceRefAr: '',
  ),

  // ── Event 68: Raji' Incident ─
  'j_m2_068': DhikrCard(
    id: 'j_m2_068',
    arabicText: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ رِضَاكَ وَالْجَنَّةَ وَأَعُوذُ بِكَ مِنْ سَخَطِكَ وَالنَّارِ',
    transliteration: 'Allahumma inni as\'aluka ridaka wal-jannah, wa a\'udhu bika min sakhatika wan-nar',
    meaningEn: 'O Allah, I ask You for Your pleasure and Paradise, and I seek refuge in You from Your anger and the Fire',
    meaningAr: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ رِضَاكَ وَالْجَنَّةَ وَأَعُوذُ بِكَ مِنْ سَخَطِكَ وَالنَّارِ',
    count: 'Three times morning and evening',
    countAr: null,
    whenToSay: 'After Fajr and Maghrib',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA said: "If anyone asks Allah for Paradise three times, Paradise says: O Allah, admit him to Paradise. And if anyone seeks refuge from the Fire three times, the Fire says: O Allah, protect him from the Fire."',
    promiseAr: 'قال النبيّ \uFDFA: "من سأل الله الجنّة ثلاث مرّات قالت الجنّة: اللهمّ أدخله الجنّة. ومن استجار من النار ثلاثًا قالت النار: اللهمّ أجره من النار."',
    sourceRef: 'Sunan al-Tirmidhi #2572; Sunan al-Nasa\'i #5521 (Sahih)',
    sourceRefAr: '',
  ),

  // ── Event 69: Bi'r Ma'una ─
  'j_m2_069': DhikrCard(
    id: 'j_m2_069',
    arabicText: 'اللَّهُمَّ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ فَاطِرَ السَّمَاوَاتِ وَالْأَرْضِ رَبَّ كُلِّ شَيْءٍ وَمَلِيكَهُ، أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا أَنْتَ',
    transliteration: 'Allahumma \'alima al-ghaybi wash-shahadah, fatira al-samawati wal-ard, rabba kulli shay\'in wa malikah, ash-hadu an la ilaha illa ant',
    meaningEn: 'O Allah, Knower of the unseen and the seen, Creator of the heavens and the earth, Lord and Sovereign of all things, I bear witness that there is no god but You',
    meaningAr: 'اللَّهُمَّ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ فَاطِرَ السَّمَاوَاتِ وَالْأَرْضِ رَبَّ كُلِّ شَيْءٍ وَمَلِيكَهُ، أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا أَنْتَ',
    count: 'Once before sleep',
    countAr: null,
    whenToSay: 'Before sleeping',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA said whoever says this supplication in full before sleep will be protected from any harm until morning.',
    promiseAr: 'قال النبيّ \uFDFA إنّ من قال هذا الدعاء كاملًا قبل النوم حُفظ من كلّ أذىً حتّى الصباح.',
    sourceRef: 'Sunan Abu Dawud #5067; Sunan al-Tirmidhi #3392 (Hasan)',
    sourceRefAr: '',
  ),

  // ── Event 70: Banu Nadir Expelled ─
  'j_m2_070': DhikrCard(
    id: 'j_m2_070',
    arabicText: 'اللَّهُمَّ مَالِكَ الْمُلْكِ تُؤْتِي الْمُلْكَ مَنْ تَشَاءُ وَتَنْزِعُ الْمُلْكَ مِمَّنْ تَشَاءُ',
    transliteration: 'Allahumma malika al-mulk, tu\'ti al-mulka man tasha\'u wa tanzi\'u al-mulka mimman tasha\'',
    meaningEn: 'O Allah, Owner of Sovereignty, You give sovereignty to whom You will and You take sovereignty from whom You will',
    meaningAr: 'اللَّهُمَّ مَالِكَ الْمُلْكِ تُؤْتِي الْمُلْكَ مَنْ تَشَاءُ وَتَنْزِعُ الْمُلْكَ مِمَّنْ تَشَاءُ',
    count: 'Once when reflecting on power and provision',
    countAr: null,
    whenToSay: 'When witnessing shifts in fortune or power',
    whenToSayAr: '',
    promiseEn: 'This supplication is drawn from Quran 3:26, reminding the believer that all power belongs to Allah alone and that He elevates and humbles whom He wills.',
    promiseAr: 'هذا الدعاء مأخوذ من الآية 26 من سورة آل عمران، يذكّر المؤمن بأنّ كلّ سلطة لله وحده وأنّه يرفع ويخفض من يشاء.',
    sourceRef: 'Quran 3:26',
    sourceRefAr: '',
  ),

  // ⚠️ NEEDS REVIEW — Event #71
  // ── Event 71: Badr al-Maw'id ─
  'j_m2_071': DhikrCard(
    id: 'j_m2_071',
    arabicText: 'اللَّهُمَّ لَا مَانِعَ لِمَا أَعْطَيْتَ وَلَا مُعْطِيَ لِمَا مَنَعْتَ وَلَا يَنْفَعُ ذَا الْجَدِّ مِنْكَ الْجَدُّ',
    transliteration: 'Allahumma la mani\'a lima a\'tayt, wa la mu\'tiya lima mana\'t, wa la yanfa\'u dhal-jaddi minka al-jadd',
    meaningEn: 'O Allah, none can withhold what You give, and none can give what You withhold, and the fortune of the fortunate will not avail them against You',
    meaningAr: 'اللَّهُمَّ لَا مَانِعَ لِمَا أَعْطَيْتَ وَلَا مُعْطِيَ لِمَا مَنَعْتَ وَلَا يَنْفَعُ ذَا الْجَدِّ مِنْكَ الْجَدُّ',
    count: 'After every obligatory prayer',
    countAr: null,
    whenToSay: 'After the taslim of prayer',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA used to say this after every prayer, reminding believers that all provision, victory, and honor come from Allah alone.',
    promiseAr: 'كان النبيّ \uFDFA يقول هذا الدعاء بعد كلّ صلاة، مذكّرًا المؤمنين بأنّ كلّ رزقٍ ونصرٍ وعزّة من الله وحده.',
    sourceRef: 'Sahih al-Bukhari #844; Sahih Muslim #593',
    sourceRefAr: '',
  ),

  // ── Event 72: Banu Mustaliq ─
  'j_m2_072': DhikrCard(
    id: 'j_m2_072',
    arabicText: 'اللَّهُمَّ أَعِزَّ الْإِسْلَامَ وَالْمُسْلِمِينَ',
    transliteration: 'Allahumma a\'izza al-Islam wal-Muslimin',
    meaningEn: 'O Allah, honor Islam and the Muslims',
    meaningAr: 'اللَّهُمَّ أَعِزَّ الْإِسْلَامَ وَالْمُسْلِمِينَ',
    count: 'Once daily',
    countAr: null,
    whenToSay: 'Whenever one prays for the Ummah',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA constantly prayed for the honor of Islam and its people, and this supplication embodies the spirit of seeking collective dignity and strength through reliance on Allah.',
    promiseAr: 'كان النبيّ \uFDFA يدعو دائمًا لعزّة الإسلام وأهله، وهذا الدعاء يجسّد روح طلب الكرامة والقوّة الجماعية بالتوكّل على الله.',
    sourceRef: 'Authentic supplication; supported by the principle in Quran 63:8',
    sourceRefAr: '',
  ),

  // ── Event 73: The Slander — Al-Ifk ─
  'j_m2_073': DhikrCard(
    id: 'j_m2_073',
    arabicText: 'سُبْحَانَكَ هَٰذَا بُهْتَانٌ عَظِيمٌ',
    transliteration: 'Subhanaka hadha buhtanun \'azim',
    meaningEn: 'Glory be to You, O Allah! This is a great slander',
    meaningAr: 'سُبْحَانَكَ هَٰذَا بُهْتَانٌ عَظِيمٌ',
    count: 'When hearing false accusations',
    countAr: null,
    whenToSay: 'When confronted with slander or lies about others',
    whenToSayAr: '',
    promiseEn: 'This was the response the Quran expected from the believers when they first heard the slander (24:16). Those who said it demonstrated true faith. It teaches that the first instinct of a believer upon hearing evil about another should be to deny it and glorify Allah.',
    promiseAr: 'هذا هو الردّ الذي توقّعه القرآن من المؤمنين حين سمعوا الإفك أوّل مرّة. من قالها أثبت إيمانه الحقيقي. يعلّمنا أنّ أوّل ردّ فعل للمؤمن حين يسمع سوءًا عن غيره ينبغي أن يكون الإنكار وتنزيه الله.',
    sourceRef: 'Quran 24:16',
    sourceRefAr: '',
  ),

  // ── Event 74: Digging the Trench ─
  'j_m2_074': DhikrCard(
    id: 'j_m2_074',
    arabicText: 'اللَّهُمَّ لَا عَيْشَ إِلَّا عَيْشُ الْآخِرَةِ، فَاغْفِرْ لِلْأَنْصَارِ وَالْمُهَاجِرَةِ',
    transliteration: 'Allahumma la \'aysha illa \'aysh al-akhira, faghfir lil-Ansar wal-Muhajira',
    meaningEn: 'O Allah, there is no life worth living except the life of the Hereafter, so forgive the Ansar and the Muhajirun',
    meaningAr: 'اللَّهُمَّ لَا عَيْشَ إِلَّا عَيْشُ الْآخِرَةِ، فَاغْفِرْ لِلْأَنْصَارِ وَالْمُهَاجِرَةِ',
    count: 'When working hard for a cause',
    countAr: null,
    whenToSay: 'During labor or hardship for a good cause',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA said this while digging the trench with blistered hands and an empty stomach. It became a chant that the companions repeated as they dug, reminding each other that their labor was for something that outlasted this world.',
    promiseAr: 'قال النبيّ \uFDFA هذا وهو يحفر الخندق بيدين متقرّحتين ومعدة فارغة. أصبح نشيدًا يردّده الصحابة وهم يحفرون يذكّرون بعضهم بأنّ عملهم لشيءٍ يتجاوز هذه الدنيا.',
    sourceRef: 'Sahih al-Bukhari #4099; Sahih Muslim #1805',
    sourceRefAr: '',
  ),

  // ── Event 75: Trench — The Siege ─
  'j_m2_075': DhikrCard(
    id: 'j_m2_075',
    arabicText: 'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ، أَعَزَّ جُنْدَهُ، وَنَصَرَ عَبْدَهُ، وَغَلَبَ الْأَحْزَابَ وَحْدَهُ',
    transliteration: 'La ilaha illallahu wahdah, a\'azza jundahu, wa nasara \'abdah, wa ghalaba al-ahzaba wahdah',
    meaningEn: 'There is no god but Allah alone, He strengthened His soldiers, supported His servant, and defeated the parties alone',
    meaningAr: 'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ، أَعَزَّ جُنْدَهُ، وَنَصَرَ عَبْدَهُ، وَغَلَبَ الْأَحْزَابَ وَحْدَهُ',
    count: 'Once when relieved of a trial',
    countAr: null,
    whenToSay: 'After a difficulty passes',
    whenToSayAr: '',
    promiseEn: 'This echoes the Prophet\'s \uFDFA supplication after the Confederates withdrew. It affirms that ultimate victory comes from Allah, no matter the size of the opposing force.',
    promiseAr: 'يردّد صدى دعاء النبيّ \uFDFA بعد انسحاب الأحزاب. يؤكّد أنّ النصر النهائي من الله مهما كان حجم القوّة المعارضة.',
    sourceRef: 'Sahih al-Bukhari #1597 (similar wording in travel du\'a)',
    sourceRefAr: '',
  ),

  // ── Event 76: Nu'aym ibn Mas'ud's Stratagem ─
  'j_m2_076': DhikrCard(
    id: 'j_m2_076',
    arabicText: 'اللَّهُمَّ اجْعَلْ لِي فِي قَلْبِي نُورًا وَفِي لِسَانِي نُورًا وَفِي سَمْعِي نُورًا وَفِي بَصَرِي نُورًا',
    transliteration: 'Allahumma ij\'al li fi qalbi nuran wa fi lisani nuran wa fi sam\'i nuran wa fi basari nuran',
    meaningEn: 'O Allah, place light in my heart, light in my tongue, light in my hearing, and light in my sight',
    meaningAr: 'اللَّهُمَّ اجْعَلْ لِي فِي قَلْبِي نُورًا وَفِي لِسَانِي نُورًا وَفِي سَمْعِي نُورًا وَفِي بَصَرِي نُورًا',
    count: 'Once before important speech or decisions',
    countAr: null,
    whenToSay: 'When seeking clarity and guidance',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA made this supplication asking for light in every faculty. Scholars note that one who is granted such light sees through deception and speaks with impact, as Nu\'aym did at the Trench.',
    promiseAr: 'دعا النبيّ \uFDFA بهذا الدعاء طالبًا النور في كلّ حاسّة. ويلاحظ العلماء أنّ من يُمنح هذا النور يرى من وراء الخداع ويتكلّم بأثر، كما فعل نعيم في الخندق.',
    sourceRef: 'Sahih al-Bukhari #6316; Sahih Muslim #763',
    sourceRefAr: '',
  ),

  // ⚠️ NEEDS REVIEW — Event #77
  // ── Event 77: Amr ibn Abd Wudd — The Duel ─
  'j_m2_077': DhikrCard(
    id: 'j_m2_077',
    arabicText: 'رَبِّ أَوْزِعْنِي أَنْ أَشْكُرَ نِعْمَتَكَ الَّتِي أَنْعَمْتَ عَلَيَّ وَعَلَىٰ وَالِدَيَّ وَأَنْ أَعْمَلَ صَالِحًا تَرْضَاهُ',
    transliteration: 'Rabbi awzi\'ni an ashkura ni\'mataka allati an\'amta \'alayya wa \'ala walidayya wa an a\'mala salihan tardahu',
    meaningEn: 'My Lord, inspire me to be grateful for Your favor which You bestowed upon me and upon my parents, and to do righteousness that pleases You',
    meaningAr: 'رَبِّ أَوْزِعْنِي أَنْ أَشْكُرَ نِعْمَتَكَ الَّتِي أَنْعَمْتَ عَلَيَّ وَعَلَىٰ وَالِدَيَّ وَأَنْ أَعْمَلَ صَالِحًا تَرْضَاهُ',
    count: 'Once daily',
    countAr: null,
    whenToSay: 'After success or receiving a blessing',
    whenToSayAr: '',
    promiseEn: 'This Quranic supplication teaches that every victory and blessing requires gratitude, and that gratitude itself is an act of worship that draws one closer to Allah.',
    promiseAr: 'يعلّم هذا الدعاء القرآني أنّ كلّ نصرٍ ونعمة يستلزم الشكر، وأنّ الشكر ذاته عبادة تقرّب العبد إلى الله.',
    sourceRef: 'Quran 27:19',
    sourceRefAr: '',
  ),

  // ── Event 78: The Wind of Victory ─
  'j_m2_078': DhikrCard(
    id: 'j_m2_078',
    arabicText: 'اللَّهُمَّ لَكَ الْحَمْدُ كُلُّهُ، وَلَكَ الْمُلْكُ كُلُّهُ، وَبِيَدِكَ الْخَيْرُ كُلُّهُ، وَإِلَيْكَ يُرْجَعُ الْأَمْرُ كُلُّهُ',
    transliteration: 'Allahumma laka al-hamdu kulluh, wa laka al-mulku kulluh, wa bi-yadika al-khayru kulluh, wa ilayka yurja\'u al-amru kulluh',
    meaningEn: 'O Allah, all praise is Yours, all sovereignty is Yours, all good is in Your hand, and all affairs return to You',
    meaningAr: 'اللَّهُمَّ لَكَ الْحَمْدُ كُلُّهُ، وَلَكَ الْمُلْكُ كُلُّهُ، وَبِيَدِكَ الْخَيْرُ كُلُّهُ، وَإِلَيْكَ يُرْجَعُ الْأَمْرُ كُلُّهُ',
    count: 'Once upon witnessing divine help',
    countAr: null,
    whenToSay: 'After major relief or witnessing Allah\'s plan unfold',
    whenToSayAr: '',
    promiseEn: 'This comprehensive praise acknowledges that every outcome, every wind, every turning point belongs to Allah alone. The believer says it when they witness divine intervention they cannot explain by human effort.',
    promiseAr: 'هذا الحمد الشامل يعترف بأنّ كلّ نتيجة وكلّ ريحٍ وكلّ نقطة تحوّل تعود إلى الله وحده. يقوله المؤمن حين يشهد تدخّلًا إلهيًّا لا يُفسَّر بجهد بشري.',
    sourceRef: 'Sahih Muslim #771 (part of longer night prayer supplication)',
    sourceRefAr: '',
  ),

  // ── Event 79: Banu Qurayza — Siege ─
  'j_m2_079': DhikrCard(
    id: 'j_m2_079',
    arabicText: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ زَوَالِ نِعْمَتِكَ وَتَحَوُّلِ عَافِيَتِكَ وَفُجَاءَةِ نِقْمَتِكَ وَجَمِيعِ سَخَطِكَ',
    transliteration: 'Allahumma inni a\'udhu bika min zawali ni\'matik, wa tahawwuli \'afiyatik, wa fuja\'ati niqmatik, wa jami\'i sakhatik',
    meaningEn: 'O Allah, I seek refuge in You from the withdrawal of Your blessing, the loss of Your protection, Your sudden punishment, and all Your displeasure',
    meaningAr: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ زَوَالِ نِعْمَتِكَ وَتَحَوُّلِ عَافِيَتِكَ وَفُجَاءَةِ نِقْمَتِكَ وَجَمِيعِ سَخَطِكَ',
    count: 'Once daily',
    countAr: null,
    whenToSay: 'Morning or evening',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA sought refuge from these four things, teaching that all blessings are temporary unless maintained through obedience, and that the loss of divine favor is the greatest calamity.',
    promiseAr: 'تعوّذ النبيّ \uFDFA من هذه الأربع، معلّمًا أنّ كلّ النعم مؤقّتة ما لم تُصَن بالطاعة، وأنّ فقدان الرضا الإلهيّ أعظم المصائب.',
    sourceRef: 'Sahih Muslim #2739',
    sourceRefAr: '',
  ),

  // ── Event 80: Judgment of Sa'd ibn Mu'adh ─
  'j_m2_080': DhikrCard(
    id: 'j_m2_080',
    arabicText: 'اللَّهُمَّ أَحْسِنْ عَاقِبَتَنَا فِي الْأُمُورِ كُلِّهَا وَأَجِرْنَا مِنْ خِزْيِ الدُّنْيَا وَعَذَابِ الْآخِرَةِ',
    transliteration: 'Allahumma ahsin \'aqibatana fil-umuri kulliha wa ajirna min khizyi al-dunya wa \'adhab al-akhira',
    meaningEn: 'O Allah, make the end of all our affairs good, and protect us from the disgrace of this world and the punishment of the Hereafter',
    meaningAr: 'اللَّهُمَّ أَحْسِنْ عَاقِبَتَنَا فِي الْأُمُورِ كُلِّهَا وَأَجِرْنَا مِنْ خِزْيِ الدُّنْيَا وَعَذَابِ الْآخِرَةِ',
    count: 'Once daily',
    countAr: null,
    whenToSay: 'Morning or when reflecting on one\'s choices',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA taught this supplication as protection against endings that are worse than beginnings, a reminder that the consequences of our choices follow us.',
    promiseAr: 'علّم النبيّ \uFDFA هذا الدعاء حمايةً من نهاياتٍ أسوأ من البدايات، تذكيرًا بأنّ عواقب خياراتنا تلاحقنا.',
    sourceRef: 'Musnad Ahmad #18325 (Sahih by al-Albani)',
    sourceRefAr: '',
  ),

  // ── Event 81: Sa'd ibn Mu'adh — Martyrdom ─
  'j_m2_081': DhikrCard(
    id: 'j_m2_081',
    arabicText: 'اللَّهُمَّ ثَبِّتْنِي عِنْدَ السُّؤَالِ',
    transliteration: 'Allahumma thabbitni \'inda al-su\'al',
    meaningEn: 'O Allah, make me firm at the time of questioning (in the grave)',
    meaningAr: 'اللَّهُمَّ ثَبِّتْنِي عِنْدَ السُّؤَالِ',
    count: 'After every prayer',
    countAr: null,
    whenToSay: 'After salah or when remembering death',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA taught that even Sa\'d was not spared the test of the grave, reminding believers to regularly ask Allah for firmness at that moment. Consistent supplication builds readiness for what lies ahead.',
    promiseAr: 'علّم النبيّ \uFDFA أنّ حتّى سعدًا لم يُعفَ من امتحان القبر، مذكّرًا المؤمنين بأن يسألوا الله الثبات عند ذلك بانتظام. الدعاء المستمر يبني الاستعداد لما ينتظر.',
    sourceRef: 'Supported by Sahih Muslim #2466; general principle from Sunan Abu Dawud #4868',
    sourceRefAr: '',
  ),

  // ── Event 82: The Throne of Allah Shook ─
  'j_m2_082': DhikrCard(
    id: 'j_m2_082',
    arabicText: 'رَضِيتُ بِاللَّهِ رَبًّا وَبِالْإِسْلَامِ دِينًا وَبِمُحَمَّدٍ \uFDFA نَبِيًّا وَرَسُولًا',
    transliteration: 'Raditu billahi Rabban, wa bil-Islami dinan, wa bi-Muhammadin \uFDFA nabiyyan wa rasula',
    meaningEn: 'I am pleased with Allah as my Lord, Islam as my religion, and Muhammad \uFDFA as my Prophet and Messenger',
    meaningAr: 'رَضِيتُ بِاللَّهِ رَبًّا وَبِالْإِسْلَامِ دِينًا وَبِمُحَمَّدٍ \uFDFA نَبِيًّا وَرَسُولًا',
    count: 'Three times after Fajr and Maghrib',
    countAr: null,
    whenToSay: 'Morning and evening',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA said: "Whoever says this three times in the morning and evening, it becomes a right upon Allah to please him on the Day of Resurrection."',
    promiseAr: 'قال النبيّ \uFDFA: "من قالها ثلاثًا حين يصبح وثلاثًا حين يمسي كان حقًّا على الله أن يُرضيه يوم القيامة."',
    sourceRef: 'Sunan Abu Dawud #5072; Musnad Ahmad (Sahih)',
    sourceRefAr: '',
  ),

  // ⚠️ NEEDS REVIEW — Event #83
  // ── Event 83: Post-Khandaq Expeditions ─
  'j_m3_083': DhikrCard(
    id: 'j_m3_083',
    arabicText: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي',
    transliteration: 'Allahumma inni as\'aluka al-\'afiya fi dini wa dunyaya wa ahli wa mali',
    meaningEn: 'O Allah, I ask You for wellbeing in my religion, my worldly affairs, my family, and my wealth',
    meaningAr: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي',
    count: 'Once morning and evening',
    countAr: null,
    whenToSay: 'Morning and evening adhkar',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA said: "Ask Allah for al-\'afiya (wellbeing), for after certainty of faith, no one is given anything better than wellbeing."',
    promiseAr: 'قال النبيّ \uFDFA: "سلوا الله العافية، فإنّه لم يُعطَ أحدٌ بعد اليقين خيرًا من العافية."',
    sourceRef: 'Sunan al-Tirmidhi #3558; Sunan Ibn Majah #3849 (Sahih)',
    sourceRefAr: '',
  ),

  // ── Event 84: Journey to Hudaybiyyah ─
  'j_m3_084': DhikrCard(
    id: 'j_m3_084',
    arabicText: 'اللَّهُمَّ يَسِّرْ وَلَا تُعَسِّرْ، وَتَمِّمْ بِالْخَيْرِ',
    transliteration: 'Allahumma yassir wa la tu\'assir, wa tammim bil-khayr',
    meaningEn: 'O Allah, make it easy and not difficult, and complete it with goodness',
    meaningAr: 'اللَّهُمَّ يَسِّرْ وَلَا تُعَسِّرْ، وَتَمِّمْ بِالْخَيْرِ',
    count: 'Before any journey or task',
    countAr: null,
    whenToSay: 'When beginning something difficult',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA taught the companions to ask for ease in all undertakings, trusting that Allah\'s plan, even when it seems difficult, leads to the best outcome.',
    promiseAr: 'علّم النبيّ \uFDFA الصحابة أن يطلبوا التيسير في كلّ عمل، واثقين بأنّ خطّة الله حتّى حين تبدو صعبة تقود إلى أفضل نتيجة.',
    sourceRef: 'Attributed; principle supported by Quran 94:5-6 and Sahih al-Bukhari (general)',
    sourceRefAr: '',
  ),

  // ── Event 85: The She-Camel Kneels ─
  'j_m3_085': DhikrCard(
    id: 'j_m3_085',
    arabicText: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ هَٰذَا الْيَوْمِ فَتْحَهُ وَنَصْرَهُ وَنُورَهُ وَبَرَكَتَهُ وَهُدَاهُ',
    transliteration: 'Allahumma inni as\'aluka khayra hadha al-yawm, fat-hahu wa nasrahu wa nurahu wa barakatahu wa hudahu',
    meaningEn: 'O Allah, I ask You for the goodness of this day — its opening, victory, light, blessing, and guidance',
    meaningAr: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ هَٰذَا الْيَوْمِ فَتْحَهُ وَنَصْرَهُ وَنُورَهُ وَبَرَكَتَهُ وَهُدَاهُ',
    count: 'Once every morning',
    countAr: null,
    whenToSay: 'After Fajr',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA taught this morning supplication, seeking the best of each new day. The journey to Hudaybiyyah began with prayer and ended with the greatest diplomatic victory in the Seerah.',
    promiseAr: 'علّم النبيّ \uFDFA دعاء الصباح هذا طلبًا لخير كلّ يومٍ جديد. رحلة الحديبية بدأت بالدعاء وانتهت بأعظم نصرٍ دبلوماسي في السيرة.',
    sourceRef: 'Sunan Abu Dawud #5084 (Hasan)',
    sourceRefAr: '',
  ),

  // ── Event 86: Bay'at al-Ridwan ─
  'j_m3_086': DhikrCard(
    id: 'j_m3_086',
    arabicText: 'سَمِعْنَا وَأَطَعْنَا غُفْرَانَكَ رَبَّنَا وَإِلَيْكَ الْمَصِيرُ',
    transliteration: 'Sami\'na wa ata\'na, ghufranaka Rabbana wa ilayka al-masir',
    meaningEn: 'We hear and we obey. Grant us Your forgiveness, our Lord, and to You is the return',
    meaningAr: 'سَمِعْنَا وَأَطَعْنَا غُفْرَانَكَ رَبَّنَا وَإِلَيْكَ الْمَصِيرُ',
    count: 'Once when renewing commitment',
    countAr: null,
    whenToSay: 'When committing to something important',
    whenToSayAr: '',
    promiseEn: 'This is the response of the believers recorded in the Quran (2:285). It embodies the spirit of the Bay\'ah: hearing the call and obeying without hesitation.',
    promiseAr: 'هذا ردّ المؤمنين المسجّل في القرآن. يجسّد روح البيعة: سماع النداء والطاعة دون تردّد.',
    sourceRef: 'Quran 2:285',
    sourceRefAr: '',
  ),

  // ── Event 87: Treaty of Hudaybiyyah ─
  'j_m3_087': DhikrCard(
    id: 'j_m3_087',
    arabicText: 'اللَّهُمَّ إِنِّي أَسْتَخِيرُكَ بِعِلْمِكَ وَأَسْتَقْدِرُكَ بِقُدْرَتِكَ وَأَسْأَلُكَ مِنْ فَضْلِكَ الْعَظِيمِ',
    transliteration: 'Allahumma inni astakhiruka bi-\'ilmik, wa astaqdiruka bi-qudratik, wa as\'aluka min fadlika al-\'azim',
    meaningEn: 'O Allah, I seek Your guidance through Your knowledge, seek ability through Your power, and ask from Your immense favor',
    meaningAr: 'اللَّهُمَّ إِنِّي أَسْتَخِيرُكَ بِعِلْمِكَ وَأَسْتَقْدِرُكَ بِقُدْرَتِكَ وَأَسْأَلُكَ مِنْ فَضْلِكَ الْعَظِيمِ',
    count: 'In istikhara prayer',
    countAr: null,
    whenToSay: 'Before making a difficult decision',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA taught istikhara as the believer\'s tool for every important decision, trusting that Allah sees what we cannot. Hudaybiyyah was the ultimate proof: what seemed worst was actually best.',
    promiseAr: 'علّم النبيّ \uFDFA الاستخارة أداة المؤمن لكلّ قرارٍ مهمّ، واثقًا بأنّ الله يرى ما لا نرى. الحديبية كانت البرهان الأعظم: ما بدا أسوأ كان في الحقيقة أفضل.',
    sourceRef: 'Sahih al-Bukhari #1162 (opening of istikhara du\'a)',
    sourceRefAr: '',
  ),

  // ── Event 88: Surah Al-Fath — A Clear Victory ─
  'j_m3_088': DhikrCard(
    id: 'j_m3_088',
    arabicText: 'رَبَّنَا آتِنَا مِنْ لَدُنْكَ رَحْمَةً وَهَيِّئْ لَنَا مِنْ أَمْرِنَا رَشَدًا',
    transliteration: 'Rabbana atina min ladunka rahmah, wa hayyi\' lana min amrina rashada',
    meaningEn: 'Our Lord, grant us mercy from Yourself and prepare for us right guidance in our affair',
    meaningAr: 'رَبَّنَا آتِنَا مِنْ لَدُنْكَ رَحْمَةً وَهَيِّئْ لَنَا مِنْ أَمْرِنَا رَشَدًا',
    count: 'When facing uncertainty',
    countAr: null,
    whenToSay: 'When events seem confusing or unfair',
    whenToSayAr: '',
    promiseEn: 'This supplication from the people of the Cave (Quran 18:10) asks Allah to guide when the path is unclear. Hudaybiyyah teaches that Allah\'s plan may look nothing like what we expect, yet it is always better.',
    promiseAr: 'هذا الدعاء من أصحاب الكهف يطلب من الله الهداية حين يكون الطريق غامضًا. الحديبية تعلّم أنّ خطّة الله قد لا تشبه ما نتوقّعه لكنّها دائمًا أفضل.',
    sourceRef: 'Quran 18:10',
    sourceRefAr: '',
  ),

  // ── Event 89: Letter to Heraclius ─
  'j_m3_089': DhikrCard(
    id: 'j_m3_089',
    arabicText: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنَ الْخَيْرِ كُلِّهِ عَاجِلِهِ وَآجِلِهِ مَا عَلِمْتُ مِنْهُ وَمَا لَمْ أَعْلَمْ',
    transliteration: 'Allahumma inni as\'aluka min al-khayri kullihi \'ajilihi wa ajilihi ma \'alimtu minhu wa ma lam a\'lam',
    meaningEn: 'O Allah, I ask You for all goodness, immediate and delayed, what I know of it and what I do not know',
    meaningAr: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنَ الْخَيْرِ كُلِّهِ عَاجِلِهِ وَآجِلِهِ مَا عَلِمْتُ مِنْهُ وَمَا لَمْ أَعْلَمْ',
    count: 'Once daily',
    countAr: null,
    whenToSay: 'In du\'a after prayer',
    whenToSayAr: '',
    promiseEn: 'This comprehensive du\'a asks Allah for every form of goodness, including outcomes we cannot foresee. The Prophet \uFDFA used it to teach that the believer should seek all good from Allah, trusting that He knows what we need better than we do.',
    promiseAr: 'يطلب هذا الدعاء الشامل من الله كلّ خير بما فيه النتائج التي لا نتوقّعها. استخدمه النبيّ \uFDFA ليعلّم أنّ المؤمن يطلب كلّ خير من الله واثقًا بأنّه يعلم حاجاتنا أفضل منّا.',
    sourceRef: 'Sunan Ibn Majah #3846; Musnad Ahmad (Sahih)',
    sourceRefAr: '',
  ),

  // ── Event 90: Letter to Chosroes ─
  'j_m3_090': DhikrCard(
    id: 'j_m3_090',
    arabicText: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ شَرِّ كُلِّ ذِي شَرٍّ أَنْتَ آخِذٌ بِنَاصِيَتِهِ',
    transliteration: 'Allahumma inni a\'udhu bika min sharri kulli dhi sharr, anta akhidhun bi-nasiyatih',
    meaningEn: 'O Allah, I seek refuge in You from the evil of every evil creature whose forelock You hold',
    meaningAr: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ شَرِّ كُلِّ ذِي شَرٍّ أَنْتَ آخِذٌ بِنَاصِيَتِهِ',
    count: 'Once when facing the arrogant or oppressive',
    countAr: null,
    whenToSay: 'When facing tyranny or arrogance',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA taught that every creature\'s fate is in Allah\'s hands. The most powerful emperor on earth was struck down from within his own palace, reminding that no tyrant is beyond Allah\'s reach.',
    promiseAr: 'علّم النبيّ \uFDFA أنّ مصير كلّ مخلوقٍ بيد الله. أقوى إمبراطور على الأرض ضُرب من داخل قصره مذكّرًا بأنّه لا طاغية خارج متناول الله.',
    sourceRef: 'Sahih Muslim #2713',
    sourceRefAr: '',
  ),

  // ── Event 91: Letter to the Negus ─
  'j_m3_091': DhikrCard(
    id: 'j_m3_091',
    arabicText: 'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
    transliteration: 'Allahumma anta al-Salam wa minka al-Salam, tabarakta ya dhal-jalali wal-ikram',
    meaningEn: 'O Allah, You are Peace and from You is peace. Blessed are You, O Possessor of Majesty and Honor',
    meaningAr: 'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
    count: 'Once after every salah',
    countAr: null,
    whenToSay: 'Immediately after the taslim of prayer',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA said this after every prayer, teaching that true peace comes only from Allah. The Negus found that peace by accepting the truth, even in secret, even alone.',
    promiseAr: 'قال النبيّ \uFDFA هذا بعد كلّ صلاة، معلّمًا أنّ السلام الحقيقي لا يأتي إلّا من الله. وجد النجاشي ذلك السلام بقبول الحقّ حتّى سرًّا وحتّى وحده.',
    sourceRef: 'Sahih Muslim #591',
    sourceRefAr: '',
  ),

  // ── Event 92: Letter to Muqawqis ─
  'j_m3_092': DhikrCard(
    id: 'j_m3_092',
    arabicText: 'اللَّهُمَّ اهْدِنَا فِيمَنْ هَدَيْتَ',
    transliteration: 'Allahumma ihdina fiman hadayt',
    meaningEn: 'O Allah, guide us among those You have guided',
    meaningAr: 'اللَّهُمَّ اهْدِنَا فِيمَنْ هَدَيْتَ',
    count: 'In Witr or daily du\'a',
    countAr: null,
    whenToSay: 'When praying for guidance for oneself and others',
    whenToSayAr: '',
    promiseEn: 'Guidance is Allah\'s gift, not a human achievement. The Negus received it; the Muqawqis did not. The believer asks for it continuously, knowing it can be granted or withheld at any moment.',
    promiseAr: 'الهداية منحة من الله لا إنجاز بشري. نالها النجاشي ولم ينلها المقوقس. يطلبها المؤمن باستمرار علمًا بأنّها قد تُمنح أو تُحجب في أيّ لحظة.',
    sourceRef: 'Sunan Abu Dawud #1425 (Qunut al-Witr)',
    sourceRefAr: '',
  ),

  // ── Event 93: March to Khaybar ─
  'j_m3_093': DhikrCard(
    id: 'j_m3_093',
    arabicText: 'اللَّهُمَّ رَبَّ السَّمَاوَاتِ السَّبْعِ وَمَا أَظْلَلْنَ وَرَبَّ الْأَرَضِينَ وَمَا أَقْلَلْنَ، أَسْأَلُكَ خَيْرَ هَذِهِ الْقَرْيَةِ',
    transliteration: 'Allahumma Rabba al-samawati al-sab\'i wa ma azlaln, wa Rabba al-aradina wa ma aqlaln, as\'aluka khayra hadhihi al-qaryah',
    meaningEn: 'O Allah, Lord of the seven heavens and what they shade, Lord of the earths and what they carry, I ask You for the good of this town',
    meaningAr: 'اللَّهُمَّ رَبَّ السَّمَاوَاتِ السَّبْعِ وَمَا أَظْلَلْنَ وَرَبَّ الْأَرَضِينَ وَمَا أَقْلَلْنَ، أَسْأَلُكَ خَيْرَ هَذِهِ الْقَرْيَةِ',
    count: 'Upon approaching any town',
    countAr: null,
    whenToSay: 'When entering a new place',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA used to say this when approaching any settlement, asking Allah for its good and seeking refuge from its evil. He said it approaching Khaybar, turning the military advance into an act of worship.',
    promiseAr: 'كان النبيّ \uFDFA يقول هذا عند الاقتراب من أيّ بلد طالبًا خيرها ومتعوّذًا من شرّها. قالها مقتربًا من خيبر محوّلًا التقدّم العسكري إلى عبادة.',
    sourceRef: 'Mustadrak al-Hakim; Ibn Hibban (Sahih chain reported)',
    sourceRefAr: '',
  ),

  // ── Event 94: Battle of Khaybar ─
  'j_m3_094': DhikrCard(
    id: 'j_m3_094',
    arabicText: 'اللَّهُمَّ بِكَ أَصُولُ وَبِكَ أَجُولُ وَبِكَ أُقَاتِلُ',
    transliteration: 'Allahumma bika asul, wa bika ajul, wa bika uqatil',
    meaningEn: 'O Allah, by You I attack, by You I advance, and by You I fight',
    meaningAr: 'اللَّهُمَّ بِكَ أَصُولُ وَبِكَ أَجُولُ وَبِكَ أُقَاتِلُ',
    count: 'Before any challenge',
    countAr: null,
    whenToSay: 'When facing a difficult task',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA taught this supplication for moments that require courage beyond one\'s natural ability. It places every action in Allah\'s hands, reminding that victory comes from Him alone.',
    promiseAr: 'علّم النبيّ \uFDFA هذا الدعاء للحظات التي تتطلّب شجاعة فوق القدرة الطبيعية. يضع كلّ فعل في يد الله مذكّرًا بأنّ النصر منه وحده.',
    sourceRef: 'Sunan Abu Dawud #2632; Sunan al-Tirmidhi #3584 (Sahih)',
    sourceRefAr: '',
  ),

  // ── Event 95: Ali's Triumph — Gate of Khaybar ─
  'j_m3_095': DhikrCard(
    id: 'j_m3_095',
    arabicText: 'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي',
    transliteration: 'Allahumma \'afini fi badani, Allahumma \'afini fi sam\'i, Allahumma \'afini fi basari',
    meaningEn: 'O Allah, grant me wellbeing in my body, O Allah, grant me wellbeing in my hearing, O Allah, grant me wellbeing in my sight',
    meaningAr: 'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي',
    count: 'Three times morning and evening',
    countAr: null,
    whenToSay: 'In morning and evening adhkar',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA asked for physical wellbeing daily, recognizing the body as a trust from Allah. Ali\'s eyes were healed at Khaybar; the Prophet \uFDFA carried poison in his body until his death. Both stories teach that the body is in Allah\'s hands.',
    promiseAr: 'طلب النبيّ \uFDFA العافية الجسدية يوميًّا مدركًا أنّ الجسد أمانة من الله. شُفيت عينا عليّ في خيبر؛ حمل النبيّ \uFDFA السمّ في جسده حتّى وفاته. كلتا القصّتين تعلّم أنّ الجسد بيد الله.',
    sourceRef: 'Sunan Abu Dawud #5090; Musnad Ahmad (Hasan)',
    sourceRefAr: '',
  ),

  // ── Event 96: The Poisoned Lamb ─
  'j_m3_096': DhikrCard(
    id: 'j_m3_096',
    arabicText: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
    transliteration: 'Bismillahi alladhi la yadurru ma\'a ismihi shay\'un fil-ardi wa la fis-sama\'i wa huwa al-Sami\' al-\'Alim',
    meaningEn: 'In the name of Allah, with whose name nothing in the earth or the heavens can cause harm, and He is the All-Hearing, the All-Knowing',
    meaningAr: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
    count: 'Three times morning and evening',
    countAr: null,
    whenToSay: 'Morning and evening adhkar',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA said: "Whoever says this three times in the morning and evening, nothing will harm him." This du\'a is the believer\'s shield against hidden dangers.',
    promiseAr: 'قال النبيّ \uFDFA: "من قالها ثلاثًا حين يصبح وثلاثًا حين يمسي لم يضرّه شيء."',
    sourceRef: 'Sunan Abu Dawud #5088; Sunan al-Tirmidhi #3388 (Sahih)',
    sourceRefAr: '',
  ),

  // ⚠️ NEEDS REVIEW — Event #97
  // ── Event 97: Return of the Abyssinian Emigrants ─
  'j_m3_097': DhikrCard(
    id: 'j_m3_097',
    arabicText: 'اللَّهُمَّ اجْمَعْ بَيْنَنَا وَبَيْنَ مَنْ نُحِبُّ فِي رَحْمَتِكَ',
    transliteration: 'Allahumma ijma\' baynana wa bayna man nuhibbu fi rahmatik',
    meaningEn: 'O Allah, reunite us with those we love through Your mercy',
    meaningAr: 'اللَّهُمَّ اجْمَعْ بَيْنَنَا وَبَيْنَ مَنْ نُحِبُّ فِي رَحْمَتِكَ',
    count: 'When missing someone',
    countAr: null,
    whenToSay: 'When separated from loved ones',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA taught that those who love each other for the sake of Allah will be reunited, whether in this life or the next. Ja\'far\'s return was the fulfillment of fourteen years of this du\'a.',
    promiseAr: 'علّم النبيّ \uFDFA أنّ المتحابّين في الله سيُجمع شملهم سواء في الدنيا أو الآخرة. كانت عودة جعفر تحقيقًا لأربع عشرة سنة من هذا الدعاء.',
    sourceRef: 'Supported by Sahih Muslim #2566 (people under shade of the Throne)',
    sourceRefAr: '',
  ),

  // ── Event 98: Umrat al-Qada ─
  'j_m3_098': DhikrCard(
    id: 'j_m3_098',
    arabicText: 'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ',
    transliteration: 'Labbayka Allahumma labbayk, labbayka la sharika laka labbayk',
    meaningEn: 'Here I am, O Allah, here I am. Here I am, You have no partner, here I am',
    meaningAr: 'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ',
    count: 'Throughout Umrah and Hajj',
    countAr: null,
    whenToSay: 'During pilgrimage rites',
    whenToSayAr: '',
    promiseEn: 'The Talbiyah is the voice of every pilgrim since Ibrahim عليه السلام. When two thousand Muslims chanted it entering Mecca, they were reconnecting with a tradition older than Quraysh, older than the idols, reaching back to the very origin of the Ka\'bah.',
    promiseAr: 'التلبية صوت كلّ حاجٍّ منذ إبراهيم عليه السلام. حين ردّدها ألفا مسلم وهم يدخلون مكة كانوا يستعيدون تقليدًا أقدم من قريش وأقدم من الأصنام يعود إلى أصل الكعبة ذاته.',
    sourceRef: 'Sahih al-Bukhari #1549; Sahih Muslim #1184',
    sourceRefAr: '',
  ),

  // ── Event 99: Khalid ibn al-Walid Accepts Islam ─
  'j_m3_099': DhikrCard(
    id: 'j_m3_099',
    arabicText: 'اللَّهُمَّ اغْفِرْ لِي مَا قَدَّمْتُ وَمَا أَخَّرْتُ وَمَا أَسْرَرْتُ وَمَا أَعْلَنْتُ وَمَا أَنْتَ أَعْلَمُ بِهِ مِنِّي',
    transliteration: 'Allahumma ighfir li ma qaddamtu wa ma akhkhartu wa ma asrartu wa ma a\'lantu wa ma anta a\'lamu bihi minni',
    meaningEn: 'O Allah, forgive me what I have done and what I have yet to do, what I have hidden and what I have made public, and what You know better than I',
    meaningAr: 'اللَّهُمَّ اغْفِرْ لِي مَا قَدَّمْتُ وَمَا أَخَّرْتُ وَمَا أَسْرَرْتُ وَمَا أَعْلَنْتُ وَمَا أَنْتَ أَعْلَمُ بِهِ مِنِّي',
    count: 'Once in each prayer',
    countAr: null,
    whenToSay: 'During sujud or before taslim',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA taught this comprehensive istighfar. Khalid\'s conversion began with the Prophet telling him to seek forgiveness for all that came before. Islam erases what preceded it, and this du\'a covers every angle of one\'s past.',
    promiseAr: 'علّم النبيّ \uFDFA هذا الاستغفار الشامل. إسلام خالد بدأ بأمر النبيّ \uFDFA له أن يستغفر لما سلف. الإسلام يجبّ ما قبله وهذا الدعاء يغطّي كلّ جوانب الماضي.',
    sourceRef: 'Sahih Muslim #771',
    sourceRefAr: '',
  ),

  // ── Event 100: Amr ibn al-As Accepts Islam ─
  'j_m3_100': DhikrCard(
    id: 'j_m3_100',
    arabicText: 'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
    transliteration: 'Allahumma innaka \'afuwwun tuhibbu al-\'afwa fa\'fu \'anni',
    meaningEn: 'O Allah, You are the Pardoner, You love to pardon, so pardon me',
    meaningAr: 'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
    count: 'Frequently in Ramadan (especially Laylat al-Qadr)',
    countAr: null,
    whenToSay: 'When seeking forgiveness',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA taught Aisha رضي الله عنها this du\'a as the best supplication for Laylat al-Qadr. It captures the essence of what Amr experienced: a God who does not just forgive but loves to forgive.',
    promiseAr: 'علّم النبيّ \uFDFA عائشة رضي الله عنها هذا الدعاء كأفضل دعاء لليلة القدر. يجسّد جوهر ما عاشه عمرو: إلهٌ لا يغفر فحسب بل يحبّ أن يغفر.',
    sourceRef: 'Sunan al-Tirmidhi #3513; Sunan Ibn Majah #3850 (Sahih)',
    sourceRefAr: '',
  ),

  // ── Event 101: Battle of Mu'tah ─
  'j_m3_101': DhikrCard(
    id: 'j_m3_101',
    arabicText: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ وَالْعَجْزِ وَالْكَسَلِ وَالْجُبْنِ وَالْبُخْلِ وَضَلَعِ الدَّيْنِ وَغَلَبَةِ الرِّجَالِ',
    transliteration: 'Allahumma inni a\'udhu bika min al-hammi wal-hazan, wal-\'ajzi wal-kasal, wal-jubni wal-bukhl, wa dala\'i al-dayni wa ghalabati al-rijal',
    meaningEn: 'O Allah, I seek refuge in You from worry and grief, from weakness and laziness, from cowardice and miserliness, from the burden of debt and being overpowered by men',
    meaningAr: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ وَالْعَجْزِ وَالْكَسَلِ وَالْجُبْنِ وَالْبُخْلِ وَضَلَعِ الدَّيْنِ وَغَلَبَةِ الرِّجَالِ',
    count: 'Morning and evening',
    countAr: null,
    whenToSay: 'Daily adhkar',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA sought refuge from being overpowered by men. At Mu\'tah, three thousand were overpowered in numbers but not in spirit. This du\'a protects the heart even when the body is outmatched.',
    promiseAr: 'تعوّذ النبيّ \uFDFA من غلبة الرجال. في مؤتة كان الثلاثة آلاف مغلوبين عددًا لا روحًا. هذا الدعاء يحمي القلب حتّى حين يُغلب الجسد.',
    sourceRef: 'Sahih al-Bukhari #6369',
    sourceRefAr: '',
  ),

  // ── Event 102: Three Commanders Fall ─
  'j_m3_102': DhikrCard(
    id: 'j_m3_102',
    arabicText: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الشَّهَادَةَ فِي سَبِيلِكَ',
    transliteration: 'Allahumma inni as\'aluka al-shahadah fi sabilik',
    meaningEn: 'O Allah, I ask You for martyrdom in Your path',
    meaningAr: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الشَّهَادَةَ فِي سَبِيلِكَ',
    count: 'Once daily',
    countAr: null,
    whenToSay: 'In sincere du\'a',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA said: "Whoever sincerely asks Allah for martyrdom, Allah will grant him the status of the martyrs even if he dies in his bed." The sincerity of the request matters more than the manner of death.',
    promiseAr: 'قال النبيّ \uFDFA: "من سأل الله الشهادة بصدقٍ بلّغه الله منازل الشهداء وإن مات على فراشه." صدق الطلب أهمّ من طريقة الموت.',
    sourceRef: 'Sahih Muslim #1909',
    sourceRefAr: '',
  ),

  // ── Event 103: Khalid Takes Command ─
  'j_m3_103': DhikrCard(
    id: 'j_m3_103',
    arabicText: 'حَسْبِيَ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
    transliteration: 'Hasbiya Allahu la ilaha illa Huwa, \'alayhi tawakkaltu wa Huwa Rabbu al-\'Arsh al-\'Azim',
    meaningEn: 'Sufficient for me is Allah; there is no god but He. In Him I place my trust, and He is the Lord of the Great Throne',
    meaningAr: 'حَسْبِيَ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
    count: 'Seven times morning and evening',
    countAr: null,
    whenToSay: 'Morning and evening adhkar',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA said: "Whoever says this seven times morning and evening, Allah will suffice him in whatever concerns him." Khalid placed his trust in Allah at Mu\'tah and was sufficient for an entire army.',
    promiseAr: 'قال النبيّ \uFDFA: "من قالها سبعًا حين يصبح وحين يمسي كفاه الله ما أهمّه." توكّل خالد على الله في مؤتة فكُفي جيشًا بأكمله.',
    sourceRef: 'Sunan Abu Dawud #5081 (Sahih by al-Albani)',
    sourceRefAr: '',
  ),

  // ⚠️ NEEDS REVIEW — Event #104
  // ── Event 104: Dhat al-Salasil ─
  'j_m3_104': DhikrCard(
    id: 'j_m3_104',
    arabicText: 'اللَّهُمَّ أَلِّفْ بَيْنَ قُلُوبِنَا وَأَصْلِحْ ذَاتَ بَيْنِنَا',
    transliteration: 'Allahumma allif bayna qulubina wa aslih dhata baynina',
    meaningEn: 'O Allah, unite our hearts and mend our relations',
    meaningAr: 'اللَّهُمَّ أَلِّفْ بَيْنَ قُلُوبِنَا وَأَصْلِحْ ذَاتَ بَيْنِنَا',
    count: 'Once when conflict threatens unity',
    countAr: null,
    whenToSay: 'When community unity is at risk',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA regularly asked for unity of hearts. The expedition of Dhat al-Salasil showed this unity in action: new and old Muslims, former enemies and lifelong believers, functioning as one body under one command.',
    promiseAr: 'كان النبيّ \uFDFA يدعو بانتظام لوحدة القلوب. أظهرت سريّة ذات السلاسل هذه الوحدة عمليًّا: مسلمون جدد وقدامى، أعداء سابقون ومؤمنون مدى الحياة، يعملون كجسد واحد تحت قيادة واحدة.',
    sourceRef: 'Sunan Abu Dawud #969 (from the Friday khutbah du\'a; Sahih)',
    sourceRefAr: '',
  ),

  // ── Event 105: Quraysh Breaks the Treaty ─
  'j_m3_105': DhikrCard(
    id: 'j_m3_105',
    arabicText: 'اللَّهُمَّ لَا تَكِلْنِي إِلَىٰ نَفْسِي طَرْفَةَ عَيْنٍ وَأَصْلِحْ لِي شَأْنِي كُلَّهُ',
    transliteration: 'Allahumma la takilni ila nafsi tarfata \'ayn, wa aslih li sha\'ni kullahu',
    meaningEn: 'O Allah, do not leave me to myself for the blink of an eye, and set right all my affairs',
    meaningAr: 'اللَّهُمَّ لَا تَكِلْنِي إِلَىٰ نَفْسِي طَرْفَةَ عَيْنٍ وَأَصْلِحْ لِي شَأْنِي كُلَّهُ',
    count: 'Once when tempted toward error',
    countAr: null,
    whenToSay: 'When facing moral dilemmas',
    whenToSayAr: '',
    promiseEn: 'Quraysh\'s leaders were left to their own judgment and made the worst decision of their history. This du\'a asks Allah never to leave the believer to his own devices, because human judgment without divine guidance leads to ruin.',
    promiseAr: 'قادة قريش تُركوا لتقديرهم فاتّخذوا أسوأ قرارٍ في تاريخهم. هذا الدعاء يطلب من الله ألّا يكل المؤمن إلى نفسه لأنّ الحكم البشري دون هداية إلهية يقود إلى الخراب.',
    sourceRef: 'Musnad Ahmad; Abu Dawud (authentic chain)',
    sourceRefAr: '',
  ),

  // ── Event 106: Abu Sufyan's Last Journey ─
  'j_m3_106': DhikrCard(
    id: 'j_m3_106',
    arabicText: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ',
    transliteration: 'Allahumma anta Rabbi la ilaha illa ant, khalaqtani wa ana \'abduk, wa ana \'ala \'ahdika wa wa\'dika ma istata\'t',
    meaningEn: 'O Allah, You are my Lord, there is no god but You. You created me and I am Your servant, and I hold to Your covenant and promise as best I can',
    meaningAr: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ',
    count: 'Once morning and evening',
    countAr: null,
    whenToSay: 'Part of the morning/evening adhkar (Sayyid al-Istighfar)',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA said: "Whoever says this with conviction in the morning and dies that day, enters Paradise. Whoever says it with conviction in the evening and dies that night, enters Paradise."',
    promiseAr: 'قال النبيّ \uFDFA: "من قالها موقنًا بها حين يصبح فمات من يومه دخل الجنة، ومن قالها موقنًا بها حين يمسي فمات من ليلته دخل الجنة."',
    sourceRef: 'Sahih al-Bukhari #6306',
    sourceRefAr: '',
  ),

  // ── Event 107: The Secret March — Ten Thousand ─
  'j_m3_107': DhikrCard(
    id: 'j_m3_107',
    arabicText: 'اللَّهُمَّ بِعِلْمِكَ الْغَيْبَ وَقُدْرَتِكَ عَلَى الْخَلْقِ أَحْيِنِي مَا عَلِمْتَ الْحَيَاةَ خَيْرًا لِي',
    transliteration: 'Allahumma bi-\'ilmika al-ghayba wa qudratika \'ala al-khalq, ahyini ma \'alimta al-hayata khayran li',
    meaningEn: 'O Allah, by Your knowledge of the unseen and Your power over creation, let me live as long as You know life is good for me',
    meaningAr: 'اللَّهُمَّ بِعِلْمِكَ الْغَيْبَ وَقُدْرَتِكَ عَلَى الْخَلْقِ أَحْيِنِي مَا عَلِمْتَ الْحَيَاةَ خَيْرًا لِي',
    count: 'Once daily',
    countAr: null,
    whenToSay: 'In the morning or after Salah',
    whenToSayAr: '',
    promiseEn: 'This supplication from Sahih al-Nasa\'i entrusts one\'s entire life plan to Allah\'s knowledge, the ultimate expression of surrender to divine wisdom.',
    promiseAr: 'يفوّض هذا الدعاء من سنن النسائي خطّة الحياة بأكملها إلى علم الله، وهو أقصى تعبيرٍ عن الاستسلام للحكمة الإلهية.',
    sourceRef: 'Sunan al-Nasa\'i #1304 (Sahih)',
    sourceRefAr: '',
  ),

  // ── Event 108: Abu Sufyan Witnesses the Army ─
  'j_m3_108': DhikrCard(
    id: 'j_m3_108',
    arabicText: 'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَٰهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ',
    transliteration: 'Subhanallah wal-hamdu lillah wa la ilaha illallah wallahu akbar wa la hawla wa la quwwata illa billahi al-\'aliyyi al-\'azim',
    meaningEn: 'Glory be to Allah, praise be to Allah, there is no god but Allah, Allah is the Greatest, and there is no power or might except with Allah the Most High, the Magnificent',
    meaningAr: 'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَٰهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ',
    count: 'Once or more throughout the day',
    countAr: null,
    whenToSay: 'Whenever one witnesses Allah\'s power',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA called these words the "remaining righteous deeds" (al-baqiyat al-salihat) and said they are beloved to Allah more than anything upon which the sun rises.',
    promiseAr: 'سمّى النبيّ \uFDFA هذه الكلمات "الباقيات الصالحات" وقال إنّها أحبّ إلى الله ممّا طلعت عليه الشمس.',
    sourceRef: 'Sahih Muslim #2695 (partial); Musnad Ahmad (full version)',
    sourceRefAr: '',
  ),

  // ── Event 109: Abu Sufyan Accepts Islam ─
  'j_m3_109': DhikrCard(
    id: 'j_m3_109',
    arabicText: 'رَبَّنَا آتِنَا مِنْ لَدُنْكَ رَحْمَةً وَهَيِّئْ لَنَا مِنْ أَمْرِنَا رَشَدًا',
    transliteration: 'Rabbana atina min ladunka rahma wa hayyi\' lana min amrina rashada',
    meaningEn: 'Our Lord, grant us from Yourself mercy and prepare for us from our affair right guidance',
    meaningAr: 'رَبَّنَا آتِنَا مِنْ لَدُنْكَ رَحْمَةً وَهَيِّئْ لَنَا مِنْ أَمْرِنَا رَشَدًا',
    count: 'Once when seeking guidance',
    countAr: null,
    whenToSay: 'Before major decisions or turning points',
    whenToSayAr: '',
    promiseEn: 'This Quranic supplication from Surah al-Kahf is the du\'a of those who seek Allah\'s mercy and right guidance in the most critical moments. It is recited every Friday as part of Surah al-Kahf.',
    promiseAr: 'هذا الدعاء القرآني من سورة الكهف هو دعاء الذين يطلبون رحمة الله والرشاد في أخطر اللحظات. يُتلى كلّ جمعة ضمن سورة الكهف.',
    sourceRef: 'Quran 18:10',
    sourceRefAr: '',
  ),

  // ── Event 110: Conquest of Mecca ─
  'j_m3_110': DhikrCard(
    id: 'j_m3_110',
    arabicText: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ، أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
    transliteration: 'Subhanallahi wa bihamdih, subhanallahi al-\'azim, astaghfirullaha wa atubu ilayh',
    meaningEn: 'Glory and praise be to Allah, glory be to Allah the Magnificent, I seek Allah\'s forgiveness and turn to Him in repentance',
    meaningAr: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ، أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
    count: 'Three times after prayer',
    countAr: null,
    whenToSay: 'After every prayer and in moments of gratitude',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA increased this dhikr dramatically after Surah al-Nasr was revealed, teaching that the greatest victory demands the greatest humility and the most sincere repentance.',
    promiseAr: 'أكثر النبيّ \uFDFA من هذا الذكر بعد نزول سورة النصر، معلّمًا أنّ أعظم نصرٍ يتطلّب أعظم تواضع وأصدق توبة.',
    sourceRef: 'Sahih al-Bukhari #4967; Sahih Muslim #484',
    sourceRefAr: '',
  ),

  // ── Event 111: Cleansing the Ka'bah ─
  'j_m3_111': DhikrCard(
    id: 'j_m3_111',
    arabicText: 'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    transliteration: 'La ilaha illallahu wahdahu la sharika lah, lahu al-mulku wa lahu al-hamd, wa huwa \'ala kulli shay\'in qadir',
    meaningEn: 'There is no god but Allah alone, with no partner. To Him belongs sovereignty and praise, and He has power over all things',
    meaningAr: 'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    count: '100 times daily',
    countAr: null,
    whenToSay: 'Morning and evening',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA said: "Whoever says this 100 times a day will have the reward of freeing 10 slaves, 100 good deeds recorded, 100 sins erased, and will be protected from Shaytan that day until evening."',
    promiseAr: 'قال النبيّ \uFDFA: "من قالها مئة مرّة في يوم كان له عدل عشر رقاب وكُتبت له مئة حسنة ومُحيت عنه مئة سيّئة وكانت له حرزًا من الشيطان يومه ذلك حتّى يمسي."',
    sourceRef: 'Sahih al-Bukhari #3293; Sahih Muslim #2691',
    sourceRefAr: '',
  ),

  // ── Event 112: The General Amnesty ─
  'j_m3_112': DhikrCard(
    id: 'j_m3_112',
    arabicText: 'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
    transliteration: 'Allahumma innaka \'afuwwun tuhibbu al-\'afwa fa\'fu \'anni',
    meaningEn: 'O Allah, You are the Pardoner, You love to pardon, so pardon me',
    meaningAr: 'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
    count: 'Frequently, especially on Laylat al-Qadr',
    countAr: null,
    whenToSay: 'During the last ten nights of Ramadan and whenever seeking forgiveness',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA taught Aisha رضي الله عنها this du\'a specifically for the Night of Power. It asks for \'afw — not just forgiveness, but the complete erasure of the sin, as though it never existed.',
    promiseAr: 'علّم النبيّ \uFDFA عائشة رضي الله عنها هذا الدعاء تحديدًا لليلة القدر. يطلب العفو لا مجرّد المغفرة بل المحو الكامل للذنب كأنّه لم يكن.',
    sourceRef: 'Sunan al-Tirmidhi #3513 (Sahih)',
    sourceRefAr: '',
  ),

  // ── Event 113: Bilal Calls Adhan from the Ka'bah ─
  'j_m3_113': DhikrCard(
    id: 'j_m3_113',
    arabicText: 'أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا رَسُولُ اللَّهِ، رَضِيتُ بِاللَّهِ رَبًّا وَبِمُحَمَّدٍ رَسُولًا وَبِالْإِسْلَامِ دِينًا',
    transliteration: 'Ash-hadu an la ilaha illallah wa ash-hadu anna Muhammadan Rasulullah, raditu billahi Rabban wa bi-Muhammadin Rasulan wa bil-Islami dinan',
    meaningEn: 'I bear witness that there is no god but Allah and Muhammad is the Messenger of Allah. I am content with Allah as my Lord, Muhammad as my Messenger, and Islam as my religion',
    meaningAr: 'أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا رَسُولُ اللَّهِ، رَضِيتُ بِاللَّهِ رَبًّا وَبِمُحَمَّدٍ رَسُولًا وَبِالْإِسْلَامِ دِينًا',
    count: 'After each adhan',
    countAr: null,
    whenToSay: 'After hearing the call to prayer',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA said: "Whoever says this after the adhan, his sins will be forgiven."',
    promiseAr: 'قال النبيّ \uFDFA: "من قال ذلك حين يسمع المؤذّن غُفر له ذنبه."',
    sourceRef: 'Sahih Muslim #386',
    sourceRefAr: '',
  ),

  // ── Event 114: Hunayn — The Ambush ─
  'j_m3_114': DhikrCard(
    id: 'j_m3_114',
    arabicText: 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ',
    transliteration: 'Ya Hayyu ya Qayyum bi-rahmatika astaghith',
    meaningEn: 'O Ever-Living, O Sustainer, by Your mercy I seek help',
    meaningAr: 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ',
    count: 'Three times in moments of distress',
    countAr: null,
    whenToSay: 'When overwhelmed or in crisis',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA used to call upon Allah with these words in times of intense distress, affirming that the Ever-Living never abandons those who call upon Him sincerely.',
    promiseAr: 'كان النبيّ \uFDFA ينادي الله بهذه الكلمات في شدّة الكرب، مؤكّدًا أنّ الحيّ القيّوم لا يخذل من ناداه بصدق.',
    sourceRef: 'Sunan al-Tirmidhi #3524 (Hasan); supported by Sahih al-Hakim',
    sourceRefAr: '',
  ),

  // ── Event 115: The Turning Point — Muslims Rally ─
  'j_m3_115': DhikrCard(
    id: 'j_m3_115',
    arabicText: 'اللَّهُمَّ اجْعَلْ فِي قَلْبِي نُورًا وَفِي سَمْعِي نُورًا وَفِي بَصَرِي نُورًا وَعَنْ يَمِينِي نُورًا وَعَنْ شِمَالِي نُورًا',
    transliteration: 'Allahumma ij\'al fi qalbi nuran wa fi sam\'i nuran wa fi basari nuran wa \'an yamini nuran wa \'an shimali nuran',
    meaningEn: 'O Allah, place light in my heart, in my hearing, in my sight, to my right, and to my left',
    meaningAr: 'اللَّهُمَّ اجْعَلْ فِي قَلْبِي نُورًا وَفِي سَمْعِي نُورًا وَفِي بَصَرِي نُورًا وَعَنْ يَمِينِي نُورًا وَعَنْ شِمَالِي نُورًا',
    count: 'Once in night prayer',
    countAr: null,
    whenToSay: 'During qiyam al-layl or before important moments',
    whenToSayAr: '',
    promiseEn: 'This expanded version of the light supplication asks for light in every direction, leaving no darkness for confusion or fear to take root. The companions who rallied at Hunayn found that light in the Prophet\'s call.',
    promiseAr: 'هذه النسخة الموسّعة من دعاء النور تطلب النور من كلّ اتجاه لا تُبقي ظلامًا للحيرة أو الخوف. الصحابة الذين عادوا في حنين وجدوا ذلك النور في نداء النبيّ \uFDFA.',
    sourceRef: 'Sahih al-Bukhari #6316; Sahih Muslim #763 (extended version)',
    sourceRefAr: '',
  ),

  // ── Event 116: Siege of Ta'if ─
  'j_m3_116': DhikrCard(
    id: 'j_m3_116',
    arabicText: 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
    transliteration: 'Rabbi ishrah li sadri wa yassir li amri',
    meaningEn: 'My Lord, expand my breast and ease my affair',
    meaningAr: 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
    count: 'Before any difficult task',
    countAr: null,
    whenToSay: 'When facing a challenge or feeling overwhelmed',
    whenToSayAr: '',
    promiseEn: 'This is the du\'a of Musa عليه السلام before facing Pharaoh, and it was given to the Ummah as a supplication for ease in the face of difficulty. Allah expanded the Prophet\'s chest as confirmed in Surah al-Sharh.',
    promiseAr: 'هذا دعاء موسى عليه السلام قبل مواجهة فرعون، أُعطي للأمّة دعاءً لتيسير الصعاب. وسّع الله صدر النبيّ \uFDFA كما أكّدت سورة الشرح.',
    sourceRef: 'Quran 20:25-26; Quran 94:1',
    sourceRefAr: '',
  ),

  // ── Event 117: Division of Hunayn Spoils ─
  'j_m3_117': DhikrCard(
    id: 'j_m3_117',
    arabicText: 'اللَّهُمَّ اقْسِمْ لَنَا مِنْ خَشْيَتِكَ مَا تَحُولُ بِهِ بَيْنَنَا وَبَيْنَ مَعَاصِيكَ',
    transliteration: 'Allahumma iqsim lana min khashyatika ma tahulu bihi baynana wa bayna ma\'asik',
    meaningEn: 'O Allah, apportion to us such fear of You as would come between us and acts of disobedience to You',
    meaningAr: 'اللَّهُمَّ اقْسِمْ لَنَا مِنْ خَشْيَتِكَ مَا تَحُولُ بِهِ بَيْنَنَا وَبَيْنَ مَعَاصِيكَ',
    count: 'Once after prayer',
    countAr: null,
    whenToSay: 'After any obligatory prayer',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA used this comprehensive du\'a asking for fear of Allah, certainty, and contentment with His decree — three things that make worldly wealth irrelevant.',
    promiseAr: 'استخدم النبيّ \uFDFA هذا الدعاء الشامل طالبًا خشية الله واليقين والرضا بقضائه، ثلاثة أشياء تجعل ثروة الدنيا بلا قيمة.',
    sourceRef: 'Sunan al-Tirmidhi #3502 (Hasan)',
    sourceRefAr: '',
  ),

  // ── Event 118: Umrah from Ji'ranah ─
  'j_m3_118': DhikrCard(
    id: 'j_m3_118',
    arabicText: 'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ',
    transliteration: 'Labbayk Allahumma labbayk, labbayk la sharika laka labbayk, inna al-hamda wan-ni\'mata laka wal-mulk, la sharika lak',
    meaningEn: 'Here I am, O Allah, here I am. Here I am, You have no partner, here I am. Verily all praise, grace, and sovereignty belong to You. You have no partner.',
    meaningAr: 'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ',
    count: 'Throughout Hajj and Umrah',
    countAr: null,
    whenToSay: 'From entering ihram until completing the pilgrimage',
    whenToSayAr: '',
    promiseEn: 'This talbiyah is the call of Ibrahim عليه السلام echoed by every pilgrim since. The Prophet \uFDFA said that anyone who recites it sincerely will have their sins forgiven between one Umrah and the next.',
    promiseAr: 'هذه التلبية نداء إبراهيم عليه السلام يردّده كلّ حاجّ منذ ذلك الحين. قال النبيّ \uFDFA إنّ من يرتّلها بصدقٍ تُغفر ذنوبه بين العمرة والعمرة.',
    sourceRef: 'Sahih al-Bukhari #1549; Sahih Muslim #1184',
    sourceRefAr: '',
  ),

  // ── Event 119: Ta'if Accepts Islam ─
  'j_m3_119': DhikrCard(
    id: 'j_m3_119',
    arabicText: 'اللَّهُمَّ اهْدِنِي وَسَدِّدْنِي',
    transliteration: 'Allahumma ihdini wa saddidni',
    meaningEn: 'O Allah, guide me and make me steadfast',
    meaningAr: 'اللَّهُمَّ اهْدِنِي وَسَدِّدْنِي',
    count: 'Once daily',
    countAr: null,
    whenToSay: 'Morning or when seeking direction',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA taught this concise supplication for guidance and steadfastness. "Guidance" here means being shown the right path, and "steadfastness" means the strength to walk it.',
    promiseAr: 'علّم النبيّ \uFDFA هذا الدعاء المختصر للهداية والسداد. "الهداية" هنا تعني إرشاد الطريق الصحيح و"السداد" يعني القوّة لسلوكه.',
    sourceRef: 'Sahih Muslim #2725',
    sourceRefAr: '',
  ),

  // ── Event 120: Arabian Peninsula Transforms ─
  'j_m3_120': DhikrCard(
    id: 'j_m3_120',
    arabicText: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
    transliteration: 'Subhanallahi wa bihamdih, astaghfirullaha wa atubu ilayh',
    meaningEn: 'Glory and praise be to Allah, I seek Allah\'s forgiveness and turn to Him in repentance',
    meaningAr: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
    count: '100 times daily (or more)',
    countAr: null,
    whenToSay: 'Throughout the day, especially after Surah al-Nasr',
    whenToSayAr: '',
    promiseEn: 'After Surah al-Nasr was revealed, the Prophet \uFDFA dramatically increased this dhikr. Aisha رضي الله عنها said he never prayed without saying it. It teaches that the greatest victory demands the greatest humility.',
    promiseAr: 'بعد نزول سورة النصر أكثر النبيّ \uFDFA من هذا الذكر بشكلٍ لافت. قالت عائشة رضي الله عنها إنّه لم يصلِّ بعدها إلّا قاله. يعلّم أنّ أعظم نصرٍ يتطلّب أعظم تواضع.',
    sourceRef: 'Sahih al-Bukhari #4967; Sahih Muslim #484',
    sourceRefAr: '',
  ),

  // ── Event 121: Call to Tabuk ─
  'j_m4_121': DhikrCard(
    id: 'j_m4_121',
    arabicText: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الثَّبَاتَ فِي الْأَمْرِ وَالْعَزِيمَةَ عَلَى الرُّشْدِ',
    transliteration: 'Allahumma inni as\'aluka al-thabata fil-amr wal-\'azimata \'ala al-rushd',
    meaningEn: 'O Allah, I ask You for steadfastness in my affairs and determination upon guidance',
    meaningAr: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الثَّبَاتَ فِي الْأَمْرِ وَالْعَزِيمَةَ عَلَى الرُّشْدِ',
    count: 'Once daily',
    countAr: null,
    whenToSay: 'Before a difficult decision or task',
    whenToSayAr: '',
    promiseEn: 'This supplication asks for two things the companions demonstrated at Tabuk: unwavering commitment to the right course even when the cost is extreme.',
    promiseAr: 'يطلب هذا الدعاء شيئين أظهرهما الصحابة في تبوك: الالتزام الراسخ بالطريق الصحيح حتّى حين تكون التكلفة باهظة.',
    sourceRef: 'Sunan al-Nasa\'i #1304 (part of longer hadith, Sahih)',
    sourceRefAr: '',
  ),

  // ── Event 122: The Hypocrites' Excuses ─
  'j_m4_122': DhikrCard(
    id: 'j_m4_122',
    arabicText: 'اللَّهُمَّ أَرِنَا الْحَقَّ حَقًّا وَارْزُقْنَا اتِّبَاعَهُ، وَأَرِنَا الْبَاطِلَ بَاطِلًا وَارْزُقْنَا اجْتِنَابَهُ',
    transliteration: 'Allahumma arina al-haqqa haqqan warzuqna ittiba\'ah, wa arina al-batila batilan warzuqna ijtinabah',
    meaningEn: 'O Allah, show us the truth as truth and grant us the ability to follow it, and show us falsehood as falsehood and grant us the ability to avoid it',
    meaningAr: 'اللَّهُمَّ أَرِنَا الْحَقَّ حَقًّا وَارْزُقْنَا اتِّبَاعَهُ، وَأَرِنَا الْبَاطِلَ بَاطِلًا وَارْزُقْنَا اجْتِنَابَهُ',
    count: 'Once when seeking clarity',
    countAr: null,
    whenToSay: 'When confused about right and wrong',
    whenToSayAr: '',
    promiseEn: 'This supplication asks for the greatest gift: clarity. The hypocrites\' failure was not ignorance — they knew the truth — but their inability to follow it. This du\'a asks for both sight and strength.',
    promiseAr: 'يطلب هذا الدعاء أعظم عطية: الوضوح. إخفاق المنافقين لم يكن جهلًا فقد عرفوا الحقّ بل عجزهم عن اتّباعه. يطلب هذا الدعاء البصيرة والقوّة معًا.',
    sourceRef: 'Attributed to the Prophet \uFDFA; widely used in scholarly tradition',
    sourceRefAr: '',
  ),

  // ⚠️ NEEDS REVIEW — Event #123
  // ── Event 123: Abu Khaythamah ─
  'j_m4_123': DhikrCard(
    id: 'j_m4_123',
    arabicText: 'رَبِّ إِنِّي ظَلَمْتُ نَفْسِي فَاغْفِرْ لِي',
    transliteration: 'Rabbi inni zalamtu nafsi faghfir li',
    meaningEn: 'My Lord, I have wronged myself, so forgive me',
    meaningAr: 'رَبِّ إِنِّي ظَلَمْتُ نَفْسِي فَاغْفِرْ لِي',
    count: 'When acknowledging a mistake',
    countAr: null,
    whenToSay: 'After recognizing one has fallen short',
    whenToSayAr: '',
    promiseEn: 'This is the du\'a of Musa عليه السلام after he erred, and Allah forgave him immediately. It teaches that acknowledging the wrong is the first step of return, and Allah is always ready to forgive the one who turns back sincerely.',
    promiseAr: 'هذا دعاء موسى عليه السلام بعد أن أخطأ فغفر الله له فورًا. يعلّم أنّ الاعتراف بالخطأ أوّل خطوة في العودة وأنّ الله مستعدٌّ دائمًا لمغفرة من عاد بصدق.',
    sourceRef: 'Quran 28:16',
    sourceRefAr: '',
  ),

  // ── Event 124: Tabuk — Bloodless Victory ─
  'j_m4_124': DhikrCard(
    id: 'j_m4_124',
    arabicText: 'اللَّهُمَّ يَسِّرْ وَلَا تُعَسِّرْ وَتَمِّمْ بِالْخَيْرِ',
    transliteration: 'Allahumma yassir wa la tu\'assir wa tammim bil-khayr',
    meaningEn: 'O Allah, make it easy, do not make it difficult, and complete it with goodness',
    meaningAr: 'اللَّهُمَّ يَسِّرْ وَلَا تُعَسِّرْ وَتَمِّمْ بِالْخَيْرِ',
    count: 'Before any task',
    countAr: null,
    whenToSay: 'When beginning something new',
    whenToSayAr: '',
    promiseEn: 'This supplication asks for ease in execution and goodness in outcome — the very combination the Tabuk expedition embodied: a difficult journey with a peaceful, strategic resolution.',
    promiseAr: 'يطلب هذا الدعاء التيسير في التنفيذ والخير في النتيجة، التركيبة ذاتها التي جسّدتها حملة تبوك: رحلة شاقّة بحلٍّ سلمي استراتيجي.',
    sourceRef: 'Attributed; widely used supplication based on Quranic principle of ease (94:5-6)',
    sourceRefAr: '',
  ),

  // ── Event 125: Masjid al-Dirar ─
  'j_m4_125': DhikrCard(
    id: 'j_m4_125',
    arabicText: 'اللَّهُمَّ اجْعَلْ فِي قَلْبِي نُورًا وَاجْعَلْ فِي بَصَرِي نُورًا وَاجْعَلْ مِنْ تَحْتِي نُورًا وَاجْعَلْ مِنْ فَوْقِي نُورًا',
    transliteration: 'Allahumma ij\'al fi qalbi nuran waj\'al fi basari nuran waj\'al min tahti nuran waj\'al min fawqi nuran',
    meaningEn: 'O Allah, place light in my heart, light in my sight, light beneath me, and light above me',
    meaningAr: 'اللَّهُمَّ اجْعَلْ فِي قَلْبِي نُورًا وَاجْعَلْ فِي بَصَرِي نُورًا وَاجْعَلْ مِنْ تَحْتِي نُورًا وَاجْعَلْ مِنْ فَوْقِي نُورًا',
    count: 'Once before sleep or in qiyam',
    countAr: null,
    whenToSay: 'Before sleep or in night prayer',
    whenToSayAr: '',
    promiseEn: 'This comprehensive light supplication asks for divine illumination that reveals truth from deception — the very discernment needed to recognize a Masjid al-Dirar for what it really is.',
    promiseAr: 'يطلب دعاء النور الشامل هذا إنارةً إلهية تكشف الحقيقة من الخداع، البصيرة ذاتها اللازمة لمعرفة مسجد الضرار على حقيقته.',
    sourceRef: 'Sahih al-Bukhari #6316; Sahih Muslim #763',
    sourceRefAr: '',
  ),

  // ── Event 126: The Three Who Stayed Behind ─
  'j_m4_126': DhikrCard(
    id: 'j_m4_126',
    arabicText: 'رَبَّنَا ظَلَمْنَا أَنْفُسَنَا وَإِنْ لَمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ',
    transliteration: 'Rabbana zalamna anfusana wa in lam taghfir lana wa tarhamna lanakoonanna min al-khasirin',
    meaningEn: 'Our Lord, we have wronged ourselves, and if You do not forgive us and have mercy upon us, we will surely be among the losers',
    meaningAr: 'رَبَّنَا ظَلَمْنَا أَنْفُسَنَا وَإِنْ لَمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ',
    count: 'When seeking sincere repentance',
    countAr: null,
    whenToSay: 'After committing a sin or falling short',
    whenToSayAr: '',
    promiseEn: 'This is the du\'a of Adam and Hawwa عليهما السلام after their slip. It is the first recorded act of human repentance, and Allah accepted it. Every sincere istighfar traces back to this moment.',
    promiseAr: 'هذا دعاء آدم وحوّاء عليهما السلام بعد زلّتهما. أوّل توبة بشرية مسجّلة وقبلها الله. كلّ استغفارٍ صادق يعود إلى هذه اللحظة.',
    sourceRef: 'Quran 7:23',
    sourceRefAr: '',
  ),

  // ── Event 127: Repentance of the Three ─
  'j_m4_127': DhikrCard(
    id: 'j_m4_127',
    arabicText: 'يَا أَيُّهَا الَّذِينَ آمَنُوا اتَّقُوا اللَّهَ وَكُونُوا مَعَ الصَّادِقِينَ',
    transliteration: 'Ya ayyuha alladhina amanu ittaqullaha wa kunu ma\'a al-sadiqin',
    meaningEn: 'O you who believe, fear Allah and be with those who are truthful',
    meaningAr: 'يَا أَيُّهَا الَّذِينَ آمَنُوا اتَّقُوا اللَّهَ وَكُونُوا مَعَ الصَّادِقِينَ',
    count: 'Once daily as a life principle',
    countAr: null,
    whenToSay: 'When facing temptation to lie or conceal',
    whenToSayAr: '',
    promiseEn: 'This Quranic verse (9:119) was revealed as the culminating lesson of the entire Tabuk ordeal. Being with the truthful — choosing honesty over convenience — is the path to Allah\'s pleasure even when it costs everything in this world.',
    promiseAr: 'هذه الآية القرآنية (9:119) نزلت درسًا ختاميًّا لمحنة تبوك كلّها. الكون مع الصادقين واختيار الصدق على الراحة هو طريق رضا الله حتّى حين يكلّف كلّ شيء في هذه الدنيا.',
    sourceRef: 'Quran 9:119',
    sourceRefAr: '',
  ),

  // ⚠️ NEEDS REVIEW — Event #128
  // ── Event 128: Death of Abdullah ibn Ubayy ─
  'j_m4_128': DhikrCard(
    id: 'j_m4_128',
    arabicText: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عِلْمٍ لَا يَنْفَعُ وَمِنْ قَلْبٍ لَا يَخْشَعُ وَمِنْ نَفْسٍ لَا تَشْبَعُ وَمِنْ دَعْوَةٍ لَا يُسْتَجَابُ لَهَا',
    transliteration: 'Allahumma inni a\'udhu bika min \'ilmin la yanfa\' wa min qalbin la yakhsha\' wa min nafsin la tashba\' wa min da\'watin la yustajab laha',
    meaningEn: 'O Allah, I seek refuge in You from knowledge that does not benefit, a heart that does not humble itself, a soul that is never satisfied, and a supplication that is not answered',
    meaningAr: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عِلْمٍ لَا يَنْفَعُ وَمِنْ قَلْبٍ لَا يَخْشَعُ وَمِنْ نَفْسٍ لَا تَشْبَعُ وَمِنْ دَعْوَةٍ لَا يُسْتَجَابُ لَهَا',
    count: 'Once daily',
    countAr: null,
    whenToSay: 'After prayer',
    whenToSayAr: '',
    promiseEn: 'This comprehensive du\'a seeks protection from the four diseases of the soul that characterized the hypocrites: useless knowledge, hard hearts, endless greed, and unanswered prayers — all consequences of insincerity.',
    promiseAr: 'يطلب هذا الدعاء الشامل الحماية من أمراض النفس الأربعة التي ميّزت المنافقين: علم بلا نفع وقلب بلا خشوع ونفس بلا قناعة ودعوة بلا استجابة، كلّها نتائج عدم الإخلاص.',
    sourceRef: 'Sahih Muslim #2722',
    sourceRefAr: '',
  ),

  // ── Event 129: Year of Delegations Begins ─
  'j_m4_129': DhikrCard(
    id: 'j_m4_129',
    arabicText: 'اللَّهُمَّ عَلِّمْنِي مَا يَنْفَعُنِي وَانْفَعْنِي بِمَا عَلَّمْتَنِي وَزِدْنِي عِلْمًا',
    transliteration: 'Allahumma \'allimni ma yanfa\'uni wanfa\'ni bima \'allamtani wa zidni \'ilman',
    meaningEn: 'O Allah, teach me what benefits me, benefit me with what You have taught me, and increase me in knowledge',
    meaningAr: 'اللَّهُمَّ عَلِّمْنِي مَا يَنْفَعُنِي وَانْفَعْنِي بِمَا عَلَّمْتَنِي وَزِدْنِي عِلْمًا',
    count: 'Once daily',
    countAr: null,
    whenToSay: 'Before studying or teaching',
    whenToSayAr: '',
    promiseEn: 'This supplication asks for three things: beneficial knowledge, the ability to apply it, and more of it. The Year of Delegations was the Prophet \uFDFA at his most pedagogical — every delegation left having learned what they needed.',
    promiseAr: 'يطلب هذا الدعاء ثلاثة أشياء: العلم النافع والقدرة على تطبيقه والمزيد منه. كان عام الوفود النبيّ \uFDFA في أعلى حالاته التعليمية: كلّ وفد غادر وقد تعلّم ما يحتاجه.',
    sourceRef: 'Sunan Ibn Majah #92; Sunan al-Tirmidhi #3599 (Hasan)',
    sourceRefAr: '',
  ),

  // ⚠️ NEEDS REVIEW — Event #130
  // ── Event 130: Delegation of Banu Tamim ─
  'j_m4_130': DhikrCard(
    id: 'j_m4_130',
    arabicText: 'اللَّهُمَّ حَبِّبْ إِلَيْنَا الْإِيمَانَ وَزَيِّنْهُ فِي قُلُوبِنَا وَكَرِّهْ إِلَيْنَا الْكُفْرَ وَالْفُسُوقَ وَالْعِصْيَانَ',
    transliteration: 'Allahumma habbib ilayna al-iman wa zayyinhu fi qulubina wa karrih ilayna al-kufra wal-fusuqa wal-\'isyan',
    meaningEn: 'O Allah, make faith beloved to us and beautify it in our hearts, and make disbelief, wickedness, and disobedience hateful to us',
    meaningAr: 'اللَّهُمَّ حَبِّبْ إِلَيْنَا الْإِيمَانَ وَزَيِّنْهُ فِي قُلُوبِنَا وَكَرِّهْ إِلَيْنَا الْكُفْرَ وَالْفُسُوقَ وَالْعِصْيَانَ',
    count: 'Once daily',
    countAr: null,
    whenToSay: 'Morning or evening',
    whenToSayAr: '',
    promiseEn: 'This supplication from the Quran itself (49:7) asks Allah to place love of faith and hatred of its opposite inside the heart, making righteous conduct effortless rather than forced.',
    promiseAr: 'هذا الدعاء من القرآن ذاته (49:7) يطلب من الله أن يزرع حبّ الإيمان وكراهية ضدّه في القلب، فيصبح السلوك الصالح طبيعيًّا لا قسريًّا.',
    sourceRef: 'Quran 49:7',
    sourceRefAr: '',
  ),

  // ── Event 131: Delegation of Thaqif ─
  'j_m4_131': DhikrCard(
    id: 'j_m4_131',
    arabicText: 'تَوَكَّلْتُ عَلَى اللَّهِ رَبِّي وَرَبِّكُمْ، مَا مِنْ دَابَّةٍ إِلَّا هُوَ آخِذٌ بِنَاصِيَتِهَا',
    transliteration: 'Tawakkaltu \'ala Allahi Rabbi wa Rabbikum, ma min dabbatin illa huwa akhidhun bi-nasiyatiha',
    meaningEn: 'I place my trust in Allah, my Lord and your Lord. There is no creature but that He holds its forelock',
    meaningAr: 'تَوَكَّلْتُ عَلَى اللَّهِ رَبِّي وَرَبِّكُمْ، مَا مِنْ دَابَّةٍ إِلَّا هُوَ آخِذٌ بِنَاصِيَتِهَا',
    count: 'Once when facing powerful opposition',
    countAr: null,
    whenToSay: 'When confronting something feared',
    whenToSayAr: '',
    promiseEn: 'This declaration of trust from the Quran (11:56) teaches that nothing — no idol, no army, no empire — has power independent of Allah. Everything is in His grasp. The women of Thaqif feared al-Lat\'s revenge. There was nothing to avenge.',
    promiseAr: 'إعلان التوكّل هذا من القرآن (11:56) يعلّم أنّ لا شيء — لا صنم ولا جيش ولا إمبراطورية — يملك قوّة مستقلّة عن الله. كلّ شيء بقبضته. خافت نساء ثقيف انتقام اللات. لم يكن هناك ما يُنتقم.',
    sourceRef: 'Quran 11:56',
    sourceRefAr: '',
  ),

  // ── Event 132: Najrani Christians — Mubahala ─
  'j_m4_132': DhikrCard(
    id: 'j_m4_132',
    arabicText: 'رَبِّ زِدْنِي عِلْمًا',
    transliteration: 'Rabbi zidni \'ilman',
    meaningEn: 'My Lord, increase me in knowledge',
    meaningAr: 'رَبِّ زِدْنِي عِلْمًا',
    count: 'Unlimited',
    countAr: null,
    whenToSay: 'Before and after seeking knowledge',
    whenToSayAr: '',
    promiseEn: 'This Quranic supplication (20:114) is the only du\'a in the Quran where Allah instructs the Prophet \uFDFA to ask for more of something. Knowledge is the one thing we are commanded to always want more of.',
    promiseAr: 'هذا الدعاء القرآني (20:114) هو الدعاء الوحيد في القرآن الذي أمر الله فيه النبيّ \uFDFA أن يطلب المزيد من شيء. العلم الشيء الوحيد الذي أُمرنا أن نريد دائمًا المزيد منه.',
    sourceRef: 'Quran 20:114',
    sourceRefAr: '',
  ),

  // ── Event 133: Abu Bakr Leads First Hajj ─
  'j_m4_133': DhikrCard(
    id: 'j_m4_133',
    arabicText: 'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ',
    transliteration: 'Labbayk Allahumma labbayk',
    meaningEn: 'Here I am, O Allah, here I am',
    meaningAr: 'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ',
    count: 'Throughout the Hajj journey',
    countAr: null,
    whenToSay: 'From ihram until the end of the pilgrimage',
    whenToSayAr: '',
    promiseEn: 'The talbiyah is the pilgrim\'s answer to Ibrahim\'s call. Every "Labbayk" echoes across millennia, connecting the pilgrim to Ibrahim عليه السلام, to the Prophet \uFDFA, and to every Muslim who has ever circled the Ka\'bah.',
    promiseAr: 'التلبية جواب الحاجّ لنداء إبراهيم. كلّ "لبّيك" يتردّد عبر الألفيّات يربط الحاجّ بإبراهيم عليه السلام وبالنبيّ \uFDFA وبكلّ مسلمٍ طاف حول الكعبة.',
    sourceRef: 'Sahih al-Bukhari #1549',
    sourceRefAr: '',
  ),

  // ── Event 134: Ali Proclaims Surah Al-Tawbah ─
  'j_m4_134': DhikrCard(
    id: 'j_m4_134',
    arabicText: 'اللَّهُمَّ إِنِّي أَبْرَأُ إِلَيْكَ مِمَّا أَشْرَكَ الْمُشْرِكُونَ، اللَّهُمَّ إِنِّي أُشْهِدُكَ أَنَّكَ أَنْتَ اللَّهُ لَا إِلَٰهَ إِلَّا أَنْتَ',
    transliteration: 'Allahumma inni abra\'u ilayka mimma ashraka al-mushrikun, Allahumma inni ushhiduka annaka anta Allahu la ilaha illa ant',
    meaningEn: 'O Allah, I disassociate myself from what the polytheists associate with You. O Allah, I bear witness that You are Allah, there is no god but You',
    meaningAr: 'اللَّهُمَّ إِنِّي أَبْرَأُ إِلَيْكَ مِمَّا أَشْرَكَ الْمُشْرِكُونَ، اللَّهُمَّ إِنِّي أُشْهِدُكَ أَنَّكَ أَنْتَ اللَّهُ لَا إِلَٰهَ إِلَّا أَنْتَ',
    count: 'Once, upon reading or hearing Surah al-Tawbah\'s opening',
    countAr: null,
    whenToSay: 'When renewing commitment to tawhid',
    whenToSayAr: '',
    promiseEn: 'This declaration of bara\'ah (disassociation from shirk) mirrors the surah\'s opening. It is the verbal expression of the heart\'s commitment to pure tawhid, the essence of everything Ibrahim built the Ka\'bah for.',
    promiseAr: 'إعلان البراءة هذا من الشرك يعكس افتتاحية السورة. هو التعبير اللفظي عن التزام القلب بالتوحيد الخالص، جوهر كلّ ما بنى إبراهيم الكعبة من أجله.',
    sourceRef: 'Quran 9:1; scholarly tradition',
    sourceRefAr: '',
  ),

  // ── Event 135: Arabia Enters Islam ─
  'j_m4_135': DhikrCard(
    id: 'j_m4_135',
    arabicText: 'الْحَمْدُ لِلَّهِ الَّذِي هَدَانَا لِهَٰذَا وَمَا كُنَّا لِنَهْتَدِيَ لَوْلَا أَنْ هَدَانَا اللَّهُ',
    transliteration: 'Al-hamdu lillahi alladhi hadana li-hadha wa ma kunna li-nahtadiya lawla an hadanallah',
    meaningEn: 'Praise be to Allah who guided us to this, and we would never have been guided had Allah not guided us',
    meaningAr: 'الْحَمْدُ لِلَّهِ الَّذِي هَدَانَا لِهَٰذَا وَمَا كُنَّا لِنَهْتَدِيَ لَوْلَا أَنْ هَدَانَا اللَّهُ',
    count: 'Once when reflecting on blessings',
    countAr: null,
    whenToSay: 'When witnessing the fruits of faith or completing something significant',
    whenToSayAr: '',
    promiseEn: 'This Quranic du\'a (7:43) is the exclamation of the people of Paradise upon entry. It recognizes that all guidance, all success, all transformation is from Allah alone — the ultimate acknowledgment after twenty-three years of prophetic work.',
    promiseAr: 'هذا الدعاء القرآني (7:43) هتاف أهل الجنة عند دخولها. يعترف بأنّ كلّ هداية وكلّ نجاح وكلّ تحوّل من الله وحده — الاعتراف الأسمى بعد ثلاث وعشرين سنة من العمل النبوي.',
    sourceRef: 'Quran 7:43',
    sourceRefAr: '',
  ),

  // ── Event 136: Preparations for Farewell Pilgrimage ─
  'j_m4_136': DhikrCard(
    id: 'j_m4_136',
    arabicText: 'اللَّهُمَّ لَكَ الْحَمْدُ كُلُّهُ وَلَكَ الْمُلْكُ كُلُّهُ وَبِيَدِكَ الْخَيْرُ كُلُّهُ',
    transliteration: 'Allahumma laka al-hamdu kulluhu wa laka al-mulku kulluhu wa biyadika al-khayru kulluhu',
    meaningEn: 'O Allah, all praise belongs to You, all sovereignty belongs to You, and all goodness is in Your hand',
    meaningAr: 'اللَّهُمَّ لَكَ الْحَمْدُ كُلُّهُ وَلَكَ الْمُلْكُ كُلُّهُ وَبِيَدِكَ الْخَيْرُ كُلُّهُ',
    count: 'Once in supplication',
    countAr: null,
    whenToSay: 'When witnessing something magnificent',
    whenToSayAr: '',
    promiseEn: 'This comprehensive praise acknowledges that every blessing — from the ability to walk to the gathering of a hundred thousand hearts — belongs to Allah alone.',
    promiseAr: 'هذا الحمد الشامل يعترف بأنّ كلّ نعمة — من القدرة على المشي إلى اجتماع مئة ألف قلب — ملك الله وحده.',
    sourceRef: 'Part of longer hadith in Sahih Muslim; general dhikr tradition',
    sourceRefAr: '',
  ),

  // ── Event 137: The Great Procession ─
  'j_m4_137': DhikrCard(
    id: 'j_m4_137',
    arabicText: 'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ',
    transliteration: 'Labbayk Allahumma labbayk, labbayk la sharika laka labbayk',
    meaningEn: 'Here I am, O Allah, here I am. Here I am, You have no partner, here I am',
    meaningAr: 'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ',
    count: 'Continuously during Hajj',
    countAr: null,
    whenToSay: 'From ihram until arriving at the Ka\'bah',
    whenToSayAr: '',
    promiseEn: 'Each "labbayk" is the pilgrim\'s answer to Allah\'s ancient call through Ibrahim. It is the sound of surrender, of arrival, of belonging. A hundred thousand voices saying it at once is the closest thing to the sound of Paradise this world has known.',
    promiseAr: 'كلّ "لبّيك" جواب الحاجّ لنداء الله القديم عبر إبراهيم. صوت الاستسلام والوصول والانتماء. مئة ألف صوت يقولونها معًا أقرب ما عرفه هذا العالم لصوت الجنة.',
    sourceRef: 'Sahih al-Bukhari #1549; Sahih Muslim #1184',
    sourceRefAr: '',
  ),

  // ── Event 138: Entry into Mecca — Talbiyah ─
  'j_m4_138': DhikrCard(
    id: 'j_m4_138',
    arabicText: 'سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلَا إِلَٰهَ إِلَّا اللَّهُ، وَاللَّهُ أَكْبَرُ',
    transliteration: 'Subhanallah, wal-hamdu lillah, wa la ilaha illallah, wallahu akbar',
    meaningEn: 'Glory be to Allah, praise be to Allah, there is no god but Allah, and Allah is the Greatest',
    meaningAr: 'سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلَا إِلَٰهَ إِلَّا اللَّهُ، وَاللَّهُ أَكْبَرُ',
    count: 'Throughout the day of Hajj',
    countAr: null,
    whenToSay: 'During tawaf and throughout the pilgrimage',
    whenToSayAr: '',
    promiseEn: 'These are the four beloved words that the Prophet \uFDFA said are more beloved to Allah than anything the sun rises upon. During tawaf, they become a connection between the pilgrim and every soul that has ever circled this house.',
    promiseAr: 'هذه الكلمات الأربع المحبوبة التي قال النبيّ \uFDFA إنّها أحبّ إلى الله ممّا طلعت عليه الشمس. أثناء الطواف تصبح صلةً بين الحاجّ وكلّ روحٍ طافت حول هذا البيت.',
    sourceRef: 'Sahih Muslim #2695',
    sourceRefAr: '',
  ),

  // ── Event 139: Day of Arafah ─
  'j_m4_139': DhikrCard(
    id: 'j_m4_139',
    arabicText: 'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، يُحْيِي وَيُمِيتُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    transliteration: 'La ilaha illallahu wahdahu la sharika lah, lahu al-mulku wa lahu al-hamd, yuhyi wa yumit, wa huwa \'ala kulli shay\'in qadir',
    meaningEn: 'There is no god but Allah alone, with no partner. To Him belongs sovereignty and praise, He gives life and causes death, and He has power over all things',
    meaningAr: 'لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، يُحْيِي وَيُمِيتُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
    count: 'As many times as possible on the Day of Arafah',
    countAr: null,
    whenToSay: 'Throughout the Day of Arafah',
    whenToSayAr: '',
    promiseEn: 'This is the dhikr the Prophet \uFDFA called the best thing he and the prophets before him had said. On the Day of Arafah, it becomes the soul\'s declaration of complete surrender.',
    promiseAr: 'هذا الذكر الذي سمّاه النبيّ \uFDFA خير ما قاله هو والنبيّون من قبله. في يوم عرفة يصبح إعلان النفس بالاستسلام الكامل.',
    sourceRef: 'Sunan al-Tirmidhi #3585 (Hasan)',
    sourceRefAr: '',
  ),

  // ── Event 140: The Farewell Sermon ─
  'j_m4_140': DhikrCard(
    id: 'j_m4_140',
    arabicText: 'اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَىٰ إِبْرَاهِيمَ وَعَلَىٰ آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ',
    transliteration: 'Allahumma salli \'ala Muhammad wa \'ala ali Muhammad kama sallayta \'ala Ibrahim wa \'ala ali Ibrahim innaka Hamidun Majid',
    meaningEn: 'O Allah, send blessings upon Muhammad and upon the family of Muhammad, as You sent blessings upon Ibrahim and upon the family of Ibrahim. Indeed, You are Praiseworthy and Glorious',
    meaningAr: 'اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَىٰ إِبْرَاهِيمَ وَعَلَىٰ آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ',
    count: 'At least once after every prayer',
    countAr: null,
    whenToSay: 'After every prayer, and whenever the Prophet \uFDFA is mentioned',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA said: "Whoever sends one blessing upon me, Allah sends ten blessings upon him." The Farewell Sermon was his final public gift. Sending salawat upon him is ours.',
    promiseAr: 'قال النبيّ \uFDFA: "من صلّى عليّ واحدة صلّى الله عليه عشرًا." خطبة الوداع كانت هديته العلنية الأخيرة. إرسال الصلوات عليه هديتنا.',
    sourceRef: 'Sahih Muslim #384',
    sourceRefAr: '',
  ),

  // ── Event 141: "Today I Have Perfected Your Religion" ─
  'j_m4_141': DhikrCard(
    id: 'j_m4_141',
    arabicText: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
    transliteration: 'Al-hamdu lillahi Rabb il-\'alamin',
    meaningEn: 'All praise belongs to Allah, Lord of all the worlds',
    meaningAr: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
    count: 'Unlimited',
    countAr: null,
    whenToSay: 'At every moment of gratitude',
    whenToSayAr: '',
    promiseEn: 'This opening of the Quran is the simplest and most complete expression of gratitude. On the day the religion was perfected, the most appropriate response is the one the Quran opens with: praise.',
    promiseAr: 'فاتحة القرآن هي أبسط وأكمل تعبير عن الامتنان. في اليوم الذي أُكمل فيه الدين أنسب ردّ هو ما يفتتح القرآن به: الحمد.',
    sourceRef: 'Quran 1:2',
    sourceRefAr: '',
  ),

  // ── Event 142: Ghadir Khumm ─
  'j_m4_142': DhikrCard(
    id: 'j_m4_142',
    arabicText: 'اللَّهُمَّ اجْمَعْ كَلِمَةَ الْمُسْلِمِينَ وَأَصْلِحْ ذَاتَ بَيْنِهِمْ',
    transliteration: 'Allahumma ijma\' kalimat al-Muslimin wa aslih dhata baynihim',
    meaningEn: 'O Allah, unite the word of the Muslims and reconcile between them',
    meaningAr: 'اللَّهُمَّ اجْمَعْ كَلِمَةَ الْمُسْلِمِينَ وَأَصْلِحْ ذَاتَ بَيْنِهِمْ',
    count: 'Once daily',
    countAr: null,
    whenToSay: 'When reflecting on Muslim unity',
    whenToSayAr: '',
    promiseEn: 'Unity is one of Islam\'s highest values. This du\'a asks for what the Prophet \uFDFA worked his entire life to build: a community united in faith, despite differences in interpretation. The prayer for unity is itself an act of love for the ummah.',
    promiseAr: 'الوحدة من أسمى قيم الإسلام. يطلب هذا الدعاء ما عمل النبيّ \uFDFA حياته كلّها لبنائه: مجتمع موحّد بالإيمان رغم اختلاف التفاسير. الدعاء بالوحدة هو ذاته عمل حبّ للأمّة.',
    sourceRef: 'General du\'a based on Quranic principles (3:103, 8:63)',
    sourceRefAr: '',
  ),

  // ── Event 143: Return to Medina ─
  'j_m4_143': DhikrCard(
    id: 'j_m4_143',
    arabicText: 'إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ، اللَّهُمَّ أْجُرْنِي فِي مُصِيبَتِي وَأَخْلِفْ لِي خَيْرًا مِنْهَا',
    transliteration: 'Inna lillahi wa inna ilayhi raji\'un, Allahumma ajurni fi musibati wa akhlif li khayran minha',
    meaningEn: 'To Allah we belong and to Him we return. O Allah, reward me in my affliction and replace it with something better',
    meaningAr: 'إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ، اللَّهُمَّ أْجُرْنِي فِي مُصِيبَتِي وَأَخْلِفْ لِي خَيْرًا مِنْهَا',
    count: 'When facing loss',
    countAr: null,
    whenToSay: 'Upon hearing news of death or facing any calamity',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA said: "No Muslim is struck with a calamity and says this except that Allah rewards them and replaces their loss with something better." Umm Salama said it when her husband died, and Allah replaced him with the Prophet \uFDFA himself.',
    promiseAr: 'قال النبيّ \uFDFA: "ما من مسلم تصيبه مصيبة فيقول ذلك إلّا أجره الله وأخلف له خيرًا منها." قالتها أمّ سلمة حين مات زوجها فأخلف الله لها النبيّ \uFDFA نفسه.',
    sourceRef: 'Sahih Muslim #918',
    sourceRefAr: '',
  ),

  // ── Event 144: Usama's Expedition Ordered ─
  'j_m4_144': DhikrCard(
    id: 'j_m4_144',
    arabicText: 'اللَّهُمَّ أَعِزَّ الْإِسْلَامَ وَالْمُسْلِمِينَ',
    transliteration: 'Allahumma a\'izza al-Islam wal-Muslimin',
    meaningEn: 'O Allah, honor Islam and the Muslims',
    meaningAr: 'اللَّهُمَّ أَعِزَّ الْإِسْلَامَ وَالْمُسْلِمِينَ',
    count: 'Once daily',
    countAr: null,
    whenToSay: 'When praying for the ummah',
    whenToSayAr: '',
    promiseEn: 'This simple supplication asks for the same thing the Prophet \uFDFA worked his entire life for: the honor and strength of the Muslim community. Usama\'s army was part of that vision — projecting strength even at the most vulnerable moment.',
    promiseAr: 'يطلب هذا الدعاء البسيط الشيء ذاته الذي عمل النبيّ \uFDFA حياته كلّها من أجله: عزّة المجتمع المسلم وقوّته. جيش أسامة كان جزءًا من تلك الرؤية: إسقاط القوّة حتّى في أشدّ اللحظات ضعفًا.',
    sourceRef: 'General du\'a; widely attributed',
    sourceRefAr: '',
  ),

  // ── Event 145: The Illness Begins ─
  'j_m4_145': DhikrCard(
    id: 'j_m4_145',
    arabicText: 'اللَّهُمَّ أَعِنِّي عَلَىٰ سَكَرَاتِ الْمَوْتِ',
    transliteration: 'Allahumma a\'inni \'ala sakarati al-mawt',
    meaningEn: 'O Allah, help me through the agonies of death',
    meaningAr: 'اللَّهُمَّ أَعِنِّي عَلَىٰ سَكَرَاتِ الْمَوْتِ',
    count: 'When facing severe hardship',
    countAr: null,
    whenToSay: 'In moments of extreme difficulty',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA himself asked for help with death\'s agonies, showing that even prophets feel pain and seek Allah\'s aid. This du\'a gives permission to every human to admit their fear and ask for help.',
    promiseAr: 'النبيّ \uFDFA نفسه طلب العون في سكرات الموت مُظهرًا أنّ حتّى الأنبياء يشعرون بالألم ويطلبون عون الله. هذا الدعاء يمنح كلّ إنسان الإذن بالاعتراف بخوفه وطلب المساعدة.',
    sourceRef: 'Sahih al-Bukhari #4449; Al-Raheeq Al-Makhtum Ch. 37',
    sourceRefAr: '',
  ),

  // ── Event 146: Visiting Graves of Uhud ─
  'j_m4_146': DhikrCard(
    id: 'j_m4_146',
    arabicText: 'اللَّهُمَّ لَا تَحْرِمْنَا أَجْرَهُمْ وَلَا تَفْتِنَّا بَعْدَهُمْ',
    transliteration: 'Allahumma la tahrimna ajrahum wa la taftinna ba\'dahum',
    meaningEn: 'O Allah, do not deprive us of their reward, and do not test us after them',
    meaningAr: 'اللَّهُمَّ لَا تَحْرِمْنَا أَجْرَهُمْ وَلَا تَفْتِنَّا بَعْدَهُمْ',
    count: 'When visiting graves or remembering the deceased',
    countAr: null,
    whenToSay: 'At cemeteries, or when remembering the departed',
    whenToSayAr: '',
    promiseEn: 'This du\'a from the Prophet\'s own prayer at Uhud asks for two things: that the living benefit from the sacrifice of the dead, and that they not be tested beyond their capacity. It is both gratitude and supplication.',
    promiseAr: 'يطلب هذا الدعاء من صلاة النبيّ في أُحد شيئين: أن ينتفع الأحياء بتضحية الموتى وألّا يُختبروا فوق طاقتهم. شكرٌ ودعاء معًا.',
    sourceRef: 'Sahih Muslim #974',
    sourceRefAr: '',
  ),

  // ── Event 147: Abu Bakr Leads the Prayer ─
  'j_m4_147': DhikrCard(
    id: 'j_m4_147',
    arabicText: 'اللَّهُمَّ تَقَبَّلْ مِنَّا إِنَّكَ أَنْتَ السَّمِيعُ الْعَلِيمُ',
    transliteration: 'Allahumma taqabbal minna innaka anta al-Sami\' al-\'Alim',
    meaningEn: 'O Allah, accept from us. Indeed, You are the All-Hearing, the All-Knowing',
    meaningAr: 'اللَّهُمَّ تَقَبَّلْ مِنَّا إِنَّكَ أَنْتَ السَّمِيعُ الْعَلِيمُ',
    count: 'After prayer',
    countAr: null,
    whenToSay: 'After completing any act of worship',
    whenToSayAr: '',
    promiseEn: 'This du\'a of Ibrahim and Isma\'il عليهما السلام (2:127) as they built the Ka\'bah is the prayer of every builder: accept what I have built. The Prophet \uFDFA built a community; now he asks Allah to accept it.',
    promiseAr: 'هذا دعاء إبراهيم وإسماعيل عليهما السلام (2:127) وهما يبنيان الكعبة وهو دعاء كلّ بانٍ: تقبّل ما بنيت. النبيّ \uFDFA بنى أمّة، والآن يسأل الله أن يتقبّلها.',
    sourceRef: 'Quran 2:127',
    sourceRefAr: '',
  ),

  // ── Event 148: Final Appearance in the Mosque ─
  'j_m4_148': DhikrCard(
    id: 'j_m4_148',
    arabicText: 'بَلِ الرَّفِيقَ الْأَعْلَىٰ مِنَ الْجَنَّةِ',
    transliteration: 'Bal al-Rafiqa al-A\'la min al-Jannah',
    meaningEn: 'Rather the highest companions in Paradise',
    meaningAr: 'بَلِ الرَّفِيقَ الْأَعْلَىٰ مِنَ الْجَنَّةِ',
    count: 'Once in reflection',
    countAr: null,
    whenToSay: 'When contemplating the afterlife',
    whenToSayAr: '',
    promiseEn: 'These were the last words of the last prophet. They teach that death is a choice for those who have earned it: this world, or the company of Allah. The Prophet \uFDFA chose. The choice itself is the promise.',
    promiseAr: 'هذه كانت آخر كلمات آخر نبيّ. تعلّم أنّ الموت اختيارٌ لمن استحقّه: هذا العالم أو صحبة الله. اختار النبيّ \uFDFA. الاختيار ذاته هو الوعد.',
    sourceRef: 'Sahih al-Bukhari #4449-4451',
    sourceRefAr: '',
  ),

  // ── Event 149: The Final Days ─
  'j_m4_149': DhikrCard(
    id: 'j_m4_149',
    arabicText: 'لَا إِلَٰهَ إِلَّا اللَّهُ، إِنَّ لِلْمَوْتِ لَسَكَرَاتٍ',
    transliteration: 'La ilaha illallah, inna lil-mawti la-sakarat',
    meaningEn: 'There is no god but Allah. Indeed, death has its agonies',
    meaningAr: 'لَا إِلَٰهَ إِلَّا اللَّهُ، إِنَّ لِلْمَوْتِ لَسَكَرَاتٍ',
    count: 'When facing extreme difficulty',
    countAr: null,
    whenToSay: 'In moments of great trial',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA said this while wiping his face with water during his death agonies. Even at the threshold of death, his declaration was tawhid. The lesson: when everything else is stripped away, the only thing that remains is La ilaha illallah.',
    promiseAr: 'قال النبيّ \uFDFA هذا وهو يمسح وجهه بالماء في سكرات الموت. حتّى على عتبة الموت كان إعلانه التوحيد. الدرس: حين يُجرَّد كلّ شيء آخر لا يبقى إلّا لا إله إلّا الله.',
    sourceRef: 'Sahih al-Bukhari #4449',
    sourceRefAr: '',
  ),

  // ── Event 150: The Departure ─
  'j_m4_150': DhikrCard(
    id: 'j_m4_150',
    arabicText: 'إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ',
    transliteration: 'Inna lillahi wa inna ilayhi raji\'un',
    meaningEn: 'To Allah we belong and to Him we return',
    meaningAr: 'إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ',
    count: 'When receiving news of death',
    countAr: null,
    whenToSay: 'Upon hearing of any loss or calamity',
    whenToSayAr: '',
    promiseEn: 'This is the Quran\'s own response to loss (2:156). It places every departure in cosmic context: we came from Allah and we return to Him. The Prophet \uFDFA has returned. And one day, every Rawi who reads these words will return too.',
    promiseAr: 'هذا ردّ القرآن ذاته على الفقد (2:156). يضع كلّ رحيل في سياقٍ كوني: جئنا من الله وإليه نعود. عاد النبيّ \uFDFA. ويومًا ما كلّ راوٍ يقرأ هذه الكلمات سيعود أيضًا.',
    sourceRef: 'Quran 2:156',
    sourceRefAr: '',
  ),

  // ── Event 151: Umar's Grief ─
  'j_m4_151': DhikrCard(
    id: 'j_m4_151',
    arabicText: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
    transliteration: 'Hasbunallahu wa ni\'ma al-Wakil',
    meaningEn: 'Allah is sufficient for us, and He is the best Disposer of affairs',
    meaningAr: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
    count: 'Seven times morning and evening',
    countAr: null,
    whenToSay: 'In moments of overwhelming distress',
    whenToSayAr: '',
    promiseEn: 'This was the du\'a of Ibrahim عليه السلام when thrown into fire, and the du\'a of the companions at Uhud. In the moment of greatest loss, it declares that Allah alone is enough. When the Prophet \uFDFA is gone, Allah remains.',
    promiseAr: 'هذا دعاء إبراهيم عليه السلام حين أُلقي في النار ودعاء الصحابة في أُحد. في لحظة الفقد الأعظم يُعلن أنّ الله وحده كافٍ. حين يرحل النبيّ \uFDFA يبقى الله.',
    sourceRef: 'Quran 3:173; Sahih al-Bukhari #4563',
    sourceRefAr: '',
  ),

  // ── Event 152: Abu Bakr's Address ─
  'j_m4_152': DhikrCard(
    id: 'j_m4_152',
    arabicText: 'وَمَا مُحَمَّدٌ إِلَّا رَسُولٌ قَدْ خَلَتْ مِنْ قَبْلِهِ الرُّسُلُ',
    transliteration: 'Wa ma Muhammadun illa rasulun qad khalat min qablihi al-rusul',
    meaningEn: 'Muhammad is not but a messenger. Other messengers have passed on before him',
    meaningAr: 'وَمَا مُحَمَّدٌ إِلَّا رَسُولٌ قَدْ خَلَتْ مِنْ قَبْلِهِ الرُّسُلُ',
    count: 'Once, in moments of grief over loss',
    countAr: null,
    whenToSay: 'When mourning a loss that feels unbearable',
    whenToSayAr: '',
    promiseEn: 'This verse (3:144) teaches the deepest truth about loss: no person, however beloved, is the source. Allah is the source. The messenger carries the message, but the message outlives the messenger. This is both the hardest and most liberating lesson of the Seerah.',
    promiseAr: 'تعلّم هذه الآية (3:144) أعمق حقيقة عن الفقد: لا شخص مهما كان محبوبًا هو المصدر. الله هو المصدر. الرسول يحمل الرسالة لكنّ الرسالة تبقى بعد الرسول. هذا أصعب دروس السيرة وأكثرها تحريرًا.',
    sourceRef: 'Quran 3:144',
    sourceRefAr: '',
  ),

  // ── Event 153: Funeral Prayer ─
  'j_m4_153': DhikrCard(
    id: 'j_m4_153',
    arabicText: 'اللَّهُمَّ اغْفِرْ لَهُ وَارْحَمْهُ وَعَافِهِ وَاعْفُ عَنْهُ وَأَكْرِمْ نُزُلَهُ',
    transliteration: 'Allahumma ighfir lahu warhamhu wa \'afihi wa\'fu \'anhu wa akrim nuzulahu',
    meaningEn: 'O Allah, forgive him, have mercy on him, grant him wellness, pardon him, and honor his reception',
    meaningAr: 'اللَّهُمَّ اغْفِرْ لَهُ وَارْحَمْهُ وَعَافِهِ وَاعْفُ عَنْهُ وَأَكْرِمْ نُزُلَهُ',
    count: 'During funeral prayer',
    countAr: null,
    whenToSay: 'In the janazah prayer for any Muslim',
    whenToSayAr: '',
    promiseEn: 'This du\'a from the funeral prayer asks Allah to welcome the departed with the honor due to a guest. The Prophet \uFDFA taught it for all Muslims. Now it was said for him.',
    promiseAr: 'يطلب هذا الدعاء من صلاة الجنازة أن يستقبل الله المتوفّى بالإكرام الواجب للضيف. علّمه النبيّ \uFDFA لكلّ المسلمين. الآن قيل له.',
    sourceRef: 'Sahih Muslim #963',
    sourceRefAr: '',
  ),

  // ── Event 154: The Burial ─
  'j_m4_154': DhikrCard(
    id: 'j_m4_154',
    arabicText: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَىٰ نَبِيِّنَا مُحَمَّدٍ',
    transliteration: 'Allahumma salli wa sallim \'ala nabiyyina Muhammad',
    meaningEn: 'O Allah, send blessings and peace upon our Prophet Muhammad',
    meaningAr: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَىٰ نَبِيِّنَا مُحَمَّدٍ',
    count: 'Unlimited',
    countAr: null,
    whenToSay: 'Always, and especially on Fridays',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA said: "Whoever sends blessings upon me, Allah sends ten blessings upon him." His body lies beneath the Green Dome. His soul is with the highest companions. Our salawat is the thread between us and him across time.',
    promiseAr: 'قال النبيّ \uFDFA: "من صلّى عليّ واحدة صلّى الله عليه عشرًا." جسده تحت القبّة الخضراء. روحه مع الرفيق الأعلى. صلواتنا هي الخيط بيننا وبينه عبر الزمن.',
    sourceRef: 'Sahih Muslim #384',
    sourceRefAr: '',
  ),

  // ── Event 155: You Are the Rawi ─
  'j_m4_155': DhikrCard(
    id: 'j_m4_155',
    arabicText: 'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا أَنْتَ، أَسْتَغْفِرُكَ وَأَتُوبُ إِلَيْكَ',
    transliteration: 'Subhanaka Allahumma wa bihamdik, ash-hadu an la ilaha illa ant, astaghfiruka wa atubu ilayk',
    meaningEn: 'Glory and praise be to You, O Allah. I bear witness that there is no god but You. I seek Your forgiveness and turn to You in repentance',
    meaningAr: 'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا أَنْتَ، أَسْتَغْفِرُكَ وَأَتُوبُ إِلَيْكَ',
    count: 'Once at the end of every gathering',
    countAr: null,
    whenToSay: 'At the closing of any gathering, study session, or journey',
    whenToSayAr: '',
    promiseEn: 'The Prophet \uFDFA said: "Whoever says this at the end of a gathering, whatever shortcomings occurred during that gathering will be forgiven." This is how every journey of knowledge should end: with praise, witness, and repentance.',
    promiseAr: 'قال النبيّ \uFDFA: "من قال ذلك في ختام مجلسه كان كفّارةً لما حدث فيه." هكذا يجب أن تنتهي كلّ رحلة علم: بالحمد والشهادة والتوبة.',
    sourceRef: 'Sunan Abu Dawud #4859 (Sahih); Sunan al-Tirmidhi #3433',
    sourceRefAr: '',
  ),

};
