/// R28-RFT-07 · OBS3 observation-note content store.
///
/// A third-person Rawi remark shown AFTER the user answers the verdict
/// and BEFORE the cinematic reveal — one note per answer option
/// (verdicts have exactly 3 options per the locked content rule).
///
/// **Content ownership:** the actual copy is Khaled's content pass
/// (spec RFT-07 — "[Khaled-side content authoring needed]"). This file
/// ships PLACEHOLDER text in the correct slots so the widget + flow are
/// fully functional and testable now; real copy drops in later by
/// editing [observationNotes] (or adding entries) with NO code change.
///
/// Structure (spec: "JSON map keyed by eventId + answerIndex"):
///   observationNotes[eventId][answerIndex] -> (en, ar)
/// Any event/answer with no authored entry falls back to
/// [placeholderNote] so the beat never renders empty.
library;

typedef ObservationNote = ({String en, String ar});

/// Placeholder used until Khaled authors the real remark. Clearly
/// marked so it can never be mistaken for shipped copy on A56.
ObservationNote placeholderNote(String eventId, int answerIndex) {
  final tag = '$eventId · answer ${String.fromCharCode(65 + answerIndex)}';
  return (
    en: '[Rawi observation — $tag — placeholder, pending content pass]',
    ar: '[ملاحظة الراوي — $tag — نص مؤقت بانتظار المحتوى]',
  );
}

/// Authored notes. Empty for now (placeholder fallback covers every
/// event). Real entries look like:
///   'j_m1_001': [
///     (en: '...', ar: '...'),  // answer A
///     (en: '...', ar: '...'),  // answer B
///     (en: '...', ar: '...'),  // answer C
///   ],
const Map<String, List<ObservationNote>> observationNotes = {};

/// Resolve the note for an (eventId, answerIndex), always non-null.
ObservationNote observationNoteFor(String eventId, int answerIndex) {
  final list = observationNotes[eventId];
  if (list != null && answerIndex >= 0 && answerIndex < list.length) {
    return list[answerIndex];
  }
  return placeholderNote(eventId, answerIndex);
}
