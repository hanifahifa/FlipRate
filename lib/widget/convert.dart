// ------------------------------------------------------
// CONVERT PAGE - FlipRate (SF Pro Version)
// Fitur konversi antar semua mata uang (real-time)
// dengan Auto-save Conversion History
// ------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
// ✅ IMPORT HistoryManager (sesuaikan path)
import '../utils/history_manager.dart';

class ConvertPage extends StatefulWidget {
  const ConvertPage({super.key});

  @override
  State<ConvertPage> createState() => _ConvertPageState();
}

class _ConvertPageState extends State<ConvertPage> {
  final TextEditingController _amountController = TextEditingController();
  String fromCurrency = 'USD';
  String toCurrency = 'IDR';
  double? convertedValue;
  bool isLoading = false;
  String errorMessage = '';

  Map<String, dynamic> currencyList = {};

  @override
  void initState() {
    super.initState();
    _fetchCurrencyList();
  }

  Future<void> _fetchCurrencyList() async {
    try {
      final response = await http
          .get(Uri.parse('https://open.er-api.com/v6/latest/USD'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        setState(() {
          currencyList = rates;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load currency list';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Unable to load data. Check your connection.';
      });
    }
  }

  Future<void> _convertCurrency() async {
    if (_amountController.text.isEmpty) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      setState(() {
        errorMessage = 'Enter a valid number';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
      convertedValue = null;
    });

    try {
      final response = await http
          .get(
            Uri.parse(
              'https://api.exchangerate-api.com/v4/latest/$fromCurrency',
            ),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;

        final rate = (rates[toCurrency] as num).toDouble();
        final result = amount * rate;

        // ✅ SIMPAN KE HISTORY SETELAH BERHASIL CONVERT
        try {
          await HistoryManager.addConversionHistory(
            fromAmount: amount,
            fromCode: fromCurrency,
            toAmount: result,
            toCode: toCurrency,
          );
          debugPrint(
            '💾 Conversion saved: $amount $fromCurrency → $result $toCurrency',
          );
        } catch (e) {
          debugPrint('❌ Failed to save conversion history: $e');
        }

        setState(() {
          convertedValue = result;
          isLoading = false;
        });

        // ✅ SHOW SUCCESS SNACKBAR
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✓ Conversion saved to history'),
              backgroundColor: const Color(0xFF2E7D32),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        throw Exception('API Error');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to convert. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Currency Converter',
          style: TextStyle(
            fontFamily: 'SF Pro',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: currencyList.isEmpty && errorMessage.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            )
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(99, 45, 120, 33),
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
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            labelStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _dropdownCurrency('From', fromCurrency, (
                                val,
                              ) {
                                setState(() => fromCurrency = val!);
                              }),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.swap_horiz,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _dropdownCurrency(
                                'To',
                                toCurrency,
                                (val) => setState(() => toCurrency = val!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: isLoading ? null : _convertCurrency,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Convert',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (convertedValue != null)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              'Converted Value',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${NumberFormat.currency(symbol: '', decimalDigits: 2).format(convertedValue)} $toCurrency',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _dropdownCurrency(
    String label,
    String current,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: current,
      dropdownColor: Colors.white,
      items: currencyList.keys
          .map((code) => DropdownMenuItem(value: code, child: Text(code)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
