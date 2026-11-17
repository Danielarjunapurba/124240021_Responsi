class FilterOption {
  const FilterOption({required this.label, required this.value});

  final String label;
  final String value;
}

class AppConfig {
  AppConfig._();

  static const String appName = 'ShoppingHub';
  static const String appTagline = 'Temukan produk favorit Anda';
  static const String appVersion = '1.0.0';

  static const String baseUrl = 'https://dummyjson.com';

  static const String listEndpoint = '/products';

  static String detailEndpoint(String id) => '/products/$id';

  static const String extraEndpoint = '/products/category-list';

  static const String searchParamKey = 'q';
  static const String filterParamKey = 'category';

  static const List<FilterOption> filterOptions = [
    FilterOption(label: 'Semua Produk', value: ''),
  ];

  static const bool enableExtraPage = false;

  static const bool enableLbs = false;

  static const bool enableNotifications = false;

  static const String extraTabLabel = 'Kategori';
  static const String extraSectionTitle = 'Kategori Produk';

  static const String dbName = 'responsi_app.db';
  static const int dbVersion = 1;
}
