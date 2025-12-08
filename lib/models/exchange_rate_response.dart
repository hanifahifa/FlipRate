// models/exchange_rate_response.dart
class ExchangeRateResponse {
  final String baseCode;
  final Map<String, double> rates;
  // Field metadata lainnya kita buat optional/tidak wajib
  final String provider;
  final int timeLastUpdateUnix;

  ExchangeRateResponse({
    required this.baseCode,
    required this.rates,
    this.provider = '',
    this.timeLastUpdateUnix = 0,
  });

  factory ExchangeRateResponse.fromJson(Map<String, dynamic> json) {
    // 1. Ambil Rates (Logika fleksibel untuk berbagai struktur API)
    Map<String, dynamic> ratesMap = {};
    
    if (json['rates'] != null) {
      ratesMap = json['rates'];
    } else if (json['usd'] != null) {
      // Handle API cadangan: @fawazahmed0/currency-api
      ratesMap = json['usd'];
    }

    // Konversi nilai rate ke double
    final parsedRates = <String, double>{};
    ratesMap.forEach((key, value) {
      if (key.toString().toUpperCase() != 'IDR') { // IDR sendiri tidak perlu dihitung
         parsedRates[key.toUpperCase()] = (value as num).toDouble();
      }
      // Khusus IDR, pastikan masuk
      if (key.toString().toUpperCase() == 'IDR') {
         parsedRates['IDR'] = (value as num).toDouble();
      }
    });
    
    // Pastikan jika ada 'idr' (lowercase) dari api tertentu, tetap masuk
    if (ratesMap.containsKey('idr')) {
       parsedRates['IDR'] = (ratesMap['idr'] as num).toDouble();
    }

    // 2. Ambil Base Code (Cari 'base_code' atau 'base')
    String base = 'USD';
    if (json['base_code'] != null) {
      base = json['base_code'];
    } else if (json['base'] != null) {
      base = json['base'];
    }

    return ExchangeRateResponse(
      baseCode: base,
      rates: parsedRates,
      provider: json['provider'] ?? 'Unknown',
      timeLastUpdateUnix: json['time_last_update_unix'] ?? 
                          json['time_last_updated'] ?? // API v4 menggunakan key ini
                          0,
    );
  }
}