import 'branch_point.dart';

// ── Era ───────────────────────────────────────────────────────────────────────

enum JourneyEra {
  jahiliyyah,   // Pre-Islamic Arabia 570 CE
  earlyLife,    // Early life of the Prophet ﷺ 570–610 CE
  mecca,        // Prophetic Era — Mecca 610–622 CE
  medina,       // Prophetic Era — Medina 622–632 CE
  rashidun,     // Rashidun Caliphate 632–661 CE
  umayyad,      // Umayyad Caliphate 661–750 CE
  abbasid,      // Abbasid Caliphate 750–1258 CE
  ottoman,      // Ottoman Empire 1299–1922 CE
}

extension JourneyEraExt on JourneyEra {
  String label(String lang) {
    if (lang == 'ar') {
      switch (this) {
        case JourneyEra.jahiliyyah: return 'الجاهلية';
        case JourneyEra.earlyLife:  return 'النشأة';
        case JourneyEra.mecca:      return 'العهد المكي';
        case JourneyEra.medina:     return 'العهد المدني';
        case JourneyEra.rashidun:   return 'الخلافة الراشدة';
        case JourneyEra.umayyad:    return 'الخلافة الأموية';
        case JourneyEra.abbasid:    return 'الخلافة العباسية';
        case JourneyEra.ottoman:    return 'الدولة العثمانية';
      }
    }
    switch (this) {
      case JourneyEra.jahiliyyah: return 'Pre-Islamic Arabia';
      case JourneyEra.earlyLife:  return 'Early Life';
      case JourneyEra.mecca:      return 'Prophetic Era — Mecca';
      case JourneyEra.medina:     return 'Prophetic Era — Medina';
      case JourneyEra.rashidun:   return 'Rashidun Caliphate';
      case JourneyEra.umayyad:    return 'Umayyad Caliphate';
      case JourneyEra.abbasid:    return 'Abbasid Caliphate';
      case JourneyEra.ottoman:    return 'Ottoman Empire';
    }
  }

  String get emoji {
    switch (this) {
      case JourneyEra.jahiliyyah: return '🌙';
      case JourneyEra.earlyLife:  return '⭐';
      case JourneyEra.mecca:      return '🕌';
      case JourneyEra.medina:     return '🌿';
      case JourneyEra.rashidun:   return '⚖️';
      case JourneyEra.umayyad:    return '🏛️';
      case JourneyEra.abbasid:    return '📚';
      case JourneyEra.ottoman:    return '🗺️';
    }
  }

  /// Chapter closing line — shown on chapter completion screen.
  String closingLine(String lang) {
    if (lang == 'ar') {
      switch (this) {
        case JourneyEra.jahiliyyah: return 'شهدتَ عصر ما قبل النور. العالم ينتظر.';
        case JourneyEra.earlyLife:  return 'من يتيم إلى الأمين. الوحي قريب.';
        case JourneyEra.mecca:      return 'ثلاثة عشر عاماً من الصبر. بدأت الهجرة.';
        case JourneyEra.medina:     return 'اكتملت الرسالة. أنتَ الراوي الآن.';
        default: return '';
      }
    }
    switch (this) {
      case JourneyEra.jahiliyyah: return 'You have witnessed the age before the light. The world is waiting.';
      case JourneyEra.earlyLife:  return 'From orphan to the Trustworthy. The revelation is near.';
      case JourneyEra.mecca:      return 'Thirteen years of patience. The Hijrah has begun.';
      case JourneyEra.medina:     return 'The message is complete. You are the Rawi now.';
      default: return '';
    }
  }

  /// Last event globalOrder in this era (for current 36 events).
  int get lastEventOrder {
    switch (this) {
      case JourneyEra.jahiliyyah: return 2;
      case JourneyEra.earlyLife:  return 11;
      case JourneyEra.mecca:      return 22;
      case JourneyEra.medina:     return 36;
      default: return 0;
    }
  }
}

// ── Quiz Question ─────────────────────────────────────────────────────────────

class JourneyQuestion {
  final String id;
  final String question;
  final String questionAr;
  final List<String> options;       // exactly 4
  final List<String> optionsAr;     // exactly 4
  final int correctIndex;           // 0–3
  final String explanation;
  final String explanationAr;

  /// Optional "Go Deeper" scholarly content for the explanation.
  final String? deeperContent;
  final String? deeperContentAr;

  const JourneyQuestion({
    required this.id,
    required this.question,
    required this.questionAr,
    required this.options,
    required this.optionsAr,
    required this.correctIndex,
    required this.explanation,
    required this.explanationAr,
    this.deeperContent,
    this.deeperContentAr,
  });
}

// ── Journey Event ─────────────────────────────────────────────────────────────

class JourneyEvent {
  /// Unique identifier — e.g. 'j_1_1_1'
  final String id;

  /// Era this event belongs to
  final JourneyEra era;

  /// Global sequential order across all M1 events (1-based)
  final int globalOrder;

  /// Map pin location (reserved for future map view)
  final double latitude;
  final double longitude;

  /// Year CE
  final int year;

  /// Optional Hijri year (AH)
  final int? yearAH;

  final String title;
  final String titleAr;

  final String location;
  final String locationAr;

  /// 2–3 paragraph narrative (EN)
  final String narrative;

  /// 2–3 paragraph narrative (AR)
  final String narrativeAr;

  /// Primary hadith / Quran reference
  final String source;

  /// XP awarded on completion
  final int xpReward;

  /// 1–2 quiz questions. Empty = narrative-only event (no quiz gate).
  final List<JourneyQuestion> questions;

  // ── Branching (optional) ──────────────────────────────────────────────────
  // If null, event uses The Reflection flow (backward compatible for Events 4+).

  /// The Gate — first mandatory hotspot that sets the scene.
  final String? anchorHotspotId;

  /// The Crossroads — two-option choice card after The Gate.
  final BranchPoint? branchPoint;

  /// The Gathering — final hotspot where all Paths meet before The Verdict.
  final String? convergenceHotspotId;

  /// Whether this event uses branching flow.
  bool get isBranching => branchPoint != null;

  const JourneyEvent({
    required this.id,
    required this.era,
    required this.globalOrder,
    required this.latitude,
    required this.longitude,
    required this.year,
    this.yearAH,
    required this.title,
    required this.titleAr,
    required this.location,
    required this.locationAr,
    required this.narrative,
    required this.narrativeAr,
    required this.source,
    this.xpReward = 30,
    this.questions = const [],
    this.anchorHotspotId,
    this.branchPoint,
    this.convergenceHotspotId,
  });
}
