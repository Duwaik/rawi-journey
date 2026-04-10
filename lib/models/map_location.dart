class MapLocation {
  final String id;
  final String name;
  final String nameAr;
  final double mapX;
  final double mapY;
  final List<String> eventIds;
  final String region;

  const MapLocation({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.mapX,
    required this.mapY,
    required this.eventIds,
    required this.region,
  });
}
