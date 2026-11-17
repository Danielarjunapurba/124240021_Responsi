import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/app_config.dart';
import '../../config/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/extra_controller.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_state_widget.dart';

class ExtraScreen extends StatelessWidget {
  const ExtraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final extraCtrl = Get.find<ExtraController>();
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = Theme.of(context).cardTheme.color ?? colorScheme.surface;

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          if (AppConfig.enableExtraPage) extraCtrl.fetchExtraItems(),
          if (AppConfig.enableLbs) extraCtrl.fetchCurrentLocation(),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          Obx(() {
            final user = authCtrl.currentUser.value;
            final initial = (user?.name.isNotEmpty ?? false)
                ? user!.name[0].toUpperCase()
                : 'U';
            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppTheme.heroGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Pengguna',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          user?.email ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Aktif',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          if (AppConfig.enableLbs || AppConfig.enableNotifications) ...[
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.adaptiveBorder(context)),
                boxShadow: AppTheme.softShadow(context),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (AppConfig.enableLbs) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Lokasi Saat Ini (LBS)',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Obx(
                          () => TextButton.icon(
                            onPressed: extraCtrl.isLocationLoading.value
                                ? null
                                : extraCtrl.fetchCurrentLocation,
                            icon: const Icon(
                              Icons.my_location_rounded,
                              size: 16,
                            ),
                            label: const Text('Perbarui'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      if (extraCtrl.isLocationLoading.value) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text('Mengambil koordinat GPS...'),
                            ],
                          ),
                        );
                      }

                      final loc = extraCtrl.locationResult.value;
                      if (loc == null) {
                        return const Text('Lokasi belum dimuat.');
                      }

                      if (loc.error != null) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.error.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            loc.error!,
                            style: TextStyle(
                              color: colorScheme.error,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.adaptiveMutedSurface(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.address,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _CoordinatePill(
                                  label:
                                      'Lat: ${loc.latitude?.toStringAsFixed(5)}',
                                ),
                                _CoordinatePill(
                                  label:
                                      'Lng: ${loc.longitude?.toStringAsFixed(5)}',
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  if (AppConfig.enableLbs && AppConfig.enableNotifications)
                    const Divider(height: 24),
                  if (AppConfig.enableNotifications)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: extraCtrl.triggerTestNotification,
                        icon: const Icon(Icons.notifications_active_outlined),
                        label: const Text('Kirim Notifikasi Lokal'),
                      ),
                    ),
                ],
              ),
            ),
          ],

          if (AppConfig.enableExtraPage) ...[
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppConfig.extraSectionTitle,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    AppConfig.extraEndpoint,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (extraCtrl.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: LoadingStateWidget(message: 'Memuat data tambahan...'),
                );
              }

              if (extraCtrl.errorMessage.value.isNotEmpty) {
                return ErrorStateWidget(
                  message: extraCtrl.errorMessage.value,
                  onRetry: extraCtrl.fetchExtraItems,
                );
              }

              if (extraCtrl.extraItems.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.layers_clear_outlined,
                  title: 'Data tidak ditemukan',
                  subtitle: 'Belum ada data pada endpoint tambahan.',
                  actionLabel: 'Muat Ulang',
                  onAction: extraCtrl.fetchExtraItems,
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: extraCtrl.extraItems.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final category = extraCtrl.extraItems[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.adaptiveBorder(context),
                      ),
                      boxShadow: AppTheme.softShadow(context),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: AppTheme.brandGradient,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                category.id,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.62,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.adaptiveMutedSurface(context),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.category_outlined,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _CoordinatePill extends StatelessWidget {
  const _CoordinatePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:
            Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.adaptiveBorder(context)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
      ),
    );
  }
}
