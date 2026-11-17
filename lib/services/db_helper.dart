import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../config/app_config.dart';
import '../models/user_model.dart';

/// Exception khusus untuk operasi autentikasi database lokal.
class AuthDatabaseException implements Exception {
  AuthDatabaseException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Helper database akun user (`users`).
///
/// Menggunakan `sqflite` (SQLite) secara penuh pada Android, iOS, dan macOS.
/// Pada platform Web / Windows / Linux (di mana `sqflite` tidak didukung bawaan),
/// otomatis menggunakan fallback penyimpanan lokal `SharedPreferences` agar
/// pengujian via browser Chrome tetap berjalan mulus.
class DbHelper {
  DbHelper._internal();
  static final DbHelper instance = DbHelper._internal();

  static const String _fallbackUsersKey = 'fallback_users_table';
  static Database? _database;

  bool get _supportsSqflite =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final fullPath = join(dbPath, AppConfig.dbName);

    return openDatabase(
      fullPath,
      version: AppConfig.dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Mengecek apakah email sudah terdaftar.
  Future<UserModel?> getUserByEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (!_supportsSqflite) {
      final users = await _loadFallbackUsers();
      for (final user in users) {
        if (user.email.trim().toLowerCase() == normalizedEmail) {
          return user;
        }
      }
      return null;
    }

    final db = await database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  /// Mendaftarkan user baru dengan pengecekan email duplikat.
  Future<UserModel> registerUser(UserModel user) async {
    final normalizedEmail = user.email.trim().toLowerCase();

    final existing = await getUserByEmail(normalizedEmail);
    if (existing != null) {
      throw AuthDatabaseException(
        'Email "$normalizedEmail" sudah terdaftar. Silakan gunakan email lain atau login.',
      );
    }

    if (!_supportsSqflite) {
      final users = await _loadFallbackUsers();
      final nextId = users.isEmpty
          ? 1
          : users
                  .map((u) => u.id ?? 0)
                  .reduce((a, b) => a > b ? a : b) +
              1;
      final created = UserModel(
        id: nextId,
        name: user.name.trim(),
        email: normalizedEmail,
        password: user.password,
      );
      users.add(created);
      await _saveFallbackUsers(users);
      return UserModel(
        id: created.id,
        name: created.name,
        email: created.email,
      );
    }

    final db = await database;
    try {
      final id = await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return UserModel(
        id: id,
        name: user.name.trim(),
        email: normalizedEmail,
      );
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw AuthDatabaseException(
          'Email "$normalizedEmail" sudah terdaftar.',
        );
      }
      throw AuthDatabaseException('Gagal menyimpan akun ke database lokal.');
    }
  }

  /// Memvalidasi email & password ke tabel `users`.
  Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (!_supportsSqflite) {
      final users = await _loadFallbackUsers();
      for (final user in users) {
        if (user.email.trim().toLowerCase() == normalizedEmail &&
            user.password == password) {
          return UserModel(
            id: user.id,
            name: user.name,
            email: user.email,
          );
        }
      }
      return null;
    }

    final db = await database;
    final rows = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [normalizedEmail, password],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  Future<List<UserModel>> _loadFallbackUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_fallbackUsersKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(UserModel.fromMap)
            .toList();
      }
    } catch (_) {
      return [];
    }
    return [];
  }

  Future<void> _saveFallbackUsers(List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(users.map((u) => u.toMap()).toList());
    await prefs.setString(_fallbackUsersKey, encoded);
  }
}
