// ------------------------------------------------------
// HISTORY MANAGER - User Specific Edition (FIXED TYPE CAST)
// Menyimpan history berdasarkan User yang sedang login
// ------------------------------------------------------

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/auth_repository.dart'; // Import AuthRepo untuk cek user

class HistoryManager {
  // Nama dasar kunci (Prefix)
  static const String _baseKeyHistory = 'conversion_history';
  static const String _baseKeyRecent = 'recently_viewed';

  // ====================================================
  // HELPER: GENERATE USER-SPECIFIC KEY
  // ====================================================
  // Mengubah 'conversion_history' menjadi 'conversion_history_ifa'
  static Future<String> _getUserKey(String baseKey) async {
    final username = await AuthRepository.getCurrentUser();
    // Jika tidak ada user (guest), pakai label 'guest'
    final userLabel = username ?? 'guest'; 
    return '${baseKey}_$userLabel';
  }

  // ====================================================
  // 1. CONVERSION HISTORY (LOGIC)
  // ====================================================
  
  static Future<void> addConversionHistory({
    required double fromAmount,
    required String fromCode,
    required double toAmount,
    required String toCode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // DAPATKAN KUNCI KHUSUS USER
    final key = await _getUserKey(_baseKeyHistory);

    // Ambil data lama milik user ini
    List<String> historyList = prefs.getStringList(key) ?? [];

    // Buat item baru
    final newItem = {
      'fromAmount': fromAmount,
      'fromCode': fromCode,
      'toAmount': toAmount,
      'toCode': toCode,
      'time': DateTime.now().toIso8601String(),
    };

    // Tambahkan ke paling atas (index 0)
    historyList.insert(0, jsonEncode(newItem));

    // Batasi cuma simpan 50 riwayat terakhir per user biar memori aman
    if (historyList.length > 50) {
      historyList = historyList.sublist(0, 50);
    }

    // Simpan balik ke kunci user tersebut
    await prefs.setStringList(key, historyList);
  }

  static Future<List<Map<String, dynamic>>> getConversionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    
    // DAPATKAN KUNCI KHUSUS USER
    final key = await _getUserKey(_baseKeyHistory);

    List<String> historyList = prefs.getStringList(key) ?? [];

    return historyList.map((item) {
      // FIX: Gunakan Map<String, dynamic>.from agar tipe datanya aman
      final data = Map<String, dynamic>.from(jsonDecode(item));
      return {
        ...data,
        'time': DateTime.parse(data['time']),
      };
    }).toList();
  }

  // ====================================================
  // 2. RECENTLY VIEWED (LOGIC)
  // ====================================================

  static Future<void> addRecentlyViewed(String from, String to) async {
    final prefs = await SharedPreferences.getInstance();
    
    // DAPATKAN KUNCI KHUSUS USER
    final key = await _getUserKey(_baseKeyRecent);

    List<String> recentList = prefs.getStringList(key) ?? [];

    // Hapus jika sudah ada sebelumnya (supaya naik ke paling atas)
    recentList.removeWhere((item) {
      final data = jsonDecode(item);
      return data['from'] == from && data['to'] == to;
    });

    final newItem = {
      'from': from,
      'to': to,
      'time': DateTime.now().toIso8601String(),
    };

    recentList.insert(0, jsonEncode(newItem));

    if (recentList.length > 10) {
      recentList = recentList.sublist(0, 10);
    }

    await prefs.setStringList(key, recentList);
  }

  static Future<List<Map<String, dynamic>>> getRecentlyViewed() async {
    final prefs = await SharedPreferences.getInstance();
    
    // DAPATKAN KUNCI KHUSUS USER
    final key = await _getUserKey(_baseKeyRecent);

    List<String> recentList = prefs.getStringList(key) ?? [];

    return recentList.map((item) {
      // FIX: Gunakan Map<String, dynamic>.from agar tipe datanya aman
      final data = Map<String, dynamic>.from(jsonDecode(item));
      return {
        ...data,
        'time': DateTime.parse(data['time']),
      };
    }).toList();
  }

  // ====================================================
  // CLEAR HISTORY (Opsional: Hapus data User Tertentu)
  // ====================================================
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final keyHist = await _getUserKey(_baseKeyHistory);
    final keyRec = await _getUserKey(_baseKeyRecent);
    
    await prefs.remove(keyHist);
    await prefs.remove(keyRec);
  }
}