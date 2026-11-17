import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_theme.dart';

class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final RxBool isDarkMode = AppTheme.useDarkMode.obs;

  void changeTab(int index, {int maxIndex = 2}) {
    if (index < 0 || index > maxIndex) return;
    currentIndex.value = index;
  }

  void toggleThemeMode() {
    isDarkMode.toggle();
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}
