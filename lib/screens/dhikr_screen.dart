import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../data/dhikr_data.dart';
import '../models/dhikr_card.dart';
import '../services/prefs_service.dart';
import 'event_list_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _card = dhikrCards[widget.eventId]!;
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shimmerAnim = CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeOut);
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

    // Brief celebration shimmer
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
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const EventListScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF04060D),
      body: Container(
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 12),

                // ── Title ───────────────────────────────────────────
                Text(
                  _isAr ? 'اكسب حسنات' : 'Earn Hasanat',
                  style: GoogleFonts.cinzelDecorative(
                    fontSize: 22,
                    color: AppColors.gold,
                  ),
                  textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
                ),

                const SizedBox(height: 24),

                // ── Main dhikr card ─────────────────────────────────
                _buildDhikrCard(),

                const SizedBox(height: 20),

                // ── Promise card ────────────────────────────────────
                _buildPromiseCard(),

                const SizedBox(height: 32),

                // ── "I've said it" button ───────────────────────────
                _buildSaidItButton(),

                const SizedBox(height: 12),

                // ── "Not now" link ──────────────────────────────────
                GestureDetector(
                  onTap: _onNotNow,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
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

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDhikrCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withAlpha(80), width: 1),
      ),
      child: Column(
        children: [
          // Arabic dhikr text — always shown
          Text(
            _card.arabicText,
            style: GoogleFonts.amiri(
              fontSize: 20,
              color: AppColors.gold,
              height: 1.8,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),

          const SizedBox(height: 12),

          // Transliteration
          Text(
            _card.transliteration,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: AppColors.gold.withAlpha(160),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // English meaning
          Text(
            _isAr ? _card.meaningAr : _card.meaningEn,
            style: GoogleFonts.lora(
              fontSize: 13,
              fontStyle: _isAr ? FontStyle.normal : FontStyle.italic,
              color: AppColors.textBody,
            ),
            textAlign: TextAlign.center,
            textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
          ),

          const SizedBox(height: 16),

          // Divider
          Container(
            height: 1,
            color: AppColors.gold.withAlpha(40),
          ),

          const SizedBox(height: 16),

          // Count
          _buildInfoLine(
            '\uD83D\uDCFF', // 📿
            _card.count != null
                ? (_isAr
                    ? 'قلها: ${_card.countAr ?? _card.count}'
                    : 'Say it: ${_card.count}')
                : (_isAr
                    ? 'قلها مرة بحضور قلب'
                    : 'Say it once with presence of heart'),
          ),

          const SizedBox(height: 8),

          // When
          _buildInfoLine(
            '\uD83D\uDD50', // 🕐
            _isAr
                ? 'متى: ${_card.whenToSayAr}'
                : 'When: ${_card.whenToSay}',
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
              color: AppColors.textPrimary,
            ),
            textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
          ),
        ),
      ],
    );
  }

  Widget _buildPromiseCard() {
    return AnimatedBuilder(
      animation: _shimmerAnim,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _celebrating
                  ? AppColors.gold.withAlpha(
                      (80 + (175 * _shimmerAnim.value)).toInt().clamp(0, 255))
                  : AppColors.gold.withAlpha(80),
              width: _celebrating ? 2 : 1,
            ),
            boxShadow: _celebrating
                ? [
                    BoxShadow(
                      color: AppColors.gold
                          .withAlpha((60 * _shimmerAnim.value).toInt()),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: child,
        );
      },
      child: Column(
        children: [
          // Header
          Text(
            _isAr ? '\u2728 الوعد' : '\u2728 The Promise',
            style: GoogleFonts.cinzelDecorative(
              fontSize: 15,
              color: AppColors.gold,
            ),
            textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
          ),

          const SizedBox(height: 12),

          // Promise text
          Text(
            _isAr ? _card.promiseAr : _card.promiseEn,
            style: GoogleFonts.lora(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
            textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
          ),

          const SizedBox(height: 12),

          // Source
          Text(
            _isAr ? _card.sourceRefAr : _card.sourceRef,
            style: GoogleFonts.nunito(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
            textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
          ),
        ],
      ),
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
