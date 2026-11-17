import 'package:get/get.dart';

import '../config/app_config.dart';
import '../models/item_model.dart';
import '../services/api_service.dart';

class HomeController extends GetxController {
  HomeController({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  final RxList<ItemModel> items = <ItemModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString categoryError = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = ''.obs;
  final RxList<FilterOption> categories = AppConfig.filterOptions.toList().obs;

  final Rxn<ItemModel> detailItem = Rxn<ItemModel>();
  final RxBool isDetailLoading = false.obs;
  final RxString detailError = ''.obs;

  Worker? _searchDebounceWorker;

  @override
  void onInit() {
    super.onInit();
    _searchDebounceWorker = debounce<String>(
      searchQuery,
      (_) => fetchItems(),
      time: const Duration(milliseconds: 400),
    );
    fetchCategories();
    fetchItems();
  }

  Future<void> fetchCategories() async {
    categoryError.value = '';
    try {
      final fetched = await _apiService.fetchCategories();
      categories.assignAll([
        AppConfig.filterOptions.first,
        ...fetched.map(
          (category) =>
              FilterOption(label: _categoryLabel(category), value: category),
        ),
      ]);
    } on ApiException catch (e) {
      categoryError.value = e.message;
    } catch (_) {
      categoryError.value = 'Gagal memuat kategori produk.';
    }
  }

  String _categoryLabel(String category) {
    return category
        .split('-')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }

  @override
  void onClose() {
    _searchDebounceWorker?.dispose();
    super.onClose();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  void clearSearch() {
    if (searchQuery.value.isEmpty) return;
    searchQuery.value = '';
  }

  void selectFilter(String filterValue) {
    if (selectedFilter.value == filterValue) return;
    selectedFilter.value = filterValue;
    fetchItems();
  }

  void resetFilters() {
    searchQuery.value = '';
    selectedFilter.value = '';
    fetchItems();
  }

  Future<void> fetchItems() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final fetched = await _apiService.fetchItems(
        query: searchQuery.value,
        filter: selectedFilter.value,
      );
      items.assignAll(fetched);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      items.clear();
    } catch (_) {
      errorMessage.value = 'Terjadi kesalahan saat mengambil data.';
      items.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadItemDetail(String id, {ItemModel? initialItem}) async {
    detailItem.value = initialItem;
    detailError.value = '';
    isDetailLoading.value = true;

    try {
      final fetched = await _apiService.fetchItemDetail(id);
      detailItem.value = fetched;
    } on ApiException catch (e) {
      if (detailItem.value == null) {
        detailError.value = e.message;
      }
    } catch (_) {
      if (detailItem.value == null) {
        detailError.value = 'Gagal memuat detail item.';
      }
    } finally {
      isDetailLoading.value = false;
    }
  }
}
