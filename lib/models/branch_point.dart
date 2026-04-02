/// The Crossroads — the two-option choice card after The Gate.
/// The user chooses which direction to explore, affecting hotspot visit order.
/// Both Paths converge at The Gathering — convergent branching.
class BranchPoint {
  final String id;

  /// Narrative prompt shown after The Gate is dismissed.
  /// Written in second-person companion voice.
  final String prompt;
  final String promptAr;

  /// Two choices — each maps to a Path hotspot ID that becomes the next stop.
  final BranchOption optionA;
  final BranchOption optionB;

  const BranchPoint({
    required this.id,
    required this.prompt,
    required this.promptAr,
    required this.optionA,
    required this.optionB,
  });
}

/// One side of The Crossroads choice.
class BranchOption {
  /// Short label on the tappable choice button.
  final String label;
  final String labelAr;

  /// The Path hotspot ID this choice leads to first.
  final String targetHotspotId;

  const BranchOption({
    required this.label,
    required this.labelAr,
    required this.targetHotspotId,
  });
}
