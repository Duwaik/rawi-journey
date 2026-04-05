import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../models/journey_event.dart';
import '../services/prefs_service.dart';

class JourneyQuizScreen extends StatefulWidget {
  final JourneyEvent event;
  const JourneyQuizScreen({super.key, required this.event});

  @override
  State<JourneyQuizScreen> createState() => _JourneyQuizScreenState();
}

class _JourneyQuizScreenState extends State<JourneyQuizScreen>
    with SingleTickerProviderStateMixin {
  int _questionIndex = 0;
  int? _selectedOption;
  bool _answered = false;
  bool _allPassed = true;
  bool _isAr = false;

  late final AnimationController _revealCtrl;
  late final Animation<double> _revealAnim;

  @override
  void initState() {
    super.initState();
    _isAr = PrefsService.language == 'ar';
    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _revealAnim = CurvedAnimation(
      parent: _revealCtrl,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _revealCtrl.dispose();
    super.dispose();
  }

  JourneyQuestion get _currentQuestion =>
      widget.event.questions[_questionIndex];

  bool get _isLastQuestion =>
      _questionIndex == widget.event.questions.length - 1;

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

  void _selectOption(int index) {
    if (_answered) return;
    setState(() {
      _selectedOption = index;
      _answered = true;
      if (index != _currentQuestion.correctIndex) _allPassed = false;
    });
    _revealCtrl.forward();
  }

  void _next() {
    if (_isLastQuestion) {
      Navigator.pop(context, _allPassed);
      return;
    }
    _revealCtrl.reset();
    setState(() {
      _questionIndex++;
      _selectedOption = null;
      _answered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final q           = _currentQuestion;
    final question    = _isAr ? q.questionAr    : q.question;
    final options     = _isAr ? q.optionsAr     : q.options;
    final explanation = _isAr ? q.explanationAr : q.explanation;
    final isCorrect   = _selectedOption == q.correctIndex;
    final total       = widget.event.questions.length;
    final eventTitle  = _isAr ? widget.event.titleAr : widget.event.title;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Era glow — top right
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [_eraColor.withAlpha(42), Colors.transparent],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top bar ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.textBody, size: 22),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                      Expanded(
                        child: Text(
                          eventTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cinzelDecorative(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      // Language toggle
                      GestureDetector(
                        onTap: () => setState(() => _isAr = !_isAr),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Text(
                            _isAr ? 'EN' : 'AR',
                            style: GoogleFonts.nunito(
                              color: AppColors.gold,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Era accent line ────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  height: 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        _eraColor.withAlpha(180),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // ── Progress dots (multi-question) ─────────────────────────
                if (total > 1) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(total, (i) {
                      final active = i == _questionIndex;
                      final done = i < _questionIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: active ? 20 : 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: done
                              ? _eraColor.withAlpha(140)
                              : active
                                  ? _eraColor
                                  : AppColors.divider,
                        ),
                      );
                    }),
                  ),
                ],

                // ── Main content ───────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Atmospheric prompt
                        Text(
                          'A moment arrives.',
                          style: GoogleFonts.lora(
                            color: AppColors.textMuted,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Question in Cinzel
                        Text(
                          question,
                          style: GoogleFonts.cinzelDecorative(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            height: 1.45,
                          ),
                          textDirection:
                              _isAr ? TextDirection.rtl : TextDirection.ltr,
                        ),
                        const SizedBox(height: 32),

                        // ── Choice cards ──────────────────────────────────
                        ...List.generate(options.length, (i) {
                          final isSelected   = _selectedOption == i;
                          final isCorrectOpt = i == q.correctIndex;

                          Color borderColor;
                          Color bgColor;
                          Color textColor;

                          if (!_answered) {
                            borderColor = AppColors.divider;
                            bgColor     = AppColors.card;
                            textColor   = AppColors.textPrimary;
                          } else if (isCorrectOpt) {
                            borderColor = _eraColor;
                            bgColor     = _eraColor.withAlpha(22);
                            textColor   = AppColors.textPrimary;
                          } else if (isSelected) {
                            borderColor = AppColors.divider.withAlpha(90);
                            bgColor     = AppColors.bg;
                            textColor   = AppColors.textMuted;
                          } else {
                            borderColor = AppColors.divider.withAlpha(60);
                            bgColor     = AppColors.bg;
                            textColor   = AppColors.textMuted.withAlpha(140);
                          }

                          return GestureDetector(
                            onTap: () => _selectOption(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 280),
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 16),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: borderColor,
                                  width:
                                      _answered && isCorrectOpt ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      options[i],
                                      style: GoogleFonts.nunito(
                                        color: textColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        height: 1.4,
                                      ),
                                      textDirection: _isAr
                                          ? TextDirection.rtl
                                          : TextDirection.ltr,
                                    ),
                                  ),
                                  if (_answered && isCorrectOpt) ...[
                                    const SizedBox(width: 10),
                                    Icon(Icons.check_circle_rounded,
                                        color: _eraColor, size: 20),
                                  ] else if (_answered && isSelected) ...[
                                    const SizedBox(width: 10),
                                    Icon(
                                        Icons.radio_button_unchecked_rounded,
                                        color: AppColors.divider,
                                        size: 20),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }),

                        // ── Historical record panel ────────────────────────
                        if (_answered) ...[
                          const SizedBox(height: 6),
                          FadeTransition(
                            opacity: _revealAnim,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.08),
                                end: Offset.zero,
                              ).animate(_revealAnim),
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: isCorrect
                                      ? _eraColor.withAlpha(14)
                                      : AppColors.card,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isCorrect
                                        ? _eraColor.withAlpha(80)
                                        : AppColors.divider,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // Label row
                                    Row(
                                      children: [
                                        Icon(
                                          isCorrect
                                              ? Icons.brightness_3_rounded
                                              : Icons.auto_stories_rounded,
                                          size: 13,
                                          color: AppColors.gold,
                                        ),
                                        const SizedBox(width: 7),
                                        Text(
                                          isCorrect
                                              ? 'History records...'
                                              : 'What history records...',
                                          style: GoogleFonts.nunito(
                                            color: AppColors.gold,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    // Explanation in Lora italic
                                    Text(
                                      explanation,
                                      style: GoogleFonts.lora(
                                        color: AppColors.textBody,
                                        fontSize: 14,
                                        fontStyle: _isAr ? FontStyle.normal : FontStyle.italic,
                                        height: 1.75),
                                      textDirection: _isAr
                                          ? TextDirection.rtl
                                          : TextDirection.ltr,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ── Continue button (appears after answering) ──────────────────────────
      bottomNavigationBar: _answered
          ? Container(
              padding: EdgeInsets.fromLTRB(
                  20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
              decoration: const BoxDecoration(
                color: AppColors.bg,
                border:
                    Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _eraColor,
                    foregroundColor: AppColors.bg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _isLastQuestion
                        ? 'Continue the Journey  →'
                        : 'The story continues  →',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
