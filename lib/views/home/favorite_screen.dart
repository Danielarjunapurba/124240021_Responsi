import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/app_theme.dart';
import '../../controllers/favorite_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/item_card.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteCtrl = Get.find<FavoriteController>();
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = Theme.of(context).cardTheme.color ?? colorScheme.surface;

    return Obx(() {
      if (favoriteCtrl.favorites.isEmpty) {
        return const EmptyStateWidget(
          icon: Icons.heart_broken,
          title: 'Belum Ada Item Yang Di Wishlistkan',
          subtitle: 'Tekan ikon hati pada item di halaman beranda atau detail untuk menyimpannya di sini.',
        );
      }

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.adaptiveBorder(context)),
                boxShadow: AppTheme.softShadow(context),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: AppTheme.dangerColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: AppTheme.dangerColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Koleksi Tersimpan',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'Geser kartu ke kiri untuk menghapus item',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${favoriteCtrl.favorites.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              itemCount: favoriteCtrl.favorites.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = favoriteCtrl.favorites[index];
                return Dismissible(
                  key: ValueKey('fav-${item.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF87171), AppTheme.dangerColor],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Hapus',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                  onDismissed: (_) => favoriteCtrl.removeFavorite(item),
                  child: ItemCard(
                    item: item,
                    heroTagPrefix: 'fav',
                    onTap: () => Get.toNamed(
                      AppRoutes.detail,
                      arguments: {
                        'item': item,
                        'heroTag': 'fav-image-${item.id}',
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
