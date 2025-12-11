import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/favorite_manager.dart';

// =========================================================
// 🎨 COLOR SETTINGS (Change hex code here)
// =========================================================
class AppColors {
  // Primary Color - Change this to change app theme
  static const Color primary = Color(0xFF043915); // 👈 CHANGE HERE!

  // Page Background Color
  static const Color background = Color(0xFFF1F8E9);

  // Text & Icon Colors
  static const Color white = Colors.white;
  static const Color blackText = Colors.black87;
  static const Color greyText = Colors.grey;

  // Status Colors
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color warning = Colors.amber;
  static const Color disabled = Colors.grey;
}
// =========================================================

class DetailRatePage extends StatefulWidget {
  final Map<String, dynamic> rateData;

  const DetailRatePage({super.key, required this.rateData});

  @override
  State<DetailRatePage> createState() => _DetailRatePageState();
}

class _DetailRatePageState extends State<DetailRatePage> {
  bool isFavorite = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final currency = widget.rateData['currency'] ?? '';
    final fav = await FavoriteManager.isFavorite(currency);
    setState(() {
      isFavorite = fav;
      isLoading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    final currency = widget.rateData['currency'] ?? '';
    final success = await FavoriteManager.toggleFavorite(currency);

    if (success || await FavoriteManager.isFavorite(currency) != isFavorite) {
      setState(() {
        isFavorite = !isFavorite;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite
                ? '✅ $currency added to favorites' // Translated
                : '❌ $currency removed from favorites', // Translated
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: isFavorite ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  String getFlag(String code) {
    if (code.length < 2) return '';
    final countryCode = code.substring(0, 2).toUpperCase();
    return String.fromCharCodes(countryCode.codeUnits.map((c) => c + 127397));
  }

  @override
  Widget build(BuildContext context) {
    final currency = widget.rateData['currency'] ?? 'Unknown';
    final name = widget.rateData['name'] ?? 'Currency';
    final rate = widget.rateData['rate'] ?? 0.0;
    final change = widget.rateData['change'] ?? '0.00%';
    final flag = widget.rateData['flag'] ?? getFlag(currency);
    final isUp = change.toString().startsWith('+');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '$currency Details',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 45,
              backgroundColor: AppColors.white,
              child: Text(flag, style: const TextStyle(fontSize: 40)),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              currency,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.greyText,
              ),
            ),
            const SizedBox(height: 24),

            // Card Info
            Card(
              color: AppColors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(
                      '💰 Current Value', // Translated
                      'Rp${NumberFormat('#,###.##').format(rate)}',
                    ),
                    const Divider(),
                    _infoRow(
                      '📉 Change', // Translated
                      change,
                      valueColor: isUp ? AppColors.success : AppColors.error,
                    ),
                    const Divider(),
                    _infoRow(
                      '🌍 Country',
                      _getCountryName(currency),
                    ), // Translated
                    const Divider(),
                    _infoRow('🔤 Currency Code', currency), // Translated
                    const Divider(),
                    _infoRow(
                      '🕒 Last Updated', // Translated
                      DateFormat('d MMM yyyy, HH:mm').format(DateTime.now()),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Button Add/Remove Favorite
            if (!isLoading)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _toggleFavorite,
                  icon: Icon(isFavorite ? Icons.star : Icons.star_border),
                  label: Text(
                    isFavorite
                        ? 'Remove from Favorites'
                        : 'Add to Favorites', // Translated
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFavorite
                        ? AppColors
                              .disabled // Grey if favorite
                        : AppColors.primary, // Green if not
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.blackText,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.primary, // Default to Primary
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCountryName(String code) {
    // Translated Country Names
    const countries = {
      'USD': 'United States',
      'EUR': 'Eurozone',
      'JPY': 'Japan',
      'GBP': 'United Kingdom',
      'SGD': 'Singapore',
      'AUD': 'Australia',
      'CNY': 'China',
      'MYR': 'Malaysia',
      'THB': 'Thailand',
      'KRW': 'South Korea',
      'INR': 'India',
      'CHF': 'Switzerland',
      'CAD': 'Canada',
      'NZD': 'New Zealand',
      'PHP': 'Philippines',
    };
    return countries[code] ?? 'Unknown'; // Translated fallback
  }
}
