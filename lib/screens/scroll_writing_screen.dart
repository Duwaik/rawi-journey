import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/scroll_entries.dart';
import '../models/scroll_entry.dart';
import '../services/prefs_service.dart';
import 'event_list_screen.dart';

/// Cinematic scroll-writing screen shown after dhikr, before event list.
/// Reveals the new scroll line with a progressive character animation.
class ScrollWritingScreen extends StatefulWidget {
  final String eventId;

  const ScrollWritingScreen({super.key, required this.eventId});

  @override
  State<ScrollWritingScreen> createState() => _ScrollWritingScreenState();
}

class _ScrollWritingScreenState extends State<ScrollWritingScreen>
    with TickerProviderStateMixin {
  static const _parchment = Color(0xFFF5E6C8);
  static const _inkDark = Color(0xFF402010);
  static const _inkFaded = Color(0x66402010);
  static const _goldShimmer = Color(0xFFD4A843);

  late final ScrollEntry? _entry;
  late final List<ScrollEntry> _previousEntries;

  // Animation controllers
  late final AnimationController _revealCtrl;
  late final AnimationController _shimmerCtrl;
  late final AnimationController _buttonCtrl;

  bool _shimmerDone = false;

  @override
  void initState() {
    super.initState();

    _entry = scrollEntries[widget.eventId];

    // Gather all previous scroll entries (completed events before this one)
    _previousEntries = [];
    final entry = _entry;
    if (entry != null) {
      final sorted = scrollEntries.values.toList()
        ..sort((a, b) => a.globalOrder.compareTo(b.globalOrder));
      for (final e in sorted) {
        if (e.globalOrder < entry.globalOrder &&
            PrefsService.isEventCompleted(e.globalOrder)) {
          _previousEntries.add(e);
        }
      }
    }

    // 3-second character reveal
    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // 200ms gold shimmer
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Button fade-in
    _buttonCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _revealCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onRevealComplete();
      }
    });

    // Start reveal after a brief pause
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _revealCtrl.forward();
    });
  }

  void _onRevealComplete() {
    HapticFeedback.mediumImpact();
    _shimmerCtrl.forward().then((_) {
      if (!mounted) return;
      setState(() => _shimmerDone = true);
      _buttonCtrl.forward();
    });
  }

  @override
  void dispose() {
    _revealCtrl.dispose();
    _shimmerCtrl.dispose();
    _buttonCtrl.dispose();
    super.dispose();
  }

  bool get _isAr => PrefsService.isAr;

  void _goToEventList() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const EventListScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // If no scroll entry for this event, skip straight to event list
    if (_entry == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _goToEventList());
      return const SizedBox.shrink();
    }

    final bottomPad = MediaQuery.of(context).padding.bottom;
    final isAr = _isAr;

    return Scaffold(
      backgroundColor: _parchment,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Center(
                      child: Text(
                        isAr
                            ? '\u0633\u0650\u062C\u0650\u0644\u0651 \u0627\u0644\u0631\u0627\u0648\u064A'
                            : 'The Rawi\u2019s Scroll',
                        style: GoogleFonts.cinzelDecorative(
                          fontSize: 20,
                          color: _inkDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Previous lines (faded)
                    for (final prev in _previousEntries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          isAr ? prev.lineAr : prev.lineEn,
                          textDirection:
                              isAr ? TextDirection.rtl : TextDirection.ltr,
                          style: isAr
                              ? GoogleFonts.amiri(
                                  color: _inkFaded,
                                  fontSize: 16,
                                  height: 2.0,
                                )
                              : GoogleFonts.lora(
                                  color: _inkFaded,
                                  fontSize: 16,
                                  height: 2.0,
                                ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // New line with character reveal animation
                    AnimatedBuilder(
                      animation: Listenable.merge([_revealCtrl, _shimmerCtrl]),
                      builder: (context, _) {
                        final text =
                            isAr ? _entry.lineAr : _entry.lineEn;
                        final revealFraction = _revealCtrl.value;
                        final charCount =
                            (text.length * revealFraction).round();
                        final visibleText = text.substring(0, charCount);

                        // Gold shimmer overlay when shimmer is active
                        final shimmerValue = _shimmerCtrl.value;
                        final lineColor = shimmerValue > 0 && !_shimmerDone
                            ? Color.lerp(_inkDark, _goldShimmer, shimmerValue)!
                            : _inkDark;

                        return Text(
                          visibleText,
                          textDirection:
                              isAr ? TextDirection.rtl : TextDirection.ltr,
                          style: isAr
                              ? GoogleFonts.amiri(
                                  color: lineColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  height: 2.0,
                                )
                              : GoogleFonts.lora(
                                  color: lineColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 2.0,
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Continue button (fades in after animation completes)
            FadeTransition(
              opacity:
                  CurvedAnimation(parent: _buttonCtrl, curve: Curves.easeIn),
              child: Padding(
                padding: EdgeInsets.fromLTRB(28, 0, 28, bottomPad + 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _shimmerDone ? _goToEventList : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _inkDark,
                      foregroundColor: _parchment,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isAr
                          ? '\u0627\u0633\u062A\u0645\u0631'
                          : 'Continue',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
