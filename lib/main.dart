import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'controllers/auth_controller.dart';
import 'controllers/favorite_controller.dart';
import 'routes/app_routes.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/home/detail_screen.dart';
import 'views/home/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi SharedPreferences sebelum aplikasi dirender (untuk proteksi rute)
  final storageService = await Get.putAsync<StorageService>(
    () => StorageService().init(),
    permanent: true,
  );

  // Inisialisasi notifikasi lokal jika fitur diaktifkan
  if (AppConfig.enableNotifications) {
    await NotificationService.instance.init();
  }

  // Registrasi controller global permanen agar state favorit & auth sinkron di seluruh app
  Get.put(FavoriteController(), permanent: true);
  Get.put(AuthController(), permanent: true);

  final initialRoute = storageService.isLoggedIn
      ? AppRoutes.main
      : AppRoutes.login;

  runApp(ResponsiApp(initialRoute: initialRoute));
}

class ResponsiApp extends StatelessWidget {
  const ResponsiApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: AppTheme.useDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: initialRoute,
      defaultTransition: Transition.cupertino,
      getPages: [
        GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
        GetPage(name: AppRoutes.register, page: () => const RegisterScreen()),
        GetPage(name: AppRoutes.main, page: () => const MainScreen()),
        GetPage(name: AppRoutes.detail, page: () => const DetailScreen()),
      ],
    );
  }
}
