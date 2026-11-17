import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../config/app_config.dart';

/// Service notifikasi lokal lintas platform menggunakan `flutter_local_notifications`.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  int _nextNotificationId = 100;

  Future<void> init() async {
    if (_initialized || !AppConfig.enableNotifications) return;

    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const linuxSettings = LinuxInitializationSettings(
        defaultActionName: 'Buka Aplikasi',
      );
      const windowsSettings = WindowsInitializationSettings(
        appName: AppConfig.appName,
        appUserModelId: 'com.example.responsi.app',
        guid: 'd49b0314-ee7a-4626-bf79-97cdb8a991bb',
      );

      const settings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: linuxSettings,
        windows: windowsSettings,
      );

      await _plugin.initialize(settings: settings);

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final androidImpl = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        await androidImpl?.requestNotificationsPermission();
      }

      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
  }

  /// Menampilkan notifikasi lokal sederhana jika fitur diaktifkan pada [AppConfig].
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!AppConfig.enableNotifications) return;
    if (!_initialized) {
      await init();
    }
    if (!_initialized) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        'responsi_general_channel',
        'Notifikasi Umum',
        channelDescription: 'Notifikasi aktivitas pengguna pada aplikasi',
        importance: Importance.high,
        priority: Priority.high,
      );
      const darwinDetails = DarwinNotificationDetails();
      const windowsDetails = WindowsNotificationDetails();

      const details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
        windows: windowsDetails,
      );

      await _plugin.show(
        id: _nextNotificationId++,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
    } catch (_) {
      // Abaikan secara aman jika platform/emulator belum mendukung notifikasi.
    }
  }
}
