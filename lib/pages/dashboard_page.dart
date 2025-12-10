// ------------------------------------------------------
// DASHBOARD PAGE - FlipRate (Fixed: Detailed Chart Labels)
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
import 'dart:ui'; // Untuk BackdropFilter
import 'addPages/detail_rate_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // UI State
  final ScrollController _scrollController = ScrollController();
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
  // FETCH POPULAR RATES
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
  // FETCH HISTORICAL DATA (3 Days)
  // ============================================
  Future<void> _fetchHistoricalData() async {
    setState(() {
      isChartLoading = true;
      chartErrorMessage = '';
    });

    try {
      final now = DateTime.now();
      List<FlSpot> spots = [];
      List<String> dates = [];

      for (int i = 3; i >= 0; i--) {
        final targetDate = now.subtract(Duration(days: i));

        try {
          final historicalRates =
              await ExchangeRateService.fetchHistoricalRates(
                baseCurrency: 'USD',
                daysAgo: i,
              );

          final idrRate =
              historicalRates['IDR'] ?? 15700.0; // Fallback jika null

          spots.add(FlSpot((3 - i).toDouble(), idrRate));
          dates.add(DateFormat('d MMM').format(targetDate));
        } catch (e) {
          // Fallback data dummy jika fetch gagal per hari
          spots.add(FlSpot((3 - i).toDouble(), 15700.0));
          dates.add(DateFormat('d MMM').format(targetDate));
        }
      }

      setState(() {
        chartData = spots;
        chartDates = dates;
        isChartLoading = false;
      });
    } catch (e) {
      print('❌ Dashboard Chart Error: $e');
      setState(() {
        isChartLoading = false;
        chartErrorMessage = 'Chart data unavailable';
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
  // HELPER: GET CHART INSIGHT (FIXED LOGIC)
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
      // Harga NAIK (15k -> 16k) = Rupiah MELEMAH
      direction = 'weakened';
      emoji = '📉'; // Panah turun (Nilai Rupiah turun)
    } else if (difference < 0) {
      // Harga TURUN (16k -> 15k) = Rupiah MENGUAT
      direction = 'strengthened';
      emoji = '📈'; // Panah naik (Nilai Rupiah naik)
    } else {
      return '➡️ IDR remains stable over the past 3 days';
    }

    return '$emoji IDR has $direction by ${percentageChange.abs().toStringAsFixed(2)}% (Rp${difference.abs().toStringAsFixed(0)}) in last few days';
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
      // 1. RefreshIndicator dipindah ke sini (Membungkus CustomScrollView)
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        color: const Color(0xFF2E7D32),
        backgroundColor: Colors.white,
        displacement:
            60, // Jarak indikator dari atas agar tidak tertutup AppBar
        edgeOffset: 120, // Sesuaikan dengan tinggi Expanded AppBar

        child: CustomScrollView(
          controller: _scrollController,
          // 2. Tambahkan physics ini agar bisa ditarik walau konten sedikit
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // AppBar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              stretch: true,
              backgroundColor: const Color(0xFF043915),
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
                      colors: [Color(0xFF043915), Color(0xFF2E7D32)],
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

            // Content Body
            SliverToBoxAdapter(
              // 3. RefreshIndicator di sini DIHAPUS, langsung ke Padding/Column
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _chartCard(),
                    const SizedBox(height: 20),
                    _quickAccessCard(context),
                    const SizedBox(height: 20),
                    _popularRatesCard(),
                    const SizedBox(height: 24),
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
          ],
        ),
      ),
    );
  }

  // ============================================
  // WIDGET: CHART CARD
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
                    'Last Few Days Trend',
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
                ? const Center(child: Text('No data'))
                : _buildChart(),
          ),

          const SizedBox(height: 16),

          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AnalysisPage()),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF2E7D32).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        isChartLoading
                            ? 'Menganalisis data pasar...'
                            : chartData.isNotEmpty
                            ? _getChartInsight()
                            : 'Data grafik tidak tersedia',
                        style: const TextStyle(
                          color: Color(0xFF1C1C1E),
                          fontSize: 13,
                          height: 1.5,
                          fontFamily: 'SF Pro',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Color(0xFF2E7D32),
                    ),
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
  // WIDGET: FL CHART BUILDER (Fixed Layout)
  // ============================================
  Widget _buildChart() {
    // 1. Hitung Range Y (Min & Max)
    final yValues = chartData.map((e) => e.y).toList();
    final minY = yValues.reduce((a, b) => a < b ? a : b);
    final maxY = yValues.reduce((a, b) => a > b ? a : b);

    final range = maxY - minY;
    final buffer = (range == 0) ? minY * 0.05 : range * 0.2;

    final finalMinY = minY - buffer;
    final finalMaxY = maxY + buffer;

    return LineChart(
      LineChartData(
        minY: finalMinY,
        maxY: finalMaxY,

        // Hapus padding chart default agar full width
        minX: chartData.first.x,
        maxX: chartData.last.x,

        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (range > 0) ? range / 3 : 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.15),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),

        borderData: FlBorderData(show: false),

        titlesData: FlTitlesData(
          show: true,

          // Sumbu Bawah (Tanggal)
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < chartDates.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      chartDates[index],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                        fontFamily: 'SF Pro',
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          // Sumbu Kiri (Harga) - DIPERBAIKI: Jarak Kiri Dihapus
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              // Ubah dari 70 jadi 44 (pas untuk angka 5 digit "16,xxx")
              reservedSize: 44,
              interval: (range > 0) ? range / 3 : 100,
              getTitlesWidget: (value, meta) {
                if (value == finalMinY || value == finalMaxY) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  // Padding kanan dikurangi jadi 4 biar lebih rapat ke garis
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    _formatNumber(value),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                      fontFamily: 'SF Pro',
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
            // Perbaikan warna tooltip (pakai warna container gelap)
            getTooltipColor: (spot) => const Color(0xFF1C1C1E),
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                final date = (index < chartDates.length)
                    ? chartDates[index]
                    : '';
                return LineTooltipItem(
                  '$date\nRp${_formatNumber(spot.y)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'SF Pro',
                  ),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),

        lineBarsData: [
          LineChartBarData(
            spots: chartData,
            isCurved: true,
            curveSmoothness: 0.35,
            color: const Color(0xFF2E7D32),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: const Color(0xFF2E7D32),
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2E7D32).withOpacity(0.25),
                  const Color(0xFF2E7D32).withOpacity(0.0),
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
  // WIDGET: QUICK ACCESS
  // ============================================
  Widget _quickAccessCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Quick Access',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 17,
              color: Color(0xFF1C1C1E),
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _quickButtonGlass(
                  Icons.currency_exchange_rounded,
                  'All Rates',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllRatesWidget(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _quickButtonGlass(
                  Icons.analytics_outlined,
                  'Analysis',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnalysisPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _quickButtonGlass(
                  Icons.swap_horiz_rounded,
                  'Convert',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConvertPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _quickButtonGlass(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              const Color(
                0xFFD3ECCD,
              ).withOpacity(0.15), // Center - lebih transparan
              const Color(0xFFD3ECCD).withOpacity(0.35), // Edge - lebih solid
            ],
            stops: const [0.3, 1.0],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF2E7D32).withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            // Inner glow untuk efek glass
            BoxShadow(
              color: const Color(0xFFD3ECCD).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(icon, color: const Color(0xFF2E7D32), size: 32),
            const SizedBox(height: 12),
            // Label
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF1C1C1E),
                letterSpacing: -0.1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // WIDGET: POPULAR RATES
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
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchPopularRates,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: popularRates.length,
                  separatorBuilder: (context, _) => const Divider(
                    thickness: 0.5,
                    color: Color(0xFFF2F2F7),
                    height: 0,
                  ),
                  itemBuilder: (context, i) {
                    final data = popularRates[i];
                    return _currencyListTile(
                      data['pair'],
                      'Rp${_formatNumber(data['value'])}',
                      data['change'],
                      data['isUpValue'],
                      data['flag'],
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailRatePage(rateData: data),
                          ),
                        );
                      },
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
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
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
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8E8E93),
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
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
