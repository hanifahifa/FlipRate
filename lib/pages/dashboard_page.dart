// ------------------------------------------------------
// DASHBOARD PAGE - FlipRate (SF Pro Version)
// ------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now());

    final popularRates = [
      {
        'pair': 'USD → IDR',
        'value': 'Rp17,432',
        'change': '+0.3%',
        'isUp': true,
        'flag': '🇺🇸',
      },
      {
        'pair': 'EUR → IDR',
        'value': 'Rp18,850',
        'change': '+0.2%',
        'isUp': true,
        'flag': '🇪🇺',
      },
      {
        'pair': 'JPY → IDR',
        'value': 'Rp115',
        'change': '-0.1%',
        'isUp': false,
        'flag': '🇯🇵',
      },
      {
        'pair': 'SGD → IDR',
        'value': 'Rp11,450',
        'change': '+0.5%',
        'isUp': true,
        'flag': '🇸🇬',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF388E3C), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'FlipRate',
          style: TextStyle(
            fontFamily: 'SF Pro',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.white),
          SizedBox(width: 12),
        ],
      ),
      body: DefaultTextStyle(
        style: const TextStyle(fontFamily: 'SF Pro'),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Greeting & Date
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(99, 45, 120, 33),
                    Color.fromARGB(48, 46, 125, 50),
                    Color.fromARGB(48, 46, 125, 50),
                    Color.fromARGB(47, 255, 255, 255),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      255,
                      2,
                      125,
                      0,
                    ).withOpacity(0.28),
                    blurRadius: 14,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: const Color(0xFFFFF9C4).withOpacity(0.18),
                    blurRadius: 28,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hello, welcome back!',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    today,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Exchange Chart
            _chartCard(),

            const SizedBox(height: 16),

            // Quick Access
            _quickAccessCard(),

            const SizedBox(height: 16),

            // Popular Rates
            _popularRatesCard(popularRates),

            const SizedBox(height: 20),
            Center(
              child: Text(
                '© 2025 FlipRate — Smart Currency Converter',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ---------------- WIDGETS ----------------

  Widget _chartCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.show_chart, color: Color(0xFF2E7D32)),
                SizedBox(width: 6),
                Text(
                  'Exchange Rate Movement (USD → IDR)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 17400),
                        FlSpot(1, 17360),
                        FlSpot(2, 17432),
                      ],
                      isCurved: true,
                      color: const Color(0xFF2E7D32),
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF2E7D32).withOpacity(0.3),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Insight: Rupiah weakened 0.3% against USD compared to yesterday.',
              style: TextStyle(color: Colors.black87, fontSize: 13.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAccessCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bolt_rounded, color: Color(0xFF2E7D32)),
                SizedBox(width: 6),
                Text(
                  'Quick Access',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _quickButton(Icons.currency_exchange, 'All Rates'),
                _quickButton(Icons.analytics_outlined, 'Analysis'),
                _quickButton(Icons.swap_horiz, 'Conversion'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickButton(IconData icon, String title) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: const Color(0xFF2E7D32), size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _popularRatesCard(List<Map<String, Object>> popularRates) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.star_rounded, color: Color(0xFF2E7D32)),
                SizedBox(width: 6),
                Text(
                  'Popular Rates Today',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: popularRates.length,
              separatorBuilder: (context, _) => const Divider(thickness: 0.5),
              itemBuilder: (context, i) {
                final data = popularRates[i];
                return _currencyListTile(
                  data['pair'] as String,
                  data['value'] as String,
                  data['change'] as String,
                  data['isUp'] as bool,
                  data['flag'] as String,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _currencyListTile(
    String pair,
    String value,
    String change,
    bool isUp,
    String flag,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      leading: Text(flag, style: const TextStyle(fontSize: 26)),
      title: Text(
        pair,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 14, color: Colors.black54),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.arrow_upward : Icons.arrow_downward,
            color: isUp ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            change,
            style: TextStyle(
              color: isUp ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
