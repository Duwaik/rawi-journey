/// R28-S2-DATA1 — Arc registry.
///
/// Source of truth for the 20 narrative arcs and the 4 modules that group
/// them. Titles were locked in the 25 Apr 2026 content session and are
/// reproduced verbatim here (no creative authorship).
///
/// Event → arc mapping is a sequential stub per the R28-S2 spec
/// (M1: 10/10/9/9/9 · M2: 7/7/7/7/7 · M3: 8/8/8/7/7 · M4: 7/7/7/7/7).
/// A narrative-driven remap is a later content-session task — owner can
/// rebalance here without touching UI code, since [arcIdForEvent] is the
/// single binding.
///
/// Structural carries from the content session:
///   • Arcs 10 & 11 are a deliberate pair — same cave, two states
///     (silence → speech).
///   • Arc 14 absorbs the Year of Sorrow (boycott end, Khadijah's death,
///     Abu Talib's death, Ta'if).
///   • Arc 15 bundles Isra + Mi'raj + Aqabah pledges.
///   • No Bahira narrative — project rule.
library;

// ── Types ────────────────────────────────────────────────────────────────────

class ArcDefinition {
  final int arcId;      // 1..20
  final int moduleId;   // 1..4
  final int firstEvent; // globalOrder, inclusive
  final int lastEvent;  // globalOrder, inclusive
  final String titleEn;
  final String titleAr;

  const ArcDefinition({
    required this.arcId,
    required this.moduleId,
    required this.firstEvent,
    required this.lastEvent,
    required this.titleEn,
    required this.titleAr,
  });

  int get eventCount => lastEvent - firstEvent + 1;

  bool contains(int globalOrder) =>
      globalOrder >= firstEvent && globalOrder <= lastEvent;
}

class ModuleDefinition {
  final int moduleId;   // 1..4
  final String nameEn;
  final String nameAr;
  final int eventCount;
  final int firstEvent;
  final int lastEvent;

  const ModuleDefinition({
    required this.moduleId,
    required this.nameEn,
    required this.nameAr,
    required this.eventCount,
    required this.firstEvent,
    required this.lastEvent,
  });
}

// ── Modules (4, locked 25 Apr 2026) ─────────────────────────────────────────

const List<ModuleDefinition> moduleRegistry = [
  ModuleDefinition(
    moduleId: 1,
    nameEn: 'Jahiliyyah',
    nameAr: 'الجاهلية',
    eventCount: 47,
    firstEvent: 1,
    lastEvent: 47,
  ),
  ModuleDefinition(
    moduleId: 2,
    nameEn: 'Early Life',
    nameAr: 'الطفولة والشباب',
    eventCount: 35,
    firstEvent: 48,
    lastEvent: 82,
  ),
  ModuleDefinition(
    moduleId: 3,
    nameEn: 'Meccan Mission',
    nameAr: 'الدعوة المكية',
    eventCount: 38,
    firstEvent: 83,
    lastEvent: 120,
  ),
  ModuleDefinition(
    moduleId: 4,
    nameEn: 'Medinan Period',
    nameAr: 'العهد المدني',
    eventCount: 35,
    firstEvent: 121,
    lastEvent: 155,
  ),
];

// ── Arcs (20, locked 25 Apr 2026) ───────────────────────────────────────────
//
// Ranges are the sequential stub split from the R28-S2 spec. Titles copied
// verbatim from R28_S2_DATA1_AGENT_UNBLOCK.md — do not paraphrase.

