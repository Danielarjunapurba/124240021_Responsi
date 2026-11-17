import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Hasil pengambilan lokasi GPS & alamat reverse geocoding.
class LocationResult {
  const LocationResult({
    this.latitude,
    this.longitude,
    this.address = '',
    this.error,
  });

  final double? latitude;
  final double? longitude;
  final String address;
  final String? error;

  bool get hasLocation => latitude != null && longitude != null;
}

/// Service Location Based Service (LBS) menggunakan `geolocator` & `geocoding`.
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  bool get _supportsGeocoding =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  Future<LocationResult> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult(
          error: 'Layanan lokasi (GPS) belum aktif pada perangkat.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const LocationResult(
            error: 'Izin akses lokasi ditolak oleh pengguna.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult(
          error:
              'Izin lokasi ditolak permanen. Aktifkan izin lokasi di Pengaturan aplikasi.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );

      final address = await _resolveAddress(
        position.latitude,
        position.longitude,
      );

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );
    } on TimeoutException {
      return const LocationResult(
        error: 'Waktu pengambilan lokasi habis. Pastikan sinyal GPS tersedia.',
      );
    } catch (e) {
      return LocationResult(
        error: 'Tidak dapat mengambil lokasi saat ini ($e).',
      );
    }
  }

  Future<String> _resolveAddress(double lat, double lng) async {
    if (!_supportsGeocoding) {
      return 'Koordinat GPS berhasil diperoleh';
    }
    try {
      final geocoding = Geocoding();
      final placemarks = await geocoding.placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return 'Alamat tidak terdeteksi';

      final place = placemarks.first;
      final parts = [
        place.subLocality,
        place.locality,
        place.subAdministrativeArea,
        place.administrativeArea,
        place.country,
      ].where((p) => p != null && p.trim().isNotEmpty).cast<String>().toList();

      if (parts.isEmpty) return 'Alamat tidak terdeteksi';
      return parts.toSet().join(', ');
    } catch (_) {
      return 'Alamat tidak tersedia (offline / layanan geocoding tidak aktif)';
    }
  }
}
