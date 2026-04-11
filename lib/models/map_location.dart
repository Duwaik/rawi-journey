class MapLocation {
  final String id;
  final String name;
  final String nameAr;

  /// Normalized position (0.0–1.0) on the parchment map.
  final double mapX;
  final double mapY;

  /// All events that take place at this location.
  final List<String> eventIds;

  /// Geographic region used for grouping (hijaz / sham / africa / etc.).
  final String region;

  /// First global event order at which this location should appear on the
  /// map. Before this, the location is invisible. Used for the
  /// progressive reveal in the parchment map.
  final int revealsAtEvent;

  /// IDs of other locations this one is connected to with an ink path.
  /// The path is "traveled" once both endpoints are at least partially
  /// completed; "next" (faint dashed) when one endpoint is the current
  /// area; otherwise hidden.
  final List<String> connectedTo;

  const MapLocation({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.mapX,
    required this.mapY,
    required this.eventIds,
    required this.region,
    this.revealsAtEvent = 1,
    this.connectedTo = const [],
  });
}
