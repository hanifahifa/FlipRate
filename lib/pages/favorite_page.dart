// ------------------------------------------------------
// FAVORITE PAGE - Refactored (Using Repository)
// Sesuai Spesifikasi: UI terpisah dari Logic Data
// ------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/currency_repository.dart'; // Import Repository
import '../utils/favorite_manager.dart';
import 'addPages/detail_rate_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  static const Color primaryGreen = Color(0xFF043915);
  static const Color lightGreen = Color(0xFFF1F8E9);
  static const Color accentGreen = Color(0xFFDDE8D4);

  List<Map<String, dynamic>> favorites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // ==========================================
  // LOAD DATA VIA REPOSITORY
  // ==========================================
  Future<void> _loadFavorites() async {
    setState(() => isLoading = true);

    try {
      // 1. Ambil list kode favorit dari Local Storage (SharedPrefs)
      final favCodes = await FavoriteManager.getFavorites();

      if (favCodes.isEmpty) {
        setState(() {
          favorites = [];
          isLoading = false;
        });
        return;
      }

      // 2. Minta Repository mengambil data lengkap berdasarkan kode tersebut
      // Repository akan mengurus API call, hitung rate IDR, dan hitung perubahan %
      final data = await CurrencyRepository.getFavoriteRates(
        favoriteCurrencies: favCodes,
      );

      if (mounted) {
        setState(() {
          favorites = data;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading favorites: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // ==========================================
  // LOGIC: DELETE FAVORITE
  // ==========================================
  Future<void> _removeFavorite(Map<String, dynamic> item) async {
    final currency = item['currency'];
    final removed = await FavoriteManager.removeFavorite(currency);

    if (removed) {
      setState(() {
        favorites.removeWhere((f) => f['currency'] == currency);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $currency dihapus dari favorit'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  // ==========================================
  // LOGIC: INSIGHT BUILDER
  // ==========================================
  String buildInsight() {
    if (favorites.isEmpty) {
      return 'Start adding currencies to your favorites to track their performance.';
    }

    final upCount = favorites.where((f) => f['isUp'] == true).length;
    final totalCount = favorites.length;

    if (upCount == totalCount) {
      return 'All your favorite currencies are showing positive trends today — great timing!';
    } else if (upCount >= totalCount / 2) {
      return 'Most of your favorites are showing positive trends — keep monitoring their performance.';
    } else {
      return 'Some of your favorites are declining — consider reviewing your watchlist.';
    }
  }

  // Helper parsing string change ke double
  double _parseChange(String changeStr) {
    try {
      return double.parse(changeStr.replaceAll('%', '').replaceAll('+', ''));
    } catch (e) {
      return 0.0;
    }
  }

  // ==========================================
  // UI BUILD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    // Hitung rata-rata perubahan
    final upCount = favorites.where((f) => f['isUp'] == true).length;
    final avgChange = favorites.isNotEmpty
        ? favorites.fold(0.0, (sum, f) => sum + _parseChange(f['change'])) /
              favorites.length
        : 0.0;

    return Scaffold(
      backgroundColor: lightGreen,
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: primaryGreen,
        elevation: 0,
        centerTitle: false,
      ),

      body: RefreshIndicator(
        onRefresh: _loadFavorites,
        color: primaryGreen,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: primaryGreen),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Gradient
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryGreen, primaryGreen.withOpacity(0.8)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat(
                              'EEEE, dd MMMM yyyy',
                            ).format(DateTime.now()),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInsightCard(),
                        ],
                      ),
                    ),

                    // Content Area
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (favorites.isNotEmpty) ...[
                            _buildSectionTitle(
                              'Headlines Today',
                              Icons.analytics_outlined,
                            ),
                            const SizedBox(height: 12),
                            _buildSummaryCard(upCount, avgChange),
                            const SizedBox(height: 20),
                          ],

                          _buildSectionTitle(
                            'Your Favorite Currencies',
                            Icons.star_rounded,
                          ),
                          const SizedBox(height: 12),
                          _buildFavoritesList(),

                          const SizedBox(height: 100), // Bottom padding
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInsightCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Insight Today',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: primaryGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  buildInsight(),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: primaryGreen),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryGreen,
            fontSize: 17,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(int upCount, double avgChange) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$upCount of ${favorites.length} currencies increased',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Today',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Average change: ${avgChange >= 0 ? '+' : ''}${avgChange.toStringAsFixed(2)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Across all favorites',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    if (favorites.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.star_border_rounded,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'No favorites yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Start adding currencies to track them here',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: favorites.asMap().entries.map((entry) {
          final index = entry.key;
          final f = entry.value;
          final isLast = index == favorites.length - 1;

          return Column(
            children: [
              _favoriteItem(f),
              if (!isLast)
                Divider(height: 1, indent: 72, color: Colors.grey[200]),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _favoriteItem(Map<String, dynamic> f) {
    final changeStr = f['change'].toString();
    final isUp = f['isUp'] == true;
    final color = isUp ? Colors.green : Colors.red;
    final icon = isUp ? Icons.arrow_upward : Icons.arrow_downward;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailRatePage(rateData: f)),
          );
          _loadFavorites(); // Refresh saat kembali
        },
        onLongPress: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Remove from Favorites'),
              content: Text('Remove ${f['currency']} from your favorites?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Remove'),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await _removeFavorite(f);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(f['flag'], style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f['currency'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rp${NumberFormat('#,###.##').format(f['rate'])}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      changeStr,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
