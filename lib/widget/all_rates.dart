// ------------------------------------------------------
// ALL RATES WIDGET - Refactored (Using Repository)
// Sesuai Spesifikasi: UI terpisah dari Logic Data
// ------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/currency_repository.dart'; // Import Repository
import '../pages/addPages/detail_rate_page.dart';
import '../utils/history_manager.dart';

class AllRatesWidget extends StatefulWidget {
  const AllRatesWidget({super.key});

  @override
  State<AllRatesWidget> createState() => _AllRatesWidgetState();
}

class _AllRatesWidgetState extends State<AllRatesWidget> {
  // State Data
  List<Map<String, dynamic>> allRates = [];
  List<Map<String, dynamic>> filteredRates = [];

  // State UI
  bool isLoading = true;
  String errorMessage = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRates(); // Panggil fungsi fetch yang baru
    _searchController.addListener(_filterRates);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // =====================================================
  // FETCH DATA VIA REPOSITORY (Sesuai Ketentuan)
  // =====================================================
  Future<void> _fetchRates() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Panggil Repository alih-alih HTTP langsung
      // Logic backend, perhitungan IDR, dan % perubahan sudah diurus di sana
      final rates = await CurrencyRepository.getAllRates();

      if (mounted) {
        setState(() {
          allRates = rates;
          filteredRates = rates;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Gagal memuat data. Periksa koneksi internet Anda.';
        });
        print("Error di AllRates: $e");
      }
    }
  }

  // =====================================================
  // FILTER LOGIC (Tetap di UI karena ini logic tampilan)
  // =====================================================
  void _filterRates() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredRates = allRates.where((r) {
        final name = (r['name'] ?? '').toString().toLowerCase();
        final code = (r['currency'] ?? '').toString().toLowerCase();
        return name.contains(query) || code.contains(query);
      }).toList();
    });
  }

  String _fmt(double n) => NumberFormat('#,###.##').format(n);

  // =====================================================
  // UI BUILD
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('All Rates', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRates, // Tarik untuk refresh via Repo
        color: const Color(0xFF2E7D32),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF2E7D32),
                  ),
                  hintText: 'Cari mata uang (USD, Euro...)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                ),
              ),
            ),

            // Content List
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2E7D32),
                      ),
                    )
                  : errorMessage.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(errorMessage, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchRates,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Coba Lagi"),
                          ),
                        ],
                      ),
                    )
                  : filteredRates.isEmpty
                  ? const Center(child: Text('Data tidak ditemukan'))
                  : ListView.builder(
                      itemCount: filteredRates.length,
                      itemBuilder: (context, i) =>
                          _buildCard(filteredRates[i], context),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // ITEM CARD
  // =====================================================
  Widget _buildCard(Map<String, dynamic> r, BuildContext context) {
    // Logic menentukan warna & arah panah sudah ada di data Repo ('isUp')
    // Tapi kita bisa cek manual juga dari string change
    final isUp = (r['isUp'] as bool?) ?? r['change'].toString().startsWith('+');
    final changeText = r['change'].toString();

    // Data format dari Repository:
    // {
    //   'currency': 'USD',
    //   'name': 'US Dollar',
    //   'flag': '🇺🇸',
    //   'rate': 15000.0,
    //   'change': '+0.50%', // Sudah String terformat
    //   'isUp': true
    // }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailRatePage(rateData: r)),
          );
          HistoryManager.addRecentlyViewed(r['currency'], 'IDR');
        },
        leading: Text(r['flag'], style: const TextStyle(fontSize: 28)),
        title: Text(
          r['currency'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(r['name']),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Rp${_fmt(r['rate'])}',
              style: const TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUp ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12,
                  color: isUp ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 2),
                Text(
                  changeText,
                  style: TextStyle(
                    color: isUp ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
