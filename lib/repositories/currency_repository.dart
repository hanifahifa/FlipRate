import '../models/exchange_rate_response.dart';
import '../services/exchange_rate_service.dart';

class CurrencyRepository {
  static const Map<String, String> currencyFlags = {
    'USD': '🇺🇸', 'EUR': '🇪🇺', 'JPY': '🇯🇵', 'GBP': '🇬🇧',
    'SGD': '🇸🇬', 'AUD': '🇦🇺', 'CNY': '🇨🇳', 'MYR': '🇲🇾',
    'THB': '🇹🇭', 'KRW': '🇰🇷', 'INR': '🇮🇳', 'CHF': '🇨🇭',
    'CAD': '🇨🇦', 'NZD': '🇳🇿', 'PHP': '🇵🇭', 'IDR': '🇮🇩',
    'AED': '🇦🇪', 'SAR': '🇸🇦', 'ZAR': '🇿🇦',
  };

  static const Map<String, String> currencyNames = {
    'USD': 'US Dollar', 'EUR': 'Euro', 'JPY': 'Japanese Yen',
    'GBP': 'British Pound', 'SGD': 'Singapore Dollar',
    'AUD': 'Australian Dollar', 'CNY': 'Chinese Yuan',
    'MYR': 'Malaysian Ringgit', 'THB': 'Thai Baht',
    'KRW': 'South Korean Won', 'INR': 'Indian Rupee',
    'CHF': 'Swiss Franc', 'CAD': 'Canadian Dollar',
    'NZD': 'New Zealand Dollar', 'PHP': 'Philippine Peso',
    'IDR': 'Indonesian Rupiah', 'AED': 'UAE Dirham',
    'SAR': 'Saudi Riyal', 'ZAR': 'South African Rand',
  };

  // ==========================================
  // GET POPULAR RATES (Untuk Dashboard)
  // ==========================================
  static Future<List<Map<String, dynamic>>> getPopularRates({
    List<String> currencies = const ['USD', 'EUR', 'JPY', 'SGD'],
  }) async {
    try {
      print('📦 Repository: Getting popular rates for ${currencies.join(", ")}');

      final exchangeResponse = await ExchangeRateService.fetchRates();
      if (exchangeResponse == null) throw Exception('Service returned null');

      final rates = exchangeResponse.rates;
      final yesterdayRates = await ExchangeRateService.fetchHistoricalRates();

      // Fallback jika IDR tidak tersedia
      final idrRate = (rates['IDR'] ?? 15000.0);
      final yesterdayIdrRate = (yesterdayRates['IDR'] ?? idrRate);

      List<Map<String, dynamic>> result = [];

      for (final currency in currencies) {
        final code = currency.toUpperCase();
        final rate = rates[code];
        if (rate == null) continue;

        // Convert 1 unit currency -> IDR using cross rate
        final curToIdr = idrRate / rate;

        double changePercent = 0.0;
        final yesterdayCurRate = yesterdayRates[code];

        if (yesterdayCurRate != null && yesterdayIdrRate != 0) {
          final yesterdayCurToIdr = yesterdayIdrRate / yesterdayCurRate;
          if (yesterdayCurToIdr != 0) {
            final diff = curToIdr - yesterdayCurToIdr;
            changePercent = (diff / yesterdayCurToIdr) * 100;
          }
        }

        result.add({
          'currency': code,
          'name': currencyNames[code] ?? code,
          'flag': currencyFlags[code] ?? '🏳️',
          'rate': curToIdr,
          'change': formatChange(changePercent),
          'isUp': changePercent >= 0,
        });
      }
      return result;
    } catch (e) {
      print('❌ Repository Error (Popular): $e');
      rethrow;
    }
  }

  // ==========================================
  // GET ALL RATES (Untuk AllRatesWidget & Analysis)
  // ==========================================
  static Future<List<Map<String, dynamic>>> getAllRates() async {
    try {
      print('📦 Repository: Getting all rates...');

      final exchangeResponse = await ExchangeRateService.fetchRates();
      if (exchangeResponse == null) throw Exception('Service returned null');

      final rates = exchangeResponse.rates;
      final yesterdayRates = await ExchangeRateService.fetchHistoricalRates();

      final idrRate = (rates['IDR'] ?? 15000.0);
      final yesterdayIdrRate = (yesterdayRates['IDR'] ?? idrRate);

      List<Map<String, dynamic>> result = [];

      for (final entry in rates.entries) {
        final code = entry.key.toUpperCase();
        if (code == 'IDR') continue;

        final rate = entry.value;
        final curToIdr = idrRate / rate;

        double changePercent = 0.0;
        final yesterdayCurRate = yesterdayRates[code];

        if (yesterdayCurRate != null && yesterdayIdrRate != 0) {
          final yesterdayCurToIdr = yesterdayIdrRate / yesterdayCurRate;
          if (yesterdayCurToIdr != 0) {
            final diff = curToIdr - yesterdayCurToIdr;
            changePercent = (diff / yesterdayCurToIdr) * 100;
          }
        }

        result.add({
          'currency': code,
          'name': currencyNames[code] ?? code,
          'flag': currencyFlags[code] ?? '🏳️',
          'rate': curToIdr,
          'change': formatChange(changePercent),
          'isUp': changePercent >= 0,
        });
      }

      result.sort((a, b) => a['currency'].compareTo(b['currency']));
      return result;
    } catch (e) {
      print('❌ Repository Error (All Rates): $e');
      rethrow;
    }
  }

