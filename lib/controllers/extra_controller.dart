import 'package:get/get.dart';

import '../config/app_config.dart';
import '../models/extra_item_model.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../widgets/app_snackbar.dart';

class ExtraController extends GetxController {
  ExtraController({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  final RxList<ExtraItemModel> extraItems = <ExtraItemModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final Rxn<LocationResult> locationResult = Rxn<LocationResult>();
  final RxBool isLocationLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (AppConfig.enableExtraPage) {
      fetchExtraItems();
    }
    if (AppConfig.enableLbs) {
      fetchCurrentLocation();
    }
  }

  Future<void> fetchExtraItems() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final fetched = await _apiService.fetchExtraItems();
      extraItems.assignAll(fetched);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      extraItems.clear();
    } catch (_) {
      errorMessage.value = 'Gagal memuat data tambahan.';
      extraItems.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCurrentLocation() async {
    if (!AppConfig.enableLbs) return;
    isLocationLoading.value = true;
    try {
      final result = await LocationService.instance.getCurrentLocation();
      locationResult.value = result;
    } finally {
      isLocationLoading.value = false;
    }
  }

  Future<void> triggerTestNotification() async {
    if (!AppConfig.enableNotifications) return;
    await NotificationService.instance.showNotification(
      title: AppConfig.appName,
      body: 'Notifikasi lokal berhasil dijalankan dari template responsi.',
    );
    AppSnackbar.show(
      title: 'Notifikasi Dikirim',
      message: 'Silakan periksa panel notifikasi perangkat Anda.',
    );
  }
}
