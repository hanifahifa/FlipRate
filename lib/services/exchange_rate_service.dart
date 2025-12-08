// services/exchange_rate_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exchange_rate_response.dart';

class ExchangeRateService {
  
  // Gunakan URL yang sama persis dengan AllRatesWidget agar konsisten
  static final List<String> _apiUrls = [
    'https://api.exchangerate-api.com/v4/latest/USD', // Paling stabil
    'https://open.er-api.com/v6/latest/USD',
    'https://api.frankfurter.app/latest?from=USD',
  ];

  // ==========================================
  // FETCH EXCHANGE RATES (LOOPING FALLBACK)
  // ==========================================
  static Future<ExchangeRateResponse?> fetchRates({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    
    for (int i = 0; i < _apiUrls.length; i++) {
      final url = _apiUrls[i];
      try {
        print('🔄 Trying API $i: $url ...');
        final response = await http.get(Uri.parse(url)).timeout(timeout);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('✅ Success fetching from API $i');
          return ExchangeRateResponse.fromJson(data);
        } else {
          print('⚠️ API $i failed with status: ${response.statusCode}');
        }
      } catch (e) {
        print('⚠️ API $i Error: $e');
        // Lanjut ke API berikutnya jika error
        continue;
      }
    }

    // Jika semua loop selesai dan tidak ada return
    print('❌ All APIs failed');
    return null;
  }

  // ==========================================
  // FETCH HISTORICAL RATES (Tetap sama)
  // ==========================================
  static Future<Map<String, double>> fetchHistoricalRates({
    String baseCurrency = 'USD',
    int daysAgo = 1,
  }) async {
    // Frankfurter adalah satu-satunya free API yang support history mudah
    // Jika ini gagal, aplikasi tidak boleh crash, cukup return empty map.
    
    final date = DateTime.now().subtract(Duration(days: daysAgo));
    final formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    try {
      final url = 'https://api.frankfurter.app/$formattedDate?from=$baseCurrency';
      print("🔄 Fetching historical: $url");

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5)); // Timeout pendek saja

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['rates'] != null) {
           return Map<String, double>.from(
            data['rates'].map(
              (k, v) => MapEntry(k.toString().toUpperCase(), (v as num).toDouble()),
            ),
          );
        }
      }
    } catch (e) {
      print("⚠️ Historical Data Error (Ignored): $e");
    }

    return {}; // Return kosong agar dashboard tetap jalan tanpa persentase perubahan
  }
}