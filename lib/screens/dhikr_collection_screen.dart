import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../data/dhikr_data.dart';
import '../data/m1_data.dart';
import '../models/dhikr_card.dart';
import '../services/prefs_service.dart';

/// B10: Dhikr Card Collection.
///
/// - Featured "Dhikr of the Day" at the top (rotates daily via day-of-year
///   modulo count-of-unlocked dhikr).
/// - Scrollable collection below: every event that has an associated dhikr
///   card. Unlocked when the event is completed.
/// - Locked cards show a silhouette with "Play Event X to unlock" hint.
class DhikrCollectionScreen extends StatelessWidget {
  const DhikrCollectionScreen({super.key});

  bool _isUnlocked(String eventId, int globalOrder) {
    return PrefsService.isEventCompleted(globalOrder);
  }

  DhikrCard? _featuredFor(List<_DhikrRow> unlocked) {
    if (unlocked.isEmpty) return null;
    final now = DateTime.now();
    final jan1 = DateTime(now.year, 1, 1);
    final dayOfYear = now.difference(jan1).inDays;
    return unlocked[dayOfYear % unlocked.length].card;
  }

  @override
  Widget build(BuildContext context) {
    final isAr = PrefsService.isAr;
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    // Build rows in event order (eventId matches m1Events[i].id).
    final rows = <_DhikrRow>[];
    for (final event in m1Events) {
      final card = dhikrCards[event.id];
      if (card == null) continue;
      rows.add(_DhikrRow(
        card: card,
        eventOrder: event.globalOrder,
        eventTitle: isAr ? event.titleAr : event.title,
        unlocked: _isUnlocked(event.id, event.globalOrder),
      ));
    }
    final unlocked = rows.where((r) => r.unlocked).toList();
    final featured = _featuredFor(unlocked);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF04060D), Color(0xFF0B1E2D), Color(0xFF04060D)],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.fromLTRB(16, topPad + 12, 12, 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold.withAlpha(20),
                        border: Border.all(
                            color: AppColors.gold.withAlpha(60)),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          size: 18, color: AppColors.gold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isAr ? 'الأذكار' : 'Dhikr Collection',
                      textDirection:
                          isAr ? TextDirection.rtl : TextDirection.ltr,
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 20,
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${unlocked.length}/${rows.length}',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding:
                    EdgeInsets.fromLTRB(16, 0, 16, bottomPad + 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  // ── Dhikr of the Day (featured) ─────────────────
                  if (featured != null)
                    _FeaturedDhikrCard(card: featured, isAr: isAr)
                  else
                    _EmptyFeatured(isAr: isAr),

                  const SizedBox(height: 20),
                  Text(
                    isAr ? 'المجموعة' : 'The Collection',
                    textDirection:
                        isAr ? TextDirection.rtl : TextDirection.ltr,
                    textAlign: isAr ? TextAlign.right : TextAlign.left,
                    style: GoogleFonts.cinzelDecorative(
                      color: AppColors.gold.withAlpha(180),
                      fontSize: 13,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── All cards (unlocked + locked silhouettes) ────
                  for (final row in rows)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: row.unlocked
                          ? _UnlockedCard(row: row, isAr: isAr)
                          : _LockedCard(row: row, isAr: isAr),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DhikrRow {
  final DhikrCard card;
  final int eventOrder;
  final String eventTitle;
  final bool unlocked;
  const _DhikrRow({
    required this.card,
    required this.eventOrder,
    required this.eventTitle,
    required this.unlocked,
  });
}

class _FeaturedDhikrCard extends StatefulWidget {
  final DhikrCard card;
  final bool isAr;
  const _FeaturedDhikrCard({required this.card, required this.isAr});

  @override
  State<_FeaturedDhikrCard> createState() => _FeaturedDhikrCardState();
}

class _FeaturedDhikrCardState extends State<_FeaturedDhikrCard> {
  /// R26 S1v2-EE6: session-local "said today" flag. Prevents the user
  /// from stacking regens by tapping I-said-it repeatedly. A full
  /// "daily reset" would need a date-keyed pref; Khaled's spec note:
  /// "don't over-engineer this" — session-scoped is enough until the
  /// daily counter lands.
  bool _saidThisSession = false;
  bool _busy = false;

  Future<void> _onSaidIt() async {
    if (_saidThisSession || _busy) return;
    setState(() => _busy = true);
    HapticFeedback.mediumImpact();
    final before = PrefsService.noorLevel;
    await PrefsService.incrementDhikrCount();
    // Tent-side regen: +25 Light, clamped to 100 ceiling in setNoorLevel.
    await PrefsService.setNoorLevel(before + 25);
    if (!mounted) return;
    setState(() {
      _saidThisSession = true;
      _busy = false;
    });
  }

  DhikrCard get card => widget.card;
  bool get isAr => widget.isAr;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1A28),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gold, width: 1.4),
        boxShadow: [
          BoxShadow(
              color: AppColors.gold.withAlpha(40), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isAr ? 'ذكر اليوم ✦' : 'Dhikr of the Day ✦',
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzelDecorative(
              color: AppColors.gold,
              fontSize: 13,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            card.arabicText,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              color: AppColors.gold,
              fontSize: 22,
              height: 1.9,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            card.transliteration,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              color: AppColors.textMuted.withAlpha(200),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isAr ? card.meaningAr : card.meaningEn,
            textAlign: TextAlign.center,
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            style: GoogleFonts.lora(
              color: AppColors.textBody,
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 1,
            color: AppColors.gold.withAlpha(40),
          ),
          const SizedBox(height: 10),
          Text(
            isAr ? card.promiseAr : card.promiseEn,
            textAlign: TextAlign.center,
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            style: GoogleFonts.nunito(
              color: AppColors.gold.withAlpha(200),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          // R26 S1v2-EE6: tent-side dhikr regen — "I said it" button on
          // the Dhikr of the Day featured card. Tapping increments the
          // lifetime dhikr count and restores +25% Light (clamped to
          // 100). After tap the button flips to a subtle "✓ Said"
          // indicator for the rest of this session.
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _saidThisSession ? null : _onSaidIt,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(
                    horizontal: 22, vertical: 10),
                decoration: BoxDecoration(
                  color: _saidThisSession
                      ? AppColors.gold.withAlpha(30)
                      : AppColors.gold,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                      color: AppColors.gold,
                      width: _saidThisSession ? 0.8 : 1.2),
                ),
                child: Text(
                  _saidThisSession
                      ? (isAr ? '✓ قلتها' : '✓ Said')
                      : (isAr ? 'قلتها ✓' : "I've said it ✓"),
                  textDirection:
                      isAr ? TextDirection.rtl : TextDirection.ltr,
                  style: GoogleFonts.nunito(
                    color: _saidThisSession
                        ? AppColors.gold.withAlpha(200)
                        : const Color(0xFF0A0E18),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnlockedCard extends StatelessWidget {
  final _DhikrRow row;
  final bool isAr;
  const _UnlockedCard({required this.row, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1A28),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            row.card.arabicText,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              color: AppColors.gold,
              fontSize: 17,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isAr ? row.card.meaningAr : row.card.meaningEn,
            textAlign: TextAlign.center,
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            style: GoogleFonts.lora(
              color: AppColors.textMuted.withAlpha(220),
              fontSize: 12,
              height: 1.45,
              fontStyle: isAr ? FontStyle.normal : FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isAr
                ? 'من الحدث ${row.eventOrder} — ${row.eventTitle}'
                : 'From Event ${row.eventOrder} — ${row.eventTitle}',
            textAlign: isAr ? TextAlign.right : TextAlign.left,
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            style: GoogleFonts.nunito(
              color: AppColors.gold.withAlpha(140),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedCard extends StatelessWidget {
  final _DhikrRow row;
  final bool isAr;
  const _LockedCard({required this.row, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1A28).withAlpha(140),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textMuted.withAlpha(40)),
      ),
      child: Row(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Icon(Icons.lock_rounded,
              color: AppColors.textMuted.withAlpha(120), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isAr
                  ? 'العب الحدث ${row.eventOrder} للفتح'
                  : 'Play Event ${row.eventOrder} to unlock',
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              style: GoogleFonts.nunito(
                color: AppColors.textMuted.withAlpha(160),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFeatured extends StatelessWidget {
  final bool isAr;
  const _EmptyFeatured({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1A28),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gold.withAlpha(50)),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_awesome_rounded,
              color: AppColors.gold.withAlpha(120), size: 28),
          const SizedBox(height: 10),
          Text(
            isAr
                ? 'أكمل أوّل حدث لفتح أول ذكر'
                : 'Complete your first event to unlock your first dhikr',
            textAlign: TextAlign.center,
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            style: GoogleFonts.nunito(
              color: AppColors.textMuted,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
