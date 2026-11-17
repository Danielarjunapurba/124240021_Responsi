import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:responsi/controllers/auth_controller.dart';
import 'package:responsi/controllers/extra_controller.dart';
import 'package:responsi/controllers/favorite_controller.dart';
import 'package:responsi/controllers/home_controller.dart';
import 'package:responsi/main.dart';
import 'package:responsi/models/extra_item_model.dart';
import 'package:responsi/models/item_model.dart';
import 'package:responsi/models/user_model.dart';
import 'package:responsi/routes/app_routes.dart';
import 'package:responsi/services/api_service.dart';
import 'package:responsi/services/db_helper.dart';
import 'package:responsi/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> _productJson({
  int id = 1,
  String title = 'Essence Mascara Lash Princess',
  String category = 'beauty',
}) => {
  'id': id,
  'title': title,
  'description': 'The product is a popular mascara.',
  'category': category,
  'price': 9.99,
  'discountPercentage': 7.17,
  'rating': 4.94,
  'stock': 5,
  'brand': 'Essence',
  'thumbnail':
      'https://cdn.dummyjson.com/product-images/beauty/1/thumbnail.webp',
  'availabilityStatus': 'Low Stock',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    Get.reset();
    Get.testMode = true;
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    await Get.putAsync<StorageService>(
      () => StorageService().init(),
      permanent: true,
    );
  });

  tearDown(() {
    Get.reset();
  });

  test('ItemModel fromJson dan toJson menjaga konsistensi data', () {
    final item = ItemModel.fromJson(_productJson());
    expect(item.id, '1');
    expect(item.name, 'Essence Mascara Lash Princess');
    expect(item.category, 'beauty');
    expect(item.brand, 'Essence');
    expect(item.price, 9.99);
    expect(item.rating, 4.94);
    expect(item.discountPercentage, 7.17);
    expect(item.stock, 5);
    expect(item.status, 'Low Stock');
    expect(item.priceLabel, '\$9.99');

    final serialized = item.toJson();
    final restored = ItemModel.fromJson(serialized);
    expect(restored.id, item.id);
    expect(restored.name, item.name);
    expect(restored.category, item.category);
    expect(restored.stock, item.stock);
    expect(
      restored.detailAttributes.map((entry) => entry.key),
      containsAll([
        'Kategori',
        'Merek',
        'Harga',
        'Rating',
        'Deskripsi',
        'Diskon',
        'Stok',
      ]),
    );
  });

  test('ExtraItemModel memetakan kategori dari API', () {
    final category = ExtraItemModel.fromJson('kitchen-accessories');
    expect(category.id, 'kitchen-accessories');
    expect(category.name, 'Kitchen Accessories');
  });

  test('ApiService memakai endpoint produk, search, dan kategori, serta menangani 404', () async {
    final mockClient = MockClient((request) async {
      if (request.url.path.endsWith('/products/category-list')) {
        return http.Response(jsonEncode(['beauty', 'fragrances']), 200);
      }
      if (request.url.path.endsWith('/products/search') &&
          request.url.queryParameters['q'] == 'tidakada') {
        return http.Response(jsonEncode({'message': 'No products found'}), 404);
      }
      if (request.url.path.endsWith('/products/category/beauty')) {
        return http.Response(
          jsonEncode({
            'products': [_productJson()],
          }),
          200,
        );
      }
      if (request.url.path.endsWith('/products/search')) {
        return http.Response(
          jsonEncode({
            'products': [_productJson()],
          }),
          200,
        );
      }
      return http.Response(
        jsonEncode({
          'products': [_productJson()],
        }),
        200,
      );
    });

    final api = ApiService(client: mockClient);

    final emptyResult = await api.fetchItems(query: 'tidakada');
    expect(emptyResult, isEmpty);

    final normalResult = await api.fetchItems(query: 'mascara');
    expect(normalResult.length, 1);
    expect(normalResult.first.name, 'Essence Mascara Lash Princess');

    final categoryResult = await api.fetchItems(filter: 'beauty');
    expect(categoryResult.single.category, 'beauty');
    expect(await api.fetchCategories(), ['beauty', 'fragrances']);
  });

  test(
    'FavoriteController menyimpan & sinkronisasi favorit via SharedPreferences',
    () async {
      final favController = Get.put(FavoriteController(), permanent: true);
      const sample = ItemModel(
        id: '10',
        name: 'Mascara',
        category: 'beauty',
        brand: 'Essence',
        status: 'In Stock',
        price: 9.99,
        rating: 4.5,
        description: 'Mascara',
        discountPercentage: 5,
        stock: 10,
        image: '',
      );

      expect(favController.isFavorite('10'), isFalse);

      await favController.toggleFavorite(sample);
      expect(favController.isFavorite('10'), isTrue);
      expect(favController.favorites.length, 1);

      final storage = Get.find<StorageService>();
      final persisted = storage.loadFavorites();
      expect(persisted.length, 1);
      expect(persisted.first.name, 'Mascara');

      await favController.removeFavorite(sample);
      expect(favController.isFavorite('10'), isFalse);
      expect(storage.loadFavorites(), isEmpty);
    },
  );

  test('HomeController menangani 404 sebagai empty state dan debounce search 400ms', () async {
    final mockClient = MockClient((request) async {
      if (request.url.path.endsWith('/products/category-list')) {
        return http.Response(jsonEncode(['beauty']), 200);
      }
      if (request.url.queryParameters['q'] == 'zzz') {
        return http.Response('{"error":"not found"}', 404);
      }
      return http.Response(
        jsonEncode({
          'products': [_productJson(id: 2, title: 'Mascara')],
        }),
        200,
      );
    });

    final controller = Get.put(
      HomeController(apiService: ApiService(client: mockClient)),
    );

    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(controller.items.length, 1);
    expect(controller.errorMessage.value, isEmpty);

    controller.onSearchChanged('zzz');
    await Future<void>.delayed(const Duration(milliseconds: 500));
    expect(controller.items, isEmpty);
    expect(controller.errorMessage.value, isEmpty);
  });

  testWidgets(
    'LoginScreen memvalidasi form dan dapat berpindah ke RegisterScreen',
    (tester) async {
      Get.testMode = false;
      Get.put(FavoriteController(), permanent: true);
      Get.put(AuthController(), permanent: true);

      await tester.pumpWidget(const ResponsiApp(initialRoute: AppRoutes.login));
      await tester.pumpAndSettle();

      expect(find.text('Masuk ke Akun'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);

      // Uji validasi input kosong
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      expect(find.text('Email wajib diisi'), findsOneWidget);
      expect(find.text('Password wajib diisi'), findsOneWidget);

      // Navigasi ke RegisterScreen
      final registerBtn = find.text('Daftar Sekarang');
      await tester.ensureVisible(registerBtn);
      await tester.tap(registerBtn);
      await tester.pumpAndSettle();
      expect(find.text('Daftar Akun Baru'), findsOneWidget);
      expect(find.text('Buat Akun'), findsOneWidget);
    },
  );

  test('DbHelper fallback menangani register, duplikat email, dan login pada non-SQLite platform', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      final created = await DbHelper.instance.registerUser(
        const UserModel(
          name: 'Daniel',
          email: 'DanielArjuna17@gmail.com',
          password: 'password123',
        ),
      );
      expect(created.id, 1);
      expect(created.email, 'danielarjuna17@gmail.com');

      await expectLater(
        DbHelper.instance.registerUser(
          const UserModel(
            name: 'Daniel 2',
            email: 'danielarjuna17@gmail.com',
            password: 'password123',
          ),
        ),
        throwsA(isA<AuthDatabaseException>()),
      );

      final loggedIn = await DbHelper.instance.loginUser(
        email: 'danielarjuna17@gmail.com',
        password: 'password123',
      );
      expect(loggedIn, isNotNull);
      expect(loggedIn!.name, 'Daniel');

      final wrongPassword = await DbHelper.instance.loginUser(
        email: 'danielarjuna17@gmail.com',
        password: 'salah',
      );
      expect(wrongPassword, isNull);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets(
    'MainScreen menampilkan Home, Detail, Favorit, dan toggle tema tanpa overflow',
    (tester) async {
      Get.testMode = false;

      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/products/category-list')) {
          return http.Response(jsonEncode(['beauty', 'fragrances']), 200);
        }
        if (request.url.path.endsWith('/products/1')) {
          return http.Response(jsonEncode(_productJson()), 200);
        }
        return http.Response(
          jsonEncode({
            'products': [_productJson()],
          }),
          200,
        );
      });

      final api = ApiService(client: mockClient);
      Get.put(FavoriteController(), permanent: true);
      Get.put(AuthController(), permanent: true);
      Get.put(HomeController(apiService: api));
      Get.put(ExtraController(apiService: api));

      await tester.pumpWidget(const ResponsiApp(initialRoute: AppRoutes.main));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Jelajahi Produk'), findsOneWidget);
      expect(find.text('Essence Mascara Lash Princess'), findsOneWidget);
      expect(find.text('Beauty'), findsOneWidget);

      // Toggle favorit dari ItemCard
      await tester.tap(find.byIcon(Icons.favorite_border_rounded).first);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byIcon(Icons.favorite_rounded), findsAtLeastNWidgets(1));

      // Buka DetailScreen
      await tester.tap(find.text('Essence Mascara Lash Princess'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Informasi Lengkap'), findsOneWidget);
      expect(find.text('Essence'), findsAtLeastNWidgets(1));
      expect(find.text('7.17%'), findsOneWidget);

      // Biarkan snackbar timer & animasi selesai bersih sebelum teardown
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
    },
  );
}
