import 'dart:ui';
import '../models/scene_config.dart';
import '../widgets/cinematic/parallax_scene.dart';

/// Shared hub layers for Mecca events, single scene image.
const _meccaHubLayers = <ParallaxLayer>[
  ParallaxLayer(
    assetPath: 'assets/scenes/scene_event1_kaabah.jpg',
    speed: 0.15,
    verticalPosition: 0.0,
    heightFraction: 1.0,
  ),
];

/// Scene configurations keyed by event ID.
final Map<String, SceneConfig> sceneConfigs = {
  // ── Event 1: Arabia Before the Light ──────────────────────────────────────
  'j_1_1_1': SceneConfig(
    hubLayers: _meccaHubLayers,
    groundLayers: const [
      ParallaxLayer(
        assetPath: 'assets/scenes/scene_event1_kaabah.jpg',
        speed: 0.15,
        verticalPosition: 0.0,
        heightFraction: 1.0,
      ),
    ],
    hotspots: const [
      SceneHotspot(
        id: 'kaabah',
        x: 0.50, y: 0.62,
        icon: '🕋',
        label: 'The Ka\'bah',
        labelAr: 'الكعبة',
        fragment: 'The Ka\'bah stands, built by Ibrahim \uFDFA and his son Ismail \uFDFA as a house of the One God. That memory lingers in the stones, even as 360 idols press against them from every side. Something is coming. You can feel it in the desert wind.',
        fragmentAr: 'الكعبة لا تزال قائمة كما بناها إبراهيم \uFDFA وابنه إسماعيل \uFDFA بيتاً للإله الواحد، وتلك الذكرى حيّة في الحجارة وإن تزاحمت 360 صنماً حولها من كل جانب. شيء ما قادم تحسّه في ريح الصحراء.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        imagePath: 'assets/scenes/bubble_kaabah.jpg',
        ambientPath: 'assets/audio/ambient/ambient_e1_kaabah.mp3',
        sourceRef: 'Quran 2:127 | Al-Raheeq Al-Makhtum, Ch. 1',
        sourceRefAr: 'القرآن 2:127 | الرحيق المختوم، الفصل 1',
        didYouKnow: 'The Ka\'bah was originally built by Ibrahim ﷺ and his son Ismail ﷺ as a house of pure monotheism, with no roof, open to the sky.',
        didYouKnowAr: 'الكعبة بناها إبراهيم ﷺ وابنه إسماعيل ﷺ أصلاً بيتاً للتوحيد الخالص بلا سقف ومفتوحة على السماء.',
      ),
      SceneHotspot(
        id: 'idols',
        x: 0.25, y: 0.45,
        icon: '🗿',
        label: 'The Idol Shrines',
        labelAr: 'معابد الأصنام',
        fragment: 'Three hundred and sixty stone figures watch you with empty eyes. The air is thick with incense smoke drifting from the shrines that crowd around the ancient house. Each tribe has placed its god here, as if proximity to the Ka\'bah could grant them truth.',
        fragmentAr: 'ثلاثمئة وستون تمثالاً حجرياً يحدّقون بعيون فارغة والهواء ثقيل بدخان البخور المتصاعد من المعابد المتراصة حول البيت العتيق. كل قبيلة وضعت إلهها هنا وكأن القرب من الكعبة يمنحهم حقيقة لا يملكونها.',
        sfxPath: 'assets/audio/sfx_idols_incense.wav',
        imagePath: 'assets/scenes/bubble_idols.jpg',
        ambientPath: 'assets/audio/ambient/ambient_e1_idols.mp3',
        sourceRef: 'Al-Raheeq Al-Makhtum, Ch. 2',
        sourceRefAr: 'الرحيق المختوم، الفصل 2',
      ),
      SceneHotspot(
        id: 'poet',
        x: 0.50, y: 0.30,
        icon: '📜',
        label: 'The Poet',
        labelAr: 'الشاعر',
        fragment: 'A poet recites verses of breathtaking beauty about honor and courage, while a few streets away, a man buries his newborn daughter in the sand without a word. The world moves in contradictions.\n\nYou have walked through this courtyard. You have seen the wealth and the poverty, the devotion and the emptiness. Now the poet falls silent, and you are left with the question that hangs in the desert air.',
        fragmentAr: 'شاعر ينشد أبياتاً خلابة عن الشرف والشجاعة بينما على بعد أزقة قليلة رجل يدفن ابنته الوليدة في الرمال دون كلمة، فالعالم يتحرك في تناقضات لا يستطيع الشعر وحده أن يصلحها.\n\nمشيت في هذا الفناء ورأيت الثروة والفقر والعبادة والفراغ، والآن يصمت الشاعر وتبقى أنت مع السؤال المعلّق في هواء الصحراء.',
        sfxPath: 'assets/audio/sfx_poet_crowd.wav',
        imagePath: 'assets/scenes/bubble_poet.jpg',
        sourceRef: 'Al-Raheeq Al-Makhtum, Ch. 2',
        sourceRefAr: 'الرحيق المختوم، الفصل 2',
        didYouKnow: 'Pre-Islamic poets held the same status as media does today. Their verses could make or break a tribe\'s reputation across all of Arabia.',
        didYouKnowAr: 'الشعراء في الجاهلية كانوا بمنزلة الإعلام اليوم فقصائدهم كانت تصنع سمعة القبيلة أو تدمرها في أنحاء الجزيرة كلها.',
      ),
      SceneHotspot(
        id: 'merchants',
        x: 0.75, y: 0.45,
        icon: '🏺',
        label: 'The Merchants',
        labelAr: 'التجّار',
        fragment: 'Merchants haggle over silk and spices on trade routes stretching from Yemen to Syria, while the poor beg at the Ka\'bah walls, invisible to those who pass. Wealth flows, but justice does not.',
        fragmentAr: 'تجّار يساومون على الحرير والتوابل في طرق تجارية تمتد من اليمن إلى الشام بينما الفقراء يستجدون عند جدران الكعبة ولا يراهم أحد من المارّين. المال يتدفق لكن العدل لا يجد طريقه إلى أحد.',
        sfxPath: 'assets/audio/sfx_merchants_bustle.wav',
        imagePath: 'assets/scenes/bubble_merchants.jpg',
        ambientPath: 'assets/audio/ambient/ambient_e1_merchants.mp3',
        sourceRef: 'Al-Raheeq Al-Makhtum, Ch. 2',
        sourceRefAr: 'الرحيق المختوم، الفصل 2',
      ),
    ],
    // Walking path: start bottom → merchants → Ka'bah → idols → poet
    pathWaypoints: const [
      // Path A: Start → Ka'bah (GATE) → Merchants → Idols → Poet (GATHERING)
      Offset(0.50, 0.80),  // Start
      Offset(0.47, 0.72),  // Walk up-left (curve)
      Offset(0.50, 0.62),  // Ka'bah (GATE)
      Offset(0.62, 0.54),  // Turn right-up toward merchants
      Offset(0.75, 0.45),  // Merchants (PATH A)
      Offset(0.55, 0.42),  // Cross toward center
      Offset(0.35, 0.44),  // Walk left toward idols
      Offset(0.25, 0.45),  // Idols (PATH B)
      Offset(0.35, 0.38),  // Turn up toward poet
      Offset(0.50, 0.30),  // Poet (GATHERING)
    ],
    // Path B: Start → Ka'bah (GATE) → Idols → Merchants → Poet (GATHERING)
    pathWaypointsAlt: const [
      Offset(0.50, 0.80),  // Start
      Offset(0.53, 0.72),  // Walk up-right (curve)
      Offset(0.50, 0.62),  // Ka'bah (GATE)
      Offset(0.38, 0.54),  // Turn left-up toward idols
      Offset(0.25, 0.45),  // Idols (PATH B first)
      Offset(0.45, 0.42),  // Cross toward center
      Offset(0.62, 0.44),  // Walk right toward merchants
      Offset(0.75, 0.45),  // Merchants (PATH A second)
      Offset(0.65, 0.38),  // Turn up toward poet
      Offset(0.50, 0.30),  // Poet (GATHERING)
    ],
    skyGradient: const [
      Color(0xFF04060D), Color(0xFF080D1C), Color(0xFF0D1428),
      Color(0xFF111A35), Color(0xFF162040), Color(0xFF1A2845),
      Color(0xFF1E3050), Color(0xFF2A3A52), Color(0xFF3D3530),
    ],
    skyStops: const [0.0, 0.12, 0.24, 0.36, 0.48, 0.58, 0.70, 0.85, 1.0],
    showStars: false,
    showMoon: false,
    particleType: ParticleType.incenseSmoke,
    particleCount: 40,
    particleColor: const Color(0x80C9A84C),
    ambientAudioPath: 'assets/audio/ambient_desert_evening.wav',
    ambientVolume: 0.25,
    showGrain: true,
  ),

  // ── Event 2: The Year of the Elephant ─────────────────────────────────────
  'j_1_1_2': SceneConfig(
    hubLayers: _meccaHubLayers,
    groundLayers: const [
      ParallaxLayer(
        assetPath: 'assets/scenes/scene_event2_elephant.jpg',
        speed: 0.15,
        verticalPosition: 0.0,
        heightFraction: 1.0,
      ),
    ],
    hotspots: const [
      SceneHotspot(
        id: 'army',
        x: 0.45, y: 0.60,
        icon: '⚔️',
        label: 'The Army',
        labelAr: 'الجيش',
        fragment: 'The horizon to the south is dark with dust. Abraha al-Ashram, the ruler of Yemen, marches with war elephants and thousands of soldiers. His mission: destroy the Ka\'bah and redirect the Arabs\' pilgrimage to a grand church he built in San\'a.',
        fragmentAr: 'الأفق جنوباً مظلم بالغبار وأبرهة الأشرم حاكم اليمن يزحف بأفيال حرب وآلاف الجنود. مهمته واحدة: تدمير الكعبة وتحويل حج العرب إلى كنيسة فخمة بناها في صنعاء لكن العرب رفضوا أن يتركوا البيت العتيق.',
        sfxPath: 'assets/audio/sfx_army_march.wav',
        imagePath: 'assets/scenes/bubble_army.jpg',
        sourceRef: 'Quran 105:1-5 | Al-Raheeq Al-Makhtum, Ch. 5',
        sourceRefAr: 'القرآن 105:1-5 | الرحيق المختوم، الفصل 5',
        didYouKnow: 'Abraha built a massive cathedral in Sana\'a called Al-Qullays to divert the Arab pilgrimage away from the Ka\'bah, but the Arabs refused to abandon the ancient house.',
        didYouKnowAr: 'بنى أبرهة كنيسة ضخمة في صنعاء تُسمى القُلّيس لتحويل حج العرب عن الكعبة لكن العرب رفضوا هجر البيت العتيق فقرر أن يهدمه بنفسه.',
      ),
      SceneHotspot(
        id: 'muttalib',
        x: 0.75, y: 0.40,
        icon: '👤',
        label: 'Abd al-Muttalib',
        labelAr: 'عبد المطلب',
        fragment: '"I am the lord of the camels. The Ka\'bah has a Lord who will protect it." Abd al-Muttalib stood before Abraha and asked only for his camels, not for the sacred house. He told his people to withdraw to the mountains.',
        fragmentAr: 'وقف عبد المطلب أمام أبرهة ولم يطلب إلا إبله فقال: "أنا ربّ الإبل وللبيت ربٌّ يحميه." لم يتوسل ولم يساوم على الكعبة بل ائتمن ربّها على حمايتها وأمر قومه بالانسحاب إلى الجبال.',
        sfxPath: 'assets/audio/sfx_muttalib_silence.wav',
        imagePath: 'assets/scenes/bubble_muttalib.jpg',
        sourceRef: 'Ibn Hisham | Al-Raheeq Al-Makhtum, Ch. 5',
        sourceRefAr: 'ابن هشام | الرحيق المختوم، الفصل 5',
        didYouKnow: 'When Abraha\'s general took Abd al-Muttalib\'s camels, he went to negotiate, but only asked for his camels back, not for the Ka\'bah\'s protection. He said: "I am the lord of the camels. As for the House, it has a Lord who will protect it."',
        didYouKnowAr: 'حين أخذ قائد أبرهة إبل عبد المطلب ذهب للتفاوض لكنه طالب فقط بإبله ولم يطلب حماية الكعبة، وحين سُئل عن ذلك قال: "أنا ربّ الإبل وللبيت ربٌّ يحميه."',
      ),
      SceneHotspot(
        id: 'elephants',
        x: 0.22, y: 0.42,
        icon: '🐘',
        label: 'The Elephants',
        labelAr: 'الأفيال',
        fragment: 'The elephants halt at the boundary of the sacred precinct and refuse to move forward. The great beasts kneel, no matter how hard their riders strike. Something unseen holds them back.',
        fragmentAr: 'الأفيال تتوقف عند حدود الحرم وترفض أن تتحرك خطوة واحدة للأمام. الحيوانات الضخمة تركع مهما ضربها فرسانها وكأن شيئاً خفياً يمنعها من التقدم نحو البيت.',
        sfxPath: 'assets/audio/sfx_elephants_rumble.wav',
        imagePath: 'assets/scenes/bubble_elephants.jpg',
        sourceRef: 'Quran 105:1-5 | Al-Raheeq Al-Makhtum, Ch. 5',
        sourceRefAr: 'القرآن 105:1-5 | الرحيق المختوم، الفصل 5',
      ),
      SceneHotspot(
        id: 'birds',
        x: 0.50, y: 0.25,
        icon: '🕊️',
        label: 'The Sky Darkens',
        labelAr: 'السماء تُظلم',
        fragment: 'The sky darkens, not with clouds, but with birds. Thousands of them, resembling hawks, each carrying three stones of baked clay. The impossible unfolds before your eyes. This is divine protection.\n\nWhether you stood near the elephants or watched from the mountains, this moment finds you the same way. The sky has answered what the earth could not. And you are left with one question.',
        fragmentAr: 'السماء تُظلم لا بالغيوم بل بآلاف الطيور التي تشبه الصقور وكل طائر يحمل ثلاثة أحجار من سجيل. المستحيل يتكشّف أمام الأعين وهذه حماية إلهية لا يد لبشر فيها.\n\nسواء وقفت قرب الأفيال أو شاهدت من الجبال فهذه اللحظة تصلك بالطريقة ذاتها: السماء أجابت ما لم تستطع الأرض وتبقى أنت مع سؤال واحد.',
        sfxPath: 'assets/audio/sfx_birds_swarm.wav',
        imagePath: 'assets/scenes/bubble_birds.jpg',
        sourceRef: 'Quran 105:3-4 | Al-Raheeq Al-Makhtum, Ch. 5',
        sourceRefAr: 'القرآن 105:3-4 | الرحيق المختوم، الفصل 5',
      ),
    ],
    // Path A: Start → Army (anchor) → Elephants → Muttalib → Birds (convergence)
    pathWaypoints: const [
      Offset(0.50, 0.80),  // Start
      Offset(0.48, 0.70),  // Walk up
      Offset(0.45, 0.60),  // Army (GATE)
      Offset(0.34, 0.52),  // Turn left-up toward elephants
      Offset(0.22, 0.42),  // Elephants (PATH A)
      Offset(0.40, 0.38),  // Cross toward center (curve up)
      Offset(0.58, 0.37),  // Walk right toward muttalib (curve)
      Offset(0.75, 0.40),  // Muttalib (PATH B)
      Offset(0.65, 0.33),  // Turn up toward birds
      Offset(0.50, 0.25),  // Birds (GATHERING)
    ],
    // Path B: Start → Army (anchor) → Muttalib → Elephants → Birds (convergence)
    pathWaypointsAlt: const [
      Offset(0.50, 0.80),  // Start
      Offset(0.48, 0.70),  // Walk up
      Offset(0.45, 0.60),  // Army (GATE)
      Offset(0.58, 0.52),  // Turn right-up toward muttalib
      Offset(0.75, 0.40),  // Muttalib (PATH B first)
      Offset(0.55, 0.38),  // Cross toward center (curve up)
      Offset(0.38, 0.39),  // Walk left toward elephants (curve)
      Offset(0.22, 0.42),  // Elephants (PATH A second)
      Offset(0.35, 0.34),  // Turn up toward birds
      Offset(0.50, 0.25),  // Birds (GATHERING)
    ],
    skyGradient: const [
      Color(0xFF0A0812), Color(0xFF121025), Color(0xFF1A1530),
      Color(0xFF28203D), Color(0xFF3D2A40), Color(0xFF553545),
      Color(0xFF6E4040), Color(0xFF8A5035), Color(0xFFAA6530),
    ],
    skyStops: const [0.0, 0.12, 0.24, 0.36, 0.48, 0.58, 0.70, 0.85, 1.0],
    showStars: false,
    showMoon: false,
    particleType: ParticleType.dust,
    particleCount: 35,
    particleColor: const Color(0x70B8986E),
    ambientAudioPath: 'assets/audio/ambient_desert_evening.wav',
    ambientVolume: 0.20,
    showGrain: true,
    showBirds: true,
    birdCount: 45,
  ),

  // ── Event 3: The Black Stone — A Wise Arbitration (605 CE) ────────────
  'j_1_1_3': SceneConfig(
    hubLayers: _meccaHubLayers,
    groundLayers: const [
      ParallaxLayer(
        assetPath: 'assets/scenes/scene_event3_blackstone.jpg',
        speed: 0.15,
        verticalPosition: 0.0,
        heightFraction: 1.0,
      ),
    ],
    hotspots: const [
      SceneHotspot(
        id: 'flood',
        x: 0.45, y: 0.62,
        icon: '🌊',
        label: 'The Flood Damage',
        labelAr: 'أضرار السيل',
        fragment: 'The rains came without warning. A torrent swept through the valley and struck the ancient house. Walls crumbled and stones shifted from their places. The Ka\'bah, weakened by the weight of centuries, could no longer stand as it was. The tribes of Quraysh gathered and agreed that the house must be rebuilt. You watch as men carry stones from the valley and stack them with care, each tribe taking its share of the sacred work. The effort is slow but united, every hand serving the same purpose. For now, there is peace.',
        fragmentAr: 'جاءت الأمطار دون سابق إنذار، فاجتاح سيلٌ جارف الوادي وضرب البيت العتيق. انهارت الجدران وتزحزحت الحجارة من مواضعها. الكعبة التي أنهكتها القرون لم تعد تحتمل البقاء على حالها. فاجتمعت قبائل قريش واتفقت على أنّ البيت يجب أن يُعاد بناؤه. تراقب الرجال يحملون الحجارة من الوادي ويرصّونها بعناية، كل قبيلة تأخذ نصيبها من العمل المقدس. الجهد بطيء لكنه موحّد، وكل يدٍ تخدم الغاية ذاتها. في الوقت الحالي، ثمة سلام.',
        sfxPath: 'assets/audio/sfx_flood_rubble.wav',
        imagePath: 'assets/scenes/bubble_flood.jpg',
        sourceRef: 'Ibn Hisham, Vol. 1 | Al-Raheeq Al-Makhtum, Ch. 6',
        sourceRefAr: 'ابن هشام، المجلد 1 | الرحيق المختوم، الفصل 6',
        didYouKnow: 'The Ka\'bah was rebuilt several times throughout history. This particular rebuilding by Quraysh happened when Muhammad \uFDFA was thirty-five years old, just five years before the first revelation.',
        didYouKnowAr: 'أُعيد بناء الكعبة عدة مرات عبر التاريخ. وقد وقعت إعادة البناء هذه على يد قريش حين كان محمد \uFDFA في الخامسة والثلاثين من عمره، أي قبل نزول الوحي بخمس سنوات فقط.',
      ),
      SceneHotspot(
        id: 'dispute',
        x: 0.25, y: 0.42,
        icon: '⚔️',
        label: 'The Dispute',
        labelAr: 'النزاع',
        fragment: 'Four days have passed and the argument has not cooled. Every tribe claims the right to place the Black Stone with its own hands. Abu Umayyah ibn al-Mughirah, the eldest among them, watches as men draw closer to their swords. He knows that blood spilled in the sanctuary would stain Quraysh for generations. So he raises his voice above the crowd and proposes something no one can refuse: let them wait until dawn, and let the first man who walks through the gate of the sanctuary be their judge. The crowd falls silent. One by one, they agree. It is the only way forward that does not end in war.',
        fragmentAr: 'مرّت أربعة أيام ولم يهدأ الخلاف. كل قبيلة تطالب بأن تضع الحجر الأسود بيدها. أبو أمية بن المغيرة، أكبرهم سنًا، يراقب الرجال وهم يقتربون من سيوفهم. يعلم أن الدم إذا سُفك في الحرم فسيلطّخ قريشًا لأجيال. فرفع صوته فوق الجمع واقترح أمرًا لا يستطيع أحد رفضه: أن ينتظروا حتى الفجر، وأن يكون أول من يدخل من باب الحرم هو الحَكَم بينهم. صمت الجمع. واحدًا تلو الآخر وافقوا. كان هذا السبيل الوحيد الذي لا ينتهي بحرب.',
        sfxPath: 'assets/audio/sfx_dispute_crowd.wav',
        imagePath: 'assets/scenes/bubble_dispute.jpg',
        sourceRef: 'Ibn Hisham, Vol. 1 | Al-Raheeq Al-Makhtum, Ch. 6',
        sourceRefAr: 'ابن هشام، المجلد 1 | الرحيق المختوم، الفصل 6',
        didYouKnow: 'Abu Umayyah ibn al-Mughirah, who proposed the solution of waiting for the first entrant, was the oldest and most respected man in Quraysh at the time. His word carried enough weight to prevent immediate bloodshed.',
        didYouKnowAr: 'أبو أمية بن المغيرة الذي اقترح انتظار أول داخل كان أكبر رجال قريش سنًا وأكثرهم هيبة في ذلك الوقت. وكان لكلمته من الثقل ما يكفي لمنع سفك الدماء الفوري.',
      ),
      SceneHotspot(
        id: 'alamin',
        x: 0.72, y: 0.42,
        icon: '⭐',
        label: 'Al-Amin Enters',
        labelAr: 'دخول الأمين',
        fragment: 'At dawn, the gate of the sanctuary opens. The first man to walk through is Muhammad \uFDFA, thirty-five years old, known to every tribe yet belonging to no faction. A murmur passes through the crowd as they recognize him. "Al-Amin," they whisper to one another. The Trustworthy. No one objects. No one demands a second judge. They have placed their trust in this man for years, in matters of trade, in disputes between neighbors, in oaths that needed a witness. He has earned this moment not through power or wealth, but through a lifetime of quiet, consistent honesty.',
        fragmentAr: 'عند الفجر يُفتح باب الحرم. أول من يدخل منه هو محمد \uFDFA، في الخامسة والثلاثين من عمره، تعرفه كل القبائل لكنه لا ينتمي لأي فصيل. همهمة تسري في الجمع حين يتعرفون عليه. "الأمين"، يهمسون لبعضهم. لا أحد يعترض ولا أحد يطالب بحَكَمٍ ثانٍ. فقد ائتمنوا هذا الرجل سنين طويلة في شؤون التجارة وفي الخلافات بين الجيران وفي الأيمان التي تحتاج شاهداً. لم يكسب هذه اللحظة بسلطة أو مال، بل بعمرٍ كامل من الصدق الهادئ الثابت.',
        sfxPath: 'assets/audio/sfx_dawn_wind.wav',
        imagePath: 'assets/scenes/bubble_alamin.jpg',
        sourceRef: 'Ibn Hisham, Vol. 1 | Al-Bayhaqi, Dala\'il al-Nubuwwah | Al-Raheeq Al-Makhtum, Ch. 6',
        sourceRefAr: 'ابن هشام، المجلد 1 | البيهقي، دلائل النبوة | الرحيق المختوم، الفصل 6',
        didYouKnow: 'The Quraysh had agreed that the first person to enter the sanctuary at dawn would be their judge. That person turned out to be Muhammad \uFDFA, by Allah\'s design, not by anyone\'s arrangement.',
        didYouKnowAr: 'اتفقت قريش على أن أول من يدخل الحرم عند الفجر يكون حَكَمهم. وكان ذلك الشخص محمدًا \uFDFA، بتدبير الله لا بترتيب أحد.',
      ),
      SceneHotspot(
        id: 'cloak',
        x: 0.50, y: 0.28,
        icon: '📿',
        label: 'The Wise Solution',
        labelAr: 'الحل الحكيم',
        fragment: 'He asks for a cloak. He spreads it on the ground and places the Black Stone upon it. Then he invites the leader of each tribe to take hold of a corner. Together they lift. Together they carry it to its place at the corner of the Ka\'bah. Then he steps forward and sets the Stone in its position with his own hands. No tribe was denied its share of the honor. No blood was shed in the sacred precinct. This was wisdom before revelation, justice before prophethood. The man the world already called Al-Amin has just shown them why he earned that name.',
        fragmentAr: 'يطلب رداءً. يبسطه على الأرض ويضع الحجر الأسود فوقه. ثم يدعو زعيم كل قبيلة ليُمسك بطرف. معًا يرفعون. معًا يحملونه إلى موضعه في ركن الكعبة. ثم يتقدّم ويضع الحجر في مكانه بيديه. لم تُحرم قبيلة من نصيبها في الشرف، ولم يُسفك دمٌ في البقعة المقدسة. كانت هذه حكمة قبل الوحي، وعدالة قبل النبوة. الرجل الذي سمّاه العالم بالفعل الأمين أراهم للتو لماذا استحق هذا الاسم.',
        sfxPath: 'assets/audio/sfx_cloak_fabric.wav',
        imagePath: 'assets/scenes/bubble_cloak.jpg',
        sourceRef: 'Ibn Hisham, Vol. 1 | Al-Raheeq Al-Makhtum, Ch. 6 | Jami\' al-Tirmidhi, Hadith 877',
        sourceRefAr: 'ابن هشام، المجلد 1 | الرحيق المختوم، الفصل 6 | جامع الترمذي، حديث 877',
        didYouKnow: 'The Black Stone is believed to have originally been white, and to have turned black from absorbing the sins of the children of Adam. It is narrated in a hadith reported by al-Tirmidhi that the Stone descended from Paradise whiter than milk.',
        didYouKnowAr: 'يُعتقد أن الحجر الأسود كان أبيض في الأصل وأنه اسودّ من امتصاص ذنوب بني آدم. وقد جاء في حديث رواه الترمذي أن الحجر نزل من الجنة أشد بياضًا من اللبن.',
      ),
    ],
    // Path A: Start → Flood (anchor) → Dispute → Al-Amin → Cloak (convergence)
    pathWaypoints: const [
      Offset(0.50, 0.80),  // Start
      Offset(0.48, 0.72),  // Walk up
      Offset(0.45, 0.62),  // Flood (GATE)
      Offset(0.35, 0.52),  // Turn left-up toward dispute
      Offset(0.25, 0.42),  // Dispute (PATH A)
      Offset(0.42, 0.38),  // Cross toward center (curve up)
      Offset(0.57, 0.39),  // Walk right toward alamin (curve)
      Offset(0.72, 0.42),  // Al-Amin (PATH B)
      Offset(0.62, 0.35),  // Turn up toward cloak
      Offset(0.50, 0.28),  // Cloak (GATHERING)
    ],
    // Path B: Start → Flood (anchor) → Al-Amin → Dispute → Cloak (convergence)
    pathWaypointsAlt: const [
      Offset(0.50, 0.80),  // Start
      Offset(0.48, 0.72),  // Walk up
      Offset(0.45, 0.62),  // Flood (GATE)
      Offset(0.55, 0.52),  // Turn right-up toward alamin
      Offset(0.72, 0.42),  // Al-Amin (PATH B first)
      Offset(0.55, 0.38),  // Cross toward center (curve up)
      Offset(0.40, 0.39),  // Walk left toward dispute (curve)
      Offset(0.25, 0.42),  // Dispute (PATH A second)
      Offset(0.35, 0.35),  // Turn up toward cloak
      Offset(0.50, 0.28),  // Cloak (GATHERING)
    ],
    // Dawn sky gradient: dark blue-purple → warm peach/gold
    skyGradient: const [
      Color(0xFF0A0C1A),  // deep night at top
      Color(0xFF141830),  // dark blue
      Color(0xFF1E2040),  // indigo
      Color(0xFF3A2848),  // purple transition
      Color(0xFF6A3840),  // warm mauve
      Color(0xFF9A5038),  // terracotta
      Color(0xFFC87840),  // amber
      Color(0xFFE8A050),  // warm gold
      Color(0xFFF0C070),  // pale gold at horizon
    ],
    skyStops: const [0.0, 0.12, 0.24, 0.36, 0.48, 0.58, 0.70, 0.85, 1.0],
    showStars: false,
    showMoon: false,
    particleType: ParticleType.dust,
    particleCount: 40,
    particleColor: const Color(0x70B8986E),
    ambientAudioPath: 'assets/audio/ambient_desert_evening.wav',
    ambientVolume: 0.18,
    showGrain: true,
  ),

  // ── Event 3: Birth of the Prophet ﷺ (570 CE) ────────────────────────────
  'j_1_2_1': SceneConfig(
    hubLayers: _meccaHubLayers,
    groundLayers: const [],
    hotspots: const [
      SceneHotspot(
        id: 'night_banu_hashim',
        x: 0.48, y: 0.62,
        icon: '🌙',
        label: 'The Night in Banu Hashim',
        labelAr: 'ليلة في بني هاشم',
        fragment: 'The Year of the Elephant has barely passed. Mecca is still shaken. The people saw an army destroyed before their eyes, stones falling from birds they had never seen. The Quraysh know something has changed, though they cannot name it. Tonight, in the quarter of Banu Hashim, a woman is in labor. The house is small. The streets are quiet. No one in Mecca knows that this night will be remembered long after the Elephant is forgotten.',
        fragmentAr: 'عام الفيل بالكاد مرّ ومكة لا تزال مهتزة بعد أن رأى الناس جيشاً يُدمَّر أمام أعينهم بحجارة تسقط من طيور لم يروها قط. قريش تعلم أن شيئاً تغيّر لكنها لا تستطيع تسميته. الليلة في حي بني هاشم امرأة تضع مولوداً والبيت صغير والأزقة هادئة ولا أحد في مكة يعلم أن هذه الليلة ستُذكر طويلاً بعد أن يُنسى الفيل.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Ibn Hisham | Al-Raheeq Al-Makhtum, Ch. 5',
        sourceRefAr: 'ابن هشام | الرحيق المختوم، الفصل 5',
      ),
      SceneHotspot(
        id: 'aminah_vision',
        x: 0.25, y: 0.45,
        icon: '✨',
        label: 'Aminah\'s Vision',
        labelAr: 'رؤيا آمنة',
        fragment: 'When Aminah carried him, she saw a vision, a light emerging from her that illuminated the palaces of distant Syria. The Prophet \uFDFA himself would later say: "I am the supplication of my father Ibrahim, the glad tidings of my brother Isa, and my mother saw when she carried me a light that illuminated the palaces of Syria." She did not yet understand what it meant. But the light was real. And the child it announced would illuminate far more than palaces.',
        fragmentAr: 'حين حملت آمنة به رأت رؤيا عجيبة: نور يخرج منها يُضيء قصور الشام البعيدة. النبي \uFDFA نفسه سيقول لاحقاً: "أنا دعوة أبي إبراهيم وبشرى أخي عيسى ورأت أمي حين حملت بي نوراً أضاءت له قصور الشام." لم تفهم آمنة بعد ما يعنيه ذلك لكن النور كان حقيقياً والطفل الذي بشّر به سيُضيء أكثر بكثير من القصور.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Quran 2:129, 61:6 | Musnad Ahmad | Al-Raheeq Al-Makhtum, Ch. 5',
        sourceRefAr: 'القرآن 2:129، 61:6 | مسند أحمد | الرحيق المختوم، الفصل 5',
        didYouKnow: 'The Prophet ﷺ described himself as the answer to three things: Ibrahim\'s prayer for a messenger from among his descendants, Isa\'s prophecy of "a messenger after me named Ahmad," and his mother\'s vision of light.',
        didYouKnowAr: 'وصف النبي ﷺ نفسه بأنه إجابة ثلاثة أمور: دعوة إبراهيم بإرسال رسول من ذريته، وبشارة عيسى بـ"رسول يأتي من بعدي اسمه أحمد"، ورؤيا أمه بالنور.',
      ),
      SceneHotspot(
        id: 'naming_kaabah',
        x: 0.72, y: 0.42,
        icon: '🕋',
        label: 'The Naming at the Ka\'bah',
        labelAr: 'التسمية عند الكعبة',
        fragment: 'Abd al-Muttalib carries the newborn to the Ka\'bah. He holds the child before the ancient house, the same house that Allah protected from Abraha\'s army just weeks before. He names him Muhammad: "The one who is praised again and again." The Arabs ask why he chose a name none of them have ever heard. He answers: "I want him to be praised in the heavens and on earth." A grandfather\'s hope. A name that would be spoken five times a day in every corner of the world.',
        fragmentAr: 'يحمل عبد المطلب المولود إلى الكعبة ويرفع الطفل أمام البيت العتيق الذي حماه الله من جيش أبرهة قبل أسابيع ويسمّيه محمداً: "الذي يُحمد مراراً وتكراراً." حين يسأله العرب لماذا اختار اسماً لم يسمعوه من قبل يجيب: "أريده أن يُحمد في السماء والأرض." أمنية جَدّ ستتحول إلى اسم يُردد خمس مرات في اليوم في كل زاوية من العالم.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Ibn Hisham | Al-Raheeq Al-Makhtum, Ch. 5',
        sourceRefAr: 'ابن هشام | الرحيق المختوم، الفصل 5',
      ),
      SceneHotspot(
        id: 'orphan_dawn',
        x: 0.50, y: 0.28,
        icon: '🌅',
        label: 'The Orphan\'s First Dawn',
        labelAr: 'فجر اليتيم الأول',
        fragment: 'He was born without a father. Abdullah died months before, some say in Medina, returning from a trade journey, never knowing what Aminah carried. This child entered the world with nothing but a mother\'s embrace and a grandfather\'s prayer. Years later, Allah would address him directly: "Did He not find you an orphan and give you shelter?" Every loss was preparation. Every absence was by design. The most influential human being in history began with the least.',
        fragmentAr: 'وُلد بلا أب فعبد الله مات قبل أشهر في المدينة عائداً من رحلة تجارة ولم يعلم قط ما حملته آمنة. هذا الطفل دخل الدنيا بلا شيء سوى حضن أمّه ودعاء جدّه. بعد سنين سيخاطبه الله مباشرة: "أَلَمْ يَجِدْكَ يَتِيمًا فَآوَىٰ؟" كل خسارة كانت إعداداً وكل غياب كان بتدبير، فأكثر إنسان أثّر في التاريخ بدأ بأقل القليل.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Quran 93:6 | Al-Raheeq Al-Makhtum, Ch. 5',
        sourceRefAr: 'القرآن 93:6 | الرحيق المختوم، الفصل 5',
        didYouKnow: 'Abdullah, the Prophet\'s father, died at age 25, so young that when his son was later asked about him, the details were few. The Prophet ﷺ once passed his father\'s grave in Medina and wept.',
        didYouKnowAr: 'عبد الله، والد النبي، توفي في سن الخامسة والعشرين، شاباً جداً حتى أن التفاصيل عنه كانت قليلة حين سُئل ابنه لاحقاً. مرّ النبي ﷺ يوماً بقبر أبيه في المدينة وبكى.',
      ),
    ],
    // Linear path: Start → Night in Banu Hashim → Aminah's Vision → Naming → Orphan's Dawn
    pathWaypoints: const [
      Offset(0.50, 0.80),  // Start
      Offset(0.49, 0.72),  // Walk up
      Offset(0.48, 0.62),  // Hotspot 1: The Night
      Offset(0.37, 0.54),  // Turn left toward Aminah's Vision
      Offset(0.25, 0.45),  // Hotspot 2: Aminah's Vision
      Offset(0.45, 0.42),  // Cross center
      Offset(0.72, 0.42),  // Hotspot 3: The Naming
      Offset(0.63, 0.36),  // Turn up
      Offset(0.50, 0.28),  // Hotspot 4: The Orphan's First Dawn
    ],
    // Static black until batch scene images are generated
    skyGradient: const [Color(0xFF000000), Color(0xFF000000)],
    skyStops: const [0.0, 0.12, 0.24, 0.36, 0.48, 0.58, 0.70, 0.85, 1.0],
    showStars: true,
    showMoon: true,
    moonPosition: const Offset(0.80, 0.06),
    particleType: ParticleType.dust,
    particleCount: 25,
    particleColor: const Color(0x50C9A84C),
    showGrain: true,
  ),

  // ── Event 4: The Nursing Years — Halimah (570 CE) ────────────────────────
  'j_1_2_2': SceneConfig(
    hubLayers: _meccaHubLayers,
    groundLayers: const [],
    hotspots: const [
      SceneHotspot(
        id: 'drought_year',
        x: 0.50, y: 0.62,
        icon: '🏜️',
        label: 'The Drought Year',
        labelAr: 'عام الجدب',
        fragment: 'The women of Banu Sa\'d arrive in Mecca in a year the Arabs call "shahba\'", gray, barren, merciless. Halimah\'s own child cries through the night because her milk has dried. Her donkey is so weak it slows the entire caravan. The other women curse her pace. In Mecca, every nursing woman finds a well-born child with a generous father. Halimah is offered only one: an orphan whose father died before he was born. She turns away. What can an orphan\'s family pay?',
        fragmentAr: 'نساء بني سعد يصلن مكة في عام يسمّيه العرب "شهباء" وهو عام رمادي قاحل بلا رحمة. طفل حليمة نفسه يبكي طوال الليل لأن حليبها جفّ وأتانها ضعيفة جداً حتى إنها تبطئ القافلة بأكملها والنساء يلعنّ بطأها. في مكة كل مرضعة تجد طفلاً من عائلة كريمة بأب سخيّ لكن حليمة لا يُعرض عليها سوى طفل واحد: يتيم مات أبوه قبل أن يُولد. فتُعرض عنه وتسأل نفسها: ماذا ستدفع عائلة يتيم؟',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Ibn Hisham | Al-Raheeq Al-Makhtum, Ch. 5',
        sourceRefAr: 'ابن هشام | الرحيق المختوم، الفصل 5',
      ),
      SceneHotspot(
        id: 'blessed_soul',
        x: 0.25, y: 0.44,
        icon: '🤲',
        label: 'A Blessed Soul',
        labelAr: 'نَسَمة مباركة',
        fragment: 'Halimah returns to the gathering place. Every other child has been taken. Only the orphan remains. She tells her husband: "I hate to return to our people with nothing. Let me take this orphan." He replies: "Take him. Perhaps Allah will place blessing in him." She lifts the child, and in that instant, her milk flows. The baby drinks until he is full. His milk-brother drinks until he is full. Their old she-camel, which had not given a drop, suddenly fills with milk. Her husband milks it and they both drink until they are satisfied. He looks at her and says: "By Allah, Halimah, you have taken a blessed soul."',
        fragmentAr: 'تعود حليمة إلى مكان التجمّع فتجد أن كل طفل آخر قد أُخذ ولم يبقَ سوى اليتيم. تقول لزوجها: "أكره أن أرجع إلى قومي بلا شيء فدعني آخذ هذا اليتيم." فيجيب: "خذيه لعل الله يجعل لنا فيه بركة." تحمل الطفل وفي تلك اللحظة يدرّ حليبها فيشرب الرضيع حتى يرتوي ويشرب أخوه في الرضاعة حتى يرتوي وناقتهم العجوز التي لم تعطِ قطرة تمتلئ فجأة بالحليب. ينظر إليها زوجها ويقول: "والله يا حليمة لقد أخذتِ نسمة مباركة."',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Ibn Hisham | Al-Raheeq Al-Makhtum, Ch. 5',
        sourceRefAr: 'ابن هشام | الرحيق المختوم، الفصل 5',
        didYouKnow: 'It was the custom of noble Quraysh families to send their newborns to Bedouin tribes in the desert, so the children would grow strong in body and pure in Arabic tongue. The Prophet \uFDFA later said: "I am the most eloquent of the Arabs, for I am from Quraysh and I was nursed among Banu Sa\'d."',
        didYouKnowAr: 'كان من عادة أشراف قريش إرسال مواليدهم إلى قبائل البادية ليكبر الأطفال أقوياء في أجسامهم وفصحاء في لسانهم. قال النبي ﷺ لاحقاً: "أنا أفصح العرب بَيد أني من قريش واسترضعت في بني سعد."',
      ),
      SceneHotspot(
        id: 'green_land',
        x: 0.72, y: 0.42,
        icon: '🌿',
        label: 'The Green Land',
        labelAr: 'الأرض الخضراء',
        fragment: 'They return to the land of Banu Sa\'d, the driest land Halimah has ever known. But now, wherever her sheep graze, they return full of milk. Her neighbors\' sheep graze the same hills and return with nothing. The people of Banu Sa\'d begin sending their shepherds to follow Halimah\'s flock, hoping for the same blessing. It does not work for them. The blessing follows the child, not the land. He grows faster than any boy his age. Halimah watches him and knows: this is not an ordinary child.',
        fragmentAr: 'يعودون إلى أرض بني سعد وهي أجدب أرض عرفتها حليمة لكن الآن أينما رعت أغنامها تعود ممتلئة بالحليب بينما أغنام جيرانها ترعى التلال ذاتها وتعود بلا شيء. أهل بني سعد يرسلون رعاتهم ليتبعوا قطيع حليمة أملاً في البركة نفسها لكنها لا تنجح معهم لأن البركة تتبع الطفل لا الأرض. ينمو أسرع من أي صبي في سنّه وحليمة تراقبه وتعلم أن هذا ليس طفلاً عادياً.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Ibn Hisham | Al-Raheeq Al-Makhtum, Ch. 5',
        sourceRefAr: 'ابن هشام | الرحيق المختوم، الفصل 5',
        didYouKnow: 'Halimah\'s donkey, which had been so weak it slowed the entire caravan on the way to Mecca, outpaced every animal on the way back. The other women said in amazement: "Is this the same donkey you came on?"',
        didYouKnowAr: 'أتان حليمة التي كانت ضعيفة جداً حتى أبطأت القافلة بأكملها في طريقها إلى مكة سبقت كل دابة في طريق العودة حتى قالت النساء بدهشة: "أهذه الأتان التي خرجتِ عليها؟"',
      ),
      SceneHotspot(
        id: 'keep_him',
        x: 0.50, y: 0.28,
        icon: '💛',
        label: '"Let Me Keep Him"',
        labelAr: '"دعيني أبقيه"',
        fragment: 'After two years, it is time to return the child to his mother Aminah. But Halimah cannot bear to let him go. She has watched the blessings multiply, in her milk, her animals, her land, her family. She goes to Aminah and begs: "Let me keep him longer. I fear the plague of Mecca for him." She argues until Aminah agrees. The child returns to Banu Sa\'d. He will stay until he is four or five, running barefoot in the open desert, learning the pure Arabic of the Bedouin, growing under a sky wider than anything Mecca could offer. Allah is raising His prophet in the wilderness.',
        fragmentAr: 'بعد سنتين حان وقت إعادة الطفل إلى أمه آمنة لكن حليمة لا تطيق فراقه فقد شاهدت البركات تتضاعف في حليبها وماشيتها وأرضها وأهلها. تذهب إلى آمنة وتتوسل: "دعيني أبقيه فإني أخاف عليه من وباء مكة." تُلحّ حتى توافق آمنة ويعود الطفل إلى بني سعد حيث سيبقى حتى الرابعة أو الخامسة يركض حافياً في الصحراء المفتوحة ويتعلم عربية البدو الصافية ويكبر تحت سماء أوسع مما تقدمه مكة. الله يربّي نبيّه في البرّية.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Ibn Hisham | Al-Raheeq Al-Makhtum, Ch. 5',
        sourceRefAr: 'ابن هشام | الرحيق المختوم، الفصل 5',
      ),
    ],
    // Linear path: Start → Drought Year → Blessed Soul → Green Land → Keep Him
    pathWaypoints: const [
      Offset(0.50, 0.80),
      Offset(0.51, 0.72),
      Offset(0.50, 0.62),  // Hotspot 1
      Offset(0.38, 0.54),
      Offset(0.25, 0.44),  // Hotspot 2
      Offset(0.45, 0.42),
      Offset(0.72, 0.42),  // Hotspot 3
      Offset(0.63, 0.36),
      Offset(0.50, 0.28),  // Hotspot 4
    ],
    // Static black until batch scene images are generated
    skyGradient: const [Color(0xFF000000), Color(0xFF000000)],
    skyStops: const [0.0, 0.12, 0.24, 0.36, 0.48, 0.58, 0.70, 0.85, 1.0],
    showStars: false,
    showMoon: false,
    particleType: ParticleType.dust,
    particleCount: 20,
    particleColor: const Color(0x40B8986E),
    showGrain: true,
  ),

  // ── Event 5: The Opening of the Chest (j_m1_005) ─────────────────────────
  'j_m1_005': SceneConfig(
    hubLayers: _meccaHubLayers,
    groundLayers: const [],
    hotspots: const [
      SceneHotspot(id: 'boys_play', x: 0.22, y: 0.52, icon: '☀️', label: 'The Boys at Play', labelAr: 'الصبيان يلعبون',
        fragment: 'He is one of them, the children of the desert. They chase each other between the tents, throw stones at imaginary targets, and wrestle in the sand. No one in Banu Sa\'d treats him differently. He is the boy Halimah brought from Mecca, the orphan who changed their fortune. He laughs like them, runs like them. But he has never bowed to an idol. He has never lied. Even at this age, there is something about him the other children cannot name, a seriousness behind the smile, a stillness when the others shout. Today feels like any other day. It is not.',
        fragmentAr: 'هو واحد من أطفال الصحراء يتراكضون بين الخيام ويرمون الحجارة على أهداف وهمية ويتصارعون في الرمل. لا أحد في بني سعد يعامله بشكل مختلف فهو الصبي الذي جاءت به حليمة من مكة واليتيم الذي غيّر حظّهم. يضحك مثلهم ويركض مثلهم لكنه لم يسجد لصنم قط ولم يكذب قط، وحتى في هذا العمر فيه شيء لا يستطيع الأطفال الآخرون تسميته: جدّية خلف الابتسامة وسكينة حين يصرخ الآخرون. اليوم يبدو كأي يوم آخر لكنه ليس كذلك.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav', sourceRef: 'Al-Raheeq Al-Makhtum, Ch. 5', sourceRefAr: 'الرحيق المختوم، الفصل 5'),
      SceneHotspot(id: 'two_strangers', x: 0.42, y: 0.46, icon: '🤍', label: 'The Two Strangers', labelAr: 'الغريبان',
        fragment: 'Two men in white appear from nowhere. They walk toward the boy. The children freeze, then scatter, screaming. The two men take him gently, lay him down on the ground. The boys run to Halimah, their faces white with terror: "Muhammad has been killed! Muhammad has been killed!" She rushes out, her heart pounding, her worst fear alive. She finds him standing, pale but unhurt. His face has changed. Something has happened that the desert cannot explain.',
        fragmentAr: 'رجلان بثياب بيضاء يظهران من العدم ويمشيان نحو الصبي فيتجمّد الأطفال ثم يتفرّقون صارخين. الرجلان يأخذانه برفق ويُمدّدانه على الأرض برفق والصبيان يركضون نحو حليمة ووجوههم شاحبة من الرعب يصرخون: "محمد قُتل! محمد قُتل!" فتندفع خارجاً وقلبها يخفق وأسوأ مخاوفها حيّة. تجده واقفاً شاحباً لكنه سليم ووجهه قد تغيّر فشيء ما حدث لا تستطيع الصحراء تفسيره.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav', sourceRef: 'Sahih Muslim #162 | Al-Raheeq Al-Makhtum, Ch. 5', sourceRefAr: 'صحيح مسلم #162 | الرحيق المختوم، الفصل 5',
        didYouKnow: 'The Prophet \uFDFA himself narrated this incident as an adult. He told his Companions exactly what happened: the two angels, the golden basin, the washing. It was not a story told about him. He remembered it.',
        didYouKnowAr: 'النبي ﷺ نفسه روى هذه الحادثة وهو كبير فأخبر أصحابه بالضبط ما حدث من الملَكين والطست الذهبي والغسل. لم تكن قصة تُروى عنه بل هو تذكّرها بنفسه.'),
      SceneHotspot(id: 'golden_basin', x: 0.62, y: 0.40, icon: '💧', label: 'The Golden Basin', labelAr: 'الطست الذهبي',
        fragment: 'The Prophet \uFDFA would later describe it himself: "They laid me down and opened my chest. They brought a golden basin filled with Zamzam water. They washed my heart, then extracted from it a dark clot and said: \'This is the share of Shaytan from you.\' Then they washed my heart until it was clean, filled it, and returned it." A purification not by human hands. A preparation by divine command.',
        fragmentAr: 'النبي ﷺ وصف ذلك بنفسه لاحقاً فقال: "أمدّاني على الأرض وشقّا صدري وجاءا بطست من ذهب مملوء ماء زمزم وغسلا قلبي ثم استخرجا منه علقة سوداء فقالا: هذا حظ الشيطان منك. ثم غسلا قلبي حتى أنقياه وأعاداه." تطهير ليس بأيدٍ بشرية بل إعداد بأمر إلهي، فالطفل يُهيَّأ لشيء لا يعرفه العالم بعد والله لا يختار إناءً دون أن يُعدّه أولاً.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav', sourceRef: 'Sahih Muslim #162 | Musnad Ahmad', sourceRefAr: 'صحيح مسلم #162 | مسند أحمد'),
      SceneHotspot(id: 'the_mark', x: 0.80, y: 0.34, icon: '✋', label: 'The Mark', labelAr: 'الأثر',
        fragment: 'Anas ibn Malik, who served the Prophet \uFDFA for ten years, said: "I used to see the mark of the stitching on his chest." The evidence remained: visible, physical, undeniable. Halimah, terrified by what happened, rushes to return the child to Aminah in Mecca. She tells her everything. But Aminah shows no fear. She says calmly: "The Shaytan has no power over my son."',
        fragmentAr: 'أنس بن مالك الذي خدم النبي ﷺ عشر سنوات قال: "كنت أرى أثر المخيط في صدره." الدليل بقي مرئياً مادياً لا يُنكر. حليمة المرعوبة مما حدث تسرع لإعادة الطفل إلى آمنة في مكة وتخبرها بكل شيء لكن آمنة لا تُظهر خوفاً وتقول بهدوء: "ما للشيطان عليه سبيل." كانت تعلم دائماً فالنور الذي رأته يصل الشام والحمل السهل والاسم الذي أُخبرت به في المنام كلها علامات أن هذا الطفل لم يكن عادياً قط والآن حتى قلبه غُسل ونُقّي.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav', sourceRef: 'Sahih Muslim #162 | Al-Raheeq Al-Makhtum, Ch. 5', sourceRefAr: 'صحيح مسلم #162 | الرحيق المختوم، الفصل 5',
        didYouKnow: 'The opening of the chest happened more than once. It happened again on the night of Al-Isra\' wal-Mi\'raj, when the Prophet \uFDFA was about to ascend through the heavens.',
        didYouKnowAr: 'شقّ الصدر حدث أكثر من مرة إذ يروي صحيح البخاري ومسلم أنه حدث مجدداً ليلة الإسراء والمعراج حين كان النبي ﷺ على وشك الصعود عبر السماوات فشُقّ صدره وغُسل قلبه ومُلئ حكمة وإيماناً.'),
    ],
    // Pattern B — left to right
    pathWaypoints: const [Offset(0.12, 0.58), Offset(0.17, 0.55), Offset(0.22, 0.52), Offset(0.32, 0.49), Offset(0.42, 0.46), Offset(0.52, 0.43), Offset(0.62, 0.40), Offset(0.72, 0.37), Offset(0.80, 0.34)],
    skyGradient: const [Color(0xFF000000), Color(0xFF000000)],
    particleType: ParticleType.dust, particleCount: 15, particleColor: const Color(0x30B8986E), showGrain: true,
  ),

  // ── Event 6: Death of Aminah (j_m1_006) ───────────────────────────────────
  'j_m1_006': SceneConfig(
    hubLayers: _meccaHubLayers,
    groundLayers: const [],
    hotspots: const [
      SceneHotspot(id: 'journey_medina', x: 0.50, y: 0.62, icon: '🐪', label: 'The Journey', labelAr: 'الرحلة',
        fragment: 'Aminah takes her son and sets out for Medina. With them travels Umm Ayman, the faithful servant of the family. The boy is six years old. His mother wants him to see the place where his father Abdullah is buried, and to meet his uncles from Banu al-Najjar. It is a long journey across the desert for a small child.',
        fragmentAr: 'تأخذ آمنة ابنها وتنطلق نحو المدينة وترافقهم أم أيمن خادمة العائلة الوفية. الصبي في السادسة من عمره وأمه تريده أن يرى المكان الذي دُفن فيه أبوه عبد الله وأن يلتقي أخواله من بني النجار. رحلة طويلة عبر الصحراء لطفل صغير لكن آمنة تريد لابنها أن يعرف من أين جاء وأن يقف ولو مرة واحدة بجانب قبر أبيه.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav', sourceRef: 'Al-Raheeq Al-Makhtum, Ch. 5', sourceRefAr: 'الرحيق المختوم، الفصل 5'),
      SceneHotspot(id: 'banu_najjar', x: 0.25, y: 0.44, icon: '🏘️', label: 'Banu al-Najjar', labelAr: 'بنو النجار',
        fragment: 'They arrive in Medina and stay with his maternal uncles for a full month. The boy sees the date palms, the wells, the narrow lanes of Yathrib. He does not know that this city will one day open its arms to him when his own city drives him out. He does not know that he will build his mosque here, form a nation here, and be buried here.',
        fragmentAr: 'يصلون المدينة ويمكثون عند أخواله بني النجار شهراً كاملاً والصبي يرى النخيل والآبار وأزقة يثرب الضيقة. لا يعلم أن هذه المدينة ستفتح له ذراعيها يوماً حين تطرده مدينته ولا يعلم أنه سيبني مسجده هنا ويؤسس أمة هنا ويُدفن هنا. الآن هو مجرد طفل بين أقارب يأكل التمر ويقف عند قبر أب لم يلقه قط.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav', sourceRef: 'Ibn Hisham | Al-Raheeq Al-Makhtum, Ch. 5', sourceRefAr: 'ابن هشام | الرحيق المختوم، الفصل 5',
        didYouKnow: 'The Prophet \uFDFA learned to swim in Medina during this childhood visit. He later said: "I learned swimming at the well of Banu al-Najjar."',
        didYouKnowAr: 'تعلّم النبي ﷺ السباحة في المدينة خلال هذه الزيارة في طفولته وقال لاحقاً: "تعلمت السباحة عند بئر بني النجار" وهي ذكراه الوحيدة من طفولته في المدينة التي ستصبح وطنه.'),
      SceneHotspot(id: 'al_abwa', x: 0.72, y: 0.42, icon: '💔', label: 'Al-Abwa', labelAr: 'الأبواء',
        fragment: 'They begin the journey home to Mecca. But on the road, Aminah falls ill. The sickness is sudden and severe. At a small village called Al-Abwa, she can go no further. She dies there, far from home, with her six-year-old son beside her. The boy who entered the world without a father now stands in the desert without a mother.',
        fragmentAr: 'يبدأون رحلة العودة إلى مكة لكن في الطريق بين المدينتين تمرض آمنة مرضاً مفاجئاً شديداً. في قرية صغيرة تُدعى الأبواء لا تستطيع المواصلة فتموت هناك بعيدة عن بيتها وبعيدة عن أهل أبيها وابنها ذو الست سنوات بجانبها وأم أيمن تسهر عليهما. الصبي الذي دخل الدنيا بلا أب يقف في الصحراء بلا أم وعمره ست سنوات وكلمة "يتيم" أخذت معناها الكامل.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav', sourceRef: 'Ibn Hisham | Al-Raheeq Al-Makhtum, Ch. 5', sourceRefAr: 'ابن هشام | الرحيق المختوم، الفصل 5'),
      SceneHotspot(id: 'umm_ayman', x: 0.50, y: 0.28, icon: '🤲', label: 'My Mother After My Mother', labelAr: 'أمي بعد أمي',
        fragment: 'Umm Ayman takes the child by the hand. She walks him across the desert, back to Mecca, back to his grandfather. The Prophet \uFDFA would remember her love his entire life. He called her "my mother after my mother." Years later, he passed by Al-Abwa and visited his mother\'s grave. He wept until those around him wept too. Even prophets grieve.',
        fragmentAr: 'أم أيمن تأخذ الطفل بيده وبركة اسمها الحقيقي خدمت هذه العائلة منذ قبل ولادته. تمشي به عبر الصحراء عائدة إلى مكة عائدة إلى جدّه عبد المطلب ولا تترك يده. النبي ﷺ سيتذكر حبّها طوال حياته وسيسمّيها "أمي بعد أمي" وسيعتقها ويرتّب زواجها ويزورها حتى آخر أيامها. بعد سنين رجلاً كبيراً ونبياً مرّ بالأبواء وزار قبر أمه فبكى حتى بكى من حوله. حتى الأنبياء يحزنون وحتى أقوى القلوب تتذكر الطريق الذي فقدت فيه كل شيء.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav', sourceRef: 'Sahih Muslim #976 | Al-Raheeq Al-Makhtum, Ch. 5', sourceRefAr: 'صحيح مسلم #976 | الرحيق المختوم، الفصل 5',
        didYouKnow: 'When the Prophet \uFDFA visited his mother\'s grave at Al-Abwa, he asked Allah for permission to pray for her forgiveness, but it was not granted. He was only permitted to visit. He wept so deeply that everyone around him wept with him.',
        didYouKnowAr: 'حين زار النبي ﷺ قبر أمه في الأبواء بعد سنين استأذن الله أن يستغفر لها فلم يُؤذن له وأُذن له بالزيارة فقط فبكى بكاءً شديداً حتى بكى كل من حوله.'),
    ],
    pathWaypoints: const [Offset(0.50, 0.80), Offset(0.51, 0.72), Offset(0.50, 0.62), Offset(0.38, 0.54), Offset(0.25, 0.44), Offset(0.45, 0.42), Offset(0.72, 0.42), Offset(0.63, 0.36), Offset(0.50, 0.28)],
    skyGradient: const [Color(0xFF000000), Color(0xFF000000)],
    skyStops: const [0.0, 0.12, 0.24, 0.36, 0.48, 0.58, 0.70, 0.85, 1.0],
    particleType: ParticleType.dust, particleCount: 15, particleColor: const Color(0x30B8986E), showGrain: true,
  ),

  // ── Event 7: Under the Care of Abd al-Muttalib (j_m1_007) ────────────────
  'j_m1_007': SceneConfig(
    hubLayers: _meccaHubLayers,
    groundLayers: const [],
    hotspots: const [
      SceneHotspot(id: 'seat_kaabah', x: 0.50, y: 0.60, icon: '👑', label: 'The Seat by the Ka\'bah', labelAr: 'المقعد عند الكعبة',
        fragment: 'Abd al-Muttalib has a seat in the shade of the Ka\'bah that belongs to him alone. But the orphan boy climbs onto it without hesitation. His uncles reach to pull him away. Abd al-Muttalib stops them: "Leave my son alone. By Allah, he has a great destiny."',
        fragmentAr: 'لعبد المطلب فراش في ظل الكعبة لا يملكه سواه ولا أحد في مكة يجلس عليه لا أبناؤه ولا زعماء القبائل الأخرى فأبناؤه يجلسون حوله على الأرض إجلالاً له. لكن الصبي اليتيم يصعد عليه دون تردد فيمدّ أعمامه أيديهم ليبعدوه لكن عبد المطلب يوقفهم بيد مرفوعة: "دعوا ابني فوالله إن له لشأناً." الشيخ يراقب الطفل ويرى ما لا يراه الآخرون ويبقيه أقرب من أي من أبنائه فلا ينام إلا والصبي بجانبه ولا يخرج من البيت إلا والصبي معه.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav', sourceRef: 'Ibn Hisham | Al-Raheeq Al-Makhtum, Ch. 5', sourceRefAr: 'ابن هشام | الرحيق المختوم، الفصل 5'),
      SceneHotspot(id: 'siqayah', x: 0.22, y: 0.42, icon: '💧', label: 'Keeper of the Siqayah', labelAr: 'سادن السقاية',
        fragment: 'Abd al-Muttalib is the chief of Banu Hashim and the keeper of the Siqayah, the sacred duty of providing water to pilgrims. He is the same man who stood before Abraha and said, "The House has a Lord who will protect it." Now this man has been entrusted with the boy who will one day cleanse the Ka\'bah.',
        fragmentAr: 'عبد المطلب ليس فقط جدّ الصبي بل هو سيد بني هاشم وصاحب السقاية وهي المسؤولية المقدسة لسقاية الحجاج الذين يزورون الكعبة والقرآن نفسه يُكرّم هذا الدور. هو الرجل نفسه الذي وقف أمام أبرهة وقال "أنا ربّ الإبل وللبيت ربٌّ يحميه" فلم يتوسل ولم يساوم على الكعبة بل وثق بالله ومضى. الآن هذا الرجل الذي ائتمن الله على الكعبة ذاتها اؤتمن على الصبي الذي سيُطهّرها يوماً ويربّيه لا بالمال بل بالكرامة.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav', sourceRef: 'Quran 9:19 | Al-Raheeq Al-Makhtum, Ch. 5', sourceRefAr: 'القرآن 9:19 | الرحيق المختوم، الفصل 5',
        didYouKnow: 'Abd al-Muttalib rediscovered the well of Zamzam after it had been lost for generations. The same water that washed the Prophet\'s heart came from the well his grandfather restored.',
        didYouKnowAr: 'عبد المطلب أعاد اكتشاف بئر زمزم بعد أن ضاعت ودُفنت لأجيال وحفرها بناءً على رؤيا رآها في منامه. الماء نفسه الذي غُسل به قلب النبي ﷺ في بني سعد جاء من البئر التي أحياها جدّه.'),
      SceneHotspot(id: 'two_years', x: 0.78, y: 0.42, icon: '🫶', label: 'Two Precious Years', labelAr: 'سنتان ثمينتان',
        fragment: 'For two years, Abd al-Muttalib raises the boy by his own side. Once, he sent the boy to find some camels that had strayed. The boy took long to return, and Abd al-Muttalib became so distressed that he swore he would never send him on an errand again.',
        fragmentAr: 'لمدة سنتين يربّي عبد المطلب الصبي بجانبه ولا يسلّمه لخدم أو أقارب بعيدين بل يبقيه قريباً ويأخذه إلى مجالس قريش ويتركه يسمع كلام الشيوخ. ذات مرة أرسل الصبي ليتبع إبلاً ضلّت فتأخر في العودة وحزن عبد المطلب حزناً شديداً حتى أقسم ألا يبعثه في حاجة أبداً ولا يفارقه بعدها أبداً. الصبي الذي فقد أباه قبل أن يُولد وأمه في السادسة صار عنده رجل يملأ الدورين معاً فعبد المطلب أب وأم وحامٍ ومعلّم.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav', sourceRef: 'Ibn Hisham | Al-Raheeq Al-Makhtum, Ch. 5', sourceRefAr: 'ابن هشام | الرحيق المختوم، الفصل 5'),
      SceneHotspot(id: 'second_loss', x: 0.50, y: 0.25, icon: '🕊️', label: 'The Second Loss', labelAr: 'الخسارة الثانية',
        fragment: 'Abd al-Muttalib dies when Muhammad \uFDFA is eight years old. The boy walks behind the funeral, weeping. Before he dies, he entrusts the child to Abu Talib. Three losses before the age of eight. The Quran would later say: "Did He not find you an orphan and give you shelter?"',
        fragmentAr: 'يموت عبد المطلب ومحمد ﷺ في الثامنة من عمره فيمشي الصبي خلف الجنازة يبكي وقد فقد الآن أباه وأمه وجدّه: ثلاث خسارات قبل سن الثامنة. لكن قبل أن يموت يتخذ الشيخ الكبير قراره الأخير فيستدعي ابنه أبا طالب ويعهد إليه بالطفل: "اعتنِ به." وأبو طالب يقبل وسيحفظ هذا العهد أربعين سنة قادمة يحمي فيها النبي ﷺ في الفقر والاضطهاد والمنفى. سلسلة الرعاية تستمر فالله لا يترك مختاريه بلا حماية والقرآن سيخاطبه لاحقاً: "أَلَمْ يَجِدْكَ يَتِيمًا فَآوَىٰ؟"',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav', sourceRef: 'Quran 93:6 | Al-Raheeq Al-Makhtum, Ch. 5', sourceRefAr: 'القرآن 93:6 | الرحيق المختوم، الفصل 5',
        didYouKnow: 'Every guardian was chosen by Allah to prepare him. The Quran addresses his orphanhood directly: "Did He not find you an orphan and give you shelter?"',
        didYouKnowAr: 'عاش النبي ﷺ وفاة جدّه وهو في الثامنة وكان قد فقد أباه قبل أن يُولد وأمه في السادسة. القرآن يخاطبه مباشرة: "أَلَمْ يَجِدْكَ يَتِيمًا فَآوَىٰ؟" فكل وليّ أمر كان مختاراً من الله ليُعدّه لما هو قادم.'),
    ],
    // Pattern C — diamond: Start → H1 bottom → H2 left → H3 top → H4 right
    pathWaypoints: const [Offset(0.50, 0.78), Offset(0.50, 0.70), Offset(0.50, 0.60), Offset(0.36, 0.52), Offset(0.22, 0.42), Offset(0.36, 0.34), Offset(0.50, 0.25), Offset(0.64, 0.34), Offset(0.78, 0.42)],
    skyGradient: const [Color(0xFF000000), Color(0xFF000000)],
    particleType: ParticleType.dust, particleCount: 20, particleColor: const Color(0x40C9A84C), showGrain: true,
  ),

  // ── Event 8: The Guardian: Abu Talib (j_1_2_3, globalOrder 8) ─────────────
  'j_1_2_3': SceneConfig(
    hubLayers: _meccaHubLayers,
    groundLayers: const [],
    hotspots: const [
      SceneHotspot(id: 'table', x: 0.22, y: 0.52, icon: '🏠', label: 'A Place at His Table', labelAr: 'مكان على مائدته',
        fragment: 'Abu Talib is not a wealthy man. He has children of his own and barely enough to feed them. But he takes the orphan in without hesitation. The people notice: when his children eat separately, they do not get full. But when Muhammad \uFDFA sits down to eat with them, everyone is satisfied. The blessing that followed this child from Halimah\'s tent has followed him here.',
        fragmentAr: 'أبو طالب ليس رجلاً ثرياً فلديه أبناؤه ويكاد لا يجد ما يكفيهم لكنه يأخذ اليتيم دون تردد ويمنحه مكاناً في مائدته ومكاناً في بيته ومكاناً في قلبه. من حول أبي طالب يلاحظون أمراً عجيباً: حين يأكل أبناؤه وحدهم لا يشبعون لكن حين يجلس محمد ﷺ ليأكل معهم يشبع الجميع فالطعام يكفي أكثر والبيت يبدو أملأ. أبو طالب يراه وزوجته تراه فالبركة التي رافقت هذا الطفل منذ خيمة حليمة تبعته إلى هنا.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav', sourceRef: 'Ibn Hisham | Al-Raheeq Al-Makhtum, Ch. 5', sourceRefAr: 'ابن هشام | الرحيق المختوم، الفصل 5'),
      SceneHotspot(id: 'road_north', x: 0.42, y: 0.46, icon: '🐪', label: 'The Road North', labelAr: 'الطريق شمالاً',
        fragment: 'When Muhammad \uFDFA is twelve years old, Abu Talib prepares to join a trade caravan heading to Syria. The boy clings to him and begs to come along. Abu Talib cannot bear to leave him behind. He takes him on the long desert road north. For the first time, Muhammad \uFDFA sees the world beyond Mecca. And his uncle makes sure he sees it safely.',
        fragmentAr: 'حين يبلغ محمد ﷺ الثانية عشرة يستعد أبو طالب للانضمام إلى قافلة تجارية متجهة إلى الشام فيتعلق الصبي به ويتوسل أن يصطحبه وأبو طالب لا يطيق تركه فيأخذه في الطريق الصحراوي الطويل شمالاً. يضع نفسه بين الصبي والشمس ويطمئن عليه في كل استراحة ويحرسه وهو نائم. القافلة تعبر مساحات شاسعة من الرمال وتمر بأودية ومستوطنات لم يرها الصبي قط فللمرة الأولى يرى محمد ﷺ العالم خارج مكة وعمّه يتأكد أنه يراه بأمان.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav', sourceRef: 'Sahih Bukhari #3884 | Al-Raheeq Al-Makhtum, Ch. 6', sourceRefAr: 'صحيح البخاري #3884 | الرحيق المختوم، الفصل 6',
        didYouKnow: 'The twelve year old boy held onto his uncle and said: "How can you leave me? I have no father and no mother." Abu Talib\'s heart broke, and he took the boy with him.',
        didYouKnowAr: 'كان النبي ﷺ متعلقاً بأبي طالب قبل هذه الرحلة لدرجة أن الصبي ذا الاثنتي عشرة سنة تعلّق بعمّه حين همّت القافلة بالرحيل وقال: "كيف تتركني وليس لي أب ولا أم؟" فانكسر قلب أبي طالب وأخذه معه.'),
      SceneHotspot(id: 'quiet_respect', x: 0.62, y: 0.40, icon: '⭐', label: 'Quiet Respect', labelAr: 'احترام هادئ',
        fragment: 'On this journey, the young Muhammad \uFDFA sees the markets of Busra, the caravans from distant lands. He watches, listens, and learns. He speaks little but observes everything. The merchants notice him. He does not cheat. He does not lie. Even at twelve, people sense that this is not an ordinary child.',
        fragmentAr: 'في هذه الرحلة يرى محمد ﷺ الصغير العالم خارج مكة للمرة الأولى فيرى أسواق بُصرى والقوافل من أراضٍ بعيدة والثقافات التي تتاجر مع الجزيرة. يراقب ويسمع ويتعلم ويتكلم قليلاً لكنه يلاحظ كل شيء. التجار يلاحظونه فشيء في هذا الصبي يفرض احتراماً هادئاً إذ لا يغش ولا يكذب ولا يجادل ولا يتفاخر، وحتى في الثانية عشرة يحس الناس أن هذا ليس طفلاً عادياً. الصفات نفسها التي ستمنحه يوماً لقب "الأمين" تتشكل بهدوء في ظل قافلة عمّه.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav', sourceRef: 'Ibn Hisham | Al-Raheeq Al-Makhtum, Ch. 6', sourceRefAr: 'ابن هشام | الرحيق المختوم، الفصل 6'),
      SceneHotspot(id: 'shield', x: 0.80, y: 0.34, icon: '🛡️', label: 'The Shield', labelAr: 'الدرع',
        fragment: 'Abu Talib will protect Muhammad \uFDFA for the next forty years. When Quraysh demands that Abu Talib hand over his nephew, he refuses. He never embraces Islam himself, but his love becomes a shield that Allah uses to protect His prophet. When he dies, the Prophet \uFDFA will call that year the Year of Grief.',
        fragmentAr: 'سيحمي أبو طالب محمداً ﷺ أربعين سنة قادمة في الطفولة وفي الدعوة المبكرة إلى الإسلام وفي الاضطهاد الذي يلي. حين تطالب قريش أبا طالب بتسليم ابن أخيه يرفض وحين يهددونه بالحرب والعزلة يصمد وحين يعرضون عليه المال والسلطة مقابل الصبي يردّهم. لا يعتنق الإسلام بنفسه لكن حبّه يصبح درعاً يستخدمه الله لحماية نبيّه. بدون أبي طالب ربما لم تنجُ الرسالة في سنواتها الأولى. القرآن يقول: "أَلَمْ يَجِدْكَ يَتِيمًا فَآوَىٰ؟" وأبو طالب كان جزءاً من ذلك الإيواء وحين يموت سيسمّي النبي ﷺ ذلك العام عام الحزن.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav', sourceRef: 'Quran 93:6 | Sahih Bukhari #3884 | Al-Raheeq Al-Makhtum, Ch. 6', sourceRefAr: 'القرآن 93:6 | صحيح البخاري #3884 | الرحيق المختوم، الفصل 6',
        didYouKnow: 'When Abu Talib died in 619 CE, the persecution became so severe that the Prophet \uFDFA was forced to seek support outside Mecca. He called that year "the Year of Grief" because he also lost Khadijah in the same period.',
        didYouKnowAr: 'حين مات أبو طالب سنة 619م فقد النبي ﷺ حمايته السياسية في مكة واشتد الاضطهاد حتى اضطر لطلب النصرة خارج المدينة وسمّى ذلك العام "عام الحزن" لأنه فقد خديجة أيضاً في الفترة نفسها.'),
    ],
    // Pattern B — left to right
    pathWaypoints: const [Offset(0.12, 0.58), Offset(0.17, 0.55), Offset(0.22, 0.52), Offset(0.32, 0.49), Offset(0.42, 0.46), Offset(0.52, 0.43), Offset(0.62, 0.40), Offset(0.72, 0.37), Offset(0.80, 0.34)],
    skyGradient: const [Color(0xFF000000), Color(0xFF000000)],
    particleType: ParticleType.dust, particleCount: 20, particleColor: const Color(0x40B8986E), showGrain: true,
  ),

  // ── Event 9: Hilf al-Fudul (j_1_2_4) — Pattern D (center outward) ────────
  'j_1_2_4': SceneConfig(
    hubLayers: _meccaHubLayers,
    groundLayers: const [],
    hotspots: const [
      SceneHotspot(id: 'merchant_cry', x: 0.50, y: 0.65, icon: '📢', label: 'The Merchant\'s Cry', labelAr: 'صرخة التاجر',
        fragment: 'A Yemeni merchant stands near the Ka\'bah, his voice breaking. He came to Mecca to trade, sold his goods to a man of Quraysh, and was never paid. He has no tribe in this city. No one to demand his rights. So he does the only thing left to him: he stands in the most public place in Mecca and cries out to anyone who still believes that honor means something.',
        fragmentAr: 'تاجر يمني يقف قرب الكعبة وصوته يتكسّر من الإحباط، فقد جاء إلى مكة وباع بضاعته لرجل من قريش ولكنه لم يحصل على حقه. ليس له في هذه المدينة قبيلة تحميه ولا ظهر يسنده ولا أحد يقف بجانبه ويطالب بما هو له.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Ibn Hisham | Al-Raheeq Al-Makhtum, Ch. 6', sourceRefAr: 'ابن هشام | الرحيق المختوم، الفصل 6'),
      SceneHotspot(id: 'ibn_judan', x: 0.25, y: 0.42, icon: '🏛️', label: 'House of Ibn Jud\'an', labelAr: 'دار ابن جدعان',
        fragment: 'The noblest clans gather in the house of Abdullah ibn Jud\'an and swear a covenant: from this day forward, they will stand as one against any injustice committed in Mecca. No victim, whether born in the city or passing through, will be denied their rights while these men draw breath. The Yemeni merchant gets his money back that very night.',
        fragmentAr: 'أشرف أحياء المدينة يجتمعون في دار عبد الله بن جدعان ويقسمون عهداً: من هذا اليوم سيقفون صفاً واحداً ضد أي ظلم يُرتكب في مكة. لن يُحرم مظلوم من حقه ما داموا أحياء. التاجر اليمني يسترد ماله في تلك الليلة نفسها.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Ibn Hisham | Al-Raheeq Al-Makhtum, Ch. 6', sourceRefAr: 'ابن هشام | الرحيق المختوم، الفصل 6',
        didYouKnow: 'The name "Hilf al-Fudul" means "The Pact of the Virtuous." It was named after an older pact from generations before where three men named al-Fadl joined together to defend the oppressed.',
        didYouKnowAr: 'اسم "حلف الفضول" يعني عهد أصحاب الفضل، وقد سمّوه على اسم حلف قديم من أجيال سابقة حيث اجتمع ثلاثة رجال يحملون اسم الفضل للدفاع عن المظلومين.'),
      SceneHotspot(id: 'silent_witness', x: 0.75, y: 0.42, icon: '👁️', label: 'The Silent Witness', labelAr: 'الشاهد الصامت',
        fragment: 'Among those present is a young man not yet twenty years old. His name is Muhammad \uFDFA. He does not speak during the gathering. He does not lead the oath. But he is there, watching. He watches the powerful choose justice over tribal loyalty. This moment plants something deep in him: justice is not a virtue you practice when convenient. It is a duty that does not expire.',
        fragmentAr: 'بين الحاضرين شاب لم يبلغ العشرين بعد اسمه محمد \uFDFA. لا يتكلم خلال الاجتماع ولا يقود القسم ولكنه هناك يراقب بعينيه. يشاهد كيف يختار الأقوياء العدل فوق الولاء القبلي. هذه اللحظة تزرع في نفسه شيئاً عميقاً لن يقتلعه الزمن مهما طال: أن العدل ليس فضيلة يمارسها المرء حين يشاء بل واجب لا تنتهي صلاحيته أبداً.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Ibn Hisham | Al-Raheeq Al-Makhtum, Ch. 6', sourceRefAr: 'ابن هشام | الرحيق المختوم، الفصل 6'),
      SceneHotspot(id: 'pact_forever', x: 0.50, y: 0.25, icon: '💬', label: 'A Pact That Never Expired', labelAr: 'حلف لم تنتهِ صلاحيته',
        fragment: 'Decades later, the Prophet \uFDFA remembers this night. He says: "I witnessed a pact in the house of Ibn Jud\'an so excellent that I would not exchange my part in it for a herd of red camels. And if I were called to it in Islam, I would answer." Justice before Islam was still justice. Islam did not come to erase what was right. It came to complete it.',
        fragmentAr: 'بعد عقود طويلة وقد صار نبياً يُوحى إليه وتغيّر وجه الجزيرة، تذكّر محمد \uFDFA تلك الليلة ويقول: "شهدت في دار ابن جدعان حلفاً لا أحب أن لي به حُمر النعم ولو دُعيت إليه في الإسلام لأجبت." العدل الذي كان قبل الإسلام لا يزال عدلاً، والإسلام لم يأتِ ليمحو ما كان صواباً بل جاء ليتممه.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Musnad Ahmad | Al-Bayhaqi | Ibn Hisham | Al-Raheeq Al-Makhtum, Ch. 6', sourceRefAr: 'مسند أحمد | البيهقي | ابن هشام | الرحيق المختوم، الفصل 6',
        didYouKnow: 'The Prophet \uFDFA praised this pact even after Islam, calling it "excellent." Scholars use this hadith to this day when discussing universal justice across cultures and religions.',
        didYouKnowAr: 'أثنى النبي \uFDFA على هذا الحلف حتى بعد الإسلام ووصفه بالتميّز. ويستشهد العلماء بهذا الحديث حتى يومنا هذا حين يناقشون العدالة الشاملة عبر الثقافات والأديان.'),
    ],
    // Pattern D — center outward
    pathWaypoints: const [Offset(0.50, 0.55), Offset(0.50, 0.60), Offset(0.50, 0.65), Offset(0.38, 0.54), Offset(0.25, 0.42), Offset(0.50, 0.42), Offset(0.75, 0.42), Offset(0.62, 0.34), Offset(0.50, 0.25)],
    skyGradient: const [Color(0xFF000000), Color(0xFF000000)],
    showStars: true,
    particleType: ParticleType.dust, particleCount: 15, particleColor: const Color(0x40C9A84C), showGrain: true,
  ),

  // ── Event 10: Al-Amin (j_m1_010) — Pattern A (bottom to top) ─────────────
  'j_m1_010': SceneConfig(
    hubLayers: _meccaHubLayers,
    groundLayers: const [],
    hotspots: const [
      SceneHotspot(id: 'the_name', x: 0.50, y: 0.62, icon: '✨', label: 'The Name', labelAr: 'الاسم',
        fragment: 'No one decided to call him Al-Amin. No tribe voted on it. The name grew on its own because every person who dealt with him found the same thing: he did not lie, he did not cheat, and he did not break a promise. In a city where merchants inflated prices and poets twisted truth for pay, one young man\'s word was worth more than a contract. They called him The Trustworthy not because he claimed it but because they could not call him anything else.',
        fragmentAr: 'لم يقرر أحد أن يسمّيه الأمين ولم تصوّت عليه قبيلة ولم يمنحه إياه زعيم. الاسم نما وحده لأن كل من تعامل معه وجد الشيء نفسه: لا يكذب ولا يغش ولا يخلف وعداً. في مدينة يبالغ فيها التجار بالأسعار ويلوّي الشعراء فيها الحقيقة لقاء أجر، كانت كلمة شاب واحد أثمن من أي عقد. سمّوه الأمين لا لأنه ادّعى ذلك بل لأنهم لم يجدوا اسماً آخر يليق به.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Ibn Hisham | Al-Raheeq Al-Makhtum, Ch. 6', sourceRefAr: 'ابن هشام | الرحيق المختوم، الفصل 6'),
      SceneHotspot(id: 'keeper_trusts', x: 0.25, y: 0.44, icon: '🔒', label: 'Keeper of Trusts', labelAr: 'حافظ الأمانات',
        fragment: 'The people of Mecca began leaving their most precious belongings with him for safekeeping. Gold, documents, goods they feared losing. They trusted no vault as much as they trusted this man. Even those who would later oppose him left their belongings in his care. On the night he left Mecca for Medina, years later, one of his final instructions was to return every trust to its owner.',
        fragmentAr: 'أهل مكة بدأوا يودعون عنده أثمن ما يملكون حفظاً لها: ذهباً ووثائق وبضائع يخافون عليها من السرقة أو النزاع. لم يثقوا بخزنة ولا بصندوق حديد بقدر ثقتهم بهذا الرجل. حتى الذين سيعادونه لاحقاً تركوا أماناتهم عنده. في الليلة التي غادر فيها مكة إلى المدينة بعد سنين كانت إحدى آخر وصاياه أن تُردّ كل أمانة إلى صاحبها.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Ibn Hisham | Al-Raheeq Al-Makhtum, Ch. 6', sourceRefAr: 'ابن هشام | الرحيق المختوم، الفصل 6',
        didYouKnow: 'When the Prophet \uFDFA migrated to Medina, he asked Ali ibn Abi Talib to stay behind in Mecca specifically to return the trusts that people had deposited with him. Even as they plotted to kill him, their belongings were still safe in his home.',
        didYouKnowAr: 'حين هاجر النبي \uFDFA إلى المدينة طلب من علي بن أبي طالب أن يبقى في مكة خصيصاً لإعادة الأمانات التي أودعها الناس عنده، وحتى وهم يتآمرون لقتله كانت ممتلكاتهم لا تزال آمنة في بيته.'),
      SceneHotspot(id: 'honest_trader', x: 0.72, y: 0.42, icon: '⚖️', label: 'The Honest Trader', labelAr: 'التاجر الأمين',
        fragment: 'He enters the trade business and travels with caravans. Every transaction he touches is clean. Word spreads among the merchants: if you want an honest partner, there is only one name. A wealthy widow named Khadijah hears about him. She has a trade caravan heading to Syria and needs someone she can trust. His reputation reaches her before he ever speaks a word to her. What her servant Maysarah reports back will change everything.',
        fragmentAr: 'يدخل عالم التجارة ويسافر مع القوافل وكل معاملة يدخلها نظيفة. الخبر ينتشر بين تجار مكة: إن أردت شريكاً أميناً فليس هناك إلا اسم واحد. أرملة ثرية اسمها خديجة بنت خويلد تسمع عنه ولديها قافلة تجارية متجهة إلى الشام وتحتاج من تأتمنه على مالها كله. سمعته تصل إليها قبل أن ينطق بكلمة واحدة أمامها. وما سيخبرها به ميسرة عند العودة سيغيّر كل شيء.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Ibn Hisham | Al-Raheeq Al-Makhtum, Ch. 6', sourceRefAr: 'ابن هشام | الرحيق المختوم، الفصل 6'),
      SceneHotspot(id: 'foundation', x: 0.50, y: 0.28, icon: '🏔️', label: 'A Foundation, Not a Title', labelAr: 'أساس لا لقب',
        fragment: 'Years from now, when he stands on Mount Safa and calls the people of Mecca to Islam, he will ask them: "If I told you there was an army behind this mountain about to attack you, would you believe me?" They will answer without hesitation: "Yes. We have never known you to lie." His character preceded his mission. Allah built the messenger before He sent the message. Al-Amin was not a title. It was a foundation on which a prophet would stand and a civilization would rise.',
        fragmentAr: 'بعد سنوات حين يقف على جبل الصفا ويدعو أهل مكة إلى الإسلام سيسألهم: "لو أخبرتكم أن جيشاً خلف هذا الجبل يوشك أن يغزوكم أكنتم مصدّقوني؟" سيجيبون دون تردد: "نعم لا جرّبنا عليك كذباً قط." شخصيته سبقت رسالته والله بنى الرسول قبل أن يُنزل الرسالة. كل تجارة نزيهة وكل وعد وفّى به وكل أمانة أدّيت كانت إعداداً لما هو قادم. الأمين لم يكن لقباً بل كان أساساً سيقف عليه نبيّ وتنهض فوقه حضارة.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Sahih Bukhari #4971 | Ibn Hisham | Al-Raheeq Al-Makhtum, Ch. 6', sourceRefAr: 'صحيح البخاري #4971 | ابن هشام | الرحيق المختوم، الفصل 6',
        didYouKnow: 'The Mount Safa moment happened years after he received prophethood. But it only worked because of decades of trust built one transaction at a time. When he asked "would you believe me?" the entire crowd said yes. That single "yes" was the product of a lifetime of integrity.',
        didYouKnowAr: 'لحظة جبل الصفا حدثت بعد سنوات من نزول الوحي عليه، ولكنها نجحت فقط بسبب عقود من الثقة بُنيت معاملة تلو معاملة. حين سألهم "أكنتم مصدّقوني؟" أجاب الجمع كله بنعم. تلك النعم الواحدة كانت ثمرة عمر كامل من النزاهة.'),
    ],
    // Pattern A — bottom to top
    pathWaypoints: const [Offset(0.50, 0.80), Offset(0.51, 0.72), Offset(0.50, 0.62), Offset(0.38, 0.54), Offset(0.25, 0.44), Offset(0.45, 0.42), Offset(0.72, 0.42), Offset(0.63, 0.36), Offset(0.50, 0.28)],
    skyGradient: const [Color(0xFF000000), Color(0xFF000000)],
    particleType: ParticleType.dust, particleCount: 20, particleColor: const Color(0x40C9A84C), showGrain: true,
  ),

  // ── Event 11: Marriage to Khadijah (j_m1_011) — Pattern C (diamond) ───────
  'j_m1_011': SceneConfig(
    hubLayers: _meccaHubLayers,
    groundLayers: const [],
    hotspots: const [
      SceneHotspot(id: 'trade_caravan', x: 0.50, y: 0.60, icon: '🐪', label: 'The Trade Caravan', labelAr: 'القافلة التجارية',
        fragment: 'Khadijah bint Khuwaylid was one of the noblest women of Quraysh and among the wealthiest merchants in all of Mecca. She was known for her sharp intellect, her dignity, and the way she carried herself among the leaders of her people. When she heard of a young man called Al-Amin, she offered him a place leading her trade caravan to Syria. She sent with him her servant Maysarah to observe him closely.',
        fragmentAr: 'كانت خديجة بنت خويلد من أشرف نساء قريش وأكثرهن مالاً في مكة كلها. عُرفت بذكائها الحاد وكرامتها وطريقتها في التعامل مع سادة قومها. فلما بلغها خبر شابّ يُدعى الأمين اشتُهر في مكة بصدقه وأمانته عرضت عليه أن يقود قافلتها التجارية إلى الشام وأرسلت معه خادمها ميسرة ليراقبه عن كثب.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Ibn Hisham | Al-Raheeq Al-Makhtum, Ch. 6', sourceRefAr: 'ابن هشام | الرحيق المختوم، الفصل 6',
        didYouKnow: 'Khadijah was known by the title "The Pure One" (al-Tahirah) even before Islam, a reflection of her character and standing among the people of Mecca.',
        didYouKnowAr: 'عُرفت خديجة بلقب "الطاهرة" حتى قبل الإسلام وهو انعكاس لأخلاقها ومكانتها بين أهل مكة.'),
      SceneHotspot(id: 'the_return', x: 0.22, y: 0.42, icon: '📦', label: 'The Return', labelAr: 'العودة',
        fragment: 'The caravan returned to Mecca with profit far greater than anything Khadijah had seen before. But it was not the wealth that moved her. Maysarah came to her with a full account of what he had witnessed. He spoke of a man who never raised his voice in anger, who dealt with every merchant with fairness that left them astonished, who gave to those in need without being asked.',
        fragmentAr: 'عادت القافلة إلى مكة بربح فاق كل ما عرفته خديجة من قبل. لكن المال لم يكن ما حرّك قلبها. فقد جاءها ميسرة بتقرير كامل عمّا شهده. تحدّث عن رجل لم يرفع صوته غضباً قط وتعامل مع كل تاجر بإنصاف أدهشهم وأعطى المحتاجين دون أن يُسأل.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Ibn Hisham | Al-Raheeq Al-Makhtum, Ch. 6', sourceRefAr: 'ابن هشام | الرحيق المختوم، الفصل 6',
        didYouKnow: 'Some narrations mention that the profit Khadijah earned from that single caravan was double what she typically made, a testament to his blessed presence and honest dealings.',
        didYouKnowAr: 'تذكر بعض الروايات أن الربح الذي حققته خديجة من تلك القافلة وحدها كان ضعف ما اعتادت عليه وهو دليل على بركة حضوره وصدق تعامله.'),
      SceneHotspot(id: 'the_proposal', x: 0.78, y: 0.42, icon: '💍', label: 'The Proposal', labelAr: 'الخِطبة',
        fragment: 'Khadijah confided in her close friend Nafisah bint Munyah and asked her to approach him on her behalf. Nafisah asked him gently why he had not yet married. He replied that he did not have the means. She then asked if a woman of beauty, wealth, nobility, and good character were to offer herself in marriage, would he accept? When Nafisah said the name Khadijah, his face brightened. It was Khadijah who chose. It was Khadijah who initiated.',
        fragmentAr: 'أفضت خديجة بما في نفسها إلى صديقتها المقربة نفيسة بنت منية وطلبت منها أن تذهب إليه نيابةً عنها. فذهبت نفيسة إليه وسألته برفق لماذا لم يتزوج بعد. فأجاب أنه لا يملك ما يكفي لذلك. فسألته إن عُرضت عليه امرأة ذات جمال ومال وشرف وخُلق أيقبل؟ فلما نطقت باسم خديجة أشرق وجهه. كانت خديجة هي من اختارت وهي من بادرت.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Ibn Hisham | Ibn Sa\'d | Al-Raheeq Al-Makhtum, Ch. 6', sourceRefAr: 'ابن هشام | ابن سعد | الرحيق المختوم، الفصل 6',
        didYouKnow: 'Nafisah bint Munyah is one of the unsung women of the Seerah. Without her role as intermediary, this historic marriage might never have happened the way it did.',
        didYouKnowAr: 'نفيسة بنت منية من النساء المغمورات في السيرة النبوية. فلولا دورها كوسيطة لربما لم يتم هذا الزواج التاريخي بالصورة التي حدث بها.'),
      SceneHotspot(id: 'the_marriage', x: 0.50, y: 0.25, icon: '🕌', label: 'The Marriage', labelAr: 'الزواج',
        fragment: 'Abu Talib delivered the marriage khutbah, praising his nephew\'s character, lineage, and standing. The mahr was twenty young camels. He was twenty-five. Khadijah was forty. From that day forward, she became his closest companion, the first to believe in him, the one who stood beside him when the entire world turned away. No other marriage in the history of the Seerah carries the weight that this one does.',
        fragmentAr: 'وقف أبو طالب أمام الحضور وألقى خطبة النكاح مادحاً خُلق ابن أخيه ونسبه ومكانته بين الناس. وكان المهر عشرين بكرة من الإبل الفتية. كان عمره خمساً وعشرين سنة وكانت خديجة في الأربعين. ومنذ ذلك اليوم صارت أقرب صحبه إليه وأول من آمن به والتي وقفت بجانبه حين أدار العالم كله ظهره. ولا يحمل زواج آخر في تاريخ السيرة كلها الثقل الذي حمله هذا الزواج.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Sahih Bukhari #3818 | Ibn Hisham | Al-Raheeq Al-Makhtum, Ch. 6', sourceRefAr: 'صحيح البخاري #3818 | ابن هشام | الرحيق المختوم، الفصل 6',
        didYouKnow: 'Khadijah was the only wife of the Prophet \uFDFA during her lifetime. He did not marry anyone else until after her passing, and he continued to speak of her with love and reverence for the rest of his life.',
        didYouKnowAr: 'كانت خديجة الزوجة الوحيدة للنبي \uFDFA طوال حياتها. فلم يتزوج غيرها حتى بعد وفاتها وظل يذكرها بالحب والتبجيل بقية حياته.'),
    ],
    // Pattern C — diamond
    pathWaypoints: const [Offset(0.50, 0.78), Offset(0.50, 0.70), Offset(0.50, 0.60), Offset(0.36, 0.52), Offset(0.22, 0.42), Offset(0.50, 0.42), Offset(0.78, 0.42), Offset(0.64, 0.34), Offset(0.50, 0.25)],
    skyGradient: const [Color(0xFF000000), Color(0xFF000000)],
    particleType: ParticleType.dust, particleCount: 20, particleColor: const Color(0x40C9A84C), showGrain: true,
  ),
};
