import 'services/prefs_service.dart';

/// Resolves character art paths based on selected gender (Rawi/Rawiah).
/// Use these static methods instead of hardcoding image paths.
class CharacterArt {
  static String _prefix() =>
      PrefsService.userGender == 'female' ? 'rawiah' : 'rawi';

  static String portrait() => 'assets/figures/${_prefix()}_portrait.jpg';
  static String walking() => 'assets/figures/${_prefix()}_walking.jpg';
  static String witnessing() => 'assets/figures/${_prefix()}_witnessing.jpg';
  static String carrying() => 'assets/figures/${_prefix()}_carrying.jpg';
}
