import '../models/branch_point.dart';
import '../models/journey_event.dart';

// ── M1: The Prophetic Journey ──────────────────────────────────────────────
// 36 events across 4 chapters. All content sourced from the Quran,
// Sahih Bukhari, Sahih Muslim, and authenticated scholarly works.
//
// COMPANION MODE — Second-person voice. The user witnesses history.
// CONVERGENT BRANCHING — Action/focus choices, all lead to same truth.

// ignore_for_file: non_constant_identifier_names

final List<JourneyEvent> m1Events = [

  // ══════════════════════════════════════════════════════════════════════════
  // CHAPTER 1 — JAHILIYYAH (Pre-Islamic Arabia) — 3 events
  // ══════════════════════════════════════════════════════════════════════════

  JourneyEvent(
    id: 'j_1_1_1',
    era: JourneyEra.jahiliyyah,
    globalOrder: 1,
    latitude: 21.4225, longitude: 39.8262,
    year: 500,
    title: 'Arabia Before the Light',
    titleAr: 'الجزيرة العربية قبل النور',
    location: 'Arabian Peninsula',
    locationAr: 'الجزيرة العربية',
    narrative:
        'You stand at the edge of the Ka\'bah courtyard as the sun sets over Mecca. The air is thick with incense smoke drifting from the idol shrines that crowd around the ancient house. Three hundred and sixty stone figures watch you with empty eyes.\n\n'
        'Around you, the world moves in contradictions. A poet recites verses of breathtaking beauty about honor and courage — while a few streets away, a man buries his newborn daughter in the sand without a word. Merchants haggle over silk and spices on trade routes that stretch from Yemen to Syria — while the poor beg at the Ka\'bah walls, invisible to those who pass.\n\n'
        'And yet — the Ka\'bah stands. Built by Ibrahim ﷺ and his son Ismail ﷺ as a house of the One God. That memory lingers in the stones, even as idols press against them from every side. Something is coming. You can feel it in the desert wind.',
    narrativeAr:
        'تقف على حافة فناء الكعبة والشمس تغرب فوق مكة. الهواء ثقيل بدخان البخور المتصاعد من معابد الأصنام المتراصة حول البيت العتيق. ثلاثمئة وستون تمثالاً حجرياً يحدّقون فيك بعيون فارغة.\n\n'
        'من حولك، العالم يتحرك في تناقضات. شاعر ينشد أبياتاً خلابة عن الشرف والشجاعة — بينما على بعد أزقة قليلة، رجل يدفن ابنته الوليدة في الرمال دون كلمة. تجّار يساومون على الحرير والتوابل في طرق تجارية تمتد من اليمن إلى الشام — بينما الفقراء يستجدون عند جدران الكعبة، لا يراهم أحد.\n\n'
        'ومع ذلك — الكعبة تقف. بناها إبراهيم ﷺ وابنه إسماعيل ﷺ بيتاً للإله الواحد. تلك الذكرى لا تزال حيّة في الحجارة، حتى وإن تزاحمت الأصنام حولها من كل جانب. شيء ما قادم. تحسّه في ريح الصحراء.',
    source: 'Quran 3:154 — "أَمْرُ اللَّهِ كَانَ قَدَرًا مَّقْدُورًا"',
    xpReward: 20,
    anchorHotspotId: 'kaabah',
    convergenceHotspotId: 'poet',
    branchPoint: BranchPoint(
      id: 'bp_1_1_1',
      prompt:
          'The Ka\'bah stands behind you — ancient, patient, waiting. The courtyard stretches in every direction. Two sounds compete for your attention.\n\n'
          'To your right, raised voices from the merchant quarter — a foreign trader shouts that he has been cheated, but no one stops to listen. Gold changes hands while the poor press against the walls like shadows.\n\n'
          'To your left, incense smoke rises thick from the idol shrines. Low chanting drifts through the air. Three hundred and sixty stone figures crowd the sacred precinct, each one placed by a tribe that has forgotten what this house was built for.\n\n'
          'Where do you go first?',
      promptAr:
          'الكعبة خلفك — عتيقة، صابرة، منتظرة. الفناء يمتد في كل اتجاه. صوتان يتنافسان على انتباهك.\n\n'
          'إلى يمينك، أصوات مرتفعة من حي التجار — تاجر غريب يصرخ أنه خُدع، لكن لا أحد يتوقف ليستمع. الذهب يتبادل الأيدي بينما الفقراء يلتصقون بالجدران كالظلال.\n\n'
          'إلى يسارك، دخان البخور يتصاعد كثيفاً من معابد الأصنام. ترتيل خافت يسري في الهواء. ثلاثمئة وستون تمثالاً حجرياً يتزاحمون في الحرم، كل واحد وضعته قبيلة نسيت لماذا بُني هذا البيت.\n\n'
          'إلى أين تذهب أولاً؟',
      optionA: BranchOption(
        label: 'Follow the voices to the merchant quarter',
        labelAr: 'اتبع الأصوات نحو حي التجار',
        targetHotspotId: 'merchants',
      ),
      optionB: BranchOption(
        label: 'Walk toward the smoke and the idol shrines',
        labelAr: 'امشِ نحو الدخان ومعابد الأصنام',
        targetHotspotId: 'idols',
      ),
    ),
    questions: [
      JourneyQuestion(
        id: 'q_1_1_1_a',
        question: 'You stand in the courtyard of the Ka\'bah. The idols crowd the ancient walls. Where does your gaze settle?',
        questionAr: 'تقف في فناء الكعبة. الأصنام تتزاحم حول الجدران العتيقة. أين يستقر نظرك؟',
        options: [
          'On the Ka\'bah itself — the house Ibrahim built, still standing beneath the idols',
          'On the poet reciting verses of honor while injustice fills the streets',
          'On the poor man begging at the walls, unseen by the merchants passing by',
        ],
        optionsAr: [
          'على الكعبة ذاتها — البيت الذي بناه إبراهيم، لا يزال قائماً تحت الأصنام',
          'على الشاعر الذي ينشد أبيات الشرف بينما الظلم يملأ الأزقة',
          'على الفقير الذي يستجدي عند الجدران، لا يراه التجار المارّون',
        ],
        correctIndex: 0,
        explanation: 'History records: The Ka\'bah stood — built by Ibrahim ﷺ — a monument to the One God, now surrounded by 360 idols. The truth was always present, buried under layers of custom and self-interest. It waited for the one who would restore it.',
        explanationAr: 'يسجّل التاريخ: ظلت الكعبة قائمة — بناها إبراهيم ﷺ — شاهداً على الإله الواحد، وقد أحاطت بها 360 صنماً. كان الحق حاضراً دائماً، مدفوناً تحت طبقات العادات والمصالح. كان ينتظر من يعيده.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_1_2',
    era: JourneyEra.jahiliyyah,
    globalOrder: 2,
    latitude: 21.4225, longitude: 39.8262,
    year: 570,
    title: 'The Year of the Elephant',
    titleAr: 'عام الفيل',
    location: 'Mecca',
    locationAr: 'مكة المكرمة',
    narrative:
        'The ground shakes beneath your feet. You are on the outskirts of Mecca, and the horizon to the south is dark with dust. Abraha al-Ashram — the ruler of Yemen — is marching on the city with an army unlike anything Arabia has seen. War elephants. Thousands of soldiers. His mission: destroy the Ka\'bah and redirect the Arabs\' pilgrimage to a grand church he built in San\'a.\n\n'
        'The Quraysh are fleeing. Abd al-Muttalib, the custodian of the Ka\'bah, has told the people to withdraw to the mountains. He stood before Abraha and asked only for his camels — not for the Ka\'bah. When Abraha mocked him, he replied: "I am the lord of the camels. The Ka\'bah has a Lord who will protect it."\n\n'
        'The army advances. The elephants halt at the boundary of the sacred precinct and refuse to move forward. Then the sky darkens — not with clouds, but with birds. Thousands of them, carrying stones of baked clay. You watch the impossible unfold before your eyes.',
    narrativeAr:
        'الأرض تهتز تحت قدميك. أنت على أطراف مكة، والأفق جنوباً مظلم بالغبار. أبرهة الأشرم — حاكم اليمن — يزحف على المدينة بجيش لم تشهد الجزيرة العربية مثله. أفيال حرب. آلاف الجنود. مهمته: تدمير الكعبة وتحويل حج العرب إلى كنيسة فخمة بناها في صنعاء.\n\n'
        'قريش تفرّ. عبد المطلب، سادن الكعبة، أمر الناس بالانسحاب إلى الجبال. وقف أمام أبرهة ولم يطلب إلا إبله — لا الكعبة. وحين سخر منه أبرهة، أجاب: "أنا ربّ الإبل. وللبيت ربّ يحميه."\n\n'
        'الجيش يتقدم. الأفيال تتوقف عند حدود الحرم وترفض التحرك. ثم تُظلم السماء — لا بالغيوم، بل بالطيور. آلاف منها، تحمل حجارة من سجيل. تشاهد المستحيل يتكشّف أمام عينيك.',
    source: 'Quran Surah Al-Fil (105): "أَلَمْ تَرَ كَيْفَ فَعَلَ رَبُّكَ بِأَصْحَابِ الْفِيلِ"',
    xpReward: 30,
    anchorHotspotId: 'army',
    convergenceHotspotId: 'birds',
    branchPoint: BranchPoint(
      id: 'bp_1_1_2',
      prompt:
          'The dust cloud on the horizon grows darker. Abraha\'s army is advancing — war elephants, thousands of soldiers, a force Arabia has never seen. The people of Mecca are scattering.\n\n'
          'Ahead of you, the great elephants have reached the boundary of the sacred precinct. Something is happening — the lead elephant has stopped. Its riders strike it, but it will not move forward.\n\n'
          'Behind you, toward the mountains, Abd al-Muttalib stands at the edge of the city. He has told the people to withdraw. He has spoken words you cannot forget: "The Ka\'bah has a Lord who will protect it."\n\n'
          'Where do you go?',
      promptAr:
          'سحابة الغبار في الأفق تزداد عتمة. جيش أبرهة يتقدم — أفيال حرب، آلاف الجنود، قوة لم تشهدها الجزيرة من قبل. أهل مكة يتفرقون.\n\n'
          'أمامك، الأفيال العظيمة وصلت حدود الحرم. شيء يحدث — الفيل الأول توقف. فرسانه يضربونه، لكنه يرفض التقدم.\n\n'
          'خلفك، نحو الجبال، عبد المطلب يقف عند حافة المدينة. أمر الناس بالانسحاب. نطق بكلمات لا تنساها: "للبيت ربّ يحميه."\n\n'
          'إلى أين تذهب؟',
      optionA: BranchOption(
        label: 'Move closer to the elephants — you must see this',
        labelAr: 'اقترب من الأفيال — يجب أن ترى هذا',
        targetHotspotId: 'elephants',
      ),
      optionB: BranchOption(
        label: 'Follow Abd al-Muttalib to the mountains',
        labelAr: 'اتبع عبد المطلب إلى الجبال',
        targetHotspotId: 'muttalib',
      ),
    ),
    questions: [
      JourneyQuestion(
        id: 'q_1_1_2_a',
        question: 'The earth shakes. Abraha\'s army approaches Mecca with war elephants. The Quraysh are fleeing to the mountains. What do you do?',
        questionAr: 'الأرض تهتز. جيش أبرهة يقترب من مكة بأفيال الحرب. قريش تفرّ إلى الجبال. ماذا تفعل؟',
        options: [
          'Stand your ground near the Ka\'bah — you cannot abandon the sacred house',
          'Flee to the mountains with the Quraysh — Abd al-Muttalib said the Ka\'bah has its own Lord',
          'Run toward the army to see the elephants with your own eyes',
        ],
        optionsAr: [
          'تثبت قرب الكعبة — لا يمكنك التخلي عن البيت المقدس',
          'تفرّ إلى الجبال مع قريش — عبد المطلب قال إن للكعبة رباً يحميها',
          'تركض نحو الجيش لترى الأفيال بأم عينك',
        ],
        correctIndex: 1,
        explanation: 'History records: The Quraysh fled to the mountains. No human army stopped Abraha. Allah sent flocks of birds carrying stones of baked clay, and the army was destroyed like consumed straw. The Ka\'bah was preserved by its Lord — not by human hands. In this very year, the final Prophet ﷺ was born.',
        explanationAr: 'يسجّل التاريخ: فرّت قريش إلى الجبال. لم يوقف أبرهة جيش بشري. أرسل الله طيراً أبابيل ترميهم بحجارة من سجيل، فجعلهم كعصف مأكول. حُفظت الكعبة بربّها — لا بأيدي البشر. وفي هذا العام ذاته، وُلد النبي الخاتم ﷺ.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_2_1',
    era: JourneyEra.earlyLife,
    globalOrder: 3,
    latitude: 21.4225, longitude: 39.8262,
    year: 570,
    title: 'The Birth of the Prophet ﷺ',
    titleAr: 'مولد النبي ﷺ',
    location: 'Mecca',
    locationAr: 'مكة المكرمة',
    narrative:
        'It is the month of Rabi\' al-Awwal, in the Year of the Elephant. You are in the narrow streets of the Banu Hashim quarter of Mecca. The night is quiet — the city still talks of the army that was destroyed, of the birds, of the stones. And now, in a modest home, a child is born.\n\n'
        'His father, Abdullah, did not live to see this moment — he died before the boy drew his first breath. His mother, Aminah bint Wahb, holds him close. His grandfather Abd al-Muttalib — one of the most powerful men in Mecca — takes the infant to the Ka\'bah and names him Muhammad. "The Praised One." It is a name the Arabs have never used before.\n\n'
        'Within days, the child is given to a wet-nurse from the tribe of Banu Sa\'d. Halima al-Sa\'diyya carries him into the open desert — into clean air, wide skies, and the pure Arabic of the Bedouin. An orphan from his first breath. A prophet before the world knew it.',
    narrativeAr:
        'إنه شهر ربيع الأول، في عام الفيل. أنت في أزقة حي بني هاشم الضيقة في مكة. الليل هادئ — المدينة لا تزال تتحدث عن الجيش الذي دُمّر، عن الطيور، عن الحجارة. والآن، في بيت متواضع، يُولد طفل.\n\n'
        'أبوه عبد الله لم يعش ليرى هذه اللحظة — مات قبل أن يأخذ الطفل نفَسه الأول. أمه آمنة بنت وهب تضمّه إليها. جدّه عبد المطلب — أحد أقوى رجال مكة — يحمل الرضيع إلى الكعبة ويسميه محمداً. "المحمود." اسم لم يستخدمه العرب من قبل.\n\n'
        'في غضون أيام، يُسلَّم الطفل إلى مرضعة من قبيلة بني سعد. حليمة السعدية تحمله إلى الصحراء المفتوحة — إلى هواء نقي وسماوات واسعة وعربية البدو الصافية. يتيم منذ أول نفَس. نبيّ قبل أن يعرف العالم.',
    source: 'Sahih Bukhari 3551 — lineage and birth of the Prophet ﷺ',
    xpReward: 30,
    questions: [
      JourneyQuestion(
        id: 'q_1_2_1_a',
        question: 'A child has been born in Banu Hashim tonight. His father did not live to see him. Where does your gaze settle?',
        questionAr: 'وُلد طفل في بني هاشم الليلة. أبوه لم يعش ليراه. أين يستقر نظرك؟',
        options: [
          'On the newborn in his mother\'s arms — fragile, fatherless, and utterly still',
          'On his grandfather Abd al-Muttalib, carrying him to the Ka\'bah to name him',
          'On the stars above Mecca — the same sky that sent the birds against Abraha',
        ],
        optionsAr: [
          'على المولود بين ذراعي أمه — ضعيف، يتيم، ساكن تماماً',
          'على جدّه عبد المطلب، يحمله إلى الكعبة ليسمّيه',
          'على نجوم مكة — السماء ذاتها التي أرسلت الطير على أبرهة',
        ],
        correctIndex: 1,
        explanation: 'History records: Abd al-Muttalib named him Muhammad — "the Praised One" — a name never before used among the Arabs. He carried him to the Ka\'bah and gave thanks. The most important birth in human history arrived quietly, in an orphan\'s first breath.',
        explanationAr: 'يسجّل التاريخ: سمّاه عبد المطلب محمداً — "المحمود" — اسم لم يُستخدم من قبل بين العرب. حمله إلى الكعبة وشكر الله. أهم ولادة في تاريخ البشرية جاءت بهدوء، في أول نفَس يتيم.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_2_2',
    era: JourneyEra.earlyLife,
    globalOrder: 4,
    latitude: 21.4225, longitude: 39.8262,
    year: 575,
    title: 'Under the Care of Abd al-Muttalib',
    titleAr: 'في كنف عبد المطلب',
    location: 'Mecca',
    locationAr: 'مكة المكرمة',
    narrative:
        'You see the boy at the Ka\'bah courtyard. He is six years old — and he has just lost his mother. Aminah died on the road back from Medina, at a place called Al-Abwa\'. He watched her fall ill. He watched her stop breathing. And now he sits beside his grandfather on the mat that no other child is allowed to touch.\n\n'
        'Abd al-Muttalib keeps the boy closer than his own sons. When the elders of Quraysh gather at the Ka\'bah, Muhammad ﷺ sits at his grandfather\'s side — a privilege no one questions. The old man\'s hand rests on the boy\'s shoulder. There is something in this child that everyone senses but no one can name.\n\n'
        'Two years pass. You see the old man growing weaker. Before he dies, he calls his son Abu Talib to his side and entrusts Muhammad ﷺ to him. The boy has lost his father before birth, his mother at six, and now his grandfather at eight. Every earthly protection is being stripped away — one by one.',
    narrativeAr:
        'ترى الصبي في فناء الكعبة. عمره ست سنوات — وقد فقد أمه للتوّ. آمنة ماتت في طريق العودة من المدينة، في مكان يُسمى الأبواء. شاهدها تمرض. شاهدها تتوقف عن التنفس. والآن يجلس بجانب جدّه على البساط الذي لا يُسمح لطفل آخر بلمسه.\n\n'
        'عبد المطلب يبقي الصبي أقرب إليه من أبنائه. حين يجتمع شيوخ قريش عند الكعبة، يجلس محمد ﷺ إلى جانب جدّه — امتياز لا يعترض عليه أحد. يد الشيخ تستقر على كتف الصبي. شيء في هذا الطفل يحسّه الجميع لكن لا أحد يستطيع تسميته.\n\n'
        'يمرّ عامان. ترى الشيخ يضعف. قبل أن يموت، يستدعي ابنه أبا طالب ويأتمنه على محمد ﷺ. الصبي فقد أباه قبل الولادة، وأمه في السادسة، وجدّه الآن في الثامنة. كل حماية أرضية تُنتزع — واحدة تلو الأخرى.',
    source: 'Sahih Muslim 2353 — account of the Prophet\'s ﷺ early guardianship',
    xpReward: 25,
    questions: [
      JourneyQuestion(
        id: 'q_1_2_2_a',
        question: 'Muhammad ﷺ has lost his mother. He sits beside his grandfather at the Ka\'bah — the one seat no other child may touch. Where does your gaze settle?',
        questionAr: 'فقد محمد ﷺ أمه. يجلس بجانب جدّه عند الكعبة — المقعد الذي لا يلمسه طفل سواه. أين يستقر نظرك؟',
        options: [
          'On the boy\'s face — quiet, watchful, carrying something you cannot name',
          'On the elders who glance at him with curiosity — sensing what they cannot explain',
          'On Abd al-Muttalib\'s hand resting on the boy\'s shoulder — a protection that will not last',
        ],
        optionsAr: [
          'على وجه الصبي — هادئ، يقظ، يحمل شيئاً لا تستطيع تسميته',
          'على الشيوخ الذين يلمحونه بفضول — يحسّون بما لا يستطيعون تفسيره',
          'على يد عبد المطلب المستقرة على كتف الصبي — حماية لن تدوم',
        ],
        correctIndex: 2,
        explanation: 'History records: Abd al-Muttalib gave the boy an honor given to no other child — a seat beside him at the Ka\'bah. Two years later, he too would die. But before leaving, he entrusted Muhammad ﷺ to his son Abu Talib. Every earthly protection was being removed — so that the boy would learn to rely only on Allah.',
        explanationAr: 'يسجّل التاريخ: منح عبد المطلب الصبي شرفاً لم يمنحه لطفل سواه — مقعداً بجانبه عند الكعبة. بعد عامين، سيموت هو أيضاً. لكنه قبل رحيله أوصى بمحمد ﷺ إلى ابنه أبي طالب. كل حماية أرضية كانت تُنزع — ليتعلم الصبي الاعتماد على الله وحده.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_2_3',
    era: JourneyEra.earlyLife,
    globalOrder: 5,
    latitude: 21.4225, longitude: 39.8262,
    year: 578,
    title: 'The Guardian: Abu Talib',
    titleAr: 'الكافل: أبو طالب',
    location: 'Mecca',
    locationAr: 'مكة المكرمة',
    narrative:
        'You walk alongside the trade caravan heading north toward Syria. The sun is fierce, the camels are heavy-laden, and Abu Talib — not a wealthy man, but a man of honor — leads the way. Beside him, a boy of twelve: Muhammad ﷺ, eyes wide, taking in lands he has never seen.\n\n'
        'Abu Talib did not have to take this orphan. He has children of his own and barely enough to feed them. But he welcomed Muhammad ﷺ as a son — a place at his table, a place in his home, a place in his heart. And now he brings the boy on this journey because he cannot bear to leave him behind.\n\n'
        'You watch Abu Talib throughout the journey — the way he positions himself between the boy and the sun, the way he checks on him at every rest stop, the way he watches over him in his sleep. This is not duty. This is love. A love that will one day shield a prophet from the most powerful forces in Arabia.',
    narrativeAr:
        'تمشي بجانب القافلة التجارية المتجهة شمالاً نحو الشام. الشمس حارقة، والجمال مُثقلة، وأبو طالب — ليس رجلاً ثرياً، لكنه رجل شرف — يقود الطريق. إلى جانبه، صبي في الثانية عشرة: محمد ﷺ، عيناه واسعتان، يتأمل أراضي لم يرها من قبل.\n\n'
        'لم يكن على أبي طالب أن يأخذ هذا اليتيم. لديه أبناؤه ويكاد لا يجد ما يكفيهم. لكنه رحّب بمحمد ﷺ كابن — مكان على مائدته، مكان في بيته، مكان في قلبه. والآن يصطحب الصبي في هذه الرحلة لأنه لا يطيق أن يتركه.\n\n'
        'تراقب أبا طالب طوال الرحلة — كيف يضع نفسه بين الصبي والشمس، كيف يطمئن عليه في كل استراحة، كيف يحرسه في نومه. هذا ليس واجباً. هذه محبة. محبة ستحمي يوماً نبيّاً من أقوى القوى في جزيرة العرب.',
    source: 'Sahih Bukhari 3884 — the Prophet ﷺ on Abu Talib\'s guardianship',
    xpReward: 25,
    questions: [
      JourneyQuestion(
        id: 'q_1_2_3_a',
        question: 'Abu Talib leads the caravan to Syria. The young Muhammad ﷺ walks beside him. You travel with them. What do you observe most closely?',
        questionAr: 'أبو طالب يقود القافلة إلى الشام. محمد ﷺ الصغير يمشي بجانبه. ترافقهم في الطريق. ما الذي تراقبه عن كثب؟',
        options: [
          'The boy\'s eager eyes — seeing new lands for the first time',
          'Abu Talib — who never lets the boy out of his sight, not once',
          'The merchants on the road who already seem to respect the boy\'s presence',
        ],
        optionsAr: [
          'عينا الصبي المتلهفتين — يرى أراضي جديدة للمرة الأولى',
          'أبو طالب — الذي لا يترك الصبي يغيب عن نظره لحظة واحدة',
          'التجار على الطريق الذين يبدو أنهم يحترمون حضور الصبي',
        ],
        correctIndex: 1,
        explanation: 'History records: Abu Talib raised him as his own son and protected him for decades — even after Islam came and the most powerful men in Mecca demanded Muhammad ﷺ be surrendered. Though Abu Talib never embraced Islam himself, his love was a mercy from Allah that allowed the Prophet ﷺ to continue his mission.',
        explanationAr: 'يسجّل التاريخ: ربّاه أبو طالب كابنه وحماه لعقود — حتى بعد مجيء الإسلام ومطالبة أقوى رجال مكة بتسليم محمد ﷺ. وإن لم يعتنق أبو طالب الإسلام بنفسه، فإن محبته كانت رحمة من الله أتاحت للنبي ﷺ مواصلة رسالته.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_2_4',
    era: JourneyEra.earlyLife,
    globalOrder: 6,
    latitude: 21.4225, longitude: 39.8262,
    year: 590,
    title: 'Hilf al-Fudul — The Pact of the Virtuous',
    titleAr: 'حلف الفضول',
    location: 'Mecca',
    locationAr: 'مكة المكرمة',
    narrative:
        'You are near the Ka\'bah when you hear it — a Yemeni merchant standing in the open, his voice cracking with frustration. He came to Mecca, sold his goods to a man of Quraysh, and was never paid. He has no tribe here. No protection. No one to fight for him. So he does the only thing he can: he stands in the most public place in Mecca and calls out to anyone who still believes in honor.\n\n'
        'Something shifts. You watch as the noblest clans of Mecca stir — not all of them, but enough. They gather in the house of Abdullah ibn Jud\'an and swear a covenant: from this day forward, they will stand together against any injustice in Mecca. No victim — whether local or foreigner — will be denied their rights while they draw breath.\n\n'
        'Among those present is a young man named Muhammad ﷺ. He says nothing during the gathering. But decades later — as a Prophet — he will say of this night: "I was present at a pact so excellent that I would not exchange my part in it for a herd of red camels; and if I were called to it in Islam, I would respond."',
    narrativeAr:
        'أنت قرب الكعبة حين تسمعه — تاجر يمني يقف في العراء، صوته يتكسّر من الإحباط. جاء مكة وباع بضاعته لرجل من قريش ولم يُدفع حقه. ليس له هنا قبيلة. لا حماية. لا أحد يقاتل عنه. فيفعل الشيء الوحيد الذي يستطيعه: يقف في أكثر أماكن مكة علنية ويصرخ مناشداً كل من يؤمن بالشرف.\n\n'
        'شيء يتحرك. تشاهد أشرف أحياء مكة تنتفض — ليس كلهم، لكن ما يكفي. يجتمعون في دار عبد الله بن جدعان ويقسمون عهداً: من هذا اليوم، سيقفون معاً ضد أي ظلم في مكة. لن يُحرم مظلوم — سواء أكان محلياً أم غريباً — من حقه ما داموا أحياء.\n\n'
        'بين الحاضرين شاب اسمه محمد ﷺ. لا يتكلم خلال الاجتماع. لكن بعد عقود — وهو نبيّ — سيقول عن هذه الليلة: "شهدت في دار ابن جدعان حلفاً ما أُحب أن لي به حُمر النعم، ولو دُعيت إليه في الإسلام لأجبت."',
    source: 'Seerah Ibn Hisham — Hilf al-Fudul; referenced by Prophet ﷺ in Sahih narrations',
    xpReward: 30,
    questions: [
      JourneyQuestion(
        id: 'q_1_2_4_a',
        question: 'A Yemeni merchant stands at the Ka\'bah, cheated and unheard. The tribes gather. You are there. What do you do?',
        questionAr: 'تاجر يمني يقف عند الكعبة، مغبون ومهمَل. القبائل تتجمع. أنت هناك. ماذا تفعل؟',
        options: [
          'Stay silent — this is between the merchant and the Quraysh, it is not your concern',
          'Stand beside the merchant and add your voice to his call',
          'Watch to see how the nobles of Mecca respond — this will reveal what kind of people they are',
        ],
        optionsAr: [
          'تلزم الصمت — هذا بين التاجر وقريش، ليس شأنك',
          'تقف بجانب التاجر وتضم صوتك إلى ندائه',
          'تراقب كيف يستجيب أشراف مكة — هذا سيكشف أي نوع من الناس هم',
        ],
        correctIndex: 2,
        explanation: 'History records: The noblest clans gathered and swore a covenant to defend any victim of injustice in Mecca. Muhammad ﷺ was present — and would later say he would honor this pact even in Islam. Allah had planted justice in His final Prophet ﷺ from youth — values that would define the civilization of Islam itself.',
        explanationAr: 'يسجّل التاريخ: اجتمع أشرف الأحياء وأقسموا عهداً بالدفاع عن كل مظلوم في مكة. كان محمد ﷺ حاضراً — وسيقول لاحقاً إنه سيفي بهذا الحلف حتى في الإسلام. زرع الله العدل في نبيّه الخاتم ﷺ منذ الصغر — قيم ستحدد حضارة الإسلام ذاتها.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_2_5',
    era: JourneyEra.earlyLife,
    globalOrder: 7,
    latitude: 21.4225, longitude: 39.8262,
    year: 595,
    title: 'Marriage to Khadijah RA',
    titleAr: 'الزواج من خديجة رضي الله عنها',
    location: 'Mecca',
    locationAr: 'مكة المكرمة',
    narrative:
        'You see Muhammad ﷺ returning from Syria at the head of Khadijah\'s trade caravan. He is twenty-five years old. The journey was successful — more successful than any caravan she has sent before. Her servant Maysara walks beside him, and you can hear Maysara talking — not about the profits, but about the man. His honesty. His kindness. The way people were drawn to him at every stop.\n\n'
        'Khadijah bint Khuwaylid is one of the most respected women in Mecca — a successful merchant of noble lineage, widowed twice, approximately forty years old. She has heard everything Maysara has to say. And she has made her decision.\n\n'
        'She proposes marriage. In the culture of that time, for a woman of her standing to propose — extraordinary. Muhammad ﷺ accepts. You witness the beginning of the greatest partnership in human history. She will be his wife, his first believer, his anchor, the mother of his children, and his closest companion for twenty-five years. When the weight of revelation comes — and it will shake him to the core — she will be the first to steady him.',
    narrativeAr:
        'ترى محمداً ﷺ عائداً من الشام على رأس قافلة خديجة التجارية. عمره خمسة وعشرون عاماً. الرحلة كانت ناجحة — أنجح من أي قافلة أرسلتها من قبل. خادمها ميسرة يمشي بجانبه، وتسمع ميسرة يتحدث — لا عن الأرباح، بل عن الرجل. أمانته. لطفه. الطريقة التي انجذب إليه بها الناس في كل محطة.\n\n'
        'خديجة بنت خويلد من أكثر نساء مكة احتراماً — تاجرة ناجحة ذات حسب ونسب، أُرملت مرتين، في نحو الأربعين من عمرها. سمعت كل ما قاله ميسرة. واتخذت قرارها.\n\n'
        'تعرض الزواج. في ثقافة ذلك الزمان، أن تعرض امرأة في مكانتها الزواج — أمر استثنائي. محمد ﷺ يقبل. تشهد بداية أعظم شراكة في تاريخ البشرية. ستكون زوجته وأول من يؤمن به وسنده وأم أبنائه وأقرب مؤنسيه لخمسة وعشرين عاماً. وحين يأتي ثقل الوحي — وسيهزّه حتى الأعماق — ستكون أول من يثبّته.',
    source: 'Sahih Bukhari 3820 — on Khadijah RA and her merits',
    xpReward: 35,
    questions: [
      JourneyQuestion(
        id: 'q_1_2_5_a',
        question: 'Muhammad ﷺ returns from the Syria trade. Maysara cannot stop describing what he witnessed. Khadijah listens. Where does your gaze settle?',
        questionAr: 'يعود محمد ﷺ من تجارة الشام. ميسرة لا يتوقف عن وصف ما شاهده. خديجة تصغي. أين يستقر نظرك؟',
        options: [
          'On the caravan\'s goods — the wealth he has earned is unprecedented',
          'On Muhammad\'s ﷺ face — something has shifted in how he carries himself',
          'On Khadijah — whose expression says she has already made her decision',
        ],
        optionsAr: [
          'على بضائع القافلة — الثروة التي جلبها لم يُسبق إليها',
          'على وجه محمد ﷺ — شيء ما تغيّر في طريقة حضوره',
          'على خديجة — التي يقول تعبير وجهها إنها اتخذت قرارها بالفعل',
        ],
        correctIndex: 2,
        explanation: 'History records: Khadijah proposed marriage to Muhammad ﷺ. At twenty-five and forty, they became husband and wife — the partnership that would anchor the most important mission in history. She would be the first to believe, the first to comfort, and the last person he would forget.',
        explanationAr: 'يسجّل التاريخ: خديجة هي من عرضت الزواج على محمد ﷺ. في الخامسة والعشرين والأربعين، صارا زوجين — الشراكة التي ستُرسي أهم رسالة في التاريخ. ستكون أول من يؤمن، وأول من يواسي، وآخر من يُنسى.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_1_3',
    era: JourneyEra.earlyLife,
    globalOrder: 8,
    latitude: 21.4225, longitude: 39.8262,
    year: 605,
    title: 'The Black Stone — A Wise Arbitration',
    titleAr: 'الحجر الأسود — حكم الأمين',
    location: 'Mecca',
    locationAr: 'مكة المكرمة',
    narrative:
        'You are inside the sanctuary. The Ka\'bah has been damaged by flood, and the tribes of Mecca have spent weeks rebuilding it. The walls are nearly complete. But now — a crisis. The Black Stone must be placed back in its corner, and every tribe demands the honor. Hands are reaching for weapons. You hear men swearing oaths. Blood is about to be spilled in the sacred precinct.\n\n'
        'A respected elder proposes a way out: let the first man to enter the sanctuary at dawn decide. The crowd agrees — anything to avoid war in this place. You wait through the night.\n\n'
        'At dawn, a figure enters. It is Muhammad ﷺ — a young man, perhaps thirty-five, known to every tribe but belonging to no faction. The crowd relaxes. "Al-Amin," they murmur. The Trustworthy. He listens to the dispute quietly. Then he removes his cloak, places the Black Stone on it, and asks the leader of every tribe to lift a corner of the cloak together.',
    narrativeAr:
        'أنت داخل الحرم. الكعبة تضررت من السيل، وقبائل مكة أمضت أسابيع تعيد بناءها. الجدران شبه مكتملة. لكن الآن — أزمة. الحجر الأسود يجب أن يعود إلى ركنه، وكل قبيلة تطالب بالشرف. أيدٍ تمتد نحو الأسلحة. تسمع رجالاً يقسمون. الدم على وشك أن يُسفك في البقعة المقدسة.\n\n'
        'يقترح شيخ مُوقّر مخرجاً: ليكن أول من يدخل الحرم عند الفجر هو الحَكَم. يوافق الجمع — أيّ شيء لتجنب الحرب في هذا المكان. تنتظر طوال الليل.\n\n'
        'عند الفجر، يدخل شخص. إنه محمد ﷺ — شاب في نحو الخامسة والثلاثين، تعرفه كل القبائل لكنه لا ينتمي لأي فريق. يرتاح الجمع. "الأمين"، يهمسون. يستمع إلى النزاع بهدوء. ثم يخلع رداءه، ويضع الحجر الأسود عليه، ويطلب من زعيم كل قبيلة أن يرفع طرفاً من الرداء معاً.',
    source: 'Seerah Ibn Hisham — authenticated account of the Black Stone arbitration',
    xpReward: 30,
    anchorHotspotId: 'flood',
    convergenceHotspotId: 'cloak',
    branchPoint: BranchPoint(
      id: 'bp_1_1_3',
      prompt:
          'The walls are nearly complete. But a crisis has erupted — the Black Stone must return to its sacred corner, and every tribe demands the honor. You hear the clash of voices rising near the Ka\'bah. Hands are gripping sword hilts.\n\n'
          'At the same time, an elder has proposed a way out: let the first man to enter the sanctuary at dawn decide. The crowd has reluctantly agreed. Dawn is approaching.\n\n'
          'Where do you go?',
      promptAr:
          'الجدران شبه مكتملة. لكن أزمة اندلعت — الحجر الأسود يجب أن يعود إلى ركنه المقدس، وكل قبيلة تطالب بالشرف. تسمع تصادم الأصوات يتصاعد قرب الكعبة. أيدٍ تقبض على مقابض السيوف.\n\n'
          'وفي الوقت ذاته، اقترح شيخ مخرجاً: ليكن أول من يدخل الحرم عند الفجر هو الحَكَم. وافق الجمع على مضض. الفجر يقترب.\n\n'
          'إلى أين تذهب؟',
      optionA: BranchOption(
        label: 'Stay near the dispute — you need to see how close this comes to bloodshed',
        labelAr: 'ابقَ قرب النزاع — تحتاج أن ترى كم اقتربوا من سفك الدماء',
        targetHotspotId: 'dispute',
      ),
      optionB: BranchOption(
        label: 'Move toward the sanctuary gate — you want to see who enters at dawn',
        labelAr: 'تحرّك نحو باب الحرم — تريد أن ترى من يدخل عند الفجر',
        targetHotspotId: 'alamin',
      ),
    ),
    questions: [
      JourneyQuestion(
        id: 'q_1_1_3_a',
        question: 'The tribes stand armed, each demanding the honor of placing the Black Stone. Swords are almost drawn. Where does your gaze settle?',
        questionAr: 'القبائل تقف مسلّحة، كلٌّ يطالب بشرف وضع الحجر الأسود. السيوف على وشك أن تُسلّ. أين يستقر نظرك؟',
        options: [
          'On the tribesmen reaching for their weapons — blood is about to be spilled',
          'On Muhammad ﷺ — who listens quietly, belonging to no faction',
          'On the Black Stone itself — waiting to be placed by the right hands',
        ],
        optionsAr: [
          'على القبائل التي تمدّ أيديها نحو أسلحتها — الدم على وشك أن يُسفك',
          'على محمد ﷺ — الذي يستمع بهدوء، لا ينتمي لأي فريق',
          'على الحجر الأسود ذاته — ينتظر أن توضعه الأيدي الصحيحة',
        ],
        correctIndex: 1,
        explanation: 'History records: Al-Amin listened, then laid his cloak on the ground. He placed the Stone on it and asked every tribe to lift a corner together. Every tribe shared the honor. No blood was shed. The people had already given him the name "The Trustworthy" — long before prophethood. Allah was preparing His Prophet ﷺ.',
        explanationAr: 'يسجّل التاريخ: استمع الأمين، ثم بسط رداءه على الأرض. وضع الحجر عليه وطلب من كل قبيلة أن ترفع طرفاً معاً. نال الجميع نصيبهم من الشرف. لم تُراق قطرة دم. كان الناس قد أسموه "الأمين" — قبل النبوة بسنين. كان الله يهيّئ نبيّه ﷺ.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_2_6',
    era: JourneyEra.earlyLife,
    globalOrder: 9,
    latitude: 21.4225, longitude: 39.8262,
    year: 605,
    title: 'Solitude in Cave Hira',
    titleAr: 'الخلوة في غار حراء',
    location: 'Cave Hira, Mecca',
    locationAr: 'غار حراء، مكة المكرمة',
    narrative:
        'You follow the path up Jabal al-Nour — the Mountain of Light — just outside Mecca. The climb is steep, the rocks sharp. Muhammad ﷺ has gone up again. He has been coming here for months now — sometimes for days at a time. A small cave near the summit, barely large enough to lie down in. From its mouth, you can see the Ka\'bah far below.\n\n'
        'You wait at the base of the mountain. Khadijah\'s servant passes you on the path, carrying food and water upward. She supports these retreats without question. She understands that something is being prepared in her husband — something even he cannot name yet.\n\n'
        'The Arabs call it "al-tahannuth" — a withdrawal from the world to seek the truth. Muhammad ﷺ is approaching forty. The idols of Mecca have never satisfied him. The cruelty has never felt normal to him. He sits in that small cave, looking out at the stars, and waits for something he can feel but not yet see. He does not know that the most significant night in human history is drawing near.',
    narrativeAr:
        'تتبع الممر صعوداً على جبل النور — خارج مكة. الصعود حاد والصخور حادة. محمد ﷺ صعد مجدداً. يأتي هنا منذ أشهر — أحياناً لأيام كاملة. كهف صغير قرب القمة، بالكاد يتسع للاضطجاع. من فتحته، ترى الكعبة بعيداً في الأسفل.\n\n'
        'تنتظر عند سفح الجبل. خادم خديجة يمر بك على الممر، يحمل طعاماً وماءً إلى الأعلى. هي تؤيد هذه الخلوات دون سؤال. تدرك أن شيئاً يُعدّ في زوجها — شيئاً حتى هو لا يستطيع تسميته بعد.\n\n'
        'يسمّيه العرب "التحنث" — انسحاب من العالم للبحث عن الحق. محمد ﷺ يقترب من الأربعين. أصنام مكة لم ترضِه يوماً. القسوة لم تكن طبيعية في نظره. يجلس في ذلك الكهف الصغير، يتأمل النجوم، وينتظر شيئاً يحسّه لكنه لا يراه بعد. لا يعلم أن أهم ليلة في تاريخ البشرية تقترب.',
    source: 'Sahih Bukhari 3 — opening of Kitab Bada\' al-Wahy',
    xpReward: 30,
    questions: [
      JourneyQuestion(
        id: 'q_1_2_6_a',
        question: 'You follow the path up Jabal al-Nour. Muhammad ﷺ has gone to Cave Hira again. You wait below. Where does your gaze settle?',
        questionAr: 'تتبع الممر صعوداً على جبل النور. محمد ﷺ صعد إلى غار حراء مجدداً. تنتظر في الأسفل. أين يستقر نظرك؟',
        options: [
          'On the mountain above — the cave opening is barely visible, a thin shadow near the summit',
          'On Mecca below — the noise and the idols seem distant and small from here',
          'On the provisions being carried up — someone who loves him keeps him sustained in his search',
        ],
        optionsAr: [
          'على الجبل أعلاه — فتحة الكهف بالكاد تُرى، ظل رفيع قرب القمة',
          'على مكة أسفلك — الضجيج والأصنام تبدو بعيدة وصغيرة من هنا',
          'على الزاد المحمول إلى الأعلى — شخص يحبه يسنده في بحثه',
        ],
        correctIndex: 0,
        explanation: 'History records: For months, sometimes days and nights at a time, he returned to that cave. Something was being prepared in the silence. The word "tahannuth" — withdrawal to seek truth — described what the Arabs could see. What they could not see was that the last night of solitude would be the most significant night in human history.',
        explanationAr: 'يسجّل التاريخ: لأشهر، أحياناً أياماً ولياليَ كاملة، كان يعود إلى ذلك الكهف. شيء كان يُعدّ في الصمت. كلمة "التحنث" وصفت ما كان العرب يرونه. ما لم يكونوا يرونه هو أن آخر ليلة خلوة ستكون أهم ليلة في تاريخ البشرية.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_2_7',
    era: JourneyEra.earlyLife,
    globalOrder: 10,
    latitude: 21.4578, longitude: 39.8579,
    year: 610,
    title: 'The First Revelation',
    titleAr: 'نزول الوحي الأول',
    location: 'Cave Hira, Mecca',
    locationAr: 'غار حراء، مكة المكرمة',
    narrative:
        'It is the month of Ramadan. You are at the foot of Jabal al-Nour in the dead of night. The mountain is silent. Muhammad ﷺ is alone in Cave Hira, as he has been for days.\n\n'
        'Then something changes. You cannot see it from below, but you feel it — the air itself seems to shift. Inside the cave, the Angel Jibreel has come. He seizes Muhammad ﷺ with a force that is overwhelming, presses him until he can barely breathe, and commands: "Iqra\'" — Read. Muhammad ﷺ replies: "I cannot read." Three times this happens. Then the words come: "Read, in the name of your Lord who created — created man from a clinging substance. Read, and your Lord is the Most Generous, who taught by the pen, taught man what he did not know."\n\n'
        'Muhammad ﷺ descends the mountain. You see him — trembling, his face white, his hands shaking. He goes straight to Khadijah. "Cover me, cover me," he says. She wraps him in a cloak. When his fear passes, he tells her everything. Her response is immediate: "Never. By Allah, He will never humiliate you. You maintain the ties of kinship, you bear the burden of others, you earn what the destitute have lost, you welcome guests, and you support those in need." The first believer has already believed.',
    narrativeAr:
        'إنه شهر رمضان. أنت عند سفح جبل النور في جوف الليل. الجبل صامت. محمد ﷺ وحيد في غار حراء، كما كان منذ أيام.\n\n'
        'ثم يتغيّر شيء. لا تراه من الأسفل، لكنك تحسّه — الهواء ذاته يبدو مختلفاً. داخل الكهف، جاء جبريل عليه السلام. يضمّ محمداً ﷺ بقوة ساحقة، يضغط عليه حتى يكاد لا يتنفس، ويأمر: "اقرأ." يجيب محمد ﷺ: "ما أنا بقارئ." يتكرر ثلاث مرات. ثم تنزل الكلمات: "اقْرَأْ بِاسْمِ رَبِّكَ الَّذِي خَلَقَ، خَلَقَ الْإِنسَانَ مِنْ عَلَقٍ، اقْرَأْ وَرَبُّكَ الْأَكْرَمُ، الَّذِي عَلَّمَ بِالْقَلَمِ، عَلَّمَ الْإِنسَانَ مَا لَمْ يَعْلَمْ."\n\n'
        'محمد ﷺ ينزل الجبل. تراه — يرتجف، وجهه شاحب، يداه ترتعشان. يذهب مباشرة إلى خديجة. "زمّلوني، زمّلوني"، يقول. تلفّه بثوب. حين يهدأ خوفه، يخبرها بكل شيء. ردّها فوري: "كلا، والله لن يُخزيك الله أبداً. إنك لتصل الرحم، وتحمل الكَلّ، وتكسب المعدوم، وتقري الضيف، وتُعين على نوائب الحق." أول مؤمنة آمنت بالفعل.',
    source: 'Sahih Bukhari 3 — Bab Kayfa Kana Bada\' al-Wahy; Quran 96:1-5',
    xpReward: 50,
    questions: [
      JourneyQuestion(
        id: 'q_1_2_7_a',
        question: 'Muhammad ﷺ has descended the mountain trembling. He is in his home. Khadijah wraps him in a cloak. He says: "I feared for myself." What do you do?',
        questionAr: 'نزل محمد ﷺ من الجبل يرتجف. هو في بيته. خديجة تلفّه بثوب. يقول: "خشيت على نفسي." ماذا تفعل؟',
        options: [
          'Lean closer — you need to hear every word of what happened in that cave',
          'Watch Khadijah — her face shows no doubt, not for a single moment',
          'Step outside — this moment belongs to them alone',
        ],
        optionsAr: [
          'تقترب أكثر — تحتاج أن تسمع كل كلمة مما حدث في ذلك الكهف',
          'تراقب خديجة — وجهها لا يُظهر أي شك، ولو للحظة واحدة',
          'تخرج — هذه اللحظة لهما وحدهما',
        ],
        correctIndex: 1,
        explanation: 'History records: Khadijah held him, steadied him, and spoke without a moment of hesitation: "Never. By Allah, He will never humiliate you." She then took him to her wise cousin Waraqah, who confirmed: this was the same angel sent to Musa. The first believer did not need proof. She knew the man.',
        explanationAr: 'يسجّل التاريخ: خديجة ضمّته وثبّتته وتكلّمت دون لحظة تردد: "كلا، والله لن يُخزيك الله أبداً." ثم أخذته إلى ابن عمها الحكيم ورقة، الذي أكّد: هذا هو الناموس الذي أُنزل على موسى. أول مؤمنة لم تحتج إلى برهان. كانت تعرف الرجل.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_2_8',
    era: JourneyEra.earlyLife,
    globalOrder: 11,
    latitude: 21.4225, longitude: 39.8262,
    year: 610,
    title: 'The First Believers',
    titleAr: 'أوائل المؤمنين',
    location: 'Mecca',
    locationAr: 'مكة المكرمة',
    narrative:
        'Islam is still a secret. You sit in a small room where a handful of people have gathered — quietly, behind closed doors. No announcement. No public declaration. Just a circle of those who know Muhammad ﷺ best.\n\n'
        'Khadijah is here — his wife, the first adult woman to believe. Ali ibn Abi Talib — his young cousin, barely a child, raised in his household, is here too. Zayd ibn Harithah — his freed servant who chose to stay with him over returning to his own family. And Abu Bakr al-Siddiq — his closest friend, the first free adult man to believe. Each came to faith not from proof they demanded, but from knowing the man.\n\n'
        'You watch Abu Bakr. He is not sitting still. Within days of his own belief, he is already moving — approaching Uthman ibn Affan, Zubayr ibn al-Awwam, Abd al-Rahman ibn Awf, Sa\'d ibn Abi Waqqas, Talha ibn Ubaydullah. One by one. Quietly. The tree of Islam is putting down its first roots. You can feel the roots spreading beneath the soil of Mecca.',
    narrativeAr:
        'الإسلام لا يزال سراً. تجلس في غرفة صغيرة حيث تجمّع حفنة من الناس — بهدوء، خلف أبواب مغلقة. لا إعلان. لا تصريح علني. مجرد حلقة ممن يعرفون محمداً ﷺ أكثر من غيرهم.\n\n'
        'خديجة هنا — زوجته، أول امرأة بالغة تؤمن. علي بن أبي طالب — ابن عمه الصغير، بالكاد طفل، رُبّي في بيته، هنا أيضاً. زيد بن حارثة — خادمه المحرَّر الذي آثر البقاء معه على العودة لأهله. وأبو بكر الصديق — صديقه المقرّب، أول رجل حر بالغ يؤمن. آمن كلٌّ منهم لا من برهان طلبوه، بل من معرفتهم بالرجل.\n\n'
        'تراقب أبا بكر. لا يجلس ساكناً. في غضون أيام من إيمانه هو نفسه، يتحرك بالفعل — يقترب من عثمان بن عفان، والزبير بن العوام، وعبد الرحمن بن عوف، وسعد بن أبي وقاص، وطلحة بن عبيد الله. واحداً تلو الآخر. بهدوء. شجرة الإسلام ترسي جذورها الأولى. تحسّ الجذور تمتد تحت تربة مكة.',
    source: 'Sahih Bukhari 3857 — first believers; Ibn Kathir, Al-Bidaya wal-Nihaya',
    xpReward: 35,
    questions: [
      JourneyQuestion(
        id: 'q_1_2_8_a',
        question: 'Islam is still a secret. A small circle gathers behind closed doors. Where does your gaze settle?',
        questionAr: 'الإسلام لا يزال سراً. حلقة صغيرة تجتمع خلف أبواب مغلقة. أين يستقر نظرك؟',
        options: [
          'On Khadijah — the first and firmest, who believed before anyone else',
          'On the young Ali — barely a child, already committed without question',
          'On Abu Bakr — who is already moving to bring others before the sun sets',
        ],
        optionsAr: [
          'على خديجة — الأولى والأثبت، التي آمنت قبل أي أحد',
          'على عليّ الصغير — بالكاد طفل، ملتزم بالفعل دون سؤال',
          'على أبي بكر — الذي يتحرك بالفعل ليأتي بآخرين قبل أن تغرب الشمس',
        ],
        correctIndex: 2,
        explanation: 'History records: Within days of his own belief, Abu Bakr RA had brought five future leaders of Islam — Uthman, Zubayr, Abd al-Rahman, Sa\'d, and Talha. A flame had been lit in a small room in Mecca. The circle was already growing. No sword. No army. Just a man telling his closest friends the truth.',
        explanationAr: 'يسجّل التاريخ: في غضون أيام من إيمانه، كان أبو بكر رضي الله عنه قد أتى بخمسة من قادة الإسلام المستقبليين — عثمان والزبير وعبد الرحمن وسعد وطلحة. شعلة أُضيئت في غرفة صغيرة في مكة. الحلقة كانت تتسع بالفعل. لا سيف. لا جيش. مجرد رجل يخبر أقرب أصدقائه الحقيقة.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_3_1',
    era: JourneyEra.mecca,
    globalOrder: 12,
    latitude: 21.4225, longitude: 39.8262,
    year: 613,
    title: 'The Call Goes Public',
    titleAr: 'الدعوة تجهر',
    location: 'Mount Safa, Mecca',
    locationAr: 'جبل الصفا، مكة المكرمة',
    narrative:
        'Three years of secrecy are over. You are standing in the crowd at the base of Mount Safa when Muhammad ﷺ climbs to its peak. He calls out to the clans of Quraysh — one by one, by name. The people gather, curious. He is known. He is trusted. This is the man they call Al-Amin.\n\n'
        'He asks them a question: "If I told you that an army was behind this mountain, about to attack you — would you believe me?" The answer comes from every direction: "Yes. We have never known you to lie." His voice steadies. "Then I am a warner to you of a severe punishment."\n\n'
        'Silence. Then a voice cuts through it — Abu Lahab, his own uncle: "May you perish! Is this why you called us together?" The crowd murmurs. Some look troubled. Some look angry. Some look away. The secret is over. Islam is now public. And the reaction of the powerful is about to begin.',
    narrativeAr:
        'ثلاث سنوات من السرّية انتهت. أنت واقف في الحشد عند سفح جبل الصفا حين يصعد محمد ﷺ إلى قمته. ينادي قبائل قريش — واحدة تلو الأخرى، بأسمائها. الناس يتجمعون، فضوليون. يعرفونه. يثقون فيه. هذا هو الرجل الذي يسمّونه الأمين.\n\n'
        'يسألهم سؤالاً: "لو أخبرتكم أن خيلاً بسفح هذا الجبل تريد أن تُغير عليكم — أكنتم مصدّقيّ؟" الجواب يأتي من كل اتجاه: "نعم. ما جرّبنا عليك كذباً." يثبت صوته. "فإني نذير لكم بين يدي عذاب شديد."\n\n'
        'صمت. ثم صوت يخترقه — أبو لهب، عمّه: "تبّاً لك! ألهذا جمعتنا؟" الحشد يهمهم. بعضهم يبدو مضطرباً. بعضهم غاضباً. بعضهم يُشيح بنظره. السرّ انتهى. الإسلام أصبح علنياً. ورد الأقوياء على وشك أن يبدأ.',
    source: 'Sahih Bukhari 4770 — Tafsir Surah Al-Shu\'ara; Quran 26:214',
    xpReward: 30,
    questions: [
      JourneyQuestion(
        id: 'q_1_3_1_a',
        question: 'Muhammad ﷺ stands on Mount Safa. The clans of Quraysh have gathered below. He delivers his warning. Where does your gaze settle?',
        questionAr: 'محمد ﷺ يقف على جبل الصفا. قبائل قريش تجمّعت أسفله. يُلقي إنذاره. أين يستقر نظرك؟',
        options: [
          'On the Prophet ﷺ above — his voice steady, his eyes certain, standing alone',
          'On Abu Lahab — whose face twists with fury before anyone else speaks',
          'On the tribesmen who look at each other, unsure what they just heard',
        ],
        optionsAr: [
          'على النبي ﷺ أعلاه — صوته ثابت، عيناه واثقتان، يقف وحيداً',
          'على أبي لهب — الذي يتشوّه وجهه بالغضب قبل أن يتكلم أي أحد',
          'على رجال القبائل الذين ينظرون إلى بعضهم، غير متأكدين مما سمعوا',
        ],
        correctIndex: 0,
        explanation: 'History records: He asked them if they trusted him. They said yes. Then he told them the truth. Abu Lahab cursed him. The crowd scattered. But the words had been spoken from the peak of Safa — and nothing in Mecca would ever be the same.',
        explanationAr: 'يسجّل التاريخ: سألهم إن كانوا يصدّقونه. قالوا نعم. فأخبرهم الحقيقة. لعنه أبو لهب. تفرّق الحشد. لكن الكلمات قيلت من قمة الصفا — ولن يعود شيء في مكة كما كان.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_3_2',
    era: JourneyEra.mecca,
    globalOrder: 13,
    latitude: 21.4225, longitude: 39.8262,
    year: 614,
    title: 'Persecution Begins',
    titleAr: 'بدء الاضطهاد',
    location: 'Mecca',
    locationAr: 'مكة المكرمة',
    narrative:
        'You walk through the streets of Mecca and you can feel it — the atmosphere has changed. The powerful of Quraysh are alarmed. Their gods are being challenged. Their social order questioned. Their authority threatened. And they have decided to respond with force.\n\n'
        'You pass a hot desert road and stop. Bilal ibn Rabah — an enslaved man from Abyssinia — lies on the burning sand. A massive stone presses down on his chest. His master demands he renounce his faith. Bilal says one word, again and again: "Ahad. Ahad." One. One. The oneness of Allah, spoken through cracked lips under the crushing weight.\n\n'
        'Further on, you see the family of Yasir — Ammar, his father, and his mother Sumayyah — being dragged to the desert. Abu Jahl stands over them. The Prophet ﷺ passes. He cannot stop it — not yet. He can only say: "Be patient, O family of Yasir. Your appointment is in Paradise." Sumayyah bint Khabbat will not return from this desert. She will become the first martyr in the history of Islam.',
    narrativeAr:
        'تمشي في شوارع مكة وتحسّ بالتغيير — الأجواء تبدّلت. أصحاب النفوذ في قريش مذعورون. آلهتهم تُتحدى. نظامهم الاجتماعي يُشكَّك فيه. سلطتهم مهددة. وقرروا الرد بالقوة.\n\n'
        'تمرّ بطريق صحراوي حار وتتوقف. بلال بن رباح — عبد من الحبشة — يرقد على الرمال المحرقة. صخرة ضخمة تضغط على صدره. سيده يطالبه بالارتداد عن إيمانه. بلال يقول كلمة واحدة، مراراً وتكراراً: "أحد. أحد." الواحد. الواحد. توحيد الله، يُنطق بشفتين متشققتين تحت الثقل الساحق.\n\n'
        'أبعد قليلاً، ترى عائلة ياسر — عمار وأباه وأمه سمية — يُجرّون إلى الصحراء. أبو جهل يقف فوقهم. يمر النبي ﷺ. لا يستطيع وقف ذلك — ليس بعد. لا يملك إلا أن يقول: "صبراً آل ياسر، فإن موعدكم الجنة." سمية بنت خبّاط لن تعود من هذه الصحراء. ستصبح أول شهيدة في تاريخ الإسلام.',
    source: 'Ibn Kathir, Al-Bidaya wal-Nihaya — accounts of early persecution; Mustadrak al-Hakim',
    xpReward: 35,
    questions: [
      JourneyQuestion(
        id: 'q_1_3_2_a',
        question: 'You pass through the desert road and see Bilal being tortured — a stone on his chest. He calls out "Ahad, Ahad." What do you do?',
        questionAr: 'تمر بالطريق الصحراوي وترى بلالاً يُعذَّب — صخرة على صدره. ينادي "أحد، أحد." ماذا تفعل؟',
        options: [
          'Look away — there is nothing you can do against his master',
          'Stay and witness — someone must remember what is happening here',
          'Run to find Abu Bakr — he is the one with the means to act',
        ],
        optionsAr: [
          'تُشيح بنظرك — لا شيء تستطيع فعله ضد سيده',
          'تبقى وتشهد — يجب أن يتذكر أحد ما يحدث هنا',
          'تركض لتجد أبا بكر — هو الذي يملك القدرة على التصرف',
        ],
        correctIndex: 2,
        explanation: 'History records: Abu Bakr RA heard of Bilal\'s torture and bought his freedom. But not all were saved. Sumayyah bint Khabbat became the first martyr in Islam — killed by Abu Jahl when she refused to renounce her faith. The Prophet ﷺ could only say: "Be patient, O family of Yasir. Your appointment is Paradise."',
        explanationAr: 'يسجّل التاريخ: سمع أبو بكر رضي الله عنه بتعذيب بلال فاشترى حريته. لكن لم يُنقذ الجميع. سمية بنت خبّاط أصبحت أول شهيدة في الإسلام — قتلها أبو جهل حين رفضت الارتداد عن إيمانها. لم يملك النبي ﷺ إلا أن يقول: "صبراً آل ياسر، فإن موعدكم الجنة."',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_3_3',
    era: JourneyEra.mecca,
    globalOrder: 14,
    latitude: 14.1270, longitude: 38.7181,
    year: 615,
    title: 'Migration to Abyssinia',
    titleAr: 'الهجرة إلى الحبشة',
    location: 'Aksum, Abyssinia (Ethiopia)',
    locationAr: 'أكسوم، الحبشة (إثيوبيا)',
    narrative:
        'You are in the court of the Negus — the Christian king of Abyssinia. The room is tense. Two envoys from Quraysh stand before the throne, their arms loaded with gifts for the king and his priests. They have come to demand the return of the Muslim refugees who fled Mecca by night.\n\n'
        'The Negus calls the Muslims forward. Ja\'far ibn Abi Talib — cousin of the Prophet ﷺ — steps up. He speaks simply: "O King, we were a people of ignorance. We worshipped idols, ate the flesh of dead animals, committed shameful deeds, and broke the ties of kinship. Then Allah sent us a Messenger from among us — one whose lineage, truthfulness, and trustworthiness we knew. He called us to worship Allah alone..."\n\n'
        'Then Ja\'far recites from Surah Maryam — the chapter about Mary and the birth of Isa (Jesus). The words fill the court. The Negus weeps. His priests weep. The Quraysh envoys watch their gifts lose their power. The king says: "By God, this and what Isa brought come from the same source of light." He refuses to hand the Muslims over.',
    narrativeAr:
        'أنت في بلاط النجاشي — الملك المسيحي للحبشة. القاعة متوترة. مبعوثان من قريش يقفان أمام العرش، أيديهما مثقلة بهدايا للملك وكهّانه. جاءا ليطلبا إعادة اللاجئين المسلمين الذين فرّوا من مكة ليلاً.\n\n'
        'يستدعي النجاشي المسلمين. يتقدم جعفر بن أبي طالب — ابن عم النبي ﷺ. يتكلم ببساطة: "أيها الملك، كنّا قوماً أهل جاهلية. نعبد الأصنام، ونأكل الميتة، ونأتي الفواحش، ونقطع الأرحام. فبعث الله إلينا رسولاً منّا — نعرف نسبه وصدقه وأمانته. فدعانا إلى عبادة الله وحده..."\n\n'
        'ثم يتلو جعفر من سورة مريم — السورة عن مريم وميلاد عيسى. الكلمات تملأ البلاط. يبكي النجاشي. يبكي كهّانه. مبعوثا قريش يشاهدان هداياهما تفقد قوتها. يقول الملك: "والله ما يزيد عيسى على ما قلتم هذا." ويرفض تسليم المسلمين.',
    source: 'Ibn Hisham, Seerah — migration to Abyssinia; Musnad Ahmad, narration of Ja\'far\'s speech',
    xpReward: 35,
    questions: [
      JourneyQuestion(
        id: 'q_1_3_3_a',
        question: 'Ja\'far recites from Surah Maryam before the Negus. The Quraysh envoys watch with their gifts in hand. Where does your gaze settle?',
        questionAr: 'جعفر يتلو من سورة مريم أمام النجاشي. مبعوثا قريش يراقبان وهداياهما في أيديهما. أين يستقر نظرك؟',
        options: [
          'On the Negus — watching his eyes fill with tears as the words reach him',
          'On the Quraysh envoys — watching their confident expressions crumble',
          'On the Muslim refugees — holding their breath, knowing everything depends on this moment',
        ],
        optionsAr: [
          'على النجاشي — تراقب عينيه تمتلئان بالدموع وهو يسمع الكلمات',
          'على مبعوثي قريش — تراقب تعابيرهما الواثقة تنهار',
          'على اللاجئين المسلمين — يحبسون أنفاسهم، يعلمون أن كل شيء يتوقف على هذه اللحظة',
        ],
        correctIndex: 0,
        explanation: 'History records: The Negus wept and said: "By God, this and what Isa brought come from the same source of light." He refused to return the Muslims. The first asylum in Islamic history was granted by a Christian king who recognized truth when it was spoken before him.',
        explanationAr: 'يسجّل التاريخ: بكى النجاشي وقال: "والله ما يزيد عيسى على ما قلتم هذا." رفض تسليم المسلمين. أول لجوء في تاريخ الإسلام منحه ملك مسيحي عرف الحق حين سمعه أمامه.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_3_4',
    era: JourneyEra.mecca,
    globalOrder: 15,
    latitude: 21.4225, longitude: 39.8262,
    year: 616,
    title: 'The Boycott — Three Years of Siege',
    titleAr: 'الحصار الاقتصادي — ثلاث سنوات من القهر',
    location: 'Shi\'b Abi Talib, Mecca',
    locationAr: 'شعب أبي طالب، مكة المكرمة',
    narrative:
        'You are inside the valley. Shi\'b Abi Talib — a narrow ravine between the mountains — has become a prison. The Quraysh have declared a total boycott of the Banu Hashim and Banu Muttalib — the Prophet\'s ﷺ entire clan, Muslim or not. A signed document hangs inside the Ka\'bah: no one may marry from them, sell to them, or buy from them. Until they surrender Muhammad ﷺ.\n\n'
        'Three years. You have watched children cry from hunger. You have eaten leaves. You have heard the sound of leather being boiled because there was nothing else. The walls of the valley press in. The sky above is the only thing that is not rationed.\n\n'
        'And yet — the community holds. Sympathizers smuggle food in under cover of darkness. Abu Talib, old and weakening, stands at the entrance of the valley like a wall. The Prophet ﷺ moves among the families, offering what comfort he can. You see him tell Abu Talib something — that the scroll in the Ka\'bah has been eaten by termites. Everything except the words "Bismik Allahumma." In Your name, O Allah.',
    narrativeAr:
        'أنت داخل الوادي. شعب أبي طالب — مضيق بين الجبال — أصبح سجناً. أعلنت قريش مقاطعة شاملة لبني هاشم وبني المطلب — عشيرة النبي ﷺ بأكملها، مسلمين وغير مسلمين. وثيقة موقّعة مُعلقة داخل الكعبة: لا يحق لأحد الزواج منهم ولا البيع لهم ولا الشراء منهم. حتى يسلّموا محمداً ﷺ.\n\n'
        'ثلاث سنوات. شاهدت أطفالاً يبكون من الجوع. أكلت أوراق الشجر. سمعت صوت الجلود تُغلى لأنه لم يكن هناك شيء آخر. جدران الوادي تضيق. السماء فوقك هي الشيء الوحيد غير المحصّص.\n\n'
        'ومع ذلك — المجتمع يصمد. متعاطفون يهرّبون الطعام تحت جنح الظلام. أبو طالب، الشيخ الذي يضعف، يقف عند مدخل الوادي كالجدار. النبي ﷺ يتنقل بين العائلات، يقدّم ما يستطيع من عزاء. تراه يخبر أبا طالب شيئاً — أن الصحيفة في الكعبة أكلتها الأرضة. كل شيء عدا كلمات "بسمك اللهم." باسمك يا الله.',
    source: 'Ibn Hisham, Seerah Vol. 1 — the parchment and the boycott',
    xpReward: 35,
    questions: [
      JourneyQuestion(
        id: 'q_1_3_4_a',
        question: 'Three years in Shi\'b Abi Talib. The Muslims have almost nothing. A child cries from hunger nearby. What do you do?',
        questionAr: 'ثلاث سنوات في شعب أبي طالب. المسلمون لا يملكون شيئاً تقريباً. طفل يبكي من الجوع قربك. ماذا تفعل؟',
        options: [
          'Try to smuggle food in under the cover of night — the risk is worth it',
          'Sit with the family and offer words of patience — sometimes presence is all you have',
          'Find a Qurayshi man of conscience and urge him to tear up the document',
        ],
        optionsAr: [
          'تحاول تهريب الطعام تحت جنح الليل — المخاطرة تستحق',
          'تجلس مع العائلة وتقدم كلمات صبر — أحياناً الحضور هو كل ما تملك',
          'تبحث عن رجل من قريش صاحب ضمير وتحثه على تمزيق الوثيقة',
        ],
        correctIndex: 0,
        explanation: 'History records: Sympathizers smuggled food into the valley at night, risking their own safety. The boycott lasted three terrible years. When men of conscience finally tore up the agreement, they found the scroll in the Ka\'bah had been eaten by termites — everything except "Bismik Allahumma." The Prophet ﷺ had already told his uncle this would happen.',
        explanationAr: 'يسجّل التاريخ: متعاطفون هرّبوا الطعام إلى الوادي ليلاً، مخاطرين بسلامتهم. استمر الحصار ثلاث سنوات رهيبة. حين مزّق رجال الضمير الوثيقة أخيراً، وجدوا الصحيفة في الكعبة قد أكلتها الأرضة — كل شيء عدا "بسمك اللهم." كان النبي ﷺ قد أخبر عمه بذلك.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_3_5',
    era: JourneyEra.mecca,
    globalOrder: 16,
    latitude: 21.4225, longitude: 39.8262,
    year: 619,
    title: 'Year of Grief — Khadijah and Abu Talib',
    titleAr: 'عام الحزن — خديجة وأبو طالب',
    location: 'Mecca',
    locationAr: 'مكة المكرمة',
    narrative:
        'Two losses. Weeks apart. You stand at the edge of the Banu Hashim quarter and feel the weight of what has happened.\n\n'
        'Khadijah is gone. Twenty-five years together. She was the first to believe, the first to comfort, the mother of his children, the one who wrapped him in a cloak when the mountain shook beneath him. Her doorway is empty now. No one will fill it.\n\n'
        'And Abu Talib — the man who raised him, who stood between him and the fury of every powerful clan in Mecca — has also died. Without Abu Talib\'s protection, the tribal system offers the Prophet ﷺ almost nothing. The enemies of Islam grow bolder by the day. You see dirt thrown at him in the street. You see him walking alone where once he walked shielded.\n\n'
        'He calls this "Aam al-Huzn" — the Year of Grief. It is the darkest point of his mission. But you sense — even now — that darkness this deep does not arrive without a dawn coming behind it.',
    narrativeAr:
        'خسارتان. بينهما أسابيع. تقف عند حافة حي بني هاشم وتحسّ بثقل ما حدث.\n\n'
        'خديجة رحلت. خمسة وعشرون عاماً معاً. كانت أول من آمن، وأول من واسى، وأم أبنائه، ومن لفّته بالثوب حين اهتزّ الجبل تحته. بابها فارغ الآن. لن يملأه أحد.\n\n'
        'وأبو طالب — الرجل الذي ربّاه، والذي وقف بينه وبين غضب كل حيّ قوي في مكة — مات أيضاً. بدون حماية أبي طالب، النظام القبلي لا يقدّم للنبي ﷺ شيئاً يُذكر. أعداء الإسلام يزدادون جرأة كل يوم. ترى التراب يُلقى عليه في الشارع. تراه يمشي وحيداً حيث كان يمشي محمياً.\n\n'
        'يسمّي هذا "عام الحزن." أحلك نقطة في رسالته. لكنك تحسّ — حتى الآن — أن ظلاماً بهذا العمق لا يأتي دون فجر يتبعه.',
    source: 'Sahih Bukhari 1245 — on the death of Khadijah; Ibn Hisham, Seerah',
    xpReward: 40,
    questions: [
      JourneyQuestion(
        id: 'q_1_3_5_a',
        question: 'Khadijah has died. Abu Talib has died. The Prophet ﷺ walks through Mecca unshielded. Where does your gaze settle?',
        questionAr: 'خديجة ماتت. أبو طالب مات. النبي ﷺ يمشي في مكة دون حماية. أين يستقر نظرك؟',
        options: [
          'On the empty doorway of Khadijah\'s home — the silence where her voice used to be',
          'On the Prophet ﷺ himself — and the weight he now carries alone',
          'On the Quraysh who have grown bolder — throwing dirt where they once feared to approach',
        ],
        optionsAr: [
          'على عتبة بيت خديجة الفارغة — الصمت حيث كان صوتها',
          'على النبي ﷺ نفسه — والثقل الذي يحمله الآن وحيداً',
          'عل�� قريش التي ازدادت جرأة — يلقون التراب حيث كانوا يخشون الاقتراب',
        ],
        correctIndex: 1,
        explanation: 'History records: The Prophet ﷺ called this Aam al-Huzn — the Year of Grief. It was the darkest period of his mission. But what followed was the Isra\' wal-Mi\'raj — the Night Journey to Jerusalem and the Ascent to the Heavens — a divine gift of consolation. Darkness does not arrive without a dawn.',
        explanationAr: 'يسجّل التاريخ: سمّى النبي ﷺ هذا عام الحزن. كان أحلك مراحل رسالته. لكن ما تلاه كان الإسراء والمعراج — رحلة الليل إلى القدس والصعود إلى السماوات — هبة إلهية من العزاء. الظلام لا يأتي دون فجر.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_3_11',
    era: JourneyEra.mecca,
    globalOrder: 17,
    latitude: 21.4225, longitude: 39.8262,
    year: 619,
    title: 'The Journey to Ta\'if — Rejection and Resilience',
    titleAr: 'رحلة الطائف — الرفض والصمود',
    location: 'Ta\'if',
    locationAr: 'الطائف',
    narrative:
        'You walk beside the Prophet ﷺ and Zayd ibn Harithah on the road to Ta\'if — a prosperous city in the mountains, home of the tribe of Thaqif. After the Year of Grief, after Mecca turned hostile, he has come here looking for a new base of support.\n\n'
        'He meets the three leaders of the tribe. He presents the message of Islam. They reject him with contempt. And then — they send their slaves and street boys after him. You see them line the road, throwing stones, shouting insults. The stones hit his feet until they bleed. Zayd throws himself over the Prophet ﷺ, taking blows meant for him.\n\n'
        'They reach a garden. The Prophet ﷺ sits, exhausted, bleeding, his sandals soaked red. He raises his hands and makes a supplication that will echo for all of time: "O Allah, to You I complain of my weakness, my insufficient ability, and my insignificance before people... if You are not angry with me, I do not care..." The Angel of the Mountains appears and offers to crush Ta\'if between two mountains. The Prophet ﷺ says: "No. I hope that Allah will bring from their descendants people who worship Allah alone."',
    narrativeAr:
        'تمشي بجانب النبي ﷺ وزيد بن حارثة على طريق الطائف — مدينة مزدهرة في الجبال، موطن قبيلة ثقيف. بعد عام الحزن، بعد أن تحوّلت مكة معادية، جاء هنا يبحث عن قاعدة دعم جديدة.\n\n'
        'يلتقي الزعماء الثلاثة للقبيلة. يعرض رسالة الإسلام. يرفضونه بازدراء. ثم — يرسلون عبيدهم وصبيان الشوارع خلفه. تراهم يصطفون على الطريق، يرمون الحجارة، يصرخون بالشتائم. الحجارة تصيب قدميه حتى ينزف. زيد يلقي بنفسه فوق النبي ﷺ، يتلقى ضربات كانت موجّهة إليه.\n\n'
        'يصلان إلى بستان. النبي ﷺ يجلس، منهكاً، نازفاً، نعلاه مُبلّلتان بالأحمر. يرفع يديه ويدعو دعاءً سيتردد صداه إلى الأبد: "اللهم إليك أشكو ضعف قوتي، وقلة حيلتي، وهواني على الناس... إن لم تكن ساخطاً عليّ فلا أبالي..." يظهر ملك الجبال ويعرض أن يطبق على الطائف جبلَيْها. يقول النبي ﷺ: "لا. أرجو أن يُخرج الله من أصلابهم من يعبد الله وحده."',
    source: 'Sahih Bukhari 3231 — Prophet\'s ﷺ supplication after Ta\'if; Sahih Muslim 1795',
    xpReward: 45,
    questions: [
      JourneyQuestion(
        id: 'q_1_3_11_a',
        question: 'The Prophet ﷺ sits wounded in a garden outside Ta\'if, bleeding from both feet. Zayd stands over him. Where does your gaze settle?',
        questionAr: 'النبي ﷺ يجلس جريحاً في بستان خارج الطائف، ينزف من قدميه. زيد يقف فوقه. أين يستقر نظرك؟',
        options: [
          'On the people of Ta\'if retreating behind their walls after throwing their stones',
          'On Zayd ibn Harithah — standing over the Prophet ﷺ like a shield made of flesh',
          'On the Prophet ﷺ — who is not angry. His hands are raised. He is praying.',
        ],
        optionsAr: [
          'على أهل الطائف المنسحبين خلف أسوارهم بعد أن ألقوا حجارتهم',
          'على زيد بن حارثة — يقف فوق النبي ﷺ كدرع من لحم',
          'على النبي ﷺ — الذي ليس غاضباً. يداه مرفوعتان. إنه يدعو.',
        ],
        correctIndex: 2,
        explanation: 'History records: He raised his hands and prayed: "O Allah, if You are not angry with me, I do not care." The Angel of Mountains offered to crush Ta\'if. He refused. "I hope their descendants will worship Allah alone." This is not the response of a man seeking power. This is the response of a prophet who knows exactly who sent him.',
        explanationAr: 'يسجّل التاريخ: رفع يديه ودعا: "اللهم إن لم تكن ساخطاً عليّ فلا أبالي." عرض ملك الجبال تدمير الطائف. رفض. "أرجو أن يُخرج الله من أصلابهم من يعبد الله وحده." هذا ليس ردّ رجل يطلب السلطة. هذا ردّ نبيّ يعرف تماماً من أرسله.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_3_6',
    era: JourneyEra.mecca,
    globalOrder: 18,
    latitude: 31.7683, longitude: 35.2137,
    year: 620,
    title: 'Al-Isra\' wal-Mi\'raj — The Night Journey',
    titleAr: 'الإسراء والمعراج',
    location: 'Mecca → Jerusalem → The Heavens',
    locationAr: 'مكة → القدس → السماوات',
    narrative:
        'One night — after the grief, after the loss, after the streets of Mecca turned hostile — the Prophet ﷺ is taken on a journey beyond anything the human mind can contain.\n\n'
        'The Angel Jibreel comes with the Buraq — a luminous creature — and carries him from the Sacred Mosque in Mecca to the Al-Aqsa Mosque in Jerusalem. There, every prophet who ever lived stands waiting. Ibrahim. Musa. Isa. And others. Muhammad ﷺ leads them all in prayer. This is Al-Isra\'.\n\n'
        'Then the Ascent. Through seven heavens, meeting prophets at each level. Adam in the first. Yahya and Isa in the second. Yusuf in the third. Idris in the fourth. Harun in the fifth. Musa in the sixth. Ibrahim in the seventh. Then — beyond all creation — brought before Allah Himself. The gift brought back: the five daily prayers. Originally fifty; reduced to five through conversation with Musa, each equal in reward to fifty.\n\n'
        'When the Prophet ﷺ returns and tells the Quraysh, they laugh. But Abu Bakr says without hesitation: "If he says it, it is true." From this night, Abu Bakr is Al-Siddiq — The Affirmer of Truth.',
    narrativeAr:
        'ذات ليلة — بعد الحزن، بعد الفقد، بعد أن تحوّلت شوارع مكة معادية — يُؤخذ النبي ﷺ في رحلة تفوق ما يستوعبه العقل البشري.\n\n'
        'يأتي جبريل بالبراق — مخلوق نوراني — ويحمله من المسجد الحرام في مكة إلى المسجد الأقصى في القدس. هناك، كل نبيّ عاش على الأرض يقف منتظراً. إبراهيم. موسى. عيسى. وغيرهم. محمد ﷺ يؤمّهم جميعاً في الصلاة. هذا الإسراء.\n\n'
        'ثم المعراج. عبر سبع سماوات، يلقى أنبياء في كل مستوى. آدم في الأولى. يحيى وعيسى في الثانية. يوسف في الثالثة. إدريس في الرابعة. هارون في الخامسة. موسى في السادسة. إبراهيم في السابعة. ثم — فوق كل الخلق — يُحضَر بين يدي الله ذاته. الهبة التي عاد بها: الصلوات الخمس. خمسون في الأصل؛ خُففت إلى خمس في حوار مع موسى، كل واحدة تعدل خمسين ثواباً.\n\n'
        'حين يعود النبي ﷺ ويخبر قريشاً، يضحكون. لكن أبا بكر يقول دون تردد: "إن قاله فهو حق." منذ هذه الليلة، أبو بكر هو الصدّيق.',
    source: 'Sahih Bukhari 3887 — Kitab al-Manaqib; Quran 17:1 — Surah Al-Isra\'',
    xpReward: 50,
    questions: [
      JourneyQuestion(
        id: 'q_1_3_6_a',
        question: 'The Prophet ﷺ has returned from the Night Journey. He describes what he witnessed. The Quraysh mock him. Where does your gaze settle?',
        questionAr: 'عاد النبي ﷺ من رحلة الليل. يصف ما شاهده. قريش تسخر منه. أين يستقر نظرك؟',
        options: [
          'On Abu Bakr — who hears the account and does not hesitate for a single breath',
          'On the crowd — whose laughter has not touched the Prophet\'s certainty',
          'On the Prophet ﷺ himself — steady, unhurried, carrying something the world cannot yet see',
        ],
        optionsAr: [
          'على أبي بكر — الذي يسمع الرواية ولا يتردد نفَساً واحداً',
          'على الحشد — الذي لم يمسّ ضحكهم يقين النبي',
          'على النبي ﷺ نفسه — ثابت، غير مستعجل، يحمل ما لا يراه العالم بعد',
        ],
        correctIndex: 0,
        explanation: 'History records: Abu Bakr said: "If he said it, it is true." For this — affirming without hesitation what the mind could not grasp — he was named Al-Siddiq, The Affirmer of Truth. The highest companion is not always the most powerful. Sometimes he is simply the one who believes first.',
        explanationAr: 'يسجّل التاريخ: قال أبو بكر: "إن قاله فهو حق." لهذا — تصديقه دون تردد ما لا يستوعبه العقل — سُمّي الصدّيق. أعلى الرفاق ليس دائماً الأقوى. أحياناً هو ببساطة من يؤمن أولاً.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_3_7',
    era: JourneyEra.mecca,
    globalOrder: 19,
    latitude: 21.4225, longitude: 39.8262,
    year: 620,
    title: 'The Pledge of Aqabah — First',
    titleAr: 'بيعة العقبة الأولى',
    location: 'Mina, near Mecca',
    locationAr: 'منى، قرب مكة المكرمة',
    narrative:
        'It is the season of Hajj. You are in the valley of Aqabah, near Mina, under the cover of night. The Prophet ﷺ has been meeting with tribes for years — rejected by every one. But tonight, something is different.\n\n'
        'Six men from the tribe of Khazraj in Yathrib met him last year and returned home talking. Now twelve have come back. They sit in a circle around the Prophet ﷺ in the dark — the glow of stars the only light. They give their word: they will not worship any beside Allah. They will not steal. They will not kill their infant daughters. They will not disobey the Prophet ﷺ in what is right.\n\n'
        'You watch the Prophet ﷺ choose a young man — Mus\'ab ibn Umayr, of exceptional character and eloquence — and send him back with the delegation. Islam\'s first official teacher to a new land. Within a year, Islam will spread through Yathrib like light through an open window. The door that Mecca slammed shut — Allah is opening from the other side.',
    narrativeAr:
        'إنه موسم الحج. أنت في وادي العقبة، قرب منى، تحت جنح الليل. النبي ﷺ يلتقي القبائل منذ سنوات — رفضته كلها. لكن الليلة، شيء مختلف.\n\n'
        'ستة رجال من قبيلة الخزرج في يثرب التقوه العام الماضي وعادوا يتحدثون. الآن عاد اثنا عشر. يجلسون في حلقة حول النبي ﷺ في الظلام — وهج النجوم النور الوحيد. يعطون كلمتهم: لن يعبدوا غير الله. لن يسرقوا. لن يقتلوا بناتهم. لن يعصوا النبي ﷺ في معروف.\n\n'
        'تشاهد النبي ﷺ يختار شاباً — مصعب بن عمير، استثنائي الخُلق والبلاغة — ويرسله مع الوفد. أول معلم رسمي للإسلام في أرض جديدة. في غضون عام، سينتشر الإسلام في يثرب كالنور من نافذة مفتوحة. الباب الذي أغلقته مكة — يفتحه الله من الجانب الآخر.',
    source: 'Ibn Hisham, Seerah — First Pledge of Aqabah; Sahih Bukhari 3892',
    xpReward: 35,
    questions: [
      JourneyQuestion(
        id: 'q_1_3_7_a',
        question: 'Twelve men from Yathrib have pledged their word. They are preparing to return home. The Prophet ﷺ chooses a young man to send with them. What do you do?',
        questionAr: 'اثنا عشر رجلاً من يثرب أعطوا كلمتهم. يستعدون للعودة. النبي ﷺ يختار شاباً ليرسله معهم. ماذا تفعل؟',
        options: [
          'Say nothing — you will see what happens when they reach Yathrib',
          'Walk with Mus\'ab to the edge of the camp — ask him if he is ready for this',
          'Look back at the Prophet ﷺ — his face in the starlight says more than words',
        ],
        optionsAr: [
          'لا تقول شيئاً — ستنتظر لترى ما يحدث حين يصلون يثرب',
          'تمشي مع مصعب إلى حافة المعسكر — تسأله إن كان مستعداً لهذا',
          'تنظر إلى النبي ﷺ — وجهه في ضوء النجوم يقول أكثر من الكلمات',
        ],
        correctIndex: 1,
        explanation: 'History records: Mus\'ab ibn Umayr traveled to Yathrib and taught with such grace that within a year, Islam had spread through the city. The next Hajj season, seventy-five people would return — not twelve. The door that Mecca slammed shut, Allah opened from the other side.',
        explanationAr: 'يسجّل التاريخ: سافر مصعب بن عمير إلى يثرب وعلّم بأناقة حتى انتشر الإسلام في المدينة خلال عام. في موسم الحج التالي، سيعود خمسة وسبعون — لا اثنا عشر. الباب الذي أغلقته مكة، فتحه الله من الجانب الآخر.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_3_8',
    era: JourneyEra.mecca,
    globalOrder: 20,
    latitude: 21.4225, longitude: 39.8262,
    year: 621,
    title: 'The Second Pledge of Aqabah',
    titleAr: 'بيعة العقبة الثانية',
    location: 'Mina, near Mecca',
    locationAr: 'منى، قرب مكة المكرمة',
    narrative:
        'It is night again at Aqabah. But this time, the circle is enormous. Seventy-three men and two women from Medina have slipped out of their camp and gathered here in secret. The Quraysh must not know.\n\n'
        'The Prophet\'s ﷺ uncle Al-Abbas — though not yet Muslim — has come to watch over his nephew. He addresses the Medinans first: "You are taking on the protection of this man. Know what that means. If you cannot hold your word, release him now — for he has honor among his own people." The Medinans do not flinch.\n\n'
        'One by one, they pledge. Not the earlier pledge of belief — this is a pledge of war. They will defend the Prophet ﷺ as they would defend their own families. They will fight for him if called. Twelve leaders are chosen from among them — nine from Khazraj, three from Aws. You sit close enough to hear the words. Each voice is steady. Each face is certain. History is turning in the dark, and you are here to witness it.',
    narrativeAr:
        'ليل مرة أخرى عند العقبة. لكن هذه المرة، الحلقة ضخمة. ثلاثة وسبعون رجلاً وامرأتان من المدينة تسللوا من معسكرهم وتجمعوا هنا سراً. يجب ألا تعلم قريش.\n\n'
        'عم النبي ﷺ العباس — الذي لم يسلم بعد — جاء ليراقب ابن أخيه. يخاطب أهل المدينة أولاً: "أنتم تتولون حماية هذا الرجل. اعرفوا ما يعني ذلك. إن لم تستطيعوا الوفاء، فأطلقوه الآن — فهو في عز بين قومه." أهل المدينة لا يتراجعون.\n\n'
        'واحداً تلو الآخر، يبايعون. ليست بيعة الإيمان السابقة — هذه بيعة حرب. سيحمون النبي ﷺ كما يحمون ذويهم. سيقاتلون عنه إن دُعوا. يُختار اثنا عشر نقيباً منهم — تسعة من الخزرج وثلاثة من الأوس. تجلس قريباً بما يكفي لسماع الكلمات. كل صوت ثابت. كل وجه واثق. التاريخ يتحول في الظلام، وأنت هنا لتشهد.',
    source: 'Ibn Hisham, Seerah — Second Pledge of Aqabah; Musnad Ahmad',
    xpReward: 40,
    questions: [
      JourneyQuestion(
        id: 'q_1_3_8_a',
        question: 'It is night. Seventy-five people from Medina have slipped out to meet the Prophet ﷺ at Aqabah. They are about to pledge their lives. What do you do?',
        questionAr: 'إنه الليل. خمسة وسبعون شخصاً من المدينة تسللوا للقاء النبي ﷺ عند العقبة. هم على وشك أن يبايعوا بأرواحهم. ماذا تفعل؟',
        options: [
          'Stand guard at the path — if the Quraysh come, someone must warn them',
          'Sit close and listen — you need to hear the words of this pledge',
          'Count the faces in the dark — you have never seen this many people commit so quietly',
        ],
        optionsAr: [
          'تقف حارساً على الممر — إن جاءت قريش، يجب أن ينبّههم أحد',
          'تجلس قريباً وتصغي — تحتاج أن تسمع كلمات هذه البيعة',
          'تعدّ الوجوه في الظلام — لم ترَ قط هذا العدد يلتزم بهذا الصمت',
        ],
        correctIndex: 1,
        explanation: 'History records: Each person pledged to protect the Prophet ﷺ as they would their own families. Twelve representatives were chosen. When news leaked to the Quraysh, the Medinans had already dispersed. The Hijrah was now possible. The course of history was about to change.',
        explanationAr: 'يسجّل التاريخ: كل شخص بايع على حماية النبي ﷺ كما يحمي ذويه. اختير اثنا عشر نقيباً. حين تسرّب الخبر إلى قريش، كان أهل المدينة قد تفرّقوا. أصبحت الهجرة ممكنة. مجرى التاريخ كان على وشك أن يتغيّر.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_3_9',
    era: JourneyEra.mecca,
    globalOrder: 21,
    latitude: 21.4225, longitude: 39.8262,
    year: 622,
    title: 'The Plot to Kill the Prophet ﷺ',
    titleAr: 'مؤامرة اغتيال النبي ﷺ',
    location: 'Mecca',
    locationAr: 'مكة المكرمة',
    narrative:
        'The Quraysh have learned that the Muslims are leaving. One by one, families have slipped out of Mecca — heading north to Medina. The powerful men of Quraysh convene an emergency council. Their conclusion: Muhammad ﷺ must die tonight. The plan is precise — one man from every tribe strikes together, so the blood-guilt is spread too thin for Banu Hashim to seek revenge.\n\n'
        'But Jibreel has warned the Prophet ﷺ. You are near the house. You see him ask Ali ibn Abi Talib — young, brave, certain — to sleep in his bed, covered by his green cloak. Ali does not hesitate. The assassins surround the house. You can see their shadows in the moonlight. They wait.\n\n'
        'The Prophet ﷺ steps out into the night. He walks past them — past every one of them — reciting the opening of Surah Ya-Sin: "And We have put before them a barrier and behind them a barrier and covered them, so they do not see." They do not see him. At dawn, they burst in. They find Ali. The Hijrah has begun.',
    narrativeAr:
        'قريش علمت أن المسلمين يرحلون. عائلة تلو عائلة، تسللوا من مكة — متجهين شمالاً إلى المدينة. أصحاب النفوذ في قريش يعقدون مجلساً طارئاً. خلاصتهم: محمد ﷺ يجب أن يموت الليلة. الخطة دقيقة — رجل من كل قبيلة يضربون معاً، فيتوزع دم الجريمة بما يجعل المطالبة بالثأر مستحيلة.\n\n'
        'لكن جبريل حذّر النبي ﷺ. أنت قرب البيت. تراه يطلب من علي بن أبي طالب — الشاب، الشجاع، الواثق — أن ينام في فراشه مغطىً ببردته الخضراء. علي لا يتردد. المتآمرون يطوّقون البيت. ترى ظلالهم في ضوء القمر. ينتظرون.\n\n'
        'النبي ﷺ يخرج في الليل. يمشي بينهم — بين كلّ واحد منهم — يتلو مطلع سورة يس: "وَجَعَلْنَا مِن بَيْنِ أَيْدِيهِمْ سَدًّا وَمِنْ خَلْفِهِمْ سَدًّا فَأَغْشَيْنَاهُمْ فَهُمْ لَا يُبْصِرُونَ." لا يرونه. عند الفجر، يقتحمون. يجدون علياً. الهجرة بدأت.',
    source: 'Sahih Bukhari 3905 — Hijrah narrative; Quran 36:9',
    xpReward: 45,
    questions: [
      JourneyQuestion(
        id: 'q_1_3_9_a',
        question: 'The killers surround the house. Ali lies in the Prophet\'s ﷺ bed. The Prophet ﷺ has stepped into the night. You are near the path. What do you do?',
        questionAr: 'القتلة يطوّقون البيت. علي يرقد في فراش النبي ﷺ. النبي ﷺ خرج في الليل. أنت قرب الممر. ماذا تفعل؟',
        options: [
          'Stay hidden and still — do not draw their eyes from the house',
          'Follow quietly in the Prophet\'s ﷺ footsteps as he moves through the dark',
          'Move toward the house to distract the killers from noticing anything outside',
        ],
        optionsAr: [
          'ابقَ مختبئاً وساكناً — لا تجذب أنظارهم بعيداً عن البيت',
          'اتبع بهدوء خطوات النبي ﷺ وهو يتحرك في الظلام',
          'تحرّك نحو البيت لتصرف انتباه القتلة عن أي شيء خارجه',
        ],
        correctIndex: 0,
        explanation: 'History records: The Prophet ﷺ walked past the assembled killers reciting Surah Ya-Sin. Allah covered their eyes. They did not see him. At dawn, they burst into the house — and found Ali. The Prophet ﷺ and Abu Bakr were already heading south, toward Cave Thawr. The Hijrah had begun.',
        explanationAr: 'يسجّل التاريخ: مشى النبي ﷺ بين القتلة المتجمعين يتلو سورة يس. غشّى الله أبصارهم. لم يروه. عند الفجر، اقتحموا البيت — ووجدوا علياً. كان النبي ﷺ وأبو بكر قد توجها جنوباً بالفعل، نحو غار ثور. الهجرة بدأت.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_3_10',
    era: JourneyEra.mecca,
    globalOrder: 22,
    latitude: 21.2927, longitude: 40.2188,
    year: 622,
    title: 'Cave Thawr — Three Days in Hiding',
    titleAr: 'غار ثور — ثلاثة أيام مختبئَيْن',
    location: 'Jabal Thawr, south of Mecca',
    locationAr: 'جبل ثور، جنوب مكة المكرمة',
    narrative:
        'They went south — the opposite direction from Medina — to throw the Quraysh off the trail. You are at the base of Jabal Thawr, a difficult mountain south of Mecca. The Prophet ﷺ and Abu Bakr have climbed to a small cave near the summit. The Quraysh have set a reward of one hundred camels — a fortune — for anyone who brings them back, dead or alive.\n\n'
        'Three days. Search parties comb the land. Abdullah ibn Abi Bakr brings news each night. Asma\' bint Abi Bakr carries provisions, tearing her waistband in two to bind the food — earning the name "Dhat al-Nitaqayn," She of the Two Bands.\n\n'
        'On the second day, a search party reaches the mouth of the cave. Abu Bakr trembles. "O Messenger of Allah," he whispers, "if one of them looks down at his feet he will see us." The Prophet ﷺ answers with a calm that does not belong to this world: "O Abu Bakr — what do you think of two when Allah is their third?" A spider has woven its web across the entrance. A pair of doves has nested at the opening. The searchers turn back.',
    narrativeAr:
        'توجّها جنوباً — عكس اتجاه المدينة — ليضلّلا قريشاً. أنت عند سفح جبل ثور، جبل وعر جنوب مكة. النبي ﷺ وأبو بكر صعدا إلى كهف صغير قرب القمة. قريش عرضت مئة ناقة — ثروة — لمن يأتي بهما حيَّيْن أو ميّتَيْن.\n\n'
        'ثلاثة أيام. فرق البحث تمشّط الأرض. عبد الله بن أبي بكر يأتي بالأخبار كل ليلة. أسماء بنت أبي بكر تحمل الزاد، شاقّةً نطاقها إلى قطعتين لتربط الطعام — فنالت لقب "ذات النطاقَيْن."\n\n'
        'في اليوم الثاني، يبلغ فريق بحث فم الكهف. يرتجف أبو بكر. "يا رسول الله"، يهمس، "لو نظر أحدهم إلى قدميه لرآنا." يجيب النبي ﷺ بهدوء ليس من هذا العالم: "يا أبا بكر، ما ظنّك باثنين الله ثالثهما؟" عنكبوت نسجت خيطها عبر المدخل. زوج من الحمام يعشّش عند الفتحة. المحيطون يرجعون.',
    source: 'Sahih Bukhari 3653 — Cave of Thawr; Quran 9:40',
    xpReward: 40,
    questions: [
      JourneyQuestion(
        id: 'q_1_3_10_a',
        question: 'Three days in Cave Thawr. A search party reaches the entrance. Abu Bakr whispers: "If one of them looks down..." Where does your gaze settle?',
        questionAr: 'ثلاثة أيام في غار ثور. فريق بحث يصل المدخل. أبو بكر يهمس: "لو نظر أحدهم..." أين يستقر نظرك؟',
        options: [
          'On the searchers\' feet at the cave entrance — so close you can hear them breathe',
          'On Abu Bakr\'s trembling hands — fear not for himself, but for the Prophet ﷺ',
          'On the Prophet\'s ﷺ face — which shows no fear at all',
        ],
        optionsAr: [
          'على أقدام المحيطين عند مدخل الكهف — قريبون جداً تسمع أنفاسهم',
          'على يدَي أبي بكر المرتجفتين — خوف ليس على نفسه، بل على النبي ﷺ',
          'على وجه النبي ﷺ — الذي لا يُظهر أي خوف إطلاقاً',
        ],
        correctIndex: 2,
        explanation: 'History records: "What do you think of two when Allah is their third?" The spider web. The dove\'s nest. The searchers turned back. On the third night, a guide arrived with two camels. They rode north under cover of darkness. Medina was waiting.',
        explanationAr: 'يسجّل التاريخ: "ما ظنّك باثنين الله ثالثهما؟" بيت العنكبوت. عشّ الحمام. المحيطون رجعوا. في الليلة الثالثة، وصل دليلهما بناقتين. انطلقا شمالاً تحت جنح الظلام. المدينة كانت تنتظر.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_4_1',
    era: JourneyEra.medina,
    globalOrder: 23,
    latitude: 24.4686, longitude: 39.6142,
    year: 622,
    yearAH: 1,
    title: 'Arrival in Medina — The Hijrah',
    titleAr: 'الوصول إلى المدينة — الهجرة',
    location: 'Quba, then Medina',
    locationAr: 'قباء، ثم المدينة المنورة',
    narrative:
        'You see it before you hear it. Women and children on the rooftops. Then the singing begins — "Tala\'a al-Badru alayna, min thaniyyat al-Wada\'" — "The full moon has risen upon us, from the valley of Wada\'. Gratitude is upon us, as long as a caller calls to Allah." Spontaneous. Joyful. A city that has been holding its breath — finally exhaling.\n\n'
        'The Prophet ﷺ rides into Medina. He spent four days at Quba first, laying the foundation of the first mosque in Islam — Masjid Quba. Now every tribe in Medina wants the honor of hosting him. Each calls out. Each reaches for the camel\'s reins. But he lets the camel walk freely. "Leave her," he says. "She is commanded."\n\n'
        'The camel kneels in the district of Banu al-Najjar. This is where Allah has directed. Here, he will build his mosque and his home. The Islamic calendar begins from this day. A community, a law, and a civilization are about to rise from the soil of this small oasis city.',
    narrativeAr:
        'تراه قبل أن تسمعه. نساء وأطفال على السطوح. ثم يبدأ الغناء — "طلع البدر علينا، من ثنيات الوداع — وجب الشكر علينا، ما دعا لله داع." عفوي. بهيج. مدينة كانت تحبس أنفاسها — أخيراً تزفر.\n\n'
        'النبي ﷺ يدخل المدينة. أمضى أربعة أيام في قباء أولاً، أرسى فيها أساس أول مسجد في الإسلام — مسجد قباء. الآن كل حيّ في المدينة يريد شرف استضافته. كلٌّ ينادي. كلٌّ يمدّ يده إلى زمام الناقة. لكنه يتركها تسير حرة. "دعوها"، يقول. "فإنها مأمورة."\n\n'
        'الناقة تبرك في حيّ بني النجار. هنا وجّه الله. هنا سيبني مسجده وبيته. التقويم الإسلامي يبدأ من هذا اليوم. أمة وشريعة وحضارة على وشك أن تنهض من تربة هذه المدينة الواحة الصغيرة.',
    source: 'Sahih Bukhari 3906 — arrival in Medina; Ibn Hisham, Seerah',
    xpReward: 50,
    questions: [
      JourneyQuestion(
        id: 'q_1_4_1_a',
        question: 'The Prophet ﷺ rides into Medina. Women sing from the rooftops. Every tribe wants him to stay. He lets the camel walk freely. Where does your gaze settle?',
        questionAr: 'النبي ﷺ يدخل المدينة. النساء يُنشدن من السطوح. كل قبيلة تريده أن يبقى. يترك الناقة تسير حرة. أين يستقر نظرك؟',
        options: [
          'On the rooftops — the joy fills the city like a breath finally released',
          'On the Prophet ﷺ — who has let the camel walk freely, not choosing for himself',
          'On the camel — who kneels in the district of Banu al-Najjar, exactly where Allah has directed',
        ],
        optionsAr: [
          'على السطوح — الفرح يملأ المدينة كنَفَس أُطلق أخيراً',
          'على النبي ﷺ — الذي ترك الناقة تسير حرة، لا يختار لنفسه',
          'على الناقة — التي تبرك في حيّ بني النجار، حيث وجّه الله تماماً',
        ],
        correctIndex: 2,
        explanation: 'History records: "Leave her. She is commanded." The camel knelt where Allah directed. There, the Prophet ﷺ built his mosque and his home. The Islamic calendar begins from this migration. A community, a law, and a civilization were about to rise.',
        explanationAr: 'يسجّل التاريخ: "دعوها فإنها مأمورة." بركت الناقة حيث وجّه الله. هناك بنى النبي ﷺ مسجده وبيته. التقويم الإسلامي يبدأ من هذه الهجرة. أمة وشريعة وحضارة كانت على وشك أن تنهض.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_4_2',
    era: JourneyEra.medina,
    globalOrder: 24,
    latitude: 24.4686, longitude: 39.6142,
    year: 622,
    yearAH: 1,
    title: 'Building the Prophet\'s Mosque',
    titleAr: 'بناء المسجد النبوي',
    location: 'Medina',
    locationAr: 'المدينة المنورة',
    narrative:
        'You are carrying bricks. Your hands are rough with mortar. Around you, the entire community works — side by side, shoulder to shoulder. And there, in the middle of it all, is the Prophet ﷺ. Carrying his own load. Mixing his own mortar. A companion offers to take his bricks. He declines.\n\n'
        'The land was a date-drying yard owned by two orphan boys. The Prophet ﷺ insisted on paying for it fairly — even though they offered it for free. Now it is becoming a mosque. The walls are mud brick. The pillars are palm tree trunks. The roof is palm fronds. Simple. But it will be more than a place of prayer — it will be the school, the court, the community hall, and the command center of a new civilization.\n\n'
        'As the workers chant verses together, you notice: the Prophet\'s ﷺ own rooms are being built attached to the eastern wall. Modest chambers — barely the size of a small room. The man who could command anything has chosen the simplest home in the community. This is what leadership looks like when it is not about power.',
    narrativeAr:
        'تحمل الطوب. يداك خشنتان من الطين. حولك، المجتمع بأكمله يعمل — جنباً إلى جنب، كتفاً بكتف. وهناك، في وسط كل ذلك، النبي ﷺ. يحمل حمله. يعجن طينه. صحابي يعرض أن يأخذ طوبه. يرفض.\n\n'
        'كانت الأرض ساحة لتجفيف التمر يملكها يتيمان. أصرّ النبي ﷺ على دفع ثمنها بالعدل — رغم أنهما عرضاها مجاناً. الآن تصبح مسجداً. الجدران من اللبن. الأعمدة من جذوع النخل. السقف من سعف النخيل. بسيط. لكنه سيكون أكثر من مكان للصلاة — سيكون المدرسة والمحكمة وقاعة المجتمع ومركز قيادة حضارة جديدة.\n\n'
        'بينما ينشد العمال أبياتاً معاً، تلاحظ: حجرات النبي ﷺ تُبنى ملاصقة للجدار الشرقي. غرف متواضعة — بالكاد بحجم غرفة صغيرة. الرجل الذي يستطيع أن يأمر بأي شيء اختار أبسط بيت في المجتمع. هذا هو شكل القيادة حين لا تكون عن السلطة.',
    source: 'Sahih Bukhari 428 — construction of the mosque; Ibn Hisham, Seerah',
    xpReward: 35,
    questions: [
      JourneyQuestion(
        id: 'q_1_4_2_a',
        question: 'The Prophet ﷺ works alongside his companions carrying bricks. A companion offers to carry his load for him. What does the Prophet ﷺ do?',
        questionAr: 'النبي ﷺ يعمل مع صحابته يحمل الطوب. صحابي يعرض حمل حمله عنه. ماذا يفعل النبي ﷺ؟',
        options: [
          'Accept the help — and thank the companion for his care',
          'Decline — and carry his own share alongside everyone else',
          'Direct the companion to help someone who needs it more',
        ],
        optionsAr: [
          'يقبل المساعدة — ويشكر الصحابي على اهتمامه',
          'يرفض — ويحمل نصيبه إلى جانب الجميع',
          'يوجّه الصحابي لمساعدة من يحتاجها أكثر',
        ],
        correctIndex: 1,
        explanation: 'History records: He worked with his own hands, carried his own bricks, and chanted with his companions as they built. A mosque rose from mud and palm — school, court, command center, and house of God. The heart of a civilization, built with bare hands. His rooms were the smallest in the community.',
        explanationAr: 'يسجّل التاريخ: عمل بيديه، حمل طوبه، وأنشد مع صحابته وهم يبنون. مسجد ارتفع من الطين والنخل — مدرسة ومحكمة ومركز قيادة وبيت لله. قلب حضارة، بُني بالأيدي العارية. حجراته كانت الأصغر في المجتمع.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_4_3',
    era: JourneyEra.medina,
    globalOrder: 25,
    latitude: 24.4686, longitude: 39.6142,
    year: 622,
    yearAH: 1,
    title: 'The Brotherhood — Muakhah',
    titleAr: 'المؤاخاة بين المهاجرين والأنصار',
    location: 'Medina',
    locationAr: 'المدينة المنورة',
    narrative:
        'The Muhajirun have arrived in Medina with nothing. They left homes, businesses, wealth — everything — in Mecca. They carry only their faith. The Prophet ﷺ gathers both communities and announces: each Muhajir will be paired with an Ansari brother. Not a symbolic bond. A real one — shared wealth, shared home, shared life.\n\n'
        'You watch the pairings form. Sa\'d ibn al-Rabi\' al-Ansari is paired with Abd al-Rahman ibn Awf. Sa\'d says: "I am the wealthiest among the Ansar. Take half my property. I also have two wives — look at whichever pleases you more and I will divorce her so you may marry her." You hold your breath. The offer is breathtaking.\n\n'
        'Abd al-Rahman replies: "May Allah bless you in your family and your wealth. Just show me the marketplace." He asks for nothing. He goes to the market, trades, and builds from zero. The Quran will immortalize the Ansar\'s generosity: "They prefer others over themselves, even if they are in need." (59:9) This is what a civilization looks like from the inside — built on brotherhood, not conquest.',
    narrativeAr:
        'وصل المهاجرون إلى المدينة بلا شيء. تركوا البيوت والتجارة والمال — كل شيء — في مكة. لا يحملون إلا إيمانهم. النبي ﷺ يجمع المجتمعين ويعلن: كل مهاجر سيُؤاخى مع أنصاري. ليس رابطاً رمزياً. رابط حقيقي — مال مشترك، بيت مشترك، حياة مشتركة.\n\n'
        'تشاهد الأزواج تتشكّل. سعد بن الربيع الأنصاري يُؤاخى مع عبد الرحمن بن عوف. يقول سعد: "أنا أكثر الأنصار مالاً. خذ نصف مالي. ولي زوجتان، فانظر أعجبهما إليك فأطلقها لك تتزوجها." تحبس أنفاسك. العرض مذهل.\n\n'
        'يجيب عبد الرحمن: "بارك الله لك في أهلك ومالك. دلّني على السوق فحسب." لا يطلب شيئاً. يذهب إلى السوق ويتاجر ويبني من الصفر. القرآن سيخلّد كرم الأنصار: "وَيُؤْثِرُونَ عَلَى أَنفُسِهِمْ وَلَوْ كَانَ بِهِمْ خَصَاصَةٌ" (59:9). هكذا تبدو الحضارة من الداخل — مبنية على الأخوة، لا على الغزو.',
    source: 'Sahih Bukhari 3937 — on the Muakhah; Quran 59:9',
    xpReward: 35,
    questions: [
      JourneyQuestion(
        id: 'q_1_4_3_a',
        question: 'The Muhajirun have arrived with nothing. The Prophet ﷺ pairs each with an Ansari brother. Sa\'d offers half his wealth. Where does your gaze settle?',
        questionAr: 'المهاجرون وصلوا بلا شيء. النبي ﷺ يؤاخي كل مهاجر بأنصاري. سعد يعرض نصف ماله. أين يستقر نظرك؟',
        options: [
          'On Abd al-Rahman ibn Awf — who refuses the gift and asks only for the marketplace',
          'On Sa\'d ibn al-Rabi\' — whose generosity has no precedent in your memory',
          'On the Prophet ﷺ watching the brotherhood form — his plan is working',
        ],
        optionsAr: [
          'على عبد الرحمن بن عوف — الذي يرفض الهبة ويطلب فقط أن يُدلّ على السوق',
          'على سعد بن الربيع — الذي لا مثيل لكرمه في ذاكرتك',
          'على النبي ﷺ يراقب الأخوة تتشكّل — خطته تنجح',
        ],
        correctIndex: 0,
        explanation: 'History records: Abd al-Rahman refused to take without working. He went to the market, traded, and built wealth from nothing. The Ansar\'s generosity was immortalized in the Quran: "They prefer others over themselves, even if they are in need." (59:9) A civilization built on brotherhood — not conquest.',
        explanationAr: 'يسجّل التاريخ: رفض عبد الرحمن الأخذ دون عمل. ذهب إلى السوق وتاجر وبنى ثروة من الصفر. خُلّد كرم الأنصار في القرآن: "وَيُؤْثِرُونَ عَلَى أَنفُسِهِمْ وَلَوْ كَانَ بِهِمْ خَصَاصَةٌ." (59:9) حضارة بُنيت على الأخوة — لا على الغزو.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_4_4',
    era: JourneyEra.medina,
    globalOrder: 26,
    latitude: 23.7309, longitude: 38.7806,
    year: 624,
    yearAH: 2,
    title: 'The Battle of Badr',
    titleAr: 'غزوة بدر',
    location: 'Badr (80km SW of Medina)',
    locationAr: 'بدر (80 كم جنوب غرب المدينة)',
    narrative:
        'Three hundred and thirteen. That is how many of you there are. You stand on the plain of Badr, watching the dust cloud to the south grow larger. Nearly one thousand Qurayshi warriors are marching toward you — armored, mounted, confident. You have two horses. They have hundreds. You have faith. They have fury.\n\n'
        'The Prophet ﷺ spent the entire night in prayer. You could hear him beneath a small shelter, his voice breaking as he called upon Allah: "O Allah, if this small group is destroyed today, You will not be worshipped on this earth." Abu Bakr took his arm and said: "Enough, O Messenger of Allah. Allah will fulfill His promise to you."\n\n'
        'Dawn. Rain fell in the night — hardening the ground beneath your feet, turning it to mud beneath theirs. The Prophet ﷺ cast a handful of dust toward the enemy. The Quran will record: "You did not throw when you threw — but it was Allah who threw." (8:17) The battle is joined. By its end, seventy Quraysh lie dead — including Abu Jahl. Seventy are captured. Fourteen Muslims are martyred. This was not a battle of numbers. This was Badr.',
    narrativeAr:
        'ثلاثمئة وثلاثة عشر. هذا عددكم. تقف على سهل بدر، تشاهد سحابة الغبار جنوباً تكبر. قرابة ألف مقاتل قرشي يزحفون نحوكم — مدرّعون، على خيولهم، واثقون. معكم فرسان. معهم مئات. معكم الإيمان. معهم الغضب.\n\n'
        'النبي ﷺ أمضى الليلة كلها يصلي. كنت تسمعه تحت عريش صغير، صوته يتكسّر وهو يدعو الله: "اللهم إن تُهلك هذه العصابة اليوم لا تُعبد في الأرض." أخذ أبو بكر بذراعه وقال: "كفاك يا رسول الله. إن الله منجز لك ما وعدك."\n\n'
        'الفجر. مطر نزل في الليل — صلّب الأرض تحت أقدامكم وحوّلها طيناً تحت أقدامهم. النبي ﷺ حثا حفنة تراب نحو العدو. القرآن سيسجّل: "وَمَا رَمَيْتَ إِذْ رَمَيْتَ وَلَكِنَّ اللَّهَ رَمَى." (8:17) تبدأ المعركة. في نهايتها، سبعون قرشياً قُتلوا — أبو جهل في مقدمتهم. سبعون أُسروا. أربعة عشر مسلماً استُشهدوا. لم تكن هذه معركة أعداد. كانت بدراً.',
    source: 'Sahih Bukhari 3992 — Battle of Badr; Quran 3:123',
    xpReward: 50,
    questions: [
      JourneyQuestion(
        id: 'q_1_4_4_a',
        question: '313 Muslims face nearly 1,000 Qurayshi warriors. The Prophet ﷺ spent the night in prayer. Dawn breaks over Badr. What do you feel?',
        questionAr: '313 مسلماً يواجهون قرابة ألف مقاتل قرشي. النبي ﷺ أمضى الليلة في الصلاة. الفجر يشرق فوق بدر. ماذا تحسّ؟',
        options: [
          'Fear — the numbers are impossible and the enemy is armed to the teeth',
          'Certainty — something shifted in the night, something you cannot explain',
          'The weight of what is at stake — pressing on every breath you take',
        ],
        optionsAr: [
          'الخوف — الأعداد مستحيلة والعدو مسلّح حتى الأسنان',
          'اليقين — شيء تغيّر في الليل، شيء لا تستطيع تفسيره',
          'ثقل ما هو على المحك — يضغط على كل نفَس تأخذه',
        ],
        correctIndex: 1,
        explanation: 'History records: Allah sent rain that hardened the ground for the Muslims and loosened it for the enemy. He sent angels to fight alongside the believers. "Allah has already given you victory at Badr while you were few." (3:123) Seventy Quraysh fell. Fourteen Muslims were martyred. This was not a battle of numbers. This was divine intervention.',
        explanationAr: 'يسجّل التاريخ: أرسل الله مطراً صلّب الأرض للمسلمين ورخّاها للعدو. أرسل ملائكة تقاتل مع المؤمنين. "وَلَقَدْ نَصَرَكُمُ اللَّهُ بِبَدْرٍ وَأَنتُمْ أَذِلَّةٌ." (3:123) سبعون من قريش سقطوا. أربعة عشر مسلماً استُشهدوا. لم تكن معركة أعداد. كان تدخلاً إلهياً.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_4_5',
    era: JourneyEra.medina,
    globalOrder: 27,
    latitude: 24.5028, longitude: 39.6224,
    year: 625,
    yearAH: 3,
    title: 'The Battle of Uhud',
    titleAr: 'غزوة أحد',
    location: 'Mount Uhud, Medina',
    locationAr: 'جبل أحد، المدينة المنورة',
    narrative:
        'You are on the slopes of Mount Uhud. Three thousand Qurayshi warriors have marched on Medina for revenge. The Prophet ﷺ leads one thousand Muslims out to meet them. The battle begins well — the Quraysh are falling back.\n\n'
        'Then you hear it. From the hill behind you, the archers are leaving. Fifty men were stationed there with one order — one clear, absolute order from the Prophet ﷺ: "Do not leave your position, whether we win or lose." But the enemy appears to be fleeing, and the spoils lie on the field. Most of the archers abandon their post.\n\n'
        'Khalid ibn al-Walid — not yet Muslim, leading the Qurayshi cavalry — sees the gap. His horsemen sweep around the hill and strike the Muslim flank. Chaos. The Prophet ﷺ is wounded — his face cut, a tooth broken. A rumor spreads: "Muhammad is dead." Some flee. But the Prophet ﷺ rallies those around him. He fights on. Seventy companions fall — among them Hamza, the Lion of Allah, the Prophet\'s ﷺ beloved uncle. Uhud is not a defeat. It is a lesson. And the lesson is about obedience.',
    narrativeAr:
        'أنت على سفوح جبل أحد. ثلاثة آلاف مقاتل قرشي زحفوا على المدينة للثأر. النبي ﷺ يقود ألف مسلم للقائهم. المعركة تبدأ بشكل جيد — قريش تتراجع.\n\n'
        'ثم تسمعه. من التلة خلفك، الرماة يغادرون. خمسون رجلاً كانوا هناك بأمر واحد — أمر واضح مطلق من النبي ﷺ: "لا تتركوا مواقعكم سواء انتصرنا أو هُزمنا." لكن العدو يبدو فارّاً، والغنائم على الأرض. معظم الرماة يتركون مواقعهم.\n\n'
        'خالد بن الوليد — لم يسلم بعد، يقود فرسان قريش — يرى الثغرة. فرسانه يلتفون حول التلة ويضربون خاصرة المسلمين. فوضى. النبي ﷺ يُجرح — وجهه يُشقّ، سنّه تُكسر. تنتشر شائعة: "محمد قُتل." بعضهم يفرّ. لكن النبي ﷺ يجمع من حوله. يواصل القتال. سبعون صحابياً يسقطون — منهم حمزة، أسد الله، عم النبي ﷺ الحبيب. أحد ليست هزيمة. إنها درس. والدرس عن الطاعة.',
    source: 'Sahih Bukhari 4043 — Battle of Uhud; Quran 3:140-165',
    xpReward: 45,
    questions: [
      JourneyQuestion(
        id: 'q_1_4_5_a',
        question: 'The archers on the hill watch the Quraysh fleeing. "The battle is won," some say. "Let\'s take the spoils." You are beside them. What do you do?',
        questionAr: 'الرماة على التلة يشاهدون قريشاً تفرّ. "انتهت المعركة"، يقول بعضهم. "لنأخذ الغنائم." أنت بجانبهم. ماذا تفعل؟',
        options: [
          'Leave with them — the battle looks won and the spoils are there for the taking',
          'Stay — the Prophet\'s ﷺ order was clear: do not leave, whether we win or lose',
          'Shout at them to stay, then follow when they do not listen',
        ],
        optionsAr: [
          'تغادر معهم — المعركة تبدو محسومة والغنائم في المتناول',
          'تبقى — أمر النبي ﷺ كان واضحاً: لا تتركوا، سواء انتصرنا أو هُزمنا',
          'تصرخ فيهم ليبقوا، ثم تتبعهم حين لا يستمعون',
        ],
        correctIndex: 1,
        explanation: 'History records: Most archers left their post. Khalid ibn al-Walid\'s cavalry swept through the gap. The Prophet ﷺ was wounded. Seventy companions fell, including Hamza — the Lion of Allah. The Quran asked: "When disaster struck you after you had struck twice the like of it, did you say: From where is this?" (3:165) This was not a battle of numbers. It was a lesson about obedience.',
        explanationAr: 'يسجّل التاريخ: معظم الرماة تركوا مواقعهم. فرسان خالد بن الوليد اخترقوا الثغرة. جُرح النبي ﷺ. سبعون صحابياً سقطوا، منهم حمزة — أسد الله. سأل القرآن: "أَوَلَمَّا أَصَابَتْكُم مُّصِيبَةٌ قَدْ أَصَبْتُم مِّثْلَيْهَا قُلْتُمْ أَنَّى هَذَا؟" (3:165) لم تكن معركة أعداد. كانت درساً في الطاعة.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_4_6',
    era: JourneyEra.medina,
    globalOrder: 28,
    latitude: 24.4686, longitude: 39.6142,
    year: 627,
    yearAH: 5,
    title: 'The Battle of the Trench — Al-Khandaq',
    titleAr: 'غزوة الخندق',
    location: 'Medina',
    locationAr: 'المدينة المنورة',
    narrative:
        'Ten thousand warriors. The largest army Arabia has ever assembled. Quraysh, Ghatafan, and their allies have come to end the Muslim community once and for all. You stand on the northern edge of Medina. The horizon is dark with dust.\n\n'
        'The trench was Salman al-Farisi\'s idea — a Persian defensive tactic the Arabs have never encountered. For six days, you dug alongside the Prophet ﷺ. He carried earth with his own hands, his stomach bound with a stone against hunger. Now the trench stretches across the northern approach — the only side of Medina not protected by lava fields or dense palm groves.\n\n'
        'The coalition army arrives and stops. They stare at the trench in confusion. This is not how Arabs wage war. The siege lasts twenty-seven days. Then — Nu\'aym ibn Mas\'ud comes to the Prophet ﷺ in secret and offers to sow distrust among the coalition. He succeeds. Allah sends a bitter wind that tears the coalition\'s tents apart. Abu Sufyan gives the order to retreat. The greatest threat Medina has ever faced — broken without a single major engagement.',
    narrativeAr:
        'عشرة آلاف محارب. أكبر جيش جمعته الجزيرة العربية. قريش وغطفان وحلفاؤهم جاؤوا للقضاء على المجتمع المسلم نهائياً. تقف على الحافة الشمالية للمدينة. الأفق مظلم بالغبار.\n\n'
        'الخندق كان فكرة سلمان الفارسي — تكتيك دفاعي فارسي لم يواجهه العرب من قبل. لستة أيام، حفرت إلى جانب النبي ﷺ. حمل التراب بيديه، بطنه معصوبة بحجر من الجوع. الآن الخندق يمتد عبر الواجهة الشمالية — الجانب الوحيد من المدينة غير المحمي بحقول الحمم أو بساتين النخل الكثيفة.\n\n'
        'جيش التحالف يصل ويتوقف. يحدّقون في الخندق مذهولين. هذه ليست طريقة العرب في الحرب. الحصار يستمر سبعة وعشرين يوماً. ثم — نُعيم بن مسعود يأتي النبي ﷺ سراً ويعرض أن يزرع الشك بين التحالف. ينجح. يرسل الله ريحاً باردة تمزّق خيام التحالف. أبو سفيان يأمر بالانسحاب. أعظم تهديد واجهته المدينة — كُسر دون خوض معركة كبرى واحدة.',
    source: 'Sahih Bukhari 4100 — Battle of Khandaq; Quran 33:9-11',
    xpReward: 45,
    questions: [
      JourneyQuestion(
        id: 'q_1_4_6_a',
        question: 'The coalition of 10,000 has arrived. The trench has stopped them. The siege enters its third week. What do you feel?',
        questionAr: 'تحالف الـ10,000 وصل. الخندق أوقفهم. الحصار يدخل أسبوعه الثالث. ماذا تحسّ؟',
        options: [
          'Doubt — the numbers are overwhelming and the food is running out',
          'Trust — the Prophet ﷺ is not panicking, and that steadies you',
          'A strange stillness that does not feel like your own — as if something unseen is holding the line',
        ],
        optionsAr: [
          'الشك — الأعداد ساحقة والطعام ينفد',
          'الثقة — النبي ﷺ لا يضطرب، وهذا يثبّتك',
          'سكينة غريبة لا تبدو منك — كأن شيئاً غير مرئي يمسك بالخط',
        ],
        correctIndex: 1,
        explanation: 'History records: Nu\'aym ibn Mas\'ud infiltrated the coalition and turned allies against each other. Allah sent a bitter wind that dismantled their camps. Abu Sufyan ordered the retreat. The greatest army Arabia had ever assembled — broken by a trench, a spy, and a wind. "Indeed, Allah is sufficient as a Disposer of affairs." (33:3)',
        explanationAr: 'يسجّل التاريخ: تسلّل نعيم بن مسعود إلى التحالف وأوقع الحلفاء ببعضهم. أرسل الله ريحاً باردة دمّرت معسكراتهم. أمر أبو سفيان بالانسحاب. أكبر جيش جمعته الجزيرة — كسره خندق وجاسوس وريح. "وَكَفَى بِاللَّهِ وَكِيلًا." (33:3)',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_4_7',
    era: JourneyEra.medina,
    globalOrder: 29,
    latitude: 21.4861, longitude: 39.8374,
    year: 628,
    yearAH: 6,
    title: 'Treaty of Hudaybiyyah',
    titleAr: 'صلح الحديبية',
    location: 'Hudaybiyyah (near Mecca)',
    locationAr: 'الحديبية (قرب مكة المكرمة)',
    narrative:
        'You walk with 1,400 Muslims toward Mecca. No weapons — only travelers\' swords. The Prophet ﷺ has come for Umrah, not war. But the Quraysh have blocked the way.\n\n'
        'Negotiations. The Prophet ﷺ sends Uthman into Mecca as his representative. A rumor spreads: Uthman has been killed. Under a tree, the Prophet ﷺ takes a pledge from every companion present — each swearing to stand firm unto death. This is the Pledge of Ridwan. The Quran will honor it: "Allah was pleased with the believers when they pledged to you under the tree." (48:18)\n\n'
        'The treaty is signed. The terms seem harsh: go home this year without Umrah. A ten-year truce. Umar is deeply troubled: "Why do we accept humiliation in our religion?" The Prophet ﷺ says nothing he does not need to. He is certain. Within two years, thousands will convert — including Khalid ibn al-Walid and Amr ibn al-As. The Quran calls Hudaybiyyah "a clear victory." (48:1) The sword was put down. And Islam spoke for itself.',
    narrativeAr:
        'تمشي مع 1,400 مسلم نحو مكة. لا سلاح — فقط سيوف المسافرين. النبي ﷺ جاء لأداء العمرة، لا للحرب. لكن قريشاً سدّت الطريق.\n\n'
        'مفاوضات. النبي ﷺ يرسل عثمان إلى مكة ممثلاً له. تنتشر شائعة: عثمان قُتل. تحت شجرة، يأخذ النبي ﷺ بيعة من كل صحابي حاضر — يقسم كلٌّ على الثبات حتى الموت. هذه بيعة الرضوان. القرآن سيكرّمها: "لَّقَدْ رَضِيَ اللَّهُ عَنِ الْمُؤْمِنِينَ إِذْ يُبَايِعُونَكَ تَحْتَ الشَّجَرَةِ." (48:18)\n\n'
        'المعاهدة تُوقَّع. الشروط تبدو قاسية: عودوا هذا العام دون عمرة. هدنة عشر سنوات. عمر مضطرب جداً: "لمَ نقبل الضيم في ديننا؟" النبي ﷺ لا يقول إلا ما يلزم. هو على يقين. في غضون عامين، سيسلم آلاف — منهم خالد بن الوليد وعمرو بن العاص. القرآن يسمّي الحديبية "فتحاً مبيناً." (48:1) وُضع السيف. وتكلّم الإسلام عن نفسه.',
    source: 'Sahih Bukhari 2731 — Treaty of Hudaybiyyah; Quran 48:1-18',
    xpReward: 40,
    questions: [
      JourneyQuestion(
        id: 'q_1_4_7_a',
        question: 'The treaty terms look like a defeat. No Umrah this year. The companions are shaken. Umar questions it openly. Where does your gaze settle?',
        questionAr: 'شروط المعاهدة تبدو كهزيمة. لا عمرة هذا العام. الصحابة مضطربون. عمر يعترض علناً. أين يستقر نظرك؟',
        options: [
          'On Umar\'s visible distress — he is rarely wrong, and his concern weighs on you',
          'On the Prophet ﷺ — who signs without hesitation, without explaining himself',
          'On the Pledge of Ridwan — where 1,400 swore under a tree to stand firm unto death',
        ],
        optionsAr: [
          'على اضطراب عمر الواضح — نادراً ما يخطئ، وقلقه يثقل عليك',
          'على النبي ﷺ — الذي يوقّع دون تردد، دون أن يفسّر لنفسه',
          'على بيعة الرضوان — حيث أقسم 1,400 تحت شجرة على الثبات حتى الموت',
        ],
        correctIndex: 1,
        explanation: 'History records: The Quran called Hudaybiyyah "a clear victory" (48:1). Within two years, Khalid ibn al-Walid and Amr ibn al-As — two of Arabia\'s greatest military minds — accepted Islam. The truce removed the war of propaganda. Islam spoke for itself. What looked like humiliation was the greatest strategic victory of the prophetic mission.',
        explanationAr: 'يسجّل التاريخ: سمّى القرآن الحديبية "فتحاً مبيناً" (48:1). في غضون عامين، أسلم خالد بن الوليد وعمرو بن العاص — اثنان من أعظم العقول العسكرية في الجزيرة. أزالت الهدنة حرب الدعايات. تكلّم الإسلام عن نفسه. ما بدا إذلالاً كان أعظم انتصار استراتيجي في الرسالة النبوية.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_4_8',
    era: JourneyEra.medina,
    globalOrder: 30,
    latitude: 24.4686, longitude: 39.6142,
    year: 628,
    yearAH: 6,
    title: 'Letters to the Kings',
    titleAr: 'الرسائل إلى الملوك',
    location: 'Medina',
    locationAr: 'المدينة المنورة',
    narrative:
        'You watch a rider mount his horse outside the Prophet\'s Mosque, a sealed letter in his saddlebag. He is heading north — toward the court of Heraclius, Emperor of Byzantium. Another rider heads east — toward Khosrow II, Emperor of Persia. Others ride toward Abyssinia, Egypt, Bahrain, Oman, Yemen. Each carries the same message: "Embrace Islam and be safe. If you refuse, the sin of your subjects falls upon you."\n\n'
        'The message has gone global. This is no longer a movement within Arabia — it is a message for all of humanity. The Quran said it from the beginning: "And We have not sent you except as a mercy for all the worlds." (21:107)\n\n'
        'You will hear the results later. Heraclius will read the letter carefully, question Abu Sufyan at length, and conclude: "If what you say is true, he will rule the ground beneath my feet." He will be unable to act. Khosrow will tear the letter up — and be torn apart by his own son shortly after. The Negus will accept. The ruler of Bahrain will accept. Truth has no borders.',
    narrativeAr:
        'تشاهد فارساً يمتطي حصانه خارج المسجد النبوي، رسالة مختومة في حقيبته. يتجه شمالاً — نحو بلاط هرقل، إمبراطور الروم. فارس آخر يتجه شرقاً — نحو كسرى الثاني، إمبراطور فارس. آخرون يركبون نحو الحبشة ومصر والبحرين وعُمان واليمن. كلٌّ يحمل الرسالة ذاتها: "أسلِم تَسلَم. وإن أبيت فعليك إثم رعيتك."\n\n'
        'الرسالة أصبحت عالمية. لم تعد حركة داخل الجزيرة — إنها رسالة لكل البشرية. القرآن قالها من البداية: "وَمَا أَرْسَلْنَاكَ إِلَّا رَحْمَةً لِّلْعَالَمِينَ." (21:107)\n\n'
        'ستسمع النتائج لاحقاً. هرقل سيقرأ الرسالة بتمعّن، ويستجوب أبا سفيان مطوّلاً، ويخلص إلى: "إن كان ما قلته حقاً، فسيملك الأرض التي تحت قدميّ." لن يستطيع التصرف. كسرى سيمزّق الرسالة — ويُمزَّق هو على يد ابنه بعد قليل. النجاشي سيسلم. حاكم البحرين سيسلم. الحق لا يعرف حدوداً.',
    source: 'Sahih Bukhari 7 — Heraclius and the letter; authenticated in Seerah collections',
    xpReward: 35,
    questions: [
      JourneyQuestion(
        id: 'q_1_4_8_a',
        question: 'Riders carry sealed letters toward the courts of empires. The message: "Embrace Islam and be safe." Where does your gaze settle?',
        questionAr: 'فرسان يحملون رسائل مختومة نحو بلاطات الإمبراطوريات. الرسالة: "أسلِم تَسلَم." أين يستقر نظرك؟',
        options: [
          'On the riders disappearing into the horizon — where no Muslim has gone on this mission before',
          'On the letter itself — simple words carrying the weight of a global message',
          'On the Prophet ﷺ watching from the mosque — certain that this message will outlast every empire it reaches',
        ],
        optionsAr: [
          'على الفرسان المختفين في الأفق — حيث لم يذهب مسلم من قبل في هذه المهمة',
          'على الرسالة ذاتها — كلمات بسيطة تحمل ثقل رسالة عالمية',
          'على النبي ﷺ يراقب من المسجد — واثقاً أن هذه الرسالة ستبقى بعد كل إمبراطورية تصلها',
        ],
        correctIndex: 2,
        explanation: 'History records: Heraclius concluded the truth but could not act. Khosrow tore the letter and was himself destroyed. The Negus and the ruler of Bahrain accepted Islam. Every empire those letters reached has since fallen. The message remains. "And We have not sent you except as a mercy for all the worlds." (21:107)',
        explanationAr: 'يسجّل التاريخ: هرقل أدرك الحق لكنه لم يستطع التصرف. كسرى مزّق الرسالة فدُمّر هو نفسه. النجاشي وحاكم البحرين أسلما. كل إمبراطورية وصلتها تلك الرسائل سقطت منذ ذلك الحين. الرسالة باقية. "وَمَا أَرْسَلْنَاكَ إِلَّا رَحْمَةً لِّلْعَالَمِينَ." (21:107)',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_4_9',
    era: JourneyEra.medina,
    globalOrder: 31,
    latitude: 21.4225, longitude: 39.8262,
    year: 630,
    yearAH: 8,
    title: 'The Conquest of Mecca',
    titleAr: 'فتح مكة',
    location: 'Mecca',
    locationAr: 'مكة المكرمة',
    narrative:
        'Ten thousand Muslims enter Mecca from four directions. The operation was so secret that the city had almost no time to prepare. Abu Sufyan — brought before the Prophet ﷺ the night before — has embraced Islam and announced: "Whoever enters the house of Abu Sufyan is safe. Whoever closes their door is safe. Whoever enters the Masjid al-Haram is safe."\n\n'
        'You walk behind the Prophet ﷺ as he enters the city. His head is bowed — not in triumph, but in humility. He recites Surah Al-Fath. The same streets that threw dirt at him. The same city that boycotted his family for three years. The same people who drove him out and tried to kill him.\n\n'
        'He reaches the Ka\'bah. He takes his staff and strikes down the 360 idols, one after another. "Truth has come, and falsehood has departed. Indeed, falsehood is bound to depart." (17:81) Then he stands at the Ka\'bah door and faces the people of Mecca — the same people who tortured his followers, killed his family, and exiled his community. "O people of Quraysh — what do you think I will do to you?" They say: "A noble brother, son of a noble brother." He replies: "Go — you are free."',
    narrativeAr:
        'عشرة آلاف مسلم يدخلون مكة من أربع جهات. كانت العملية سرية لدرجة أن المدينة بالكاد وجدت وقتاً للاستعداد. أبو سفيان — الذي أُحضر أمام النبي ﷺ الليلة السابقة — أسلم وأعلن: "من دخل دار أبي سفيان فهو آمن. ومن أغلق بابه فهو آمن. ومن دخل المسجد الحرام فهو آمن."\n\n'
        'تمشي خلف النبي ﷺ وهو يدخل المدينة. رأسه مطأطأ — لا في انتصار، بل في تواضع. يتلو سورة الفتح. الشوارع ذاتها التي ألقت عليه التراب. المدينة ذاتها التي حاصرت عائلته ثلاث سنوات. الناس أنفسهم الذين طردوه وحاولوا قتله.\n\n'
        'يصل إلى الكعبة. يأخذ عصاه ويحطّم الأصنام الـ360، واحداً تلو الآخر. "جَاءَ الْحَقُّ وَزَهَقَ الْبَاطِلُ إِنَّ الْبَاطِلَ كَانَ زَهُوقًا." (17:81) ثم يقف عند باب الكعبة ويواجه أهل مكة — الناس أنفسهم الذين عذّبوا أتباعه، وقتلوا من عائلته، ونفوا مجتمعه. "يا معشر قريش — ما تظنون أني فاعل بكم؟" يقولون: "أخ كريم وابن أخ كريم." يقول: "اذهبوا — فأنتم الطلقاء."',
    source: 'Sahih Bukhari 4280 — Conquest of Mecca; Quran 48:1',
    xpReward: 60,
    questions: [
      JourneyQuestion(
        id: 'q_1_4_9_a',
        question: '10,000 Muslims enter Mecca. The city falls without battle. The Prophet ﷺ approaches the Ka\'bah. What do you do?',
        questionAr: '10,000 مسلم يدخلون مكة. المدينة تسقط دون قتال. النبي ﷺ يقترب من الكعبة. ماذا تفعل؟',
        options: [
          'Walk beside him — you have waited years for this moment',
          'Stop and kneel where you stand — gratitude overwhelms you before your legs can carry you further',
          'Look back at the streets of Mecca — remembering what they did, seeing what is happening now',
        ],
        optionsAr: [
          'تمشي بجانبه — انتظرت سنوات لهذه اللحظة',
          'تتوقف وتركع حيث أنت — الامتنان يغمرك قبل أن تحملك قدماك أبعد',
          'تنظر خلفك إلى شوارع مكة — تتذكر ما فعلوا، وترى ما يحدث الآن',
        ],
        correctIndex: 1,
        explanation: 'History records: The Prophet ﷺ entered with his head bowed in humility, reciting Surah Al-Fath. He destroyed 360 idols. Then he stood at the Ka\'bah door and said to those who had persecuted him for twenty years: "Go — you are free." This is what mercy looks like at its highest. This is what power looks like in the hands of a prophet.',
        explanationAr: 'يسجّل التاريخ: دخل النبي ﷺ ورأسه مطأطأ تواضعاً، يتلو سورة الفتح. حطّم 360 صنماً. ثم وقف عند باب الكعبة وقال لمن اضطهدوه عشرين عاماً: "اذهبوا — فأنتم الطلقاء." هكذا تبدو الرحمة في أعلاها. هكذا تبدو القوة في يد نبيّ.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_4_10',
    era: JourneyEra.medina,
    globalOrder: 32,
    latitude: 21.4225, longitude: 39.8262,
    year: 630,
    yearAH: 8,
    title: 'The Battle of Hunayn',
    titleAr: 'غزوة حنين',
    location: 'Hunayn Valley, near Mecca',
    locationAr: 'وادي حنين، قرب مكة المكرمة',
    narrative:
        'Days after the conquest, a new threat. The tribes of Hawazin and Thaqif have assembled a massive force in the valley of Hunayn. You march with 12,000 Muslims — the largest army the Prophet ﷺ has ever led. Some say: "We cannot be defeated today — look at our numbers."\n\n'
        'The narrow valley. The ambush. Arrows rain from the hills. The massive army — your army — breaks. Men flee in every direction. In the chaos, you are swept along. Then you hear a voice from the center of the storm: "O people — I am here. I am the Prophet of Allah, the son of Abd al-Muttalib!"\n\n'
        'You turn. A handful of companions surround the Prophet ﷺ. He has not moved. He is calling people back — not with an army, but with his voice. You run toward him. Others follow. The tide turns. The battle is won. The Quran will record: "On the day of Hunayn, when your great numbers pleased you — then it availed you nothing." (9:25) Numbers do not win. Turning back toward truth does.',
    narrativeAr:
        'أيام بعد الفتح، تهديد جديد. قبيلتا هوازن وثقيف جمعتا قوة ضخمة في وادي حني��. تزحف مع 12,000 مسلم — أكبر جيش قاده النبي ﷺ. بعضهم يقول: "لن نُهزم اليوم — انظروا إلى أعدادنا."\n\n'
        'الوادي الضيق. الكمين. السهام تنهمر من التلال. الجيش الضخم — جيشك — ينكسر. رجال يفرّون في كل اتجاه. في الفوضى، تُجرف معهم. ثم تسمع صوتاً من قلب العاصفة: "أيها الناس — أنا هنا. أنا نبي الله ابن عبد المطلب!"\n\n'
        'تلتفت. حفنة من الصحابة يحيطون بالنبي ﷺ. لم يتحرك. ينادي الناس للعودة — لا بجيش، بل بصوته. تركض نحوه. آخرون يتبعون. يتحول المد. المعركة تُحسم. القرآن سيسجّل: "وَيَوْمَ حُنَيْنٍ إِذْ أَعْجَبَتْكُمْ كَثْرَتُكُمْ فَلَمْ تُغْنِ عَنكُمْ شَيْئًا." (9:25) الأعداد لا تنتصر. العودة نحو الحق هي التي تنتصر.',
    source: 'Sahih Bukhari 4317 — Battle of Hunayn; Quran 9:25-26',
    xpReward: 40,
    questions: [
      JourneyQuestion(
        id: 'q_1_4_10_a',
        question: 'Ambushed in the narrow valley. The army is in chaos. You are swept along with those fleeing. Then you hear the Prophet\'s ﷺ voice: "I am here." What do you do?',
        questionAr: 'كمين في الوادي الضيق. الجيش في فوضى. تُجرف مع الفارّين. ثم تسمع صوت النبي ﷺ: "أنا هنا." ماذا تفعل؟',
        options: [
          'Keep running — the situation is lost and survival comes first',
          'Turn back toward the voice — if he has not moved, neither will you',
          'Freeze where you stand — unable to choose between fear and faith',
        ],
        optionsAr: [
          'تواصل الفرار — الموقف ضائع والنجاة أولاً',
          'تعود نحو الصوت — إن لم يتحرك هو، لن تتحرك أنت',
          'تتجمّد مكانك — عاجز عن الاختيار بين الخوف والإيمان',
        ],
        correctIndex: 1,
        explanation: 'History records: A handful turned back toward the voice. Then others followed. Then more. The battle turned. "On the day of Hunayn, when your great numbers pleased you — then it availed you nothing." (9:25) Numbers do not win. Turning back toward truth does.',
        explanationAr: 'يسجّل التاريخ: حفنة عادت نحو الصوت. ثم تبعهم آخرون. ثم أكثر. تحوّل المد. "وَيَوْمَ حُنَيْنٍ إِذْ أَعْجَبَتْكُمْ كَثْرَتُكُمْ فَلَمْ تُغْنِ عَنكُمْ شَيْئًا." (9:25) الأعداد لا تنتصر. العودة نحو الحق هي التي تنتصر.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_4_11',
    era: JourneyEra.medina,
    globalOrder: 33,
    latitude: 29.3697, longitude: 34.8060,
    year: 630,
    yearAH: 9,
    title: 'The Expedition to Tabuk',
    titleAr: 'غزوة تبوك',
    location: 'Tabuk (northern Arabia)',
    locationAr: 'تبوك (شمال الجزيرة العربية)',
    narrative:
        'The height of summer. The harvest is ripe. The heat is brutal. And the Prophet ﷺ has called for a march — 700 kilometers north — to face the Byzantine Empire. This is the hardest call he has ever made on his community.\n\n'
        'You watch the companions respond. Uthman ibn Affan donates an enormous sum to equip the army. Abu Bakr brings everything he owns — every dirham, every piece of cloth. Umar brings half. The Prophet ﷺ asks Abu Bakr: "What did you leave for your family?" He replies: "Allah and His Messenger." Then a man approaches with a single date — the only thing he has. The Prophet ﷺ accepts it with the same dignity he accepted Uthman\'s fortune.\n\n'
        'The army marches 700 km to Tabuk. The Byzantine force never appears. The Prophet ﷺ remains twenty days, signing agreements with local tribes. The expedition proves the reach and resolve of the Muslim state. It is the last major expedition of his life. And the smallest donation — the single date — will be remembered as long as the greatest.',
    narrativeAr:
        'ذروة الصيف. المحصول نضج. الحر لاهب. والنبي ﷺ دعا إلى مسيرة — 700 كيلومتر شمالاً — لمواجهة الإمبراطورية البيزنطية. هذا أصعب نداء أطلقه في حياة مجتمعه.\n\n'
        'تشاهد الصحابة يستجيبون. عثمان بن عفان يتبرع بمبلغ هائل لتجهيز الجيش. أبو بكر يأتي بكل ما يملك — كل درهم، كل قطعة قماش. عمر يأتي بالنصف. يسأل النبي ﷺ أبا بكر: "ماذا أبقيت لأهلك؟" يجيب: "الله ورسوله." ثم يأتي رجل بتمرة واحدة — الشيء الوحيد الذي يملكه. يقبلها النبي ﷺ بالكرامة ذاتها التي قبل بها ثروة عثمان.\n\n'
        'الجيش يزحف 700 كيلومتر إلى تبوك. الجيش البيزنطي لا يظهر. يمكث النبي ﷺ عشرين يوماً، يوقّع اتفاقيات مع القبائل المحلية. الحملة تُثبت مدى الدولة المسلمة وعزمها. إنها آخر حملة كبرى في حياته. وأصغر تبرع — التمرة الواحدة — سيُذكر كما يُذكر أعظمها.',
    source: 'Sahih Bukhari 4416 — Expedition of Tabuk; Quran 9:38-42',
    xpReward: 40,
    questions: [
      JourneyQuestion(
        id: 'q_1_4_11_a',
        question: 'The height of summer. The march to Tabuk is 700 km. Abu Bakr has given everything. A man offers a single date. Where does your gaze settle?',
        questionAr: 'ذروة الصيف. المسيرة إلى تبوك 700 كم. أبو بكر أعطى كل شيء. رجل يقدّم تمرة واحدة. أين يستقر نظرك؟',
        options: [
          'On the faces of those who stayed behind in Medina — the weight of their absence',
          'On Abu Bakr walking with nothing but his trust in Allah',
          'On the Prophet ﷺ accepting the single date with the same dignity as Uthman\'s fortune',
        ],
        optionsAr: [
          'على وجوه من تخلّفوا في المدينة — ثقل غيابهم',
          'على أبي بكر الذي يمشي بلا شيء سوى توكله على الله',
          'على النبي ﷺ يقبل التمرة الواحدة بالكرامة ذاتها التي قبل بها ثروة عثمان',
        ],
        correctIndex: 2,
        explanation: 'History records: He accepted the smallest gift as if it were equal to the greatest fortune. The Byzantine army never appeared. The expedition demonstrated the reach of the Muslim state. It was the last major campaign of his life. The single date will be remembered as long as Uthman\'s gold.',
        explanationAr: 'يسجّل التاريخ: قبل أصغر هبة وكأنها تساوي أعظم ثروة. الجيش البيزنطي لم يظهر. أثبتت الحملة مدى الدولة المسلمة. كانت آخر حملة كبرى في حياته. التمرة الواحدة ستُذكر كما يُذكر ذهب عثمان.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_4_12',
    era: JourneyEra.medina,
    globalOrder: 34,
    latitude: 24.4686, longitude: 39.6142,
    year: 631,
    yearAH: 9,
    title: 'Year of Delegations',
    titleAr: 'عام الوفود',
    location: 'Medina',
    locationAr: 'المدينة المنورة',
    narrative:
        'They come from every corner of the peninsula. You stand in the Prophet\'s Mosque and watch delegation after delegation arrive — from Yemen, from Bahrain, from Oman, from the far north. Tribe after tribe. Leaders you have never seen before, speaking dialects you barely understand, all saying the same thing: "We have come to accept Islam."\n\n'
        'The Quran captures this moment: "When the victory of Allah has come and the conquest, and you see the people entering into the religion of Allah in multitudes..." (110:1-2) You see the Prophet ﷺ receive each delegation with the same care — listening to their leaders, teaching them the fundamentals, sending teachers back with them.\n\n'
        'Within a decade of the first public call at Mount Safa, the entire Arabian Peninsula has embraced Islam. What seemed impossible — a persecuted minority hiding behind a closed door — has become the governing principle of a civilization. You remember that small room in Mecca where a handful of people gathered in secret. And now — this.',
    narrativeAr:
        'يأتون من كل أطراف الجزيرة. تقف في المسجد النبوي وتشاهد وفداً تلو وفد يصل — من اليمن، من البحرين، من عُمان، من الشمال البعيد. قبيلة بعد قبيلة. زعماء لم ترهم من قبل، يتحدثون بلهجات بالكاد تفهمها، كلهم يقولون الشيء ذاته: "جئنا لنسلم."\n\n'
        'القرآن يرصد هذه اللحظة: "إِذَا جَاءَ نَصْرُ اللَّهِ وَالْفَتْحُ وَرَأَيْتَ النَّاسَ يَدْخُلُونَ فِي دِينِ اللَّهِ أَفْوَاجًا..." (110:1-2) ترى النبي ﷺ يستقبل كل وفد بالعناية ذاتها — يصغي لزعمائهم، يعلّمهم الأسس، يرسل معهم معلمين.\n\n'
        'في غضون عقد من أول نداء علني على جبل الصفا، اعتنق الإسلام كامل شبه الجزيرة العربية. ما بدا مستحيلاً — أقلية مضطهدة تختبئ خلف باب مغلق — أصبح المبدأ الحاكم لحضارة. تتذكر تلك الغرفة الصغيرة في مكة حيث تجمّع حفنة من الناس سراً. والآن — هذا.',
    source: 'Quran 110:1-3 — Surah Al-Nasr; Sahih Bukhari 4966',
    xpReward: 35,
    questions: [
      JourneyQuestion(
        id: 'q_1_4_12_a',
        question: 'Tribe after tribe arrives at the Prophet\'s Mosque to declare their faith. The year they call Aam al-Wufud. Where does your gaze settle?',
        questionAr: 'قبيلة بعد قبيلة تصل المسجد النبوي لتعلن إيمانها. العام الذي يسمّونه عام الوفود. أين يستقر نظرك؟',
        options: [
          'On the sheer number — people you never imagined would come, from lands you have never visited',
          'On the Prophet ﷺ — receiving each delegation with the same attention and care as the first',
          'On the Quran being recited in voices and accents you have never heard before',
        ],
        optionsAr: [
          'على العدد المهول — أناس لم تتخيّل قدومهم، من أراضٍ لم تزرها',
          'على النبي ﷺ — يستقبل كل وفد بالعناية والاهتمام ذاتهما كالأول',
          'على القرآن يُتلى بأصوات ولهجات لم تسمعها من قبل',
        ],
        correctIndex: 1,
        explanation: 'History records: He listened to each leader. He taught them. He sent teachers back with them. The entire Arabian Peninsula embraced Islam within a decade of the first public call. What seemed impossible — a handful of believers in a secret room — had become the governing principle of a civilization.',
        explanationAr: 'يسجّل التاريخ: أصغى لكل زعيم. علّمهم. أرسل معهم معلمين. اعتنق الإسلام كامل شبه الجزيرة العربية في غضون عقد من أول نداء علني. ما بدا مستحيلاً — حفنة من المؤمنين في غرفة سرية — أصبح المبدأ الحاكم لحضارة.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_4_13',
    era: JourneyEra.medina,
    globalOrder: 35,
    latitude: 21.4225, longitude: 39.8262,
    year: 632,
    yearAH: 10,
    title: 'The Farewell Pilgrimage',
    titleAr: 'حجة الوداع',
    location: 'Mecca — Arafat — Mina',
    locationAr: 'مكة — عرفات — منى',
    narrative:
        'One hundred thousand companions stand on the plain of Arafat. You are among them. The 9th of Dhul-Hijjah. The Prophet ﷺ sits on his camel and delivers the last great sermon of his life.\n\n'
        '"O people, listen to me carefully, for I do not know if I will meet you again after this year in this place." You feel the weight of those words before you understand them. He speaks of the sanctity of life, property, and honor. He abolishes all debts of the pre-Islamic era. He declares: "An Arab has no superiority over a non-Arab, nor a non-Arab over an Arab; nor does a white person over a black person, nor a black person over a white — except through piety and good deeds."\n\n'
        'Then the sky opens. The last verse descends: "Today I have perfected your religion for you and completed My favor upon you." (5:3) The companions around you weep. They know. The mission is complete. Twenty-three years — from a cave on a mountain to this plain where a hundred thousand stand in white. The Prophet ﷺ is preparing to depart.',
    narrativeAr:
        'مئة ألف صحابي يقفون على صعيد عرفات. أنت بينهم. التاسع من ذي الحجة. النبي ﷺ على ناقته يُلقي آخر خطبة عظيمة في حياته.\n\n'
        '"أيها الناس، اسمعوا مني بيان، فإني لا أدري لعلي لا ألقاكم بعد عامي هذا في هذا الموقف." تحسّ بثقل تلك الكلمات قبل أن تفهمها. يتحدث عن حرمة الدماء والأموال والأعراض. يُلغي كل ديون الجاهلية. يعلن: "لا فضل لعربي على أعجمي ولا لأعجمي على عربي ولا لأحمر على أسود ولا لأسود على أحمر — إلا بالتقوى والعمل الصالح."\n\n'
        'ثم تنفتح السماء. تنزل آخر آية: "الْيَوْمَ أَكْمَلْتُ لَكُمْ دِينَكُمْ وَأَتْمَمْتُ عَلَيْكُمْ نِعْمَتِي." (5:3) الصحابة من حولك يبكون. يعلمون. اكتملت الرسالة. ثلاثة وعشرون عاماً — من كهف على جبل إلى هذا السهل حيث مئة ألف يقفون في البياض. النبي ﷺ يستعد للرحيل.',
    source: 'Sahih Bukhari 1623 — Farewell Hajj; Quran 5:3',
    xpReward: 60,
    questions: [
      JourneyQuestion(
        id: 'q_1_4_13_a',
        question: '100,000 companions stand on Arafat. The Prophet ﷺ delivers his final sermon. He says: "I may not meet you here again." Where does your gaze settle?',
        questionAr: '100,000 صحابي يقفون في عرفات. النبي ﷺ يُلقي خطبته الأخيرة. يقول: "لعلي لا ألقاكم بعد عامي هذا." أين يستقر نظرك؟',
        options: [
          'On the vast crowd stretching to the horizon — you have never seen this many people in one place',
          'On the Prophet ﷺ — who seems to be saying goodbye, though he has not used the word',
          'On the sky — waiting, as if the final verse is about to descend',
        ],
        optionsAr: [
          'على الحشد الممتد إلى الأفق — لم ترَ هذا العدد في مكان واحد من قبل',
          'على النبي ﷺ — الذي يبدو أنه يودّع، وإن لم ينطق بالكلمة',
          'على السماء — تنتظر، كأن الآية الأخيرة على وشك أن تنزل',
        ],
        correctIndex: 1,
        explanation: 'History records: "Today I have perfected your religion for you and completed My favor upon you." (5:3) The companions wept — they knew what "perfected" meant. The mission was complete. The Prophet ﷺ had delivered the message. What remained was the departure.',
        explanationAr: 'يسجّل التاريخ: "الْيَوْمَ أَكْمَلْتُ لَكُمْ دِينَكُمْ وَأَتْمَمْتُ عَلَيْكُمْ نِعْمَتِي." (5:3) بكى الصحابة — عرفوا ماذا تعني "أكملت". اكتملت الرسالة. بلّغ النبي ﷺ الأمانة. ما تبقى هو الرحيل.',
      ),
    ],
  ),

  JourneyEvent(
    id: 'j_1_4_14',
    era: JourneyEra.medina,
    globalOrder: 36,
    latitude: 24.4686, longitude: 39.6142,
    year: 632,
    yearAH: 11,
    title: 'The Final Illness and Departure',
    titleAr: 'المرض الأخير والرحيل',
    location: 'Medina',
    locationAr: 'المدينة المنورة',
    narrative:
        'It is the morning of Monday, the 12th of Rabi\' al-Awwal, 11 AH. You are in the mosque. Abu Bakr is leading the Fajr prayer. The rows are straight. The voices are steady.\n\n'
        'Then the curtain of Aisha\'s room lifts. The Prophet ﷺ stands there — his face lit with a smile. He looks at the rows of worshippers — the community he built from nothing, praying in the mosque he built with his own hands. You see his face and something in your chest breaks open. He smiles. Then the curtain falls.\n\n'
        'He returns to his bed. With his head in Aisha\'s lap, he raises his hand toward the ceiling and speaks his final words: "Bel al-rafiq al-a\'la... al-rafiq al-a\'la..." — "No — the highest companion. The highest companion." He chooses the company of Allah over remaining in the world. His hand falls. The news breaks on Medina like nothing before it. Umar stands in the street refusing to believe. It is Abu Bakr who steadies the world: "Whoever worshipped Muhammad, know that Muhammad has died. And whoever worshipped Allah, know that Allah is living and will never die."',
    narrativeAr:
        'إنه صباح الاثنين، الثاني عشر من ربيع الأول، 11 هـ. أنت في المسجد. أبو بكر يؤم صلاة الفجر. الصفوف مستقيمة. الأصوات ثابتة.\n\n'
        'ثم يُرفع ستار حجرة عائشة. النبي ﷺ يقف هناك — وجهه مُضاء بابتسامة. ينظر إلى صفوف المصلين — المجتمع الذي بناه من لا شيء، يصلّون في المسجد الذي بناه بيديه. ترى وجهه وشيء في صدرك ينفتح. يبتسم. ثم يسقط الستار.\n\n'
        'يعود إلى فراشه. رأسه في حجر عائشة، يرفع يده نحو السقف وينطق كلماته الأخيرة: "بل الرفيق الأعلى... الرفيق الأعلى..." يختار صحبة الله على البقاء في الدنيا. تسقط يده. ينهمر الخبر على المدينة كما لم ينهمر خبر من قبل. عمر يقف في الشارع يرفض التصديق. أبو بكر هو من يثبّت العالم: "من كان يعبد محمداً فإن محمداً قد مات. ومن كان يعبد الله فإن الله حيٌّ لا يموت."',
    source: 'Sahih Bukhari 4462 — death of the Prophet ﷺ; Sahih Muslim 2444',
    xpReward: 60,
    questions: [
      JourneyQuestion(
        id: 'q_1_4_14_a',
        question: 'The morning of the 12th of Rabi\' al-Awwal. Abu Bakr leads Fajr. The curtain lifts. The Prophet ﷺ smiles at the rows of worshippers. Where does your gaze settle?',
        questionAr: 'صباح الثاني عشر من ربيع الأول. أبو بكر يؤم الفجر. يُرفع الستار. النبي ﷺ يبتسم لصفوف المصلين. أين يستقر نظرك؟',
        options: [
          'On the rows of worshippers — who do not yet know this is the last time',
          'On the Prophet\'s ﷺ face — the smile of a man who has given everything and is at peace',
          'On Abu Bakr — who will carry what comes next, though he does not know it yet',
        ],
        optionsAr: [
          'على صفوف المصلين — الذين لا يعلمون بعد أن هذه المرة الأخيرة',
          'على وجه النبي ﷺ — ابتسامة رجل أعطى كل شيء وهو في سلام',
          'على أبي بكر — الذي سيحمل ما سيأتي بعد ذلك، وإن لم يعلم بعد',
        ],
        correctIndex: 1,
        explanation: 'History records: He smiled, returned to his room, and chose "the highest companion." His final words: "Bel al-rafiq al-a\'la." Umar refused to believe. Abu Bakr steadied the Ummah with the most important words ever spoken after the Prophet ﷺ: "Whoever worshipped Muhammad, know that Muhammad has died. And whoever worshipped Allah, know that Allah is living and will never die."',
        explanationAr: 'يسجّل التاريخ: ابتسم، عاد إلى غرفته، واختار "الرفيق الأعلى." كلماته الأخيرة: "بل الرفيق الأعلى." عمر رفض التصديق. أبو بكر ثبّت الأمة بأهم كلمات قيلت بعد النبي ﷺ: "من كان يعبد محمداً فإن محمداً قد مات. ومن كان يعبد الله فإن الله حيٌّ لا يموت."',
      ),
    ],
  ),

]; // end m1Events

/// Total number of events in the current module.
final int m1EventCount = m1Events.length;
