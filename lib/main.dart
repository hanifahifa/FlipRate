import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'widget/navbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const FlipRateApp());
}

class FlipRateApp extends StatelessWidget {
  const FlipRateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlipRate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      home: const Navbar(),
    );
  }
}
