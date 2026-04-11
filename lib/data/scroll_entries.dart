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
  'j_1_2_8': ScrollEntry(
    eventId: 'j_1_2_8',
    globalOrder: 15,
    lineEn:
        'A wife, a friend, a child, and a freed man — four people became the first to carry a truth the whole world would one day know.',
    lineAr:
        'زوجة وصديق وطفل ومحرَّر — أربعة أشخاص كانوا أول من حمل حقيقة سيعرفها العالم كله يوماً.',
  ),
  'j_m1_016': ScrollEntry(
    eventId: 'j_m1_016',
    globalOrder: 16,
    lineEn:
        'For three years, Islam grew in whispers — forty believers meeting in a living room, praying in hidden valleys, memorizing lightning.',
    lineAr:
        'لمدة ثلاث سنوات نما الإسلام همساً — أربعون مؤمناً يجتمعون في غرفة ويصلون في شعاب خفية ويحفظون صواعق.',
  ),
  'j_1_3_1': ScrollEntry(
    eventId: 'j_1_3_1',
    globalOrder: 17,
    lineEn:
        'He climbed a hill and asked them one question. They all said yes. Then he told them the truth, and the world split in two.',
    lineAr:
        'صعد تلة وسألهم سؤالاً واحداً. قالوا جميعاً نعم. ثم أخبرهم بالحق، وانشقّ العالم إلى نصفين.',
  ),
  'j_1_3_2': ScrollEntry(
    eventId: 'j_1_3_2',
    globalOrder: 18,
    lineEn:
        'They offered him a crown, wealth, and anything he desired. He wanted none of it. The sun and the moon were not enough to buy his silence.',
    lineAr:
        'عرضوا عليه التاج والمال وكل ما يشتهي. لم يرد شيئاً منها. الشمس والقمر لم يكونا كافيين لشراء صمته.',
  ),
  'j_1_3_3': ScrollEntry(
    eventId: 'j_1_3_3',
    globalOrder: 19,
    lineEn:
        'A slave said "One" under a boulder. A mother died rather than deny. The weakest became the strongest proof.',
    lineAr:
        'عبدٌ قال "أحد" تحت صخرة. وأمٌّ ماتت ولم تنكر. الأضعف صاروا أقوى دليل.',
  ),
  'j_1_3_4': ScrollEntry(
    eventId: 'j_1_3_4',
    globalOrder: 20,
    lineEn:
        'Fifteen people boarded two boats and crossed the sea, trusting a king they had never met. Justice has no borders.',
    lineAr:
        'خمسة عشر شخصاً ركبوا مركبتين وعبروا البحر واثقين بملك لم يلتقوه قط. العدل لا يعرف حدوداً.',
  ),
  'j_1_3_5': ScrollEntry(
    eventId: 'j_1_3_5',
    globalOrder: 21,
    lineEn: 'A refugee stood in a king\'s court and spoke the truth. The king wept, drew a line in the sand, and said: the difference is no more than this.',
    lineAr: 'وقف لاجئ في بلاط ملك ونطق بالحق. بكى الملك ورسم خطاً في الرمل وقال: الفرق لا يتجاوز هذا.',
  ),

  'j_1_3_11': ScrollEntry(
    eventId: 'j_1_3_11',
    globalOrder: 22,
    lineEn: 'A Christian king refused a bribe, protected strangers, and taught the world that justice has no religion — only conscience.',
    lineAr: 'ملك مسيحي رفض رشوة وحمى غرباء وعلّم العالم أن العدل لا دين له — بل ضمير فقط.',
  ),

  'j_1_3_6': ScrollEntry(
    eventId: 'j_1_3_6',
    globalOrder: 23,
    lineEn: 'A hunter returned from the wild, heard an insult, and struck. By morning, his rage had become faith, and Mecca had a new protector.',
    lineAr: 'عاد صياد من البرية وسمع إهانة فضرب. وبحلول الفجر صار غضبه إيماناً وصارت لمكة حامٍ جديد.',
  ),

  'j_1_3_7': ScrollEntry(
    eventId: 'j_1_3_7',
    globalOrder: 24,
    lineEn: 'A man drew his sword to kill the truth. He read a page instead. By nightfall, he marched the Muslims to pray openly at the Ka\'bah.',
    lineAr: 'سلّ رجل سيفه ليقتل الحق. فقرأ صفحة بدلاً من ذلك. وقبل الغروب قاد المسلمين ليصلوا جهاراً عند الكعبة.',
  ),

  'j_1_3_8': ScrollEntry(
    eventId: 'j_1_3_8',
    globalOrder: 25,
    lineEn: 'A hundred souls crossed the sea. Mecca tried to break Islam with pain, but all it did was plant it in a second land.',
    lineAr: 'مئة نفس عبرت البحر. حاولت مكة كسر الإسلام بالألم فكل ما فعلته أنها زرعته في أرض ثانية.',
  ),

  'j_1_3_9': ScrollEntry(
    eventId: 'j_1_3_9',
    globalOrder: 26,
    lineEn: 'A city sealed a ravine with hunger and silence. Inside, a community that was meant to break only grew stronger.',
    lineAr: 'أغلقت مدينة شِعباً بالجوع والصمت. وفي الداخل جماعة أُريد لها أن تنكسر فلم تزدد إلا قوة.',
  ),

  'j_1_3_10': ScrollEntry(
    eventId: 'j_1_3_10',
    globalOrder: 27,
    lineEn: 'Three years in a ravine. Leather boiled for food. An old man guarding his nephew every night. The pact ate itself, but it had already consumed everything they had.',
    lineAr: 'ثلاث سنوات في شِعب. جلود تُسلق للأكل. وشيخ يحرس ابن أخيه كل ليلة. الصحيفة أكلت نفسها لكنها كانت قد أكلت كل ما يملكون.',
  ),

  'j_m1_028': ScrollEntry(
    eventId: 'j_m1_028',
    globalOrder: 28,
    lineEn: 'The pact ate itself — termites devoured every word except Allah\'s name. The ravine opened, and the survivors walked out carrying nothing but faith.',
    lineAr: 'الصحيفة أكلت نفسها — الأرَضة التهمت كل كلمة إلا اسم الله. فُتح الشِّعب وخرج الناجون لا يحملون شيئاً سوى الإيمان.',
  ),

  'j_m1_029': ScrollEntry(
    eventId: 'j_m1_029',
    globalOrder: 29,
    lineEn: 'The first believer left the world. The Prophet \uFDFA lowered her into the earth with his own hands, and years later, pitched his victory tent beside her grave.',
    lineAr: 'رحلت أول مؤمنة. أنزلها النبي \uFDFA بيديه في التراب، وبعد سنوات نصب خيمة نصره بجوار قبرها.',
  ),

  'j_m1_030': ScrollEntry(
    eventId: 'j_m1_030',
    globalOrder: 30,
    lineEn: 'Within days, he lost the wife who believed first and the uncle who protected longest. The Year of Grief began, and so did the search for a new home.',
    lineAr: 'في أيام متقاربة فقد الزوجة التي آمنت أولاً والعم الذي حمى أطول. بدأ عام الحزن وبدأ معه البحث عن وطن جديد.',
  ),

  'j_m1_031': ScrollEntry(
    eventId: 'j_m1_031',
    globalOrder: 31,
    lineEn: 'They stoned him until his sandals filled with blood. An angel offered to crush them. He said: perhaps their children will believe.',
    lineAr: 'رجموه حتى امتلأ نعلاه دماً. عرض عليه ملَك أن يسحقهم. قال: لعل أبناءهم يؤمنون.',
  ),

  'j_m1_032': ScrollEntry(
    eventId: 'j_m1_032',
    globalOrder: 32,
    lineEn: 'When every human door shut, the unseen world opened. Jinn heard the Quran in a desert valley and believed before the people of two cities would.',
    lineAr: 'حين أُغلقت كل الأبواب البشرية انفتح عالم الغيب. الجن سمعوا القرآن في وادٍ صحراوي وآمنوا قبل أن تؤمن مدينتان.',
  ),

  'j_m1_033': ScrollEntry(
    eventId: 'j_m1_033',
    globalOrder: 33,
    lineEn: 'He went to every tribe in Arabia. Every one refused. Then six men from a city he had never visited said: this is the one the Jews warned us about.',
    lineAr: 'ذهب إلى كل قبيلة في الجزيرة. رفضته جميعاً. ثم قال ستة رجال من مدينة لم يزرها قط: هذا من حذّرنا منه اليهود.',
  ),

  'j_m1_034': ScrollEntry(
    eventId: 'j_m1_034',
    globalOrder: 34,
    lineEn: 'One night, he journeyed from Mecca to Jerusalem to the highest heaven. He returned with five prayers — the only command given beyond the stars.',
    lineAr: 'في ليلة واحدة رحل من مكة إلى القدس إلى أعلى السماوات. وعاد بخمس صلوات — الأمر الوحيد الذي أُعطي فوق النجوم.',
  ),

  'j_m1_035': ScrollEntry(
    eventId: 'j_m1_035',
    globalOrder: 35,
    lineEn: '"If he said it, then he spoke the truth." One sentence earned a man the title Al-Siddiq and a place beside the Prophet \uFDFA for eternity.',
    lineAr: '"إن كان قالها فقد صدق." جملة واحدة منحت رجلاً لقب الصدّيق ومكاناً بجانب النبي \uFDFA إلى الأبد.',
  ),

  'j_m1_036': ScrollEntry(
    eventId: 'j_m1_036',
    globalOrder: 36,
    lineEn: 'Twelve men met in a rocky pass at night and made a promise that had nothing to do with war — only character. One teacher was sent north, and within a year, a city was ready.',
    lineAr: 'اثنا عشر رجلاً التقوا في ممر صخري ليلاً وقطعوا وعداً لا علاقة له بالحرب بل بالخُلق فقط. أُرسل معلّم واحد شمالاً وخلال سنة كانت مدينة جاهزة.',
  ),

  'j_m1_038': ScrollEntry(
    eventId: 'j_m1_038',
    globalOrder: 38,
    lineEn: 'Seventy-three men and two women pledged in the dark to protect a man their city had never met. War was now on the table, and the migration had begun.',
    lineAr: 'ثلاثة وسبعون رجلاً وامرأتان بايعوا في الظلام على حماية رجل لم تلتقِه مدينتهم قط. الحرب صارت على الطاولة والهجرة بدأت.',
  ),

  'j_m1_039': ScrollEntry(
    eventId: 'j_m1_039',
    globalOrder: 39,
    lineEn: 'They surrounded his house with drawn swords. He walked between them, unseen, reciting Quran. The greatest escape began in silence.',
    lineAr: 'أحاطوا ببيته بالسيوف. مشى بينهم غير مرئي يتلو القرآن. أعظم هروب بدأ في صمت.',
  ),

  'j_m1_040': ScrollEntry(
    eventId: 'j_m1_040',
    globalOrder: 40,
    lineEn: 'A young man lay in the Prophet\'s \uFDFA bed while swords circled the house. At dawn they found the wrong person. The real journey had already begun.',
    lineAr: 'شاب نام في فراش النبي \uFDFA والسيوف تطوّق البيت. عند الفجر وجدوا الشخص الخطأ. الرحلة الحقيقية كانت قد بدأت بالفعل.',
  ),

  'j_m1_041': ScrollEntry(
    eventId: 'j_m1_041',
    globalOrder: 41,
    lineEn: 'A bounty hunter\'s horse sank three times. He asked for mercy instead of the reward. A fugitive promised him the bracelets of an emperor — and seventeen years later, he wore them.',
    lineAr: 'فرس صائد مكافآت غاص ثلاث مرات. طلب الأمان بدل المكافأة. هارب وعده بسواري إمبراطور — وبعد سبعة عشر عاماً لبسها.',
  ),

  'j_m1_042': ScrollEntry(
    eventId: 'j_m1_042',
    globalOrder: 42,
    lineEn: 'Two men hid in a cave while a city hunted them. A spider wove, a dove nested, and the trackers left saying no one had entered. Allah is the best of planners.',
    lineAr: 'رجلان اختبأا في غار ومدينة تطاردهم. عنكبوت نسجت وحمامة عشّشت والمتتبعون عادوا قائلين لم يدخل أحد. والله خير الماكرين.',
  ),

  'j_m1_044': ScrollEntry(
    eventId: 'j_m1_044',
    globalOrder: 44,
    lineEn: 'He laid the first stones of the first mosque, led the first Friday prayer, and rode toward a city that was about to become the capital of a new civilization.',
    lineAr: 'وضع أول حجارة لأول مسجد وأمّ أول صلاة جمعة وركب نحو مدينة ستصبح عاصمة حضارة جديدة.',
  ),

  'j_m1_047': ScrollEntry(
    eventId: 'j_m1_047',
    globalOrder: 47,
    lineEn: 'A camel knelt in an empty lot. Girls sang from the rooftops. The city was renamed, and the building of a civilization began where the animal chose to rest.',
    lineAr: 'بركت ناقة في أرض فضاء. وأنشدت البنات من فوق الأسطح. أُعيد تسمية المدينة وبدأ بناء حضارة حيث اختار الحيوان أن يستريح.',
  ),

  'j_m2_048': ScrollEntry(
    eventId: 'j_m2_048',
    globalOrder: 48,
    lineEn: 'He bought the land, cleared the ground, and carried the bricks himself. The first mosque was a school, a shelter, a parliament, and a home — all in one.',
    lineAr: 'اشترى الأرض وأزال ما عليها وحمل اللبن بيديه. المسجد الأول كان مدرسة وملجأ وبرلماناً وبيتاً — في بناء واحد.',
  ),

  'j_m2_049': ScrollEntry(
    eventId: 'j_m2_049',
    globalOrder: 49,
    lineEn: 'He paired strangers as brothers. One offered half his wealth. The other said: just show me where the market is. A nation was built on that exchange.',
    lineAr: 'آخى بين غرباء. أحدهم عرض نصف ماله والآخر قال: فقط دلّني على السوق. على هذا التبادل بُنيت أمة.',
  ),

  'j_m2_050': ScrollEntry(
    eventId: 'j_m2_050',
    globalOrder: 50,
    lineEn: 'A constitution was written. Muslims and Jews formed one nation. Freedom of worship was guaranteed. The first Islamic state was born not from conquest, but from a contract.',
    lineAr: 'كُتب دستور. المسلمون واليهود شكّلوا أمة واحدة. حرية العبادة مضمونة. أول دولة إسلامية وُلدت لا من فتح بل من عقد.',
  ),

  'j_m2_051': ScrollEntry(
    eventId: 'j_m2_051',
    globalOrder: 51,
    lineEn: 'A voice rose above Medina, and the sky learned the sound of faith.',
    lineAr: 'ارتفع صوتٌ فوق المدينة، فتعلّمت السماء صوت الإيمان.',
  ),

  'j_m2_052': ScrollEntry(
    eventId: 'j_m2_052',
    globalOrder: 52,
    lineEn: 'The rows turned mid-prayer, and faith proved it was never about the direction of the body.',
    lineAr: 'استدارت الصفوف في منتصف الصلاة، فأثبت الإيمان أنّه لم يكن يومًا عن اتجاه الجسد.',
  ),

  'j_m2_053': ScrollEntry(
    eventId: 'j_m2_053',
    globalOrder: 53,
    lineEn: 'Before the sword was drawn, the road itself became the message.',
    lineAr: 'قبل أن يُسلّ السيف، أصبح الطريق ذاته هو الرسالة.',
  ),

  'j_m2_054': ScrollEntry(
    eventId: 'j_m2_054',
    globalOrder: 54,
    lineEn: 'A decision made in a valley taught an entire nation the weight of a sacred day.',
    lineAr: 'قرارٌ اتُّخذ في وادٍ علّم أمّةً بأسرها ثقل يومٍ حرام.',
  ),

  'j_m2_055': ScrollEntry(
    eventId: 'j_m2_055',
    globalOrder: 55,
    lineEn: 'Three hundred walked toward the unknown, and every step was a choice.',
    lineAr: 'مشى ثلاثمئةٍ نحو المجهول، وكلّ خطوةٍ كانت اختيارًا.',
  ),

  'j_m2_056': ScrollEntry(
    eventId: 'j_m2_056',
    globalOrder: 56,
    lineEn: 'Rain fell on two armies, and only one woke with firm ground beneath its feet.',
    lineAr: 'هطل المطر على جيشَين، ولم يصحُ إلّا واحدٌ وتحت قدميه أرضٌ صلبة.',
  ),

  'j_m2_057': ScrollEntry(
    eventId: 'j_m2_057',
    globalOrder: 57,
    lineEn: 'Three hundred stood where a thousand should have prevailed, and heaven intervened.',
    lineAr: 'وقف ثلاثمئة حيث كان ينبغي أن ينتصر الألف، فتدخّلت السماء.',
  ),

  'j_m2_058': ScrollEntry(
    eventId: 'j_m2_058',
    globalOrder: 58,
    lineEn: 'At Badr, the unseen world crossed into the seen, and the dust carried more than sand.',
    lineAr: 'في بدر عبر عالم الغيب إلى عالم الشهادة، وحمل الغبار أكثر من الرمل.',
  ),

  'j_m2_059': ScrollEntry(
    eventId: 'j_m2_059',
    globalOrder: 59,
    lineEn: 'In the shadow of war, a prisoner\'s alphabet became worth more than his gold.',
    lineAr: 'في ظلّ الحرب، أصبح أبجديّة الأسير أغلى من ذهبه.',
  ),

  'j_m2_060': ScrollEntry(
    eventId: 'j_m2_060',
    globalOrder: 60,
    lineEn: 'A pact broken in the marketplace echoed louder than any battle cry.',
    lineAr: 'عهدٌ نُقض في السوق كان صداه أعلى من أيّ صيحة حرب.',
  ),

  'j_m2_061': ScrollEntry(
    eventId: 'j_m2_061',
    globalOrder: 61,
    lineEn: 'A poet\'s journey to the enemy camp turned words into weapons and silence into the only answer.',
    lineAr: 'رحلة شاعرٍ إلى معسكر العدوّ حوّلت الكلمات إلى أسلحة والصمت إلى الجواب الوحيد.',
  ),

  'j_m2_062': ScrollEntry(
    eventId: 'j_m2_062',
    globalOrder: 62,
    lineEn: 'Badr\'s victors had barely rested when the dust of three thousand rose on the southern horizon.',
    lineAr: 'بالكاد استراح منتصرو بدرٍ حين ارتفع غبار ثلاثة آلاف في الأفق الجنوبي.',
  ),

  'j_m2_063': ScrollEntry(
    eventId: 'j_m2_063',
    globalOrder: 63,
    lineEn: 'Seven hundred stood where a thousand had promised to be, and the mountain watched.',
    lineAr: 'وقف سبعمئة حيث وعد ألفٌ بالوقوف، والجبل يراقب.',
  ),

  'j_m2_064': ScrollEntry(
    eventId: 'j_m2_064',
    globalOrder: 64,
    lineEn: 'An order disobeyed on a small hill turned the tide of a battle and taught a nation the cost of a single choice.',
    lineAr: 'أمرٌ عُصي على تلّةٍ صغيرة غيّر مجرى معركةٍ وعلّم أمّةً ثمن خيارٍ واحد.',
  ),

  'j_m2_065': ScrollEntry(
    eventId: 'j_m2_065',
    globalOrder: 65,
    lineEn: 'On a hill above the battle, obedience held its ground while everything else collapsed.',
    lineAr: 'على تلّةٍ فوق المعركة، صمدت الطاعة بينما انهار كلّ شيء آخر.',
  ),

  'j_m2_066': ScrollEntry(
    eventId: 'j_m2_066',
    globalOrder: 66,
    lineEn: 'The lion of Allah fell, and even the mountains of Medina seemed to grieve.',
    lineAr: 'سقط أسد الله، وبدا أنّ حتّى جبال المدينة حزنت.',
  ),

  'j_m2_067': ScrollEntry(
    eventId: 'j_m2_067',
    globalOrder: 67,
    lineEn: 'The wounded rose the next morning and lit fires so bright that an empire thought twice.',
    lineAr: 'نهض الجرحى في الصباح التالي وأوقدوا نيرانًا ساطعة جعلت إمبراطورية تفكّر مرّتين.',
  ),

  'j_m2_068': ScrollEntry(
    eventId: 'j_m2_068',
    globalOrder: 68,
    lineEn: 'A man prayed on the scaffold, and fear found no room beside his faith.',
    lineAr: 'صلّى رجلٌ على المنصّة، ولم يجد الخوف مكانًا بجانب إيمانه.',
  ),

  'j_m2_069': ScrollEntry(
    eventId: 'j_m2_069',
    globalOrder: 69,
    lineEn: 'Seventy hearts that carried the Quran were silenced, and the sky wept a month of prayer.',
    lineAr: 'سبعون قلبًا حملت القرآن أُسكتت، فبكت السماء شهرًا من الصلاة.',
  ),

  'j_m2_070': ScrollEntry(
    eventId: 'j_m2_070',
    globalOrder: 70,
    lineEn: 'They carried their doors on their backs, for the house of treachery has no roof to shelter it.',
    lineAr: 'حملوا أبوابهم على ظهورهم، فبيت الخيانة لا سقف يظلّه.',
  ),

  'j_m2_071': ScrollEntry(
    eventId: 'j_m2_071',
    globalOrder: 71,
    lineEn: 'They came for war and found an empty field, so they filled it with commerce and left richer in both gold and honor.',
    lineAr: 'جاؤوا للحرب فوجدوا ميدانًا فارغًا، فملأوه بالتجارة وعادوا أغنى ذهبًا وعزّة.',
  ),

  'j_m2_072': ScrollEntry(
    eventId: 'j_m2_072',
    globalOrder: 72,
    lineEn: 'A whisper of arrogance was written into eternity, and the one who spoke it became the lesson.',
    lineAr: 'هَمسةُ غرورٍ كُتبت في الخلود، وصاحبها صار هو العبرة.',
  ),

  'j_m2_073': ScrollEntry(
    eventId: 'j_m2_073',
    globalOrder: 73,
    lineEn: 'A lie traveled through a city for a month, then heaven spoke and silenced it forever.',
    lineAr: 'سافرت كذبةٌ في مدينة شهرًا كاملًا، ثمّ تكلّمت السماء فأسكتتها إلى الأبد.',
  ),

  'j_m2_074': ScrollEntry(
    eventId: 'j_m2_074',
    globalOrder: 74,
    lineEn: 'Three thousand hands dug a line in the earth, and an army of ten thousand could not cross it.',
    lineAr: 'حفرت ثلاثة آلاف يدٍ خطًّا في الأرض، فعجز عشرة آلاف عن عبوره.',
  ),

  'j_m2_075': ScrollEntry(
    eventId: 'j_m2_075',
    globalOrder: 75,
    lineEn: 'Ten thousand camped outside a ditch, and one man\'s whisper unraveled them all.',
    lineAr: 'عسكر عشرة آلاف خارج خندق، فحلّهم جميعًا همسة رجلٍ واحد.',
  ),

  'j_m2_076': ScrollEntry(
    eventId: 'j_m2_076',
    globalOrder: 76,
    lineEn: 'One man carried no sword, spoke no threat, and broke an army with three conversations.',
    lineAr: 'رجلٌ لم يحمل سيفًا ولم يُطلق تهديدًا، فكسر جيشًا بثلاث محادثات.',
  ),

  'j_m2_077': ScrollEntry(
    eventId: 'j_m2_077',
    globalOrder: 77,
    lineEn: 'One young man stepped into the dust where a thousand feared to tread, and the dust remembered his name.',
    lineAr: 'خطا شابٌّ في الغبار حيث خاف ألفٌ أن يخطوا، فحفظ الغبار اسمه.',
  ),

  'j_m2_078': ScrollEntry(
    eventId: 'j_m2_078',
    globalOrder: 78,
    lineEn: 'Heaven sent no army, only wind, and ten thousand vanished before the dawn prayer.',
    lineAr: 'لم ترسل السماء جيشًا بل ريحًا، فاختفى عشرة آلاف قبل صلاة الفجر.',
  ),

  'j_m2_079': ScrollEntry(
    eventId: 'j_m2_079',
    globalOrder: 79,
    lineEn: 'A treaty broken at the darkest hour carried a weight no fortress wall could bear.',
    lineAr: 'عهدٌ نُقض في أحلك ساعة حمل ثقلًا لا يتحمّله سور حصن.',
  ),

  'j_m2_080': ScrollEntry(
    eventId: 'j_m2_080',
    globalOrder: 80,
    lineEn: 'A wounded judge spoke once, and a nation learned that betrayal in the darkest hour carries the heaviest cost.',
    lineAr: 'تكلّم قاضٍ جريح مرّة واحدة، فتعلّمت أمّة أنّ الخيانة في أحلك ساعة تحمل أثقل الأثمان.',
  ),

  'j_m2_081': ScrollEntry(
    eventId: 'j_m2_081',
    globalOrder: 81,
    lineEn: 'The throne above the heavens shook for a man who gave six years and left an eternity.',
    lineAr: 'اهتزّ العرش فوق السموات لرجلٍ أعطى ستّ سنوات وترك خلوداً.',
  ),

  'j_m2_082': ScrollEntry(
    eventId: 'j_m2_082',
    globalOrder: 82,
    lineEn: 'Six years of faith moved the throne above the heavens, and time itself bowed to a life fully lived.',
    lineAr: 'ستّ سنوات من الإيمان حرّكت العرش فوق السموات، وانحنى الزمن لحياةٍ عُيشت بالكامل.',
  ),

  'j_m3_083': ScrollEntry(
    eventId: 'j_m3_083',
    globalOrder: 83,
    lineEn: 'The besieged became the marchers, and every tribe between two cities felt the shift.',
    lineAr: 'المحاصَرون أصبحوا المتقدّمين، وكلّ قبيلة بين المدينتين أحسّت بالتحوّل.',
  ),

  'j_m3_084': ScrollEntry(
    eventId: 'j_m3_084',
    globalOrder: 84,
    lineEn: 'Fourteen hundred wore white and carried no swords, and their peace was a weapon Quraysh could not answer.',
    lineAr: 'ارتدى ألفٌ وأربعمئة البياض ولم يحملوا سيوفًا، وكان سلامهم سلاحًا لم تستطع قريش ردّه.',
  ),

  'j_m3_085': ScrollEntry(
    eventId: 'j_m3_085',
    globalOrder: 85,
    lineEn: 'A camel knelt where heaven drew the line, and fourteen hundred waited for what only patience could win.',
    lineAr: 'بركت ناقة حيث رسمت السماء الخطّ، وانتظر ألفٌ وأربعمئة ما لا يُنال إلّا بالصبر.',
  ),

  'j_m3_086': ScrollEntry(
    eventId: 'j_m3_086',
    globalOrder: 86,
    lineEn: 'Under a tree at the edge of the sacred, hands met and heaven witnessed a pledge it would never forget.',
    lineAr: 'تحت شجرةٍ على حدود الحرم التقت الأيدي وشهدت السماء بيعةً لن تنساها.',
  ),

  'j_m3_087': ScrollEntry(
    eventId: 'j_m3_087',
    globalOrder: 87,
    lineEn: 'A treaty that tasted like defeat changed the map of Arabia, and those who wept at its signing soon understood.',
    lineAr: 'معاهدةٌ مذاقها الهزيمة غيّرت خريطة الجزيرة، والذين بكوا عند توقيعها فهموا قريبًا.',
  ),

  'j_m3_088': ScrollEntry(
    eventId: 'j_m3_088',
    globalOrder: 88,
    lineEn: 'What tasted like surrender, heaven called victory, and the years that followed proved heaven right.',
    lineAr: 'ما مذاقه الاستسلام سمّته السماء نصرًا، والسنوات التالية أثبتت أنّ السماء كانت محقّة.',
  ),

  'j_m3_089': ScrollEntry(
    eventId: 'j_m3_089',
    globalOrder: 89,
    lineEn: 'A letter sealed with silver crossed the desert, and the thrones of the world heard the name for the first time.',
    lineAr: 'رسالةٌ مختومة بالفضّة عبرت الصحراء، وسمعت عروش العالم الاسم لأوّل مرّة.',
  ),

  'j_m3_090': ScrollEntry(
    eventId: 'j_m3_090',
    globalOrder: 90,
    lineEn: 'One emperor considered the truth and survived. Another tore it, and the world tore his throne.',
    lineAr: 'إمبراطورٌ تأمّل الحقّ فبقي، وآخر مزّقه فمزّق العالم عرشه.',
  ),

  'j_m3_091': ScrollEntry(
    eventId: 'j_m3_091',
    globalOrder: 91,
    lineEn: 'A king across the sea believed in secret, and a prophet across the desert prayed for him in public.',
    lineAr: 'ملكٌ عبر البحر آمن سرًّا، ونبيٌّ عبر الصحراء صلّى عليه علنًا.',
  ),

  'j_m3_092': ScrollEntry(
    eventId: 'j_m3_092',
    globalOrder: 92,
    lineEn: 'A letter crossed the sea to Egypt and returned with gifts but not faith, and even that silence was an answer.',
    lineAr: 'عبرت رسالةٌ البحر إلى مصر وعادت بهدايا لا بإيمان، وحتّى ذلك الصمت كان جوابًا.',
  ),

  'j_m3_093': ScrollEntry(
    eventId: 'j_m3_093',
    globalOrder: 93,
    lineEn: 'The army came at dawn, and the fortresses that had never fallen watched their last sunrise as they knew it.',
    lineAr: 'جاء الجيش عند الفجر، والحصون التي لم تسقط قطّ شاهدت آخر شروقٍ كما عرفته.',
  ),

  'j_m3_094': ScrollEntry(
    eventId: 'j_m3_094',
    globalOrder: 94,
    lineEn: 'A banner waited for the morning, and the man it found had blind eyes that saw more than any sword.',
    lineAr: 'رايةٌ انتظرت الصباح، والرجل الذي وجدته كانت عيناه عمياوين ترى أبعد من أيّ سيف.',
  ),

  'j_m3_095': ScrollEntry(
    eventId: 'j_m3_095',
    globalOrder: 95,
    lineEn: 'A gate that no army could breach fell to a man whose eyes had been blind that morning, and the impossible obeyed faith.',
    lineAr: 'بابٌ لم يستطع جيشٌ اختراقه سقط على يد رجلٍ كانت عيناه عمياوين ذلك الصباح، والمستحيل أطاع الإيمان.',
  ),

  'j_m3_096': ScrollEntry(
    eventId: 'j_m3_096',
    globalOrder: 96,
    lineEn: 'A single bite at a table carried a shadow that reached across four years and dimmed the final light.',
    lineAr: 'لقمةٌ واحدة على مائدة حملت ظلًّا امتدّ أربع سنوات وأطفأ النور الأخير.',
  ),

  'j_m3_097': ScrollEntry(
    eventId: 'j_m3_097',
    globalOrder: 97,
    lineEn: 'After fourteen years, a cousin came home, and the prophet who conquered fortresses said this homecoming was just as sweet.',
    lineAr: 'بعد أربع عشرة سنة عاد ابن عمّ إلى الوطن، والنبيّ الذي فتح الحصون قال إنّ هذه العودة لا تقلّ حلاوة.',
  ),

  'j_m3_098': ScrollEntry(
    eventId: 'j_m3_098',
    globalOrder: 98,
    lineEn: 'Seven years of exile ended in three days of prayer, and the city that once expelled them watched them leave by choice.',
    lineAr: 'سبع سنوات من المنفى انتهت بثلاثة أيام من الصلاة، والمدينة التي طردتهم يومًا شاهدتهم يغادرون باختيارهم.',
  ),

  'j_m3_099': ScrollEntry(
    eventId: 'j_m3_099',
    globalOrder: 99,
    lineEn: 'The hand that turned the tide at Uhud reached out in Medina, and the Prophet \uFDFA called it the Sword of Allah.',
    lineAr: 'اليد التي غيّرت مجرى أُحد امتدّت في المدينة، فسمّاها النبيّ \uFDFA سيف الله.',
  ),

  'j_m3_100': ScrollEntry(
    eventId: 'j_m3_100',
    globalOrder: 100,
    lineEn: 'The sword, the brain, and the key of Quraysh walked into Medina on the same road, and the war ended before the last battle began.',
    lineAr: 'سيف قريش وعقلها ومفتاحها دخلوا المدينة من الطريق ذاته، وانتهت الحرب قبل أن تبدأ المعركة الأخيرة.',
  ),

  'j_m3_101': ScrollEntry(
    eventId: 'j_m3_101',
    globalOrder: 101,
    lineEn: 'Three thousand walked toward one hundred thousand, and faith measured itself not in numbers but in footsteps.',
    lineAr: 'مشى ثلاثة آلاف نحو مئة ألف، وقاس الإيمان نفسه لا بالأعداد بل بالخطوات.',
  ),

  'j_m3_102': ScrollEntry(
    eventId: 'j_m3_102',
    globalOrder: 102,
    lineEn: 'Three banners fell and three men rose, and the one who lost his arms was given wings.',
    lineAr: 'سقطت ثلاث رايات ونهض ثلاثة رجال، ومن فقد ذراعيه مُنح جناحين.',
  ),

  'j_m3_103': ScrollEntry(
    eventId: 'j_m3_103',
    globalOrder: 103,
    lineEn: 'A general who had been Muslim for weeks saved an army with nine broken swords and one unbreakable mind.',
    lineAr: 'قائدٌ لم يكن مسلمًا إلّا أسابيع أنقذ جيشًا بتسعة سيوفٍ مكسورة وعقلٍ لا يُكسر.',
  ),

  'j_m3_104': ScrollEntry(
    eventId: 'j_m3_104',
    globalOrder: 104,
    lineEn: 'The Prophet \uFDFA sent yesterday\'s enemy to command today\'s army, and trust proved sharper than any sword.',
    lineAr: 'أرسل النبيّ \uFDFA عدوّ الأمس ليقود جيش اليوم، وأثبتت الثقة أنّها أمضى من أيّ سيف.',
  ),

  'j_m3_105': ScrollEntry(
    eventId: 'j_m3_105',
    globalOrder: 105,
    lineEn: 'A treaty held by honor was broken by the very hands that signed it, and the road to Mecca opened itself.',
    lineAr: 'معاهدةٌ صانها الشرف نقضتها الأيدي ذاتها التي وقّعتها، وانفتح الطريق إلى مكة بنفسه.',
  ),

  'j_m3_106': ScrollEntry(
    eventId: 'j_m3_106',
    globalOrder: 106,
    lineEn: 'The man who sent armies now came alone, and every door in the city he once besieged closed quietly in his face.',
    lineAr: 'الرجل الذي أرسل جيوشًا جاء وحيدًا، وكلّ بابٍ في المدينة التي حاصرها يومًا أُغلق بهدوءٍ في وجهه.',
  ),

  'j_m3_107': ScrollEntry(
    eventId: 'j_m3_107',
    globalOrder: 107,
    lineEn: 'Ten thousand fires lit the valley, and Mecca saw the end of denial written in flame.',
    lineAr: 'عشرة آلاف نار أضاءت الوادي، ورأت مكة نهاية الإنكار مكتوبةً بالنار.',
  ),

  'j_m3_108': ScrollEntry(
    eventId: 'j_m3_108',
    globalOrder: 108,
    lineEn: 'The man who once counted Muslim heads at Badr now lost count, and understood.',
    lineAr: 'الرجل الذي عدّ رؤوس المسلمين في بدر يومًا فقد العدّ الآن وفهم.',
  ),

  'j_m3_109': ScrollEntry(
    eventId: 'j_m3_109',
    globalOrder: 109,
    lineEn: 'Twenty years of war ended with a whispered shahada in a tent, and three promises that emptied Mecca of fear.',
    lineAr: 'عشرون سنة من الحرب انتهت بشهادةٍ همست في خيمة، وثلاثة وعودٍ أفرغت مكة من الخوف.',
  ),

  'j_m3_110': ScrollEntry(
    eventId: 'j_m3_110',
    globalOrder: 110,
    lineEn: 'He left as a fugitive in the dark and returned as a servant in the light, his head bowed lower than any crown.',
    lineAr: 'غادر طريدًا في الظلام وعاد عبدًا في النور، رأسه أخفض من أيّ تاج.',
  ),

  'j_m3_111': ScrollEntry(
    eventId: 'j_m3_111',
    globalOrder: 111,
    lineEn: 'Three hundred and sixty idols fell, and the house that began with Ibrahim returned to its first word: One.',
    lineAr: 'سقط ثلاثمئة وستون صنمًا، وعاد البيت الذي بدأه إبراهيم إلى كلمته الأولى: واحد.',
  ),

  'j_m3_112': ScrollEntry(
    eventId: 'j_m3_112',
    globalOrder: 112,
    lineEn: 'In the hour of absolute power, he chose the words of a prophet who forgave his brothers, and a city exhaled.',
    lineAr: 'في ساعة السلطة المطلقة اختار كلمات نبيٍّ سامح إخوته، فتنفّست مدينة.',
  ),

  'j_m3_113': ScrollEntry(
    eventId: 'j_m3_113',
    globalOrder: 113,
    lineEn: 'The voice that once whispered "One" under a boulder now echoed "God is Greatest" from the roof of God\'s house.',
    lineAr: 'الصوت الذي همس يومًا "أحد" تحت صخرة يردّد الآن "الله أكبر" من سطح بيت الله.',
  ),

  'j_m3_114': ScrollEntry(
    eventId: 'j_m3_114',
    globalOrder: 114,
    lineEn: 'Twelve thousand marched into a valley trusting their numbers, and the valley taught them who truly decides.',
    lineAr: 'دخل اثنا عشر ألفًا واديًا يثقون بأعدادهم، فعلّمهم الوادي من يقرّر حقًّا.',
  ),

  'j_m3_115': ScrollEntry(
    eventId: 'j_m3_115',
    globalOrder: 115,
    lineEn: 'A voice cried out across the valley, and the men who had fled turned into the men who conquered.',
    lineAr: 'صرخ صوتٌ عبر الوادي، فتحوّل الذين فرّوا إلى الذين فتحوا.',
  ),

  'j_m3_116': ScrollEntry(
    eventId: 'j_m3_116',
    globalOrder: 116,
    lineEn: 'The city that stoned him once opened its gates to his prayer, not his sword.',
    lineAr: 'المدينة التي رجمته يومًا فتحت أبوابها لدعائه لا لسيفه.',
  ),

  'j_m3_117': ScrollEntry(
    eventId: 'j_m3_117',
    globalOrder: 117,
    lineEn: 'Others carried gold from the valley. The Ansar carried something the gold could never buy.',
    lineAr: 'حمل الآخرون ذهبًا من الوادي، وحمل الأنصار شيئًا لا يشتريه الذهب.',
  ),

  'j_m3_118': ScrollEntry(
    eventId: 'j_m3_118',
    globalOrder: 118,
    lineEn: 'He circled the house that Ibrahim built, and for the first time in memory, only One Name echoed inside its walls.',
    lineAr: 'طاف حول البيت الذي بناه إبراهيم، وللمرّة الأولى في الذاكرة لم يتردّد داخل جدرانه إلّا اسمٌ واحد.',
  ),

  'j_m3_119': ScrollEntry(
    eventId: 'j_m3_119',
    globalOrder: 119,
    lineEn: 'The city that threw stones learned to throw them only at idols, and the last fortress of the old world opened from within.',
    lineAr: 'المدينة التي رمت الحجارة تعلّمت أن ترميها على الأصنام فقط، وآخر حصون العالم القديم فُتح من الداخل.',
  ),

  'j_m3_120': ScrollEntry(
    eventId: 'j_m3_120',
    globalOrder: 120,
    lineEn: 'A peninsula that once worshipped three hundred and sixty names learned there was only One, and the teacher who taught them began to look toward the sky.',
    lineAr: 'جزيرةٌ عبدت يومًا ثلاثمئة وستين اسمًا تعلّمت أنّه لا يوجد إلّا واحد، والمعلّم الذي علّمها بدأ ينظر نحو السماء.',
  ),

  'j_m4_121': ScrollEntry(
    eventId: 'j_m4_121',
    globalOrder: 121,
    lineEn: 'The harvest was ripe and the desert was on fire, but thirty thousand walked toward the horizon anyway.',
    lineAr: 'كان الحصاد ناضجًا والصحراء مشتعلة، لكنّ ثلاثين ألفًا ساروا نحو الأفق رغم ذلك.',
  ),

  'j_m4_122': ScrollEntry(
    eventId: 'j_m4_122',
    globalOrder: 122,
    lineEn: 'Excuses are the language of the soul retreating from its own truth.',
    lineAr: 'الأعذار لغة النفس حين تتراجع عن حقيقتها.',
  ),

  'j_m4_123': ScrollEntry(
    eventId: 'j_m4_123',
    globalOrder: 123,
    lineEn: 'A man sat in perfect shade, then stood and walked into the sun because his heart could not rest where his body was comfortable.',
    lineAr: 'جلس رجلٌ في ظلٍّ مثالي، ثمّ قام ومشى في الشمس لأنّ قلبه لم يستطع الراحة حيث جسده مرتاح.',
  ),

  'j_m4_124': ScrollEntry(
    eventId: 'j_m4_124',
    globalOrder: 124,
    lineEn: 'They marched seven hundred kilometers to fight an empire, and the empire chose not to come.',
    lineAr: 'ساروا سبعمئة كيلومتر لمحاربة إمبراطورية، فاختارت الإمبراطورية ألّا تأتي.',
  ),

  'j_m4_125': ScrollEntry(
    eventId: 'j_m4_125',
    globalOrder: 125,
    lineEn: 'A building that wore the name of worship carried the heart of conspiracy, and truth reduced it to ash.',
    lineAr: 'مبنىً ارتدى اسم العبادة حمل قلب المؤامرة، فحوّله الحقّ إلى رماد.',
  ),

  'j_m4_126': ScrollEntry(
    eventId: 'j_m4_126',
    globalOrder: 126,
    lineEn: 'For fifty days the earth narrowed around three honest men, then heaven widened and they breathed again.',
    lineAr: 'خمسون يومًا ضاقت الأرض على ثلاثة صادقين، ثمّ اتّسعت السماء وتنفّسوا من جديد.',
  ),

  'j_m4_127': ScrollEntry(
    eventId: 'j_m4_127',
    globalOrder: 127,
    lineEn: 'The truth cost them fifty days, but the lie would have cost them eternity.',
    lineAr: 'كلّفهم الصدق خمسين يومًا، لكنّ الكذب كان ليكلّفهم الأبدية.',
  ),

  'j_m4_128': ScrollEntry(
    eventId: 'j_m4_128',
    globalOrder: 128,
    lineEn: 'He gave his shirt to the man who spent a lifetime opposing him, and mercy had the final word.',
    lineAr: 'أعطى قميصه لمن قضى عمره يعارضه، فكانت الرحمة الكلمة الأخيرة.',
  ),

  'j_m4_129': ScrollEntry(
    eventId: 'j_m4_129',
    globalOrder: 129,
    lineEn: 'An entire peninsula walked through one door, and the man who opened it greeted each one by name.',
    lineAr: 'جزيرةٌ بأكملها عبرت بابًا واحدًا، والرجل الذي فتحه حيّا كلّ واحدٍ باسمه.',
  ),

  'j_m4_130': ScrollEntry(
    eventId: 'j_m4_130',
    globalOrder: 130,
    lineEn: 'Rough voices at a door taught an entire civilization that faith begins with how you knock.',
    lineAr: 'أصواتٌ خشنة عند بابٍ علّمت حضارةً بأكملها أنّ الإيمان يبدأ بطريقة الطَّرق.',
  ),

  'j_m4_131': ScrollEntry(
    eventId: 'j_m4_131',
    globalOrder: 131,
    lineEn: 'The idol that generations feared turned to dust under one blow, and the women who screamed learned there was nothing to fear.',
    lineAr: 'الصنم الذي هابته أجيال تحوّل ترابًا بضربة واحدة، والنساء اللواتي صرخن عرفن أنّه لا شيء يُخاف.',
  ),

  'j_m4_132': ScrollEntry(
    eventId: 'j_m4_132',
    globalOrder: 132,
    lineEn: 'Two faiths sat in one mosque, and when words reached their limit, one side brought family and the other brought wisdom.',
    lineAr: 'جلس إيمانان في مسجدٍ واحد، وحين بلغت الكلمات حدّها جلب طرفٌ عائلته وجلب الآخر حكمته.',
  ),

  'j_m4_133': ScrollEntry(
    eventId: 'j_m4_133',
    globalOrder: 133,
    lineEn: 'The first Hajj under Islam was led not by the Prophet but by his dearest friend, clearing the path for a farewell yet to come.',
    lineAr: 'أوّل حجّة في الإسلام قادها لا النبيّ بل أحبّ صديق إليه، ممهّدًا الطريق لوداعٍ لم يأتِ بعد.',
  ),

  'j_m4_134': ScrollEntry(
    eventId: 'j_m4_134',
    globalOrder: 134,
    lineEn: 'A voice at Mina read the last chapter of an old agreement, and the house of Ibrahim heard only One Name again.',
    lineAr: 'صوتٌ في مِنى قرأ الفصل الأخير من عهدٍ قديم، ولم يسمع بيت إبراهيم إلّا اسمًا واحدًا مجدّدًا.',
  ),

  'j_m4_135': ScrollEntry(
    eventId: 'j_m4_135',
    globalOrder: 135,
    lineEn: 'It began with one word in a cave and ended with an entire peninsula answering that word with their lives.',
    lineAr: 'بدأ بكلمةٍ واحدة في غار وانتهى بجزيرة بأكملها تجيب تلك الكلمة بحياتها.',
  ),

  'j_m4_136': ScrollEntry(
    eventId: 'j_m4_136',
    globalOrder: 136,
    lineEn: 'A hundred thousand answered one man\'s call to walk the path Ibrahim walked, and none of them knew it was goodbye.',
    lineAr: 'لبّى مئة ألف نداء رجلٍ واحد ليسلكوا طريق إبراهيم، ولم يعلم أحدٌ منهم أنّه الوداع.',
  ),

  'j_m4_137': ScrollEntry(
    eventId: 'j_m4_137',
    globalOrder: 137,
    lineEn: 'A hundred thousand walked in white toward one house, and the desert had never carried a louder silence.',
    lineAr: 'مئة ألف ساروا بالأبيض نحو بيتٍ واحد، ولم تحمل الصحراء صمتًا أعلى من ذلك.',
  ),

  'j_m4_138': ScrollEntry(
    eventId: 'j_m4_138',
    globalOrder: 138,
    lineEn: 'He entered the city of his birth one final time, circled the house his father Ibrahim built, and turned his face toward the plain where everything would end and begin.',
    lineAr: 'دخل مدينة مولده للمرّة الأخيرة، وطاف حول البيت الذي بناه أبوه إبراهيم، ووجّه وجهه نحو السهل حيث سينتهي كلّ شيء ويبدأ.',
  ),

  'j_m4_139': ScrollEntry(
    eventId: 'j_m4_139',
    globalOrder: 139,
    lineEn: 'On a plain that held no shade, a hundred thousand raised their hands and one man wept for them all.',
    lineAr: 'على سهلٍ لا ظلّ فيه رفع مئة ألف أيديهم وبكى رجلٌ واحد من أجلهم جميعًا.',
  ),

  'j_m4_140': ScrollEntry(
    eventId: 'j_m4_140',
    globalOrder: 140,
    lineEn: 'He asked a hundred thousand, "Have I conveyed?" and when they answered, he lifted his finger to heaven and made Allah the witness.',
    lineAr: 'سأل مئة ألف: "هل بلّغت؟" فلمّا أجابوا رفع إصبعه نحو السماء وأشهد الله.',
  ),

  'j_m4_141': ScrollEntry(
    eventId: 'j_m4_141',
    globalOrder: 141,
    lineEn: 'The religion that began with one word in a cave was declared complete on a plain, and the man who carried it understood his work was done.',
    lineAr: 'الدين الذي بدأ بكلمة واحدة في غار أُعلن كاملًا على سهل، والرجل الذي حمله فهم أنّ عمله انتهى.',
  ),

  'j_m4_142': ScrollEntry(
    eventId: 'j_m4_142',
    globalOrder: 142,
    lineEn: 'At a crossroads in the desert, a hand was raised, a name was spoken, and the Muslim world still hears the echo.',
    lineAr: 'عند مفترق طرقٍ في الصحراء رُفعت يد ونُطق اسم والعالم الإسلامي لا يزال يسمع الصدى.',
  ),

  'j_m4_143': ScrollEntry(
    eventId: 'j_m4_143',
    globalOrder: 143,
    lineEn: 'He walked through the graves at night, greeted the dead as neighbors, and quietly chose to join them.',
    lineAr: 'مشى بين القبور ليلًا وحيّا الموتى كجيران واختار بهدوءٍ أن ينضمّ إليهم.',
  ),

  'j_m4_144': ScrollEntry(
    eventId: 'j_m4_144',
    globalOrder: 144,
    lineEn: 'His last military order was to hand the flag to a young man the world underestimated, proving one final time that Islam sees what others refuse to see.',
    lineAr: 'آخر أمر عسكري له كان تسليم الراية لشابّ استخفّ به العالم، مثبتًا للمرّة الأخيرة أنّ الإسلام يرى ما يرفض الآخرون رؤيته.',
  ),

  'j_m4_145': ScrollEntry(
    eventId: 'j_m4_145',
    globalOrder: 145,
    lineEn: 'The strongest man they had ever known lay burning with fever, and all of Medina held its breath.',
    lineAr: 'أقوى رجلٍ عرفوه يرقد محمومًا، والمدينة كلّها تحبس أنفاسها.',
  ),

  'j_m4_146': ScrollEntry(
    eventId: 'j_m4_146',
    globalOrder: 146,
    lineEn: 'He stood among the graves of men who died for him and told them he was coming.',
    lineAr: 'وقف بين قبور رجالٍ ماتوا من أجله وأخبرهم أنّه قادم.',
  ),

  'j_m4_147': ScrollEntry(
    eventId: 'j_m4_147',
    globalOrder: 147,
    lineEn: 'Another man stood where the Prophet once stood, and the mosque learned it could hold faith without holding the one who planted it.',
    lineAr: 'وقف رجلٌ آخر حيث وقف النبيّ يومًا، وتعلّم المسجد أنّه يستطيع حمل الإيمان دون حمل من غرسه.',
  ),

  'j_m4_148': ScrollEntry(
    eventId: 'j_m4_148',
    globalOrder: 148,
    lineEn: 'He smiled at his ummah one final time through a curtain, then turned his face toward heaven and whispered the name of where he was going.',
    lineAr: 'ابتسم لأمّته للمرّة الأخيرة من وراء ستار، ثمّ حوّل وجهه نحو السماء وهمس اسم المكان الذي يذهب إليه.',
  ),

  'j_m4_149': ScrollEntry(
    eventId: 'j_m4_149',
    globalOrder: 149,
    lineEn: 'He gave away his last coins, then gave away his life, and met his Lord as he came into this world: owning nothing.',
    lineAr: 'تصدّق بآخر قروشه ثمّ بذل حياته ولقي ربّه كما دخل هذا العالم: لا يملك شيئًا.',
  ),

  'j_m4_150': ScrollEntry(
    eventId: 'j_m4_150',
    globalOrder: 150,
    lineEn: 'He chose the highest companions, and the earth lost the one man who made heaven feel close.',
    lineAr: 'اختار الرفيق الأعلى، وفقدت الأرض الرجل الوحيد الذي جعل السماء تبدو قريبة.',
  ),

  'j_m4_151': ScrollEntry(
    eventId: 'j_m4_151',
    globalOrder: 151,
    lineEn: 'The strongest man in Medina drew his sword against death itself, refusing to let go of the one man who had made him strong.',
    lineAr: 'أقوى رجل في المدينة استلّ سيفه ضدّ الموت ذاته، رافضًا التخلّي عن الرجل الذي جعله قويًّا.',
  ),

  'j_m4_152': ScrollEntry(
    eventId: 'j_m4_152',
    globalOrder: 152,
    lineEn: 'One verse, one voice, and a community that was falling remembered how to stand.',
    lineAr: 'آية واحدة وصوت واحد ومجتمعٌ كان ينهار تذكّر كيف يقف.',
  ),

  'j_m4_153': ScrollEntry(
    eventId: 'j_m4_153',
    globalOrder: 153,
    lineEn: 'They came one by one to say goodbye, and each one prayed alone, because no one could stand where he once stood and lead.',
    lineAr: 'جاؤوا فرادى ليودّعوا، وكلّ واحد صلّى وحده، لأنّ لا أحد يستطيع الوقوف حيث وقف يومًا ويؤمّ.',
  ),

  'j_m4_154': ScrollEntry(
    eventId: 'j_m4_154',
    globalOrder: 154,
    lineEn: 'They returned him to the earth in the room where he had prayed, and the ground that held him became the most loved ground on earth.',
    lineAr: 'أعادوه إلى الأرض في الغرفة التي صلّى فيها، وأصبحت الأرض التي احتضنته أحبّ أرضٍ على وجه الأرض.',
  ),

  'j_m4_155': ScrollEntry(
    eventId: 'j_m4_155',
    globalOrder: 155,
    lineEn: 'The scroll is full. The quill rests. But the ink of this story will never dry, because you are still writing it — with your life.',
    lineAr: 'المخطوطة ممتلئة. القلم يرتاح. لكنّ حبر هذه القصة لن يجفّ، لأنّك لا تزال تكتبها — بحياتك.',
  ),

};
