// ------------------------------------------------------
// FAVORITE PAGE - FlipRate (Real-time data from API)
// ------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/favorite_manager.dart';
import '../pages/detail_rate_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFFF1F8E9);
  static const Color accentGreen = Color(0xFFDDE8D4);

  List<Map<String, dynamic>> favorites = [];
  Map<String, double> yesterdayRates = {};
  bool isLoading = true;

  final Map<String, String> currencyFlags = {
    'USD': '🇺🇸',
    'EUR': '🇪🇺',
    'JPY': '🇯🇵',
    'GBP': '🇬🇧',
    'SGD': '🇸🇬',
    'AUD': '🇦🇺',
    'CNY': '🇨🇳',
    'MYR': '🇲🇾',
    'THB': '🇹🇭',
    'KRW': '🇰🇷',
    'INR': '🇮🇳',
    'CHF': '🇨🇭',
    'CAD': '🇨🇦',
    'NZD': '🇳🇿',
    'PHP': '🇵🇭',
  };

  final Map<String, String> currencyNames = {
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'JPY': 'Japanese Yen',
    'GBP': 'British Pound',
    'SGD': 'Singapore Dollar',
    'AUD': 'Australian Dollar',
    'CNY': 'Chinese Yuan',
    'MYR': 'Malaysian Ringgit',
    'THB': 'Thai Baht',
    'KRW': 'South Korean Won',
    'INR': 'Indian Rupee',
    'CHF': 'Swiss Franc',
    'CAD': 'Canadian Dollar',
    'NZD': 'New Zealand Dollar',
    'PHP': 'Philippine Peso',
  };

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => isLoading = true);

    // Load favorite codes dari storage
    final favCodes = await FavoriteManager.getFavorites();

    if (favCodes.isEmpty) {
      setState(() {
        favorites = [];
        isLoading = false;
      });
      return;
    }

    // Fetch yesterday rates
    await _fetchYesterdayRates();

    // Fetch current rates dari API
    await _fetchCurrentRates(favCodes);
  }

  Future<void> _fetchYesterdayRates() async {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final twoDaysAgo = now.subtract(const Duration(days: 2));

    String formatDate(DateTime date) =>
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final urls = [
      "https://api.frankfurter.app/${formatDate(yesterday)}?from=USD",
      "https://api.frankfurter.app/${formatDate(twoDaysAgo)}?from=USD",
    ];

    for (final url in urls) {
      try {
        final res = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 10));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['rates'] != null && data['rates'].isNotEmpty) {
            yesterdayRates = Map<String, double>.from(
              data['rates'].map(
                (k, v) =>
                    MapEntry(k.toString().toUpperCase(), (v as num).toDouble()),
              ),
            );
            return;
          }
        }
      } catch (e) {
        print("⚠️ Error fetching yesterday rates: $e");
      }
    }
  }

  Future<void> _fetchCurrentRates(List<String> favCodes) async {
    final apis = [
      'https://api.exchangerate-api.com/v4/latest/USD',
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json',
      'https://api.frankfurter.app/latest?from=USD',
    ];

    for (int i = 0; i < apis.length; i++) {
      try {
        final response = await http
            .get(Uri.parse(apis[i]))
            .timeout(const Duration(seconds: 10));

        if (response.statusCode != 200) continue;

        final data = json.decode(response.body);
        Map<String, dynamic> rates;
        double idrRate;

        if (i == 0) {
          rates = data['rates'];
          idrRate = (rates['IDR'] as num).toDouble();
        } else if (i == 1) {
          rates = data['usd'];
          idrRate = (rates['idr'] as num).toDouble();
        } else {
          rates = data['rates'];
          idrRate = (rates['IDR'] as num).toDouble();
        }

        final list = favCodes
            .map((code) {
              final rate = rates[code.toLowerCase()] ?? rates[code];
              if (rate == null) return null;

              // 1 USD = rate CUR (contoh: 1 USD = 1.5 AUD)
              // 1 USD = idrRate IDR (contoh: 1 USD = 16000 IDR)
              // Jadi: 1 CUR = idrRate / rate IDR
              final curToIdr = idrRate / (rate as num).toDouble();
              final change = _calcChange(code, curToIdr, idrRate);

              return {
                'currency': code,
                'name': currencyNames[code] ?? code,
                'flag': currencyFlags[code] ?? '🏳️',
                'rate': curToIdr,
                'change': change,
                'isUp': change.startsWith('+'),
              };
            })
            .where((item) => item != null)
            .cast<Map<String, dynamic>>()
            .toList();

        setState(() {
          favorites = list;
          isLoading = false;
        });
        return;
      } catch (e) {
        if (i == apis.length - 1) {
          setState(() => isLoading = false);
        }
      }
    }
  }

  String _calcChange(String cur, double todayCurToIdr, double todayUsdToIdr) {
    if (yesterdayRates.isEmpty ||
        !yesterdayRates.containsKey(cur) ||
        !yesterdayRates.containsKey('IDR')) {
      return '0.00%';
    }

    // Yesterday: 1 USD = yesterdayRates['IDR'] IDR
    // Yesterday: 1 USD = yesterdayRates[cur] CUR
    // Jadi: 1 CUR = yesterdayRates['IDR'] / yesterdayRates[cur] IDR

    final yesterdayUsdToIdr = yesterdayRates['IDR']!;
    final yesterdayUsdToCur = yesterdayRates[cur]!;
    final yesterdayCurToIdr = yesterdayUsdToIdr / yesterdayUsdToCur;

    // Hitung perubahan persen
    final diff = todayCurToIdr - yesterdayCurToIdr;
    final percent = (diff / yesterdayCurToIdr) * 100;

    final sign = percent >= 0 ? '+' : '';
    return '$sign${percent.toStringAsFixed(2)}%';
  }

  String buildInsight() {
    if (favorites.isEmpty) {
      return 'Start adding currencies to your favorites to track their performance.';
    }

    final upCount = favorites.where((f) => f['isUp']).length;
    final totalCount = favorites.length;

    if (upCount == totalCount) {
      return 'All your favorite currencies are showing positive trends today — great timing!';
    } else if (upCount >= totalCount / 2) {
      return 'Most of your favorites are showing positive trends — keep monitoring their performance.';
    } else {
      return 'Some of your favorites are declining — consider reviewing your watchlist.';
    }
  }

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
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final upCount = favorites.where((f) => f['isUp'] == true).length;
    final avgChange = favorites.isNotEmpty
        ? favorites.fold(0.0, (sum, f) {
                final changeStr = f['change'].toString();
                final changeVal =
                    double.tryParse(
                      changeStr.replaceAll('%', '').replaceAll('+', ''),
                    ) ??
                    0.0;
                return sum + changeVal;
              }) /
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
            fontFamily: 'Poppins',
            fontSize: 20,
          ),
        ),
        backgroundColor: primaryGreen,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadFavorites,
          ),
        ],
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
                    // Header dengan gradient
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

                    // Content area
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

    return Column(
      children: [
        Container(
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
        ),
        if (favorites.isNotEmpty) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('Clear All Favorites'),
                    content: const Text(
                      'Are you sure you want to remove all favorites?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await FavoriteManager.clearAllFavorites();
                  setState(() => favorites.clear());
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ All favorites cleared'),
                        backgroundColor: primaryGreen,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 18,
              ),
              label: const Text(
                'Clear All Favorites',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _favoriteItem(Map<String, dynamic> f) {
    final changeStr = f['change'].toString();
    final changeVal =
        double.tryParse(changeStr.replaceAll('%', '').replaceAll('+', '')) ??
        0.0;
    final isUp = f['isUp'] == true;
    final color = isUp ? Colors.green : Colors.red;
    final icon = isUp ? Icons.arrow_upward : Icons.arrow_downward;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          // Navigate to detail
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailRatePage(rateData: f)),
          );
          // Refresh after coming back
          _loadFavorites();
        },
        onLongPress: () async {
          // Show delete dialog
          final shouldRemove = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Remove from Favorites'),
              content: Text(
                'Do you want to remove ${f['currency']} from your favorites?',
              ),
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

          if (shouldRemove == true) {
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
