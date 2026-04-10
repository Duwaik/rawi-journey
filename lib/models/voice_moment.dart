class VoiceMoment {
  final String eventId;
  final String type; // 'witness', 'scroll', 'chapter', 'rawi_call'
  final String audioPathEn;
  final String audioPathAr;

  const VoiceMoment({
    required this.eventId,
    required this.type,
    required this.audioPathEn,
    required this.audioPathAr,
  });
}
