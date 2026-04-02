import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_colors.dart';
import 'go_deeper_section.dart';

/// Slide-up panel showing a discovery fragment when a hotspot is tapped.
/// When [centerMode] is true, shows as a centered card instead of bottom panel.
class DiscoveryPanel extends StatefulWidget {
  final String label;
  final String fragment;
  final String icon;
  final bool isAr;
  final VoidCallback onDismiss;
  final String? imagePath;
  final bool centerMode;
  final String? deeperContent;

  const DiscoveryPanel({
    super.key,
    required this.label,
    required this.fragment,
    required this.icon,
    required this.isAr,
    required this.onDismiss,
    this.imagePath,
    this.centerMode = false,
    this.deeperContent,
  });

  @override
  State<DiscoveryPanel> createState() => _DiscoveryPanelState();
}

class _DiscoveryPanelState extends State<DiscoveryPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

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
      child: GestureDetector(
        onTap: _dismiss,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Container(
            color: Colors.black.withAlpha(140),
            alignment: Alignment.center,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xF0101820),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.gold.withAlpha(70),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bubble image (larger in center mode)
                    if (hasImage) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 180,
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

                    // Label row
                    Row(
                      children: [
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
                        fontStyle: FontStyle.italic,
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

                    const SizedBox(height: 16),

                    // Tap to continue
                    Container(
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
                        widget.isAr ? 'اضغط للمتابعة' : 'Tap to continue',
                        style: GoogleFonts.nunito(
                          color: AppColors.gold.withAlpha(220),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
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

  // ── Bottom panel mode (original) ───────────────────────────────────────────

  Widget _buildBottom(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final hasImage = widget.imagePath != null;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: _dismiss,
        child: SlideTransition(
          position: _slideAnim,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 16 + bottomPad),
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
                          height: 100,
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
                              fontStyle: FontStyle.italic,
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
                        fontStyle: FontStyle.italic,
                        height: 1.8,
                      ),
                      textDirection:
                          widget.isAr ? TextDirection.rtl : TextDirection.ltr,
                    ),

                  const SizedBox(height: 12),

                  Center(
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
                        widget.isAr ? 'اضغط للمتابعة' : 'Tap to continue',
                        style: GoogleFonts.nunito(
                          color: AppColors.gold.withAlpha(200),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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
