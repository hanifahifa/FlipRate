// ------------------------------------------------------
// ALL RATES WIDGET - FlipRate (Final + Detail Navigation)
// ------------------------------------------------------

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../pages/detail_rate_page.dart'; // ⬅️ tambahkan import ini
import '../utils/history_manager.dart';


class AllRatesWidget extends StatefulWidget {
  const AllRatesWidget({super.key});

  @override
  State<AllRatesWidget> createState() => _AllRatesWidgetState();
}

class _AllRatesWidgetState extends State<AllRatesWidget> {
  List<Map<String, dynamic>> allRates = [];
  List<Map<String, dynamic>> filteredRates = [];
  Map<String, double> yesterdayRates = {};
  bool isLoading = true;
  String errorMessage = '';
  final _searchController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    fetchYesterdayRates().then((_) => fetchRates());
    _searchController.addListener(_filterRates);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // =====================================================
  // FETCH DATA API
  // =====================================================
  Future<void> fetchRates() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final apis = [
      'https://api.exchangerate-api.com/v4/latest/USD',
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json',
      'https://api.frankfurter.app/latest?from=USD',
    ];

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

        final list =
            rates.entries.where((e) => e.key.toUpperCase() != 'IDR').map((e) {
              final cur = e.key.toUpperCase();
              final val = idrRate / (e.value as num).toDouble();
              return {
                'currency': cur,
                'name': currencyNames[cur] ?? cur,
                'flag': currencyFlags[cur] ?? '🏳️',
                'rate': val,
                'change': _calcChange(cur, val),
              };
            }).toList()..sort(
              (a, b) =>
                  a['currency'].toString().compareTo(b['currency'].toString()),
            );

        setState(() {
          allRates = list;
          filteredRates = list;
          isLoading = false;
        });
        return;
      } catch (e) {
        if (i == apis.length - 1) {
          setState(() {
            isLoading = false;
            errorMessage =
                'Failed to fetch rates. Please check your connection.';
          });
        }
      }
    }
  }

  // =====================================================
  // FETCH HARGA KEMARIN
  // =====================================================
  Future<void> fetchYesterdayRates() async {
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
            setState(() {
              yesterdayRates = Map<String, double>.from(
                data['rates'].map(
                  (k, v) => MapEntry(
                    k.toString().toUpperCase(),
                    (v as num).toDouble(),
                  ),
                ),
              );
            });
            print("✅ Yesterday rates loaded from $url");
            return;
          }
        }
      } catch (e) {
        print("⚠️ Error fetching yesterday rates from $url: $e");
      }
    }

    setState(() => yesterdayRates = {});
  }

  // =====================================================
  // UI BUILD
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('All Rates', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchYesterdayRates();
          await fetchRates();
        },
        color: const Color(0xFF2E7D32),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF2E7D32),
                  ),
                  hintText: 'Search currency...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2E7D32),
                      ),
                    )
                  : errorMessage.isNotEmpty
                  ? Center(child: Text(errorMessage))
                  : filteredRates.isEmpty
                  ? const Center(child: Text('No data found'))
                  : ListView.builder(
                      itemCount: filteredRates.length,
                      itemBuilder: (context, i) =>
                          _buildCard(filteredRates[i], context),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // ITEM CARD DENGAN NAVIGASI KE DETAIL
  // =====================================================
  Widget _buildCard(Map<String, dynamic> r, BuildContext context) {
    final isUp = r['change'].toString().startsWith('+');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailRatePage(rateData: r)),
          );
         HistoryManager.addRecentlyViewed(r['currency'], 'IDR');
        },
        leading: Text(r['flag'], style: const TextStyle(fontSize: 28)),
        title: Text(
          r['currency'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(r['name']),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Rp${_fmt(r['rate'])}',
              style: const TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              r['change'],
              style: TextStyle(color: isUp ? Colors.green : Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  void _filterRates() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredRates = allRates.where((r) {
        final name = (r['name'] ?? '').toString().toLowerCase();
        final code = (r['currency'] ?? '').toString().toLowerCase();
        return name.contains(query) || code.contains(query);
      }).toList();
    });
  }

  String _fmt(double n) => NumberFormat('#,###.##').format(n);

  String _calcChange(String cur, double todayRate) {
    if (yesterdayRates.isEmpty || !yesterdayRates.containsKey(cur))
      return '0.00%';
    final yesterday = yesterdayRates[cur]!;
    final diff = todayRate - yesterday;
    final percent = (diff / yesterday) * 100;
    final sign = percent >= 0 ? '+' : '-';
    return '$sign${percent.abs().toStringAsFixed(2)}%';
  }
}
