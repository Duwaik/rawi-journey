import 'dart:ui';
import '../models/scene_config.dart';
import '../widgets/cinematic/parallax_scene.dart';

/// Shared hub layers for Mecca events — single scene image.
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
        fragment: 'The Ka\'bah stands — built by Ibrahim \uFDFA and his son Ismail \uFDFA as a house of the One God. That memory lingers in the stones, even as 360 idols press against them from every side. Something is coming. You can feel it in the desert wind.',
        fragmentAr: 'الكعبة تقف — بناها إبراهيم \uFDFA وابنه إسماعيل \uFDFA بيتاً للإله الواحد. تلك الذكرى لا تزال حيّة في الحجارة، حتى وإن تزاحمت 360 صنماً حولها. شيء ما قادم. تحسّه في ريح الصحراء.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        imagePath: 'assets/scenes/bubble_kaabah.jpg',
        ambientPath: 'assets/audio/ambient/ambient_e1_kaabah.mp3',
        sourceRef: 'Al-Raheeq Al-Makhtum, Ch. 1',
        sourceRefAr: 'الرحيق المختوم، الفصل 1',
        didYouKnow: 'The Ka\'bah was originally built by Ibrahim ﷺ and his son Ismail ﷺ as a house of pure monotheism — with no roof, open to the sky.',
        didYouKnowAr: 'الكعبة بناها إبراهيم ﷺ وابنه إسماعيل ﷺ أصلاً بيتاً للتوحيد الخالص — بلا سقف، مفتوحة على السماء.',
      ),
      SceneHotspot(
        id: 'idols',
        x: 0.25, y: 0.45,
        icon: '🗿',
        label: 'The Idol Shrines',
        labelAr: 'معابد الأصنام',
        fragment: 'Three hundred and sixty stone figures watch you with empty eyes. The air is thick with incense smoke drifting from the shrines that crowd around the ancient house. Each tribe has placed its god here — as if proximity to the Ka\'bah could grant them truth.',
        fragmentAr: 'ثلاثمئة وستون تمثالاً حجرياً يحدّقون فيك بعيون فارغة. الهواء ثقيل بدخان البخور المتصاعد من المعابد المتراصة حول البيت العتيق. كل قبيلة وضعت إلهها هنا — وكأن القرب من الكعبة يمنحهم الحقيقة.',
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
        fragment: 'A poet recites verses of breathtaking beauty about honor and courage — while a few streets away, a man buries his newborn daughter in the sand without a word. The world moves in contradictions.\n\nYou have walked through this courtyard. You have seen the wealth and the poverty, the devotion and the emptiness. Now the poet falls silent, and you are left with the question that hangs in the desert air —',
        fragmentAr: 'شاعر ينشد أبياتاً خلابة عن الشرف والشجاعة — بينما على بعد أزقة قليلة، رجل يدفن ابنته الوليدة في الرمال دون كلمة. العالم يتحرك في تناقضات.\n\nمشيت في هذا الفناء. رأيت الثروة والفقر، العبادة والفراغ. الآن يصمت الشاعر، وتبقى أنت مع السؤال المعلّق في هواء الصحراء —',
        sfxPath: 'assets/audio/sfx_poet_crowd.wav',
        imagePath: 'assets/scenes/bubble_poet.jpg',
        sourceRef: 'Al-Raheeq Al-Makhtum, Ch. 2',
        sourceRefAr: 'الرحيق المختوم، الفصل 2',
        didYouKnow: 'Pre-Islamic poets held the same status as media does today — their verses could make or break a tribe\'s reputation across all of Arabia.',
        didYouKnowAr: 'الشعراء في الجاهلية كانوا بمنزلة الإعلام اليوم — قصائدهم كانت تصنع سمعة القبيلة أو تدمرها في أنحاء الجزيرة.',
      ),
      SceneHotspot(
        id: 'merchants',
        x: 0.75, y: 0.45,
        icon: '🏺',
        label: 'The Merchants',
        labelAr: 'التجّار',
        fragment: 'Merchants haggle over silk and spices on trade routes stretching from Yemen to Syria — while the poor beg at the Ka\'bah walls, invisible to those who pass. Wealth flows, but justice does not.',
        fragmentAr: 'تجّار يساومون على الحرير والتوابل في طرق تجارية تمتد من اليمن إلى الشام — بينما الفقراء يستجدون عند جدران الكعبة، لا يراهم أحد. المال يتدفق، لكن العدل لا.',
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
        fragment: 'The horizon to the south is dark with dust. Abraha al-Ashram — the ruler of Yemen — marches with war elephants and thousands of soldiers. His mission: destroy the Ka\'bah and redirect the Arabs\' pilgrimage to a grand church he built in San\'a.',
        fragmentAr: 'الأفق جنوباً مظلم بالغبار. أبرهة الأشرم — حاكم اليمن — يزحف بأفيال حرب وآلاف الجنود. مهمته: تدمير الكعبة وتحويل حج العرب إلى كنيسة فخمة بناها في صنعاء.',
        sfxPath: 'assets/audio/sfx_army_march.wav',
        imagePath: 'assets/scenes/bubble_army.jpg',
        sourceRef: 'Al-Raheeq Al-Makhtum, Ch. 5 | Quran 105:1-5',
        sourceRefAr: 'الرحيق المختوم، الفصل 5 | القرآن 105:1-5',
        didYouKnow: 'Abraha built a massive cathedral in Sana\'a called Al-Qullays to divert the Arab pilgrimage away from the Ka\'bah — but the Arabs refused to abandon the ancient house.',
        didYouKnowAr: 'بنى أبرهة كنيسة ضخمة في صنعاء تُسمى القُلّيس لتحويل حج العرب عن الكعبة — لكن العرب رفضوا هجر البيت العتيق.',
      ),
      SceneHotspot(
        id: 'muttalib',
        x: 0.75, y: 0.40,
        icon: '👤',
        label: 'Abd al-Muttalib',
        labelAr: 'عبد المطلب',
        fragment: '"I am the lord of the camels. The Ka\'bah has a Lord who will protect it." Abd al-Muttalib stood before Abraha and asked only for his camels — not for the sacred house. He told his people to withdraw to the mountains.',
        fragmentAr: '"أنا ربّ الإبل. وللبيت ربّ يحميه." وقف عبد المطلب أمام أبرهة ولم يطلب إلا إبله — لا البيت الحرام. وأمر قومه بالانسحاب إلى الجبال.',
        sfxPath: 'assets/audio/sfx_muttalib_silence.wav',
        imagePath: 'assets/scenes/bubble_muttalib.jpg',
        sourceRef: 'Al-Raheeq Al-Makhtum, Ch. 5',
        sourceRefAr: 'الرحيق المختوم، الفصل 5',
        didYouKnow: 'When Abraha\'s general took Abd al-Muttalib\'s camels, he went to negotiate — but only asked for his camels back, not for the Ka\'bah\'s protection. He said: "I am the lord of the camels. As for the House, it has a Lord who will protect it."',
        didYouKnowAr: 'حين أخذ قائد أبرهة إبل عبد المطلب، ذهب للتفاوض — لكنه طالب فقط بإبله، لا بحماية الكعبة. قال: "أنا ربّ الإبل، وللبيت ربٌّ يحميه."',
      ),
      SceneHotspot(
        id: 'elephants',
        x: 0.22, y: 0.42,
        icon: '🐘',
        label: 'The Elephants',
        labelAr: 'الأفيال',
        fragment: 'The elephants halt at the boundary of the sacred precinct and refuse to move forward. The great beasts kneel, no matter how hard their riders strike. Something unseen holds them back.',
        fragmentAr: 'الأفيال تتوقف عند حدود الحرم وترفض التحرك. الحيوانات الضخمة تركع، مهما ضربها فرسانها. شيء خفي يمنعها.',
        sfxPath: 'assets/audio/sfx_elephants_rumble.wav',
        imagePath: 'assets/scenes/bubble_elephants.jpg',
        sourceRef: 'Al-Raheeq Al-Makhtum, Ch. 5',
        sourceRefAr: 'الرحيق المختوم، الفصل 5',
      ),
      SceneHotspot(
        id: 'birds',
        x: 0.50, y: 0.25,
        icon: '🕊️',
        label: 'The Sky Darkens',
        labelAr: 'السماء تُظلم',
        fragment: 'The sky darkens — not with clouds, but with birds. Thousands of them, resembling hawks, each carrying three stones of baked clay. The impossible unfolds before your eyes. This is divine protection.\n\nWhether you stood near the elephants or watched from the mountains — this moment finds you the same way. The sky has answered what the earth could not. And you are left with one question —',
        fragmentAr: 'السماء تُظلم — لا بالغيوم، بل بالطيور. آلاف منها، تشبه الصقور، كل طائر يحمل ثلاثة أحجار من سجيل. المستحيل يتكشّف أمام عينيك. هذه حماية إلهية.\n\nسواء وقفت قرب الأفيال أو شاهدت من الجبال — هذه اللحظة تصلك بالطريقة ذاتها. السماء أجابت ما لم تستطع الأرض. وتبقى أنت مع سؤال واحد —',
        sfxPath: 'assets/audio/sfx_birds_swarm.wav',
        imagePath: 'assets/scenes/bubble_birds.jpg',
        sourceRef: 'Al-Raheeq Al-Makhtum, Ch. 5 | Quran 105:3-4',
        sourceRefAr: 'الرحيق المختوم، الفصل 5 | القرآن 105:3-4',
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
        fragment: 'The rains came without warning — a torrent that swept through the valley and struck the ancient house. Walls crumbled. Stones shifted. The Ka\'bah, already weakened by centuries, could no longer stand as it was. The tribes of Quraysh agreed: it must be rebuilt. You watch as men carry stones from the valley, stacking them carefully. The work is slow but united — for now.',
        fragmentAr: 'جاءت الأمطار دون سابق إنذار — سيل جارف اجتاح الوادي وضرب البيت العتيق. انهارت الجدران. تزحزحت الحجارة. الكعبة، المتهالكة بفعل القرون، لم تعد تحتمل. اتفقت قبائل قريش: يجب إعادة البناء. تراقب الرجال يحملون الحجارة من الوادي، يرصّونها بعناية. العمل بطيء لكنه موحّد — في الوقت الحالي.',
        sfxPath: 'assets/audio/sfx_flood_rubble.wav',
        imagePath: 'assets/scenes/bubble_flood.jpg',
        sourceRef: 'Al-Raheeq Al-Makhtum, Ch. 6',
        sourceRefAr: 'الرحيق المختوم، الفصل 6',
        didYouKnow: 'The Ka\'bah was rebuilt several times throughout history. This particular rebuilding by Quraysh happened when Muhammad ﷺ was 35 years old — just 5 years before prophethood.',
        didYouKnowAr: 'أُعيد بناء الكعبة عدة مرات عبر التاريخ. إعادة البناء هذه على يد قريش حدثت حين كان محمد ﷺ في الخامسة والثلاثين — قبل النبوة بخمس سنوات فقط.',
      ),
      SceneHotspot(
        id: 'dispute',
        x: 0.25, y: 0.42,
        icon: '⚔️',
        label: 'The Dispute',
        labelAr: 'النزاع',
        fragment: 'The walls are nearly done. But one task remains — placing the Black Stone back in its sacred corner. And with it comes a crisis. Every tribe claims the right. You see hands gripping sword hilts. Voices rise. Four days of argument, and still no resolution. The sanctuary, meant for peace, trembles on the edge of bloodshed.',
        fragmentAr: 'الجدران شبه مكتملة. لكن مهمة واحدة بقيت — إعادة الحجر الأسود إلى ركنه المقدس. ومعها جاءت الأزمة. كل قبيلة تطالب بالحق. ترى الأيدي تقبض على مقابض السيوف. الأصوات تعلو. أربعة أيام من الخلاف، ولا حل. الحرم، المخصص للسلام، يرتجف على حافة سفك الدماء.',
        sfxPath: 'assets/audio/sfx_dispute_crowd.wav',
        imagePath: 'assets/scenes/bubble_dispute.jpg',
        sourceRef: 'Al-Raheeq Al-Makhtum, Ch. 6',
        sourceRefAr: 'الرحيق المختوم، الفصل 6',
      ),
      SceneHotspot(
        id: 'alamin',
        x: 0.72, y: 0.42,
        icon: '⭐',
        label: 'Al-Amin Enters',
        labelAr: 'دخول الأمين',
        fragment: 'At dawn, the gate of the sanctuary opens. The first man to enter is Muhammad \uFDFA — thirty-five years old, known to every tribe yet belonging to no faction. A murmur passes through the crowd: \'Al-Amin.\' The Trustworthy. No one objects. They have already placed their trust in him — long before prophethood.',
        fragmentAr: 'عند الفجر، يُفتح باب الحرم. أول من يدخل هو محمد \uFDFA — في الخامسة والثلاثين، تعرفه كل القبائل لكنه لا ينتمي لأي فريق. همسة تسري في الجمع: \'الأمين.\' لا أحد يعترض. لقد ائتمنوه — قبل النبوة بسنين.',
        sfxPath: 'assets/audio/sfx_dawn_wind.wav',
        imagePath: 'assets/scenes/bubble_alamin.jpg',
        sourceRef: 'Al-Raheeq Al-Makhtum, Ch. 6',
        sourceRefAr: 'الرحيق المختوم، الفصل 6',
      ),
      SceneHotspot(
        id: 'cloak',
        x: 0.50, y: 0.28,
        icon: '📿',
        label: 'The Wise Solution',
        labelAr: 'الحل الحكيم',
        fragment: 'He asks for a cloak. He spreads it on the ground and places the Black Stone upon it. Then he invites the leader of each tribe to take hold of a corner. Together, they lift. Together, they carry it to its place. He sets the Stone with his own hands. No tribe was denied. No blood was shed. Wisdom — before revelation.\n\nWhether you watched the swords nearly drawn or the gate where Al-Amin entered — you have arrived at the same truth. A man the world already trusted has just shown why. And the question remains —',
        fragmentAr: 'يطلب رداءً. يبسطه على الأرض ويضع الحجر الأسود فوقه. ثم يدعو زعيم كل قبيلة ليمسك بطرف. معاً يرفعون. معاً يحملونه إلى مكانه. يضع الحجر بيديه الشريفتين. لم تُحرم قبيلة. لم يُسفك دم. حكمة — قبل الوحي.\n\nسواء شاهدت السيوف تكاد تُسلّ أو الباب الذي دخل منه الأمين — وصلت إلى الحقيقة ذاتها. رجل ائتمنه العالم سلفاً أظهر للتو لماذا. والسؤال يبقى —',
        sfxPath: 'assets/audio/sfx_cloak_fabric.wav',
        imagePath: 'assets/scenes/bubble_cloak.jpg',
        sourceRef: 'Al-Raheeq Al-Makhtum, Ch. 6',
        sourceRefAr: 'الرحيق المختوم، الفصل 6',
        didYouKnow: 'The Quraysh had agreed that the first person to enter the sanctuary at dawn would be their judge. That person turned out to be Muhammad ﷺ — by Allah\'s design, not by anyone\'s arrangement.',
        didYouKnowAr: 'اتفقت قريش أن أول من يدخل الحرم عند الفجر يكون حَكَمهم. وكان ذلك الشخص محمداً ﷺ — بتدبير الله، لا بترتيب أحد.',
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
    groundLayers: const [
      ParallaxLayer(
        assetPath: 'assets/scenes/scene_event1_kaabah.jpg', // placeholder — Khaled provides night Mecca BG
        speed: 0.15,
        verticalPosition: 0.0,
        heightFraction: 1.0,
      ),
    ],
    hotspots: const [
      SceneHotspot(
        id: 'night_banu_hashim',
        x: 0.48, y: 0.62,
        icon: '🌙',
        label: 'The Night in Banu Hashim',
        labelAr: 'ليلة في بني هاشم',
        fragment: 'The Year of the Elephant has barely passed. Mecca is still shaken — the people saw an army destroyed before their eyes, stones falling from birds they had never seen. The Quraysh know something has changed, though they cannot name it. Tonight, in the quarter of Banu Hashim, a woman is in labor. The house is small. The streets are quiet. No one in Mecca knows that this night will be remembered long after the Elephant is forgotten.',
        fragmentAr: 'عام الفيل بالكاد مرّ. مكة لا تزال مهتزة — رأى الناس جيشاً يُدمَّر أمام أعينهم، حجارة تسقط من طيور لم يروها قط. قريش تعلم أن شيئاً تغيّر، لكنها لا تستطيع تسميته. الليلة، في حي بني هاشم، امرأة تضع مولوداً. البيت صغير. الأزقة هادئة. لا أحد في مكة يعلم أن هذه الليلة ستُذكر طويلاً بعد أن يُنسى الفيل.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Al-Raheeq Al-Makhtum, Ch. 5',
        sourceRefAr: 'الرحيق المختوم، الفصل 5',
      ),
      SceneHotspot(
        id: 'aminah_vision',
        x: 0.25, y: 0.45,
        icon: '✨',
        label: 'Aminah\'s Vision',
        labelAr: 'رؤيا آمنة',
        fragment: 'When Aminah carried him, she saw a vision — a light emerging from her that illuminated the palaces of distant Syria. The Prophet \uFDFA himself would later say: "I am the supplication of my father Ibrahim, the glad tidings of my brother Isa, and my mother saw when she carried me a light that illuminated the palaces of Syria." She did not yet understand what it meant. But the light was real. And the child it announced would illuminate far more than palaces.',
        fragmentAr: 'حين حملت آمنة به، رأت رؤيا — نور يخرج منها يُضيء قصور الشام البعيدة. النبي \uFDFA نفسه سيقول لاحقاً: "أنا دعوة أبي إبراهيم، وبشرى أخي عيسى، ورأت أمي حين حملت بي نوراً أضاءت له قصور الشام." لم تفهم بعد ما يعنيه ذلك. لكن النور كان حقيقياً. والطفل الذي بشّر به سيُضيء أكثر بكثير من القصور.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Musnad Ahmad | Quran 2:129, 61:6',
        sourceRefAr: 'مسند أحمد | القرآن 2:129، 61:6',
        didYouKnow: 'The Prophet ﷺ described himself as the answer to three things: Ibrahim\'s prayer for a messenger from among his descendants, Isa\'s prophecy of "a messenger after me named Ahmad," and his mother\'s vision of light.',
        didYouKnowAr: 'وصف النبي ﷺ نفسه بأنه إجابة ثلاثة أمور: دعوة إبراهيم بإرسال رسول من ذريته، وبشارة عيسى بـ"رسول يأتي من بعدي اسمه أحمد"، ورؤيا أمه بالنور.',
      ),
      SceneHotspot(
        id: 'naming_kaabah',
        x: 0.72, y: 0.42,
        icon: '🕋',
        label: 'The Naming at the Ka\'bah',
        labelAr: 'التسمية عند الكعبة',
        fragment: 'Abd al-Muttalib carries the newborn to the Ka\'bah. He holds the child before the ancient house — the same house that Allah protected from Abraha\'s army just weeks before. He names him Muhammad: "The one who is praised again and again." The Arabs ask why he chose a name none of them have ever heard. He answers: "I want him to be praised in the heavens and on earth." A grandfather\'s hope. A name that would be spoken five times a day in every corner of the world.',
        fragmentAr: 'يحمل عبد المطلب المولود إلى الكعبة. يرفع الطفل أمام البيت العتيق — البيت نفسه الذي حماه الله من جيش أبرهة قبل أسابيع. يسمّيه محمداً: "الذي يُحمد مراراً وتكراراً." يسأله العرب لماذا اختار اسماً لم يسمعوه من قبل. يجيب: "أريده أن يُحمد في السماء والأرض." أمنية جَدّ. اسم سيُردد خمس مرات في اليوم في كل زاوية من العالم.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Al-Raheeq Al-Makhtum, Ch. 5 | Ibn Hisham',
        sourceRefAr: 'الرحيق المختوم، الفصل 5 | ابن هشام',
      ),
      SceneHotspot(
        id: 'orphan_dawn',
        x: 0.50, y: 0.28,
        icon: '🌅',
        label: 'The Orphan\'s First Dawn',
        labelAr: 'فجر اليتيم الأول',
        fragment: 'He was born without a father. Abdullah died months before — some say in Medina, returning from a trade journey, never knowing what Aminah carried. This child entered the world with nothing but a mother\'s embrace and a grandfather\'s prayer. Years later, Allah would address him directly: "Did He not find you an orphan and give you shelter?" Every loss was preparation. Every absence was by design. The most influential human being in history began with the least.',
        fragmentAr: 'وُلد بلا أب. عبد الله مات قبل أشهر — يُقال في المدينة، عائداً من رحلة تجارة، لم يعلم قط ما حملته آمنة. هذا الطفل دخل الدنيا بلا شيء سوى حضن أمّه ودعاء جدّه. بعد سنين، سيخاطبه الله مباشرة: "أَلَمْ يَجِدْكَ يَتِيمًا فَآوَىٰ؟" كل خسارة كانت إعداداً. كل غياب كان بتدبير. أكثر إنسان أثّر في التاريخ بدأ بأقل القليل.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Al-Raheeq Al-Makhtum, Ch. 5 | Quran 93:6',
        sourceRefAr: 'الرحيق المختوم، الفصل 5 | القرآن 93:6',
        didYouKnow: 'Abdullah, the Prophet\'s father, died at age 25 — so young that when his son was later asked about him, the details were few. The Prophet ﷺ once passed his father\'s grave in Medina and wept.',
        didYouKnowAr: 'عبد الله، والد النبي، توفي في سن الخامسة والعشرين — شاباً جداً حتى أن التفاصيل عنه كانت قليلة حين سُئل ابنه لاحقاً. مرّ النبي ﷺ يوماً بقبر أبيه في المدينة وبكى.',
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
    // Night sky — deep indigo/navy, stars visible, warm glow on horizon
    skyGradient: const [
      Color(0xFF020510),  // very deep night at top
      Color(0xFF060C1A),
      Color(0xFF0C1428),
      Color(0xFF101830),
      Color(0xFF141E38),
      Color(0xFF182440),
      Color(0xFF1C2C4A),
      Color(0xFF243450),
      Color(0xFF2E3C48),  // faint warm glow at horizon
    ],
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
    groundLayers: const [
      ParallaxLayer(
        assetPath: 'assets/scenes/scene_event1_kaabah.jpg', // placeholder — Khaled provides desert morning BG
        speed: 0.15,
        verticalPosition: 0.0,
        heightFraction: 1.0,
      ),
    ],
    hotspots: const [
      SceneHotspot(
        id: 'drought_year',
        x: 0.50, y: 0.62,
        icon: '🏜️',
        label: 'The Drought Year',
        labelAr: 'عام الجدب',
        fragment: 'The women of Banu Sa\'d arrive in Mecca in a year the Arabs call "shahba\'" \u2014 gray, barren, merciless. Halimah\'s own child cries through the night because her milk has dried. Her donkey is so weak it slows the entire caravan \u2014 the other women curse her pace. In Mecca, every nursing woman finds a well-born child with a generous father. Halimah is offered only one: an orphan whose father died before he was born. She turns away. What can an orphan\'s family pay?',
        fragmentAr: 'نساء بني سعد يصلن مكة في عام يسمّيه العرب "شهباء" \u2014 رمادي، قاحل، بلا رحمة. طفل حليمة نفسه يبكي طوال الليل لأن حليبها جفّ. أتانها ضعيفة جداً حتى إنها تبطئ القافلة بأكملها \u2014 النساء يلعنّ بطأها. في مكة، كل مرضعة تجد طفلاً من عائلة كريمة بأب سخيّ. حليمة لا يُعرض عليها سوى طفل واحد: يتيم مات أبوه قبل أن يُولد. تُعرض عنه. ماذا ستدفع عائلة يتيم؟',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Al-Raheeq Al-Makhtum, Ch. 5 | Ibn Hisham',
        sourceRefAr: 'الرحيق المختوم، الفصل 5 | ابن هشام',
      ),
      SceneHotspot(
        id: 'blessed_soul',
        x: 0.25, y: 0.44,
        icon: '🤲',
        label: 'A Blessed Soul',
        labelAr: 'نَسَمة مباركة',
        fragment: 'Halimah returns to the gathering place. Every other child has been taken. Only the orphan remains. She tells her husband: "I hate to return to our people with nothing. Let me take this orphan." He replies: "Take him. Perhaps Allah will place blessing in him." She lifts the child \u2014 and in that instant, her milk flows. The baby drinks until he is full. His milk-brother drinks until he is full. Their old she-camel, which had not given a drop, suddenly fills with milk. Her husband milks it and they both drink until they are satisfied. He looks at her and says: "By Allah, Halimah \u2014 you have taken a blessed soul."',
        fragmentAr: 'تعود حليمة إلى مكان التجمّع. كل طفل آخر أُخذ. لم يبقَ سوى اليتيم. تقول لزوجها: "أكره أن أرجع إلى قومي بلا شيء. دعني آخذ هذا اليتيم." يجيب: "خذيه. لعل الله يجعل لنا فيه بركة." تحمل الطفل \u2014 وفي تلك اللحظة، يدرّ حليبها. الرضيع يشرب حتى يرتوي. أخوه في الرضاعة يشرب حتى يرتوي. ناقتهم العجوز التي لم تعطِ قطرة، تمتلئ فجأة بالحليب. زوجها يحلبها ويشربان حتى يشبعا. ينظر إليها ويقول: "والله يا حليمة \u2014 لقد أخذتِ نسمة مباركة."',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Al-Raheeq Al-Makhtum, Ch. 5 | Ibn Hisham',
        sourceRefAr: 'الرحيق المختوم، الفصل 5 | ابن هشام',
        didYouKnow: 'It was the custom of noble Quraysh families to send their newborns to Bedouin tribes in the desert \u2014 so the children would grow strong in body and pure in Arabic tongue. The Prophet \uFDFA later said: "I am the most eloquent of the Arabs, for I am from Quraysh and I was nursed among Banu Sa\'d."',
        didYouKnowAr: 'كان من عادة أشراف قريش إرسال مواليدهم إلى قبائل البادية \u2014 ليكبر الأطفال أقوياء في أجسامهم وفصحاء في لسانهم. قال النبي \uFDFA لاحقاً: "أنا أفصح العرب، بَيد أني من قريش واسترضعت في بني سعد."',
      ),
      SceneHotspot(
        id: 'green_land',
        x: 0.72, y: 0.42,
        icon: '🌿',
        label: 'The Green Land',
        labelAr: 'الأرض الخضراء',
        fragment: 'They return to the land of Banu Sa\'d \u2014 the driest land Halimah has ever known. But now, wherever her sheep graze, they return full of milk. Her neighbors\' sheep graze the same hills and return with nothing. The people of Banu Sa\'d begin sending their shepherds to follow Halimah\'s flock, hoping for the same blessing. It does not work for them. The blessing follows the child, not the land. He grows faster than any boy his age. Halimah watches him and knows \u2014 this is not an ordinary child.',
        fragmentAr: 'يعودون إلى أرض بني سعد \u2014 أجدب أرض عرفتها حليمة. لكن الآن، أينما رعت أغنامها، تعود ممتلئة بالحليب. أغنام جيرانها ترعى التلال ذاتها وتعود بلا شيء. أهل بني سعد يرسلون رعاتهم ليتبعوا قطيع حليمة، أملاً في البركة نفسها. لا تنجح معهم. البركة تتبع الطفل، لا الأرض. ينمو أسرع من أي صبي في سنّه. حليمة تراقبه وتعلم \u2014 هذا ليس طفلاً عادياً.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Al-Raheeq Al-Makhtum, Ch. 5 | Ibn Hisham',
        sourceRefAr: 'الرحيق المختوم، الفصل 5 | ابن هشام',
        didYouKnow: 'Halimah\'s donkey, which had been so weak it slowed the entire caravan on the way to Mecca, outpaced every animal on the way back. The other women said in amazement: "Is this the same donkey you came on?"',
        didYouKnowAr: 'أتان حليمة التي كانت ضعيفة جداً حتى أبطأت القافلة بأكملها في طريقها إلى مكة، سبقت كل دابة في طريق العودة. قالت النساء بدهشة: "أهذه الأتان التي خرجتِ عليها؟"',
      ),
      SceneHotspot(
        id: 'keep_him',
        x: 0.50, y: 0.28,
        icon: '💛',
        label: '"Let Me Keep Him"',
        labelAr: '"دعيني أبقيه"',
        fragment: 'After two years, it is time to return the child to his mother Aminah. But Halimah cannot bear to let him go. She has watched the blessings multiply \u2014 in her milk, her animals, her land, her family. She goes to Aminah and begs: "Let me keep him longer. I fear the plague of Mecca for him." She argues until Aminah agrees. The child returns to Banu Sa\'d. He will stay until he is four or five \u2014 running barefoot in the open desert, learning the pure Arabic of the Bedouin, growing under a sky wider than anything Mecca could offer. Allah is raising His prophet in the wilderness.',
        fragmentAr: 'بعد سنتين، حان وقت إعادة الطفل إلى أمه آمنة. لكن حليمة لا تطيق فراقه. شاهدت البركات تتضاعف \u2014 في حليبها، وماشيتها، وأرضها، وأهلها. تذهب إلى آمنة وتتوسل: "دعيني أبقيه. أخاف عليه من وباء مكة." تُلحّ حتى توافق آمنة. يعود الطفل إلى بني سعد. سيبقى حتى الرابعة أو الخامسة \u2014 يركض حافياً في الصحراء المفتوحة، يتعلم عربية البدو الصافية، يكبر تحت سماء أوسع مما تقدمه مكة. الله يربّي نبيّه في البرّية.',
        sfxPath: 'assets/audio/sfx_kaabah_wind.wav',
        sourceRef: 'Al-Raheeq Al-Makhtum, Ch. 5 | Ibn Hisham',
        sourceRefAr: 'الرحيق المختوم، الفصل 5 | ابن هشام',
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
    // Early morning desert — pale gold/amber → warm blue
    skyGradient: const [
      Color(0xFF0A1420),
      Color(0xFF142030),
      Color(0xFF1E2C40),
      Color(0xFF2A3850),
      Color(0xFF3A4A58),
      Color(0xFF5A5A48),
      Color(0xFF8A7040),
      Color(0xFFB88838),
      Color(0xFFD8A840),
    ],
    skyStops: const [0.0, 0.12, 0.24, 0.36, 0.48, 0.58, 0.70, 0.85, 1.0],
    showStars: false,
    showMoon: false,
    particleType: ParticleType.dust,
    particleCount: 20,
    particleColor: const Color(0x40B8986E),
    showGrain: true,
  ),
};
