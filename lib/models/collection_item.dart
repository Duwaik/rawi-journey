/// A collectible item discovered after completing certain events.
/// Goes into the Collection Gallery accessible from the home screen.
class CollectionItem {
  final String id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;

  /// Category: 'people', 'places', 'artifacts', 'moments'
  final String category;

  /// globalOrder of the event that unlocks this item.
  final int unlockedByEvent;

  /// Placeholder until batch generation.
  final String? imagePath;

  final String sourceRef;
  final String sourceRefAr;

  const CollectionItem({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.category,
    required this.unlockedByEvent,
    this.imagePath,
    required this.sourceRef,
    required this.sourceRefAr,
  });
}
