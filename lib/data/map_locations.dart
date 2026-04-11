import '../models/map_location.dart';

/// Hand-drawn parchment map of the Arabian Peninsula.
///
/// Coordinates are normalized 0..1 over a virtual map. The map is NOT
/// geographically accurate — it is a stylized layout optimized for the
/// narrative arc of the Seerah, with Mecca near the center-south and
/// Medina north of it. Locations reveal progressively as the user
/// reaches the events that take place there.
///
/// Each location's `eventIds` list maps to the events the user will
/// see when tapping it; `revealsAtEvent` is the global order at which
/// the location first appears (drawn-in) on the map.

const List<MapLocation> mapLocations = [
  // ── Mecca: always visible (the starting point) ──────────────────────────
  MapLocation(
    id: 'mecca',
    name: 'Mecca',
    nameAr: 'مكة المكرمة',
    mapX: 0.45,
    mapY: 0.62,
    region: 'hijaz',
    revealsAtEvent: 1,
    connectedTo: ['cave_hira', 'taif', 'medina', 'arafat'],
    eventIds: [
      'j_1_1_1', 'j_1_1_2', 'j_1_2_1', 'j_m1_007', 'j_1_2_3', 'j_1_2_4',
      'j_m1_010', 'j_m1_011', 'j_1_1_3', 'j_1_2_8', 'j_m1_016',
      'j_1_3_1', 'j_1_3_2', 'j_1_3_3', 'j_1_3_5', 'j_1_3_11',
      'j_m1_028', 'j_m1_029', 'j_m1_030', 'j_m1_039', 'j_m1_040',
      // Conquest of Mecca onward (back to Mecca)
      'j_m3_098', 'j_m3_105', 'j_m3_110', 'j_m3_111', 'j_m3_112', 'j_m3_113',
      'j_m4_133', 'j_m4_134', 'j_m4_138',
    ],
  ),

  // ── Cave Hira: revealed when the Prophet ﷺ retreats there ──────────────
  MapLocation(
    id: 'cave_hira',
    name: 'Cave Hira',
    nameAr: 'غار حراء',
    mapX: 0.49,
    mapY: 0.58,
    region: 'hijaz',
    revealsAtEvent: 13,
    connectedTo: ['mecca'],
    eventIds: ['j_1_2_6', 'j_1_2_7'],
  ),

  // ── Banu Sa'd / Al-Abwa: nursing years (revealed by Halimah) ────────────
  MapLocation(
    id: 'banu_sad',
    name: "Banu Sa'd",
    nameAr: 'بادية بني سعد',
    mapX: 0.51,
    mapY: 0.55,
    region: 'hijaz',
    revealsAtEvent: 4,
    connectedTo: ['mecca'],
    eventIds: ['j_1_2_2', 'j_m1_005'],
  ),
  MapLocation(
    id: 'al_abwa',
    name: 'Al-Abwa',
    nameAr: 'الأبواء',
    mapX: 0.41,
    mapY: 0.52,
    region: 'hijaz',
    revealsAtEvent: 6,
    connectedTo: ['mecca'],
    eventIds: ['j_m1_006'],
  ),

  // ── Abyssinia: first migration ──────────────────────────────────────────
  MapLocation(
    id: 'abyssinia',
    name: 'Abyssinia',
    nameAr: 'الحبشة',
    mapX: 0.18,
    mapY: 0.78,
    region: 'africa',
    revealsAtEvent: 20,
    connectedTo: ['mecca'],
    eventIds: ['j_1_3_4', 'j_1_3_5_neg', 'j_1_3_11', 'j_1_3_8'],
  ),

  // ── Ta'if ────────────────────────────────────────────────────────────────
  MapLocation(
    id: 'taif',
    name: "Ta'if",
    nameAr: 'الطائف',
    mapX: 0.55,
    mapY: 0.59,
    region: 'hijaz',
    revealsAtEvent: 31,
    connectedTo: ['mecca'],
    eventIds: ['j_m1_031', 'j_m1_032', 'j_m1_033', 'j_m3_116', 'j_m3_119'],
  ),

  // ── Jerusalem (Isra wal-Mi'raj) ─────────────────────────────────────────
  MapLocation(
    id: 'jerusalem',
    name: 'Jerusalem',
    nameAr: 'القدس',
    mapX: 0.52,
    mapY: 0.16,
    region: 'sham',
    revealsAtEvent: 34,
    connectedTo: ['mecca'],
    eventIds: ['j_m1_034', 'j_m1_035'],
  ),

  // ── Mina (Pledges of Aqabah) ────────────────────────────────────────────
  MapLocation(
    id: 'mina',
    name: 'Mina',
    nameAr: 'منى',
    mapX: 0.47,
    mapY: 0.60,
    region: 'hijaz',
    revealsAtEvent: 36,
    connectedTo: ['mecca'],
    eventIds: ['j_m1_036', 'j_m1_038'],
  ),

  // ── Cave Thawr (hijrah hideout) ─────────────────────────────────────────
  MapLocation(
    id: 'cave_thawr',
    name: 'Cave Thawr',
    nameAr: 'غار ثور',
    mapX: 0.43,
    mapY: 0.65,
    region: 'hijaz',
    revealsAtEvent: 42,
    connectedTo: ['mecca', 'medina'],
    eventIds: ['j_m1_041', 'j_m1_042', 'j_m1_043'],
  ),

  // ── Quba (arrival in Medina region) ─────────────────────────────────────
  MapLocation(
    id: 'quba',
    name: 'Quba',
    nameAr: 'قباء',
    mapX: 0.40,
    mapY: 0.40,
    region: 'hijaz',
    revealsAtEvent: 44,
    connectedTo: ['medina'],
    eventIds: ['j_m1_044', 'j_m1_045', 'j_m1_046'],
  ),

  // ── Medina: the new home ────────────────────────────────────────────────
  MapLocation(
    id: 'medina',
    name: 'Medina',
    nameAr: 'المدينة المنورة',
    mapX: 0.42,
    mapY: 0.36,
    region: 'hijaz',
    revealsAtEvent: 47,
    connectedTo: ['mecca', 'badr', 'mount_uhud', 'khandaq', 'khaybar', 'tabuk'],
    eventIds: [
      'j_m1_047',
      'j_m2_048', 'j_m2_049', 'j_m2_050', 'j_m2_051', 'j_m2_052',
      'j_m2_059', 'j_m2_060', 'j_m2_061',
      'j_m2_070', 'j_m2_073',
      'j_m2_079', 'j_m2_080', 'j_m2_081', 'j_m2_082',
      'j_m3_083', 'j_m3_089', 'j_m3_090', 'j_m3_091', 'j_m3_092', 'j_m3_097',
      'j_m3_099', 'j_m3_100', 'j_m3_106',
      'j_m4_125', 'j_m4_127', 'j_m4_128',
      'j_m4_129', 'j_m4_130', 'j_m4_131', 'j_m4_132',
      'j_m4_136', 'j_m4_143', 'j_m4_144', 'j_m4_145',
      'j_m4_147', 'j_m4_148', 'j_m4_149', 'j_m4_150',
      'j_m4_151', 'j_m4_152', 'j_m4_153', 'j_m4_154', 'j_m4_155',
    ],
  ),

  // ── Badr ─────────────────────────────────────────────────────────────────
  MapLocation(
    id: 'badr',
    name: 'Badr',
    nameAr: 'بدر',
    mapX: 0.36,
    mapY: 0.46,
    region: 'hijaz',
    revealsAtEvent: 55,
    connectedTo: ['medina'],
    eventIds: [
      'j_m2_053', 'j_m2_054', 'j_m2_055', 'j_m2_056', 'j_m2_057', 'j_m2_058',
      'j_m2_071',
    ],
  ),

  // ── Mount Uhud ──────────────────────────────────────────────────────────
  MapLocation(
    id: 'mount_uhud',
    name: 'Mount Uhud',
    nameAr: 'جبل أحد',
    mapX: 0.45,
    mapY: 0.32,
    region: 'hijaz',
    revealsAtEvent: 62,
    connectedTo: ['medina'],
    eventIds: [
      'j_m2_062', 'j_m2_063', 'j_m2_064', 'j_m2_065', 'j_m2_066', 'j_m2_067',
      'j_m4_146',
    ],
  ),

  // ── Raji' / Bi'r Ma'una (treachery sites) ───────────────────────────────
  MapLocation(
    id: 'raji',
    name: "Raji' & Bi'r Ma'una",
    nameAr: 'الرجيع وبئر معونة',
    mapX: 0.51,
    mapY: 0.42,
    region: 'hijaz',
    revealsAtEvent: 68,
    connectedTo: ['medina'],
    eventIds: ['j_m2_068', 'j_m2_069'],
  ),

  // ── Khandaq area / Banu Mustaliq ────────────────────────────────────────
  MapLocation(
    id: 'khandaq',
    name: 'Khandaq',
    nameAr: 'الخندق',
    mapX: 0.39,
    mapY: 0.30,
    region: 'hijaz',
    revealsAtEvent: 72,
    connectedTo: ['medina'],
    eventIds: [
      'j_m2_072', 'j_m2_074', 'j_m2_075', 'j_m2_076', 'j_m2_077', 'j_m2_078',
    ],
  ),

  // ── Hudaybiyyah ─────────────────────────────────────────────────────────
  MapLocation(
    id: 'hudaybiyyah',
    name: 'Hudaybiyyah',
    nameAr: 'الحديبية',
    mapX: 0.42,
    mapY: 0.50,
    region: 'hijaz',
    revealsAtEvent: 84,
    connectedTo: ['medina', 'mecca'],
    eventIds: ['j_m3_084', 'j_m3_085', 'j_m3_086', 'j_m3_087', 'j_m3_088'],
  ),

  // ── Khaybar ─────────────────────────────────────────────────────────────
  MapLocation(
    id: 'khaybar',
    name: 'Khaybar',
    nameAr: 'خيبر',
    mapX: 0.49,
    mapY: 0.28,
    region: 'hijaz',
    revealsAtEvent: 93,
    connectedTo: ['medina'],
    eventIds: ['j_m3_093', 'j_m3_094', 'j_m3_095', 'j_m3_096'],
  ),

  // ── Mu'tah (battle in the north) ────────────────────────────────────────
  MapLocation(
    id: 'mutah',
    name: "Mu'tah",
    nameAr: 'مؤتة',
    mapX: 0.55,
    mapY: 0.20,
    region: 'sham',
    revealsAtEvent: 101,
    connectedTo: ['medina'],
    eventIds: ['j_m3_101', 'j_m3_102', 'j_m3_103', 'j_m3_104'],
  ),

  // ── Marr al-Zahran / approach to Mecca during Conquest ──────────────────
  MapLocation(
    id: 'marr_al_zahran',
    name: 'Marr al-Zahran',
    nameAr: 'مر الظهران',
    mapX: 0.43,
    mapY: 0.55,
    region: 'hijaz',
    revealsAtEvent: 107,
    connectedTo: ['medina', 'mecca'],
    eventIds: ['j_m3_107', 'j_m3_108', 'j_m3_109'],
  ),

  // ── Hunayn ──────────────────────────────────────────────────────────────
  MapLocation(
    id: 'hunayn',
    name: 'Hunayn',
    nameAr: 'حنين',
    mapX: 0.50,
    mapY: 0.66,
    region: 'hijaz',
    revealsAtEvent: 114,
    connectedTo: ['mecca'],
    eventIds: ['j_m3_114', 'j_m3_115', 'j_m3_117', 'j_m3_118'],
  ),

  // ── Tabuk: the far north expedition ─────────────────────────────────────
  MapLocation(
    id: 'tabuk',
    name: 'Tabuk',
    nameAr: 'تبوك',
    mapX: 0.50,
    mapY: 0.10,
    region: 'sham',
    revealsAtEvent: 121,
    connectedTo: ['medina'],
    eventIds: ['j_m4_121', 'j_m4_122', 'j_m4_123', 'j_m4_124', 'j_m4_126'],
  ),

  // ── Arafat (Farewell Pilgrimage) ────────────────────────────────────────
  MapLocation(
    id: 'arafat',
    name: 'Arafat',
    nameAr: 'عرفات',
    mapX: 0.49,
    mapY: 0.66,
    region: 'hijaz',
    revealsAtEvent: 139,
    connectedTo: ['mecca'],
    eventIds: ['j_m4_137', 'j_m4_139', 'j_m4_140', 'j_m4_141', 'j_m4_142'],
  ),
];

/// Get the location that a given event ID belongs to (first match wins).
MapLocation? findLocationForEvent(String eventId) {
  for (final loc in mapLocations) {
    if (loc.eventIds.contains(eventId)) return loc;
  }
  return null;
}

/// Get all locations that should be visible given the user's current
/// global event order. A location is "revealed" once the user reaches
/// `revealsAtEvent` (or beyond).
List<MapLocation> visibleLocations(int currentOrder) {
  return mapLocations.where((l) => currentOrder >= l.revealsAtEvent).toList();
}

/// Get locations that are about to be revealed (next 3 by reveal order
/// after the current event). These render as faint "?" marks.
List<MapLocation> upcomingLocations(int currentOrder) {
  final upcoming = mapLocations
      .where((l) => l.revealsAtEvent > currentOrder)
      .toList()
    ..sort((a, b) => a.revealsAtEvent.compareTo(b.revealsAtEvent));
  return upcoming.take(3).toList();
}
