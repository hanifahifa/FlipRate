// ------------------------------------------------------
// ANALYSIS PAGE - Refactored (Using Repository)
// Sesuai Spesifikasi: UI terpisah dari Logic Data
// ------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/currency_repository.dart'; // Import Repository

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  // Theme Colors
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFFF1F8E9);
  
  // Data State
  List<Map<String, dynamic>> topGainers = [];
  List<Map<String, dynamic>> topLosers = [];
  Map<String, dynamic> predictions = {};
  
  // UI State
  bool isLoading = true;
  String errorMessage = '';

  // Static Data (News - Hardcoded as per design)
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
      'subtitle': 'SGD and JPY show moderate volatility amid regional trade talks',
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

  // ==========================================
  // LOGIC: LOAD DATA VIA REPOSITORY
  // ==========================================
  Future<void> _loadAnalysisData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // 1. Ambil semua data rate yang sudah diproses oleh Repository
      // Data sudah berisi: currency, flag, name, rate, change (String format)
      final allRates = await CurrencyRepository.getAllRates();

      // 2. Sorting Logic (Dilakukan di UI/ViewModel karena ini kebutuhan Tampilan)
      // Kita perlu convert string "+0.50%" kembali ke double untuk sorting
      allRates.sort((a, b) {
        double valA = _parseChange(a['change']);
        double valB = _parseChange(b['change']);
        return valB.compareTo(valA); // Descending (Besar ke Kecil)
      });

      // 3. Ambil Top 5 Gainers (Teratas)
      final gainers = allRates.where((r) => _parseChange(r['change']) > 0).take(5).toList();
      
      // 4. Ambil Top 5 Losers (Terbawah)
      // Reverse list untuk mendapatkan nilai minus terbesar
      final losers = allRates.where((r) => _parseChange(r['change']) < 0).toList();
      losers.sort((a, b) {
        double valA = _parseChange(a['change']);
        double valB = _parseChange(b['change']);
        return valA.compareTo(valB); // Ascending (Kecil ke Besar / Minus Gede)
      });
      final topLosersList = losers.take(5).toList();

      if (mounted) {
        setState(() {
          topGainers = gainers;
          topLosers = topLosersList;
          isLoading = false;
        });
        
        // 5. Hitung Prediksi setelah data masuk
        _calculatePredictions();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Gagal memuat data analisis.';
        });
      }
    }
  }

  // Helper untuk parsing string persen ke double (misal: "+0.50%" -> 0.50)
  double _parseChange(String changeStr) {
    try {
      String clean = changeStr.replaceAll('%', '').replaceAll('+', '');
      return double.parse(clean);
    } catch (e) {
      return 0.0;
    }
  }

  // ==========================================
  // LOGIC: PREDICTIONS
  // ==========================================
  void _calculatePredictions() {
    if (topGainers.isEmpty && topLosers.isEmpty) return;

    Map<String, dynamic> preds = {};
    // Prediksi hanya untuk mata uang utama
    final List<String> mainCurrencies = ['USD', 'EUR', 'JPY', 'SGD'];
    
    // Gabungkan list untuk pencarian
    final allProcessed = [...topGainers, ...topLosers];

    for (String cur in mainCurrencies) {
      // Cari data mata uang tersebut di hasil fetch
      // Karena allProcessed mungkin tidak lengkap (cuma top 5), 
      // idealnya kita cari di allRates, tapi untuk simpel kita default 0
      
      double change = 0.0;
      try {
        final found = allProcessed.firstWhere(
          (element) => element['currency'] == cur, 
          orElse: () => {}
        );
        if (found.isNotEmpty) {
          change = _parseChange(found['change']);
        }
      } catch (_) {}

      String trend;
      String confidence;
      String text;

      if (change > 1.0) {
        trend = 'up';
        confidence = 'high';
        text = 'Momentum kenaikan kuat';
      } else if (change > 0.0) { // Sedikit naik
        trend = 'up';
        confidence = 'moderate';
        text = 'Cenderung menguat';
      } else if (change < -1.0) {
        trend = 'down';
        confidence = 'high';
        text = 'Tekanan jual tinggi';
      } else if (change < 0.0) { // Sedikit turun
        trend = 'down';
        confidence = 'moderate';
        text = 'Sedikit melemah';
      } else {
        trend = 'stable';
        confidence = 'high';
        text = 'Stabil / Belum ada data signifikan';
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

  // ==========================================
  // UI BUILD (Tetap mempertahankan SF Pro Style)
  // ==========================================
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
              fontSize: 20,
            ),
          ),
          backgroundColor: primaryGreen,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
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
              ? const Center(child: CircularProgressIndicator(color: primaryGreen))
              : errorMessage.isNotEmpty
                  ? _buildErrorState()
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 24),
                          
                          // News
                          _buildSectionTitle('Market News & Insights', Icons.newspaper),
                          const SizedBox(height: 12),
                          _buildMarketNews(),
                          const SizedBox(height: 24),

                          // Top Performers
                          _buildSectionTitle('Top Performers (24h)', Icons.trending_up),
                          const SizedBox(height: 12),
                          _buildTopPerformersSection(),
                          const SizedBox(height: 24),

                          // Predictions
                          _buildSectionTitle('Market Predictions', Icons.insights),
                          const SizedBox(height: 12),
                          _buildPredictionsSection(),
                          const SizedBox(height: 24),

                          _buildDisclaimer(),
                          const SizedBox(height: 16),
                        ],
                      ),
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
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(errorMessage, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAnalysisData,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
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
                child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Currency Market Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
                style: const TextStyle(fontSize: 13, color: Colors.white70),
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
          final isLast = entry.key == marketInsights.length - 1;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(item['icon'], color: item['color'], size: 20),
                ),
                title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(item['subtitle'], style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(item['time'], style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1, indent: 68),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopPerformersSection() {
    if (topGainers.isEmpty && topLosers.isEmpty) {
      return _buildEmptyState('No performance data available');
    }

    return Column(
      children: [
        if (topGainers.isNotEmpty)
          _buildPerformerCard('🏆 Top Gainers', topGainers, Colors.green),
        const SizedBox(height: 16),
        if (topLosers.isNotEmpty)
          _buildPerformerCard('📉 Biggest Losers', topLosers, Colors.red),
      ],
    );
  }

  Widget _buildPerformerCard(String title, List<Map<String, dynamic>> data, Color accentColor) {
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
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: accentColor),
            ),
          ),
          ...data.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            // Data sudah dalam format repository
            final changeStr = item['change']; // "+0.50%"
            final changeVal = _parseChange(changeStr);
            final isPositive = changeVal >= 0;

            return Column(
              children: [
                if (index > 0) Divider(height: 1, indent: 68, color: Colors.grey[200]),
                ListTile(
                  leading: Text(item['flag'], style: const TextStyle(fontSize: 24)),
                  title: Text(item['currency'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item['name'], style: const TextStyle(fontSize: 12)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      changeStr,
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPredictionsSection() {
    if (predictions.isEmpty) return _buildEmptyState('Calculating predictions...');
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: predictions.entries.map((entry) {
           final currency = entry.key;
           final data = entry.value;
           // Ambil flag dari Repo helper jika tidak ada di map
           final flag = CurrencyRepository.getFlag(currency); 
           
           return ListTile(
             leading: Text(flag, style: const TextStyle(fontSize: 28)),
             title: Text(currency, style: const TextStyle(fontWeight: FontWeight.bold)),
             subtitle: Text(data['text'], style: TextStyle(fontSize: 12, color: Colors.grey[700])),
             trailing: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               crossAxisAlignment: CrossAxisAlignment.end,
               children: [
                 Icon(
                   data['trend'] == 'up' ? Icons.trending_up : Icons.trending_down,
                   color: data['trend'] == 'up' ? Colors.green : (data['trend'] == 'down' ? Colors.red : Colors.grey),
                 ),
                 Text(
                   data['confidence'].toUpperCase(),
                   style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                 )
               ],
             ),
           );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.analytics_outlined, size: 52, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(message, style: TextStyle(color: Colors.grey[600])),
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
        border: Border.all(color: Colors.orange.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Disclaimer: Prediksi hanya referensi. Selalu lakukan riset sendiri sebelum mengambil keputusan finansial.',
              style: TextStyle(fontSize: 11, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}