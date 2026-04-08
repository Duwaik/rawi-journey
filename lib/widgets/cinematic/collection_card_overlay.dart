import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app_colors.dart';
import '../../models/collection_item.dart';
import '../../services/prefs_service.dart';

/// Slide-up card overlay shown after event completion when a
/// collection item is discovered. "Add to collection" confirms.
class CollectionCardOverlay extends StatefulWidget {
  final CollectionItem item;
  final VoidCallback onDismiss;

  const CollectionCardOverlay({
    super.key,
    required this.item,
    required this.onDismiss,
  });

  @override
  State<CollectionCardOverlay> createState() => _CollectionCardOverlayState();
}

class _CollectionCardOverlayState extends State<CollectionCardOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  bool get _isAr => PrefsService.isAr;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  Future<void> _dismiss() async {
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return FadeTransition(
      opacity: _fade,
      child: Container(
        color: Colors.black.withAlpha(180),
        child: SlideTransition(
          position: _slide,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.gold.withAlpha(100), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withAlpha(30),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Text(
                    _isAr ? 'لقد اكتشفت:' : 'You have discovered:',
                    style: GoogleFonts.nunito(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Item icon placeholder (category-based)
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold.withAlpha(20),
                      border: Border.all(color: AppColors.gold.withAlpha(80)),
                    ),
                    child: Icon(
                      _categoryIcon(item.category),
                      color: AppColors.gold,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Name
                  Text(
                    _isAr ? item.nameAr : item.name,
                    textAlign: TextAlign.center,
                    textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
                    style: GoogleFonts.lora(
                      color: AppColors.gold,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    _isAr ? item.descriptionAr : item.description,
                    textAlign: TextAlign.center,
                    textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
                    style: GoogleFonts.nunito(
                      color: AppColors.textBody,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Add button
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _dismiss,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.bg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _isAr ? 'أضف إلى المجموعة' : 'Add to collection',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
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

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'people': return Icons.person_rounded;
      case 'places': return Icons.place_rounded;
      case 'artifacts': return Icons.auto_awesome_rounded;
      case 'moments': return Icons.flash_on_rounded;
      default: return Icons.star_rounded;
    }
  }
}
