// ------------------------------------------------------
// FAVORITE MANAGER - FlipRate
// Mengelola penyimpanan favorit menggunakan SharedPreferences
// ------------------------------------------------------

import 'package:shared_preferences/shared_preferences.dart';

class FavoriteManager {
  static const String _key = 'favorite_currencies';

  // Tambah currency ke favorit
  static Future<bool> addFavorite(String currencyCode) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    if (!favorites.contains(currencyCode)) {
      favorites.add(currencyCode);
      return await prefs.setStringList(_key, favorites);
    }
    return false; // Sudah ada di favorit
  }

  // Hapus currency dari favorit
  static Future<bool> removeFavorite(String currencyCode) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    if (favorites.contains(currencyCode)) {
      favorites.remove(currencyCode);
      return await prefs.setStringList(_key, favorites);
    }
    return false;
  }

  // Cek apakah currency ada di favorit
  static Future<bool> isFavorite(String currencyCode) async {
    final favorites = await getFavorites();
    return favorites.contains(currencyCode);
  }

  // Ambil semua favorit
  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  // Clear semua favorit
  static Future<bool> clearAllFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_key);
  }

  // Toggle favorite (add jika belum ada, remove jika sudah ada)
  static Future<bool> toggleFavorite(String currencyCode) async {
    final isFav = await isFavorite(currencyCode);
    if (isFav) {
      return await removeFavorite(currencyCode);
    } else {
      return await addFavorite(currencyCode);
    }
  }
}
