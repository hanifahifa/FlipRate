// ------------------------------------------------------
// ALL RATES WIDGET - With Centralized Colors
// ------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/currency_repository.dart';
import '../pages/addPages/detail_rate_page.dart';
import '../utils/history_manager.dart';

// =====================================================
// APP COLORS - Ubah warna primary di sini untuk ganti semua tema!
// =====================================================
class AppColors {
  static const Color primary = Color(0xFF043915);        // 👈 UBAH DI SINI!
  static const Color primaryLight = Color(0xFF2E7D32);
  static const Color background = Color(0xFFF1F8E9);
  static const Color backgroundWhite = Colors.white;
  static const Color textWhite = Colors.white;
  static const Color textSecondary = Color(0xFF757575);
  static const Color textPrimary = Color(0xFF043915);
  static const Color rateUp = Color(0xFF4CAF50);
  static const Color rateDown = Color(0xFFE53935);
}

class AllRatesWidget extends StatefulWidget {
  const AllRatesWidget({super.key});

  @override
  State<AllRatesWidget> createState() => _AllRatesWidgetState();
}

class _AllRatesWidgetState extends State<AllRatesWidget> {
  List<Map<String, dynamic>> allRates = [];
  List<Map<String, dynamic>> filteredRates = [];
  bool isLoading = true;
  String errorMessage = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRates();
    _searchController.addListener(_filterRates);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRates() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('All Rates', style: TextStyle(color: AppColors.textWhite)),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRates,
        color: AppColors.primary,
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: AppColors.primary),
                  hintText: 'Cari mata uang (USD, Euro...)',
                  filled: true,
                  fillColor: AppColors.backgroundWhite,
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
                  ? Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : errorMessage.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            errorMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchRates,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textWhite,
                            ),
                            child: const Text("Coba Lagi"),
                          ),
                        ],
                      ),
                    )
                  : filteredRates.isEmpty
                  ? Center(
                      child: Text(
                        'Data tidak ditemukan',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
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

  Widget _buildCard(Map<String, dynamic> r, BuildContext context) {
    final isUp = (r['isUp'] as bool?) ?? r['change'].toString().startsWith('+');
    final changeText = r['change'].toString();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: AppColors.backgroundWhite,
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          r['name'],
          style: TextStyle(color: AppColors.textSecondary),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Rp${_fmt(r['rate'])}',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUp ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12,
                  color: isUp ? AppColors.rateUp : AppColors.rateDown,
                ),
                const SizedBox(width: 2),
                Text(
                  changeText,
                  style: TextStyle(
                    color: isUp ? AppColors.rateUp : AppColors.rateDown,
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