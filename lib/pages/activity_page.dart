// ------------------------------------------------------
// ACTIVITY PAGE - FlipRate (SF Pro Edition)
// (Realtime Exchange Rate via open.er-api.com)
// dengan History Manager & Real Data
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

  final List<Map<String, dynamic>> portfolio = [
    {'pair': 'USD → IDR', 'change': 0.4, 'flag': '🇺🇸', 'isUp': true},
    {'pair': 'EUR → IDR', 'change': -0.2, 'flag': '🇪🇺', 'isUp': false},
    {'pair': 'SGD → IDR', 'change': 0.5, 'flag': '🇸🇬', 'isUp': true},
  ];

  List<Map<String, dynamic>> conversionHistory = [];
  List<Map<String, dynamic>> recentlyViewed = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<double> fetchExchangeRate(String from, String to) async {
    try {
      final url = Uri.parse('https://open.er-api.com/v6/latest/$from');
      final response = await http.get(url);

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
    setState(() => isLoading = true);

    // Load conversion history dari SharedPreferences
    await _loadConversionHistory();

    // Load recently viewed dari HistoryManager
    await _loadRecentlyViewed();

    setState(() => isLoading = false);
  }

  /// Mengambil conversion history dari HistoryManager
  Future<void> _loadConversionHistory() async {
    try {
      final history = await HistoryManager.getConversionHistory();

      setState(() {
        conversionHistory = history;
      });
    } catch (e) {
      debugPrint('Error loading conversion history: $e');
      setState(() {
        conversionHistory = [];
      });
    }
  }

  /// Mengambil recently viewed dari HistoryManager
  Future<void> _loadRecentlyViewed() async {
    try {
      final viewed = await HistoryManager.getRecentlyViewed();
      final List<Map<String, dynamic>> tempViewed = [];

      for (final item in viewed) {
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

      setState(() {
        recentlyViewed = tempViewed;
      });
    } catch (e) {
      debugPrint('Error loading recently viewed: $e');
      setState(() {
        recentlyViewed = [];
      });
    }
  }

  String buildInsight() {
    if (conversionHistory.isEmpty) {
      return 'Start converting currencies to get personalized insights.';
    }

    final usdCount = conversionHistory
        .where((c) => c['fromCode'] == 'USD')
        .length;
    final recentMostViewed = recentlyViewed.isNotEmpty
        ? recentlyViewed.first['pair']
        : '';

    if (usdCount >= 1) {
      return 'You frequently converted USD this week — monitor short-term volatility.';
    } else if (recentMostViewed.contains('EUR')) {
      return 'You often viewed EUR — watch for EUR → IDR movements in the coming days.';
    } else {
      return 'Monitor the currencies in your portfolio to minimize risks.';
    }
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
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header gradient
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
                          const SizedBox(height: 20),

                          _buildSectionTitle(
                            'Currency Portfolio',
                            Icons.account_balance_wallet,
                          ),
                          const SizedBox(height: 12),
                          _buildPortfolioSection(context),
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

  Widget _buildPortfolioSection(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: portfolio.length,
      itemBuilder: (context, index) {
        final p = portfolio[index];
        return _miniPortfolioCard(
          p['flag'] as String,
          p['pair'] as String,
          (p['change'] as num).toDouble(),
          p['isUp'] as bool,
        );
      },
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

    return Column(
      children: conversionHistory.asMap().entries.map((entry) {
        final index = entry.key;
        final c = entry.value;
        final isLast = index == conversionHistory.length - 1;

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
                                  padding: EdgeInsets.symmetric(horizontal: 6),
                                  child: Icon(
                                    Icons.arrow_forward,
                                    size: 14,
                                    color: primaryGreen,
                                  ),
                                ),
                                Text(
                                  '${NumberFormat('#,###', 'id_ID').format(c['toAmount'])} ${c['toCode']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: primaryGreen,
                                    fontFamily: 'SF Pro',
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
      }).toList(),
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

    return SizedBox(
      height: 85,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recentlyViewed.length,
        itemBuilder: (context, index) {
          final r = recentlyViewed[index];
          final pair = r['pair'] as String;
          final when = r['when'] as DateTime;
          final from = r['from'] as String;
          final rate = r['rate'] as double;

          return Padding(
            padding: EdgeInsets.only(
              right: index < recentlyViewed.length - 1 ? 10 : 0,
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
                                Text(
                                  relativeTime(when),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                    fontFamily: 'SF Pro',
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
    );
  }

  Widget _miniPortfolioCard(
    String flag,
    String pair,
    double change,
    bool isUp,
  ) {
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
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    flag,
                    style: const TextStyle(fontSize: 22, fontFamily: 'SF Pro'),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isUp
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isUp ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 12,
                      color: isUp ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${change.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: isUp ? Colors.green : Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF Pro',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pair,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'SF Pro',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Today',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontFamily: 'SF Pro',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
