import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/extra_item_model.dart';
import '../models/item_model.dart';

/// Exception terstruktur untuk kegagalan pemanggilan REST API.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Service REST API terpusat menggunakan package `http`.
class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 15);

  /// Mengambil list item utama dengan dukungan search & filter.
  ///
  /// Respons HTTP 404 saat pencarian/filter dikembalikan sebagai list kosong `[]`
  /// agar UI menampilkan Empty State dengan mulus tanpa crash.
  Future<List<ItemModel>> fetchItems({
    String query = '',
    String filter = '',
    int page = 1,
  }) async {
    final normalizedQuery = query.trim();
    final normalizedFilter = filter.trim();
    final endpoint = normalizedQuery.isNotEmpty
        ? '/products/search'
        : normalizedFilter.isNotEmpty
        ? '${AppConfig.listEndpoint}/${AppConfig.filterParamKey}/${Uri.encodeComponent(normalizedFilter)}'
        : AppConfig.listEndpoint;
    final params = <String, String>{
      if (normalizedQuery.isNotEmpty) AppConfig.searchParamKey: normalizedQuery,
      if (page > 1) 'skip': '${(page - 1) * 30}',
    };

    final uri = Uri.parse('${AppConfig.baseUrl}$endpoint')
        .replace(queryParameters: params.isEmpty ? null : params);

    final decoded = await _getJson(uri, allow404AsEmpty: true);
    if (decoded == null) return [];

    final rawList = _extractList(decoded);
    final items = rawList
        .whereType<Map<String, dynamic>>()
        .map(ItemModel.fromJson)
        .toList();
    if (normalizedQuery.isNotEmpty && normalizedFilter.isNotEmpty) {
      return items.where((item) => item.category == normalizedFilter).toList();
    }
    return items;
  }

  /// Retrieves category slugs from DummyJSON's `/products/category-list`.
  Future<List<String>> fetchCategories() async {
    final uri = Uri.parse('${AppConfig.baseUrl}${AppConfig.extraEndpoint}');
    final decoded = await _getJson(uri, allow404AsEmpty: true);
    if (decoded == null) return [];

    return _extractList(decoded)
        .map((value) {
          if (value is String) return value;
          if (value is Map<String, dynamic>) {
            return (value['slug'] ?? value['name'] ?? '').toString();
          }
          return '';
        })
        .where((category) => category.isNotEmpty)
        .toList();
  }

  /// Mengambil detail item berdasarkan [id].
  Future<ItemModel> fetchItemDetail(String id) async {
    final uri = Uri.parse(
      '${AppConfig.baseUrl}${AppConfig.detailEndpoint(id)}',
    );
    final decoded = await _getJson(uri);

    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'] is Map<String, dynamic>
          ? decoded['data'] as Map<String, dynamic>
          : decoded;
      return ItemModel.fromJson(data);
    }

    throw ApiException('Format respons detail tidak valid.');
  }

  /// Loads category entries from the configured category-list endpoint.
  Future<List<ExtraItemModel>> fetchExtraItems() async {
    final uri = Uri.parse('${AppConfig.baseUrl}${AppConfig.extraEndpoint}');
    final decoded = await _getJson(uri, allow404AsEmpty: true);
    if (decoded == null) return [];

    final rawList = _extractList(decoded);
    return rawList
        .map(ExtraItemModel.fromJson)
        .where((item) => item.id.isNotEmpty)
        .toList();
  }

  Future<dynamic> _getJson(Uri uri, {bool allow404AsEmpty = false}) async {
    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        if (response.body.trim().isEmpty) return null;
        return jsonDecode(response.body);
      }

      if (response.statusCode == 404 && allow404AsEmpty) {
        return null;
      }

      if (response.statusCode == 404) {
        throw ApiException(
          'Data tidak ditemukan (404).',
          statusCode: response.statusCode,
        );
      }

      throw ApiException(
        'Terjadi kesalahan server (HTTP ${response.statusCode}).',
        statusCode: response.statusCode,
      );
    } on http.ClientException {
      throw ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on TimeoutException {
      throw ApiException(
        'Koneksi ke server melebihi batas waktu. Silakan coba lagi.',
      );
    } on FormatException {
      throw ApiException('Format data dari server tidak dapat dibaca.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Gagal memuat data dari server.');
    }
  }

  /// Extracts lists from DummyJSON product/category payloads or top-level arrays.
  List<dynamic> _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      for (final key in [
        'products',
        'results',
        'data',
        'items',
        'categories',
      ]) {
        final candidate = decoded[key];
        if (candidate is List) return candidate;
      }
    }
    return [];
  }
}
