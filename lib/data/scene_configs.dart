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
};
