import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/app_theme.dart';
import '../../controllers/favorite_controller.dart';
import '../../controllers/home_controller.dart';
import '../../models/item_model.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_state_widget.dart';
import '../../widgets/status_badge.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final HomeController _homeController = Get.find<HomeController>();
  final FavoriteController _favoriteController = Get.find<FavoriteController>();

  String _itemId = '';
  ItemModel? _initialItem;
  String? _heroTag;

  @override
  void initState() {
    super.initState();
    final arg = Get.arguments;
    if (arg is ItemModel) {
      _initialItem = arg;
      _itemId = arg.id;
    } else if (arg is Map<String, dynamic>) {
      final rawItem = arg['item'];
      if (rawItem is ItemModel) {
        _initialItem = rawItem;
        _itemId = rawItem.id;
      }
      if (arg['heroTag'] is String) {
        _heroTag = arg['heroTag'] as String;
      }
    } else if (arg is String) {
      _itemId = arg;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_itemId.isNotEmpty) {
        _homeController.loadItemDetail(_itemId, initialItem: _initialItem);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = Theme.of(context).cardTheme.color ?? colorScheme.surface;

    return Scaffold(
      body: Obx(() {
        final item = _homeController.detailItem.value;

        if (_homeController.isDetailLoading.value && item == null) {
          return const SafeArea(
            child: LoadingStateWidget(message: 'Memuat detail...'),
          );
        }

        if (_homeController.detailError.value.isNotEmpty && item == null) {
          return SafeArea(
            child: ErrorStateWidget(
              message: _homeController.detailError.value,
              onRetry: () => _homeController.loadItemDetail(
                _itemId,
                initialItem: _initialItem,
              ),
            ),
          );
        }

        if (item == null) {
          return const Center(child: Text('Item tidak tersedia.'));
        }

        final isFav = _favoriteController.isFavorite(item.id);

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 330,
              pinned: true,
              stretch: true,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.45),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.45),
                    child: IconButton(
                      tooltip: isFav
                          ? 'Hapus dari Favorit'
                          : 'Simpan ke Favorit',
                      onPressed: () => _favoriteController.toggleFavorite(item),
                      icon: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFav ? AppTheme.dangerColor : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: _heroTag ?? 'detail-image-${item.id}',
                      child: AppNetworkImage(
                        imageUrl: item.image,
                        borderRadius: 0,
                        fit: BoxFit.cover,
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.25),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.78),
                          ],
                          stops: const [0, 0.45, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              StatusBadge(label: item.status),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'ID #${item.id}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.name,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _QuickStatTile(
                                icon: Icons.category_outlined,
                                label: 'Kategori',
                                value: item.category,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _QuickStatTile(
                                icon: Icons.sell_outlined,
                                label: 'Harga',
                                value: item.priceLabel,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _QuickStatTile(
                                icon: Icons.star_rounded,
                                label: 'Rating',
                                value: item.rating.toStringAsFixed(1),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.adaptiveBorder(context),
                            ),
                            boxShadow: AppTheme.softShadow(context),
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Informasi Lengkap',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              ...item.detailAttributes.asMap().entries.map((e) {
                                final isLast =
                                    e.key == item.detailAttributes.length - 1;
                                final attr = e.value;
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 132,
                                            child: Text(
                                              attr.key,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: colorScheme.onSurface
                                                        .withValues(alpha: 0.6),
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              attr.value,
                                              textAlign: TextAlign.end,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!isLast)
                                      Divider(
                                        height: 1,
                                        color: AppTheme.adaptiveBorder(context)
                                            .withValues(alpha: 0.5),
                                      ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final item = _homeController.detailItem.value;
        if (item == null) return const SizedBox.shrink();
        final isFav = _favoriteController.isFavorite(item.id);
        final surface =
            Theme.of(context).cardTheme.color ?? colorScheme.surface;

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: surface,
            border: Border(
              top: BorderSide(color: AppTheme.adaptiveBorder(context)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFav
                          ? AppTheme.dangerColor
                          : colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _favoriteController.toggleFavorite(item),
                    icon: Icon(
                      isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                    ),
                    label: Text(
                      isFav ? 'Hapus dari Favorit' : 'Tambahkan ke Favorit',
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _QuickStatTile extends StatelessWidget {
  const _QuickStatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = Theme.of(context).cardTheme.color ?? colorScheme.surface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.adaptiveBorder(context)),
        boxShadow: AppTheme.softShadow(context),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.58),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
