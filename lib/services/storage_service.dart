import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/item_model.dart';
import '../models/user_model.dart';

/// Service penyimpanan lokal persisten berbasis SharedPreferences
/// untuk session login dan daftar item favorit (JSON String).
class StorageService extends GetxService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyCurrentUser = 'current_user';
  static const String _keyFavorites = 'favorites_items';

  late final SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // =========================================================================
  // SESSION LOGIN
  // =========================================================================

  bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;

  UserModel? get currentUser {
    final raw = _prefs.getString(_keyCurrentUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return UserModel.fromJson(decoded);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> saveSession(UserModel user) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyCurrentUser, jsonEncode(user.toSessionJson()));
  }

  Future<void> clearSession() async {
    await _prefs.setBool(_keyIsLoggedIn, false);
    await _prefs.remove(_keyCurrentUser);
  }

  // =========================================================================
  // FAVORITES (JSON STRING PERSISTENT)
  // =========================================================================

  List<ItemModel> loadFavorites() {
    final raw = _prefs.getString(_keyFavorites);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(ItemModel.fromJson)
            .toList();
      }
    } catch (_) {
      return [];
    }
    return [];
  }

  Future<void> saveFavorites(List<ItemModel> items) async {
    final jsonString = jsonEncode(items.map((item) => item.toJson()).toList());
    await _prefs.setString(_keyFavorites, jsonString);
  }
}
