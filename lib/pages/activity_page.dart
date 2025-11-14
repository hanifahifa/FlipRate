// ------------------------------------------------------
// ACTIVITY PAGE - FlipRate (SF Pro Edition)
// (Realtime Exchange Rate via open.er-api.com)
// dengan History Manager & Real Data + See More
// FIXED: Insight logic yang lebih akurat
// ------------------------------------------------------

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
// Import HistoryManager (sesuaikan path-nya)
import '../utils/history_manager.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFFF1F8E9);
  static const Color accentGreen = Color(0xFFDDE8D4);

  List<Map<String, dynamic>> conversionHistory = [];
  List<Map<String, dynamic>> recentlyViewed = [];
  bool isLoading = true;

  // State untuk expand/collapse
  bool showAllHistory = false;
  bool showAllRecentlyViewed = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<double> fetchExchangeRate(String from, String to) async {
    try {
      final url = Uri.parse('https://open.er-api.com/v6/latest/$from');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] == 'success' && data['rates'][to] != null) {
          return (data['rates'][to] as num).toDouble();
        }
      }
    } catch (e) {
      debugPrint('Error fetching rate $from->$to: $e');
    }
    return 0.0;
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    // Load conversion history dari SharedPreferences
    await _loadConversionHistory();

    // Load recently viewed dari HistoryManager
    await _loadRecentlyViewed();

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  /// Mengambil conversion history dari HistoryManager
  Future<void> _loadConversionHistory() async {
    try {
      final history = await HistoryManager.getConversionHistory();

      if (mounted) {
        setState(() {
          conversionHistory = history;
        });
      }
    } catch (e) {
      debugPrint('Error loading conversion history: $e');
      if (mounted) {
        setState(() {
          conversionHistory = [];
        });
      }
    }
  }

  /// Mengambil recently viewed dari HistoryManager
  Future<void> _loadRecentlyViewed() async {
    try {
      final viewed = await HistoryManager.getRecentlyViewed();
      final List<Map<String, dynamic>> tempViewed = [];

      // Process data tanpa setState di dalam loop
      for (final item in viewed) {
        if (!mounted) break; // Stop jika widget sudah di-dispose

        final from = item['from'] as String;
        final to = item['to'] as String;
        final dt = item['time'] as DateTime;

        // Fetch rate untuk recently viewed
        final rate = await fetchExchangeRate(from, to);

        tempViewed.add({
          'pair': '$from → $to',
          'when': dt,
          'from': from,
          'to': to,
          'rate': rate,
        });
      }

      // setState hanya sekali setelah semua data selesai di-load
      if (mounted) {
        setState(() {
          recentlyViewed = tempViewed;
        });
      }
    } catch (e) {
      debugPrint('Error loading recently viewed: $e');
      if (mounted) {
        setState(() {
          recentlyViewed = [];
        });
      }
    }
  }

  String buildInsight() {
    if (conversionHistory.isEmpty) {
      return 'Start converting currencies to get personalized insights.';
    }

    // Hitung frekuensi semua currency (dari fromCode dan toCode)
    Map<String, int> currencyCount = {};

    for (var conversion in conversionHistory) {
      final fromCode = conversion['fromCode'] as String;
      final toCode = conversion['toCode'] as String;

      // Hitung fromCode
      currencyCount[fromCode] = (currencyCount[fromCode] ?? 0) + 1;

      // Hitung toCode
      currencyCount[toCode] = (currencyCount[toCode] ?? 0) + 1;
    }

    // Cari currency yang paling sering digunakan
    String mostUsedCurrency = '';
    int maxCount = 0;

    currencyCount.forEach((currency, count) {
      if (count > maxCount) {
        maxCount = count;
        mostUsedCurrency = currency;
      }
    });

    // Generate insight berdasarkan currency yang paling sering
    if (mostUsedCurrency.isNotEmpty) {
      // Hitung berapa kali currency ini dikonversi
      final conversionCount = conversionHistory.length;

      if (mostUsedCurrency == 'AED') {
        return 'You converted $mostUsedCurrency $conversionCount times — UAE Dirham shows consistent activity!';
      } else if (mostUsedCurrency == 'USD') {
        return 'You converted USD $conversionCount times — monitor US Dollar volatility for better rates.';
      } else if (mostUsedCurrency == 'EUR') {
        return 'You converted EUR $conversionCount times — Euro rates are fluctuating this week.';
      } else if (mostUsedCurrency == 'IDR') {
        return 'You converted IDR $conversionCount times — great for managing local transactions!';
      } else if (mostUsedCurrency == 'JPY') {
        return 'You converted JPY $conversionCount times — Japanese Yen activity detected.';
      } else if (mostUsedCurrency == 'AUD') {
        return 'You converted AUD $conversionCount times — Australian Dollar is your focus currency.';
      } else {
        return 'You converted $mostUsedCurrency $conversionCount times — stay updated on its exchange trends.';
      }
    }

    // Fallback: cek recently viewed (jarang terjadi)
    if (recentlyViewed.isNotEmpty) {
      final recentPair = recentlyViewed.first['pair'] as String;
      return 'You recently viewed $recentPair rates — check back for updates.';
    }

    // Seharusnya tidak pernah sampai sini karena ada conversionHistory
    return 'Start tracking more currencies to get better insights.';
  }

  String formatDateTimeShort(DateTime dt) =>
      DateFormat('dd MMM yyyy, HH:mm').format(dt);

  String relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    if (diff.inDays == 1) return 'yesterday';
    return '${diff.inDays} days ago';
  }

  String _getFlag(String currencyCode) {
    final flags = {
      'USD': '🇺🇸',
      'EUR': '🇪🇺',
      'JPY': '🇯🇵',
      'GBP': '🇬🇧',
      'AUD': '🇦🇺',
      'CAD': '🇨🇦',
      'CHF': '🇨🇭',
      'CNY': '🇨🇳',
      'SGD': '🇸🇬',
      'IDR': '🇮🇩',
      'MYR': '🇲🇾',
      'THB': '🇹🇭',
      'KRW': '🇰🇷',
      'INR': '🇮🇳',
      'AED': '🇦🇪',
    };
    return flags[currencyCode.toUpperCase()] ?? '🌍';
  }

  String _formatRate(double rate) {
    if (rate >= 1000) {
      return '≈ Rp${NumberFormat('#,###', 'id_ID').format(rate.round())}';
    } else if (rate >= 1) {
      return '≈ Rp${rate.toStringAsFixed(0)}';
    } else {
      return '≈ Rp${rate.toStringAsFixed(2)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(fontFamily: 'SF Pro'),
      child: Scaffold(
        backgroundColor: lightGreen,
        appBar: AppBar(
          title: const Text(
            'My Activity',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'SF Pro',
              fontSize: 20,
            ),
          ),
          backgroundColor: primaryGreen,
          elevation: 0,
          centerTitle: false,
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: primaryGreen),
              )
            : RefreshIndicator(
                onRefresh: _loadAllData,
                color: primaryGreen,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header gradient
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryGreen,
                              primaryGreen.withOpacity(0.8),
                            ],
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
                                fontFamily: 'SF Pro',
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
                            _buildSectionTitle(
                              'Recently Viewed',
                              Icons.remove_red_eye_outlined,
                            ),
                            const SizedBox(height: 12),
                            _buildRecentlyViewedSection(),
                            const SizedBox(height: 20),

                            _buildSectionTitle(
                              'Conversion History',
                              Icons.history,
                            ),
                            const SizedBox(height: 12),
                            _buildHistorySection(),

                            // PADDING BOTTOM agar tidak tertutup navbar
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ],
                  ),
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
              color: const Color.fromARGB(18, 243, 255, 14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: Color.fromARGB(255, 255, 242, 0),
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
                    fontFamily: 'SF Pro',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  buildInsight(),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                    fontFamily: 'SF Pro',
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
            fontFamily: 'SF Pro',
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    if (conversionHistory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.history, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'No conversion history yet',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontFamily: 'SF Pro',
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Tampilkan 4 item pertama atau semua jika showAllHistory true
    final displayedHistory = showAllHistory
        ? conversionHistory
        : conversionHistory.take(4).toList();

    return Column(
      children: [
        ...displayedHistory.asMap().entries.map((entry) {
          final index = entry.key;
          final c = entry.value;
          final isLast = index == displayedHistory.length - 1;

          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: accentGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.swap_horiz_rounded,
                            color: primaryGreen,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${c['fromAmount']} ${c['fromCode']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black87,
                                      fontFamily: 'SF Pro',
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward,
                                      size: 14,
                                      color: primaryGreen,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      '${NumberFormat('#,###', 'id_ID').format(c['toAmount'])} ${c['toCode']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: primaryGreen,
                                        fontFamily: 'SF Pro',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 12,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    relativeTime(c['time'] as DateTime),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontFamily: 'SF Pro',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey[400],
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),

        // See More Button untuk History
        if (conversionHistory.length > 4)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: InkWell(
              onTap: () {
                setState(() {
                  showAllHistory = !showAllHistory;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryGreen.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      showAllHistory
                          ? 'Show Less'
                          : 'See More (${conversionHistory.length - 4}+)',
                      style: const TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'SF Pro',
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      showAllHistory
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: primaryGreen,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentlyViewedSection() {
    if (recentlyViewed.isEmpty) {
      return Container(
        height: 85,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            'No recently viewed currencies',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              fontFamily: 'SF Pro',
            ),
          ),
        ),
      );
    }

    // Tampilkan 3 item pertama atau semua jika showAllRecentlyViewed true
    final displayedViewed = showAllRecentlyViewed
        ? recentlyViewed
        : recentlyViewed.take(3).toList();

    return Column(
      children: [
        SizedBox(
          height: 85,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount:
                displayedViewed.length +
                (recentlyViewed.length > 3 && !showAllRecentlyViewed ? 1 : 0),
            itemBuilder: (context, index) {
              // Show "See More" button as last item jika ada lebih dari 3
              if (!showAllRecentlyViewed &&
                  recentlyViewed.length > 3 &&
                  index == 3) {
                return Padding(
                  padding: const EdgeInsets.only(right: 0),
                  child: InkWell(
                    onTap: () {
                      if (mounted) {
                        setState(() {
                          showAllRecentlyViewed = true;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 80,
                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: primaryGreen.withOpacity(0.3),
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_forward,
                            color: primaryGreen,
                            size: 24,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'See\nMore',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: primaryGreen,
                              fontFamily: 'SF Pro',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final r = displayedViewed[index];
              final pair = r['pair'] as String;
              final when = r['when'] as DateTime;
              final from = r['from'] as String;
              final rate = r['rate'] as double;

              return Padding(
                padding: EdgeInsets.only(
                  right:
                      index < displayedViewed.length - 1 ||
                          (!showAllRecentlyViewed && recentlyViewed.length > 3)
                      ? 10
                      : 0,
                ),
                child: Container(
                  width: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB9DDB5),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _getFlag(from),
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  pair,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    fontFamily: 'SF Pro',
                                  ),
                                ),
                                Text(
                                  rate > 0 ? _formatRate(rate) : 'Loading...',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                    fontFamily: 'SF Pro',
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.schedule_rounded,
                                      size: 11,
                                      color: Colors.black54,
                                    ),
                                    const SizedBox(width: 3),
                                    Flexible(
                                      child: Text(
                                        relativeTime(when),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black54,
                                          fontFamily: 'SF Pro',
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Show Less Button untuk Recently Viewed (jika sudah expand)
        if (showAllRecentlyViewed && recentlyViewed.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: InkWell(
              onTap: () {
                if (mounted) {
                  setState(() {
                    showAllRecentlyViewed = false;
                  });
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryGreen.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Show Less',
                      style: TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'SF Pro',
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.keyboard_arrow_up,
                      color: primaryGreen,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
