import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_theme.dart';

class AppSnackbar {
  AppSnackbar._();

  static void show({
    required String title,
    required String message,
    bool isError = false,
    Color? backgroundColor,
    IconData? icon,
  }) {
    if (Get.overlayContext == null) return;

    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      borderRadius: 16,
      duration: const Duration(seconds: 2),
      backgroundColor:
          backgroundColor ??
          (isError ? AppTheme.dangerColor : const Color(0xFF0F172A)),
      colorText: Colors.white,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.18),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
      icon: Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Icon(
          icon ??
              (isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded),
          color: Colors.white,
        ),
      ),
    );
  }
}
