// ------------------------------------------------------
// ACTIVITY PAGE - Refactored (Clean Architecture)
// Menggunakan Repository untuk fetch rate terkini
// Menggunakan HistoryManager untuk data lokal
// ------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/currency_repository.dart'; // Import Repo
import '../utils/history_manager.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  static const Color primaryGreen = Color(0xFF043915);
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

  Future<void> _loadAllData() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    // 1. Load History (Lokal)
    await _loadConversionHistory();

    // 2. Load Recently Viewed (Lokal + Fetch Rate Terbaru via Repo)
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
    }
  }

  /// Mengambil recently viewed dan update rate terkini via Repository
  Future<void> _loadRecentlyViewed() async {
    try {
      final viewed = await HistoryManager.getRecentlyViewed();
      final List<Map<String, dynamic>> tempViewed = [];

      for (final item in viewed) {
        if (!mounted) break;

        final from = item['from'] as String;
        final to = item['to'] as String;
        final dt = item['time'] as DateTime;

        // PERUBAHAN UTAMA: Panggil Repository, bukan HTTP langsung
        final rate = await CurrencyRepository.getExchangeRate(
          from: from,
          to: to,
        );

        tempViewed.add({
          'pair': '$from → $to',
          'when': dt,
          'from': from,
          'to': to,
          'rate': rate,
        });
      }

      if (mounted) {
        setState(() {
          recentlyViewed = tempViewed;
        });
      }
    } catch (e) {
      debugPrint('Error loading recently viewed: $e');
    }
  }

  // Logic Insight (Client Side Logic - Aman di UI)
  String buildInsight() {
    if (conversionHistory.isEmpty) {
      return 'Start converting currencies to get personalized insights.';
    }

    Map<String, int> currencyCount = {};

    for (var conversion in conversionHistory) {
      final fromCode = conversion['fromCode'] as String;
      currencyCount[fromCode] = (currencyCount[fromCode] ?? 0) + 1;
    }

    String mostUsedCurrency = '';
    int maxCount = 0;

    currencyCount.forEach((currency, count) {
      if (count > maxCount) {
        maxCount = count;
        mostUsedCurrency = currency;
      }
    });

    if (mostUsedCurrency.isNotEmpty) {
      //final conversionCount = conversionHistory.length;
      return 'Anda sering menukar $mostUsedCurrency ($maxCount kali). Pantau terus pergerakan kurs ini!';
    }

    if (recentlyViewed.isNotEmpty) {
      final recentPair = recentlyViewed.first['pair'] as String;
      return 'Anda baru saja melihat kurs $recentPair. Cek kembali untuk update terbaru.';
    }

    return 'Pantau terus aktivitas tukar mata uang Anda di sini.';
  }

  String relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    if (diff.inDays == 1) return 'yesterday';
    return '${diff.inDays} days ago';
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
              fontSize: 20,
            ),
          ),
          backgroundColor: Color(0xFF043915),
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
                      // Header Gradient
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
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInsightCard(),
                          ],
                        ),
                      ),

                      // Content Area
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Recently Viewed
                            _buildSectionTitle(
                              'Recently Viewed',
                              Icons.remove_red_eye_outlined,
                            ),
                            const SizedBox(height: 12),
                            _buildRecentlyViewedSection(),
                            const SizedBox(height: 20),

                            // Conversion History
                            _buildSectionTitle(
                              'Conversion History',
                              Icons.history,
                            ),
                            const SizedBox(height: 12),
                            _buildHistorySection(),

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
              color: Color.fromARGB(255, 230, 215, 0),
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

  Widget _buildRecentlyViewedSection() {
    if (recentlyViewed.isEmpty) {
      return _buildEmptyState('No recently viewed currencies');
    }

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
              if (!showAllRecentlyViewed &&
                  recentlyViewed.length > 3 &&
                  index == 3) {
                return _buildSeeMoreButton(() {
                  setState(() => showAllRecentlyViewed = true);
                });
              }

              final r = displayedViewed[index];
              // Mengambil flag dari Repo helper
              final flag = CurrencyRepository.getFlag(r['from']);

              return Padding(
                padding: const EdgeInsets.only(right: 10),
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
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Text(flag, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                r['pair'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                r['rate'] > 0
                                    ? _formatRate(r['rate'])
                                    : 'Loading...',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                relativeTime(r['when']),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (showAllRecentlyViewed && recentlyViewed.length > 3)
          _buildShowLessButton(() {
            setState(() => showAllRecentlyViewed = false);
          }),
      ],
    );
  }

  Widget _buildHistorySection() {
    if (conversionHistory.isEmpty) {
      return _buildEmptyState('No conversion history yet');
    }

    final displayedHistory = showAllHistory
        ? conversionHistory
        : conversionHistory.take(4).toList();

    return Column(
      children: [
        ...displayedHistory.asMap().entries.map((entry) {
          final c = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
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
                            Flexible(
                              child: Text(
                                '${NumberFormat('#,###.##', 'id_ID').format(c['toAmount'])} ${c['toCode']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: primaryGreen,
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
                              size: 11,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              relativeTime(c['time']),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
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
          );
        }),
        if (conversionHistory.length > 4)
          InkWell(
            onTap: () => setState(() => showAllHistory = !showAllHistory),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    showAllHistory ? 'Show Less' : 'See More',
                    style: const TextStyle(
                      color: primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    showAllHistory
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: primaryGreen,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(String msg) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(msg, style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }

  Widget _buildSeeMoreButton(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: primaryGreen.withOpacity(0.3)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_forward, color: primaryGreen),
            Text(
              'See\nMore',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowLessButton(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Show Less',
              style: TextStyle(
                color: primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.keyboard_arrow_up, color: primaryGreen),
          ],
        ),
      ),
    );
  }
}
