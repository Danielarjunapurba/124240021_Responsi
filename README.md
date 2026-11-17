# ShoppingHub - Responsi Flutter + GetX

Template aplikasi mobile Flutter modular menggunakan **GetX** (`State Management`, `Routing`, `Dependency Injection`), **SQLite (`sqflite`)**, **SharedPreferences**, **REST API (`http`)**, **Google Fonts**, **LBS (`geolocator` & `geocoding`)**, dan **Notifikasi Lokal (`flutter_local_notifications`)**.

ShoppingHub memakai API publik **DummyJSON Products** (`https://dummyjson.com/products`) untuk katalog, pencarian, detail produk, dan filter kategori. Login/Register tetap memakai SQLite (dengan fallback web), sedangkan wishlist tersinkronisasi dan tersimpan melalui SharedPreferences.

## Panduan Cepat Menyesuaikan Tema Saat Soal Responsi Keluar

Fitur utama:
- Login/Register lokal dengan proteksi rute GetX.
- Daftar produk, pencarian, dan kategori dari API.
- Detail produk berdasarkan ID API.
- Wishlist persisten melalui SharedPreferences.
- Penanganan respons kosong dan HTTP 404 sebagai Empty State.

Halaman tambahan, LBS, dan notifikasi dinonaktifkan karena tidak diminta dalam soal.
