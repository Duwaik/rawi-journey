import '../models/map_location.dart';

const List<MapLocation> mapLocations = [
  MapLocation(
    id: 'mecca',
    name: 'Mecca',
    nameAr: 'مكة المكرمة',
    mapX: 0.45,
    mapY: 0.65,
    eventIds: ['j_1_1_1', 'j_1_1_2', 'j_1_2_1'],
    region: 'hijaz',
  ),
  MapLocation(
    id: 'taif',
    name: "Ta'if",
    nameAr: 'الطائف',
    mapX: 0.50,
    mapY: 0.60,
    eventIds: [],
    region: 'hijaz',
  ),
  MapLocation(
    id: 'medina',
    name: 'Medina',
    nameAr: 'المدينة المنورة',
    mapX: 0.42,
    mapY: 0.45,
    eventIds: [],
    region: 'hijaz',
  ),
  MapLocation(
    id: 'abyssinia',
    name: 'Abyssinia',
    nameAr: 'الحبشة',
    mapX: 0.20,
    mapY: 0.75,
    eventIds: [],
    region: 'africa',
  ),
  MapLocation(
    id: 'syria',
    name: 'Syria',
    nameAr: 'الشام',
    mapX: 0.55,
    mapY: 0.20,
    eventIds: [],
    region: 'sham',
  ),
];
