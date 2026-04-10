import 'services/prefs_service.dart';

/// Resolves character art paths based on selected gender (Rawi/Rawiah)
/// and evolution stage.
///
/// Stage-specific assets follow the naming convention:
///   rawi_walking_s2.jpg, rawiah_portrait_s3.jpg, etc.
/// Currently only Stage 1 (base) assets exist — the fallback always
/// returns the base asset. When stage-specific art is added later,
/// the resolution will automatically pick them up.
class CharacterArt {
  static String _prefix() =>
      PrefsService.userGender == 'female' ? 'rawiah' : 'rawi';

  // TODO: When stage-specific assets are added, remove the early return
  // and let the stage suffix resolve naturally.
  static String _resolve(String pose, {int stage = 1}) {
    // Stage 1 is the base asset (no suffix).
    // Future stages will use e.g. rawi_walking_s2.jpg.
    // For now, always return the base asset since only Stage 1 art exists.
    return 'assets/figures/${_prefix()}_$pose.jpg';
  }

  static String portrait({int stage = 1}) => _resolve('portrait', stage: stage);
  static String walking({int stage = 1}) => _resolve('walking', stage: stage);
  static String witnessing({int stage = 1}) => _resolve('witnessing', stage: stage);
  static String carrying({int stage = 1}) => _resolve('carrying', stage: stage);
}
