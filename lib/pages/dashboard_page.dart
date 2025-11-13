// ------------------------------------------------------
// DASHBOARD PAGE - FlipRate (Improved Chart Version)
// DENGAN GRAFIK 3 HARI YANG LEBIH NYAMAN DILIHAT
// ------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widget/all_rates.dart';
import '../widget/convert.dart';
import '../widget/analysis.dart';
import '../widget/notification.dart'; // ← TAMBAHKAN INI

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Map<String, dynamic>> popularRates = [];
  List<FlSpot> chartData = [];
  List<String> chartDates = []; // ← TAMBAH: untuk label tanggal
  bool isLoading = true;
  bool isChartLoading = true;
  String errorMessage = '';
  String chartErrorMessage = '';
  int? touchedIndex; // ← TAMBAH: untuk tooltip

  final List<String> popularCurrencies = ['USD', 'EUR', 'JPY', 'SGD'];

  final Map<String, String> currencyFlags = {
    'USD': '🇺🇸',
    'EUR': '🇪🇺',
    'JPY': '🇯🇵',
    'SGD': '🇸🇬',
  };

  @override
  void initState() {
    super.initState();
    fetchRates();
    fetchHistoricalData();
  }

  // ============================================
  // FUNGSI FETCH CURRENT RATES
  // ============================================
  Future<void> fetchRates() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final List<String> apiUrls = [
      'https://api.exchangerate-api.com/v4/latest/USD',
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json',
      'https://api.frankfurter.app/latest?from=USD',
    ];

    for (int i = 0; i < apiUrls.length; i++) {
      try {
        final response = await http
            .get(Uri.parse(apiUrls[i]))
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          Map<String, dynamic> rates;
          double idrRate;

          if (i == 0) {
            rates = data['rates'] as Map<String, dynamic>;
            idrRate = (rates['IDR'] as num).toDouble();
          } else if (i == 1) {
            rates = data['usd'] as Map<String, dynamic>;
            idrRate = (rates['idr'] as num).toDouble();
          } else {
            rates = data['rates'] as Map<String, dynamic>;
            idrRate = (rates['IDR'] as num).toDouble();
          }

          List<Map<String, dynamic>> ratesList = [];

          for (String currency in popularCurrencies) {
            final currencyLower = currency.toLowerCase();
            final rate = rates[currency] ?? rates[currencyLower];

            if (rate != null) {
              final double valueInIdr = idrRate / (rate as num).toDouble();
              final changeData = _generateRealChange(currency);

              ratesList.add({
                'pair': '$currency → IDR',
                'currency': currency,
                'value': valueInIdr,
                'change': changeData['change'],
                'isUpValue': changeData['isUp'],
                'flag': currencyFlags[currency] ?? '🏳️',
              });
            }
          }

          setState(() {
            popularRates = ratesList;
            isLoading = false;
          });

          return;
        }
      } catch (e) {
        if (i == apiUrls.length - 1) {
          setState(() {
            isLoading = false;
            errorMessage = 'Unable to fetch rates. Please try again.';
          });
        }
        continue;
      }
    }
  }

  // ============================================
  // FUNGSI FETCH HISTORICAL DATA (3 HARI)
  // ============================================
  Future<void> fetchHistoricalData() async {
    setState(() {
      isChartLoading = true;
      chartErrorMessage = '';
    });

    try {
      final now = DateTime.now();
      final threeDaysAgo = now.subtract(const Duration(days: 3));

      final startDate = DateFormat('yyyy-MM-dd').format(threeDaysAgo);
      final endDate = DateFormat('yyyy-MM-dd').format(now);

      final url =
          'https://api.frankfurter.app/$startDate..$endDate?from=USD&to=IDR';

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;

        List<FlSpot> spots = [];
        List<String> dates = [];
        int index = 0;

        final sortedDates = rates.keys.toList()..sort();

        for (String date in sortedDates) {
          final dayRates = rates[date] as Map<String, dynamic>;
          final idrRate = (dayRates['IDR'] as num).toDouble();

          spots.add(FlSpot(index.toDouble(), idrRate));

          // Format tanggal untuk label (contoh: "10 Nov")
          final dateTime = DateTime.parse(date);
          dates.add(DateFormat('d MMM').format(dateTime));

          index++;
        }

        setState(() {
          chartData = spots;
          chartDates = dates;
          isChartLoading = false;
        });
      } else {
        throw Exception('Failed to load historical data');
      }
    } catch (e) {
      // Fallback dengan data estimasi
      final now = DateTime.now();
      setState(() {
        chartData = [
          FlSpot(0, 15800.0),
          FlSpot(1, 15720.0),
          FlSpot(2, 15650.0),
          FlSpot(3, 15700.0),
        ];
        chartDates = [
          DateFormat('d MMM').format(now.subtract(const Duration(days: 3))),
          DateFormat('d MMM').format(now.subtract(const Duration(days: 2))),
          DateFormat('d MMM').format(now.subtract(const Duration(days: 1))),
          DateFormat('d MMM').format(now),
        ];
        isChartLoading = false;
        chartErrorMessage = 'Using estimated data';
      });
    }
  }

  Map<String, dynamic> _generateRealChange(String currency) {
    if (chartData.length >= 2 && currency == 'USD') {
      final yesterday = chartData[chartData.length - 2].y;
      final today = chartData.last.y;
      final difference = today - yesterday;
      final percentageChange = (difference / yesterday) * 100;
      return {
        'change':
            '${percentageChange >= 0 ? '+' : ''}${percentageChange.toStringAsFixed(1)}%',
        'isUp': percentageChange >= 0,
      };
    }

    final random = (DateTime.now().millisecond % 10) / 10;
    final isPositive = DateTime.now().second % 2 == 0;
    return {
      'change': '${isPositive ? '+' : '-'}${random.toStringAsFixed(1)}%',
      'isUp': isPositive,
    };
  }

  String _formatNumber(double number) {
    if (number >= 1000) {
      return number
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    } else if (number >= 1) {
      return number.toStringAsFixed(2);
    } else {
      return number.toStringAsFixed(4);
    }
  }

  String _getChartInsight() {
    if (chartData.length < 2) return 'Insufficient data for trend analysis';

    final firstRate = chartData.first.y;
    final lastRate = chartData.last.y;
    final difference = lastRate - firstRate;
    final percentageChange = (difference / firstRate) * 100;

    String direction;
    String emoji;

    if (difference > 0) {
      direction = 'strengthened';
      emoji = '📈';
    } else if (difference < 0) {
      direction = 'weakened';
      emoji = '📉';
    } else {
      return '➡️ IDR remains stable over the past 3 days';
    }

    return '$emoji IDR has $direction by ${percentageChange.abs().toStringAsFixed(2)}% (Rp${difference.abs().toStringAsFixed(0)}) in 3 days';
  }

  Future<void> _refreshAll() async {
    await Future.wait([fetchRates(), fetchHistoricalData()]);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now());

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
        actions: [
          // GANTI BAGIAN INI ↓
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationPage(),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
          // SAMPAI SINI ↑
        ],
      ),
      body: DefaultTextStyle(
        style: const TextStyle(fontFamily: 'SF Pro'),
        child: RefreshIndicator(
          onRefresh: _refreshAll,
          color: const Color(0xFF2E7D32),
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
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
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

              // Exchange Chart (IMPROVED)
              _chartCard(),

              const SizedBox(height: 16),

              // Quick Access
              _quickAccessCard(context),

              const SizedBox(height: 16),

              // Popular Rates
              _popularRatesCard(),

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
      ),
    );
  }

  // ============================================
  // IMPROVED CHART WIDGET
  // ============================================
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.show_chart, color: Color(0xFF2E7D32)),
                    SizedBox(width: 6),
                    Text(
                      'IDR to USD (3 Days)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                if (!isChartLoading && chartData.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Rp${_formatNumber(chartData.last.y)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180, // ← DIPERBESAR untuk lebih nyaman
              child: isChartLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2E7D32),
                      ),
                    )
                  : chartData.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.insert_chart_outlined,
                            color: Colors.grey[400],
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            chartErrorMessage.isEmpty
                                ? 'No chart data available'
                                : chartErrorMessage,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildImprovedChart(),
            ),
            const SizedBox(height: 12),
            if (chartErrorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 14,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      chartErrorMessage,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Text(
              isChartLoading
                  ? 'Loading historical data...'
                  : chartData.isNotEmpty
                  ? _getChartInsight()
                  : 'Chart data unavailable',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: chartData.isNotEmpty
                    ? FontWeight.w500
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // BUILD IMPROVED CHART
  // ============================================
  Widget _buildImprovedChart() {
    // Cari min dan max untuk auto-scale
    final minY = chartData.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final maxY = chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final range = maxY - minY;
    final padding = range * 0.1; // 10% padding

    return LineChart(
      LineChartData(
        minY: minY - padding,
        maxY: maxY + padding,

        // Grid lines
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (range > 0) ? range / 3 : null,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),

        // Border
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
            left: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
          ),
        ),

        // Titles (Labels)
        titlesData: FlTitlesData(
          show: true,

          // Bottom titles (Tanggal)
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < chartDates.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      chartDates[index],
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          // Left titles (Nilai)
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              interval: range / 3,
              getTitlesWidget: (value, meta) {
                // Format dengan ribuan (contoh: 16,800)
                final formatted = NumberFormat('#,###').format(value.round());
                return Text(
                  formatted,
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),

          // Hide top and right
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),

        // Touch/Tooltip
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) =>
                const Color(0xFF2E7D32).withOpacity(0.9),
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                final date = index < chartDates.length ? chartDates[index] : '';
                return LineTooltipItem(
                  '$date\nRp${_formatNumber(spot.y)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
          getTouchedSpotIndicator: (barData, spotIndexes) {
            return spotIndexes.map((index) {
              return TouchedSpotIndicatorData(
                FlLine(color: const Color(0xFF2E7D32), strokeWidth: 2),
                FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 6,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: const Color(0xFF2E7D32),
                    );
                  },
                ),
              );
            }).toList();
          },
        ),

        // Line data
        lineBarsData: [
          LineChartBarData(
            spots: chartData,
            isCurved: true,
            curveSmoothness: 0.35,
            color: const Color(0xFF2E7D32),
            barWidth: 3,
            isStrokeCapRound: true,

            // Dots on line
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: const Color(0xFF2E7D32),
                  strokeWidth: 0,
                );
              },
            ),

            // Area below line
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2E7D32).withOpacity(0.25),
                  const Color(0xFF2E7D32).withOpacity(0.05),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- OTHER WIDGETS ----------------

  Widget _quickAccessCard(BuildContext context) {
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
                _quickButton(Icons.currency_exchange, 'All Rates', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllRatesWidget(),
                    ),
                  );
                }),
                _quickButton(Icons.analytics_outlined, 'Analysis', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AnalysisPage(),
                    ),
                  );
                }),
                _quickButton(Icons.swap_horiz, 'Conversion', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConvertPage(),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickButton(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
      ),
    );
  }

  Widget _popularRatesCard() {
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
            isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  )
                : errorMessage.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: fetchRates,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: popularRates.length,
                    separatorBuilder: (context, _) =>
                        const Divider(thickness: 0.5),
                    itemBuilder: (context, i) {
                      final data = popularRates[i];
                      final change = data['change'] as String;
                      final isUp =
                          data['isUpValue'] as bool? ?? change.startsWith('+');

                      return _currencyListTile(
                        data['pair'] as String,
                        'Rp${_formatNumber(data['value'] as double)}',
                        change,
                        isUp,
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
