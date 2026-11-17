import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../models/item_model.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../widgets/app_snackbar.dart';

class FavoriteController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final RxList<ItemModel> favorites = <ItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    favorites.assignAll(_storage.loadFavorites());
  }

  bool isFavorite(String id) {
    return favorites.any((item) => item.id == id);
  }

  Future<void> toggleFavorite(ItemModel item) async {
    if (isFavorite(item.id)) {
      favorites.removeWhere((element) => element.id == item.id);
      await _storage.saveFavorites(favorites);
      AppSnackbar.show(
        title: 'Dihapus dari Favorit',
        message: '"${item.name}" telah dihapus dari daftar favorit.',
        isError: true,
        icon: Icons.heart_broken_rounded,
      );
    } else {
      favorites.insert(0, item);
      await _storage.saveFavorites(favorites);
      AppSnackbar.show(
        title: 'Ditambahkan ke Favorit',
        message: '"${item.name}" disimpan ke daftar favorit.',
        backgroundColor: AppTheme.successColor,
        icon: Icons.favorite_rounded,
      );

      if (AppConfig.enableNotifications) {
        await NotificationService.instance.showNotification(
          title: 'Favorit Baru Disimpan',
          body: '"${item.name}" ditambahkan ke daftar favorit Anda.',
        );
      }
    }
  }

  Future<void> removeFavorite(ItemModel item) async {
    favorites.removeWhere((element) => element.id == item.id);
    await _storage.saveFavorites(favorites);
    AppSnackbar.show(
      title: 'Item Dihapus',
      message: '"${item.name}" dihapus dari daftar favorit.',
      isError: true,
      icon: Icons.delete_outline_rounded,
    );
  }
}
