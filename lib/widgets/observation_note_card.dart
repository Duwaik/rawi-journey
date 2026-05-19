import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../data/observation_notes.dart';

/// R28-RFT-07 · OBS3 observation-note beat.
///
/// Rendered as a full-bleed overlay between the answered verdict and
/// the cinematic reveal: a quiet third-person Rawi remark reflecting
/// on the answer the user chose, then an explicit user-gated Continue
/// (NOT auto-advance — the user controls the pacing). On Continue the
/// host resumes the existing cinematic-reveal flow.
///
/// Copy is resolved from [observationNoteFor] (placeholder until
/// Khaled's content pass — flagged in handoff).
class ObservationNoteCard extends StatelessWidget {
  final ObservationNote note;
  final bool isAr;
  final VoidCallback onContinue;

  const ObservationNoteCard({
    super.key,
    required this.note,
    required this.isAr,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final td = isAr ? TextDirection.rtl : TextDirection.ltr;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Positioned.fill(
      child: Container(
        // Mid-strength scrim so the held scene reads behind the note
        // without competing with it.
        color: const Color(0xFF04060D).withValues(alpha: 0.78),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(28, 28, 28, bottomPad + 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Icon(Icons.menu_book_rounded,
                    size: 30, color: AppColors.gold.withAlpha(200)),
                const SizedBox(height: 20),
                Text(
                  isAr ? note.ar : note.en,
                  textAlign: TextAlign.center,
                  textDirection: td,
                  style: GoogleFonts.lora(
                    fontSize: 17,
                    height: 1.7,
                    fontStyle: isAr ? FontStyle.normal : FontStyle.italic,
                    color: const Color(0xFFE8D8B8),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: const Color(0xFF0B1E2D),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text(
                      isAr ? 'تابع' : 'Continue',
                      textDirection: td,
                      style: GoogleFonts.nunito(
                          fontSize: 16, fontWeight: FontWeight.w800),
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
