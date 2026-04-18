/// R25-S1-5: Top-level feature flags.
///
/// Compile-time constants so the Dart tree-shaker can strip gated code
/// paths entirely in release mode.
library;

/// Rawi figure voiceover — the short VO clips the companion figure plays
/// when showing a bubble (e.g. idle prompts, post-discovery nudges,
/// all-done line, branch intro).
///
/// LOCKED OFF per Khaled, Apr 19 2026. Do not flip without a design review.
/// Keep the VO code in place (gated) so it can be restored if needed.
const bool kRawiFigureVoEnabled = false;
