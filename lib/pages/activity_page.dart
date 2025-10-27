// ------------------------------------------------------
// ACTIVITY PAGE - FlipRate (Fixed Spacing)
// ------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  final List<Map<String, dynamic>> conversionHistory = [
    {
      'fromAmount': 10,
      'fromCode': 'USD',
      'toAmount': 174320,
      'toCode': 'IDR',
      'time': DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
    },
    {
      'fromAmount': 5,
      'fromCode': 'EUR',
      'toAmount': 87000,
      'toCode': 'IDR',
      'time': DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    },
    {
      'fromAmount': 200,
      'fromCode': 'JPY',
      'toAmount': 1740,
      'toCode': 'IDR',
      'time': DateTime.now().subtract(const Duration(days: 2, hours: 6)),
    },
  ];

  final List<Map<String, dynamic>> recentlyViewed = [
    {
      'pair': 'JPY → IDR',
      'when': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'pair': 'SGD → IDR',
      'when': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    },
    {
      'pair': 'AUD → IDR',
      'when': DateTime.now().subtract(const Duration(days: 3)),
    },
  ];

  String buildInsight() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreen,
      appBar: AppBar(
        title: const Text(
          'My Activity',
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
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
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
                    DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()),
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
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

                  _buildSectionTitle('Conversion History', Icons.history),
                  const SizedBox(height: 12),
                  _buildHistorySection(),

                  const SizedBox(height: 20),

                  _buildSectionTitle(
                    'Currency Portfolio',
                    Icons.account_balance_wallet,
                  ),
                  const SizedBox(height: 12),
                  _buildPortfolioSection(context),

                  // Padding bawah agar tidak tertutup navbar
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- INSIGHT CARD ----------
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

  // ---------- SECTION TITLE ----------
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

  // ---------- PORTFOLIO SECTION ----------
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

  // ---------- HISTORY SECTION ----------
  Widget _buildHistorySection() {
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
                      // Icon circle
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
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

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Currency pair
                            Row(
                              children: [
                                Text(
                                  '${c['fromAmount']} ${c['fromCode']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black87,
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
                                  '${c['toAmount']} ${c['toCode']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Time
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
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Arrow icon
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

  // ---------- RECENTLY VIEWED SECTION ----------
  Widget _buildRecentlyViewedSection() {
    return SizedBox(
      height: 85,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recentlyViewed.length,
        itemBuilder: (context, index) {
          final r = recentlyViewed[index];
          final pair = r['pair'] as String;
          final when = r['when'] as DateTime;

          // dummy data rate dan bendera
          final info = {
            'JPY → IDR': {'rate': '≈ Rp115', 'flag': '🇯🇵'},
            'SGD → IDR': {'rate': '≈ Rp11.450', 'flag': '🇸🇬'},
            'AUD → IDR': {'rate': '≈ Rp10.300', 'flag': '🇦🇺'},
          };

          final item = info[pair];

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
                      // Bendera
                      Text(
                        item?['flag'] ?? '🌍',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),

                      // Info kurs
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
                              ),
                            ),
                            Text(
                              item?['rate'] ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
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

  // ---------- MINI PORTFOLIO CARD ----------
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
                  child: Text(flag, style: const TextStyle(fontSize: 22)),
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
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Today',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
