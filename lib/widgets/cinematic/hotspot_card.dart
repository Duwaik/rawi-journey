import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_colors.dart';
import '../../character_art.dart';
import '../../services/audio_service.dart';
import '../../services/prefs_service.dart';
import '../scroll_hint_wrapper.dart';
import 'go_deeper_section.dart';

/// Slide-up panel showing a discovery fragment when a hotspot is tapped.
/// When [centerMode] is true, shows as a centered card instead of bottom panel.
class HotspotCard extends StatefulWidget {
  final String label;
  final String fragment;
  final String icon;
  final bool isAr;
  final VoidCallback onDismiss;
  final String? imagePath;
  final bool centerMode;
  final String? deeperContent;
  final String? voPath;
  final String? didYouKnow;
  final String? didYouKnowAr;
  final String? sourceRef;
  final String? sourceRefAr;

  const HotspotCard({
    super.key,
    required this.label,
    required this.fragment,
    required this.icon,
    required this.isAr,
    required this.onDismiss,
    this.imagePath,
    this.centerMode = false,
    this.deeperContent,
    this.voPath,
    this.didYouKnow,
    this.didYouKnowAr,
    this.sourceRef,
    this.sourceRefAr,
  });

  @override
  State<HotspotCard> createState() => _HotspotCardState();
}

