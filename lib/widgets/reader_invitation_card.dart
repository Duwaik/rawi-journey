import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../services/prefs_service.dart';

/// R28-RFT-09 Part B · One-time Reader-mode invitation.
///
/// Registration no longer asks Explorer/Reader (Part A) — new users
/// default to Explorer and meet this invitation once, after Event 1
/// completes, so the choice is made AFTER they've actually felt a mode
/// rather than from an unlabelled guess.
///
/// Self-contained: on either choice it writes the mode preference and
/// flips `readerInvitationShown` itself, then calls [onResolved] so the
/// host just continues its flow. This keeps the logic with the widget
/// so RFT-08 can relocate it into the end-of-event Screen B with no
/// behavioural rewrite.
///
/// AR strings are first-pass — flagged for Khaled's sign-off.
class ReaderInvitationCard extends StatelessWidget {
  /// Called after the user picks an option and prefs are written.
  /// [choseReader] = true if they opted into Reader.
  final void Function(bool choseReader) onResolved;
  final bool isAr;

  const ReaderInvitationCard({
    super.key,
    required this.onResolved,
    required this.isAr,
  });

  static const _cardBg = Color(0xFF0E1A28);

  Future<void> _choose(bool reader) async {
    await PrefsService.setJourneyMode(reader ? 'reader' : 'explorer');
    await PrefsService.setReaderInvitationShown();
    onResolved(reader);
  }

  @override
  Widget build(BuildContext context) {
    final td = isAr ? TextDirection.rtl : TextDirection.ltr;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gold.withAlpha(80), width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_stories_rounded,
              size: 30, color: AppColors.gold.withAlpha(220)),
          const SizedBox(height: 12),
          Text(
            isAr
                ? 'تريد تجربة وضع القراءة للحدث القادم؟ يمكنك التبديل في أي وقت من الإعدادات.'
                : 'Want to try Reader mode for the next event? '
                    'You can switch any time in Settings.',
            textAlign: TextAlign.center,
            textDirection: td,
            style: GoogleFonts.lora(
              fontSize: 14,
              color: const Color(0xFFE8D8B8),
              height: 1.55,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _choose(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: const Color(0xFF0B1E2D),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                isAr ? 'نعم، جرّب القارئ' : 'Yes, try Reader',
                textDirection: td,
                style: GoogleFonts.nunito(
                    fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => _choose(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gold,
                side: BorderSide(color: AppColors.gold.withAlpha(120)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                isAr ? 'ابقَ مع المستكشف' : 'Stay with Explorer',
                textDirection: td,
                style: GoogleFonts.nunito(
                    fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
