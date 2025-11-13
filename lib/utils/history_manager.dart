import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoryManager {
  static const _recentlyViewedKey = 'recently_viewed';
  static const _conversionHistoryKey = 'conversion_history';

  // ==========================================
  // RECENTLY VIEWED (untuk AllRates)
  // ==========================================

  /// Menyimpan pair + waktu sekarang sebagai objek JSON.
  static Future<void> addRecentlyViewed(String from, String to) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawList = prefs.getStringList(_recentlyViewedKey) ?? [];

    final nowIso = DateTime.now().toIso8601String();
    final pairObj = json.encode({'from': from, 'to': to, 'time': nowIso});

    // remove duplicates (sama from/to), tetap simpan yang terbaru di depan
    rawList.removeWhere((e) {
      try {
        final m = json.decode(e);
        return m['from'] == from && m['to'] == to;
      } catch (_) {
        return false;
      }
    });

    rawList.insert(0, pairObj);

    // batasi 10 item
    if (rawList.length > 10) {
      rawList.removeRange(10, rawList.length);
    }

    await prefs.setStringList(_recentlyViewedKey, rawList);
  }

  /// Mengembalikan list map { 'from':..., 'to':..., 'time': DateTime }
  static Future<List<Map<String, dynamic>>> getRecentlyViewed() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawList = prefs.getStringList(_recentlyViewedKey) ?? [];

    final parsed = <Map<String, dynamic>>[];
    for (final s in rawList) {
      try {
        final m = json.decode(s);
        final dt = DateTime.tryParse(m['time'] ?? '') ?? DateTime.now();
        parsed.add({'from': m['from'], 'to': m['to'], 'time': dt});
      } catch (e) {
        // skip broken item
      }
    }
    return parsed;
  }

  // ==========================================
  // CONVERSION HISTORY (untuk ConvertPage)
  // ==========================================

  /// Menyimpan conversion history setelah user convert
  static Future<void> addConversionHistory({
    required double fromAmount,
    required String fromCode,
    required double toAmount,
    required String toCode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawList =
        prefs.getStringList(_conversionHistoryKey) ?? [];

    final nowIso = DateTime.now().toIso8601String();
    final conversionObj = json.encode({
      'fromAmount': fromAmount,
      'fromCode': fromCode,
      'toAmount': toAmount,
      'toCode': toCode,
      'time': nowIso,
    });

    rawList.insert(0, conversionObj);

    // batasi 50 item
    if (rawList.length > 50) {
      rawList.removeRange(50, rawList.length);
    }

    await prefs.setStringList(_conversionHistoryKey, rawList);
  }

  /// Mengembalikan list conversion history
  static Future<List<Map<String, dynamic>>> getConversionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawList =
        prefs.getStringList(_conversionHistoryKey) ?? [];

    final parsed = <Map<String, dynamic>>[];
    for (final s in rawList) {
      try {
        final m = json.decode(s);
        final dt = DateTime.tryParse(m['time'] ?? '') ?? DateTime.now();
        parsed.add({
          'fromAmount': m['fromAmount'],
          'fromCode': m['fromCode'],
          'toAmount': m['toAmount'],
          'toCode': m['toCode'],
          'time': dt,
        });
      } catch (e) {
        // skip broken item
      }
    }
    return parsed;
  }

  // ==========================================
  // CLEAR HISTORY (Optional)
  // ==========================================

  /// Bersihkan recently viewed
  static Future<void> clearRecentlyViewed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentlyViewedKey);
  }

  /// Bersihkan conversion history
  static Future<void> clearConversionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_conversionHistoryKey);
  }

  /// Bersihkan semua history
  static Future<void> clearAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentlyViewedKey);
    await prefs.remove(_conversionHistoryKey);
  }
}
