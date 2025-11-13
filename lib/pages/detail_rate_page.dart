import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailRatePage extends StatelessWidget {
  final Map<String, dynamic> rateData;

  const DetailRatePage({super.key, required this.rateData});

  String getFlag(String code) {
    if (code.length < 2) return '';
    final countryCode = code.substring(0, 2).toUpperCase();
    return String.fromCharCodes(
      countryCode.codeUnits.map((c) => c + 127397),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = rateData['currency'] ?? 'Unknown';
    final name = rateData['name'] ?? 'Currency';
    final rate = rateData['rate'] ?? 0.0;
    final change = rateData['change'] ?? '0.00%';
    final flag = rateData['flag'] ?? getFlag(currency);
    final isUp = change.toString().startsWith('+');

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: Text(
          '$currency Details',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
              backgroundColor: Colors.white,
              child: Text(flag, style: const TextStyle(fontSize: 40)),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              currency,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow('💰 Nilai Saat Ini',
                        'Rp${NumberFormat('#,###.##').format(rate)}'),
                    const Divider(),
                    _infoRow('📉 Perubahan', change,
                        valueColor: isUp ? Colors.green : Colors.red),
                    const Divider(),
                    _infoRow('🌍 Negara', _getCountryName(currency)),
                    const Divider(),
                    _infoRow('🔤 Kode Mata Uang', currency),
                    const Divider(),
                    _infoRow('🕒 Terakhir Diperbarui',
                        DateFormat('d MMM yyyy, HH:mm').format(DateTime.now())),
                  ],
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
                color: Colors.black87,
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
                color: valueColor ?? const Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCountryName(String code) {
    const countries = {
      'USD': 'Amerika Serikat',
      'EUR': 'Eropa',
      'JPY': 'Jepang',
      'GBP': 'Inggris',
      'SGD': 'Singapura',
      'AUD': 'Australia',
      'CNY': 'China',
      'MYR': 'Malaysia',
      'THB': 'Thailand',
      'KRW': 'Korea Selatan',
      'INR': 'India',
      'CHF': 'Swiss',
      'CAD': 'Kanada',
      'NZD': 'Selandia Baru',
      'PHP': 'Filipina',
    };
    return countries[code] ?? 'Tidak diketahui';
  }
}
