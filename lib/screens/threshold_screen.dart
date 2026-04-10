import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../models/threshold_challenge.dart';
import '../services/prefs_service.dart';

/// Full-screen threshold challenge — must answer correctly to proceed.
/// No penalty, no limit. Hint on wrong answer.
class ThresholdScreen extends StatefulWidget {
  final ThresholdChallenge challenge;
  final VoidCallback onUnlocked;

  const ThresholdScreen({
    super.key,
    required this.challenge,
    required this.onUnlocked,
  });

  @override
  State<ThresholdScreen> createState() => _ThresholdScreenState();
}

class _ThresholdScreenState extends State<ThresholdScreen>
    with SingleTickerProviderStateMixin {
  int? _selectedIndex;
  bool _showHint = false;
  bool _unlocked = false;
  late final AnimationController _fadeCtrl;

  bool get _isAr => PrefsService.isAr;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _selectOption(int index) {
    if (_unlocked) return;
    setState(() {
      _selectedIndex = index;
      _showHint = false;
    });

    if (index == widget.challenge.correctIndex) {
      HapticFeedback.mediumImpact();
      setState(() => _unlocked = true);
      // Brief celebration then proceed
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) widget.onUnlocked();
      });
    } else {
      // Show hint after brief delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _showHint = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.challenge;
    final question = _isAr ? c.questionAr : c.question;
    final options = _isAr ? c.optionsAr : c.options;
    final hint = _isAr
        ? 'تذكّر: ${c.hintEventTitleAr}'
        : 'Think back to: ${c.hintEventTitle}';

    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF04060D), Color(0xFF0B1E2D), Color(0xFF04060D)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Label
                  Text(
                    _isAr ? 'العَتَبة' : 'The Threshold',
                    style: GoogleFonts.cinzelDecorative(
                      fontSize: 24,
                      color: AppColors.gold,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isAr ? 'أجب لتفتح الطريق' : 'Answer to unlock the next path',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: AppColors.textMuted.withAlpha(140),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Question card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1520),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.gold.withAlpha(100),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withAlpha(20),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
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
                          final correct = i == c.correctIndex;
                          final isWrong = selected && !correct;
                          final isRight = selected && correct;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GestureDetector(
                              onTap: _unlocked ? null : () => _selectOption(i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: isRight
                                      ? AppColors.gold.withAlpha(30)
                                      : isWrong
                                          ? Colors.redAccent.withAlpha(20)
                                          : AppColors.gold.withAlpha(8),
                                  border: Border.all(
                                    color: isRight
                                        ? AppColors.gold
                                        : isWrong
                                            ? Colors.redAccent.withAlpha(120)
                                            : AppColors.gold.withAlpha(50),
                                    width: isRight ? 2 : 1,
                                  ),
                                ),
                                child: Text(
                                  options[i],
                                  textDirection: _isAr
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  style: GoogleFonts.nunito(
                                    color: isRight
                                        ? AppColors.gold
                                        : isWrong
                                            ? Colors.redAccent
                                            : AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),

                        // Hint on wrong answer
                        if (_showHint)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              hint,
                              textAlign: TextAlign.center,
                              textDirection: _isAr
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              style: GoogleFonts.nunito(
                                color: AppColors.gold.withAlpha(160),
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),

                        // Unlocked message
                        if (_unlocked)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_open_rounded,
                                    color: AppColors.gold, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  _isAr ? 'مفتوح!' : 'Unlocked!',
                                  style: GoogleFonts.nunito(
                                    color: AppColors.gold,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