  // ==========================================
  // GET FAVORITE RATES
  // ==========================================
  static Future<List<Map<String, dynamic>>> getFavoriteRates({
    required List<String> favoriteCurrencies,
  }) async {
    return getPopularRates(currencies: favoriteCurrencies);
  }

  // ==========================================
  // GET CURRENCY CODES (Untuk Dropdown Convert)
  // ==========================================
  static Future<List<String>> getCurrencyCodes() async {
    try {
      final response = await ExchangeRateService.fetchRates(); // Default USD base
      if (response == null) return [];

      List<String> codes = response.rates.keys.map((k) => k.toString()).toList();

      // Pastikan USD & IDR ada jika tidak terambil
      if (!codes.contains('USD')) codes.add('USD');
      if (!codes.contains('IDR')) codes.add('IDR');

      codes.sort();
      return codes;
    } catch (e) {
      print('❌ Repo Error (Codes): $e');
      return [];
    }
  }

  // ==========================================
  // CONVERT CURRENCY (Fixed Logic: Cross-Rate)
  // ==========================================
  static Future<double> convertCurrency({
    required double amount,
    required String from,
    required String to,
  }) async {
    try {
      final response = await ExchangeRateService.fetchRates();
      if (response == null) throw Exception('Gagal mengambil data');

      final rates = response.rates;

      // usdToFrom: 1 USD = X (from)
      // usdToTo:   1 USD = Y (to)
      double usdToFrom = (from.toUpperCase() == 'USD') ? 1.0 : (rates[from.toUpperCase()] ?? 0.0);
      double usdToTo = (to.toUpperCase() == 'USD') ? 1.0 : (rates[to.toUpperCase()] ?? 0.0);

      if (usdToFrom == 0.0 || usdToTo == 0.0) {
        throw Exception('Mata uang tidak didukung atau data kosong');
      }

      // Rumus: (amount / usdToFrom) * usdToTo
      return (amount / usdToFrom) * usdToTo;
    } catch (e) {
      print('❌ Repo Error (Convert): $e');
      rethrow;
    }
  }

  // ==========================================
  // GET SINGLE EXCHANGE RATE (rate of 1 unit 'from' in 'to')
  // ==========================================
  static Future<double> getExchangeRate({
    required String from,
    required String to,
  }) async {
    try {
      final response = await ExchangeRateService.fetchRates();
      if (response == null) throw Exception('Failed to fetch rates');

      final rates = response.rates;

      final fromKey = from.toUpperCase();
      final toKey = to.toUpperCase();

      // Handle USD explicitly
      double usdToFrom = (fromKey == 'USD') ? 1.0 : (rates[fromKey] ?? 0.0);
      double usdToTo = (toKey == 'USD') ? 1.0 : (rates[toKey] ?? 0.0);

      if (usdToFrom == 0.0 || usdToTo == 0.0) {
        // Jika data tidak lengkap, kembalikan 0.0 sebagai indikator gagal
        return 0.0;
      }

      // Rate 1 from = (1 / usdToFrom) * usdToTo
      return (1 / usdToFrom) * usdToTo;
    } catch (e) {
      print('❌ Repo Error (Single Rate): $e');
      return 0.0;
    }
  }

  // ==========================================
  // MARKET NEWS (Placeholder - bisa diganti API nyata)
  // ==========================================
  static Future<String> getMarketNews() async {
    try {
      // Simulasi delay kecil
      await Future.delayed(const Duration(milliseconds: 600));
      // Dummy message — ganti dengan panggilan API news jika ingin real-time
      return 'Global currency markets remain sensitive to central bank announcements and major macroeconomic releases.';
    } catch (e) {
      print('❌ Repo Error (MarketNews): $e');
      return 'Market insights are currently unavailable.';
    }
  }

  // ==========================================
  // HELPERS
  // ==========================================
  static String getFlag(String currencyCode) =>
      currencyFlags[currencyCode.toUpperCase()] ?? '🏳️';

  static String getName(String currencyCode) =>
      currencyNames[currencyCode.toUpperCase()] ?? currencyCode;

  static String formatChange(double changePercent) {
    if (changePercent.isNaN || changePercent.isInfinite) {
      return '0.00%';
    }
    final sign = changePercent >= 0 ? '+' : '';
    return '$sign${changePercent.toStringAsFixed(2)}%';
  }
}