class _HotspotCardState extends State<HotspotCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  final ScrollController _scrollCtrl = ScrollController();

  // "Did You Know?" state
  String? _dykResponse; // null = not answered, 'knew' or 'new'

  String? get _dykText => widget.isAr ? widget.didYouKnowAr : widget.didYouKnow;
  String? get _sourceText => widget.isAr ? widget.sourceRefAr : widget.sourceRef;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.centerMode ? 350 : 400),
    );

    if (widget.centerMode) {
      _scaleAnim = Tween<double>(begin: 0.85, end: 1.0)
          .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutBack));
    } else {
      _scaleAnim = const AlwaysStoppedAnimation(1.0);
    }

    _slideAnim = Tween<Offset>(
      begin: widget.centerMode ? Offset.zero : const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));

    _fadeAnim = CurvedAnimation(parent: _anim, curve: Curves.easeIn);
    _anim.forward();
  }

  void _dismiss() async {
    await _anim.reverse();
    if (mounted) widget.onDismiss();
  }

  @override
  void dispose() {
    _anim.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.centerMode) {
      return _buildCentered(context);
    }
    return _buildBottom(context);
  }

  // ── Centered card mode ─────────────────────────────────────────────────────

  Widget _buildCentered(BuildContext context) {
    final hasImage = widget.imagePath != null;

    return Positioned.fill(
      // R26 S1v2-EE8: outer tap is a no-op (swallow) instead of a
      // dismiss. Accidental taps on the scene behind the card used to
      // advance past content the user meant to read. The "Tap to
      // continue" pill below is now the only dismiss path.
      child: GestureDetector(
        onTap: () {},
        behavior: HitTestBehavior.opaque,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Container(
            color: Colors.black.withAlpha(140),
            alignment: Alignment.center,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color(0xF0101820),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFC9A84C).withAlpha(60),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withAlpha(15),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: Stack(
                    children: [
                      // Subtle parchment texture overlay
                      Positioned.fill(
                        child: Image.asset(
                          'assets/textures/parchment_light.jpg',
                          fit: BoxFit.cover,
                          opacity: const AlwaysStoppedAnimation(0.08),
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.75,
                  ),
                  child: ScrollHintWrapper(
                    controller: _scrollCtrl,
                    child: SingleChildScrollView(
                      controller: _scrollCtrl,
                      child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bubble image (larger in center mode)
                    if (hasImage) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: 170 * PrefsService.textScale,
                          ),
                          child: Image.asset(
                            widget.imagePath!,
                            fit: BoxFit.contain,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Label row with witnessing portrait
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            CharacterArt.witnessing(),
                            width: 32, height: 32, fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(widget.icon,
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.label,
                            style: GoogleFonts.cinzelDecorative(
                              color: AppColors.gold,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Fragment text
                    Text(
                      widget.fragment,
                      style: GoogleFonts.lora(
                        color: const Color(0xFFD6CCBE),
                        fontSize: 15,
                        fontStyle: widget.isAr ? FontStyle.normal : FontStyle.italic,
                        height: 1.8,
                      ),
                      textDirection:
                          widget.isAr ? TextDirection.rtl : TextDirection.ltr,
                    ),

                    // Go Deeper (if available)
                    if (widget.deeperContent != null)
                      GoDeeperSection(
                        content: widget.deeperContent!,
                        isAr: widget.isAr,
                      ),

                    // "Did You Know?" section — always visible when DYK exists.
                    // Buttons below remain for engagement feedback but do NOT
                    // gate the "Tap to continue" button.
                    if (_dykText != null) ...[
                      const SizedBox(height: 14),
                      // Subtle gold separator below fragment
                      Container(height: 1, color: AppColors.gold.withAlpha(50)),
                      const SizedBox(height: 12),
                      Row(children: [
                        Text('✨ ',
                            style: const TextStyle(fontSize: 14)),
                        Text(
                          widget.isAr ? 'هل تعلم؟' : 'Did You Know?',
                          style: GoogleFonts.nunito(
                            color: AppColors.gold,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Text(
                        _dykText!,
                        style: GoogleFonts.lora(
                          color: const Color(0xFFD6CCBE),
                          fontSize: 14,
                          fontStyle: widget.isAr ? FontStyle.normal : FontStyle.italic,
                          height: 1.7,
                        ),
                        textDirection: widget.isAr ? TextDirection.rtl : TextDirection.ltr,
                      ),
                      const SizedBox(height: 12),
                      // Engagement buttons — visual feedback only, no gating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _DykButton(
                            label: widget.isAr ? 'كنت أعرف' : 'I knew this',
                            selected: _dykResponse == 'knew',
                            onTap: () => setState(() => _dykResponse = 'knew'),
                          ),
                          const SizedBox(width: 12),
                          _DykButton(
                            label: widget.isAr ? 'جديدة عليّ' : 'New to me',
                            selected: _dykResponse == 'new',
                            onTap: () => setState(() => _dykResponse = 'new'),
                          ),
                        ],
                      ),
                    ],

                    // Source reference
                    if (_sourceText != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '📖 $_sourceText',
                        style: GoogleFonts.nunito(
                          color: const Color(0xFF8A9BB0),
                          fontSize: 11,
                        ),
                        textDirection: widget.isAr ? TextDirection.rtl : TextDirection.ltr,
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Tap to continue + VO replay — always visible (no DYK gate)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.voPath != null) ...[
                          // Replay VO
                          GestureDetector(
                            onTap: () {
                              // playVoiceover fades previous internally (LOCKED RULE)
                              AudioService.playVoiceover(widget.voPath!);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              margin: const EdgeInsetsDirectional.only(end: 6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.gold.withAlpha(25),
                                border: Border.all(
                                    color: AppColors.gold.withAlpha(80)),
                              ),
                              child: Icon(Icons.replay_rounded,
                                  size: 14, color: AppColors.gold.withAlpha(200)),
                            ),
                          ),
                          // Mute/unmute VO
                          GestureDetector(
                            onTap: () {
                              if (PrefsService.voEnabled) {
                                AudioService.fadeOutVoiceover(
                                    duration: const Duration(milliseconds: 200));
                                PrefsService.setVoEnabled(false);
                              } else {
                                PrefsService.setVoEnabled(true);
                              }
                              setState(() {}); // Rebuild to update icon
                            },
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              margin: const EdgeInsetsDirectional.only(end: 10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.gold.withAlpha(15),
                                border: Border.all(
                                    color: AppColors.gold.withAlpha(50)),
                              ),
                              child: Icon(
                                PrefsService.voEnabled
                                    ? Icons.volume_up_rounded
                                    : Icons.volume_off_rounded,
                                size: 14,
                                color: PrefsService.voEnabled
                                    ? AppColors.gold.withAlpha(180)
                                    : AppColors.textMuted.withAlpha(120)),
                            ),
                          ),
                        ],
                        // R26 S1v2-EE8: the pill is now THE dismiss
                        // control — outer outside-tap no longer works.
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _dismiss,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withAlpha(30),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.gold.withAlpha(80),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.isAr
                                  ? 'متابعة'
                                  : 'Continue',
                              style: GoogleFonts.nunito(
                                color: AppColors.gold.withAlpha(220),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ), // SingleChildScrollView
            ), // ScrollHintWrapper
          ), // ConstrainedBox
                      ), // Padding
                    ],
                  ), // Stack
                ), // ClipRRect
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Bottom panel mode (original) ───────────────────────────────────────────

  Widget _buildBottom(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final hasImage = widget.imagePath != null;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      // R26 S1v2-EE8: outer tap swallowed — dismiss lives on the
      // "Tap to continue" pill below.
      child: GestureDetector(
        onTap: () {},
        behavior: HitTestBehavior.opaque,
        child: SlideTransition(
          position: _slideAnim,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Container(
              padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 16 + bottomPad),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(0),
                    Colors.black.withAlpha(220),
                    Colors.black.withAlpha(245),
                  ],
                  stops: const [0.0, 0.12, 0.35],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label row
                  Row(
                    children: [
                      Text(widget.icon,
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.label,
                          style: GoogleFonts.cinzelDecorative(
                            color: AppColors.gold,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Image + Fragment
                  if (hasImage)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          height: 100 * PrefsService.textScale,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.gold.withAlpha(60),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withAlpha(20),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Image.asset(
                              widget.imagePath!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            widget.fragment,
                            style: GoogleFonts.lora(
                              color: const Color(0xFFD6CCBE),
                              fontSize: 14,
                              fontStyle: widget.isAr ? FontStyle.normal : FontStyle.italic,
                              height: 1.7,
                            ),
                            textDirection: widget.isAr
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      widget.fragment,
                      style: GoogleFonts.lora(
                        color: const Color(0xFFD6CCBE),
                        fontSize: 15,
                        fontStyle: widget.isAr ? FontStyle.normal : FontStyle.italic,
                        height: 1.8,
                      ),
                      textDirection:
                          widget.isAr ? TextDirection.rtl : TextDirection.ltr,
                    ),

                  const SizedBox(height: 12),

                  Center(
                    // R26 S1v2-EE8: bottom-sheet pill also promoted to
                    // the sole dismiss control.
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _dismiss,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.gold.withAlpha(80),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.isAr ? 'متابعة' : 'Continue',
                          style: GoogleFonts.nunito(
                            color: AppColors.gold.withAlpha(200),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DykButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DykButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: selected ? AppColors.teal.withAlpha(40) : Colors.transparent,
          border: Border.all(
            color: selected ? AppColors.teal : AppColors.textMuted.withAlpha(60),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.teal : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
