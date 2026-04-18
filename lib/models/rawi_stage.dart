/// Rawi evolution stages — the companion title evolves as the user progresses.
class RawiStage {
  /// Returns the stage number (1–5) based on total completed events.
  static int getStage(int completedEvents) {
    if (completedEvents >= 155) return 5;
    if (completedEvents >= 121) return 4;
    if (completedEvents >= 71) return 3;
    if (completedEvents >= 31) return 2;
    return 1;
  }

  /// Human-readable stage name in EN or AR.
  static String stageName(int stage, {bool isAr = false}) {
    const namesEn = [
      '',
      'Young Traveler',
      'Seasoned Narrator',
      'Wise Chronicler',
      'Master Rawi',
      'The Keeper',
    ];
    const namesAr = [
      '',
      'المسافر الشاب',
      'الراوي المخضرم',
      'المؤرخ الحكيم',
      'الراوي الأعظم',
      'الحافظ',
    ];
    return isAr ? namesAr[stage] : namesEn[stage];
  }

  /// B21: Age + gender based rank title (replaces stage title on tent).
  /// Ages: <25 young, 25-55 explorer, 56+ wise. Gender 'male'/'female'.
  static String ageGenderTitle({
    required int age,
    required String gender,
    required bool isAr,
  }) {
    final female = gender == 'female';
    if (age < 25) {
      if (isAr) return female ? 'الرحّالة الشابة' : 'الرحّالة الشاب';
      return 'Young Explorer';
    }
    if (age <= 55) {
      if (isAr) return female ? 'الرحّالة' : 'الرحّال';
      return 'The Explorer';
    }
    if (isAr) return female ? 'الرحّالة الحكيمة' : 'الرحّال الحكيم';
    return 'The Wise Explorer';
  }
}
