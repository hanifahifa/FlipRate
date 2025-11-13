import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/favorite_manager.dart';

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
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite 
              ? '✅ $currency ditambahkan ke favorit'
              : '❌ $currency dihapus dari favorit',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: isFavorite ? Colors.green : Colors.red,
        ),
      );
    }
  }

  String getFlag(String code) {
    if (code.length < 2) return '';
    final countryCode = code.substring(0, 2).toUpperCase();
    return String.fromCharCodes(
      countryCode.codeUnits.map((c) => c + 127397),
    );
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
        actions: [
          // Tombol favorite di AppBar
          if (!isLoading)
            IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? Colors.amber : Colors.white,
              ),
              onPressed: _toggleFavorite,
            ),
        ],
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
            
            // Card Info
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
            
            const SizedBox(height: 20),
            
            // Tombol Add/Remove Favorite (Alternatif di bawah card)
            if (!isLoading)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                  ),
                  label: Text(
                    isFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFavorite ? Colors.grey[400] : const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
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