const List<ArcDefinition> arcRegistry = [
  // ── Module 1 · Jahiliyyah · events 1–47 · 10/10/9/9/9 ──
  ArcDefinition(
    arcId: 1, moduleId: 1, firstEvent: 1, lastEvent: 10,
    titleEn: 'The Light Before the Dawn',
    titleAr: 'النور قبل الفجر',
  ),
  ArcDefinition(
    arcId: 2, moduleId: 1, firstEvent: 11, lastEvent: 20,
    titleEn: 'The House Abraham Built',
    titleAr: 'بيت بناه إبراهيم',
  ),
  ArcDefinition(
    arcId: 3, moduleId: 1, firstEvent: 21, lastEvent: 29,
    titleEn: 'When Stones Became Gods',
    titleAr: 'حين صارت الحجارة آلهة',
  ),
  ArcDefinition(
    arcId: 4, moduleId: 1, firstEvent: 30, lastEvent: 38,
    titleEn: 'The Year the Sky Defended Mecca',
    titleAr: 'عام السماء التي حمت مكة',
  ),
  ArcDefinition(
    arcId: 5, moduleId: 1, firstEvent: 39, lastEvent: 47,
    titleEn: 'Seed of the Chosen One',
    titleAr: 'بذرة المصطفى',
  ),

  // ── Module 2 · Early Life · events 48–82 · 7/7/7/7/7 ──
  ArcDefinition(
    arcId: 6, moduleId: 2, firstEvent: 48, lastEvent: 54,
    titleEn: 'Birth Under a Silent Sky',
    titleAr: 'مولد تحت سماء صامتة',
  ),
  ArcDefinition(
    arcId: 7, moduleId: 2, firstEvent: 55, lastEvent: 61,
    titleEn: 'The Orphan in the Desert',
    titleAr: 'يتيم في الصحراء',
  ),
  ArcDefinition(
    arcId: 8, moduleId: 2, firstEvent: 62, lastEvent: 68,
    titleEn: 'Years of Quiet Honor',
    titleAr: 'سنوات الأمانة الصامتة',
  ),
  ArcDefinition(
    arcId: 9, moduleId: 2, firstEvent: 69, lastEvent: 75,
    titleEn: 'When Khadijah Saw Him',
    titleAr: 'حين رأته خديجة',
  ),
  ArcDefinition(
    arcId: 10, moduleId: 2, firstEvent: 76, lastEvent: 82,
    titleEn: "The Cave's Long Silence",
    titleAr: 'صمت الغار الطويل',
  ),

  // ── Module 3 · Meccan Mission · events 83–120 · 8/8/8/7/7 ──
  ArcDefinition(
    arcId: 11, moduleId: 3, firstEvent: 83, lastEvent: 90,
    titleEn: 'When the Cave Spoke',
    titleAr: 'حين نطق الغار',
  ),
  ArcDefinition(
    arcId: 12, moduleId: 3, firstEvent: 91, lastEvent: 98,
    titleEn: 'Whispers in the House of Arqam',
    titleAr: 'همسات في دار الأرقم',
  ),
  ArcDefinition(
    arcId: 13, moduleId: 3, firstEvent: 99, lastEvent: 106,
    titleEn: 'The Mountain That Heard Him',
    titleAr: 'الجبل الذي سمعه',
  ),
  ArcDefinition(
    arcId: 14, moduleId: 3, firstEvent: 107, lastEvent: 113,
    titleEn: 'The Year the Light Grieved',
    titleAr: 'عام الحزن',
  ),
  ArcDefinition(
    arcId: 15, moduleId: 3, firstEvent: 114, lastEvent: 120,
    titleEn: 'A Night Beyond the Stars',
    titleAr: 'ليلة وراء النجوم',
  ),

  // ── Module 4 · Medinan Period · events 121–155 · 7/7/7/7/7 ──
  ArcDefinition(
    arcId: 16, moduleId: 4, firstEvent: 121, lastEvent: 127,
    titleEn: 'The Road That Changed the World',
    titleAr: 'الطريق التي غيّرت العالم',
  ),
  ArcDefinition(
    arcId: 17, moduleId: 4, firstEvent: 128, lastEvent: 134,
    titleEn: 'A City Becomes a Nation',
    titleAr: 'مدينة تصير أمة',
  ),
  ArcDefinition(
    arcId: 18, moduleId: 4, firstEvent: 135, lastEvent: 141,
    titleEn: 'The Swords That Spoke Truth',
    titleAr: 'سيوف نطقت بالحق',
  ),
  ArcDefinition(
    arcId: 19, moduleId: 4, firstEvent: 142, lastEvent: 148,
    titleEn: 'When the Doors of Mecca Opened',
    titleAr: 'حين فُتحت أبواب مكة',
  ),
  ArcDefinition(
    arcId: 20, moduleId: 4, firstEvent: 149, lastEvent: 155,
    titleEn: 'The Farewell That Echoed Forever',
    titleAr: 'الوداع الذي لا يفنى',
  ),
];

// ── Lookups ──────────────────────────────────────────────────────────────────

/// Returns the arcId (1..20) that owns [globalOrder] (1..155).
/// Returns 0 if [globalOrder] is out of range — callers should not hit this.
int arcIdForEvent(int globalOrder) {
  for (final a in arcRegistry) {
    if (a.contains(globalOrder)) return a.arcId;
  }
  return 0;
}

ArcDefinition? arcForEvent(int globalOrder) {
  for (final a in arcRegistry) {
    if (a.contains(globalOrder)) return a;
  }
  return null;
}

ArcDefinition? arcById(int arcId) {
  for (final a in arcRegistry) {
    if (a.arcId == arcId) return a;
  }
  return null;
}

ModuleDefinition? moduleById(int moduleId) {
  for (final m in moduleRegistry) {
    if (m.moduleId == moduleId) return m;
  }
  return null;
}

List<ArcDefinition> arcsInModule(int moduleId) =>
    arcRegistry.where((a) => a.moduleId == moduleId).toList();
