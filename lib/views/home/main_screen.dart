import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/app_config.dart';
import '../../config/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/extra_controller.dart';
import '../../controllers/favorite_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/navigation_controller.dart';
import 'extra_screen.dart';
import 'favorite_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final NavigationController _navController;
  late final AuthController _authController;
  late final FavoriteController _favoriteController;

  bool get _showThirdTab =>
      AppConfig.enableExtraPage ||
      AppConfig.enableLbs ||
      AppConfig.enableNotifications;

  @override
  void initState() {
    super.initState();
    _navController = Get.isRegistered<NavigationController>()
        ? Get.find<NavigationController>()
        : Get.put(NavigationController());
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController());
    }
    if (_showThirdTab && !Get.isRegistered<ExtraController>()) {
      Get.put(ExtraController());
    }
    _authController = Get.find<AuthController>();
    _favoriteController = Get.find<FavoriteController>();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final pages = <Widget>[
      const HomeScreen(),
      const FavoriteScreen(),
      if (_showThirdTab) const ExtraScreen(),
    ];

    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: 'Beranda',
      ),
      NavigationDestination(
        icon: Obx(() {
          final count = _favoriteController.favorites.length;
          return Badge(
            isLabelVisible: count > 0,
            label: Text('$count'),
            child: const Icon(Icons.favorite_outline_rounded),
          );
        }),
        selectedIcon: Obx(() {
          final count = _favoriteController.favorites.length;
          return Badge(
            isLabelVisible: count > 0,
            label: Text('$count'),
            child: const Icon(Icons.favorite_rounded),
          );
        }),
        label: 'Wishlist',
      ),
      if (_showThirdTab)
        const NavigationDestination(
          icon: Icon(Icons.shopping_bag),
          selectedIcon: Icon(Icons.shopping_bag),
          label: AppConfig.extraTabLabel,
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Obx(() {
          final user = _authController.currentUser.value;
          return Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: AppTheme.brandGradient,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.shopping_bag,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppConfig.appName,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (user != null)
                      Text(
                        'Halo Boskyuh, ${user.name}',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.62),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        }),
        actions: [
          Obx(
            () => IconButton(
              tooltip: _navController.isDarkMode.value
                  ? 'Mode Terang'
                  : 'Mode Gelap',
              onPressed: _navController.toggleThemeMode,
              icon: Icon(
                _navController.isDarkMode.value
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: 'Logout',
              onPressed: _authController.showLogoutDialog,
              icon: const Icon(Icons.logout_rounded),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: AppTheme.adaptiveBorder(context),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Obx(
            () => IndexedStack(
              index: _navController.currentIndex.value.clamp(
                0,
                pages.length - 1,
              ),
              children: pages,
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.adaptiveBorder(context)),
          ),
        ),
        child: Obx(
          () => NavigationBar(
            selectedIndex: _navController.currentIndex.value.clamp(
              0,
              destinations.length - 1,
            ),
            onDestinationSelected: (index) =>
                _navController.changeTab(index, maxIndex: pages.length - 1),
            destinations: destinations,
          ),
        ),
      ),
    );
  }
}
