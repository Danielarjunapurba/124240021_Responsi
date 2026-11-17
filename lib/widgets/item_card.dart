import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_theme.dart';
import '../controllers/favorite_controller.dart';
import '../models/item_model.dart';
import 'app_network_image.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.heroTagPrefix = 'item',
  });

  final ItemModel item;
  final VoidCallback onTap;
  final String heroTagPrefix;

  String get heroTag => '$heroTagPrefix-image-${item.id}';

  @override
  Widget build(BuildContext context) {
    final favoriteCtrl = Get.find<FavoriteController>();
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = Theme.of(context).cardTheme.color ?? colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.adaptiveBorder(context)),
        boxShadow: AppTheme.softShadow(context),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Hero(
                      tag: heroTag,
                      child: AppNetworkImage(
                        imageUrl: item.image,
                        width: 88,
                        height: 88,
                        borderRadius: 14,
                      ),
                    ),
                    Positioned(
                      left: 6,
                      bottom: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#${item.id}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.68),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.priceLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                          const Icon(
                            Icons.star_rounded,
                            color: AppTheme.accentColor,
                            size: 16,
                          ),
                          Text(
                            item.rating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Obx(() {
                  final isFav = favoriteCtrl.isFavorite(item.id);
                  return Material(
                    color: isFav
                        ? AppTheme.dangerColor.withValues(alpha: 0.12)
                        : AppTheme.adaptiveMutedSurface(context),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => favoriteCtrl.toggleFavorite(item),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Icon(
                            isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            key: ValueKey(isFav),
                            size: 21,
                            color: isFav
                                ? AppTheme.dangerColor
                                : colorScheme.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
