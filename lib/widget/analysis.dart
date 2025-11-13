// ------------------------------------------------------
// ANALYSIS PAGE - FlipRate (SF Pro Edition)
// Market News, Top Performers, Predictions
// IMPROVED UI WITH BETTER SPACING & VISUAL HIERARCHY
// ------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFFF1F8E9);
  static const Color accentGreen = Color(0xFFDDE8D4);

  List<Map<String, dynamic>> topGainers = [];
  List<Map<String, dynamic>> topLosers = [];
  Map<String, dynamic> predictions = {};
  bool isLoading = true;
  String errorMessage = '';

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

  final List<Map<String, dynamic>> marketInsights = [
    {
      'icon': Icons.trending_up,
      'color': Colors.green,
      'title': 'US Dollar Strengthens',
      'subtitle': 'Fed maintains interest rates, boosting USD confidence',
      'time': '2 hours ago',
    },
    {
      'icon': Icons.info_outline,
      'color': Colors.blue,
      'title': 'Asian Markets Update',
      'subtitle':
          'SGD and JPY show moderate volatility amid regional trade talks',
      'time': '5 hours ago',
    },
    {
      'icon': Icons.warning_amber_rounded,
      'color': Colors.orange,
      'title': 'EUR Under Pressure',
      'subtitle': 'European Central Bank signals potential rate adjustments',
      'time': '1 day ago',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadAnalysisData();
  }

  Future<void> _loadAnalysisData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      await _fetchTopPerformers();
      _calculatePredictions();
      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load analysis data';
      });
    }
  }

  Future<void> _fetchTopPerformers() async {
    final apis = [
      'https://api.exchangerate-api.com/v4/latest/USD',
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json',
      'https://api.frankfurter.app/latest?from=USD',
    ];

    Map<String, double> yesterdayRates = await _fetchYesterdayRates();

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

        List<Map<String, dynamic>> allCurrencies = [];

        for (var entry in rates.entries) {
          final cur = entry.key.toUpperCase();
          if (cur == 'IDR' || !currencyFlags.containsKey(cur)) continue;

          final curToUsd = (entry.value as num).toDouble();
          final curToIdr = idrRate / curToUsd;

          double changePercent = 0.0;
          if (yesterdayRates.containsKey(cur) &&
              yesterdayRates.containsKey('IDR')) {
            final yesterdayCurToIdr =
                yesterdayRates['IDR']! / yesterdayRates[cur]!;
            changePercent =
                ((curToIdr - yesterdayCurToIdr) / yesterdayCurToIdr) * 100;
          }

          allCurrencies.add({
            'currency': cur,
            'name': currencyNames[cur] ?? cur,
            'flag': currencyFlags[cur] ?? '🏳️',
            'rate': curToIdr,
            'change': changePercent,
          });
        }

        allCurrencies.sort(
          (a, b) => (b['change'] as double).compareTo(a['change'] as double),
        );

        setState(() {
          topGainers = allCurrencies
              .where((c) => c['change'] > 0)
              .take(5)
              .toList();
          topLosers = allCurrencies
              .where((c) => c['change'] < 0)
              .toList()
              .reversed
              .take(5)
              .toList();
        });

        return;
      } catch (e) {
        if (i == apis.length - 1) {
          throw Exception('Failed to fetch rates');
        }
      }
    }
  }

  Future<Map<String, double>> _fetchYesterdayRates() async {
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
        final res = await http.get(Uri.parse(url));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['rates'] != null && data['rates'].isNotEmpty) {
            return Map<String, double>.from(
              data['rates'].map(
                (k, v) =>
                    MapEntry(k.toString().toUpperCase(), (v as num).toDouble()),
              ),
            );
          }
        }
      } catch (e) {
        debugPrint("⚠️ Error fetching yesterday rates: $e");
      }
    }
    return {};
  }

  void _calculatePredictions() {
    if (topGainers.isEmpty && topLosers.isEmpty) return;

    Map<String, dynamic> preds = {};
    final List<String> mainCurrencies = ['USD', 'EUR', 'JPY', 'SGD'];

    for (String cur in mainCurrencies) {
      var data = topGainers.firstWhere(
        (c) => c['currency'] == cur,
        orElse: () => topLosers.firstWhere(
          (c) => c['currency'] == cur,
          orElse: () => {'currency': cur, 'change': 0.0},
        ),
      );

      final double change = data['change'] ?? 0.0;
      String trend;
      String confidence;
      String text;

      if (change > 1.0) {
        trend = 'up';
        confidence = 'high';
        text = 'Strong upward momentum';
      } else if (change > 0.3) {
        trend = 'up';
        confidence = 'moderate';
        text = 'Likely to strengthen';
      } else if (change < -1.0) {
        trend = 'down';
        confidence = 'high';
        text = 'Significant downward pressure';
      } else if (change < -0.3) {
        trend = 'down';
        confidence = 'moderate';
        text = 'May weaken slightly';
      } else {
        trend = 'stable';
        confidence = 'high';
        text = 'Expected to remain stable';
      }

      preds[cur] = {
        'trend': trend,
        'confidence': confidence,
        'text': text,
        'change': change,
      };
    }

    setState(() => predictions = preds);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(fontFamily: 'SF Pro'),
      child: Scaffold(
        backgroundColor: lightGreen,
        appBar: AppBar(
          title: const Text(
            'Market Analysis',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'SF Pro',
              fontSize: 20,
            ),
          ),
          backgroundColor: primaryGreen,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadAnalysisData,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadAnalysisData,
          color: primaryGreen,
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: primaryGreen),
                )
              : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(errorMessage, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAnalysisData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header dengan gradient
                      _buildHeader(),
                      const SizedBox(height: 24),

                      // 1. MARKET NEWS
                      _buildSectionTitle(
                        'Market News & Insights',
                        Icons.newspaper,
                      ),
                      const SizedBox(height: 12),
                      _buildMarketNews(),
                      const SizedBox(height: 24),

                      // 2. TOP PERFORMERS
                      _buildSectionTitle(
                        'Top Performers (24h)',
                        Icons.trending_up,
                      ),
                      const SizedBox(height: 12),
                      _buildTopPerformersSection(),
                      const SizedBox(height: 24),

                      // 3. PREDICTIONS
                      _buildSectionTitle('Market Predictions', Icons.insights),
                      const SizedBox(height: 12),
                      _buildPredictionsSection(),
                      const SizedBox(height: 24),

                      // Disclaimer
                      _buildDisclaimer(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryGreen, primaryGreen.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Currency Market Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'SF Pro',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white70, size: 14),
              const SizedBox(width: 6),
              Text(
                DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()),
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  fontFamily: 'SF Pro',
                ),
              ),
            ],
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

  Widget _buildMarketNews() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: marketInsights.asMap().entries.map((entry) {
          final index = entry.key;
          final insight = entry.value;
          final isLast = index == marketInsights.length - 1;

          return Column(
            children: [
              _newsItem(
                insight['icon'],
                insight['color'],
                insight['title'],
                insight['subtitle'],
                insight['time'],
              ),
              if (!isLast)
                Divider(height: 1, indent: 68, color: Colors.grey[200]),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _newsItem(
    IconData icon,
    Color color,
    String title,
    String subtitle,
    String time,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: 'SF Pro',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.3,
                    fontFamily: 'SF Pro',
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
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
    );
  }

  Widget _buildTopPerformersSection() {
    if (topGainers.isEmpty && topLosers.isEmpty) {
      return _buildEmptyState('No performance data available');
    }

    return Column(
      children: [
        if (topGainers.isNotEmpty) ...[
          _buildPerformerCard('🏆 Top Gainers', topGainers, Colors.green),
          const SizedBox(height: 16),
        ],
        if (topLosers.isNotEmpty)
          _buildPerformerCard('📉 Biggest Losers', topLosers, Colors.red),
      ],
    );
  }

  Widget _buildPerformerCard(
    String title,
    List<Map<String, dynamic>> data,
    Color accentColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: accentColor,
                fontFamily: 'SF Pro',
              ),
            ),
          ),
          ...data.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == data.length - 1;

            return Column(
              children: [
                if (index > 0)
                  Divider(height: 1, indent: 68, color: Colors.grey[200]),
                _performerItem(item, index + 1, accentColor),
              ],
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _performerItem(
    Map<String, dynamic> item,
    int rank,
    Color accentColor,
  ) {
    final change = item['change'] as double;
    final isPositive = change >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                  fontSize: 14,
                  fontFamily: 'SF Pro',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(item['flag'], style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['currency'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: 'SF Pro',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['name'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'SF Pro',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: accentColor,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
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

  Widget _buildPredictionsSection() {
    if (predictions.isEmpty) {
      return _buildEmptyState('Calculating predictions...');
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: predictions.entries.map((entry) {
          return _predictionItem(
            entry.key,
            currencyNames[entry.key] ?? entry.key,
            currencyFlags[entry.key] ?? '🏳️',
            entry.value['trend'],
            entry.value['text'],
            entry.value['confidence'],
          );
        }).toList(),
      ),
    );
  }

  Widget _predictionItem(
    String currency,
    String name,
    String flag,
    String trend,
    String text,
    String confidence,
  ) {
    Color trendColor;
    IconData trendIcon;

    if (trend == 'up') {
      trendColor = Colors.green;
      trendIcon = Icons.trending_up;
    } else if (trend == 'down') {
      trendColor = Colors.red;
      trendIcon = Icons.trending_down;
    } else {
      trendColor = Colors.grey;
      trendIcon = Icons.trending_flat;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(flag, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      currency,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'SF Pro',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: trendColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(trendIcon, size: 12, color: trendColor),
                          const SizedBox(width: 4),
                          Text(
                            trend.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: trendColor,
                              fontFamily: 'SF Pro',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.3,
                    fontFamily: 'SF Pro',
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.insights, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      'Confidence: $confidence',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
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
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.analytics_outlined, size: 52, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'SF Pro',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.25), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Disclaimer: Predictions are for reference only and not financial advice. Always do your own research before making decisions.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                height: 1.4,
                fontFamily: 'SF Pro',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
