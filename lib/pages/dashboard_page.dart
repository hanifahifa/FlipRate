// ------------------------------------------------------
// DASHBOARD PAGE - FlipRate (Integrated with Backend)
// iPhone-Style Professional UI + Backend Logic
// ------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../repositories/currency_repository.dart';
import '../services/exchange_rate_service.dart';
import '../widget/all_rates.dart';
import '../widget/convert.dart';
import '../widget/analysis.dart';
import '../widget/notification.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // UI State
  ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  // Data State
  List<Map<String, dynamic>> popularRates = [];
  List<FlSpot> chartData = [];
  List<String> chartDates = [];
  bool isLoading = true;
  bool isChartLoading = true;
  String errorMessage = '';
  String chartErrorMessage = '';

  final List<String> popularCurrencies = ['USD', 'EUR', 'JPY', 'SGD'];

  @override
  void initState() {
    super.initState();
    _initData();

    _scrollController.addListener(() {
      if (_scrollController.offset > 50 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 50 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ============================================
  // INITIALIZE DATA
  // ============================================
  Future<void> _initData() async {
    await Future.wait([_fetchPopularRates(), _fetchHistoricalData()]);
  }

  // ============================================
  // FETCH POPULAR RATES (Using Repository)
  // ============================================
  Future<void> _fetchPopularRates() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final rates = await CurrencyRepository.getPopularRates(
        currencies: popularCurrencies,
      );

      setState(() {
        popularRates = rates.map((rate) {
          return {
            'pair': '${rate['currency']} → IDR',
            'currency': rate['currency'],
            'value': rate['rate'] as double,
            // 'change' di sini SUDAH STRING (misal: "+0.20%") dari Repo
            'change': rate['change'],
            'isUpValue': rate['isUp'] as bool,
            'flag': rate['flag'],
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('❌ Dashboard Error: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Unable to fetch rates.';
      });
    }
  }

  // ============================================
  // FETCH HISTORICAL DATA (3 Days for Chart)
  // ============================================
  Future<void> _fetchHistoricalData() async {
    setState(() {
      isChartLoading = true;
      chartErrorMessage = '';
    });

    try {
      print('🔄 Dashboard: Fetching historical data...');

      final now = DateTime.now();
      List<FlSpot> spots = [];
      List<String> dates = [];

      // Fetch data for the last 4 days (including today)
      for (int i = 3; i >= 0; i--) {
        final targetDate = now.subtract(Duration(days: i));
        final formattedDate = DateFormat('yyyy-MM-dd').format(targetDate);

        try {
          final historicalRates =
              await ExchangeRateService.fetchHistoricalRates(
                baseCurrency: 'USD',
                daysAgo: i,
              );

          final idrRate = historicalRates['IDR'] ?? 15700.0;

          spots.add(FlSpot((3 - i).toDouble(), idrRate));
          dates.add(DateFormat('d MMM').format(targetDate));

          print('✅ Got rate for $formattedDate: $idrRate');
        } catch (e) {
          print('⚠️ Failed to fetch data for $formattedDate: $e');
          // Use fallback data for this day
          spots.add(FlSpot((3 - i).toDouble(), 15700.0));
          dates.add(DateFormat('d MMM').format(targetDate));
        }
      }

      setState(() {
        chartData = spots;
        chartDates = dates;
        isChartLoading = false;
      });

      print('✅ Dashboard: Chart data loaded (${chartData.length} points)');
    } catch (e) {
      print('❌ Dashboard Chart Error: $e');

      // Fallback data
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

  // ============================================
  // HELPER: FORMAT NUMBER
  // ============================================
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

  // ============================================
  // HELPER: GET CHART INSIGHT
  // ============================================
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

  // ============================================
  // REFRESH ALL DATA
  // ============================================
  Future<void> _refreshAll() async {
    await Future.wait([_fetchPopularRates(), _fetchHistoricalData()]);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Modern iOS-style App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFF388E3C),
            title: AnimatedOpacity(
              opacity: _isScrolled ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: const Text(
                'FlipRate',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF388E3C), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedOpacity(
                          opacity: _isScrolled ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: const Text(
                            'FlipRate',
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedOpacity(
                          opacity: _isScrolled ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            today,
                            style: const TextStyle(
                              fontFamily: 'SF Pro',
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 12, top: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: RefreshIndicator(
              onRefresh: _refreshAll,
              color: const Color(0xFF2E7D32),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chart Card
                    _chartCard(),
                    const SizedBox(height: 20),

                    // Quick Access Card
                    _quickAccessCard(context),
                    const SizedBox(height: 20),

                    // Popular Rates Card
                    _popularRatesCard(),
                    const SizedBox(height: 24),

                    // Footer
                    Center(
                      child: Text(
                        '© 2025 FlipRate – Smart Currency Converter',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // CHART CARD - iPhone Style
  // ============================================
  Widget _chartCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'USD to IDR',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      color: Color(0xFF1C1C1E),
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '3 Days Trend',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8E8E93),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              if (!isChartLoading && chartData.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Rp${_formatNumber(chartData.last.y)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: isChartLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2E7D32),
                      strokeWidth: 2.5,
                    ),
                  )
                : chartData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.insert_chart_outlined_rounded,
                          color: Colors.grey[300],
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          chartErrorMessage.isEmpty
                              ? 'No chart data available'
                              : chartErrorMessage,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildChart(),
          ),
          if (chartErrorMessage.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    chartErrorMessage,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            isChartLoading
                ? 'Loading historical data...'
                : chartData.isNotEmpty
                ? _getChartInsight()
                : 'Chart data unavailable',
            style: TextStyle(
              color: const Color(0xFF1C1C1E),
              fontSize: 13,
              fontWeight: chartData.isNotEmpty
                  ? FontWeight.w500
                  : FontWeight.w400,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // BUILD CHART
  // ============================================
  Widget _buildChart() {
    final minY = chartData.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final maxY = chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final range = maxY - minY;
    final padding = range * 0.12;

    return LineChart(
      LineChartData(
        minY: minY - padding,
        maxY: maxY + padding,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (range > 0) ? range / 4 : null,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: const Color(0xFFF2F2F7), strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < chartDates.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      chartDates[index],
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8E8E93),
                        letterSpacing: -0.2,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 65,
              interval: range / 4,
              getTitlesWidget: (value, meta) {
                final formatted = NumberFormat('#,###').format(value.round());
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    formatted,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF8E8E93),
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.2,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => const Color(0xFF1C1C1E),
            tooltipRoundedRadius: 12,
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                final date = index < chartDates.length ? chartDates[index] : '';
                return LineTooltipItem(
                  '$date\nRp${_formatNumber(spot.y)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    height: 1.4,
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
                      radius: 5,
                      color: Colors.white,
                      strokeWidth: 2.5,
                      strokeColor: const Color(0xFF2E7D32),
                    );
                  },
                ),
              );
            }).toList();
          },
        ),
        lineBarsData: [
          LineChartBarData(
            spots: chartData,
            isCurved: true,
            curveSmoothness: 0.4,
            color: const Color(0xFF2E7D32),
            barWidth: 3,
            isStrokeCapRound: true,
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
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2E7D32).withOpacity(0.2),
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

  // ============================================
  // QUICK ACCESS CARD - iPhone Style
  // ============================================
  Widget _quickAccessCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Access',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 17,
              color: Color(0xFF1C1C1E),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _quickButton(Icons.currency_exchange_rounded, 'All Rates', () {
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
                  MaterialPageRoute(builder: (context) => const AnalysisPage()),
                );
              }),
              _quickButton(Icons.swap_horiz_rounded, 'Convert', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ConvertPage()),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickButton(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF2E7D32), size: 30),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 68,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1C1C1E),
                height: 1.2,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // POPULAR RATES CARD - iPhone Style
  // ============================================
  Widget _popularRatesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popular Rates',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 17,
              color: Color(0xFF1C1C1E),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(
                      color: Color(0xFF2E7D32),
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              : errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: Colors.grey[400],
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchPopularRates,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: popularRates.length,
                  separatorBuilder: (context, _) => const Divider(
                    thickness: 0.5,
                    color: Color(0xFFF2F2F7),
                    height: 1,
                  ),
                  // Di dalam ListView.separated dashboard_page.dart
                  itemBuilder: (context, i) {
                    final data = popularRates[i];

                    // Ambil data yang sudah matang dari Map
                    final String change = data['change']; // Ini sudah "+0.50%"
                    final bool isUp = data['isUpValue'];

                    return _currencyListTile(
                      data['pair'],
                      'Rp${_formatNumber(data['value'])}',
                      change, // Kirim string langsung
                      isUp,
                      data['flag'],
                    );
                  },
                ),
        ],
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(flag, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pair,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isUp
                  ? const Color(0xFF34C759).withOpacity(0.1)
                  : const Color(0xFFFF3B30).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUp
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: isUp
                      ? const Color(0xFF34C759)
                      : const Color(0xFFFF3B30),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  change,
                  style: TextStyle(
                    color: isUp
                        ? const Color(0xFF34C759)
                        : const Color(0xFFFF3B30),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
