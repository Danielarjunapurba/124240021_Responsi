import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/app_config.dart';
import '../../config/app_theme.dart';
import '../../controllers/home_controller.dart';
import '../../models/item_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/item_card.dart';
import '../../widgets/loading_state_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final HomeController _homeController = Get.find<HomeController>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleClearSearch() {
    _searchController.clear();
    _homeController.clearSearch();
  }

  void _handleResetAll() {
    _searchController.clear();
    _homeController.resetFilters();
  }

  Widget _buildItemCard(ItemModel item) {
    return ItemCard(
      item: item,
      heroTagPrefix: 'home',
      onTap: () => Get.toNamed(
        AppRoutes.detail,
        arguments: {'item': item, 'heroTag': 'home-image-${item.id}'},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = Theme.of(context).cardTheme.color ?? colorScheme.surface;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: AppTheme.heroGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.24),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Silahkan Dipilih Produknya',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppConfig.appTagline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Text(
                      '${_homeController.items.length} Produk',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.softShadow(context),
            ),
            child: Obx(
              () => TextField(
                controller: _searchController,
                onChanged: _homeController.onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Cari nama produk...',
                  fillColor: cardColor,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colorScheme.primary,
                  ),
                  suffixIcon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: _homeController.searchQuery.value.isNotEmpty
                        ? IconButton(
                            key: const ValueKey('clear-btn'),
                            tooltip: 'Hapus pencarian',
                            onPressed: _handleClearSearch,
                            icon: const Icon(Icons.close_rounded),
                          )
                        : const SizedBox.shrink(key: ValueKey('empty-btn')),
                  ),
                ),
              ),
            ),
          ),
        ),

        Obx(
          () => SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _homeController.categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final option = _homeController.categories[index];
                final isSelected =
                    _homeController.selectedFilter.value == option.value;
                return ChoiceChip(
                  label: Text(option.label),
                  showCheckmark: false,
                  selected: isSelected,
                  onSelected: (_) => _homeController.selectFilter(option.value),
                  selectedColor: colorScheme.primary,
                  backgroundColor: cardColor,
                  labelStyle: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 13,
                    color: isSelected
                        ? Colors.white
                        : colorScheme.onSurface.withValues(alpha: 0.78),
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? colorScheme.primary
                        : AppTheme.adaptiveBorder(context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              },
            ),
          ),
        ),
        Obx(
          () => _homeController.categoryError.value.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Filter kategori: ${_homeController.categoryError.value}',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colorScheme.error),
                    ),
                  ),
                ),
        ),

        const SizedBox(height: 8),

        Expanded(
          child: Obx(() {
            if (_homeController.isLoading.value) {
              return const LoadingStateWidget(message: 'Mengambil data API...');
            }

            if (_homeController.errorMessage.value.isNotEmpty) {
              return ErrorStateWidget(
                message: _homeController.errorMessage.value,
                onRetry: _homeController.fetchItems,
              );
            }

            if (_homeController.items.isEmpty) {
              final hasQueryOrFilter =
                  _homeController.searchQuery.value.isNotEmpty ||
                  _homeController.selectedFilter.value.isNotEmpty;
              return EmptyStateWidget(
                icon: Icons.search_off_rounded,
                title: 'Data tidak ditemukan',
                subtitle: hasQueryOrFilter
                    ? 'Tidak ada hasil yang cocok dengan pencarian atau filter Anda.'
                    : 'Belum ada data tersedia dari server saat ini.',
                actionLabel: hasQueryOrFilter ? 'Reset Filter' : 'Muat Ulang',
                onAction: hasQueryOrFilter
                    ? _handleResetAll
                    : _homeController.fetchItems,
              );
            }

            return RefreshIndicator(
              onRefresh: _homeController.fetchItems,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final useGrid = constraints.maxWidth >= 660;
                  if (useGrid) {
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            mainAxisExtent: 118,
                          ),
                      itemCount: _homeController.items.length,
                      itemBuilder: (context, index) =>
                          _buildItemCard(_homeController.items[index]),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: _homeController.items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _buildItemCard(_homeController.items[index]),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}
