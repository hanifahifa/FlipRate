// ------------------------------------------------------
// ANALYSIS PAGE - Final Polish
// Professional UI, Realtime Data, & Better Forecast Layout
// ------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/currency_repository.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  // ------------------------------------------------------
  // 🎨 THEME COLORS - Ditempatkan di bagian atas
  // ------------------------------------------------------
  static const Color primary = Color(
    0xFF043915,
  ); // 👈 UBAH DI SINI! (Sebelumnya primaryGreen)

  static const Color darkPrimary = Color(
    0xFF021C08,
  ); // Diambil dari warna yang lebih gelap dari primary

  static const Color lightBg = Color(0xFFF1F8E9); // Background

  // Warna yang lain
  static const Color greenAccent = Color(0xFF4CAF50);
  static const Color redAccent = Color(0xFFF44336);

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  // Akses warna statis dari StatefulWidget
  final Color primaryColor = AnalysisPage.primary;
  final Color darkPrimaryColor = AnalysisPage.darkPrimary;
  final Color lightBgColor = AnalysisPage.lightBg;
  final Color greenAccentColor = AnalysisPage.greenAccent;
  final Color redAccentColor = AnalysisPage.redAccent;

  // Data State
  List<Map<String, dynamic>> topGainers = [];
  List<Map<String, dynamic>> topLosers = [];
  Map<String, dynamic> predictions = {};
  bool isLoading = true;
  String errorMessage = '';

  // Static News (Dummy)
  final List<Map<String, dynamic>> marketInsights = [
    {
      'icon': Icons.trending_up,
      'color': AnalysisPage.greenAccent,
      'title': 'USD Menguat Tajam',
      'subtitle':
          'The Fed mempertahankan suku bunga, mendorong kepercayaan investor.',
      'time': '2 jam lalu',
    },
    {
      'icon': Icons.info_outline,
      'color': Colors.blue,
      'title': 'Update Pasar Asia',
      'subtitle':
          'SGD dan JPY menunjukkan volatilitas moderat di tengah isu dagang.',
      'time': '5 jam lalu',
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
      final allRates = await CurrencyRepository.getAllRates();

      // Sorting Logic
      allRates.sort((a, b) {
        double valA = _parseChange(a['change']);
        double valB = _parseChange(b['change']);
        return valB.compareTo(valA);
      });

      final gainers = allRates
          .where((r) => _parseChange(r['change']) > 0)
          .take(5)
          .toList();

      final losers = allRates
          .where((r) => _parseChange(r['change']) < 0)
          .toList();

      losers.sort((a, b) {
        double valA = _parseChange(a['change']);
        double valB = _parseChange(b['change']);
        return valA.compareTo(valB);
      });

      final topLosersList = losers.take(5).toList();

      if (!mounted) return;
      setState(() {
        topGainers = gainers;
        topLosers = topLosersList;
        isLoading = false;
      });
      _calculatePredictions();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'Gagal memuat data analisis. Cek koneksi internet.';
      });
    }
  }

  double _parseChange(String changeStr) {
    try {
      return double.parse(changeStr.replaceAll('%', '').replaceAll('+', ''));
    } catch (e) {
      return 0.0;
    }
  }

  void _calculatePredictions() {
    if (topGainers.isEmpty && topLosers.isEmpty) return;

    Map<String, dynamic> preds = {};
    // Fokus pada mata uang populer
    final List<String> mainCurrencies = ['USD', 'EUR', 'JPY', 'SGD', 'MYR'];
    final allProcessed = [...topGainers, ...topLosers];

    for (String cur in mainCurrencies) {
      double change = 0.0;
      try {
        final found = allProcessed.firstWhere(
          (element) => element['currency'] == cur,
          orElse: () => {},
        );
        if (found.isNotEmpty) change = _parseChange(found['change']);
      } catch (_) {}

      // Logic sederhana untuk menentukan "Outlook"
      String signal = 'NEUTRAL';
      String text = 'Pergerakan stabil, volatilitas rendah.';
      Color color = Colors.grey;

      if (change > 0.3) {
        signal = 'BULLISH'; // Naik
        text =
            'Tren penguatan terdeteksi. Potensi kenaikan berlanjut dalam jangka pendek.';
        color = greenAccentColor;
      } else if (change < -0.3) {
        signal = 'BEARISH'; // Turun
        text = 'Tekanan jual cukup tinggi. Waspadai penurunan lebih lanjut.';
        color = redAccentColor;
      }

      preds[cur] = {
        'signal': signal,
        'text': text,
        'color': color,
        'change': change,
      };
    }

    setState(() => predictions = preds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBgColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 140,
              floating: false,
              pinned: true,
              backgroundColor: primaryColor,
              elevation: 0,

              // --- PERUBAHAN DI SINI ---
              // Mengubah warna tombol back menjadi putih
              iconTheme: const IconThemeData(color: Colors.white),

              // -------------------------
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, darkPrimaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Market Analysis',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SF Pro',
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '● LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat(
                              'EEEE, dd MMM yyyy',
                            ).format(DateTime.now()),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: _loadAnalysisData,
          color: primaryColor,
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : errorMessage.isNotEmpty
              ? _buildErrorState()
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  children: [
                    _buildSectionHeader(
                      'Market Insights',
                      Icons.auto_graph_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildMarketNews(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Top Movers (24h)', Icons.bolt_rounded),
                    const SizedBox(height: 12),
                    _buildTopPerformersSection(),
                    const SizedBox(height: 24),
                    // JUDUL DIGANTI agar tidak "AI Prediction"
                    _buildSectionHeader('Market Outlook', Icons.radar_rounded),
                    const SizedBox(height: 12),
                    _buildForecastSection(), // Layout Baru
                    const SizedBox(height: 24),
                    _buildDisclaimer(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(errorMessage, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadAnalysisData,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C1C1E),
            fontFamily: 'SF Pro',
          ),
        ),
      ],
    );
  }

  Widget _buildMarketNews() {
    return Column(
      children: marketInsights.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (item['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item['icon'], color: item['color']),
            ),
            title: Text(
              item['title'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['subtitle'],
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['time'],
                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTopPerformersSection() {
    if (topGainers.isEmpty && topLosers.isEmpty) {
      return const Center(child: Text('Data belum tersedia'));
    }

    return Column(
      children: [
        if (topGainers.isNotEmpty)
          _buildMoverCard(
            'Top Gainers',
            topGainers,
            const Color(0xFFE8F5E9),
            greenAccentColor,
          ),
        const SizedBox(height: 16),
        if (topLosers.isNotEmpty)
          _buildMoverCard(
            'Top Losers',
            topLosers,
            const Color(0xFFFFEBEE),
            redAccentColor,
          ),
      ],
    );
  }

  Widget _buildMoverCard(
    String title,
    List<Map<String, dynamic>> data,
    Color bgColor,
    Color accent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(19),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          ...data.asMap().entries.map((entry) {
            final item = entry.value;
            final isLast = entry.key == data.length - 1;

            return Column(
              children: [
                ListTile(
                  leading: Text(
                    item['flag'],
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    item['currency'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    item['name'],
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item['change'],
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Divider(height: 1, indent: 70, color: Colors.grey[100]),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET: FORECAST CARD (DESAIN BARU)
  // ==========================================
  Widget _buildForecastSection() {
    if (predictions.isEmpty) return const SizedBox();

    return Column(
      children: predictions.entries.map((entry) {
        final currency = entry.key;
        final data = entry.value;
        final Color statusColor = data['color'];
        final flag = CurrencyRepository.getFlag(currency);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Indikator Warna di Kiri (Strip)
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(16),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Card: Flag, Code, Badge Signal
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  flag,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  currency,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF1C1C1E),
                                  ),
                                ),
                              ],
                            ),
                            // Badge Signal (Bullish/Bearish/Neutral)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: statusColor.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                data['signal'],
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Text Outlook
                        Text(
                          data['text'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Footer: Confidence Level (Bar)
                        Row(
                          children: [
                            Text(
                              'Confidence:',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: 0.85, // Dummy value for UI purpose
                                  backgroundColor: Colors.grey[200],
                                  color: statusColor.withOpacity(0.7),
                                  minHeight: 6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Disclaimer: Analisis ini dihasilkan berdasarkan data pergerakan 24 jam terakhir. Selalu lakukan riset mendalam sebelum mengambil keputusan finansial.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
