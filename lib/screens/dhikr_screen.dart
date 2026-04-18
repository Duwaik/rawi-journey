import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../data/dhikr_data.dart';
import '../models/dhikr_card.dart';
import '../services/prefs_service.dart';
import 'scroll_writing_screen.dart';

/// Full-screen cinematic dhikr card shown after event completion.
class DhikrScreen extends StatefulWidget {
  final String eventId;

  const DhikrScreen({super.key, required this.eventId});

  @override
  State<DhikrScreen> createState() => _DhikrScreenState();
}

class _DhikrScreenState extends State<DhikrScreen>
    with SingleTickerProviderStateMixin {
  late final DhikrCard _card;
  bool _celebrating = false;
  late final AnimationController _shimmerCtrl;
  late final Animation<double> _shimmerAnim;
  // B24: first-time tooltip explaining the dhikr → Event Question flow
  bool _showFirstTimeTooltip = false;

  @override
  void initState() {
    super.initState();
    _card = dhikrCards[widget.eventId]!;
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shimmerAnim = CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeOut);
    // B24: show tooltip on first-ever dhikr encounter only
    if (!PrefsService.isEventQTooltipSeen) {
      _showFirstTimeTooltip = true;
    }
  }

  void _dismissTooltip() {
    PrefsService.setEventQTooltipSeen();
    setState(() => _showFirstTimeTooltip = false);
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  bool get _isAr => PrefsService.isAr;

  Future<void> _onSaidIt() async {
    // Save progress
    await PrefsService.incrementDhikrCount();
    await PrefsService.setDhikrCompleted(widget.eventId);

    if (!mounted) return;

    // Brief celebration shimmer + haptic
    HapticFeedback.mediumImpact();
    setState(() => _celebrating = true);
    _shimmerCtrl.forward();

    // Wait then navigate
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    _goToEventList();
  }

  void _onNotNow() {
    _goToEventList();
  }

  void _goToEventList() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ScrollWritingScreen(eventId: widget.eventId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF04060D),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF04060D),
                  Color(0xFF0B1E2D),
                  Color(0xFF04060D),
                ],
              ),
            ),
            // B25: tight vertical layout — content sits naturally around the
            // button, no pre-allocated blank space below it.
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  children: [
                    // ── Title ───────────────────────────────────────────
                    Text(
                      _isAr ? 'اكسب حسنات' : 'Earn Hasanat',
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 22,
                        color: AppColors.gold,
                      ),
                      textDirection:
                          _isAr ? TextDirection.rtl : TextDirection.ltr,
                    ),

                    const SizedBox(height: 20),

                    // ── Standalone dhikr card (elevated, centered) ─────
                    _buildStandaloneCard(),

                    const SizedBox(height: 24),

                    // ── "I've said it" button ───────────────────────────
                    _buildSaidItButton(),

                    const SizedBox(height: 10),

                    // ── "Not now" link ──────────────────────────────────
                    GestureDetector(
                      onTap: _onNotNow,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          _isAr ? 'ليس الآن' : 'Not now',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                          textDirection:
                              _isAr ? TextDirection.rtl : TextDirection.ltr,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ── B24: First-time tooltip (explains upcoming Event Question) ─
          if (_showFirstTimeTooltip) _buildFirstTimeTooltip(),
        ],
      ),
    );
  }

  /// B24: One-time tooltip on first dhikr encounter. Explains that after
  /// dhikr, the user will answer an Event Question. Tap anywhere to dismiss.
  Widget _buildFirstTimeTooltip() {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _dismissTooltip,
        child: Container(
          color: Colors.black.withAlpha(210),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold.withAlpha(30),
                        border: Border.all(
                            color: AppColors.gold.withAlpha(120), width: 2),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.gold.withAlpha(60),
                              blurRadius: 20,
                              spreadRadius: 4),
                        ],
                      ),
                      child: const Icon(Icons.auto_stories_rounded,
                          size: 32, color: AppColors.gold),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isAr ? 'الذكر ثم سؤال الحدث' : 'Dhikr, then Event Question',
                      textAlign: TextAlign.center,
                      textDirection:
                          _isAr ? TextDirection.rtl : TextDirection.ltr,
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 18,
                        color: AppColors.gold,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _isAr
                          ? 'بعد الذكر، ستجيب على سؤال الحدث لتختبر ما تعلّمته.'
                          : 'After your dhikr, you\'ll answer an Event Question to test what you learned.',
                      textAlign: TextAlign.center,
                      textDirection:
                          _isAr ? TextDirection.rtl : TextDirection.ltr,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: AppColors.textBody,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      _isAr ? 'انقر للمتابعة' : 'Tap to continue',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: AppColors.textMuted.withAlpha(160),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStandaloneCard() {
    return AnimatedBuilder(
      animation: _shimmerAnim,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF5E6C8),
            image: const DecorationImage(
              image: AssetImage('assets/textures/parchment_light.jpg'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _celebrating
                  ? AppColors.gold.withAlpha(
                      (80 + (175 * _shimmerAnim.value)).toInt().clamp(0, 255))
                  : AppColors.gold.withAlpha(80),
              width: _celebrating ? 2 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withAlpha(_celebrating
                    ? (60 * _shimmerAnim.value).toInt()
                    : 15),
                blurRadius: _celebrating ? 24 : 12,
                spreadRadius: _celebrating ? 2 : 0,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Column(
        children: [
          // Arabic dhikr text — hero element, always shown
          Text(
            _card.arabicText,
            style: GoogleFonts.amiri(
              fontSize: 22,
              color: const Color(0xFF402010),
              height: 1.8,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),

          const SizedBox(height: 14),

          // Transliteration
          Text(
            _card.transliteration,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: const Color(0xFF6B4423),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Meaning
          Text(
            _isAr ? _card.meaningAr : _card.meaningEn,
            style: GoogleFonts.lora(
              fontSize: 13,
              fontStyle: _isAr ? FontStyle.normal : FontStyle.italic,
              color: const Color(0xFF402010),
            ),
            textAlign: TextAlign.center,
            textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
          ),

          const SizedBox(height: 18),

          // Divider
          Container(height: 1, color: const Color(0xFF8B6F47).withAlpha(60)),

          const SizedBox(height: 18),

          // Count + When
          _buildInfoLine(
            '\uD83D\uDCFF',
            _card.count != null
                ? (_isAr
                    ? 'قلها: ${_card.countAr ?? _card.count}'
                    : 'Say it: ${_card.count}')
                : (_isAr
                    ? 'قلها مرة بحضور قلب'
                    : 'Say it once with presence of heart'),
          ),
          const SizedBox(height: 8),
          _buildInfoLine(
            '\uD83D\uDD50',
            _isAr
                ? 'متى: ${_card.whenToSayAr}'
                : 'When: ${_card.whenToSay}',
          ),

          const SizedBox(height: 20),

          // ── Promise sub-card (nested inside main card) ──────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8D6B0),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF8B6F47).withAlpha(60)),
            ),
            child: Column(
              children: [
                Text(
                  _isAr ? '\u2728 الوعد' : '\u2728 The Promise',
                  style: GoogleFonts.cinzelDecorative(
                    fontSize: 14,
                    color: AppColors.gold,
                  ),
                  textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
                ),
                const SizedBox(height: 10),
                Text(
                  _isAr ? _card.promiseAr : _card.promiseEn,
                  style: GoogleFonts.lora(
                    fontSize: 14,
                    color: const Color(0xFF402010),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
                ),
                const SizedBox(height: 10),
                Text(
                  _isAr ? _card.sourceRefAr : _card.sourceRef,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: const Color(0xFF6B4423),
                  ),
                  textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoLine(String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: const Color(0xFF402010),
            ),
            textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
          ),
        ),
      ],
    );
  }

  Widget _buildSaidItButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _celebrating ? null : _onSaidIt,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: const Color(0xFF0B1E2D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Text(
          _isAr ? 'قلتها \u2713' : 'I\'ve said it \u2713',
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
          textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
        ),
      ),
    );
  }
}
