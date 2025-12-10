// ------------------------------------------------------
// FAVORITE MANAGER - User Specific Edition
// Menyimpan favorit berdasarkan User yang sedang login
// ------------------------------------------------------

import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/auth_repository.dart'; // Import AuthRepo untuk cek user

class FavoriteManager {
  // Nama dasar kunci (Prefix)
  static const String _baseKey = 'favorite_currencies';

  // ====================================================
  // HELPER: GENERATE USER-SPECIFIC KEY
  // ====================================================
  // Mengubah 'favorite_currencies' menjadi 'favorite_currencies_ifa'
  static Future<String> _getUserKey() async {
    final username = await AuthRepository.getCurrentUser();
    // Jika tidak ada user (guest), pakai label 'guest'
    final userLabel = username ?? 'guest'; 
    return '${_baseKey}_$userLabel';
  }

  // ====================================================
  // LOGIC FAVORIT
  // ====================================================

  // Tambah currency ke favorit
  static Future<bool> addFavorite(String currencyCode) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Ambil Key Khusus User
    final key = await _getUserKey();
    
    // Ambil list lama user ini
    final favorites = prefs.getStringList(key) ?? [];

    if (!favorites.contains(currencyCode)) {
      favorites.add(currencyCode);
      return await prefs.setStringList(key, favorites);
    }
    return false; // Sudah ada di favorit
  }

  // Hapus currency dari favorit
  static Future<bool> removeFavorite(String currencyCode) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Ambil Key Khusus User
    final key = await _getUserKey();
    
    final favorites = prefs.getStringList(key) ?? [];

    if (favorites.contains(currencyCode)) {
      favorites.remove(currencyCode);
      return await prefs.setStringList(key, favorites);
    }
    return false;
  }

  // Cek apakah currency ada di favorit
  static Future<bool> isFavorite(String currencyCode) async {
    // Kita panggil getFavorites() di sini agar logic pengambilan key tidak duplikat
    final favorites = await getFavorites();
    return favorites.contains(currencyCode);
  }

  // Ambil semua favorit
  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Ambil Key Khusus User
    final key = await _getUserKey();
    
    return prefs.getStringList(key) ?? [];
  }

  // Clear semua favorit (User Tertentu)
  static Future<bool> clearAllFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Ambil Key Khusus User
    final key = await _getUserKey();
    
    return await prefs.remove(key);
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