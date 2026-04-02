import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../models/journey_event.dart';
import '../services/prefs_service.dart';
import 'era_complete_screen.dart';

// ── Fallback flat event screen ──────────────────────────────────────────────
// Used for events WITHOUT a panorama/scene config.
// The immersive 360° experience is in immersive_event_screen.dart.

class JourneyEventScreen extends StatefulWidget {
  final JourneyEvent event;
  const JourneyEventScreen({super.key, required this.event});

  @override
  State<JourneyEventScreen> createState() => _JourneyEventScreenState();
}

class _JourneyEventScreenState extends State<JourneyEventScreen>
    with SingleTickerProviderStateMixin {
  bool _isAr = false;
  bool _alreadyCompleted = false;

  late final List<int?> _answers;
  late final AnimationController _revealCtrl;
  late final Animation<double> _revealAnim;

  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _isAr = PrefsService.language == 'ar';
    _alreadyCompleted = PrefsService.isEventCompleted(widget.event.globalOrder);
    _answers = List.filled(widget.event.questions.length, null);

    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _revealAnim = CurvedAnimation(parent: _revealCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _revealCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Color get _eraColor {
    switch (widget.event.era) {
      case JourneyEra.jahiliyyah: return AppColors.eraJahiliyyah;
      case JourneyEra.earlyLife:  return AppColors.eraEarlyLife;
      case JourneyEra.mecca:      return AppColors.eraMecca;
      case JourneyEra.medina:     return AppColors.eraMediana;
      case JourneyEra.rashidun:   return AppColors.eraRashidun;
      case JourneyEra.umayyad:    return AppColors.eraUmayyad;
      case JourneyEra.abbasid:    return AppColors.eraAbbasid;
      case JourneyEra.ottoman:    return AppColors.eraOttoman;
    }
  }

  bool get _allAnswered =>
      widget.event.questions.isEmpty ||
      _answers.every((a) => a != null);

  bool _didCompleteEra(int completedOrder) {
    const eraTransitions = <int>[3, 11, 22];
    return eraTransitions.contains(completedOrder);
  }

  void _selectChoice(int qIdx, int choiceIdx) {
    if (_answers[qIdx] != null) return;
    setState(() => _answers[qIdx] = choiceIdx);
    _revealCtrl.forward();
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _continue() async {
    final event = widget.event;
    if (!_alreadyCompleted) {
      await PrefsService.completeEvent(event.globalOrder, event.xpReward);
    }
    if (!mounted) return;

    if (_didCompleteEra(event.globalOrder)) {
      await Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (c, a1, a2) =>
              EraCompleteScreen(era: event.era, xpGained: event.xpReward),
          transitionsBuilder: (c, a, a2, child) => FadeTransition(
            opacity: CurvedAnimation(parent: a, curve: Curves.easeInOut),
            child: child,
          ),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final event    = widget.event;
    final title    = _isAr ? event.titleAr    : event.title;
    final location = _isAr ? event.locationAr : event.location;
    final narrative = _isAr ? event.narrativeAr : event.narrative;
    final yearStr  = '${event.year} CE'
        '${event.yearAH != null ? '  ·  ${event.yearAH} AH' : ''}';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned(
            top: -80, left: -80,
            child: Container(
              width: 320, height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [_eraColor.withAlpha(38), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded,
                            color: AppColors.textBody, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _eraColor.withAlpha(22),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _eraColor.withAlpha(65)),
                        ),
                        child: Text(
                          '${event.era.emoji}  ${event.era.label(PrefsService.language)}',
                          style: GoogleFonts.nunito(
                            color: _eraColor, fontSize: 11,
                            fontWeight: FontWeight.w700),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _isAr = !_isAr),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Text(
                            _isAr ? 'EN' : 'AR',
                            style: GoogleFonts.nunito(
                              color: AppColors.gold, fontSize: 12,
                              fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(26, 22, 26, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(yearStr,
                            style: GoogleFonts.nunito(
                              color: AppColors.gold, fontSize: 12,
                              fontWeight: FontWeight.w600, letterSpacing: 1.4)),
                        const SizedBox(height: 10),
                        Text(title,
                            style: GoogleFonts.cinzelDecorative(
                              color: AppColors.textPrimary, fontSize: 21,
                              fontWeight: FontWeight.w700, height: 1.35),
                            textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr),
                        const SizedBox(height: 10),
                        Row(children: [
                          Icon(Icons.place_outlined, size: 13, color: _eraColor.withAlpha(200)),
                          const SizedBox(width: 4),
                          Text(location,
                              style: GoogleFonts.nunito(color: AppColors.textMuted, fontSize: 13)),
                        ]),
                        const SizedBox(height: 26),
                        Row(children: [
                          Container(height: 1, width: 28, color: AppColors.gold.withAlpha(130)),
                          const SizedBox(width: 8),
                          Icon(Icons.brightness_3_rounded, size: 9, color: AppColors.gold.withAlpha(200)),
                          const SizedBox(width: 8),
                          Expanded(child: Container(height: 1, color: AppColors.divider)),
                        ]),
                        const SizedBox(height: 28),
                        Text(narrative,
                            style: GoogleFonts.lora(
                              color: const Color(0xFFD6CCBE),
                              fontSize: 16, fontStyle: FontStyle.italic, height: 1.92),
                            textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr),
                        const SizedBox(height: 26),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.menu_book_rounded, size: 13, color: AppColors.textMuted),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(event.source,
                                  style: GoogleFonts.nunito(
                                    color: AppColors.textMuted, fontSize: 12, height: 1.5)),
                            ),
                          ],
                        ),
                        if (event.questions.isNotEmpty && !_alreadyCompleted) ...[
                          const SizedBox(height: 36),
                          _buildChoiceSection(),
                        ],
                        if (_alreadyCompleted || _allAnswered) ...[
                          const SizedBox(height: 28),
                          _buildContinueButton(),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(child: Container(height: 1, color: AppColors.divider)),
          const SizedBox(width: 10),
          Icon(Icons.brightness_3_rounded, size: 9, color: _eraColor.withAlpha(200)),
          const SizedBox(width: 10),
          Expanded(child: Container(height: 1, color: AppColors.divider)),
        ]),
        const SizedBox(height: 24),
        ...List.generate(widget.event.questions.length, (qIdx) {
          final answered = _answers[qIdx] != null;
          final prevAnswered = qIdx == 0 || _answers[qIdx - 1] != null;
          if (!prevAnswered) return const SizedBox.shrink();

          final q = widget.event.questions[qIdx];
          final question = _isAr ? q.questionAr : q.question;
          final options = _isAr ? q.optionsAr : q.options;
          final explanation = _isAr ? q.explanationAr : q.explanation;
          final isCorrect = _answers[qIdx] == q.correctIndex;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (qIdx > 0) const SizedBox(height: 28),
              Text(_isAr ? 'تأتي لحظة...' : 'A moment arrives.',
                  style: GoogleFonts.lora(
                    color: AppColors.textMuted, fontSize: 13,
                    fontStyle: FontStyle.italic)),
              const SizedBox(height: 14),
              Text(question,
                  style: GoogleFonts.cinzelDecorative(
                    color: AppColors.textPrimary, fontSize: 17, height: 1.45),
                  textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr),
              const SizedBox(height: 24),
              ...List.generate(options.length, (i) {
                final isSelected = _answers[qIdx] == i;
                final isCorrectOpt = i == q.correctIndex;
                Color borderColor, bgColor, textColor;
                if (!answered) {
                  borderColor = AppColors.divider;
                  bgColor = AppColors.card;
                  textColor = AppColors.textPrimary;
                } else if (isCorrectOpt) {
                  borderColor = _eraColor;
                  bgColor = _eraColor.withAlpha(22);
                  textColor = AppColors.textPrimary;
                } else if (isSelected) {
                  borderColor = AppColors.divider.withAlpha(90);
                  bgColor = AppColors.bg;
                  textColor = AppColors.textMuted;
                } else {
                  borderColor = AppColors.divider.withAlpha(60);
                  bgColor = AppColors.bg;
                  textColor = AppColors.textMuted.withAlpha(140);
                }
                return GestureDetector(
                  onTap: () => _selectChoice(qIdx, i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: answered && isCorrectOpt ? 1.5 : 1.0),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(options[i],
                              style: GoogleFonts.nunito(
                                color: textColor, fontSize: 15,
                                fontWeight: FontWeight.w600, height: 1.4),
                              textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr),
                        ),
                        if (answered && isCorrectOpt) ...[
                          const SizedBox(width: 10),
                          Icon(Icons.check_circle_rounded, color: _eraColor, size: 20),
                        ] else if (answered && isSelected) ...[
                          const SizedBox(width: 10),
                          Icon(Icons.radio_button_unchecked_rounded, color: AppColors.divider, size: 20),
                        ],
                      ],
                    ),
                  ),
                );
              }),
              if (answered) ...[
                const SizedBox(height: 4),
                FadeTransition(
                  opacity: _revealAnim,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(_revealAnim),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isCorrect ? _eraColor.withAlpha(14) : AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isCorrect ? _eraColor.withAlpha(80) : AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(isCorrect ? Icons.brightness_3_rounded : Icons.auto_stories_rounded,
                                size: 13, color: AppColors.gold),
                            const SizedBox(width: 7),
                            Text(
                              isCorrect
                                  ? (_isAr ? 'يسجّل التاريخ...' : 'History records...')
                                  : (_isAr ? 'ما يسجّله التاريخ...' : 'What history records...'),
                              style: GoogleFonts.nunito(
                                color: AppColors.gold, fontSize: 11,
                                fontWeight: FontWeight.w700, letterSpacing: 0.6)),
                          ]),
                          const SizedBox(height: 10),
                          Text(explanation,
                              style: GoogleFonts.lora(
                                color: AppColors.textBody, fontSize: 14,
                                fontStyle: FontStyle.italic, height: 1.75),
                              textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _continue,
        style: ElevatedButton.styleFrom(
          backgroundColor: _alreadyCompleted ? AppColors.card : _eraColor,
          foregroundColor: _alreadyCompleted ? AppColors.textMuted : AppColors.bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(
          _alreadyCompleted
              ? (_isAr ? 'شوهد  ✓' : 'Witnessed  ✓')
              : (_isAr ? 'أكمل الرحلة  →' : 'Continue the Journey  →'),
          style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        ),
      ),
    );
  }
}
