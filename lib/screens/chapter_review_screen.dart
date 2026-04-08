import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../models/chapter_review.dart';
import '../services/prefs_service.dart';

/// Cross-event quiz at the end of each era. 5-7 questions one at a time.
/// Score screen at end with Master/Scholar/Keep Learning status.
class ChapterReviewScreen extends StatefulWidget {
  final ChapterReview review;
  final VoidCallback onComplete;

  const ChapterReviewScreen({
    super.key,
    required this.review,
    required this.onComplete,
  });

  @override
  State<ChapterReviewScreen> createState() => _ChapterReviewScreenState();
}

class _ChapterReviewScreenState extends State<ChapterReviewScreen> {
  int _currentQuestion = 0;
  int _correctCount = 0;
  int? _selectedIndex;
  bool _answered = false;
  bool _showScore = false;

  bool get _isAr => PrefsService.isAr;

  void _selectOption(int index) {
    if (_answered) return;
    final q = widget.review.questions[_currentQuestion];
    setState(() {
      _selectedIndex = index;
      _answered = true;
      if (index == q.correctIndex) _correctCount++;
    });

    // Auto-advance after 1.5s
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (_currentQuestion < widget.review.questions.length - 1) {
        setState(() {
          _currentQuestion++;
          _selectedIndex = null;
          _answered = false;
        });
      } else {
        setState(() => _showScore = true);
      }
    });
  }

  String get _status {
    final total = widget.review.questions.length;
    if (_correctCount >= total - 2) return _isAr ? 'متقن' : 'Master';
    if (_correctCount >= total / 2) return _isAr ? 'عالم' : 'Scholar';
    return _isAr ? 'واصل التعلم' : 'Keep learning';
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final eraTitle = _isAr ? review.eraTitleAr : review.eraTitle;

    if (_showScore) return _buildScoreScreen(eraTitle);

    final q = review.questions[_currentQuestion];
    final question = _isAr ? q.questionAr : q.question;
    final options = _isAr ? q.optionsAr : q.options;
    final explanation = _isAr ? q.explanationAr : q.explanation;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Header
              Text(
                _isAr ? 'مراجعة الفصل' : 'Chapter Review',
                style: GoogleFonts.cinzelDecorative(
                  fontSize: 20,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                eraTitle,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),

              // Progress
              Text(
                '${_currentQuestion + 1}/${review.questions.length}',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: AppColors.gold.withAlpha(120),
                ),
              ),
              const SizedBox(height: 24),

              // Question
              Text(
                question,
                textAlign: TextAlign.center,
                textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
                style: GoogleFonts.lora(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontStyle: _isAr ? FontStyle.normal : FontStyle.italic,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),

              // Options
              ...List.generate(options.length, (i) {
                final selected = _selectedIndex == i;
                final correct = i == q.correctIndex;
                final showCorrect = _answered && correct;
                final showWrong = _answered && selected && !correct;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: _answered ? null : () => _selectOption(i),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: showCorrect
                            ? AppColors.gold.withAlpha(30)
                            : showWrong
                                ? Colors.redAccent.withAlpha(20)
                                : AppColors.card,
                        border: Border.all(
                          color: showCorrect
                              ? AppColors.gold
                              : showWrong
                                  ? Colors.redAccent.withAlpha(120)
                                  : AppColors.gold.withAlpha(40),
                        ),
                      ),
                      child: Text(
                        options[i],
                        textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
                        style: GoogleFonts.nunito(
                          color: showCorrect
                              ? AppColors.gold
                              : showWrong
                                  ? Colors.redAccent
                                  : AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: (showCorrect || showWrong)
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // Explanation on answer
              if (_answered)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    explanation,
                    textAlign: TextAlign.center,
                    textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
                    style: GoogleFonts.nunito(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreScreen(String eraTitle) {
    final total = widget.review.questions.length;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isAr ? 'مراجعة الفصل' : 'Chapter Review',
                  style: GoogleFonts.cinzelDecorative(
                    fontSize: 20,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(eraTitle,
                    style: GoogleFonts.nunito(
                        color: AppColors.textMuted, fontSize: 13)),
                const SizedBox(height: 32),

                // Score
                Text(
                  '$_correctCount/$total',
                  style: GoogleFonts.cinzelDecorative(
                    fontSize: 48,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _status,
                  style: GoogleFonts.lora(
                    fontSize: 22,
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 40),

                // Continue
                SizedBox(
                  width: 200,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: widget.onComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.bg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isAr ? 'أكمل الرحلة' : 'Continue journey',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
