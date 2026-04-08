import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../models/chain_moment.dart';
import '../services/prefs_service.dart';

/// The Chain of Transmission — shows the golden chain from event →
/// sahabi → scholar → 1400 years → the user (by name).
/// Appears every 25 events. No share button (deferred to post-launch).
class ChainScreen extends StatefulWidget {
  final ChainMoment moment;
  final VoidCallback onContinue;

  const ChainScreen({
    super.key,
    required this.moment,
    required this.onContinue,
  });

  @override
  State<ChainScreen> createState() => _ChainScreenState();
}

class _ChainScreenState extends State<ChainScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  bool get _isAr => PrefsService.isAr;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.moment;
    final userName = PrefsService.userName.isNotEmpty
        ? PrefsService.userName
        : (_isAr ? 'الراوي' : 'The Rawi');

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    _isAr ? 'سلسلة الإسناد' : 'The Chain of Transmission',
                    style: GoogleFonts.cinzelDecorative(
                      fontSize: 20,
                      color: AppColors.gold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Chain nodes
                  _buildNode(
                    icon: Icons.auto_stories_rounded,
                    label: _isAr ? m.eventTitleAr : m.eventTitle,
                    sublabel: _isAr ? 'الحدث الذي شهدته' : 'The event you witnessed',
                    size: 44,
                    progress: _ctrl.value,
                    threshold: 0.0,
                  ),
                  _buildChainLine(_ctrl.value, 0.1),

                  _buildNode(
                    icon: Icons.edit_rounded,
                    label: _isAr ? m.sahabiNameAr : m.sahabiName,
                    sublabel: _isAr ? 'الصحابي الذي رواه' : 'The sahabi who narrated',
                    size: 40,
                    progress: _ctrl.value,
                    threshold: 0.2,
                  ),
                  _buildChainLine(_ctrl.value, 0.3),

                  _buildNode(
                    icon: Icons.menu_book_rounded,
                    label: _isAr ? m.scholarNameAr : m.scholarName,
                    sublabel: m.sourceBook,
                    size: 40,
                    progress: _ctrl.value,
                    threshold: 0.4,
                  ),
                  _buildChainLine(_ctrl.value, 0.5),

                  // Dotted gap — 1400 years
                  if (_ctrl.value > 0.5)
                    Opacity(
                      opacity: ((_ctrl.value - 0.5) / 0.15).clamp(0.0, 1.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          _isAr
                              ? '· · · 1400 سنة من النقل · · ·'
                              : '· · · 1400 years of transmission · · ·',
                          style: GoogleFonts.nunito(
                            color: AppColors.gold.withAlpha(100),
                            fontSize: 12,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  _buildChainLine(_ctrl.value, 0.65),

                  // User node — largest, gold fill
                  _buildNode(
                    icon: Icons.person_rounded,
                    label: userName,
                    sublabel: _isAr
                        ? 'أنت الحلقة التالية في السلسلة'
                        : 'You are the next link in the chain',
                    size: 52,
                    progress: _ctrl.value,
                    threshold: 0.75,
                    isUser: true,
                  ),

                  const SizedBox(height: 32),

                  // Quote
                  if (_ctrl.value > 0.85)
                    Opacity(
                      opacity: ((_ctrl.value - 0.85) / 0.15).clamp(0.0, 1.0),
                      child: Column(
                        children: [
                          Text(
                            _isAr ? m.shareQuoteAr : m.shareQuote,
                            textAlign: TextAlign.center,
                            textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
                            style: GoogleFonts.lora(
                              color: AppColors.gold,
                              fontSize: 16,
                              fontStyle: _isAr ? FontStyle.normal : FontStyle.italic,
                              height: 1.7,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Continue button
                          GestureDetector(
                            onTap: widget.onContinue,
                            child: Text(
                              _isAr ? 'أكمل الرحلة' : 'Continue journey',
                              style: GoogleFonts.nunito(
                                color: AppColors.gold.withAlpha(160),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.gold.withAlpha(80),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNode({
    required IconData icon,
    required String label,
    required String sublabel,
    required double size,
    required double progress,
    required double threshold,
    bool isUser = false,
  }) {
    if (progress < threshold) return const SizedBox.shrink();
    final opacity = ((progress - threshold) / 0.15).clamp(0.0, 1.0);

    return Opacity(
      opacity: opacity,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUser ? AppColors.gold.withAlpha(40) : AppColors.bg,
              border: Border.all(
                color: AppColors.gold,
                width: isUser ? 2 : 1.5,
              ),
              boxShadow: isUser
                  ? [BoxShadow(color: AppColors.gold.withAlpha(40), blurRadius: 16)]
                  : null,
            ),
            child: Icon(icon, color: AppColors.gold, size: size * 0.45),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              color: isUser ? AppColors.gold : AppColors.textPrimary,
              fontSize: isUser ? 16 : 13,
              fontWeight: isUser ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          Text(
            sublabel,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              color: AppColors.textMuted.withAlpha(120),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChainLine(double progress, double threshold) {
    if (progress < threshold) return const SizedBox(height: 24);
    final opacity = ((progress - threshold) / 0.1).clamp(0.0, 1.0);
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 2,
        height: 24,
        color: AppColors.gold.withAlpha(120),
      ),
    );
  }
}
