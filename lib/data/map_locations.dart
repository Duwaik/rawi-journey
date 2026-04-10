import '../models/map_location.dart';

/// Chronological order of locations for route drawing.
/// Index in this list = drawing order for route lines.
const List<String> locationRouteOrder = [
  'arabian_peninsula', // Event 1
  'mecca',             // Events 2, 3, 7, 8, 9, 10, 11, 12
  'banu_sad',          // Events 4, 5
  'al_abwa',           // Event 6
  'cave_hira',         // Events 13, 14
  'mount_safa',        // Event 16
  'abyssinia',         // Event 18
  'taif',              // Event 21
  'jerusalem',         // Event 22
  'mina',              // Events 23, 24
  'cave_thawr',        // Event 26
  'medina',            // Events 27, 28, 29, 32, 34, 38, 40
  'badr',              // Event 30
  'mount_uhud',        // Event 31
  'hudaybiyyah',       // Event 33
  'hunayn',            // Event 36
  'tabuk',             // Event 37
];

const List<MapLocation> mapLocations = [
  // ── Hijaz ───────────────────────────────────────────────────────────────
  MapLocation(
    id: 'arabian_peninsula',
    name: 'Arabian Peninsula',
    nameAr: 'الجزيرة العربية',
    mapX: 0.50,
    mapY: 0.72,
    eventIds: ['j_1_1_1'],
    region: 'hijaz',
  ),
  MapLocation(
    id: 'mecca',
    name: 'Mecca',
    nameAr: 'مكة المكرمة',
    mapX: 0.42,
    mapY: 0.62,
    eventIds: [
      'j_1_1_2',  // 2  Year of the Elephant
      'j_1_2_1',  // 3  Birth of the Prophet
      'j_m1_007', // 7  Under Abd al-Muttalib
      'j_1_2_3',  // 8  Guardian: Abu Talib
      'j_1_2_4',  // 9  Hilf al-Fudul
      'j_m1_010', // 10 Al-Amin
      'j_m1_011', // 11 Marriage to Khadijah
      'j_1_1_3',  // 12 The Black Stone
      'j_1_2_8',  // 15 First Believers
      'j_1_3_2',  // 17 Persecution Begins
      'j_1_3_4',  // 19 Boycott
      'j_1_3_5',  // 20 Year of Grief
      'j_1_3_9',  // 25 Plot to Kill
      'j_1_4_9',  // 35 Conquest of Mecca
      'j_1_4_13', // 39 Farewell Pilgrimage
    ],
    region: 'hijaz',
  ),
  MapLocation(
    id: 'banu_sad',
    name: "Banu Sa'd",
    nameAr: 'بادية بني سعد',
    mapX: 0.48,
    mapY: 0.56,
    eventIds: [
      'j_1_2_2',  // 4  Nursing Years
      'j_m1_005', // 5  Opening of the Chest
    ],
    region: 'hijaz',
  ),
  MapLocation(
    id: 'al_abwa',
    name: "Al-Abwa",
    nameAr: 'الأبواء',
    mapX: 0.38,
    mapY: 0.50,
    eventIds: [
      'j_m1_006', // 6  Death of Aminah
    ],
    region: 'hijaz',
  ),
  MapLocation(
    id: 'cave_hira',
    name: 'Cave Hira',
    nameAr: 'غار حراء',
    mapX: 0.46,
    mapY: 0.59,
    eventIds: [
      'j_1_2_6', // 13 Solitude in Cave Hira
      'j_1_2_7', // 14 The First Revelation
    ],
    region: 'hijaz',
  ),
  MapLocation(
    id: 'mount_safa',
    name: 'Mount Safa',
    nameAr: 'جبل الصفا',
    mapX: 0.44,
    mapY: 0.64,
    eventIds: [
      'j_1_3_1', // 16 The Call Goes Public
    ],
    region: 'hijaz',
  ),
  MapLocation(
    id: 'taif',
    name: "Ta'if",
    nameAr: 'الطائف',
    mapX: 0.50,
    mapY: 0.58,
    eventIds: [
      'j_1_3_11', // 21 Journey to Ta'if
    ],
    region: 'hijaz',
  ),
  MapLocation(
    id: 'mina',
    name: 'Mina',
    nameAr: 'منى',
    mapX: 0.44,
    mapY: 0.60,
    eventIds: [
      'j_1_3_7', // 23 First Pledge of Aqabah
      'j_1_3_8', // 24 Second Pledge of Aqabah
    ],
    region: 'hijaz',
  ),
  MapLocation(
    id: 'cave_thawr',
    name: 'Cave Thawr',
    nameAr: 'غار ثور',
    mapX: 0.40,
    mapY: 0.64,
    eventIds: [
      'j_1_3_10', // 26 Cave Thawr — Three Days
    ],
    region: 'hijaz',
  ),
  MapLocation(
    id: 'hudaybiyyah',
    name: 'Hudaybiyyah',
    nameAr: 'الحديبية',
    mapX: 0.39,
    mapY: 0.61,
    eventIds: [
      'j_1_4_7', // 33 Treaty of Hudaybiyyah
    ],
    region: 'hijaz',
  ),
  MapLocation(
    id: 'hunayn',
    name: 'Hunayn Valley',
    nameAr: 'وادي حنين',
    mapX: 0.46,
    mapY: 0.63,
    eventIds: [
      'j_1_4_10', // 36 Battle of Hunayn
    ],
    region: 'hijaz',
  ),

  // ── Medina region ───────────────────────────────────────────────────────
  MapLocation(
    id: 'medina',
    name: 'Medina',
    nameAr: 'المدينة المنورة',
    mapX: 0.40,
    mapY: 0.38,
    eventIds: [
      'j_1_4_1',  // 27 Arrival — Hijrah
      'j_1_4_2',  // 28 Building the Mosque
      'j_1_4_3',  // 29 The Brotherhood
      'j_1_4_6',  // 32 Battle of the Trench
      'j_1_4_8',  // 34 Letters to the Kings
      'j_1_4_12', // 38 Year of Delegations
      'j_1_4_14', // 40 Final Illness
    ],
    region: 'hijaz',
  ),
  MapLocation(
    id: 'badr',
    name: 'Badr',
    nameAr: 'بدر',
    mapX: 0.38,
    mapY: 0.44,
    eventIds: [
      'j_1_4_4', // 30 Battle of Badr
    ],
    region: 'hijaz',
  ),
  MapLocation(
    id: 'mount_uhud',
    name: 'Mount Uhud',
    nameAr: 'جبل أحد',
    mapX: 0.42,
    mapY: 0.36,
    eventIds: [
      'j_1_4_5', // 31 Battle of Uhud
    ],
    region: 'hijaz',
  ),

  // ── Beyond Hijaz ────────────────────────────────────────────────────────
  MapLocation(
    id: 'abyssinia',
    name: 'Abyssinia',
    nameAr: 'الحبشة',
    mapX: 0.18,
    mapY: 0.75,
    eventIds: [
      'j_1_3_3', // 18 Migration to Abyssinia
    ],
    region: 'africa',
  ),
  MapLocation(
    id: 'jerusalem',
    name: 'Jerusalem',
    nameAr: 'القدس',
    mapX: 0.55,
    mapY: 0.18,
    eventIds: [
      'j_1_3_6', // 22 Al-Isra' wal-Mi'raj
    ],
    region: 'sham',
  ),
  MapLocation(
    id: 'tabuk',
    name: 'Tabuk',
    nameAr: 'تبوك',
    mapX: 0.50,
    mapY: 0.24,
    eventIds: [
      'j_1_4_11', // 37 Expedition to Tabuk
    ],
    region: 'sham',
  ),
];
