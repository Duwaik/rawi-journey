import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../character_art.dart';
import '../services/prefs_service.dart';
import 'event_list_screen.dart';

/// One-time story moment after registration, before the event list.
/// Sets context for what the user is about to do. Plays ONCE.
class RawiCallScreen extends StatefulWidget {
  const RawiCallScreen({super.key});

  @override
  State<RawiCallScreen> createState() => _RawiCallScreenState();
}

class _RawiCallScreenState extends State<RawiCallScreen> {
  bool _disposed = false;

  // Animation state — each element fades in at a specific time
  double _portraitOpacity = 0.0;
  double _portraitScale = 0.8;
  double _headerOpacity = 0.0;
  double _line1Opacity = 0.0;
  double _line2Opacity = 0.0;
  double _line3Opacity = 0.0;
  double _line4Opacity = 0.0;
  double _buttonOpacity = 0.0;

  bool get _isAr => PrefsService.isAr;
  bool get _isFemale => PrefsService.userGender == 'female';
  String get _userName => PrefsService.userName.isNotEmpty
      ? PrefsService.userName
      : (_isFemale ? (_isAr ? 'الراوية' : 'Rawiah') : (_isAr ? 'الراوي' : 'Rawi'));

  @override
  void initState() {
    super.initState();
    _runSequence();
  }

  Future<void> _runSequence() async {
    // Step 1: Portrait (0.5s)
    await Future.delayed(const Duration(milliseconds: 500));
    if (_disposed) return;
    await _fadeIn((v) { _portraitOpacity = v; _portraitScale = 0.8 + v * 0.2; }, 500);

    // Step 2: Header (1.5s)
    await Future.delayed(const Duration(milliseconds: 500));
    if (_disposed) return;
    await _fadeIn((v) => _headerOpacity = v, 400);

    // Step 3: Line 1 (3.0s)
    await Future.delayed(const Duration(milliseconds: 500));
    if (_disposed) return;
    await _fadeIn((v) => _line1Opacity = v, 400);

    // Step 4: Line 2 (4.5s)
    await Future.delayed(const Duration(milliseconds: 1100));
    if (_disposed) return;
    await _fadeIn((v) => _line2Opacity = v, 400);

    // Step 5: Line 3 (6.0s)
    await Future.delayed(const Duration(milliseconds: 1100));
    if (_disposed) return;
    await _fadeIn((v) => _line3Opacity = v, 400);

    // Step 6: Line 4 (7.5s)
    await Future.delayed(const Duration(milliseconds: 1100));
    if (_disposed) return;
    await _fadeIn((v) => _line4Opacity = v, 400);

    // Step 7: Button (9.0s)
    await Future.delayed(const Duration(milliseconds: 1100));
    if (_disposed) return;
    await _fadeIn((v) => _buttonOpacity = v, 400);
  }

  Future<void> _fadeIn(void Function(double) setter, int ms) async {
    final steps = (ms / 16).round();
    for (int s = 1; s <= steps; s++) {
      if (_disposed) return;
      await Future.delayed(const Duration(milliseconds: 16));
      if (_disposed) return;
      setState(() => setter(s / steps));
    }
    if (!_disposed) setState(() => setter(1.0));
  }

  void _proceed() {
    PrefsService.setRawiCallShown();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const EventListScreen(),
        transitionsBuilder: (context, anim, secondaryAnimation, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Content
    final header = _isFemale
        ? (_isAr ? 'نداء الراوية' : 'The Rawiah\'s Call')
        : (_isAr ? 'نداء الراوي' : 'The Rawi\'s Call');

    final line1 = _isFemale
        ? (_isAr ? 'أنتِ الآن $_userName، الراوية.' : 'You are now $_userName, the Rawiah.')
        : (_isAr ? 'أنت الآن $_userName، الراوي.' : 'You are now $_userName, the Rawi.');

    final line2 = _isFemale
        ? (_isAr
            ? 'دورك بسيط: امشي في مشاهد التاريخ واكتشفي ما حدث في كل مكان واحملي الرواية إلى من بعدك.'
            : 'Your role is simple: walk through the scenes of history, discover what happened at each place, and carry the story forward.')
        : (_isAr
            ? 'دورك بسيط: امشِ في مشاهد التاريخ واكتشف ما حدث في كل مكان واحمل الرواية إلى من بعدك.'
            : 'Your role is simple: walk through the scenes of history, discover what happened at each place, and carry the story forward.');

    final line3 = _isAr
        ? 'كل حدث لحظة في الزمن.\nكل موقع قطعة من الحقيقة.\nوفي النهاية سيسألك التاريخ\nماذا يحفظ.'
        : 'Every event is a moment in time.\nEvery hotspot is a piece of the truth.\nAt the end, history will ask you\nwhat it remembers.';

    final line4 = _isFemale
        ? (_isAr ? 'أجيبي جيداً، وستستمر السلسلة.' : 'Answer well, and the chain continues.')
        : (_isAr ? 'أجب جيداً، وستستمر السلسلة.' : 'Answer well, and the chain continues.');

    final buttonText = _isFemale
        ? (_isAr ? 'ابدأي' : 'Begin')
        : (_isAr ? 'ابدأ' : 'Begin');

    final textDir = _isAr ? TextDirection.rtl : TextDirection.ltr;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Portrait
              Opacity(
                opacity: _portraitOpacity,
                child: Transform.scale(
                  scale: _portraitScale,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 1.5),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        CharacterArt.portrait(),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Opacity(
                opacity: _headerOpacity,
                child: Text(
                  header,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: AppColors.gold.withAlpha(150),
                    letterSpacing: 3,
                    fontWeight: FontWeight.w600,
                  ),
                  textDirection: textDir,
                ),
              ),
              const SizedBox(height: 24),

              // Line 1 — name in gold
              Opacity(
                opacity: _line1Opacity,
                child: Text(
                  line1,
                  textAlign: TextAlign.center,
                  textDirection: textDir,
                  style: GoogleFonts.lora(
                    fontSize: 16,
                    color: AppColors.gold,
                    height: 1.8,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Line 2
              Opacity(
                opacity: _line2Opacity,
                child: Text(
                  line2,
                  textAlign: TextAlign.center,
                  textDirection: textDir,
                  style: GoogleFonts.lora(
                    fontSize: 14,
                    fontStyle: _isAr ? FontStyle.normal : FontStyle.italic,
                    color: Colors.white.withAlpha(200),
                    height: 2.0,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Line 3
              Opacity(
                opacity: _line3Opacity,
                child: Text(
                  line3,
                  textAlign: TextAlign.center,
                  textDirection: textDir,
                  style: GoogleFonts.lora(
                    fontSize: 14,
                    fontStyle: _isAr ? FontStyle.normal : FontStyle.italic,
                    color: Colors.white.withAlpha(200),
                    height: 2.0,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Line 4 — closing
              Opacity(
                opacity: _line4Opacity,
                child: Text(
                  line4,
                  textAlign: TextAlign.center,
                  textDirection: textDir,
                  style: GoogleFonts.lora(
                    fontSize: 15,
                    color: Colors.white,
                    height: 1.8,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Begin button
              Opacity(
                opacity: _buttonOpacity,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _buttonOpacity > 0.9 ? _proceed : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.bg,
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      buttonText,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
