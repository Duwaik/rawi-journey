import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';
import '../data/collection_data.dart';
import '../models/collection_item.dart';
import '../services/prefs_service.dart';

/// Grid gallery of all collection items. Discovered items show
/// full color + name. Undiscovered show silhouette + "???".
class CollectionGalleryScreen extends StatelessWidget {
  const CollectionGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = PrefsService.isAr;
    final discovered = PrefsService.discoveredCollectionIds;
    final total = allCollectionItems.length;
    final found = allCollectionItems
        .where((item) => discovered.contains(item.id))
        .length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textMuted, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isAr ? 'المجموعة' : 'Collection',
          style: GoogleFonts.cinzelDecorative(
            color: AppColors.gold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              '$found/$total ${isAr ? "اكتُشف" : "discovered"}',
              style: GoogleFonts.nunito(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ),
          // B23: Guidance text — visible when nothing is discovered yet,
          // muted but still readable once user has started unlocking.
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 24, right: 24),
            child: Text(
              isAr
                  ? 'العب الأحداث لفتح عناصر المجموعة'
                  : 'Play events to unlock collection items',
              textAlign: TextAlign.center,
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              style: GoogleFonts.nunito(
                color: AppColors.textMuted.withAlpha(found == 0 ? 200 : 140),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          // Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemCount: total,
              itemBuilder: (context, index) {
                final item = allCollectionItems[index];
                final isDiscovered = discovered.contains(item.id);
                return _CollectionTile(
                  item: item,
                  discovered: isDiscovered,
                  isAr: isAr,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionTile extends StatelessWidget {
  final CollectionItem item;
  final bool discovered;
  final bool isAr;

  const _CollectionTile({
    required this.item,
    required this.discovered,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: discovered ? AppColors.card : AppColors.card.withAlpha(60),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: discovered
              ? AppColors.gold.withAlpha(80)
              : AppColors.textMuted.withAlpha(30),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: discovered
                  ? AppColors.gold.withAlpha(20)
                  : Colors.transparent,
              border: Border.all(
                color: discovered
                    ? AppColors.gold.withAlpha(80)
                    : AppColors.textMuted.withAlpha(40),
              ),
            ),
            child: Icon(
              discovered ? _categoryIcon(item.category) : Icons.lock_rounded,
              color: discovered
                  ? AppColors.gold
                  : AppColors.textMuted.withAlpha(60),
              size: discovered ? 22 : 18,
            ),
          ),
          const SizedBox(height: 8),

          // Name or ???
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              discovered ? (isAr ? item.nameAr : item.name) : '???',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                color: discovered
                    ? AppColors.gold
                    : AppColors.textMuted.withAlpha(60),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
