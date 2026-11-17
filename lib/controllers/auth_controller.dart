import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';
import '../services/db_helper.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../widgets/app_snackbar.dart';
import 'navigation_controller.dart';

class AuthController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final DbHelper _db = DbHelper.instance;

  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _storage.currentUser;
  }

  void togglePasswordVisibility() => obscurePassword.toggle();

  void toggleConfirmPasswordVisibility() => obscureConfirmPassword.toggle();

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      await _db.registerUser(
        UserModel(name: name, email: email, password: password),
      );
      AppSnackbar.show(
        title: 'Registrasi Berhasil',
        message: 'Akun berhasil dibuat. Silakan login dengan email Anda.',
      );
      Get.offNamed(AppRoutes.login);
    } on AuthDatabaseException catch (e) {
      AppSnackbar.show(
        title: 'Registrasi Gagal',
        message: e.message,
        isError: true,
      );
    } catch (e) {
      debugPrint('Register error: $e');
      AppSnackbar.show(
        title: 'Registrasi Gagal',
        message: 'Terjadi kesalahan saat mendaftarkan akun: $e',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login({required String email, required String password}) async {
    isLoading.value = true;
    try {
      final user = await _db.loginUser(email: email, password: password);
      if (user == null) {
        AppSnackbar.show(
          title: 'Login Gagal',
          message: 'Email atau password tidak sesuai.',
          isError: true,
        );
        return;
      }

      await _storage.saveSession(user);
      currentUser.value = user;

      if (AppConfig.enableNotifications) {
        await NotificationService.instance.showNotification(
          title: 'Selamat Datang, ${user.name}!',
          body: 'Anda berhasil masuk ke ${AppConfig.appName}.',
        );
      }

      AppSnackbar.show(
        title: 'Login Berhasil',
        message: 'Selamat datang kembali, ${user.name}!',
      );

      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      debugPrint('Login error: $e');
      AppSnackbar.show(
        title: 'Login Gagal',
        message: 'Terjadi kesalahan saat memverifikasi akun: $e',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Menampilkan dialog konfirmasi sebelum logout dan menghapus session lokal.
  void showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Logout'),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari sesi akun saat ini?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Get.back();
              await logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> logout() async {
    await _storage.clearSession();
    currentUser.value = null;
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().currentIndex.value = 0;
    }
    Get.offAllNamed(AppRoutes.login);
    AppSnackbar.show(
      title: 'Berhasil Keluar',
      message: 'Sesi Anda telah berakhir.',
      icon: Icons.logout_rounded,
    );
  }
}
